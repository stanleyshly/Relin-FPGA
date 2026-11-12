# Relin-FPGA

**FHE Relinearization Accelerator on FPGA**

This repository contains an FPGA-based accelerator for BFV/FHE relinearization. The project includes software model generation, test-vector creation, RTL simulation, hardware emulation, and real FPGA testing support.

The design has been tested on the **AMD/Xilinx Alveo U280 FPGA board with HBM**.

---

## 1. Repository Setup

Clone the repository:

```bash
git clone <repository-url> Relin-FPGA
cd Relin-FPGA
```

TP-NTT and its modular arithmetic dependency are included directly in this
repository; no submodule initialization is required.

---

## 2. Generate Relinearization Reference Vectors

The former `model` submodule has been removed. The maintained replacement is
[software_model](software_model/README.md), a standalone Python arithmetic
reference that generates deterministic test fixtures:

```bash
python3 software_model/relin.py
```

By default it uses `N=4096`, `L=2`, and writes to
`software_model/test_vectors/`. Set `--n`, `--moduli` (the Q primes followed by
special prime p), `--seed`, and `--output` to choose another fixture. The model
is an arithmetic oracle; its vectors do not yet include the TP-NTT twiddle,
Montgomery, and HBM layout conversions required by the hardware host.
`software_model/README.md` documents that boundary and the supported arithmetic.

---

## 3. Configure Simulation Parameters

For RTL simulation testing, go to the testbench directory:

```bash
cd src/relin/tb/kernel_tb
```

Update the following parameters in the testbench according to your configuration:

```verilog
parameter LOGN  = 12;
parameter LOGQ  = 60;
parameter LOGQH = 17;
parameter LOGTP = 5;
parameter L     = 2;
```

The `LOGQH` parameter depends on `LOGQ`:

```text
LOGQ = 60  -> LOGQH = 17
LOGQ = 32  -> LOGQH = 15
```

Make sure the RTL simulation parameters match the selected parameters for the
software reference.

---

## 4. Run RTL Simulation in Vivado

Open the Vivado 2022.1 project:

```bash
vivado_2022/relin.xpr
```

You can open this file directly from Vivado.

The project and its IP were recreated using Vivado 2022.1. To recreate the project
or check that every source exists and all IP is unlocked, run from the repository root:

```bash
/opt/xilinx/Xilinx_Vivado_Vitis_2022.1/Vivado/2022.1/bin/vivado -mode batch -source scripts/create_project.tcl
/opt/xilinx/Xilinx_Vivado_Vitis_2022.1/Vivado/2022.1/bin/vivado -mode batch -source scripts/check_project.tcl
```

The 2025.1 project is kept beside it in `vivado_2025/`. Create, check, or open
the V80 project through the same Makefile with:

```bash
make create_project device=v80
make check_project device=v80
make open_vivado_project device=v80
```

Project creation uses `xcv80-lsva4737-2MHP-e-S` and recreates the AXI VIP for
the V80 project in Vivado 2025.1. The U280-only FIFO Generator IPs are not
instantiated by this project RTL and are omitted from the V80 project because
that IP is unsupported for the V80 part. Keep the U280 project and its Vivado
2022.1 IP in `vivado_2022/`.

The open check does not run simulation. A hardware correctness run still needs
validated TP-NTT/HBM layout conversion of the replacement model vectors.

Then click:

```text
Run Simulation
```

If the configuration and test vectors are correct, the simulation should finish successfully.

At the end of the simulation output, you should see:

```text
HBM Data Verification Completed
```

There should be no errors in the simulation log.

---

## 5. Real FPGA Testing

For hardware emulation or real FPGA testing, go to the HBM interface directory:

```bash
cd HBM_interface
source source_me
```

This defaults to U280. For V80, select its environment before sourcing:

```bash
export DEVICE=V80
source source_me
```

The Makefile selector is lowercase (`device=v80` or `device=u280`); `DEVICE`
selects the environment for `source_me`.

