
RM = rm -f
RMDIR = rm -rf
CP = cp -rf
LN = ln -sf
ECHO := @echo
XILINX_ROOT ?= /opt/xilinx/Xilinx_Vivado_Vitis_2022.1
XILINX_VIVADO ?= $(XILINX_ROOT)/Vivado/2022.1
XILINX_VITIS ?= $(XILINX_ROOT)/Vitis/2022.1
XILINX_HLS ?= $(XILINX_ROOT)/Vitis_HLS/2022.1
XILINX_XRT ?= /opt/xilinx/xrt
PLATFORM_REPO_PATHS ?= /opt/xilinx/platforms
export XILINX_VIVADO XILINX_VITIS XILINX_HLS XILINX_XRT PLATFORM_REPO_PATHS

# Initialize the matching Xilinx tools in each recipe shell. v++ launches
# vitis_hls and Vivado internally, so their settings must be in its environment.
SHELL := /bin/bash
.SHELLFLAGS := -c
XILINX_ENV = source "$(XILINX_VIVADO)/settings64.sh" && source "$(XILINX_VITIS)/settings64.sh" && source "$(XILINX_HLS)/settings64.sh" &&

VPP ?= $(XILINX_VITIS)/bin/v++
VIVADO ?= $(XILINX_VIVADO)/bin/vivado
EMCONFIGUTIL ?= $(XILINX_VITIS)/bin/emconfigutil
PLATFORMINFO ?= $(XILINX_VITIS)/bin/platforminfo

################################################################################
# Help Section

.PHONY: help

help::
	$(ECHO) "Makefile Usage:"
	$(ECHO) "  make all TARGET=<sw_emu/hw_emu/hw>"
	$(ECHO) "      Command to generate the design for specified Target."
	$(ECHO) ""
	$(ECHO) "  make clean"
	$(ECHO) "      Command to remove the generated non-hardware files."
	$(ECHO) ""
	$(ECHO) "  make cleanall"
	$(ECHO) "      Command to remove all the generated files."
	$(ECHO) ""
	$(ECHO) "  make run TARGET=<sw_emu/hw_emu/hw> PACKAGE=<my_package>"
	$(ECHO) "      Command to run application in emulation."
	$(ECHO) ""
	$(ECHO) "  make build TARGET=<sw_emu/hw_emu/hw>"
	$(ECHO) "      Command to build xclbin application."
	$(ECHO) ""
	$(ECHO) "  make host"
	$(ECHO) "      Command to build host application."
	$(ECHO) ""

################################################################################
# Configure Project Variables

include config.mk

# Keep compiler and linker temporary files on the workspace filesystem.
TMPDIR ?= $(abspath $(TMP_DIR))
export TMPDIR

DUMMY := $(shell mkdir -p $(BUILD_ROOT))
DUMMY := $(shell mkdir -p run)
DUMMY := $(shell mkdir -p $(RUN_DIR))
DUMMY := $(shell mkdir -p $(TMP_DIR))
DUMMY := $(shell mkdir -p $(TMPDIR))
DUMMY := $(shell mkdir -p $(LOG_DIR))
DUMMY := $(shell mkdir -p $(REP_DIR))

################################################################################
# Setting up Variables

XRT_INCLUDE       := $(XILINX_XRT)/include
VIVADO_INCLUDE    := $(XILINX_VIVADO)/include
VITIS_INCLUDE     := $(XILINX_VITIS)/include
VITIS_HLS_INCLUDE := $(XILINX_HLS)/include
XRT_LIB           := $(XILINX_XRT)/lib

CXXFLAGS += -I$(XRT_INCLUDE) -I$(VIVADO_INCLUDE) -I$(VITIS_INCLUDE) -I$(VITIS_HLS_INCLUDE) -Wall -O3 -g -std=c++1y
LDFLAGS  += -L$(XRT_LIB) -lOpenCL -pthread

