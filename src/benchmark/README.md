# Matched forward NTT benchmark

## Explicit SRAM timing

```bash
python3 scripts/run_matched_ntt.py --tp 8 --memory-model sram
```

For N=1024, SRAM runs measure TP8: **963 device / 567 core cycles**;
TP16: **558 / 354**; TP32: **348 / 240**. Each passes all 1024 coefficients
and packed twiddle rows in 11 seed-1 repetitions. TP8 seed 2 also passes.
The SRAM path reads its first word on AXI address acceptance, so the first
read handshake is one cycle later; subsequent beats stream at one per cycle.
Each port is 256 bits. Operand/twiddle/output ports stay separate and their
counts scale with TP. Source memories are preloaded outside device timing;
all DMA, core twiddle loading and acknowledged output writes remain timed.
The controller and arithmetic are unchanged. This is AXI SRAM modeling,
not a resident-buffer or core-only benchmark, synthesis, or hardware timing.

The default --memory-model behavioral-hbm preserves the historical RAM path
with READ_LATENCY=8. A new testbench assertion observes **9 cycles** from AR
handshake to first R-valid, including the RAM state transition; historical
documentation's 8 cycles refers to the parameter. The TP8 default regression
still measures 971 device / 567 core cycles. SRAM saves eight cycles per
transform because operand/twiddle reads overlap and only their initial
response delay changes. The bulk transfer and serialized controller costs
remain. Source hashes, commands and explicit memory settings are in run.json.

## Historical TP32 measurement

This benchmark passes RTL execution with Vivado/XSim 2025.1: **356 device
cycles / 1.424 us at 250 MHz**, and **240 core cycles / 0.960 us**. All 1024
output coefficients and all packed twiddle rows pass in each of 11 repetitions
of seed 1. The successful host run is `build/matched-ntt-20261111-225042-497508`,
completed 2026-11-11 22:50 EST. This is simulation, with the conditions below.

Run from a normal host terminal:

```bash
cd /data/ss3679/Relin-FPGA
python3 scripts/run_matched_ntt.py
```

The runner creates a new directory under `build/matched-ntt-<timestamp>` with
vectors, source hashes, exact commands, logs, and `run.json`. Defaults: seed 1,
11 repetitions. `--output /absolute/new/path` selects a new output directory;
`--compile-only` skips execution. Each successful run must verify all 1024
coefficients in modeled output HBM. The runner emits measured cycles and
latency only after every requested repetition passes. Simulator exit status
alone does not establish success.

The workload is one cyclic forward NTT of length 1024 modulo 3221225473, root
1855261384, natural-order input and output, 32-bit canonical residues. This
matches the documented VBFly vn1 workload parameters. The original hardware
measurement's exact input vector and bitstream revision are unavailable.
The independent finite-sum oracle agrees with a radix-2 network on all inputs
in the generated fixture, including zero, q-1, q-2 and values around 2^31.

The arithmetic uses the existing Relin `ntt_wrapper` and TP-NTT core, configured
for the supported TP=32 partition 32*32. Only decomposition parameter overrides
were exposed in `ntt_wrapper`; defaults preserve its existing configurations.
The vector generator reuses the upstream permutation schedule and converts
structural twiddle slots to cyclic Montgomery twiddles. It retains repeated
cyclic twiddles in distinct slots rather than deduplicating their values.

`matched_ntt.sv` is a **new standalone benchmark adapter**, not the existing
relinearization controller. It reuses Relin `dma_rx`, `dma_tx` and `fifo_sync`.
The testbench reuses `axi_ram` with 8-cycle read latency. Four 256-bit operand
ports, four twiddle ports and four output ports each transfer a 32-beat burst.
The adapter buffers input, loads q/twiddles, streams the core, stores outputs
at bit-reversed addresses to restore natural order, then writes output HBM.
This is a behavioral simulation, not a hardware measurement or timing-closure
result. The new adapter passes the recorded functional RTL run.

The measured device interval starts at the rising edge that accepts `start`
and ends at the rising edge asserting `halt` after all four output DMA write
responses. `cycles` counts the edge difference. It includes operand/twiddle
reads, parameter loading, input streaming, arithmetic, output reordering,
FIFO/DMA writes and completion handshakes. Host preload, start-write transport,
polling and software verification are excluded. `core_cycles` separately counts
first input-valid edge through last output-valid capture.

VBFly's imported 1874-cycle (7.496 us at 250 MHz) result is documented only as
start-to-halt; its internal memory conditions and bitstream revision are not
supplied. This benchmark aligns the semantic measurement endpoints, but cannot
establish identical internal memory conditions. The runner does not derive a
hardware speedup claim automatically.
