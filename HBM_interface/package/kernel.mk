DEVICE ?= U280
ifeq ($(DEVICE),U280)
PLATFORM := xilinx_u280_gen3x16_xdma_1_202211_1
PART := xcu280-fsvh2892-2L-e
else ifeq ($(DEVICE),V80)
# Label for Vivado simulation artifacts; this is not a Vitis/XRT platform.
PLATFORM := aved_v80_gen5x8_25.1
PART := xcv80-lsva4737-2MHP-e-S
else
$(error Unsupported device '$(DEVICE)'; use device=U280 or device=V80)
endif
# PLATFORM := xilinx_u55n_gen3x4_xdma_1_202110_1
# PLATFORM := xilinx_u55c_gen3x16_xdma_2_202110_1
# PLATFORM := xilinx_u55n_gen3x4_xdma_2_202110_1

# PART setting: uncomment the line matching your Alveo card
# PART := xcu200-fsgd2104-2-e
# PART := cu250-figd2104-2L-e
# PART := xcu50-fsvh2104-2-e
# PART := xcu280-fsvh2892-2L-e
# PART := xcu55n-fsvh2892-2L-e

# TARGET {sw_emu|hw_emu|hw}
TARGET := hw

HLS_KERNELS := 
RTL_KERNELS := kernel.xo
SIM_KERNEL  := kernel.xo

PACKAGE_TARGET := flipflop:~/zprize/pack_kernel/.