CXXFLAGS += -fmessage-length=0
LDFLAGS  += -lrt -lstdc++ 
LDFLAGS  += -luuid -lxrt_coreutil
LDFLAGS  += -pthread

# Kernel compiler global settings
VPP_FLAGS += --target $(TARGET) --platform $(PLATFORM)
VPP_FLAGS += --save-temps 
VPP_FLAGS += --temp_dir $(TMP_DIR) --log_dir $(LOG_DIR) --report_dir $(REP_DIR)

ifneq ($(TARGET), hw)
	VPP_FLAGS += -g
endif

################################################################################
# Setting Rules for Containers (Compiling xclbin files)

# Functional netlist exports are unnecessary for physical hardware builds.
# Keep the normal Vivado flow for RTL simulation and hardware emulation.
ifeq ($(TARGET),hw)
HW_LINK_INPUTS := ../scripts/hw_synth_no_sim_netlists.tcl
VPP_FLAGS += --vivado.prop run.ulp_kernel_1_0_synth_1.STEPS.SYNTH_DESIGN.TCL.PRE=$(abspath $(HW_LINK_INPUTS))
# Emit per-instance resource totals after routing, alongside the full-device reports.
VPP_FLAGS += --vivado.prop run.impl_1.STEPS.ROUTE_DESIGN.TCL.POST=$(abspath ../scripts/report_hierarchical_utilization.tcl)
endif

CONTAINERS := $(foreach P, $(basename $(PACKAGES)), C$P)

.PHONY: build
build: $(CONTAINERS)

# Real output targets preserve completed links and rebuild when inputs change.
$(CONTAINERS): C%: $(BUILD_DIR)/%.xclbin

$(BUILD_DIR)/%.xclbin: $(KERNELS) $(PKGDIR)/%.cfg $(HW_LINK_INPUTS)
	mkdir -p $(BUILD_DIR)
	$(XILINX_ENV) $(VPP) $(VPP_FLAGS) --config $(PKGDIR)/$*.cfg --link $(VPP_LDFLAGS) -o $@ $(KERNELS)

.PHONY: build-status
build-status:
	python3 ../scripts/build_status.py $(TMP_DIR)/link/vivado/vpl/prj/prj.runs

################################################################################
# Setting Rules for Host Executables (Compiling binary files)

HOSTS := $(foreach P, $(basename $(PACKAGES)), H$P)

.PHONY: host
host: $(HOSTS)

$(HOSTS): H%: $(RUN_DIR)/%

$(RUN_DIR)/%: $(HOST_DIR)/%.cpp $(HOST_INCS) $(shell find $(HOST_DIR)/includes -type f)
	$(CXX) -o $@ $< $(HOST_INCS) $(CXXFLAGS) $(LDFLAGS)
	
################################################################################
# Setting Essential Checks and Running Rules

EMCONFIG := $(EM_DIR)/emconfig.json

# .PHONY: run
# run:
# 	cd $(RUN_DIR) && XCL_EMULATION_MODE=$(TARGET) ./$(PACKAGES) --xclbin $(PACKAGES)

.PHONY: run_prepare
run_prepare: $(EMCONFIG)
ifneq (1, $(words $(PACKAGES)))
	$(ECHO) 'The PACKAGES variable is: $(PACKAGES)'
	$(ECHO) 'Though it is fine for build/host targets for preparing multiple'
	$(ECHO) 'packages for run, we cannot run multiple at the same time.'
	$(ECHO) 'Instead, you can try:'
	$(ECHO) '  make run PACKAGES=<my_package>'
