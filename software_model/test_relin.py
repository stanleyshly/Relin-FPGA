import random
import tempfile
import unittest
from pathlib import Path

from relin import (DEFAULT_MODULI, centered, intt, make_case, mod_down,
                   multiply, ntt, relinearize, root_of_unity, write_case)


def schoolbook(a, b, q):
    result = [0] * len(a)
    for i, x in enumerate(a):
        for j, y in enumerate(b):
            index = i + j
            result[index % len(a)] += x * y * (-1 if index >= len(a) else 1)
    return [x % q for x in result]


class ReferenceTests(unittest.TestCase):
    def test_transform_against_direct_evaluation(self):
        for n in (2, 4, 8, 16):
            q = 97
            psi = root_of_unity(n, q)
            values = [3 * k - 2 for k in range(n)]
            expected = []
            for i in range(n):
                frequency = int(f"{i:0{n.bit_length()-1}b}"[::-1], 2)
                point = pow(psi, 2 * frequency + 1, q)
                expected.append(sum(x * pow(point, j, q) for j, x in enumerate(values)) % q)
            self.assertEqual(ntt(values, q), expected)
            self.assertEqual(intt(expected, q), [x % q for x in values])

    def test_multiplication_against_schoolbook(self):
        rng = random.Random(8)
        for q in (97, *DEFAULT_MODULI):
            for _ in range(3):
                a, b = [[rng.randrange(q) for _ in range(16)] for _ in range(2)]
                self.assertEqual(multiply(a, b, q), schoolbook(a, b, q))

    def test_centered_mod_down_rounding_boundaries(self):
        moduli = (97, 113)
        values = [-200, -114, -57, -56, -1, 0, 1, 56, 57, 114, 300]
        residues = [[x % q for x in values] for q in moduli]
        expected = [((x + 56) // 113) % 97 for x in values]
        self.assertEqual(mod_down(residues, moduli)[0], expected)

    def test_relinearization_against_coefficient_oracle(self):
        moduli = (97, 113, 193)
        ct, key, actual = make_case(8, moduli, 42)
        expected = []
        for c in range(2):
            accum = []
            for j, q in enumerate(moduli):
                total = [0] * 8
                for i in range(2):
                    term = schoolbook(ct[2][i], intt(key[c][i][j], q), q)
                    total = [(a + b) % q for a, b in zip(total, term)]
                accum.append(total)
            p = moduli[-1]
            component = []
            for j, q in enumerate(moduli[:-1]):
                component.append([(ct[c][j][k] + (accum[j][k] - centered(accum[-1][k], p))
                                   * pow(p, -1, q)) % q for k in range(8)])
            expected.append(component)
        self.assertEqual(actual, expected)
        zeros = [[[0] * 8 for _ in range(2)] for _ in range(3)]
        self.assertEqual(relinearize(zeros, key, moduli), zeros[:2])

    def test_noiseless_key_identity(self):
        moduli = (97, 113, 193)
        ct, key, _ = make_case(8, moduli, 7)
        rng = random.Random(7)
        s = [rng.choice((-1, 0, 1)) for _ in range(8)]
        Q, p = 97 * 113, 193
        for i, qi in enumerate(moduli[:-1]):
            basis = (Q // qi) * pow(Q // qi, -1, qi)
            for j, q in enumerate(moduli):
                b = intt(key[0][i][j], q)
                a = intt(key[1][i][j], q)
                lhs = [(x + y) % q for x, y in zip(b, schoolbook(a, s, q))]
                rhs = [p * basis * x % q for x in schoolbook(s, s, q)]
                self.assertEqual(lhs, rhs)

    def test_vector_export_and_parameter_validation(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder)
            result = write_case(path, 8, (97, 113, 193), 1)
            self.assertEqual(len(list(path.glob('*.txt'))), 22)
            self.assertEqual([int(x, 16) for x in (path / 'relin_ct0_0.txt').read_text().split()], result[0][0])
            self.assertIn('"hardware_layout_validated": false', (path / 'manifest.json').read_text())
        with self.assertRaises(ValueError):
            root_of_unity(3, 97)
        with self.assertRaises(ValueError):
            root_of_unity(64, 97)


if __name__ == '__main__':
    unittest.main()
