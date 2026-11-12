"""Cyclic NTT fixture and TP-NTT twiddle packing for the matched benchmark."""
import argparse
import ast
import hashlib
import io
import json
import math
from pathlib import Path
import random

N, TP, Q, ROOT = 1024, 32, 3221225473, 1855261384


def reverse(value, bits=10):
    return int(f'{value:0{bits}b}'[::-1], 2)


def finite_sum(values):
    result = []
    for k in range(N):
        step, factor, total = pow(ROOT, k, Q), 1, 0
        for value in values:
            total = (total + value * factor) % Q
            factor = factor * step % Q
        result.append(total)
    return result


def butterfly_reference(values):
    result = list(values)
    m, distance = 1, N
    while m < N:
        distance //= 2
        for i in range(m):
            exponent = reverse(i, m.bit_length() - 1) * (N // (2 * m)) if m > 1 else 0
            twiddle = pow(ROOT, exponent, Q)
            for j in range(2 * i * distance, (2 * i + 1) * distance):
                u, v = result[j], result[j + distance] * twiddle % Q
                result[j], result[j + distance] = (u + v) % Q, (u - v) % Q
        m *= 2
    return [result[reverse(k)] for k in range(N)]


def packed_twiddles(tp=32):
    TP = tp
    source = Path(__file__).resolve().parents[1] / 'TP-NTT/test/iterative_moduled_version_updated.py'
    names = {'small_stage_model', 'iterative_first_block1', 'iterative_second_block', 'iterative_four_model', 'iterative_six_model', 'iterative_seven_model'}
    tree = ast.parse(source.read_text())
    selected = ast.Module(body=[node for node in tree.body if isinstance(node, ast.FunctionDef) and node.name in names], type_ignores=[])
    env = dict(N=N, TP=TP, depth=N // TP, log2=math.log2)
    exec(compile(selected, str(source), 'exec'), env)
    tags, m, distance = {}, 1, N
    # Unique structural tags preserve the upstream packing slots even when
    # cyclic twiddles repeat (especially 1). Deduplicating values is incorrect.
    while m < N:
        distance //= 2
        for i in range(m):
            tag = reverse(m + i)
            for j in range(2 * i * distance, (2 * i + 1) * distance):
                tags[j, j + distance] = tag
        m *= 2
    labels = [[reverse(i) for i in range(start, start + TP)] for start in range(0, N, TP)]
    stream = io.StringIO()
    if TP == 32:
        layout = env['iterative_four_model'](labels, TP, TP, TP, N, False, stream, tags)
    elif TP == 16:
        layout = env['iterative_six_model'](labels, TP, 16, 4, 16, 1, 64, 16, False, stream, tags)
    elif TP == 8:
        layout = env['iterative_seven_model'](labels, TP, 8, 2, 8, 8, 16, 64, False, stream, tags)
    else:
        raise ValueError('Supported benchmark TP values: 8, 16, 32')
    order = [i for row in layout for i in row]
    assert sorted(order) == list(range(N))
    assert order == list(range(N)), 'Benchmark adapter expects this schedule to emit bit-reversed frequencies'
    rows = [[int(s, 16) for s in row.split()] for row in dict.fromkeys(stream.getvalue().splitlines())]
    head = rows[:N // TP]
    extra = [tag for row in rows[N // TP:] for tag in row]
    cursor = 0
    for row in head:
        count = min(TP - len(row), len(extra) - cursor)
        row.extend(extra[cursor:cursor + count])
        cursor += count
        row.extend([0] * (TP - len(row)))
    assert cursor == len(extra)
    packed_tags = [tag for row in head for tag in row]
    assert sorted(tag for tag in packed_tags if tag) == list(range(1, N))
    # Negacyclic tag = (2*bit_reverse(i)+1)*N/(2*m).
    # Corresponding cyclic exponent = bit_reverse(i)*N/(2*m).
    packed = [pow(ROOT, (tag - (tag & -tag)) // 2, Q) * (1 << 32) % Q if tag else 0 for tag in packed_tags]
    return packed, order, hashlib.sha256(source.read_bytes()).hexdigest()


def generate(output, seed, tp=32):
    TP = tp
    assert pow(ROOT, N, Q) == 1 and pow(ROOT, N // 2, Q) == Q - 1
    assert Q == (24576 << 17) + 1
    output.mkdir(parents=True, exist_ok=True)
    rng = random.Random(seed)
    values = [rng.randrange(Q) for _ in range(N)]
    # Include arithmetic boundary values as well as random canonical residues.
    values[:6] = [0, 1, Q - 1, Q - 2, 1 << 31, (1 << 31) - 1]
    expected = finite_sum(values)
    assert butterfly_reference(values) == expected
    twiddles, order, schedule_sha = packed_twiddles(TP)
    # Schedule labels refer to the bit-reversed-frequency reference output.
    natural_order = [reverse(i) for i in order]
    files = {}
    def write(name, data, width=8):
        path = output / name
        path.write_text(''.join(f'{v:0{width}x}\n' for v in data))
        files[name] = hashlib.sha256(path.read_bytes()).hexdigest()
    write('input.txt', values)
    write('expected.txt', expected)
    write('twiddle.txt', twiddles)
    write('output_order.txt', natural_order)
    for port in range(TP // 8):
        for prefix, data in [('input', values), ('twiddle', twiddles)]:
            words = [sum(data[row * TP + port * 8 + j] << (32 * j) for j in range(8)) for row in range(N // TP)]
            write(f'{prefix}-port{port}.txt', words, 64)
    manifest = dict(format='relin-matched-ntt-vectors/1', n=N, tp=TP, q=Q, root=ROOT, seed=seed,
                    transform='cyclic forward NTT; natural input and logical natural output',
                    reference_check='finite sum equals radix-2 network for all 1024 coefficients',
                    rtl_validation='not run', schedule_sha256=schedule_sha, files=files)
    (output / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(f'Vector oracle PASS: {N} coefficients, seed={seed}, output={output}')
    print(f'Physical output requires natural-order permutation: {natural_order != list(range(N))}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--seed', type=int, default=1)
    parser.add_argument('--tp', type=int, choices=(8, 16, 32), default=16)
    args = parser.parse_args()
    generate(args.output, args.seed, args.tp)