The default device is U280 and uses Vivado/Vitis 2022.1 under
`/opt/xilinx/Xilinx_Vivado_Vitis_2022.1`. Select V80 with `device=v80`; it uses
Vivado 2025.1 under `/opt/xilinx-full/2025.1` and the V80 part above. U280 is
selected with `device=u280`. Both selectors work from the repository root and
`HBM_interface/`.

For a U280 build, the Makefile keeps the Vitis/XRT `.xclbin` flow. For V80,
`make build TARGET=hw device=v80` packages the RTL kernel with Vivado 2025.1,
generates the AVED design around it, and runs AVED's `build_all.sh` to produce
the PDI. The AVED sources and design builder default to the installed copies
under `/data/yd383`; override `AVED_ROOT`, `AVED_HW_VERSION`, or
`AVED_DESIGN_BUILDER_ROOT` if those move. The generated design connects the
kernel's 32 AXI master ports to AVED's 32 HBM interfaces and places it in
`SLR2` by default (`V80_SLR` can select another SLR).

The V80 AVED hardware image flow uses Python to generate the AVED project. By
default, it creates `.venv/` in the repository root on the first V80 build and
installs `pydantic>=2.0` there if needed. Set `AVED_PYTHON_VENV` to choose a
different environment; an active `$VIRTUAL_ENV` takes precedence. You can also
run `make aved-python device=v80` to prepare the environment explicitly. The
existing `host`, `run_prepare`, and `run` targets still use U280 XRT and report
that V80 AVED host deployment is not ported. The V80 project setup, project
check, and RTL simulation use Vivado 2025.1. This host has the AVED deployment
package and `static.xsa` at
`/opt/amd/aved/amd_v80_gen5x8_25.1_exdes_1_xbtest/`; that XSA is an AVED
firmware input, not an XRT acceleration platform.

XRT defaults to `/opt/xilinx/xrt` and U280 platform repositories to
`/opt/xilinx/platforms`; override `XILINX_ROOT`, `XILINX_XRT`,
`PLATFORM_REPO_PATHS`, or `PLATFORM` for a different installation. Individual
tool paths can be overridden with `VIVADO=...` and `VPP=...`. Temporary
compiler files default to the build directory; `TMPDIR` can override this.

The standalone model's output is not a drop-in input for the host-side hardware
test. Hardware testing still requires a TP-NTT/HBM vector-layout conversion
before placing vectors under `HBM_interface/scripts/kernel/test_vectors/`.

---

### 5.1 Hardware Emulation

Hardware emulation can be built and run with `TARGET=hw_emu`.

This may take around 30 minutes.

```bash
make build TARGET=hw_emu device=u280
make run_prepare TARGET=hw_emu device=u280
make host TARGET=hw_emu device=u280
make run TARGET=hw_emu device=u280
```

This runs the design in hardware emulation mode for the Alveo U280 platform.

---

### 5.2 Real Hardware Execution

Real hardware execution can be built and run with `TARGET=hw`.

This may take several hours.

Build commands also work from the repository root:

```bash
make build TARGET=hw
make build-status TARGET=hw
```

New outputs go to `build/<platform>/<target>/` at the repository root.
`BUILD_ROOT=/absolute/path` overrides this location. Existing active builds under
`HBM_interface/build/` must finish in place: Vivado embeds absolute paths in its
projects and run scripts. Inspect those with
`make build-status TARGET=hw BUILD_ROOT="$PWD/HBM_interface/build"` from the root.
Do not move an active project or start a second build against its output directory.
Completed `.xclbin` files can be copied to the new build directory for execution;
moving intermediate projects does not make them safely resumable.

Hardware builds skip Verilog and VHDL functional simulation netlist exports for
the large `ulp_kernel_1_0_synth_1` run. Checkpoints and synthesis stubs are retained.
The hardware-only Tcl pre-hook also prevents that kernel from publishing an
incomplete IP cache entry. Platform IP caching is retained. Hardware emulation
and RTL simulation retain the normal export flow. No extra flag is required.
These changes apply to subsequent builds, not the already-running build.

