#!/usr/bin/env python3
"""Build/run a verified cyclic forward NTT using existing Relin arithmetic/DMA."""
import argparse
from datetime import datetime
import hashlib
import json
from pathlib import Path
import re
import statistics
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'software_model'))
from matched_ntt_vectors import generate


def source_files(vivado):
    files = []
    # Reuse the existing project's arithmetic source list. Avoid compiling
    # unused Barrett/K2RED implementations and unrelated testbenches.
    listing = ROOT / 'HBM_interface/src/rtl/kernel/sources'
    for line in listing.read_text().splitlines():
        if line.startswith('../TP-NTT/') and Path(line).suffix in ('.v', '.sv'):
            files.append(ROOT / line[3:])
    files += [ROOT / p for p in (
        'src/util/shift_reg.sv', 'src/util/shift_reg_arr.sv',
        'src/relin/relin_ntt_wrapper.sv', 'src/hbm/dma_rx.sv',
        'src/hbm/dma_tx.sv', 'src/tb/axi_ram.sv',
        'HBM_interface/src/rtl/kernel/fifo_sync_v80.sv',
        'src/benchmark/matched_ntt.sv', 'src/benchmark/matched_ntt_tb.sv')]
    files.append(vivado / 'data/verilog/src/glbl.v')
    return sorted(set(files))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--vivado', type=Path, default=Path('/opt/Xilinx/2025.1/Vivado'))
    parser.add_argument('--output', type=Path)
    parser.add_argument('--seed', type=int, default=1)
    parser.add_argument('--tp', type=int, choices=(8, 16, 32), default=16)
    parser.add_argument('--repeats', type=int, default=11)
    parser.add_argument('--memory-model', choices=('behavioral-hbm', 'sram'),
                        default='behavioral-hbm',
                        help='AXI RAM timing: 8-cycle behavioral HBM or 1-cycle SRAM; transfers remain timed')
    parser.add_argument('--compile-only', action='store_true')
    args = parser.parse_args()
    read_latency = 1 if args.memory_model == 'sram' else 8
    if args.repeats < 1:
        parser.error('--repeats must be positive')
    output = (args.output or ROOT / 'build' / ('matched-ntt-' + datetime.now().strftime('%Y%m%d-%H%M%S-%f'))).resolve()
    output.mkdir(parents=True, exist_ok=False)
    vectors = output / 'vectors'
    generate(vectors, args.seed, args.tp)
    files = source_files(args.vivado)
    includes = sorted({str(p.parent) for p in files} | {str(ROOT / 'TP-NTT/modmul/src/def')})
    manifest = dict(format='relin-matched-ntt-run/1', time=datetime.now().astimezone().isoformat(),
                    n=1024, q=3221225473, root=1855261384, tp=args.tp, modular_multipliers=args.tp*5, partition=({8:[8,2,8,8], 16:[16,4,16], 32:[32,32]}[args.tp]), clock_mhz=250,
                    seed=args.seed, repeats=args.repeats, execution='XSim; ' + args.memory_model,
                    memory=dict(ports=3*args.tp//8, bits_per_port=256, input_ports=args.tp//8, twiddle_ports=args.tp//8,
                                output_ports=args.tp//8, read_latency_cycles=read_latency, burst_beats=1024//args.tp,
                                model=args.memory_model, burst_beats_per_cycle=1,
                                first_read_handshake_cycles=1 if args.memory_model == 'sram' else 9,
                                twiddle_source='separate preinitialized RAM; core twiddle loading is timed'),
                    boundary='device start acceptance through halt after all output AXI write responses',
                    includes=['operand and twiddle DMA reads', 'parameter/twiddle loading', 'input streaming',
                              'forward cyclic NTT', 'natural-order output permutation', 'output DMA and write responses'],
                    excludes=['host preload', 'host start write transport', 'host polling', 'software verification'],
                    vbfly_reference=dict(cycles_median=1874, latency_us=7.496, repeats=11,
                                         boundary='start-to-halt', bitstream_revision=None,
                                         memory_conditions_verified=False),
                    rtl_check='not run', measured_result=None,
                    source_sha256={str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest()
                                   for p in files + [Path(__file__).resolve(), ROOT / 'software_model/matched_ntt_vectors.py']
                                   if p.is_relative_to(ROOT)})
    manifest_path = output / 'run.json'
    def save():
        manifest_path.write_text(json.dumps(manifest, indent=2) + '\n')
    save()
    commands = []
    def run(argv, name):
        commands.append(dict(argv=[str(x) for x in argv], log=name+'.log'))
        manifest['commands'] = commands
        save()
        with (output / (name+'.log')).open('w') as log:
            completed = subprocess.run([str(x) for x in argv], cwd=output, stdout=log, stderr=subprocess.STDOUT, timeout=300)
        content = (output / (name+'.log')).read_text(errors='replace')
        print(content[-2000:])
        if completed.returncode:
            raise RuntimeError(f'{name} exited {completed.returncode}: {output / (name+".log")}')
        return content
    try:
        compile_cmd = [args.vivado / 'bin/xvlog', '--sv', '--relax']
        for directory in includes:
            compile_cmd.extend(['-i', directory])
        compile_cmd.extend(files)
        run(compile_cmd, 'compile')
        run([args.vivado / 'bin/xelab', '--relax', '--debug', 'typical', '--mt', '8',
             '-L', 'unisims_ver', '-L', 'unimacro_ver', '-L', 'secureip', '-L', 'xpm',
             '-generic_top', f'LOGTP={args.tp.bit_length()-1}',
             '-generic_top', f'MEMORY_READ_LATENCY={read_latency}',
             '-s', 'matched_ntt', 'work.matched_ntt_tb', 'work.glbl'], 'elaborate')
        manifest['elaboration'] = 'passed'
        save()
        if args.compile_only:
            print(f'Compile/elaboration PASS; RTL execution not run. Evidence: {output}')
            return
        text = run([args.vivado / 'bin/xsim', 'matched_ntt', '-runall',
                    '-testplusarg', f'VECTOR_DIR={vectors}',
                    '-testplusarg', f'REPEATS={args.repeats}'], 'simulate')
        rows = re.findall(rf'MATCHED_NTT_RESULT: run=(\d+) n=1024 q=3221225473 tp={args.tp} cycles=(\d+) core_cycles=(\d+) checked=1024 PASS', text)
        if len(rows) != args.repeats or f'MATCHED_NTT_PASS: repeats={args.repeats}' not in text:
            raise RuntimeError('Missing complete functional/timing evidence')
        cycles = [int(row[1]) for row in rows]
        core = [int(row[2]) for row in rows]
        manifest['rtl_check'] = 'passed'
        manifest['measured_result'] = dict(cycles=cycles, cycles_median=statistics.median(cycles),
                                          latency_us_median=statistics.median(cycles)/250,
                                          core_cycles=core, coefficients_checked_per_run=1024)
        # Memory conditions/revision remain unknown for the imported VBFly run.
        # Do not automatically turn these numbers into a hardware speedup claim.
        save()
        print(json.dumps(manifest['measured_result'], indent=2))
        print(f'Evidence: {output}')
    except (RuntimeError, OSError, subprocess.TimeoutExpired) as error:
        manifest['execution_error'] = str(error)
        save()
        sys.exit(str(error))


if __name__ == '__main__':
    main()
