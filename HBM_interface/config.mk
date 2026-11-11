################################################################################
# Setting target packages

PACKAGES := kernel

PKGDIR := package
include $(PKGDIR)/$(PACKAGES).mk

################################################################################
# Setting paths

HOST_DIR   = src/host
HOST_INCS += $(HOST_DIR)/includes/cmdparser/cmdlineparser.cpp 
HOST_INCS += $(HOST_DIR)/includes/logger/logger.cpp

CXXFLAGS  += -Isrc/host/includes/cmdparser
CXXFLAGS  += -Isrc/host/includes/logger
CXXFLAGS  += -Isrc/hls
CXXFLAGS  += -Wno-int-in-bool-context
LDFLAGS   += 

BUILD_ROOT ?= $(abspath ../build)
EM_DIR    := $(BUILD_ROOT)/$(PLATFORM)/emconfig
BUILD_DIR := $(BUILD_ROOT)/$(PLATFORM)/$(TARGET)
RUN_DIR   := ./run/$(PLATFORM)/$(TARGET)

TMP_DIR   := $(BUILD_DIR)/tmp
LOG_DIR   := $(BUILD_DIR)/logs
REP_DIR   := $(BUILD_DIR)/reports

PACKAGE_SCRIPT = $(PKGDIR)/package.tcl

PACK 			:= pack

################################################################################
# Setting Targets

## hls 
HLS_KERNELS := $(patsubst %, $(BUILD_DIR)/%, $(HLS_KERNELS))
$(HLS_KERNELS) : $(BUILD_DIR)/%.xo : src/hls/%.cpp
	$(VPP) $(VPP_FLAGS) --compile --kernel $* -o $@ $^

## rtl
RTL_KERNELS := $(patsubst %, $(BUILD_DIR)/%, $(RTL_KERNELS))
RTL_INPUTS := $(shell cat src/rtl/kernel/sources)
$(RTL_KERNELS) : $(BUILD_DIR)/%.xo : $(RTL_INPUTS) $(wildcard src/rtl/kernel/*.tcl) src/rtl/kernel/sources src/rtl/kernel/kernel.xml $(PACKAGE_SCRIPT)

	$(VIVADO) -mode batch -source $(PACKAGE_SCRIPT) -nojournal -log $(LOG_DIR)/vivado_$*.log -tclargs $* $(TARGET) $(PART) $(BUILD_DIR) $(TMP_DIR)

## sim
SIM_KERNEL  := $(basename $(SIM_KERNEL))
SIMULATE :	
	$(VIVADO) -mode batch -source $(PACKAGE_SCRIPT) -nojournal -log $(LOG_DIR)/vivado_$(SIM_KERNEL).log -tclargs $(SIM_KERNEL) $(TARGET) $(PART) $(BUILD_DIR) $(TMP_DIR) sim
	$(VIVADO) $(TMP_DIR)/_$(SIM_KERNEL)/kernel_pack.xpr

# KERNELS := $(HLS_KERNELS) $(RTL_KERNELS)
KERNELS := $(RTL_KERNELS)