The current run spent about 37 minutes in kernel synthesis and another 22 minutes
in its first VHDL export, followed by a second VHDL export. Skipping the exports
removes those export costs; the total saving needs a full build measurement.
Packaging now creates the testbench block design only for `make sim`.
Host compilation tracks source/header timestamps instead of recompiling every time.

For `TARGET=hw`, the Vivado route step writes `hierarchical_utilization_routed.rpt`
in the implementation run directory, with resource counts by instantiated module.
`make cleanbuild` removes the complete configured build root, including reports,
temporary files, logs, and checkpoints. `make cleanall` also removes local Vivado
and IP cache directories.

Further build-time considerations:

* The active kernel run refused cache publication because of duplicate-declaration
  critical warnings. The current RTL already removes those declarations. Other
  critical warnings should be fixed rather than hidden.
* The configured 32 synthesis jobs run separate IPs concurrently. Once only the
  kernel remains, increasing that number cannot accelerate its single synthesis.
  Implementation jobs similarly do not mean threads within one routing run.
* Placement, routing, and timing closure remain necessary at the requested 200 MHz.
  Do not lower effort or change the clock without measuring timing and runtime.
* Keep intermediates and platform caches between builds. Completed links are
  timestamp-tracked. `cleanbuild` removes the new build root, and `cleanall` also
  removes the shared IP cache; neither is a routine prerequisite to building.
* `continue-dcp` and `continue-bit` reuse completed implementation artifacts; they
  are not a resume mechanism for an unfinished synthesis run. Their output is
  `<build-dir>/continue/kernel.xclbin`.

The link progress counter counts completed blocks, not work within a block.
`226 of 227 jobs complete` can persist while the large relinearization kernel
synthesizes. Inspect the child logs from another terminal:

```bash
make build-status TARGET=hw
# Refresh periodically:
watch -n 30 make build-status TARGET=hw
```

The status command reports unfinished/failed runs, log age, and the last messages.
An old log alone does not prove a hang: check the Vivado process CPU usage and
memory on the build host before stopping it. A running marker can remain after
an interrupted process. Avoid starting another build in the same output directory
while one is active. `make build` tracks RTL/header and packaging changes and
reuses an up-to-date final xclbin; it does not resume an interrupted link.
The existing `make kill` target kills all matching tools and should not be used
on a shared host.

Before running the hardware test, open:

```bash
HBM_interface/auto_run.sh
```

Update the following variables:

```bash
ITER
RNS_NUM
```

`ITER` specifies how many times the hardware test will be repeated.

`RNS_NUM` specifies the number of RNS primes in the BFV modulus `Q`. This value should match `L`.

Then build and run the hardware design:

```bash
make build TARGET=hw
make host TARGET=hw
make run_prepare TARGET=hw
./auto_run.sh
```

The script automatically creates test logs in:

```bash
run.txt
```

It also compares the reference results:

```bash
test_vectors/relin_ct*
```

with the computed hardware results:

```bash
computed/relin_ct*
```

If the test is successful, the computed FPGA outputs should match the reference test-vector outputs.

---

## Notes

Make sure the following parameters are consistent between the software model, RTL simulation, hardware emulation, and real FPGA testing:

* `ring_dimension`
* `LOGN`
* `LOGQ`
* `LOGQH`
* `LOGTP`
* `L`
* `RNS_NUM`

Mismatch between generated test vectors, RTL parameters, and host-side hardware configuration may cause simulation or hardware verification errors.

---

## Citation

If you use this repository or the relinearization accelerator in your work, please cite:

```bibtex
@misc{kocer_relin,
      author = {Emre Koçer and Tolun Tosun and Beren Aydoğan and Erkay Savaş and Furkan Turan and Ingrid Verbauwhede},
      title = {{TP}-{NTT}: Batch {NTT} Hardware with Application to Relinearization},
      howpublished = {Cryptology {ePrint} Archive, Paper 2026/556},
      year = {2026},
      url = {https://eprint.iacr.org/2026/556}
}
```

---

## Contact

For any questions, please contact:

**Emre Koçer**
`kocer@sabanciuniv.edu`