else
	$(CP) $(BUILD_DIR)/*.xclbin $(RUN_DIR)
	$(CP) xrt.ini               $(RUN_DIR)
	$(CP) xsim.tcl              $(RUN_DIR)
	$(CP) $(EMCONFIG) 				  $(RUN_DIR)	
endif

.PHONY: run
run:
ifeq ($(TARGET),$(filter $(TARGET),sw_emu hw_emu))
	cd $(RUN_DIR) && XCL_EMULATION_MODE=$(TARGET) ./$(PACKAGES) --xclbin $(PACKAGES)
else
	cd $(RUN_DIR) && ./$(PACKAGES) --xclbin $(PACKAGES) --device_id 0
endif	
	
$(EMCONFIG):
	$(XILINX_ENV) $(EMCONFIGUTIL) --platform $(PLATFORM) --od $(EM_DIR)

################################################################################
# Setting Rules for Simulating a Kernel

sim: SIMULATE

################################################################################
# Utility

.PHONY: pack
pack: run_prepare
	mkdir -p _$(PACK)/$(RUN_DIR)
	mkdir -p _$(PACK)/$(PKGDIR)
	mkdir -p _$(PACK)/$(HOST_DIR)
	mkdir -p _$(PACK)/scripts
	$(CP) -r $(RUN_DIR)/* _$(PACK)/$(RUN_DIR)/.
	$(CP) -r $(PKGDIR)/*	 _$(PACK)/$(PKGDIR)/.
	$(CP) -r $(HOST_DIR)/* _$(PACK)/$(HOST_DIR)/.
	$(CP) -r scripts/* _$(PACK)/scripts/.
	$(CP) -r config.mk _$(PACK)/.
	$(CP) -r Makefile _$(PACK)/.
	tar -zcvf $(PACK).tar.gz ./_$(PACK) --transform s/_$(PACK)/$(PACK)/
	scp -r ./_$(PACK)/* $(PACKAGE_TARGET)
	-$(RMDIR) _$(PACK)

.PHONY: platforminfo
platforminfo: $(PLATFORM).pinfo

$(PLATFORM).pinfo:
	$(PLATFORMINFO) --force --platform $(PLATFORM) -o $@

.PHONY: vitis_analyzer
vitis_analyzer: 
	vitis_analyzer .

.PHONY: open_vivado_project
open_vivado_project:
	$(VIVADO) $(TMP_DIR)/link/vivado/vpl/prj/prj.xpr

################################################################################
# Cleaning Rules

.PHONY: clean
clean:
	-$(RM) *.jou *.log *.str
	-$(RMDIR) run $(BUILD_ROOT) .Xil .run .ipcache .cache *.cache *.gen *.runs *.sim *.ip_user_files *.hw *.sdk *.data
	-$(RMDIR) _$(PACK) $(PACK)
	
.PHONY: kill
kill:
	killall vivado vitis xsim

# make continue-dcp STRAT=Congestion_SpreadLogic_high
STRAT       ?= 1
DCP         := pfm_top_wrapper_routed.dcp
BIT         := pfm_top_i_dynamic_region_my_rm_partial.bit
DCP_BIT_DIR := $(TMP_DIR)/link/vivado/vpl/prj/prj.runs/impl_$(STRAT)

#TODO: output in diff dir, this messes up the initial logs (but also needs to be in same dir to work properly?)
.PHONY: continue-dcp
continue-dcp: $(DCP_BIT_DIR)/$(DCP) 
	mkdir -p $(BUILD_DIR)/continue
	$(XILINX_ENV) $(VPP) $(VPP_FLAGS) --link $(VPP_LDFLAGS) --reuse_impl $< --config $(PKGDIR)/kernel.cfg -o $(BUILD_DIR)/continue/kernel.xclbin $(KERNELS)

.PHONY: continue-bit
continue-bit: $(DCP_BIT_DIR)/$(BIT) 
	mkdir -p $(BUILD_DIR)/continue
	$(XILINX_ENV) $(VPP) $(VPP_FLAGS) --link $(VPP_LDFLAGS) --reuse_bit $< --config $(PKGDIR)/kernel.cfg -o $(BUILD_DIR)/continue/kernel.xclbin $(KERNELS)

