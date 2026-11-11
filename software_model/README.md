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
