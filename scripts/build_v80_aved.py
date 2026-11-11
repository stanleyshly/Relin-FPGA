#!/usr/bin/env python3
"""Generate the AVED project around the packaged Relin RTL IP."""

import argparse
import os
from pathlib import Path
import sys
import xml.etree.ElementTree as ET


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ip-dir", required=True, type=Path)
    parser.add_argument("--output-dir", required=True, type=Path)
    parser.add_argument("--slr", default="SLR2", choices=("SLR0", "SLR1", "SLR2"))
    args = parser.parse_args()

    aved_root = Path(os.environ.get("AVED_ROOT", "/data/yd383/AMD-AVED/AVED"))
    hw_version = os.environ.get("AVED_HW_VERSION", "amd_v80_gen5x8_25.1")
    builder_root = Path(os.environ.get(
        "AVED_DESIGN_BUILDER_ROOT",
        "/data/yd383/bfly-dse/g2_p4/bfly-xcel/aved-design-builder",
    ))
    if not (args.ip_dir / "component.xml").is_file():
        raise SystemExit(f"Packaged RTL IP not found: {args.ip_dir}/component.xml")
    if not (aved_root / "hw" / hw_version / "src").is_dir():
        raise SystemExit(
            f"AVED hardware sources not found under {aved_root}/hw/{hw_version}; "
            "set AVED_ROOT and AVED_HW_VERSION"
        )
    if not (builder_root / "aved_design_builder" / "builder.py").is_file():
        raise SystemExit(
            f"AVED design builder not found under {builder_root}; "
            "set AVED_DESIGN_BUILDER_ROOT"
        )
    sys.path.insert(0, str(builder_root))
    from aved_design_builder.builder import DesignBuilder

    builder = DesignBuilder(str(aved_root), aved_hw_version=hw_version)
    builder.set_design_name("relin")
    builder.add_ip("relin", str(args.ip_dir.resolve()))
    builder.add_instance("relin_0", "relin", args.slr)
    for channel in range(32):
        builder.connect_hbm(f"relin_0.m{channel:02d}_axi", f"HBM_{channel}")
    builder.generate(str(args.output_dir.resolve()))

    # The shared builder assumes the control address block is named Reg.
    # Vivado packages this kernel with reg0; use the IP metadata instead.
    ns = {"spirit": "http://www.spiritconsortium.org/XMLSchema/SPIRIT/1685-2009"}
    core = ET.parse(args.ip_dir / "component.xml").getroot()
    blocks = [
        block.findtext("spirit:name", namespaces=ns)
        for memory_map in core.findall("spirit:memoryMaps/spirit:memoryMap", ns)
        if memory_map.findtext("spirit:name", namespaces=ns) == "s_axi_control"
        for block in memory_map.findall("spirit:addressBlock", ns)
    ]
    if len(blocks) != 1 or not blocks[0]:
        raise SystemExit(f"Expected one s_axi_control address block, found {blocks}")
    design_tcl = args.output_dir / "hw" / "src" / "create_design.tcl"
    tcl = design_tcl.read_text()
    old_segment = "relin_0/s_axi_control/Reg"
    actual_segment = f"relin_0/s_axi_control/{blocks[0]}"
    if old_segment not in tcl and actual_segment not in tcl:
        raise SystemExit("Generated design has no Relin control address assignment")
    design_tcl.write_text(tcl.replace(old_segment, actual_segment))


if __name__ == "__main__":
    main()
