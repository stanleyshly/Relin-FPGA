"""Read Vivado run markers and logs without opening or changing the project."""
import sys
import time
from pathlib import Path


def main():
    runs = Path(sys.argv[1])
    if not runs.is_dir():
        print(f"No Vivado runs directory: {runs}")
        return 1
    complete = failed = unfinished = 0
    for run in sorted(runs.iterdir()):
        log = run / "runme.log"
        if not log.is_file():
            continue
        if (run / ".vivado.error.rst").exists():
            state = "FAILED"
            failed += 1
        elif (run / ".vivado.end.rst").exists():
            complete += 1
            continue
        else:
            state = "unfinished (marker does not prove process is alive)"
            unfinished += 1
        age = int(time.time() - log.stat().st_mtime)
        print(f"{run.name}: {state}; log updated {age}s ago")
        print(f"  {log}")
        lines = log.read_text(errors="replace").splitlines()
        for line in lines[-3:]:
            print(f"  {line}")
    print(f"Runs: {complete} complete, {failed} failed, {unfinished} unfinished")
    return int(failed > 0)


if __name__ == "__main__":
    sys.exit(main())
