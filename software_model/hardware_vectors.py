"""Experimental hardware-layout encoder for N=4096, TP=64, L=2, 32-bit RTL.

Expected results come from relin.py; only index/twiddle packing uses the
upstream TP-NTT schedule. RTL equivalence requires an actual functional run.
"""
import argparse
import ast
import io
import json
import math
import hashlib
import re
from pathlib import Path
import random

import relin

N, TP = 4096, 64
MODULI = (0x80140001, 0x80320001, 0x80340001)


def schedule_functions():
    # Reuse only the pure permutation functions. The upstream CLI imports
    # sympy for unrelated prime generation; this adapter needs no packages.
    source = Path(__file__).resolve().parents[1] / 'TP-NTT/test/iterative_moduled_version_updated.py'
    names = {'small_stage_model', 'iterative_first_block1', 'iterative_second_block', 'iterative_four_model'}
    tree = ast.parse(source.read_text())
    selected = ast.Module(body=[node for node in tree.body
                               if isinstance(node, ast.FunctionDef) and node.name in names], type_ignores=[])
    env = dict(N=N, TP=TP, depth=N // TP, log2=math.log2)
    exec(compile(selected, str(source), 'exec'), env)
    return env['iterative_four_model']


def twiddle_map(q, inverse=False):
    psi = relin.root_of_unity(N, q)
    if inverse:
        psi = pow(psi, -1, q)
    result = {}
    m, t = 1, N
    while m < N:
        t //= 2
        for i in range(m):
            value = pow(psi, relin.reverse_bits(m + i, 12), q) * (1 << 32) % q
            if inverse:
                value = value * pow(2, -1, q) % q
            for j in range(2 * i * t, (2 * i + 1) * t):
                result[j, j + t] = value
        m *= 2
    return result


def packed_twiddles(schedule, labels, q, inverse):
    stream = io.StringIO()
    output = schedule(labels, TP, TP, TP, N, False, stream, twiddle_map(q, inverse))
    flat = [v for row in output for v in row]
    if sorted(flat) != list(range(N)):
        raise ValueError('TP-NTT schedule is not a permutation')
    rows = list(dict.fromkeys(stream.getvalue().splitlines()))
    if len(rows) < N // TP:
        raise ValueError('Insufficient unique twiddle rows')
    head = [[int(x, 16) for x in row.split()] for row in rows[:N // TP]]
    extra = [int(x, 16) for row in rows[N // TP:] for x in row.split()]
    cursor = 0
    for row in head:
        count = min(TP - len(row), len(extra) - cursor)
        row.extend(extra[cursor:cursor + count])
        cursor += count
        row.extend([0] * (TP - len(row)))
    if cursor != len(extra):
        raise ValueError('Packed twiddles overflow the N-entry store')
    return [x for row in head for x in row], output


def generate(output, seed):
    root = Path(__file__).resolve().parents[1]
    tb = (root / 'src/tb/kernel_tb.v').read_text()
    for name, value in dict(LOGN=12, LOGTP=6, L=2, LOGQ=32, LOGQH=15, EN_ADD=1).items():
        match = re.search(r'parameter\s+' + name + r'\s*=\s*(\d+)', tb)
        if match is None or int(match.group(1)) != value:
            raise ValueError(f'Hardware encoder requires {name}={value}')
    output.mkdir(parents=True, exist_ok=True)
    rng = random.Random(seed)
    # Arbitrary nonzero evaluation-key entries exercise both multiply/accumulate
    # paths; cryptographic key validity is unnecessary for arithmetic testing.
    ciphertext = [[[rng.randrange(min(MODULI)) for _ in range(N)]
                   for _ in range(2)] for _ in range(3)]
    key = [[[ [rng.randrange(q) for _ in range(N)] for q in MODULI]
            for _ in range(2)] for _ in range(2)]
    expected = relin.relinearize(ciphertext, key, MODULI)
    schedule = schedule_functions()
    labels = [[relin.reverse_bits(i, 12) for i in range(start, start + TP)]
              for start in range(0, N, TP)]
    roots = []
    files = {}

    def write(name, values):
        values = list(values)
        (output / name).write_text(''.join(f'{v:08x}\n' for v in values))
        files[name] = len(values)

    for j, q in enumerate(MODULI):
        forward, ntt_order = packed_twiddles(schedule, labels, q, False)
        inverse, _ = packed_twiddles(schedule, ntt_order, q, True)
        order = [v for row in ntt_order for v in row]
        write(f'psi_{j}.txt', forward)
        write(f'psi_inv_{j}.txt', inverse)
        roots.append(relin.root_of_unity(N, q))
        for component in range(2):
            for digit in range(2):
                # The adapter addresses keys as modulus-major, then digit.
                write(f'relinkey_{component}_{j * 2 + digit}.txt',
                      (key[component][digit][j][k] * (1 << 32) % q for k in order))
    for component in range(3):
        for digit in range(2):
            write(f'ct{component}_{digit}.txt', ciphertext[component][digit])
    for component in range(2):
        for digit in range(2):
            write(f'relin_ct{component}_{digit}.txt', expected[component][digit])
    metadata = dict(format='relin-hardware-vectors/1', n=N, tp=TP, l=2,
                    logq=32, logqh=15, moduli=list(MODULI), roots=roots,
                    seed=seed, files=files, rtl_validation='not run',
                    purpose='nonzero arithmetic fixture; not an encrypted BFV ciphertext')
    metadata['source_sha256'] = {
        name: hashlib.sha256((root / name).read_bytes()).hexdigest()
        for name in ('src/tb/kernel_tb.v', 'src/relin/relin_q_mux.v',
                     'src/relin/relin_q_inv_mux.v', 'src/relin/relin_half_mux.v',
                     'software_model/relin.py', 'software_model/hardware_vectors.py')}
    (output / 'manifest.json').write_text(json.dumps(metadata, indent=2) + '\n')
    print(f'Wrote {len(files)} hardware-layout vector files to {output}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--seed', type=int, default=1)
    args = parser.parse_args()
    generate(args.output, args.seed)
