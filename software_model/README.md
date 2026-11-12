# Relinearization arithmetic reference

This in-repository model replaces the removed external `model` submodule. It
has no third-party Python dependencies and is invoked from the repository root.

It implements negacyclic NTT/INTT, RNS digit lifting, two evaluation-key
multiply/accumulate paths, centered division by the special prime, and addition
to the original ciphertext components. The default N=4096, L=2, 60-bit primes
match `src/hbm/kernel_top.v` and the RTL modulus tables.

```bash
python3 -m unittest discover -s software_model -v
python3 software_model/relin.py
```

Vectors are deterministic (default seed 1) and written to
`software_model/test_vectors/`, which Git ignores. Select a different seed,
ring size, or prime set with `--seed`, `--n`, and `--moduli` (Q primes followed by
special prime p). The manifest records the parameters and primitive roots.

The model uses coefficient-domain ciphertexts and standard-residue,
bit-reversed negacyclic NTT evaluation keys. It generates noiseless evaluation
keys satisfying `b_i + a_i*s = p*CRT_basis_i*s^2 mod Q*p` and random ciphertext
fixtures. It does not implement BFV encryption, ciphertext multiplication,
plaintext encoding, or noise/security estimation.

These are mathematical reference vectors. TP-NTT packed twiddles, Montgomery
scaling, and HBM permutations are not exported or validated, so do not copy these
files directly into the hardware test directory. The original host also has
N=65536, L=59, LOGQ=32 hard-coded, unlike the current kernel; align those settings
before an FPGA correctness run. No hardware equivalence claim is made by the
software tests.

Tests compare transforms to direct evaluation and polynomial products to
schoolbook negacyclic convolution; the complete key-switch path is independently
checked with coefficient-domain convolution and centered mod-down, including
rounding boundaries, key identities, zero inputs, and vector export.

## Experimental RTL functional fixtures

`hardware_vectors.py` encodes the N=4096, TP=64, L=2, LOGQ=32 configuration.
The fixed RTL moduli are `0x80140001`, `0x80320001`, and special prime
`0x80340001`. It emits nonzero ciphertext components, arbitrary evaluation-key
entries, packed forward/inverse twiddles, and independent expected outputs.
The key entries are Montgomery-scaled by R=2^32 and ordered modulus-major,
then digit. Expected values come from `relin.relinearize`, not RTL outputs.
The upstream TP-NTT permutation functions supply twiddle storage scheduling;
the encoder extracts only those pure functions to avoid the upstream CLI's
optional sympy dependency. No submodule files are changed.

```bash
python3 software_model/hardware_vectors.py --output build/functional-vectors/seed-1
bash scripts/run_rtl_sim.sh --functional
# Another deterministic case:
RELIN_SEED=2 bash scripts/run_rtl_sim.sh --functional
```

The launcher generates the fixtures and passes an absolute `RELIN_VECTOR_DIR`
to XSim. Verification checks all 16384 output coefficients with case inequality
and a total-length guard. Missing files, malformed input, mismatch, or a kernel
timeout fail the run. The wrapper requires `FUNCTIONAL_RESULT: PASS` in the log.
The encoder's layout is experimental until this host-terminal RTL check passes;
Python model tests alone do not establish RTL equivalence. A negative check
should also corrupt an expected coefficient and confirm the comparator fails.
These fixtures test arithmetic on arbitrary nonzero data; they are not BFV
encryption or security tests.
