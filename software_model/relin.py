"""Integer reference for RNS relinearization in Z_q[x]/(x^N+1).

Pure Python, no external packages. Coefficients are canonical residues; NTT
arrays use bit-reversed frequency order. This is an arithmetic oracle, not a
cycle model or a TP-NTT/HBM memory-layout encoder.
"""
import argparse
import json
from math import prod
from pathlib import Path
import random

DEFAULT_MODULI = (0x800580000000001, 0x800800000000001, 0x801A80000000001)


def root_of_unity(n, q):
    if n < 2 or n & (n - 1) or (q - 1) % (2 * n):
        raise ValueError("N must be a power of two and 2*N must divide q-1")
    for base in range(2, 10000):
        psi = pow(base, (q - 1) // (2 * n), q)
        if pow(psi, n, q) == q - 1:
            return psi
    raise ValueError("No primitive 2N-th root found; supply an NTT prime")


def reverse_bits(value, bits):
    return int(f"{value:0{bits}b}"[::-1], 2)


def ntt(values, q, psi=None):
    """Negacyclic forward transform, natural input to bit-reversed output."""
    n = len(values)
    psi = root_of_unity(n, q) if psi is None else psi
    bits = n.bit_length() - 1
    b = [x % q for x in values]
    m, t = 1, n
    while m < n:
        t //= 2
        for i in range(m):
            s = pow(psi, reverse_bits(m + i, bits), q)
            for j in range(2 * i * t, (2 * i + 1) * t):
                u, v = b[j], b[j + t] * s % q
                b[j], b[j + t] = (u + v) % q, (u - v) % q
        m *= 2
    return b


def intt(values, q, psi=None):
    """Inverse of ntt, including N^-1 normalization."""
    n = len(values)
    psi = root_of_unity(n, q) if psi is None else psi
    psi_inv = pow(psi, -1, q)
    bits = n.bit_length() - 1
    b = [x % q for x in values]
    m, t = n, 1
    while m > 1:
        h = m // 2
        for i in range(h):
            s = pow(psi_inv, reverse_bits(h + i, bits), q)
            for j in range(2 * i * t, (2 * i + 1) * t):
                u, v = b[j], b[j + t]
                b[j], b[j + t] = (u + v) % q, (u - v) * s % q
        t *= 2
        m //= 2
    inv_n = pow(n, -1, q)
    return [x * inv_n % q for x in b]


def multiply(a, b, q):
    if len(a) != len(b):
        raise ValueError("Polynomial sizes must match")
    return intt([x * y % q for x, y in zip(ntt(a, q), ntt(b, q))], q)


def centered(value, modulus):
    return (value + modulus // 2) % modulus - modulus // 2


def mod_down(residues, moduli):
    """Round-divide a Q*p polynomial by p, returning its residues modulo Q."""
    p = moduli[-1]
    last = [centered(x, p) for x in residues[-1]]
    return [[(a - b) * pow(p, -1, q) % q for a, b in zip(row, last)]
            for row, q in zip(residues[:-1], moduli[:-1])]


def relinearize(ciphertext, key, moduli):
    """key[component][digit][modulus] stores standard-residue NTT arrays.

    Each ct2 residue is independently lifted to every modulus, transformed,
    multiplied by the corresponding evaluation-key digit and accumulated.
    Then inverse-transform, centered mod-down by p, and add ct0/ct1.
    """
    l = len(moduli) - 1
    if len(ciphertext) != 3 or any(len(c) != l for c in ciphertext):
        raise ValueError("Expected three ciphertext components with L RNS limbs")
    n = len(ciphertext[0][0])
    if any(len(row) != n for c in ciphertext for row in c):
        raise ValueError("Ciphertext polynomial sizes must match")
    if (len(key) != 2 or any(len(c) != l for c in key)
            or any(len(d) != l + 1 for c in key for d in c)
            or any(len(row) != n for c in key for d in c for row in d)):
        raise ValueError("Expected key shape [2][L][L+1][N]")
    if len(set(moduli)) != len(moduli):
        raise ValueError("Moduli must be distinct")
    accum = [[], []]
    for j, q in enumerate(moduli):
        lifted = [ntt([v % q for v in digit], q) for digit in ciphertext[2]]
        for component in range(2):
            total = [sum(lifted[i][k] * key[component][i][j][k]
                         for i in range(l)) % q for k in range(n)]
            accum[component].append(intt(total, q))
    return [[[ (a + b) % q for a, b in zip(row, switched)]
             for row, switched, q in zip(ciphertext[c], mod_down(accum[c], moduli), moduli)]
            for c in range(2)]


def make_case(n=4096, moduli=DEFAULT_MODULI, seed=1):
    """Deterministic evaluation-key/ciphertext fixture; no encryption API.

    Key digits satisfy b_i + a_i*s = p*CRT_basis_i*s^2 (mod Q*p).
    No evaluation-key error is added. Random is for reproducible tests only.
    """
    for q in moduli:
        root_of_unity(n, q)
    rng = random.Random(seed)
    l, p = len(moduli) - 1, moduli[-1]
    q_product = prod(moduli[:-1])
    secret = [rng.choice((-1, 0, 1)) for _ in range(n)]
    ciphertext = []
    for _ in range(3):
        poly = [rng.randrange(q_product) for _ in range(n)]
        ciphertext.append([[x % q for x in poly] for q in moduli[:-1]])
    key = [[[] for _ in range(l)] for _ in range(2)]
    for i, qi in enumerate(moduli[:-1]):
        q_hat = q_product // qi
        basis = q_hat * pow(q_hat, -1, qi)
        a = [rng.randrange(q_product * p) for _ in range(n)]
        for j, q in enumerate(moduli):
            sn = ntt(secret, q)
            an = ntt(a, q)
            bn = [(p * basis * s * s - x * s) % q for x, s in zip(an, sn)]
            key[0][i].append(bn)
            key[1][i].append(an)
    return ciphertext, key, relinearize(ciphertext, key, moduli)


def write_case(output, n, moduli, seed):
    ciphertext, key, result = make_case(n, moduli, seed)
    output.mkdir(parents=True, exist_ok=True)
    width = (max(moduli).bit_length() + 3) // 4

    def write(name, values):
        (output / name).write_text("".join(f"{x:0{width}x}\n" for x in values))

    for c, component in enumerate(ciphertext):
        for i, row in enumerate(component):
            write(f"ct{c}_{i}.txt", row)
    for c, component in enumerate(result):
        for i, row in enumerate(component):
            write(f"relin_ct{c}_{i}.txt", row)
    for c in range(2):
        for i in range(len(moduli) - 1):
            for j in range(len(moduli)):
                write(f"relinkey_{i}_{j}_{c}.txt", key[c][i][j])
    metadata = dict(n=n, l=len(moduli)-1, moduli=list(moduli), seed=seed,
                    roots=[root_of_unity(n, q) for q in moduli],
                    key_domain="standard residues, bit-reversed negacyclic NTT",
                    ciphertext_domain="coefficient",
                    hardware_layout_validated=False,
                    note="TP-NTT twiddle packing and Montgomery/HBM layout are not encoded")
    (output / "manifest.json").write_text(json.dumps(metadata, indent=2) + "\n")
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--n", type=int, default=4096)
    parser.add_argument("--moduli", nargs="+", type=lambda s: int(s, 0), default=DEFAULT_MODULI)
    parser.add_argument("--seed", type=int, default=1)
    parser.add_argument("--output", type=Path, default=Path(__file__).parent / "test_vectors")
    args = parser.parse_args()
    if len(args.moduli) < 2:
        parser.error("Supply at least one Q prime and the special prime p")
    write_case(args.output, args.n, args.moduli, args.seed)
    print(f"Generated N={args.n}, L={len(args.moduli)-1} reference vectors in {args.output}")


if __name__ == "__main__":
    main()
