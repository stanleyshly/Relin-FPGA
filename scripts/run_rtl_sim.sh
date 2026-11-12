#!/usr/bin/env bash
set -euo pipefail
case "${1:-}" in
  --timing-only) export RELIN_TIMING_ONLY=1 ;;
  --functional) export RELIN_TIMING_ONLY=0 ;;
  "") export RELIN_TIMING_ONLY=0 ;;
  *) echo "Usage: bash scripts/run_rtl_sim.sh [--timing-only|--functional]" >&2; exit 2 ;;
esac
relin_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
python3 - <<'PY'
import socket
import sys
try:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as listener:
        listener.bind(('127.0.0.1', 0))
        listener.listen(1)
except OSError as error:
    sys.exit('XSim requires a local TCP socket for simulator communication. '
             'Run this script in a normal host terminal with local socket access. '
             'Socket preflight failed: ' + str(error))
PY
vivado_bin="${VIVADO_BIN:-/opt/Xilinx/2025.1/Vivado/bin/vivado}"
cd "$relin_root"
if [[ "${1:-}" == "--functional" ]]; then
    export RELIN_VECTOR_DIR="$relin_root/build/functional-vectors/seed-${RELIN_SEED:-1}"
    python3 software_model/hardware_vectors.py --output "$RELIN_VECTOR_DIR" --seed "${RELIN_SEED:-1}"
fi
mkdir -p build/rtl-sim
relin_log="build/rtl-sim/run-$(date +%Y%m%d-%H%M%S).log"
timeout --signal=TERM --kill-after=5s "${RELIN_WALLTIME_SECONDS:-300}s" \
    "$vivado_bin" -mode batch -source scripts/run_rtl_sim.tcl 2>&1 | tee "$relin_log"
if [[ "$RELIN_TIMING_ONLY" == 1 ]]; then
    grep -q 'TIMING_ONLY_RESULT:' "$relin_log"
else
    grep -q 'FUNCTIONAL_RESULT: PASS' "$relin_log"
fi
