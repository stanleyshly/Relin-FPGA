// default_nettype of none prevents implicit wire declaration.
`default_nettype none

`timescale 1 ns / 1 ps

`include "axi.sv"

`define HBM_PC_COUNT      32



module kernel_sv #(
  parameter integer LOGN                       = 16,
  parameter integer L                          = 28,
  parameter integer LOGQ                       = 60,
  parameter integer LOGQH                      = 17,
  parameter integer LOGTP                      = 5,
  parameter integer EN_ADD                     = 1,
  parameter integer PSI_CC                     = 1 << (LOGN - LOGTP),
  parameter integer HBM_ADDR_WIDTH             = 64,
  parameter integer HBM_DATA_WIDTH             = 256,
  parameter integer C_S_AXI_CONTROL_ADDR_WIDTH = 12,
  parameter integer C_S_AXI_CONTROL_DATA_WIDTH = 32,
  parameter integer C_M00_AXI_ADDR_WIDTH       = HBM_ADDR_WIDTH,
  parameter integer C_M01_AXI_ADDR_WIDTH       = HBM_ADDR_WIDTH,
  parameter integer C_M02_AXI_ADDR_WIDTH       = HBM_ADDR_WIDTH,
  parameter integer C_M03_AXI_ADDR_WIDTH       = HBM_ADDR_WIDTH,
  parameter integer C_M04_AXI_ADDR_WIDTH       = HBM_ADDR_WIDTH,
  parameter integer C_M05_AXI_ADDR_WIDTH       = HBM_ADDR_WIDTH,
  parameter integer C_M06_AXI_ADDR_WIDTH       = HBM_ADDR_WIDTH,
  parameter integer C_M07_AXI_ADDR_WIDTH       = HBM_ADDR_WIDTH,
  parameter integer C_M08_AXI_ADDR_WIDTH       = HBM_ADDR_WIDTH,
  parameter integer C_M09_AXI_ADDR_WIDTH       = HBM_ADDR_WIDTH,
  parameter integer C_M10_AXI_ADDR_WIDTH       = HBM_ADDR_WIDTH,
  parameter integer C_M11_AXI_ADDR_WIDTH       = HBM_ADDR_WIDTH,
  parameter integer C_M12_AXI_ADDR_WIDTH       = HBM_ADDR_WIDTH,
  parameter integer C_M13_AXI_ADDR_WIDTH       = HBM_ADDR_WIDTH,
  parameter integer C_M14_AXI_ADDR_WIDTH       = HBM_ADDR_WIDTH,
  parameter integer C_M15_AXI_ADDR_WIDTH       = HBM_ADDR_WIDTH,
  parameter integer C_M16_AXI_ADDR_WIDTH       = HBM_ADDR_WIDTH,
  parameter integer C_M17_AXI_ADDR_WIDTH       = HBM_ADDR_WIDTH,
  parameter integer C_M18_AXI_ADDR_WIDTH       = HBM_ADDR_WIDTH,
  parameter integer C_M19_AXI_ADDR_WIDTH       = HBM_ADDR_WIDTH,
  parameter integer C_M20_AXI_ADDR_WIDTH       = HBM_ADDR_WIDTH,
  parameter integer C_M21_AXI_ADDR_WIDTH       = HBM_ADDR_WIDTH,
  parameter integer C_M22_AXI_ADDR_WIDTH       = HBM_ADDR_WIDTH,
  parameter integer C_M23_AXI_ADDR_WIDTH       = HBM_ADDR_WIDTH,
  parameter integer C_M24_AXI_ADDR_WIDTH       = HBM_ADDR_WIDTH,
  parameter integer C_M25_AXI_ADDR_WIDTH       = HBM_ADDR_WIDTH,
  parameter integer C_M26_AXI_ADDR_WIDTH       = HBM_ADDR_WIDTH,
  parameter integer C_M27_AXI_ADDR_WIDTH       = HBM_ADDR_WIDTH,
  parameter integer C_M28_AXI_ADDR_WIDTH       = HBM_ADDR_WIDTH,
  parameter integer C_M29_AXI_ADDR_WIDTH       = HBM_ADDR_WIDTH,
  parameter integer C_M30_AXI_ADDR_WIDTH       = HBM_ADDR_WIDTH,
  parameter integer C_M31_AXI_ADDR_WIDTH       = HBM_ADDR_WIDTH,
  parameter integer C_M00_AXI_DATA_WIDTH       = HBM_DATA_WIDTH,
  parameter integer C_M01_AXI_DATA_WIDTH       = HBM_DATA_WIDTH,
  parameter integer C_M02_AXI_DATA_WIDTH       = HBM_DATA_WIDTH,
  parameter integer C_M03_AXI_DATA_WIDTH       = HBM_DATA_WIDTH,
  parameter integer C_M04_AXI_DATA_WIDTH       = HBM_DATA_WIDTH,
  parameter integer C_M05_AXI_DATA_WIDTH       = HBM_DATA_WIDTH,
  parameter integer C_M06_AXI_DATA_WIDTH       = HBM_DATA_WIDTH,
  parameter integer C_M07_AXI_DATA_WIDTH       = HBM_DATA_WIDTH,
  parameter integer C_M08_AXI_DATA_WIDTH       = HBM_DATA_WIDTH,
  parameter integer C_M09_AXI_DATA_WIDTH       = HBM_DATA_WIDTH,
  parameter integer C_M10_AXI_DATA_WIDTH       = HBM_DATA_WIDTH,
  parameter integer C_M11_AXI_DATA_WIDTH       = HBM_DATA_WIDTH,
  parameter integer C_M12_AXI_DATA_WIDTH       = HBM_DATA_WIDTH,
  parameter integer C_M13_AXI_DATA_WIDTH       = HBM_DATA_WIDTH,
  parameter integer C_M14_AXI_DATA_WIDTH       = HBM_DATA_WIDTH,
  parameter integer C_M15_AXI_DATA_WIDTH       = HBM_DATA_WIDTH,
  parameter integer C_M16_AXI_DATA_WIDTH       = HBM_DATA_WIDTH,
  parameter integer C_M17_AXI_DATA_WIDTH       = HBM_DATA_WIDTH,
  parameter integer C_M18_AXI_DATA_WIDTH       = HBM_DATA_WIDTH,
  parameter integer C_M19_AXI_DATA_WIDTH       = HBM_DATA_WIDTH,
  parameter integer C_M20_AXI_DATA_WIDTH       = HBM_DATA_WIDTH,
  parameter integer C_M21_AXI_DATA_WIDTH       = HBM_DATA_WIDTH,
  parameter integer C_M22_AXI_DATA_WIDTH       = HBM_DATA_WIDTH,
  parameter integer C_M23_AXI_DATA_WIDTH       = HBM_DATA_WIDTH,
  parameter integer C_M24_AXI_DATA_WIDTH       = HBM_DATA_WIDTH,
  parameter integer C_M25_AXI_DATA_WIDTH       = HBM_DATA_WIDTH,
  parameter integer C_M26_AXI_DATA_WIDTH       = HBM_DATA_WIDTH,
  parameter integer C_M27_AXI_DATA_WIDTH       = HBM_DATA_WIDTH,
  parameter integer C_M28_AXI_DATA_WIDTH       = HBM_DATA_WIDTH,
  parameter integer C_M29_AXI_DATA_WIDTH       = HBM_DATA_WIDTH,
  parameter integer C_M30_AXI_DATA_WIDTH       = HBM_DATA_WIDTH,
  parameter integer C_M31_AXI_DATA_WIDTH       = HBM_DATA_WIDTH
)
(
  // Note: A minimum subset of AXI4 memory mapped signals are declared.
  // AXI signals omitted from these interfaces are automatically inferred with
  // the optimal values for Xilinx SDx systems.
  // This allows Xilinx AXI4 Interconnects within the system to be optimized by
  // removing logic for AXI4 protocol features that are not necessary.
  // When adapting AXI4 masters within the RTL kernel that have signals not
  // declared below, it is suitable to add the signals to the declarations
  // below to connect them to the AXI4 Master.

  // List of ommited signals - effect
  // -------------------------------
  // ID     - Transaction ID are used for multithreading and out of order
  //          transactions.  This increases complexity. This saves logic and
  //          increases Fmax in the system when ommited.
  // SIZE   - Default value is log2(data width in bytes). Needed for subsize
  //          bursts. This saves logic and increases Fmax in the system when
  //          ommited.
  // BURST  - Default value (0b01) is incremental. Wrap and fixed bursts are
  //          not recommended. This saves logic and increases Fmax in the
  //          system when ommited.
  // LOCK   - Not supported in AXI4
  // CACHE  - Default value (0b0011) allows modifiable transactions. No benefit
  //          to changing this.
  // PROT   - Has no effect in SDx systems.
  // QOS    - Has no effect in SDx systems.
  // REGION - Has no effect in SDx systems.
  // USER   - Has no effect in SDx systems.
  // RESP   - Not useful in most SDx systems.

  // AXI4-Lite slave interface
  input  wire                                     s_axi_control_awvalid ,
  output wire                                     s_axi_control_awready ,
  input  wire [C_S_AXI_CONTROL_ADDR_WIDTH-1:0]    s_axi_control_awaddr  ,
  input  wire                                     s_axi_control_wvalid  ,
  output wire                                     s_axi_control_wready  ,
  input  wire [C_S_AXI_CONTROL_DATA_WIDTH-1:0]    s_axi_control_wdata   ,
  input  wire [C_S_AXI_CONTROL_DATA_WIDTH/8-1:0]  s_axi_control_wstrb   ,
  input  wire                                     s_axi_control_arvalid ,
  output wire                                     s_axi_control_arready ,
  input  wire [C_S_AXI_CONTROL_ADDR_WIDTH-1:0]    s_axi_control_araddr  ,
  output wire                                     s_axi_control_rvalid  ,
  input  wire                                     s_axi_control_rready  ,
  output wire [C_S_AXI_CONTROL_DATA_WIDTH-1:0]    s_axi_control_rdata   ,
  output wire [2-1:0]                             s_axi_control_rresp   ,
  output wire                                     s_axi_control_bvalid  ,
  input  wire                                     s_axi_control_bready  ,
  output wire [2-1:0]                             s_axi_control_bresp   ,

  // AXI4 master interface m00_axi
  output wire [C_M00_AXI_ADDR_WIDTH-1:0]          m00_axi_awaddr  ,
  output wire [8-1:0]                             m00_axi_awlen   ,
  output wire [2:0]                               m00_axi_awsize  ,
  output wire [1:0]                               m00_axi_awburst ,
  output wire                                     m00_axi_awvalid ,
  input  wire                                     m00_axi_awready ,
  output wire [C_M00_AXI_DATA_WIDTH-1:0]          m00_axi_wdata   ,
  output wire [C_M00_AXI_DATA_WIDTH/8-1:0]        m00_axi_wstrb   ,
  output wire                                     m00_axi_wlast   ,
  output wire                                     m00_axi_wvalid  ,
  input  wire                                     m00_axi_wready  ,
  input  wire                                     m00_axi_bvalid  ,
  output wire                                     m00_axi_bready  ,
  output wire [C_M00_AXI_ADDR_WIDTH-1:0]          m00_axi_araddr  ,
  output wire [8-1:0]                             m00_axi_arlen   ,
  output wire [2:0]                               m00_axi_arsize  ,
  output wire [1:0]                               m00_axi_arburst ,
  output wire                                     m00_axi_arvalid ,
  input  wire                                     m00_axi_arready ,
  input  wire [C_M00_AXI_DATA_WIDTH-1:0]          m00_axi_rdata   ,
  input  wire                                     m00_axi_rlast   ,
  input  wire                                     m00_axi_rvalid  ,
  output wire                                     m00_axi_rready  ,

  // AXI4 master interface m01_axi
  output wire [C_M01_AXI_ADDR_WIDTH-1:0]          m01_axi_awaddr  ,
  output wire [8-1:0]                             m01_axi_awlen   ,
  output wire [2:0]                               m01_axi_awsize  ,
  output wire [1:0]                               m01_axi_awburst ,
  output wire                                     m01_axi_awvalid ,
  input  wire                                     m01_axi_awready ,
  output wire [C_M01_AXI_DATA_WIDTH-1:0]          m01_axi_wdata   ,
  output wire [C_M01_AXI_DATA_WIDTH/8-1:0]        m01_axi_wstrb   ,
  output wire                                     m01_axi_wlast   ,
  output wire                                     m01_axi_wvalid  ,
  input  wire                                     m01_axi_wready  ,
  input  wire                                     m01_axi_bvalid  ,
  output wire                                     m01_axi_bready  ,
  output wire [C_M01_AXI_ADDR_WIDTH-1:0]          m01_axi_araddr  ,
  output wire [8-1:0]                             m01_axi_arlen   ,
  output wire [2:0]                               m01_axi_arsize  ,
  output wire [1:0]                               m01_axi_arburst ,
  output wire                                     m01_axi_arvalid ,
  input  wire                                     m01_axi_arready ,
  input  wire [C_M01_AXI_DATA_WIDTH-1:0]          m01_axi_rdata   ,
  input  wire                                     m01_axi_rlast   ,
  input  wire                                     m01_axi_rvalid  ,
  output wire                                     m01_axi_rready  ,

  // AXI4 master interface m02_axi
  output wire [C_M02_AXI_ADDR_WIDTH-1:0]          m02_axi_awaddr  ,
  output wire [8-1:0]                             m02_axi_awlen   ,
  output wire [2:0]                               m02_axi_awsize  ,
  output wire [1:0]                               m02_axi_awburst ,
  output wire                                     m02_axi_awvalid ,
  input  wire                                     m02_axi_awready ,
  output wire [C_M02_AXI_DATA_WIDTH-1:0]          m02_axi_wdata   ,
  output wire [C_M02_AXI_DATA_WIDTH/8-1:0]        m02_axi_wstrb   ,
  output wire                                     m02_axi_wlast   ,
  output wire                                     m02_axi_wvalid  ,
  input  wire                                     m02_axi_wready  ,
  input  wire                                     m02_axi_bvalid  ,
  output wire                                     m02_axi_bready  ,
  output wire [C_M02_AXI_ADDR_WIDTH-1:0]          m02_axi_araddr  ,
  output wire [8-1:0]                             m02_axi_arlen   ,
  output wire [2:0]                               m02_axi_arsize  ,
  output wire [1:0]                               m02_axi_arburst ,
  output wire                                     m02_axi_arvalid ,
  input  wire                                     m02_axi_arready ,
  input  wire [C_M02_AXI_DATA_WIDTH-1:0]          m02_axi_rdata   ,
  input  wire                                     m02_axi_rlast   ,
  input  wire                                     m02_axi_rvalid  ,
  output wire                                     m02_axi_rready  ,

  // AXI4 master interface m03_axi
  output wire [C_M03_AXI_ADDR_WIDTH-1:0]          m03_axi_awaddr  ,
  output wire [8-1:0]                             m03_axi_awlen   ,
  output wire [2:0]                               m03_axi_awsize  ,
  output wire [1:0]                               m03_axi_awburst ,
  output wire                                     m03_axi_awvalid ,
  input  wire                                     m03_axi_awready ,
  output wire [C_M03_AXI_DATA_WIDTH-1:0]          m03_axi_wdata   ,
  output wire [C_M03_AXI_DATA_WIDTH/8-1:0]        m03_axi_wstrb   ,
  output wire                                     m03_axi_wlast   ,
  output wire                                     m03_axi_wvalid  ,
  input  wire                                     m03_axi_wready  ,
  input  wire                                     m03_axi_bvalid  ,
  output wire                                     m03_axi_bready  ,
  output wire [C_M03_AXI_ADDR_WIDTH-1:0]          m03_axi_araddr  ,
  output wire [8-1:0]                             m03_axi_arlen   ,
  output wire [2:0]                               m03_axi_arsize  ,
  output wire [1:0]                               m03_axi_arburst ,
  output wire                                     m03_axi_arvalid ,
  input  wire                                     m03_axi_arready ,
  input  wire [C_M03_AXI_DATA_WIDTH-1:0]          m03_axi_rdata   ,
  input  wire                                     m03_axi_rlast   ,
  input  wire                                     m03_axi_rvalid  ,
  output wire                                     m03_axi_rready  ,

  // AXI4 master interface m04_axi
  output wire [C_M04_AXI_ADDR_WIDTH-1:0]          m04_axi_awaddr  ,
  output wire [8-1:0]                             m04_axi_awlen   ,
  output wire [2:0]                               m04_axi_awsize  ,
  output wire [1:0]                               m04_axi_awburst ,
  output wire                                     m04_axi_awvalid ,
  input  wire                                     m04_axi_awready ,
  output wire [C_M04_AXI_DATA_WIDTH-1:0]          m04_axi_wdata   ,
  output wire [C_M04_AXI_DATA_WIDTH/8-1:0]        m04_axi_wstrb   ,
  output wire                                     m04_axi_wlast   ,
  output wire                                     m04_axi_wvalid  ,
  input  wire                                     m04_axi_wready  ,
  input  wire                                     m04_axi_bvalid  ,
  output wire                                     m04_axi_bready  ,
  output wire [C_M04_AXI_ADDR_WIDTH-1:0]          m04_axi_araddr  ,
  output wire [8-1:0]                             m04_axi_arlen   ,
  output wire [2:0]                               m04_axi_arsize  ,
  output wire [1:0]                               m04_axi_arburst ,
  output wire                                     m04_axi_arvalid ,
  input  wire                                     m04_axi_arready ,
  input  wire [C_M04_AXI_DATA_WIDTH-1:0]          m04_axi_rdata   ,
  input  wire                                     m04_axi_rlast   ,
  input  wire                                     m04_axi_rvalid  ,
  output wire                                     m04_axi_rready  ,

  // AXI4 master interface m05_axi
  output wire [C_M05_AXI_ADDR_WIDTH-1:0]          m05_axi_awaddr  ,
  output wire [8-1:0]                             m05_axi_awlen   ,
  output wire [2:0]                               m05_axi_awsize  ,
  output wire [1:0]                               m05_axi_awburst ,
  output wire                                     m05_axi_awvalid ,
  input  wire                                     m05_axi_awready ,
  output wire [C_M05_AXI_DATA_WIDTH-1:0]          m05_axi_wdata   ,
  output wire [C_M05_AXI_DATA_WIDTH/8-1:0]        m05_axi_wstrb   ,
  output wire                                     m05_axi_wlast   ,
  output wire                                     m05_axi_wvalid  ,
  input  wire                                     m05_axi_wready  ,
  input  wire                                     m05_axi_bvalid  ,
  output wire                                     m05_axi_bready  ,
  output wire [C_M05_AXI_ADDR_WIDTH-1:0]          m05_axi_araddr  ,
  output wire [8-1:0]                             m05_axi_arlen   ,
  output wire [2:0]                               m05_axi_arsize  ,
  output wire [1:0]                               m05_axi_arburst ,
  output wire                                     m05_axi_arvalid ,
  input  wire                                     m05_axi_arready ,
  input  wire [C_M05_AXI_DATA_WIDTH-1:0]          m05_axi_rdata   ,
  input  wire                                     m05_axi_rlast   ,
  input  wire                                     m05_axi_rvalid  ,
  output wire                                     m05_axi_rready  ,

  // AXI4 master interface m06_axi
  output wire [C_M06_AXI_ADDR_WIDTH-1:0]          m06_axi_awaddr  ,
  output wire [8-1:0]                             m06_axi_awlen   ,
  output wire [2:0]                               m06_axi_awsize  ,
  output wire [1:0]                               m06_axi_awburst ,
  output wire                                     m06_axi_awvalid ,
  input  wire                                     m06_axi_awready ,
  output wire [C_M06_AXI_DATA_WIDTH-1:0]          m06_axi_wdata   ,
  output wire [C_M06_AXI_DATA_WIDTH/8-1:0]        m06_axi_wstrb   ,
  output wire                                     m06_axi_wlast   ,
  output wire                                     m06_axi_wvalid  ,
  input  wire                                     m06_axi_wready  ,
  input  wire                                     m06_axi_bvalid  ,
  output wire                                     m06_axi_bready  ,
  output wire [C_M06_AXI_ADDR_WIDTH-1:0]          m06_axi_araddr  ,
  output wire [8-1:0]                             m06_axi_arlen   ,
  output wire [2:0]                               m06_axi_arsize  ,
  output wire [1:0]                               m06_axi_arburst ,
  output wire                                     m06_axi_arvalid ,
  input  wire                                     m06_axi_arready ,
  input  wire [C_M06_AXI_DATA_WIDTH-1:0]          m06_axi_rdata   ,
  input  wire                                     m06_axi_rlast   ,
  input  wire                                     m06_axi_rvalid  ,
  output wire                                     m06_axi_rready  ,

  // AXI4 master interface m07_axi
  output wire [C_M07_AXI_ADDR_WIDTH-1:0]          m07_axi_awaddr  ,
  output wire [8-1:0]                             m07_axi_awlen   ,
  output wire [2:0]                               m07_axi_awsize  ,
  output wire [1:0]                               m07_axi_awburst ,
  output wire                                     m07_axi_awvalid ,
  input  wire                                     m07_axi_awready ,
  output wire [C_M07_AXI_DATA_WIDTH-1:0]          m07_axi_wdata   ,
  output wire [C_M07_AXI_DATA_WIDTH/8-1:0]        m07_axi_wstrb   ,
  output wire                                     m07_axi_wlast   ,
  output wire                                     m07_axi_wvalid  ,
  input  wire                                     m07_axi_wready  ,
  input  wire                                     m07_axi_bvalid  ,
  output wire                                     m07_axi_bready  ,
  output wire [C_M07_AXI_ADDR_WIDTH-1:0]          m07_axi_araddr  ,
  output wire [8-1:0]                             m07_axi_arlen   ,
  output wire [2:0]                               m07_axi_arsize  ,
  output wire [1:0]                               m07_axi_arburst ,
  output wire                                     m07_axi_arvalid ,
  input  wire                                     m07_axi_arready ,
  input  wire [C_M07_AXI_DATA_WIDTH-1:0]          m07_axi_rdata   ,
  input  wire                                     m07_axi_rlast   ,
  input  wire                                     m07_axi_rvalid  ,
  output wire                                     m07_axi_rready  ,

  // AXI4 master interface m08_axi
  output wire [C_M08_AXI_ADDR_WIDTH-1:0]          m08_axi_awaddr  ,
  output wire [8-1:0]                             m08_axi_awlen   ,
  output wire [2:0]                               m08_axi_awsize  ,
  output wire [1:0]                               m08_axi_awburst ,
  output wire                                     m08_axi_awvalid ,
  input  wire                                     m08_axi_awready ,
  output wire [C_M08_AXI_DATA_WIDTH-1:0]          m08_axi_wdata   ,
  output wire [C_M08_AXI_DATA_WIDTH/8-1:0]        m08_axi_wstrb   ,
  output wire                                     m08_axi_wlast   ,
  output wire                                     m08_axi_wvalid  ,
  input  wire                                     m08_axi_wready  ,
  input  wire                                     m08_axi_bvalid  ,
  output wire                                     m08_axi_bready  ,
  output wire [C_M08_AXI_ADDR_WIDTH-1:0]          m08_axi_araddr  ,
  output wire [8-1:0]                             m08_axi_arlen   ,
  output wire [2:0]                               m08_axi_arsize  ,
  output wire [1:0]                               m08_axi_arburst ,
  output wire                                     m08_axi_arvalid ,
  input  wire                                     m08_axi_arready ,
  input  wire [C_M08_AXI_DATA_WIDTH-1:0]          m08_axi_rdata   ,
  input  wire                                     m08_axi_rlast   ,
  input  wire                                     m08_axi_rvalid  ,
  output wire                                     m08_axi_rready  ,

  // AXI4 master interface m09_axi
  output wire [C_M09_AXI_ADDR_WIDTH-1:0]          m09_axi_awaddr  ,
  output wire [8-1:0]                             m09_axi_awlen   ,
  output wire [2:0]                               m09_axi_awsize  ,
  output wire [1:0]                               m09_axi_awburst ,
  output wire                                     m09_axi_awvalid ,
  input  wire                                     m09_axi_awready ,
  output wire [C_M09_AXI_DATA_WIDTH-1:0]          m09_axi_wdata   ,
  output wire [C_M09_AXI_DATA_WIDTH/8-1:0]        m09_axi_wstrb   ,
  output wire                                     m09_axi_wlast   ,
  output wire                                     m09_axi_wvalid  ,
  input  wire                                     m09_axi_wready  ,
  input  wire                                     m09_axi_bvalid  ,
  output wire                                     m09_axi_bready  ,
  output wire [C_M09_AXI_ADDR_WIDTH-1:0]          m09_axi_araddr  ,
  output wire [8-1:0]                             m09_axi_arlen   ,
  output wire [2:0]                               m09_axi_arsize  ,
  output wire [1:0]                               m09_axi_arburst ,
  output wire                                     m09_axi_arvalid ,
  input  wire                                     m09_axi_arready ,
  input  wire [C_M09_AXI_DATA_WIDTH-1:0]          m09_axi_rdata   ,
  input  wire                                     m09_axi_rlast   ,
  input  wire                                     m09_axi_rvalid  ,
  output wire                                     m09_axi_rready  ,

  // AXI4 master interface m10_axi
  output wire [C_M10_AXI_ADDR_WIDTH-1:0]          m10_axi_awaddr  ,
  output wire [8-1:0]                             m10_axi_awlen   ,
  output wire [2:0]                               m10_axi_awsize  ,
  output wire [1:0]                               m10_axi_awburst ,
  output wire                                     m10_axi_awvalid ,
  input  wire                                     m10_axi_awready ,
  output wire [C_M10_AXI_DATA_WIDTH-1:0]          m10_axi_wdata   ,
  output wire [C_M10_AXI_DATA_WIDTH/8-1:0]        m10_axi_wstrb   ,
  output wire                                     m10_axi_wlast   ,
  output wire                                     m10_axi_wvalid  ,
  input  wire                                     m10_axi_wready  ,
  input  wire                                     m10_axi_bvalid  ,
  output wire                                     m10_axi_bready  ,
  output wire [C_M10_AXI_ADDR_WIDTH-1:0]          m10_axi_araddr  ,
  output wire [8-1:0]                             m10_axi_arlen   ,
  output wire [2:0]                               m10_axi_arsize  ,
  output wire [1:0]                               m10_axi_arburst ,
  output wire                                     m10_axi_arvalid ,
  input  wire                                     m10_axi_arready ,
  input  wire [C_M10_AXI_DATA_WIDTH-1:0]          m10_axi_rdata   ,
  input  wire                                     m10_axi_rlast   ,
  input  wire                                     m10_axi_rvalid  ,
  output wire                                     m10_axi_rready  ,

  // AXI4 master interface m11_axi
  output wire [C_M11_AXI_ADDR_WIDTH-1:0]          m11_axi_awaddr  ,
  output wire [8-1:0]                             m11_axi_awlen   ,
  output wire [2:0]                               m11_axi_awsize  ,
  output wire [1:0]                               m11_axi_awburst ,
  output wire                                     m11_axi_awvalid ,
  input  wire                                     m11_axi_awready ,
  output wire [C_M11_AXI_DATA_WIDTH-1:0]          m11_axi_wdata   ,
  output wire [C_M11_AXI_DATA_WIDTH/8-1:0]        m11_axi_wstrb   ,
  output wire                                     m11_axi_wlast   ,
  output wire                                     m11_axi_wvalid  ,
  input  wire                                     m11_axi_wready  ,
  input  wire                                     m11_axi_bvalid  ,
  output wire                                     m11_axi_bready  ,
  output wire [C_M11_AXI_ADDR_WIDTH-1:0]          m11_axi_araddr  ,
  output wire [8-1:0]                             m11_axi_arlen   ,
  output wire [2:0]                               m11_axi_arsize  ,
  output wire [1:0]                               m11_axi_arburst ,
  output wire                                     m11_axi_arvalid ,
  input  wire                                     m11_axi_arready ,
  input  wire [C_M11_AXI_DATA_WIDTH-1:0]          m11_axi_rdata   ,
  input  wire                                     m11_axi_rlast   ,
  input  wire                                     m11_axi_rvalid  ,
  output wire                                     m11_axi_rready  ,

  // AXI4 master interface m12_axi
  output wire [C_M12_AXI_ADDR_WIDTH-1:0]          m12_axi_awaddr  ,
  output wire [8-1:0]                             m12_axi_awlen   ,
  output wire [2:0]                               m12_axi_awsize  ,
  output wire [1:0]                               m12_axi_awburst ,
  output wire                                     m12_axi_awvalid ,
  input  wire                                     m12_axi_awready ,
  output wire [C_M12_AXI_DATA_WIDTH-1:0]          m12_axi_wdata   ,
  output wire [C_M12_AXI_DATA_WIDTH/8-1:0]        m12_axi_wstrb   ,
  output wire                                     m12_axi_wlast   ,
  output wire                                     m12_axi_wvalid  ,
  input  wire                                     m12_axi_wready  ,
  input  wire                                     m12_axi_bvalid  ,
  output wire                                     m12_axi_bready  ,
  output wire [C_M12_AXI_ADDR_WIDTH-1:0]          m12_axi_araddr  ,
  output wire [8-1:0]                             m12_axi_arlen   ,
  output wire [2:0]                               m12_axi_arsize  ,
  output wire [1:0]                               m12_axi_arburst ,
  output wire                                     m12_axi_arvalid ,
  input  wire                                     m12_axi_arready ,
  input  wire [C_M12_AXI_DATA_WIDTH-1:0]          m12_axi_rdata   ,
  input  wire                                     m12_axi_rlast   ,
  input  wire                                     m12_axi_rvalid  ,
  output wire                                     m12_axi_rready  ,

  // AXI4 master interface m13_axi
  output wire [C_M13_AXI_ADDR_WIDTH-1:0]          m13_axi_awaddr  ,
  output wire [8-1:0]                             m13_axi_awlen   ,
  output wire [2:0]                               m13_axi_awsize  ,
  output wire [1:0]                               m13_axi_awburst ,
  output wire                                     m13_axi_awvalid ,
  input  wire                                     m13_axi_awready ,
  output wire [C_M13_AXI_DATA_WIDTH-1:0]          m13_axi_wdata   ,
  output wire [C_M13_AXI_DATA_WIDTH/8-1:0]        m13_axi_wstrb   ,
  output wire                                     m13_axi_wlast   ,
  output wire                                     m13_axi_wvalid  ,
  input  wire                                     m13_axi_wready  ,
  input  wire                                     m13_axi_bvalid  ,
  output wire                                     m13_axi_bready  ,
  output wire [C_M13_AXI_ADDR_WIDTH-1:0]          m13_axi_araddr  ,
  output wire [8-1:0]                             m13_axi_arlen   ,
  output wire [2:0]                               m13_axi_arsize  ,
  output wire [1:0]                               m13_axi_arburst ,
  output wire                                     m13_axi_arvalid ,
  input  wire                                     m13_axi_arready ,
  input  wire [C_M13_AXI_DATA_WIDTH-1:0]          m13_axi_rdata   ,
  input  wire                                     m13_axi_rlast   ,
  input  wire                                     m13_axi_rvalid  ,
  output wire                                     m13_axi_rready  ,

  // AXI4 master interface m14_axi
  output wire [C_M14_AXI_ADDR_WIDTH-1:0]          m14_axi_awaddr  ,
  output wire [8-1:0]                             m14_axi_awlen   ,
  output wire [2:0]                               m14_axi_awsize  ,
  output wire [1:0]                               m14_axi_awburst ,
  output wire                                     m14_axi_awvalid ,
  input  wire                                     m14_axi_awready ,
  output wire [C_M14_AXI_DATA_WIDTH-1:0]          m14_axi_wdata   ,
  output wire [C_M14_AXI_DATA_WIDTH/8-1:0]        m14_axi_wstrb   ,
  output wire                                     m14_axi_wlast   ,
  output wire                                     m14_axi_wvalid  ,
  input  wire                                     m14_axi_wready  ,
  input  wire                                     m14_axi_bvalid  ,
  output wire                                     m14_axi_bready  ,
  output wire [C_M14_AXI_ADDR_WIDTH-1:0]          m14_axi_araddr  ,
  output wire [8-1:0]                             m14_axi_arlen   ,
  output wire [2:0]                               m14_axi_arsize  ,
  output wire [1:0]                               m14_axi_arburst ,
  output wire                                     m14_axi_arvalid ,
  input  wire                                     m14_axi_arready ,
  input  wire [C_M14_AXI_DATA_WIDTH-1:0]          m14_axi_rdata   ,
  input  wire                                     m14_axi_rlast   ,
  input  wire                                     m14_axi_rvalid  ,
  output wire                                     m14_axi_rready  ,

  // AXI4 master interface m15_axi
  output wire [C_M15_AXI_ADDR_WIDTH-1:0]          m15_axi_awaddr  ,
  output wire [8-1:0]                             m15_axi_awlen   ,
  output wire [2:0]                               m15_axi_awsize  ,
  output wire [1:0]                               m15_axi_awburst ,
  output wire                                     m15_axi_awvalid ,
  input  wire                                     m15_axi_awready ,
  output wire [C_M15_AXI_DATA_WIDTH-1:0]          m15_axi_wdata   ,
  output wire [C_M15_AXI_DATA_WIDTH/8-1:0]        m15_axi_wstrb   ,
  output wire                                     m15_axi_wlast   ,
  output wire                                     m15_axi_wvalid  ,
  input  wire                                     m15_axi_wready  ,
  input  wire                                     m15_axi_bvalid  ,
  output wire                                     m15_axi_bready  ,
  output wire [C_M15_AXI_ADDR_WIDTH-1:0]          m15_axi_araddr  ,
  output wire [8-1:0]                             m15_axi_arlen   ,
  output wire [2:0]                               m15_axi_arsize  ,
  output wire [1:0]                               m15_axi_arburst ,
  output wire                                     m15_axi_arvalid ,
  input  wire                                     m15_axi_arready ,
  input  wire [C_M15_AXI_DATA_WIDTH-1:0]          m15_axi_rdata   ,
  input  wire                                     m15_axi_rlast   ,
  input  wire                                     m15_axi_rvalid  ,
  output wire                                     m15_axi_rready  ,

  // AXI4 master interface m16_axi
  output wire [C_M16_AXI_ADDR_WIDTH-1:0]          m16_axi_awaddr  ,
  output wire [8-1:0]                             m16_axi_awlen   ,
  output wire [2:0]                               m16_axi_awsize  ,
  output wire [1:0]                               m16_axi_awburst ,
  output wire                                     m16_axi_awvalid ,
  input  wire                                     m16_axi_awready ,
  output wire [C_M16_AXI_DATA_WIDTH-1:0]          m16_axi_wdata   ,
  output wire [C_M16_AXI_DATA_WIDTH/8-1:0]        m16_axi_wstrb   ,
  output wire                                     m16_axi_wlast   ,
  output wire                                     m16_axi_wvalid  ,
  input  wire                                     m16_axi_wready  ,
  input  wire                                     m16_axi_bvalid  ,
  output wire                                     m16_axi_bready  ,
  output wire [C_M16_AXI_ADDR_WIDTH-1:0]          m16_axi_araddr  ,
  output wire [8-1:0]                             m16_axi_arlen   ,
  output wire [2:0]                               m16_axi_arsize  ,
  output wire [1:0]                               m16_axi_arburst ,
  output wire                                     m16_axi_arvalid ,
  input  wire                                     m16_axi_arready ,
  input  wire [C_M16_AXI_DATA_WIDTH-1:0]          m16_axi_rdata   ,
  input  wire                                     m16_axi_rlast   ,
  input  wire                                     m16_axi_rvalid  ,
  output wire                                     m16_axi_rready  ,

  // AXI4 master interface m17_axi
  output wire [C_M17_AXI_ADDR_WIDTH-1:0]          m17_axi_awaddr  ,
  output wire [8-1:0]                             m17_axi_awlen   ,
  output wire [2:0]                               m17_axi_awsize  ,
  output wire [1:0]                               m17_axi_awburst ,
  output wire                                     m17_axi_awvalid ,
  input  wire                                     m17_axi_awready ,
  output wire [C_M17_AXI_DATA_WIDTH-1:0]          m17_axi_wdata   ,
  output wire [C_M17_AXI_DATA_WIDTH/8-1:0]        m17_axi_wstrb   ,
  output wire                                     m17_axi_wlast   ,
  output wire                                     m17_axi_wvalid  ,
  input  wire                                     m17_axi_wready  ,
  input  wire                                     m17_axi_bvalid  ,
  output wire                                     m17_axi_bready  ,
  output wire [C_M17_AXI_ADDR_WIDTH-1:0]          m17_axi_araddr  ,
  output wire [8-1:0]                             m17_axi_arlen   ,
  output wire [2:0]                               m17_axi_arsize  ,
  output wire [1:0]                               m17_axi_arburst ,
  output wire                                     m17_axi_arvalid ,
  input  wire                                     m17_axi_arready ,
  input  wire [C_M17_AXI_DATA_WIDTH-1:0]          m17_axi_rdata   ,
  input  wire                                     m17_axi_rlast   ,
  input  wire                                     m17_axi_rvalid  ,
  output wire                                     m17_axi_rready  ,

  // AXI4 master interface m18_axi
  output wire [C_M18_AXI_ADDR_WIDTH-1:0]          m18_axi_awaddr  ,
  output wire [8-1:0]                             m18_axi_awlen   ,
  output wire [2:0]                               m18_axi_awsize  ,
  output wire [1:0]                               m18_axi_awburst ,
  output wire                                     m18_axi_awvalid ,
  input  wire                                     m18_axi_awready ,
  output wire [C_M18_AXI_DATA_WIDTH-1:0]          m18_axi_wdata   ,
  output wire [C_M18_AXI_DATA_WIDTH/8-1:0]        m18_axi_wstrb   ,
  output wire                                     m18_axi_wlast   ,
  output wire                                     m18_axi_wvalid  ,
  input  wire                                     m18_axi_wready  ,
  input  wire                                     m18_axi_bvalid  ,
  output wire                                     m18_axi_bready  ,
  output wire [C_M18_AXI_ADDR_WIDTH-1:0]          m18_axi_araddr  ,
  output wire [8-1:0]                             m18_axi_arlen   ,
  output wire [2:0]                               m18_axi_arsize  ,
  output wire [1:0]                               m18_axi_arburst ,
  output wire                                     m18_axi_arvalid ,
  input  wire                                     m18_axi_arready ,
  input  wire [C_M18_AXI_DATA_WIDTH-1:0]          m18_axi_rdata   ,
  input  wire                                     m18_axi_rlast   ,
  input  wire                                     m18_axi_rvalid  ,
  output wire                                     m18_axi_rready  ,

  // AXI4 master interface m19_axi
  output wire [C_M19_AXI_ADDR_WIDTH-1:0]          m19_axi_awaddr  ,
  output wire [8-1:0]                             m19_axi_awlen   ,
  output wire [2:0]                               m19_axi_awsize  ,
  output wire [1:0]                               m19_axi_awburst ,
  output wire                                     m19_axi_awvalid ,
  input  wire                                     m19_axi_awready ,
  output wire [C_M19_AXI_DATA_WIDTH-1:0]          m19_axi_wdata   ,
  output wire [C_M19_AXI_DATA_WIDTH/8-1:0]        m19_axi_wstrb   ,
  output wire                                     m19_axi_wlast   ,
  output wire                                     m19_axi_wvalid  ,
  input  wire                                     m19_axi_wready  ,
  input  wire                                     m19_axi_bvalid  ,
  output wire                                     m19_axi_bready  ,
  output wire [C_M19_AXI_ADDR_WIDTH-1:0]          m19_axi_araddr  ,
  output wire [8-1:0]                             m19_axi_arlen   ,
  output wire [2:0]                               m19_axi_arsize  ,
  output wire [1:0]                               m19_axi_arburst ,
  output wire                                     m19_axi_arvalid ,
  input  wire                                     m19_axi_arready ,
  input  wire [C_M19_AXI_DATA_WIDTH-1:0]          m19_axi_rdata   ,
  input  wire                                     m19_axi_rlast   ,
  input  wire                                     m19_axi_rvalid  ,
  output wire                                     m19_axi_rready  ,

  // AXI4 master interface m20_axi
  output wire [C_M20_AXI_ADDR_WIDTH-1:0]          m20_axi_awaddr  ,
  output wire [8-1:0]                             m20_axi_awlen   ,
  output wire [2:0]                               m20_axi_awsize  ,
  output wire [1:0]                               m20_axi_awburst ,
  output wire                                     m20_axi_awvalid ,
  input  wire                                     m20_axi_awready ,
  output wire [C_M20_AXI_DATA_WIDTH-1:0]          m20_axi_wdata   ,
  output wire [C_M20_AXI_DATA_WIDTH/8-1:0]        m20_axi_wstrb   ,
  output wire                                     m20_axi_wlast   ,
  output wire                                     m20_axi_wvalid  ,
  input  wire                                     m20_axi_wready  ,
  input  wire                                     m20_axi_bvalid  ,
  output wire                                     m20_axi_bready  ,
  output wire [C_M20_AXI_ADDR_WIDTH-1:0]          m20_axi_araddr  ,
  output wire [8-1:0]                             m20_axi_arlen   ,
  output wire [2:0]                               m20_axi_arsize  ,
  output wire [1:0]                               m20_axi_arburst ,
  output wire                                     m20_axi_arvalid ,
  input  wire                                     m20_axi_arready ,
  input  wire [C_M20_AXI_DATA_WIDTH-1:0]          m20_axi_rdata   ,
  input  wire                                     m20_axi_rlast   ,
  input  wire                                     m20_axi_rvalid  ,
  output wire                                     m20_axi_rready  ,

  // AXI4 master interface m21_axi
  output wire [C_M21_AXI_ADDR_WIDTH-1:0]          m21_axi_awaddr  ,
  output wire [8-1:0]                             m21_axi_awlen   ,
  output wire [2:0]                               m21_axi_awsize  ,
  output wire [1:0]                               m21_axi_awburst ,
  output wire                                     m21_axi_awvalid ,
  input  wire                                     m21_axi_awready ,
  output wire [C_M21_AXI_DATA_WIDTH-1:0]          m21_axi_wdata   ,
  output wire [C_M21_AXI_DATA_WIDTH/8-1:0]        m21_axi_wstrb   ,
  output wire                                     m21_axi_wlast   ,
  output wire                                     m21_axi_wvalid  ,
  input  wire                                     m21_axi_wready  ,
  input  wire                                     m21_axi_bvalid  ,
  output wire                                     m21_axi_bready  ,
  output wire [C_M21_AXI_ADDR_WIDTH-1:0]          m21_axi_araddr  ,
  output wire [8-1:0]                             m21_axi_arlen   ,
  output wire [2:0]                               m21_axi_arsize  ,
  output wire [1:0]                               m21_axi_arburst ,
  output wire                                     m21_axi_arvalid ,
  input  wire                                     m21_axi_arready ,
  input  wire [C_M21_AXI_DATA_WIDTH-1:0]          m21_axi_rdata   ,
  input  wire                                     m21_axi_rlast   ,
  input  wire                                     m21_axi_rvalid  ,
  output wire                                     m21_axi_rready  ,

  // AXI4 master interface m22_axi
  output wire [C_M22_AXI_ADDR_WIDTH-1:0]          m22_axi_awaddr  ,
  output wire [8-1:0]                             m22_axi_awlen   ,
  output wire [2:0]                               m22_axi_awsize  ,
  output wire [1:0]                               m22_axi_awburst ,
  output wire                                     m22_axi_awvalid ,
  input  wire                                     m22_axi_awready ,
  output wire [C_M22_AXI_DATA_WIDTH-1:0]          m22_axi_wdata   ,
  output wire [C_M22_AXI_DATA_WIDTH/8-1:0]        m22_axi_wstrb   ,
  output wire                                     m22_axi_wlast   ,
  output wire                                     m22_axi_wvalid  ,
  input  wire                                     m22_axi_wready  ,
  input  wire                                     m22_axi_bvalid  ,
  output wire                                     m22_axi_bready  ,
  output wire [C_M22_AXI_ADDR_WIDTH-1:0]          m22_axi_araddr  ,
  output wire [8-1:0]                             m22_axi_arlen   ,
  output wire [2:0]                               m22_axi_arsize  ,
  output wire [1:0]                               m22_axi_arburst ,
  output wire                                     m22_axi_arvalid ,
  input  wire                                     m22_axi_arready ,
  input  wire [C_M22_AXI_DATA_WIDTH-1:0]          m22_axi_rdata   ,
  input  wire                                     m22_axi_rlast   ,
  input  wire                                     m22_axi_rvalid  ,
  output wire                                     m22_axi_rready  ,

  // AXI4 master interface m23_axi
  output wire [C_M23_AXI_ADDR_WIDTH-1:0]          m23_axi_awaddr  ,
  output wire [8-1:0]                             m23_axi_awlen   ,
  output wire [2:0]                               m23_axi_awsize  ,
  output wire [1:0]                               m23_axi_awburst ,
  output wire                                     m23_axi_awvalid ,
  input  wire                                     m23_axi_awready ,
  output wire [C_M23_AXI_DATA_WIDTH-1:0]          m23_axi_wdata   ,
  output wire [C_M23_AXI_DATA_WIDTH/8-1:0]        m23_axi_wstrb   ,
  output wire                                     m23_axi_wlast   ,
  output wire                                     m23_axi_wvalid  ,
  input  wire                                     m23_axi_wready  ,
  input  wire                                     m23_axi_bvalid  ,
  output wire                                     m23_axi_bready  ,
  output wire [C_M23_AXI_ADDR_WIDTH-1:0]          m23_axi_araddr  ,
  output wire [8-1:0]                             m23_axi_arlen   ,
  output wire [2:0]                               m23_axi_arsize  ,
  output wire [1:0]                               m23_axi_arburst ,
  output wire                                     m23_axi_arvalid ,
  input  wire                                     m23_axi_arready ,
  input  wire [C_M23_AXI_DATA_WIDTH-1:0]          m23_axi_rdata   ,
  input  wire                                     m23_axi_rlast   ,
  input  wire                                     m23_axi_rvalid  ,
  output wire                                     m23_axi_rready  ,

  // AXI4 master interface m24_axi
  output wire [C_M24_AXI_ADDR_WIDTH-1:0]          m24_axi_awaddr  ,
  output wire [8-1:0]                             m24_axi_awlen   ,
  output wire [2:0]                               m24_axi_awsize  ,
  output wire [1:0]                               m24_axi_awburst ,
  output wire                                     m24_axi_awvalid ,
  input  wire                                     m24_axi_awready ,
  output wire [C_M24_AXI_DATA_WIDTH-1:0]          m24_axi_wdata   ,
  output wire [C_M24_AXI_DATA_WIDTH/8-1:0]        m24_axi_wstrb   ,
  output wire                                     m24_axi_wlast   ,
  output wire                                     m24_axi_wvalid  ,
  input  wire                                     m24_axi_wready  ,
  input  wire                                     m24_axi_bvalid  ,
  output wire                                     m24_axi_bready  ,
  output wire [C_M24_AXI_ADDR_WIDTH-1:0]          m24_axi_araddr  ,
  output wire [8-1:0]                             m24_axi_arlen   ,
  output wire [2:0]                               m24_axi_arsize  ,
  output wire [1:0]                               m24_axi_arburst ,
  output wire                                     m24_axi_arvalid ,
  input  wire                                     m24_axi_arready ,
  input  wire [C_M24_AXI_DATA_WIDTH-1:0]          m24_axi_rdata   ,
  input  wire                                     m24_axi_rlast   ,
  input  wire                                     m24_axi_rvalid  ,
  output wire                                     m24_axi_rready  ,

  // AXI4 master interface m25_axi
  output wire [C_M25_AXI_ADDR_WIDTH-1:0]          m25_axi_awaddr  ,
  output wire [8-1:0]                             m25_axi_awlen   ,
  output wire [2:0]                               m25_axi_awsize  ,
  output wire [1:0]                               m25_axi_awburst ,
  output wire                                     m25_axi_awvalid ,
  input  wire                                     m25_axi_awready ,
  output wire [C_M25_AXI_DATA_WIDTH-1:0]          m25_axi_wdata   ,
  output wire [C_M25_AXI_DATA_WIDTH/8-1:0]        m25_axi_wstrb   ,
  output wire                                     m25_axi_wlast   ,
  output wire                                     m25_axi_wvalid  ,
  input  wire                                     m25_axi_wready  ,
  input  wire                                     m25_axi_bvalid  ,
  output wire                                     m25_axi_bready  ,
  output wire [C_M25_AXI_ADDR_WIDTH-1:0]          m25_axi_araddr  ,
  output wire [8-1:0]                             m25_axi_arlen   ,
  output wire [2:0]                               m25_axi_arsize  ,
  output wire [1:0]                               m25_axi_arburst ,
  output wire                                     m25_axi_arvalid ,
  input  wire                                     m25_axi_arready ,
  input  wire [C_M25_AXI_DATA_WIDTH-1:0]          m25_axi_rdata   ,
  input  wire                                     m25_axi_rlast   ,
  input  wire                                     m25_axi_rvalid  ,
  output wire                                     m25_axi_rready  ,

  // AXI4 master interface m26_axi
  output wire [C_M26_AXI_ADDR_WIDTH-1:0]          m26_axi_awaddr  ,
  output wire [8-1:0]                             m26_axi_awlen   ,
  output wire [2:0]                               m26_axi_awsize  ,
  output wire [1:0]                               m26_axi_awburst ,
  output wire                                     m26_axi_awvalid ,
  input  wire                                     m26_axi_awready ,
  output wire [C_M26_AXI_DATA_WIDTH-1:0]          m26_axi_wdata   ,
  output wire [C_M26_AXI_DATA_WIDTH/8-1:0]        m26_axi_wstrb   ,
  output wire                                     m26_axi_wlast   ,
  output wire                                     m26_axi_wvalid  ,
  input  wire                                     m26_axi_wready  ,
  input  wire                                     m26_axi_bvalid  ,
  output wire                                     m26_axi_bready  ,
  output wire [C_M26_AXI_ADDR_WIDTH-1:0]          m26_axi_araddr  ,
  output wire [8-1:0]                             m26_axi_arlen   ,
  output wire [2:0]                               m26_axi_arsize  ,
  output wire [1:0]                               m26_axi_arburst ,
  output wire                                     m26_axi_arvalid ,
  input  wire                                     m26_axi_arready ,
  input  wire [C_M26_AXI_DATA_WIDTH-1:0]          m26_axi_rdata   ,
  input  wire                                     m26_axi_rlast   ,
  input  wire                                     m26_axi_rvalid  ,
  output wire                                     m26_axi_rready  ,

  // AXI4 master interface m27_axi
  output wire [C_M27_AXI_ADDR_WIDTH-1:0]          m27_axi_awaddr  ,
  output wire [8-1:0]                             m27_axi_awlen   ,
  output wire [2:0]                               m27_axi_awsize  ,
  output wire [1:0]                               m27_axi_awburst ,
  output wire                                     m27_axi_awvalid ,
  input  wire                                     m27_axi_awready ,
  output wire [C_M27_AXI_DATA_WIDTH-1:0]          m27_axi_wdata   ,
  output wire [C_M27_AXI_DATA_WIDTH/8-1:0]        m27_axi_wstrb   ,
  output wire                                     m27_axi_wlast   ,
  output wire                                     m27_axi_wvalid  ,
  input  wire                                     m27_axi_wready  ,
  input  wire                                     m27_axi_bvalid  ,
  output wire                                     m27_axi_bready  ,
  output wire [C_M27_AXI_ADDR_WIDTH-1:0]          m27_axi_araddr  ,
  output wire [8-1:0]                             m27_axi_arlen   ,
  output wire [2:0]                               m27_axi_arsize  ,
  output wire [1:0]                               m27_axi_arburst ,
  output wire                                     m27_axi_arvalid ,
  input  wire                                     m27_axi_arready ,
  input  wire [C_M27_AXI_DATA_WIDTH-1:0]          m27_axi_rdata   ,
  input  wire                                     m27_axi_rlast   ,
  input  wire                                     m27_axi_rvalid  ,
  output wire                                     m27_axi_rready  ,

  // AXI4 master interface m28_axi
  output wire [C_M28_AXI_ADDR_WIDTH-1:0]          m28_axi_awaddr  ,
  output wire [8-1:0]                             m28_axi_awlen   ,
  output wire [2:0]                               m28_axi_awsize  ,
  output wire [1:0]                               m28_axi_awburst ,
  output wire                                     m28_axi_awvalid ,
  input  wire                                     m28_axi_awready ,
  output wire [C_M28_AXI_DATA_WIDTH-1:0]          m28_axi_wdata   ,
  output wire [C_M28_AXI_DATA_WIDTH/8-1:0]        m28_axi_wstrb   ,
  output wire                                     m28_axi_wlast   ,
  output wire                                     m28_axi_wvalid  ,
  input  wire                                     m28_axi_wready  ,
  input  wire                                     m28_axi_bvalid  ,
  output wire                                     m28_axi_bready  ,
  output wire [C_M28_AXI_ADDR_WIDTH-1:0]          m28_axi_araddr  ,
  output wire [8-1:0]                             m28_axi_arlen   ,
  output wire [2:0]                               m28_axi_arsize  ,
  output wire [1:0]                               m28_axi_arburst ,
  output wire                                     m28_axi_arvalid ,
  input  wire                                     m28_axi_arready ,
  input  wire [C_M28_AXI_DATA_WIDTH-1:0]          m28_axi_rdata   ,
  input  wire                                     m28_axi_rlast   ,
  input  wire                                     m28_axi_rvalid  ,
  output wire                                     m28_axi_rready  ,

  // AXI4 master interface m29_axi
  output wire [C_M29_AXI_ADDR_WIDTH-1:0]          m29_axi_awaddr  ,
  output wire [8-1:0]                             m29_axi_awlen   ,
  output wire [2:0]                               m29_axi_awsize  ,
  output wire [1:0]                               m29_axi_awburst ,
  output wire                                     m29_axi_awvalid ,
  input  wire                                     m29_axi_awready ,
  output wire [C_M29_AXI_DATA_WIDTH-1:0]          m29_axi_wdata   ,
  output wire [C_M29_AXI_DATA_WIDTH/8-1:0]        m29_axi_wstrb   ,
  output wire                                     m29_axi_wlast   ,
  output wire                                     m29_axi_wvalid  ,
  input  wire                                     m29_axi_wready  ,
  input  wire                                     m29_axi_bvalid  ,
  output wire                                     m29_axi_bready  ,
  output wire [C_M29_AXI_ADDR_WIDTH-1:0]          m29_axi_araddr  ,
  output wire [8-1:0]                             m29_axi_arlen   ,
  output wire [2:0]                               m29_axi_arsize  ,
  output wire [1:0]                               m29_axi_arburst ,
  output wire                                     m29_axi_arvalid ,
  input  wire                                     m29_axi_arready ,
  input  wire [C_M29_AXI_DATA_WIDTH-1:0]          m29_axi_rdata   ,
  input  wire                                     m29_axi_rlast   ,
  input  wire                                     m29_axi_rvalid  ,
  output wire                                     m29_axi_rready  ,

  // AXI4 master interface m30_axi
  output wire [C_M30_AXI_ADDR_WIDTH-1:0]          m30_axi_awaddr  ,
  output wire [8-1:0]                             m30_axi_awlen   ,
  output wire [2:0]                               m30_axi_awsize  ,
  output wire [1:0]                               m30_axi_awburst ,
  output wire                                     m30_axi_awvalid ,
  input  wire                                     m30_axi_awready ,
  output wire [C_M30_AXI_DATA_WIDTH-1:0]          m30_axi_wdata   ,
  output wire [C_M30_AXI_DATA_WIDTH/8-1:0]        m30_axi_wstrb   ,
  output wire                                     m30_axi_wlast   ,
  output wire                                     m30_axi_wvalid  ,
  input  wire                                     m30_axi_wready  ,
  input  wire                                     m30_axi_bvalid  ,
  output wire                                     m30_axi_bready  ,
  output wire [C_M30_AXI_ADDR_WIDTH-1:0]          m30_axi_araddr  ,
  output wire [8-1:0]                             m30_axi_arlen   ,
  output wire [2:0]                               m30_axi_arsize  ,
  output wire [1:0]                               m30_axi_arburst ,
  output wire                                     m30_axi_arvalid ,
  input  wire                                     m30_axi_arready ,
  input  wire [C_M30_AXI_DATA_WIDTH-1:0]          m30_axi_rdata   ,
  input  wire                                     m30_axi_rlast   ,
  input  wire                                     m30_axi_rvalid  ,
  output wire                                     m30_axi_rready  ,

  // AXI4 master interface m31_axi
  output wire [C_M31_AXI_ADDR_WIDTH-1:0]          m31_axi_awaddr  ,
  output wire [8-1:0]                             m31_axi_awlen   ,
  output wire [2:0]                               m31_axi_awsize  ,
  output wire [1:0]                               m31_axi_awburst ,
  output wire                                     m31_axi_awvalid ,
  input  wire                                     m31_axi_awready ,
  output wire [C_M31_AXI_DATA_WIDTH-1:0]          m31_axi_wdata   ,
  output wire [C_M31_AXI_DATA_WIDTH/8-1:0]        m31_axi_wstrb   ,
  output wire                                     m31_axi_wlast   ,
  output wire                                     m31_axi_wvalid  ,
  input  wire                                     m31_axi_wready  ,
  input  wire                                     m31_axi_bvalid  ,
  output wire                                     m31_axi_bready  ,
  output wire [C_M31_AXI_ADDR_WIDTH-1:0]          m31_axi_araddr  ,
  output wire [8-1:0]                             m31_axi_arlen   ,
  output wire [2:0]                               m31_axi_arsize  ,
  output wire [1:0]                               m31_axi_arburst ,
  output wire                                     m31_axi_arvalid ,
  input  wire                                     m31_axi_arready ,
  input  wire [C_M31_AXI_DATA_WIDTH-1:0]          m31_axi_rdata   ,
  input  wire                                     m31_axi_rlast   ,
  input  wire                                     m31_axi_rvalid  ,
  output wire                                     m31_axi_rready  ,

  // System Signals
  input  wire                                     ap_clk          ,
  input  wire                                     ap_rst_n        ,
  output wire                                     interrupt
);

////////////////////////////////////////////////////////////////////////////////
// Local Parameters
////////////////////////////////////////////////////////////////////////////////
localparam LOGL = $rtoi($ceil($clog2(L+ 1)));
localparam TP = 1 << LOGTP;

////////////////////////////////////////////////////////////////////////////////
// Wires and Variables
////////////////////////////////////////////////////////////////////////////////

  // Kernel Control Signals
  wire ap_start;
  wire ap_idle;
  wire ap_done;
  wire ap_ready;

  reg ap_start_q;
  wire ap_start_pulse;

  // CSRs <-> COMP
  wire [32-1:0] ap_control;
  wire [32-1:0] ap_status;
  wire [32-1:0] ap_debug;


  wire [32-1:0] ap_timing;

  // CSRs <-> DMA
  wire [HBM_ADDR_WIDTH-1:0] dma_address[0:`HBM_PC_COUNT-1];

////////////////////////////////////////////////////////////////////////////////
// Control Signals
////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////
  // Command Signals (A command from software to COMP module)

  wire        cmd_start, cmd_start_pulse;
  wire        cmd_exit;
  wire        cmd_idle;
  wire        cmd_done;
  reg  [31:0] cmd_timing = 32'b0;

  // cmd_start:
  assign cmd_start = (ap_control != 32'b0);
  reg cmd_start_r = 1'b0;
  always @(posedge ap_clk)
    cmd_start_r <= cmd_start;
  assign cmd_start_pulse = cmd_start & ~cmd_start_r & ~ap_idle;

  // cmd_exit:
  assign cmd_exit = (ap_control == 32'hFFFFFFFF);

  // cmd_idle:
  reg started;
  always_ff @(posedge(ap_clk))
  if (~ap_rst_n || ap_done) begin
    started <= 0;
  end else begin
    started <= (ap_start_pulse) ? 1'b1 : started;
  end
    

  // cmd_done:

  // cmd_timing:
  always_ff @(posedge ap_clk)
    if (ap_start_pulse)
      cmd_timing <= 'b0;
    else if (started)
      cmd_timing <= cmd_timing + 32'd1;

  //////////////////////////////////////////////////////////////////////////////
  // Kernel Interfacing Signals

  reg ap_done_r = 1'b0;
  reg ap_is_busy = 1'b0;
  always @(posedge ap_clk)
    if (~ap_rst_n || ap_done)
      ap_is_busy <= 1'b0;
    else if (ap_start)
      ap_is_busy <= 1'b1;

  // Done if all DMA's are done
  assign ap_idle  = ~ap_start & ~ap_is_busy;
  assign ap_ready = ap_done;
  assign ap_done  = cmd_done & ~ap_done_r;


  always @(posedge ap_clk)
    ap_done_r <= cmd_done;


  always @(posedge ap_clk) begin
    ap_start_q <= ap_start;
  end

  assign ap_start_pulse = ap_start & ~ap_start_q;

  //////////////////////////////////////////////////////////////////////////////
  // Kernel's Status Registers

  assign ap_status = {30'b0, ap_idle, cmd_idle};

  assign ap_timing = cmd_timing;

////////////////////////////////////////////////////////////////////////////////
// Control/Status Registers
////////////////////////////////////////////////////////////////////////////////

  // AXI4-Lite slave interface
  csrs #(
    .C_S_AXI_ADDR_WIDTH ( C_S_AXI_CONTROL_ADDR_WIDTH ),
    .C_S_AXI_DATA_WIDTH ( C_S_AXI_CONTROL_DATA_WIDTH )
  )
  inst_csrs (
    .ACLK              ( ap_clk                ),
    .ARESET            ( 1'b0                  ),
    .ACLK_EN           ( 1'b1                  ),
    .AWVALID           ( s_axi_control_awvalid ),
    .AWREADY           ( s_axi_control_awready ),
    .AWADDR            ( s_axi_control_awaddr  ),
    .WVALID            ( s_axi_control_wvalid  ),
    .WREADY            ( s_axi_control_wready  ),
    .WDATA             ( s_axi_control_wdata   ),
    .WSTRB             ( s_axi_control_wstrb   ),
    .ARVALID           ( s_axi_control_arvalid ),
    .ARREADY           ( s_axi_control_arready ),
    .ARADDR            ( s_axi_control_araddr  ),
    .RVALID            ( s_axi_control_rvalid  ),
    .RREADY            ( s_axi_control_rready  ),
    .RDATA             ( s_axi_control_rdata   ),
    .RRESP             ( s_axi_control_rresp   ),
    .BVALID            ( s_axi_control_bvalid  ),
    .BREADY            ( s_axi_control_bready  ),
    .BRESP             ( s_axi_control_bresp   ),
    .interrupt         ( interrupt             ),
    .ap_start          ( ap_start              ),
    .ap_idle           ( ap_idle               ),
    .ap_ready          ( ap_ready              ),
    .ap_done           ( ap_done               ),
    // CSRs <-> COMP
    .ap_control        ( ap_control            ),
    .ap_status         ( ap_status             ),
    .ap_debug          ( ap_debug              ),
    .ap_timing         ( ap_timing             ),
    .hbm_params_0      (                       ),
    .hbm_params_1      (                       ),
    // CSRs <-> DMA
    .hbm_address00     ( dma_address[ 0]       ),
    .hbm_address01     ( dma_address[ 1]       ),
    .hbm_address02     ( dma_address[ 2]       ),
    .hbm_address03     ( dma_address[ 3]       ),
    .hbm_address04     ( dma_address[ 4]       ),
    .hbm_address05     ( dma_address[ 5]       ),
    .hbm_address06     ( dma_address[ 6]       ),
    .hbm_address07     ( dma_address[ 7]       ),
    .hbm_address08     ( dma_address[ 8]       ),
    .hbm_address09     ( dma_address[ 9]       ),
    .hbm_address10     ( dma_address[10]       ),
    .hbm_address11     ( dma_address[11]       ),
    .hbm_address12     ( dma_address[12]       ),
    .hbm_address13     ( dma_address[13]       ),
    .hbm_address14     ( dma_address[14]       ),
    .hbm_address15     ( dma_address[15]       ),
    .hbm_address16     ( dma_address[16]       ),
    .hbm_address17     ( dma_address[17]       ),
    .hbm_address18     ( dma_address[18]       ),
    .hbm_address19     ( dma_address[19]       ),
    .hbm_address20     ( dma_address[20]       ),
    .hbm_address21     ( dma_address[21]       ),
    .hbm_address22     ( dma_address[22]       ),
    .hbm_address23     ( dma_address[23]       ),
    .hbm_address24     ( dma_address[24]       ),
    .hbm_address25     ( dma_address[25]       ),
    .hbm_address26     ( dma_address[26]       ),
    .hbm_address27     ( dma_address[27]       ),
    .hbm_address28     ( dma_address[28]       ),
    .hbm_address29     ( dma_address[29]       ),
    .hbm_address30     ( dma_address[30]       ),
    .hbm_address31     ( dma_address[31]       )
  );


////////////////////////////////////////////////////////////////////////////////
// HBM Interface
//
//             ┌─────────────────────────────────────────────────────┐
// ┌─────┐     │   ┌────────┐            ┌──────┐          ┌──────┐  │
// │     │---16x-->│ DMA_rx │-16x256bit->│ FIFO │-4096bit->│      |  |
// |     |     │   └────────┘            └──────┘          |      |  |  ┌──────┐
// | HBM |     │   ┌────────────────────────────┐          | COMP |<─│─>│ CSRS │
// |     |     │   |┌──────┐                    |          │      |  |  └──────┘
// |     |<--16x---|│ FIFO │<-16x256bit- DMA_tx │<-4096bit-│      |  |
// └─────┘     │   |└──────┘                    |          |      |  |
//             |   └────────────────────────────┘          └──────┘  |
//             └─────────────────────────────────────────────────────┘
//
// * Input/Output data: 4096*64-bit
// * 16 HBM Pseudo Channels for input data from HBM
// * 16 HBM Pseudo Channels for output data to HBM
// * Each port is 256-bit width.
// * Input/Output data transfer requires bursts of 64 AXI transfers:
//      (4096*64-bit) / (256-bit*16) = 64
// * Maximum burst size is 128 (as 4KiB for a burst the max)
//
////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////

// Declare AXI interfaces

// HBM <-> DMA
axi4_t #(
    .AXI_ADDR_WIDTH(HBM_ADDR_WIDTH),
    .AXI_DATA_WIDTH(HBM_DATA_WIDTH)
) dma_axi[`HBM_PC_COUNT]();


relin_t #(
    .LOGL(LOGL),    // From tb parameters
    .LOGQ(LOGQ),    // From tb parameters
    .TP(TP)// TP = 2^LOGTP
) relin_t_inst ();


//////////////////////////////////////////////////////////////////////////////

wire [10:0] relin_dbg_state;
wire [5:0]  hbm_p0_dbg;
wire [5:0]  hbm_p1_dbg;
wire [5:0]  hbm_p2_dbg;
wire [5:0]  hbm_p3_dbg;
wire [4:0]  accum_dbg_state_main;
wire [1:0]  accum_dbg_state_st12;

wire [6:0] write_addr0_accum, read_addr0_accum;

wire [LOGL-1:0] accum_ctr0;
wire [LOGL-1:0] accum_ctr1;
wire [LOGL-1:0] cu_out_ctr;
wire [10:0]      cu_out_state;
wire [15:0]      cu_p0_state;
wire [LOGL-1:0] ctr_L_out_cu_p0;
wire [LOGL-1:0] ctr_L__out_cu_p0;
wire [LOGL-1:0] ctr_poly_out_cu_p0;
wire [10:0]       state_p1_p2_out;
wire [LOGL-1:0] ctr_L_out_p1_p2;
wire [LOGL-1:0] ctr_L__out_p1_p2;
wire [LOGL-1:0] ctr_out_p1_p2;
wire [LOGL-1:0] ctr_relin;

wire [LOGQ-1:0] ntt_o_data_last_dbg, ntt_i_data_last_dbg, ntt_valid_out_dbg, fifo_0_dbg_reg, fifo_1_dbg_reg, i_p1_data_d5_reg, i_p2_data_d5_reg, had_0_dbg_data, had_1_dbg_data, ntt_i_data_dbg, psi_i_data_dbg, fifo_0_i_data_dbg, fifo_1_i_data_dbg, had_0_i_poly_A_dbg, had_0_i_poly_B_dbg, had_1_i_poly_A_dbg, had_1_i_poly_B_dbg, acc_i_poly_0_dbg, acc_i_poly_1_dbg, acc_o_data_dbg, intt_i_poly_dbg, fn_i_poly_dbg, fn_o_poly_dbg;
wire [LOGQ-1:0] had_0_i_poly_last, had_1_i_poly_last, had_0_o_poly_last, had_1_o_poly_last, acc_i_0_poly_last, acc_i_1_poly_last, acc_o_poly_last, intt_i_poly_last, fn_i_poly_last, fn_o_poly_last;

wire [LOGQ-1:0] acc_i_poly_0_dbg_4, acc_i_0_poly_last_4, acc_i_poly_0_dbg_8, acc_i_0_poly_last_8, acc_i_poly_0_dbg_16, acc_i_0_poly_last_16, acc_i_poly_0_dbg_20, acc_i_0_poly_last_20, acc_i_poly_0_dbg_27, acc_i_0_poly_last_27;

wire [2:0] ctr_ntt_start_sig;

wire [LOGQ-1:0] had_0_i_poly_last_B;

relin #(
    .L        (L       ),
    .LOGQ     (LOGQ     ),
    .LOGQH    (LOGQH    ),
    .LOGN     (LOGN     ),
    .LOGTP    (LOGTP    ),
    .EN_ADD   (EN_ADD   ),
    .PSI_CC   (PSI_CC   )
) inst_relin (
    .clk     (ap_clk    ),
    .rst     (~ap_rst_n ),
    .start   (ap_start_pulse),
    .done    (cmd_done      ),
    .relin_t (relin_t_inst  )
);

relin_hbm_adapter #(
    .L              (L             ),
    .LOGN           (LOGN           ),
    .LOGTP          (LOGTP          ),
    .LOGQ           (LOGQ           ),
    .PSI_CC         (PSI_CC         ),
    .HBM_ADDR_WIDTH (HBM_ADDR_WIDTH ),
    .HBM_DATA_WIDTH (HBM_DATA_WIDTH )
) inst_relin_hbm_adapter (
    .clk     (ap_clk    ),
    .rst     (~ap_rst_n ),
    .start   (ap_start_pulse ),
    .dma_address(dma_address ),
    .relin_t (relin_t_inst   ),
    .m_axi   (dma_axi        )
);


////////////////////////////////////////////////////////////////////////////////
// Make AXI interface connections to kernel module's port definitions
////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////
  // Python generated code

  assign m00_axi_awaddr      = dma_axi[ 0].awaddr  ;
  assign m00_axi_awlen       = dma_axi[ 0].awlen   ;
  assign m00_axi_awsize      = dma_axi[ 0].awsize  ;
  assign m00_axi_awburst     = dma_axi[ 0].awburst ;
  assign m00_axi_awvalid     = dma_axi[ 0].awvalid ;
  assign dma_axi[ 0].awready = m00_axi_awready     ;
  assign m00_axi_wdata       = dma_axi[ 0].wdata   ;
  assign m00_axi_wstrb       = dma_axi[ 0].wstrb   ;
  assign m00_axi_wlast       = dma_axi[ 0].wlast   ;
  assign m00_axi_wvalid      = dma_axi[ 0].wvalid  ;
  assign dma_axi[ 0].wready  = m00_axi_wready      ;
  assign dma_axi[ 0].bvalid  = m00_axi_bvalid      ;
  assign m00_axi_bready      = dma_axi[ 0].bready  ;
  assign m00_axi_araddr      = dma_axi[ 0].araddr  ;
  assign m00_axi_arlen       = dma_axi[ 0].arlen   ;
  assign m00_axi_arsize      = dma_axi[ 0].arsize  ;
  assign m00_axi_arburst     = dma_axi[ 0].arburst ;
  assign m00_axi_arvalid     = dma_axi[ 0].arvalid ;
  assign dma_axi[ 0].arready = m00_axi_arready     ;
  assign dma_axi[ 0].rdata   = m00_axi_rdata       ;
  assign dma_axi[ 0].rlast   = m00_axi_rlast       ;
  assign dma_axi[ 0].rvalid  = m00_axi_rvalid      ;
  assign m00_axi_rready      = dma_axi[ 0].rready  ;

  assign m01_axi_awaddr      = dma_axi[ 1].awaddr  ;
  assign m01_axi_awlen       = dma_axi[ 1].awlen   ;
  assign m01_axi_awsize      = dma_axi[ 1].awsize  ;
  assign m01_axi_awburst     = dma_axi[ 1].awburst ;
  assign m01_axi_awvalid     = dma_axi[ 1].awvalid ;
  assign dma_axi[ 1].awready = m01_axi_awready     ;
  assign m01_axi_wdata       = dma_axi[ 1].wdata   ;
  assign m01_axi_wstrb       = dma_axi[ 1].wstrb   ;
  assign m01_axi_wlast       = dma_axi[ 1].wlast   ;
  assign m01_axi_wvalid      = dma_axi[ 1].wvalid  ;
  assign dma_axi[ 1].wready  = m01_axi_wready      ;
  assign dma_axi[ 1].bvalid  = m01_axi_bvalid      ;
  assign m01_axi_bready      = dma_axi[ 1].bready  ;
  assign m01_axi_araddr      = dma_axi[ 1].araddr  ;
  assign m01_axi_arlen       = dma_axi[ 1].arlen   ;
  assign m01_axi_arsize      = dma_axi[ 1].arsize  ;
  assign m01_axi_arburst     = dma_axi[ 1].arburst ;
  assign m01_axi_arvalid     = dma_axi[ 1].arvalid ;
  assign dma_axi[ 1].arready = m01_axi_arready     ;
  assign dma_axi[ 1].rdata   = m01_axi_rdata       ;
  assign dma_axi[ 1].rlast   = m01_axi_rlast       ;
  assign dma_axi[ 1].rvalid  = m01_axi_rvalid      ;
  assign m01_axi_rready      = dma_axi[ 1].rready  ;

  assign m02_axi_awaddr      = dma_axi[ 2].awaddr  ;
  assign m02_axi_awlen       = dma_axi[ 2].awlen   ;
  assign m02_axi_awsize      = dma_axi[ 2].awsize  ;
  assign m02_axi_awburst     = dma_axi[ 2].awburst ;
  assign m02_axi_awvalid     = dma_axi[ 2].awvalid ;
  assign dma_axi[ 2].awready = m02_axi_awready     ;
  assign m02_axi_wdata       = dma_axi[ 2].wdata   ;
  assign m02_axi_wstrb       = dma_axi[ 2].wstrb   ;
  assign m02_axi_wlast       = dma_axi[ 2].wlast   ;
  assign m02_axi_wvalid      = dma_axi[ 2].wvalid  ;
  assign dma_axi[ 2].wready  = m02_axi_wready      ;
  assign dma_axi[ 2].bvalid  = m02_axi_bvalid      ;
  assign m02_axi_bready      = dma_axi[ 2].bready  ;
  assign m02_axi_araddr      = dma_axi[ 2].araddr  ;
  assign m02_axi_arlen       = dma_axi[ 2].arlen   ;
  assign m02_axi_arsize      = dma_axi[ 2].arsize  ;
  assign m02_axi_arburst     = dma_axi[ 2].arburst ;
  assign m02_axi_arvalid     = dma_axi[ 2].arvalid ;
  assign dma_axi[ 2].arready = m02_axi_arready     ;
  assign dma_axi[ 2].rdata   = m02_axi_rdata       ;
  assign dma_axi[ 2].rlast   = m02_axi_rlast       ;
  assign dma_axi[ 2].rvalid  = m02_axi_rvalid      ;
  assign m02_axi_rready      = dma_axi[ 2].rready  ;

  assign m03_axi_awaddr      = dma_axi[ 3].awaddr  ;
  assign m03_axi_awlen       = dma_axi[ 3].awlen   ;
  assign m03_axi_awsize      = dma_axi[ 3].awsize  ;
  assign m03_axi_awburst     = dma_axi[ 3].awburst ;
  assign m03_axi_awvalid     = dma_axi[ 3].awvalid ;
  assign dma_axi[ 3].awready = m03_axi_awready     ;
  assign m03_axi_wdata       = dma_axi[ 3].wdata   ;
  assign m03_axi_wstrb       = dma_axi[ 3].wstrb   ;
  assign m03_axi_wlast       = dma_axi[ 3].wlast   ;
  assign m03_axi_wvalid      = dma_axi[ 3].wvalid  ;
  assign dma_axi[ 3].wready  = m03_axi_wready      ;
  assign dma_axi[ 3].bvalid  = m03_axi_bvalid      ;
  assign m03_axi_bready      = dma_axi[ 3].bready  ;
  assign m03_axi_araddr      = dma_axi[ 3].araddr  ;
  assign m03_axi_arlen       = dma_axi[ 3].arlen   ;
  assign m03_axi_arsize      = dma_axi[ 3].arsize  ;
  assign m03_axi_arburst     = dma_axi[ 3].arburst ;
  assign m03_axi_arvalid     = dma_axi[ 3].arvalid ;
  assign dma_axi[ 3].arready = m03_axi_arready     ;
  assign dma_axi[ 3].rdata   = m03_axi_rdata       ;
  assign dma_axi[ 3].rlast   = m03_axi_rlast       ;
  assign dma_axi[ 3].rvalid  = m03_axi_rvalid      ;
  assign m03_axi_rready      = dma_axi[ 3].rready  ;

  assign m04_axi_awaddr      = dma_axi[ 4].awaddr  ;
  assign m04_axi_awlen       = dma_axi[ 4].awlen   ;
  assign m04_axi_awsize      = dma_axi[ 4].awsize  ;
  assign m04_axi_awburst     = dma_axi[ 4].awburst ;
  assign m04_axi_awvalid     = dma_axi[ 4].awvalid ;
  assign dma_axi[ 4].awready = m04_axi_awready     ;
  assign m04_axi_wdata       = dma_axi[ 4].wdata   ;
  assign m04_axi_wstrb       = dma_axi[ 4].wstrb   ;
  assign m04_axi_wlast       = dma_axi[ 4].wlast   ;
  assign m04_axi_wvalid      = dma_axi[ 4].wvalid  ;
  assign dma_axi[ 4].wready  = m04_axi_wready      ;
  assign dma_axi[ 4].bvalid  = m04_axi_bvalid      ;
  assign m04_axi_bready      = dma_axi[ 4].bready  ;
  assign m04_axi_araddr      = dma_axi[ 4].araddr  ;
  assign m04_axi_arlen       = dma_axi[ 4].arlen   ;
  assign m04_axi_arsize      = dma_axi[ 4].arsize  ;
  assign m04_axi_arburst     = dma_axi[ 4].arburst ;
  assign m04_axi_arvalid     = dma_axi[ 4].arvalid ;
  assign dma_axi[ 4].arready = m04_axi_arready     ;
  assign dma_axi[ 4].rdata   = m04_axi_rdata       ;
  assign dma_axi[ 4].rlast   = m04_axi_rlast       ;
  assign dma_axi[ 4].rvalid  = m04_axi_rvalid      ;
  assign m04_axi_rready      = dma_axi[ 4].rready  ;

  assign m05_axi_awaddr      = dma_axi[ 5].awaddr  ;
  assign m05_axi_awlen       = dma_axi[ 5].awlen   ;
  assign m05_axi_awsize      = dma_axi[ 5].awsize  ;
  assign m05_axi_awburst     = dma_axi[ 5].awburst ;
  assign m05_axi_awvalid     = dma_axi[ 5].awvalid ;
  assign dma_axi[ 5].awready = m05_axi_awready     ;
  assign m05_axi_wdata       = dma_axi[ 5].wdata   ;
  assign m05_axi_wstrb       = dma_axi[ 5].wstrb   ;
  assign m05_axi_wlast       = dma_axi[ 5].wlast   ;
  assign m05_axi_wvalid      = dma_axi[ 5].wvalid  ;
  assign dma_axi[ 5].wready  = m05_axi_wready      ;
  assign dma_axi[ 5].bvalid  = m05_axi_bvalid      ;
  assign m05_axi_bready      = dma_axi[ 5].bready  ;
  assign m05_axi_araddr      = dma_axi[ 5].araddr  ;
  assign m05_axi_arlen       = dma_axi[ 5].arlen   ;
  assign m05_axi_arsize      = dma_axi[ 5].arsize  ;
  assign m05_axi_arburst     = dma_axi[ 5].arburst ;
  assign m05_axi_arvalid     = dma_axi[ 5].arvalid ;
  assign dma_axi[ 5].arready = m05_axi_arready     ;
  assign dma_axi[ 5].rdata   = m05_axi_rdata       ;
  assign dma_axi[ 5].rlast   = m05_axi_rlast       ;
  assign dma_axi[ 5].rvalid  = m05_axi_rvalid      ;
  assign m05_axi_rready      = dma_axi[ 5].rready  ;

  assign m06_axi_awaddr      = dma_axi[ 6].awaddr  ;
  assign m06_axi_awlen       = dma_axi[ 6].awlen   ;
  assign m06_axi_awsize      = dma_axi[ 6].awsize  ;
  assign m06_axi_awburst     = dma_axi[ 6].awburst ;
  assign m06_axi_awvalid     = dma_axi[ 6].awvalid ;
  assign dma_axi[ 6].awready = m06_axi_awready     ;
  assign m06_axi_wdata       = dma_axi[ 6].wdata   ;
  assign m06_axi_wstrb       = dma_axi[ 6].wstrb   ;
  assign m06_axi_wlast       = dma_axi[ 6].wlast   ;
  assign m06_axi_wvalid      = dma_axi[ 6].wvalid  ;
  assign dma_axi[ 6].wready  = m06_axi_wready      ;
  assign dma_axi[ 6].bvalid  = m06_axi_bvalid      ;
  assign m06_axi_bready      = dma_axi[ 6].bready  ;
  assign m06_axi_araddr      = dma_axi[ 6].araddr  ;
  assign m06_axi_arlen       = dma_axi[ 6].arlen   ;
  assign m06_axi_arsize      = dma_axi[ 6].arsize  ;
  assign m06_axi_arburst     = dma_axi[ 6].arburst ;
  assign m06_axi_arvalid     = dma_axi[ 6].arvalid ;
  assign dma_axi[ 6].arready = m06_axi_arready     ;
  assign dma_axi[ 6].rdata   = m06_axi_rdata       ;
  assign dma_axi[ 6].rlast   = m06_axi_rlast       ;
  assign dma_axi[ 6].rvalid  = m06_axi_rvalid      ;
  assign m06_axi_rready      = dma_axi[ 6].rready  ;

  assign m07_axi_awaddr      = dma_axi[ 7].awaddr  ;
  assign m07_axi_awlen       = dma_axi[ 7].awlen   ;
  assign m07_axi_awsize      = dma_axi[ 7].awsize  ;
  assign m07_axi_awburst     = dma_axi[ 7].awburst ;
  assign m07_axi_awvalid     = dma_axi[ 7].awvalid ;
  assign dma_axi[ 7].awready = m07_axi_awready     ;
  assign m07_axi_wdata       = dma_axi[ 7].wdata   ;
  assign m07_axi_wstrb       = dma_axi[ 7].wstrb   ;
  assign m07_axi_wlast       = dma_axi[ 7].wlast   ;
  assign m07_axi_wvalid      = dma_axi[ 7].wvalid  ;
  assign dma_axi[ 7].wready  = m07_axi_wready      ;
  assign dma_axi[ 7].bvalid  = m07_axi_bvalid      ;
  assign m07_axi_bready      = dma_axi[ 7].bready  ;
  assign m07_axi_araddr      = dma_axi[ 7].araddr  ;
  assign m07_axi_arlen       = dma_axi[ 7].arlen   ;
  assign m07_axi_arsize      = dma_axi[ 7].arsize  ;
  assign m07_axi_arburst     = dma_axi[ 7].arburst ;
  assign m07_axi_arvalid     = dma_axi[ 7].arvalid ;
  assign dma_axi[ 7].arready = m07_axi_arready     ;
  assign dma_axi[ 7].rdata   = m07_axi_rdata       ;
  assign dma_axi[ 7].rlast   = m07_axi_rlast       ;
  assign dma_axi[ 7].rvalid  = m07_axi_rvalid      ;
  assign m07_axi_rready      = dma_axi[ 7].rready  ;

  assign m08_axi_awaddr      = dma_axi[ 8].awaddr  ;
  assign m08_axi_awlen       = dma_axi[ 8].awlen   ;
  assign m08_axi_awsize      = dma_axi[ 8].awsize  ;
  assign m08_axi_awburst     = dma_axi[ 8].awburst ;
  assign m08_axi_awvalid     = dma_axi[ 8].awvalid ;
  assign dma_axi[ 8].awready = m08_axi_awready     ;
  assign m08_axi_wdata       = dma_axi[ 8].wdata   ;
  assign m08_axi_wstrb       = dma_axi[ 8].wstrb   ;
  assign m08_axi_wlast       = dma_axi[ 8].wlast   ;
  assign m08_axi_wvalid      = dma_axi[ 8].wvalid  ;
  assign dma_axi[ 8].wready  = m08_axi_wready      ;
  assign dma_axi[ 8].bvalid  = m08_axi_bvalid      ;
  assign m08_axi_bready      = dma_axi[ 8].bready  ;
  assign m08_axi_araddr      = dma_axi[ 8].araddr  ;
  assign m08_axi_arlen       = dma_axi[ 8].arlen   ;
  assign m08_axi_arsize      = dma_axi[ 8].arsize  ;
  assign m08_axi_arburst     = dma_axi[ 8].arburst ;
  assign m08_axi_arvalid     = dma_axi[ 8].arvalid ;
  assign dma_axi[ 8].arready = m08_axi_arready     ;
  assign dma_axi[ 8].rdata   = m08_axi_rdata       ;
  assign dma_axi[ 8].rlast   = m08_axi_rlast       ;
  assign dma_axi[ 8].rvalid  = m08_axi_rvalid      ;
  assign m08_axi_rready      = dma_axi[ 8].rready  ;

  assign m09_axi_awaddr      = dma_axi[ 9].awaddr  ;
  assign m09_axi_awlen       = dma_axi[ 9].awlen   ;
  assign m09_axi_awsize      = dma_axi[ 9].awsize  ;
  assign m09_axi_awburst     = dma_axi[ 9].awburst ;
  assign m09_axi_awvalid     = dma_axi[ 9].awvalid ;
  assign dma_axi[ 9].awready = m09_axi_awready     ;
  assign m09_axi_wdata       = dma_axi[ 9].wdata   ;
  assign m09_axi_wstrb       = dma_axi[ 9].wstrb   ;
  assign m09_axi_wlast       = dma_axi[ 9].wlast   ;
  assign m09_axi_wvalid      = dma_axi[ 9].wvalid  ;
  assign dma_axi[ 9].wready  = m09_axi_wready      ;
  assign dma_axi[ 9].bvalid  = m09_axi_bvalid      ;
  assign m09_axi_bready      = dma_axi[ 9].bready  ;
  assign m09_axi_araddr      = dma_axi[ 9].araddr  ;
  assign m09_axi_arlen       = dma_axi[ 9].arlen   ;
  assign m09_axi_arsize      = dma_axi[ 9].arsize  ;
  assign m09_axi_arburst     = dma_axi[ 9].arburst ;
  assign m09_axi_arvalid     = dma_axi[ 9].arvalid ;
  assign dma_axi[ 9].arready = m09_axi_arready     ;
  assign dma_axi[ 9].rdata   = m09_axi_rdata       ;
  assign dma_axi[ 9].rlast   = m09_axi_rlast       ;
  assign dma_axi[ 9].rvalid  = m09_axi_rvalid      ;
  assign m09_axi_rready      = dma_axi[ 9].rready  ;

  assign m10_axi_awaddr      = dma_axi[10].awaddr  ;
  assign m10_axi_awlen       = dma_axi[10].awlen   ;
  assign m10_axi_awsize      = dma_axi[10].awsize  ;
  assign m10_axi_awburst     = dma_axi[10].awburst ;
  assign m10_axi_awvalid     = dma_axi[10].awvalid ;
  assign dma_axi[10].awready = m10_axi_awready     ;
  assign m10_axi_wdata       = dma_axi[10].wdata   ;
  assign m10_axi_wstrb       = dma_axi[10].wstrb   ;
  assign m10_axi_wlast       = dma_axi[10].wlast   ;
  assign m10_axi_wvalid      = dma_axi[10].wvalid  ;
  assign dma_axi[10].wready  = m10_axi_wready      ;
  assign dma_axi[10].bvalid  = m10_axi_bvalid      ;
  assign m10_axi_bready      = dma_axi[10].bready  ;
  assign m10_axi_araddr      = dma_axi[10].araddr  ;
  assign m10_axi_arlen       = dma_axi[10].arlen   ;
  assign m10_axi_arsize      = dma_axi[10].arsize  ;
  assign m10_axi_arburst     = dma_axi[10].arburst ;
  assign m10_axi_arvalid     = dma_axi[10].arvalid ;
  assign dma_axi[10].arready = m10_axi_arready     ;
  assign dma_axi[10].rdata   = m10_axi_rdata       ;
  assign dma_axi[10].rlast   = m10_axi_rlast       ;
  assign dma_axi[10].rvalid  = m10_axi_rvalid      ;
  assign m10_axi_rready      = dma_axi[10].rready  ;

  assign m11_axi_awaddr      = dma_axi[11].awaddr  ;
  assign m11_axi_awlen       = dma_axi[11].awlen   ;
  assign m11_axi_awsize      = dma_axi[11].awsize  ;
  assign m11_axi_awburst     = dma_axi[11].awburst ;
  assign m11_axi_awvalid     = dma_axi[11].awvalid ;
  assign dma_axi[11].awready = m11_axi_awready     ;
  assign m11_axi_wdata       = dma_axi[11].wdata   ;
  assign m11_axi_wstrb       = dma_axi[11].wstrb   ;
  assign m11_axi_wlast       = dma_axi[11].wlast   ;
  assign m11_axi_wvalid      = dma_axi[11].wvalid  ;
  assign dma_axi[11].wready  = m11_axi_wready      ;
  assign dma_axi[11].bvalid  = m11_axi_bvalid      ;
  assign m11_axi_bready      = dma_axi[11].bready  ;
  assign m11_axi_araddr      = dma_axi[11].araddr  ;
  assign m11_axi_arlen       = dma_axi[11].arlen   ;
  assign m11_axi_arsize      = dma_axi[11].arsize  ;
  assign m11_axi_arburst     = dma_axi[11].arburst ;
  assign m11_axi_arvalid     = dma_axi[11].arvalid ;
  assign dma_axi[11].arready = m11_axi_arready     ;
  assign dma_axi[11].rdata   = m11_axi_rdata       ;
  assign dma_axi[11].rlast   = m11_axi_rlast       ;
  assign dma_axi[11].rvalid  = m11_axi_rvalid      ;
  assign m11_axi_rready      = dma_axi[11].rready  ;

  assign m12_axi_awaddr      = dma_axi[12].awaddr  ;
  assign m12_axi_awlen       = dma_axi[12].awlen   ;
  assign m12_axi_awsize      = dma_axi[12].awsize  ;
  assign m12_axi_awburst     = dma_axi[12].awburst ;
  assign m12_axi_awvalid     = dma_axi[12].awvalid ;
  assign dma_axi[12].awready = m12_axi_awready     ;
  assign m12_axi_wdata       = dma_axi[12].wdata   ;
  assign m12_axi_wstrb       = dma_axi[12].wstrb   ;
  assign m12_axi_wlast       = dma_axi[12].wlast   ;
  assign m12_axi_wvalid      = dma_axi[12].wvalid  ;
  assign dma_axi[12].wready  = m12_axi_wready      ;
  assign dma_axi[12].bvalid  = m12_axi_bvalid      ;
  assign m12_axi_bready      = dma_axi[12].bready  ;
  assign m12_axi_araddr      = dma_axi[12].araddr  ;
  assign m12_axi_arlen       = dma_axi[12].arlen   ;
  assign m12_axi_arsize      = dma_axi[12].arsize  ;
  assign m12_axi_arburst     = dma_axi[12].arburst ;
  assign m12_axi_arvalid     = dma_axi[12].arvalid ;
  assign dma_axi[12].arready = m12_axi_arready     ;
  assign dma_axi[12].rdata   = m12_axi_rdata       ;
  assign dma_axi[12].rlast   = m12_axi_rlast       ;
  assign dma_axi[12].rvalid  = m12_axi_rvalid      ;
  assign m12_axi_rready      = dma_axi[12].rready  ;

  assign m13_axi_awaddr      = dma_axi[13].awaddr  ;
  assign m13_axi_awlen       = dma_axi[13].awlen   ;
  assign m13_axi_awsize      = dma_axi[13].awsize  ;
  assign m13_axi_awburst     = dma_axi[13].awburst ;
  assign m13_axi_awvalid     = dma_axi[13].awvalid ;
  assign dma_axi[13].awready = m13_axi_awready     ;
  assign m13_axi_wdata       = dma_axi[13].wdata   ;
  assign m13_axi_wstrb       = dma_axi[13].wstrb   ;
  assign m13_axi_wlast       = dma_axi[13].wlast   ;
  assign m13_axi_wvalid      = dma_axi[13].wvalid  ;
  assign dma_axi[13].wready  = m13_axi_wready      ;
  assign dma_axi[13].bvalid  = m13_axi_bvalid      ;
  assign m13_axi_bready      = dma_axi[13].bready  ;
  assign m13_axi_araddr      = dma_axi[13].araddr  ;
  assign m13_axi_arlen       = dma_axi[13].arlen   ;
  assign m13_axi_arsize      = dma_axi[13].arsize  ;
  assign m13_axi_arburst     = dma_axi[13].arburst ;
  assign m13_axi_arvalid     = dma_axi[13].arvalid ;
  assign dma_axi[13].arready = m13_axi_arready     ;
  assign dma_axi[13].rdata   = m13_axi_rdata       ;
  assign dma_axi[13].rlast   = m13_axi_rlast       ;
  assign dma_axi[13].rvalid  = m13_axi_rvalid      ;
  assign m13_axi_rready      = dma_axi[13].rready  ;

  assign m14_axi_awaddr      = dma_axi[14].awaddr  ;
  assign m14_axi_awlen       = dma_axi[14].awlen   ;
  assign m14_axi_awsize      = dma_axi[14].awsize  ;
  assign m14_axi_awburst     = dma_axi[14].awburst ;
  assign m14_axi_awvalid     = dma_axi[14].awvalid ;
  assign dma_axi[14].awready = m14_axi_awready     ;
  assign m14_axi_wdata       = dma_axi[14].wdata   ;
  assign m14_axi_wstrb       = dma_axi[14].wstrb   ;
  assign m14_axi_wlast       = dma_axi[14].wlast   ;
  assign m14_axi_wvalid      = dma_axi[14].wvalid  ;
  assign dma_axi[14].wready  = m14_axi_wready      ;
  assign dma_axi[14].bvalid  = m14_axi_bvalid      ;
  assign m14_axi_bready      = dma_axi[14].bready  ;
  assign m14_axi_araddr      = dma_axi[14].araddr  ;
  assign m14_axi_arlen       = dma_axi[14].arlen   ;
  assign m14_axi_arsize      = dma_axi[14].arsize  ;
  assign m14_axi_arburst     = dma_axi[14].arburst ;
  assign m14_axi_arvalid     = dma_axi[14].arvalid ;
  assign dma_axi[14].arready = m14_axi_arready     ;
  assign dma_axi[14].rdata   = m14_axi_rdata       ;
  assign dma_axi[14].rlast   = m14_axi_rlast       ;
  assign dma_axi[14].rvalid  = m14_axi_rvalid      ;
  assign m14_axi_rready      = dma_axi[14].rready  ;

  assign m15_axi_awaddr      = dma_axi[15].awaddr  ;
  assign m15_axi_awlen       = dma_axi[15].awlen   ;
  assign m15_axi_awsize      = dma_axi[15].awsize  ;
  assign m15_axi_awburst     = dma_axi[15].awburst ;
  assign m15_axi_awvalid     = dma_axi[15].awvalid ;
  assign dma_axi[15].awready = m15_axi_awready     ;
  assign m15_axi_wdata       = dma_axi[15].wdata   ;
  assign m15_axi_wstrb       = dma_axi[15].wstrb   ;
  assign m15_axi_wlast       = dma_axi[15].wlast   ;
  assign m15_axi_wvalid      = dma_axi[15].wvalid  ;
  assign dma_axi[15].wready  = m15_axi_wready      ;
  assign dma_axi[15].bvalid  = m15_axi_bvalid      ;
  assign m15_axi_bready      = dma_axi[15].bready  ;
  assign m15_axi_araddr      = dma_axi[15].araddr  ;
  assign m15_axi_arlen       = dma_axi[15].arlen   ;
  assign m15_axi_arsize      = dma_axi[15].arsize  ;
  assign m15_axi_arburst     = dma_axi[15].arburst ;
  assign m15_axi_arvalid     = dma_axi[15].arvalid ;
  assign dma_axi[15].arready = m15_axi_arready     ;
  assign dma_axi[15].rdata   = m15_axi_rdata       ;
  assign dma_axi[15].rlast   = m15_axi_rlast       ;
  assign dma_axi[15].rvalid  = m15_axi_rvalid      ;
  assign m15_axi_rready      = dma_axi[15].rready  ;

  assign m16_axi_awaddr      = dma_axi[16].awaddr  ;
  assign m16_axi_awlen       = dma_axi[16].awlen   ;
  assign m16_axi_awsize      = dma_axi[16].awsize  ;
  assign m16_axi_awburst     = dma_axi[16].awburst ;
  assign m16_axi_awvalid     = dma_axi[16].awvalid ;
  assign dma_axi[16].awready = m16_axi_awready     ;
  assign m16_axi_wdata       = dma_axi[16].wdata   ;
  assign m16_axi_wstrb       = dma_axi[16].wstrb   ;
  assign m16_axi_wlast       = dma_axi[16].wlast   ;
  assign m16_axi_wvalid      = dma_axi[16].wvalid  ;
  assign dma_axi[16].wready  = m16_axi_wready      ;
  assign dma_axi[16].bvalid  = m16_axi_bvalid      ;
  assign m16_axi_bready      = dma_axi[16].bready  ;
  assign m16_axi_araddr      = dma_axi[16].araddr  ;
  assign m16_axi_arlen       = dma_axi[16].arlen   ;
  assign m16_axi_arsize      = dma_axi[16].arsize  ;
  assign m16_axi_arburst     = dma_axi[16].arburst ;
  assign m16_axi_arvalid     = dma_axi[16].arvalid ;
  assign dma_axi[16].arready = m16_axi_arready     ;
  assign dma_axi[16].rdata   = m16_axi_rdata       ;
  assign dma_axi[16].rlast   = m16_axi_rlast       ;
  assign dma_axi[16].rvalid  = m16_axi_rvalid      ;
  assign m16_axi_rready      = dma_axi[16].rready  ;

  assign m17_axi_awaddr      = dma_axi[17].awaddr  ;
  assign m17_axi_awlen       = dma_axi[17].awlen   ;
  assign m17_axi_awsize      = dma_axi[17].awsize  ;
  assign m17_axi_awburst     = dma_axi[17].awburst ;
  assign m17_axi_awvalid     = dma_axi[17].awvalid ;
  assign dma_axi[17].awready = m17_axi_awready     ;
  assign m17_axi_wdata       = dma_axi[17].wdata   ;
  assign m17_axi_wstrb       = dma_axi[17].wstrb   ;
  assign m17_axi_wlast       = dma_axi[17].wlast   ;
  assign m17_axi_wvalid      = dma_axi[17].wvalid  ;
  assign dma_axi[17].wready  = m17_axi_wready      ;
  assign dma_axi[17].bvalid  = m17_axi_bvalid      ;
  assign m17_axi_bready      = dma_axi[17].bready  ;
  assign m17_axi_araddr      = dma_axi[17].araddr  ;
  assign m17_axi_arlen       = dma_axi[17].arlen   ;
  assign m17_axi_arsize      = dma_axi[17].arsize  ;
  assign m17_axi_arburst     = dma_axi[17].arburst ;
  assign m17_axi_arvalid     = dma_axi[17].arvalid ;
  assign dma_axi[17].arready = m17_axi_arready     ;
  assign dma_axi[17].rdata   = m17_axi_rdata       ;
  assign dma_axi[17].rlast   = m17_axi_rlast       ;
  assign dma_axi[17].rvalid  = m17_axi_rvalid      ;
  assign m17_axi_rready      = dma_axi[17].rready  ;

  assign m18_axi_awaddr      = dma_axi[18].awaddr  ;
  assign m18_axi_awlen       = dma_axi[18].awlen   ;
  assign m18_axi_awsize      = dma_axi[18].awsize  ;
  assign m18_axi_awburst     = dma_axi[18].awburst ;
  assign m18_axi_awvalid     = dma_axi[18].awvalid ;
  assign dma_axi[18].awready = m18_axi_awready     ;
  assign m18_axi_wdata       = dma_axi[18].wdata   ;
  assign m18_axi_wstrb       = dma_axi[18].wstrb   ;
  assign m18_axi_wlast       = dma_axi[18].wlast   ;
  assign m18_axi_wvalid      = dma_axi[18].wvalid  ;
  assign dma_axi[18].wready  = m18_axi_wready      ;
  assign dma_axi[18].bvalid  = m18_axi_bvalid      ;
  assign m18_axi_bready      = dma_axi[18].bready  ;
  assign m18_axi_araddr      = dma_axi[18].araddr  ;
  assign m18_axi_arlen       = dma_axi[18].arlen   ;
  assign m18_axi_arsize      = dma_axi[18].arsize  ;
  assign m18_axi_arburst     = dma_axi[18].arburst ;
  assign m18_axi_arvalid     = dma_axi[18].arvalid ;
  assign dma_axi[18].arready = m18_axi_arready     ;
  assign dma_axi[18].rdata   = m18_axi_rdata       ;
  assign dma_axi[18].rlast   = m18_axi_rlast       ;
  assign dma_axi[18].rvalid  = m18_axi_rvalid      ;
  assign m18_axi_rready      = dma_axi[18].rready  ;

  assign m19_axi_awaddr      = dma_axi[19].awaddr  ;
  assign m19_axi_awlen       = dma_axi[19].awlen   ;
  assign m19_axi_awsize      = dma_axi[19].awsize  ;
  assign m19_axi_awburst     = dma_axi[19].awburst ;
  assign m19_axi_awvalid     = dma_axi[19].awvalid ;
  assign dma_axi[19].awready = m19_axi_awready     ;
  assign m19_axi_wdata       = dma_axi[19].wdata   ;
  assign m19_axi_wstrb       = dma_axi[19].wstrb   ;
  assign m19_axi_wlast       = dma_axi[19].wlast   ;
  assign m19_axi_wvalid      = dma_axi[19].wvalid  ;
  assign dma_axi[19].wready  = m19_axi_wready      ;
  assign dma_axi[19].bvalid  = m19_axi_bvalid      ;
  assign m19_axi_bready      = dma_axi[19].bready  ;
  assign m19_axi_araddr      = dma_axi[19].araddr  ;
  assign m19_axi_arlen       = dma_axi[19].arlen   ;
  assign m19_axi_arsize      = dma_axi[19].arsize  ;
  assign m19_axi_arburst     = dma_axi[19].arburst ;
  assign m19_axi_arvalid     = dma_axi[19].arvalid ;
  assign dma_axi[19].arready = m19_axi_arready     ;
  assign dma_axi[19].rdata   = m19_axi_rdata       ;
  assign dma_axi[19].rlast   = m19_axi_rlast       ;
  assign dma_axi[19].rvalid  = m19_axi_rvalid      ;
  assign m19_axi_rready      = dma_axi[19].rready  ;

  assign m20_axi_awaddr      = dma_axi[20].awaddr  ;
  assign m20_axi_awlen       = dma_axi[20].awlen   ;
  assign m20_axi_awsize      = dma_axi[20].awsize  ;
  assign m20_axi_awburst     = dma_axi[20].awburst ;
  assign m20_axi_awvalid     = dma_axi[20].awvalid ;
  assign dma_axi[20].awready = m20_axi_awready     ;
  assign m20_axi_wdata       = dma_axi[20].wdata   ;
  assign m20_axi_wstrb       = dma_axi[20].wstrb   ;
  assign m20_axi_wlast       = dma_axi[20].wlast   ;
  assign m20_axi_wvalid      = dma_axi[20].wvalid  ;
  assign dma_axi[20].wready  = m20_axi_wready      ;
  assign dma_axi[20].bvalid  = m20_axi_bvalid      ;
  assign m20_axi_bready      = dma_axi[20].bready  ;
  assign m20_axi_araddr      = dma_axi[20].araddr  ;
  assign m20_axi_arlen       = dma_axi[20].arlen   ;
  assign m20_axi_arsize      = dma_axi[20].arsize  ;
  assign m20_axi_arburst     = dma_axi[20].arburst ;
  assign m20_axi_arvalid     = dma_axi[20].arvalid ;
  assign dma_axi[20].arready = m20_axi_arready     ;
  assign dma_axi[20].rdata   = m20_axi_rdata       ;
  assign dma_axi[20].rlast   = m20_axi_rlast       ;
  assign dma_axi[20].rvalid  = m20_axi_rvalid      ;
  assign m20_axi_rready      = dma_axi[20].rready  ;

  assign m21_axi_awaddr      = dma_axi[21].awaddr  ;
  assign m21_axi_awlen       = dma_axi[21].awlen   ;
  assign m21_axi_awsize      = dma_axi[21].awsize  ;
  assign m21_axi_awburst     = dma_axi[21].awburst ;
  assign m21_axi_awvalid     = dma_axi[21].awvalid ;
  assign dma_axi[21].awready = m21_axi_awready     ;
  assign m21_axi_wdata       = dma_axi[21].wdata   ;
  assign m21_axi_wstrb       = dma_axi[21].wstrb   ;
  assign m21_axi_wlast       = dma_axi[21].wlast   ;
  assign m21_axi_wvalid      = dma_axi[21].wvalid  ;
  assign dma_axi[21].wready  = m21_axi_wready      ;
  assign dma_axi[21].bvalid  = m21_axi_bvalid      ;
  assign m21_axi_bready      = dma_axi[21].bready  ;
  assign m21_axi_araddr      = dma_axi[21].araddr  ;
  assign m21_axi_arlen       = dma_axi[21].arlen   ;
  assign m21_axi_arsize      = dma_axi[21].arsize  ;
  assign m21_axi_arburst     = dma_axi[21].arburst ;
  assign m21_axi_arvalid     = dma_axi[21].arvalid ;
  assign dma_axi[21].arready = m21_axi_arready     ;
  assign dma_axi[21].rdata   = m21_axi_rdata       ;
  assign dma_axi[21].rlast   = m21_axi_rlast       ;
  assign dma_axi[21].rvalid  = m21_axi_rvalid      ;
  assign m21_axi_rready      = dma_axi[21].rready  ;

  assign m22_axi_awaddr      = dma_axi[22].awaddr  ;
  assign m22_axi_awlen       = dma_axi[22].awlen   ;
  assign m22_axi_awsize      = dma_axi[22].awsize  ;
  assign m22_axi_awburst     = dma_axi[22].awburst ;
  assign m22_axi_awvalid     = dma_axi[22].awvalid ;
  assign dma_axi[22].awready = m22_axi_awready     ;
  assign m22_axi_wdata       = dma_axi[22].wdata   ;
  assign m22_axi_wstrb       = dma_axi[22].wstrb   ;
  assign m22_axi_wlast       = dma_axi[22].wlast   ;
  assign m22_axi_wvalid      = dma_axi[22].wvalid  ;
  assign dma_axi[22].wready  = m22_axi_wready      ;
  assign dma_axi[22].bvalid  = m22_axi_bvalid      ;
  assign m22_axi_bready      = dma_axi[22].bready  ;
  assign m22_axi_araddr      = dma_axi[22].araddr  ;
  assign m22_axi_arlen       = dma_axi[22].arlen   ;
  assign m22_axi_arsize      = dma_axi[22].arsize  ;
  assign m22_axi_arburst     = dma_axi[22].arburst ;
  assign m22_axi_arvalid     = dma_axi[22].arvalid ;
  assign dma_axi[22].arready = m22_axi_arready     ;
  assign dma_axi[22].rdata   = m22_axi_rdata       ;
  assign dma_axi[22].rlast   = m22_axi_rlast       ;
  assign dma_axi[22].rvalid  = m22_axi_rvalid      ;
  assign m22_axi_rready      = dma_axi[22].rready  ;

  assign m23_axi_awaddr      = dma_axi[23].awaddr  ;
  assign m23_axi_awlen       = dma_axi[23].awlen   ;
  assign m23_axi_awsize      = dma_axi[23].awsize  ;
  assign m23_axi_awburst     = dma_axi[23].awburst ;
  assign m23_axi_awvalid     = dma_axi[23].awvalid ;
  assign dma_axi[23].awready = m23_axi_awready     ;
  assign m23_axi_wdata       = dma_axi[23].wdata   ;
  assign m23_axi_wstrb       = dma_axi[23].wstrb   ;
  assign m23_axi_wlast       = dma_axi[23].wlast   ;
  assign m23_axi_wvalid      = dma_axi[23].wvalid  ;
  assign dma_axi[23].wready  = m23_axi_wready      ;
  assign dma_axi[23].bvalid  = m23_axi_bvalid      ;
  assign m23_axi_bready      = dma_axi[23].bready  ;
  assign m23_axi_araddr      = dma_axi[23].araddr  ;
  assign m23_axi_arlen       = dma_axi[23].arlen   ;
  assign m23_axi_arsize      = dma_axi[23].arsize  ;
  assign m23_axi_arburst     = dma_axi[23].arburst ;
  assign m23_axi_arvalid     = dma_axi[23].arvalid ;
  assign dma_axi[23].arready = m23_axi_arready     ;
  assign dma_axi[23].rdata   = m23_axi_rdata       ;
  assign dma_axi[23].rlast   = m23_axi_rlast       ;
  assign dma_axi[23].rvalid  = m23_axi_rvalid      ;
  assign m23_axi_rready      = dma_axi[23].rready  ;

  assign m24_axi_awaddr      = dma_axi[24].awaddr  ;
  assign m24_axi_awlen       = dma_axi[24].awlen   ;
  assign m24_axi_awsize      = dma_axi[24].awsize  ;
  assign m24_axi_awburst     = dma_axi[24].awburst ;
  assign m24_axi_awvalid     = dma_axi[24].awvalid ;
  assign dma_axi[24].awready = m24_axi_awready     ;
  assign m24_axi_wdata       = dma_axi[24].wdata   ;
  assign m24_axi_wstrb       = dma_axi[24].wstrb   ;
  assign m24_axi_wlast       = dma_axi[24].wlast   ;
  assign m24_axi_wvalid      = dma_axi[24].wvalid  ;
  assign dma_axi[24].wready  = m24_axi_wready      ;
  assign dma_axi[24].bvalid  = m24_axi_bvalid      ;
  assign m24_axi_bready      = dma_axi[24].bready  ;
  assign m24_axi_araddr      = dma_axi[24].araddr  ;
  assign m24_axi_arlen       = dma_axi[24].arlen   ;
  assign m24_axi_arsize      = dma_axi[24].arsize  ;
  assign m24_axi_arburst     = dma_axi[24].arburst ;
  assign m24_axi_arvalid     = dma_axi[24].arvalid ;
  assign dma_axi[24].arready = m24_axi_arready     ;
  assign dma_axi[24].rdata   = m24_axi_rdata       ;
  assign dma_axi[24].rlast   = m24_axi_rlast       ;
  assign dma_axi[24].rvalid  = m24_axi_rvalid      ;
  assign m24_axi_rready      = dma_axi[24].rready  ;

  assign m25_axi_awaddr      = dma_axi[25].awaddr  ;
  assign m25_axi_awlen       = dma_axi[25].awlen   ;
  assign m25_axi_awsize      = dma_axi[25].awsize  ;
  assign m25_axi_awburst     = dma_axi[25].awburst ;
  assign m25_axi_awvalid     = dma_axi[25].awvalid ;
  assign dma_axi[25].awready = m25_axi_awready     ;
  assign m25_axi_wdata       = dma_axi[25].wdata   ;
  assign m25_axi_wstrb       = dma_axi[25].wstrb   ;
  assign m25_axi_wlast       = dma_axi[25].wlast   ;
  assign m25_axi_wvalid      = dma_axi[25].wvalid  ;
  assign dma_axi[25].wready  = m25_axi_wready      ;
  assign dma_axi[25].bvalid  = m25_axi_bvalid      ;
  assign m25_axi_bready      = dma_axi[25].bready  ;
  assign m25_axi_araddr      = dma_axi[25].araddr  ;
  assign m25_axi_arlen       = dma_axi[25].arlen   ;
  assign m25_axi_arsize      = dma_axi[25].arsize  ;
  assign m25_axi_arburst     = dma_axi[25].arburst ;
  assign m25_axi_arvalid     = dma_axi[25].arvalid ;
  assign dma_axi[25].arready = m25_axi_arready     ;
  assign dma_axi[25].rdata   = m25_axi_rdata       ;
  assign dma_axi[25].rlast   = m25_axi_rlast       ;
  assign dma_axi[25].rvalid  = m25_axi_rvalid      ;
  assign m25_axi_rready      = dma_axi[25].rready  ;

  assign m26_axi_awaddr      = dma_axi[26].awaddr  ;
  assign m26_axi_awlen       = dma_axi[26].awlen   ;
  assign m26_axi_awsize      = dma_axi[26].awsize  ;
  assign m26_axi_awburst     = dma_axi[26].awburst ;
  assign m26_axi_awvalid     = dma_axi[26].awvalid ;
  assign dma_axi[26].awready = m26_axi_awready     ;
  assign m26_axi_wdata       = dma_axi[26].wdata   ;
  assign m26_axi_wstrb       = dma_axi[26].wstrb   ;
  assign m26_axi_wlast       = dma_axi[26].wlast   ;
  assign m26_axi_wvalid      = dma_axi[26].wvalid  ;
  assign dma_axi[26].wready  = m26_axi_wready      ;
  assign dma_axi[26].bvalid  = m26_axi_bvalid      ;
  assign m26_axi_bready      = dma_axi[26].bready  ;
  assign m26_axi_araddr      = dma_axi[26].araddr  ;
  assign m26_axi_arlen       = dma_axi[26].arlen   ;
  assign m26_axi_arsize      = dma_axi[26].arsize  ;
  assign m26_axi_arburst     = dma_axi[26].arburst ;
  assign m26_axi_arvalid     = dma_axi[26].arvalid ;
  assign dma_axi[26].arready = m26_axi_arready     ;
  assign dma_axi[26].rdata   = m26_axi_rdata       ;
  assign dma_axi[26].rlast   = m26_axi_rlast       ;
  assign dma_axi[26].rvalid  = m26_axi_rvalid      ;
  assign m26_axi_rready      = dma_axi[26].rready  ;

  assign m27_axi_awaddr      = dma_axi[27].awaddr  ;
  assign m27_axi_awlen       = dma_axi[27].awlen   ;
  assign m27_axi_awsize      = dma_axi[27].awsize  ;
  assign m27_axi_awburst     = dma_axi[27].awburst ;
  assign m27_axi_awvalid     = dma_axi[27].awvalid ;
  assign dma_axi[27].awready = m27_axi_awready     ;
  assign m27_axi_wdata       = dma_axi[27].wdata   ;
  assign m27_axi_wstrb       = dma_axi[27].wstrb   ;
  assign m27_axi_wlast       = dma_axi[27].wlast   ;
  assign m27_axi_wvalid      = dma_axi[27].wvalid  ;
  assign dma_axi[27].wready  = m27_axi_wready      ;
  assign dma_axi[27].bvalid  = m27_axi_bvalid      ;
  assign m27_axi_bready      = dma_axi[27].bready  ;
  assign m27_axi_araddr      = dma_axi[27].araddr  ;
  assign m27_axi_arlen       = dma_axi[27].arlen   ;
  assign m27_axi_arsize      = dma_axi[27].arsize  ;
  assign m27_axi_arburst     = dma_axi[27].arburst ;
  assign m27_axi_arvalid     = dma_axi[27].arvalid ;
  assign dma_axi[27].arready = m27_axi_arready     ;
  assign dma_axi[27].rdata   = m27_axi_rdata       ;
  assign dma_axi[27].rlast   = m27_axi_rlast       ;
  assign dma_axi[27].rvalid  = m27_axi_rvalid      ;
  assign m27_axi_rready      = dma_axi[27].rready  ;

  assign m28_axi_awaddr      = dma_axi[28].awaddr  ;
  assign m28_axi_awlen       = dma_axi[28].awlen   ;
  assign m28_axi_awsize      = dma_axi[28].awsize  ;
  assign m28_axi_awburst     = dma_axi[28].awburst ;
  assign m28_axi_awvalid     = dma_axi[28].awvalid ;
  assign dma_axi[28].awready = m28_axi_awready     ;
  assign m28_axi_wdata       = dma_axi[28].wdata   ;
  assign m28_axi_wstrb       = dma_axi[28].wstrb   ;
  assign m28_axi_wlast       = dma_axi[28].wlast   ;
  assign m28_axi_wvalid      = dma_axi[28].wvalid  ;
  assign dma_axi[28].wready  = m28_axi_wready      ;
  assign dma_axi[28].bvalid  = m28_axi_bvalid      ;
  assign m28_axi_bready      = dma_axi[28].bready  ;
  assign m28_axi_araddr      = dma_axi[28].araddr  ;
  assign m28_axi_arlen       = dma_axi[28].arlen   ;
  assign m28_axi_arsize      = dma_axi[28].arsize  ;
  assign m28_axi_arburst     = dma_axi[28].arburst ;
  assign m28_axi_arvalid     = dma_axi[28].arvalid ;
  assign dma_axi[28].arready = m28_axi_arready     ;
  assign dma_axi[28].rdata   = m28_axi_rdata       ;
  assign dma_axi[28].rlast   = m28_axi_rlast       ;
  assign dma_axi[28].rvalid  = m28_axi_rvalid      ;
  assign m28_axi_rready      = dma_axi[28].rready  ;

  assign m29_axi_awaddr      = dma_axi[29].awaddr  ;
  assign m29_axi_awlen       = dma_axi[29].awlen   ;
  assign m29_axi_awsize      = dma_axi[29].awsize  ;
  assign m29_axi_awburst     = dma_axi[29].awburst ;
  assign m29_axi_awvalid     = dma_axi[29].awvalid ;
  assign dma_axi[29].awready = m29_axi_awready     ;
  assign m29_axi_wdata       = dma_axi[29].wdata   ;
  assign m29_axi_wstrb       = dma_axi[29].wstrb   ;
  assign m29_axi_wlast       = dma_axi[29].wlast   ;
  assign m29_axi_wvalid      = dma_axi[29].wvalid  ;
  assign dma_axi[29].wready  = m29_axi_wready      ;
  assign dma_axi[29].bvalid  = m29_axi_bvalid      ;
  assign m29_axi_bready      = dma_axi[29].bready  ;
  assign m29_axi_araddr      = dma_axi[29].araddr  ;
  assign m29_axi_arlen       = dma_axi[29].arlen   ;
  assign m29_axi_arsize      = dma_axi[29].arsize  ;
  assign m29_axi_arburst     = dma_axi[29].arburst ;
  assign m29_axi_arvalid     = dma_axi[29].arvalid ;
  assign dma_axi[29].arready = m29_axi_arready     ;
  assign dma_axi[29].rdata   = m29_axi_rdata       ;
  assign dma_axi[29].rlast   = m29_axi_rlast       ;
  assign dma_axi[29].rvalid  = m29_axi_rvalid      ;
  assign m29_axi_rready      = dma_axi[29].rready  ;

  assign m30_axi_awaddr      = dma_axi[30].awaddr  ;
  assign m30_axi_awlen       = dma_axi[30].awlen   ;
  assign m30_axi_awsize      = dma_axi[30].awsize  ;
  assign m30_axi_awburst     = dma_axi[30].awburst ;
  assign m30_axi_awvalid     = dma_axi[30].awvalid ;
  assign dma_axi[30].awready = m30_axi_awready     ;
  assign m30_axi_wdata       = dma_axi[30].wdata   ;
  assign m30_axi_wstrb       = dma_axi[30].wstrb   ;
  assign m30_axi_wlast       = dma_axi[30].wlast   ;
  assign m30_axi_wvalid      = dma_axi[30].wvalid  ;
  assign dma_axi[30].wready  = m30_axi_wready      ;
  assign dma_axi[30].bvalid  = m30_axi_bvalid      ;
  assign m30_axi_bready      = dma_axi[30].bready  ;
  assign m30_axi_araddr      = dma_axi[30].araddr  ;
  assign m30_axi_arlen       = dma_axi[30].arlen   ;
  assign m30_axi_arsize      = dma_axi[30].arsize  ;
  assign m30_axi_arburst     = dma_axi[30].arburst ;
  assign m30_axi_arvalid     = dma_axi[30].arvalid ;
  assign dma_axi[30].arready = m30_axi_arready     ;
  assign dma_axi[30].rdata   = m30_axi_rdata       ;
  assign dma_axi[30].rlast   = m30_axi_rlast       ;
  assign dma_axi[30].rvalid  = m30_axi_rvalid      ;
  assign m30_axi_rready      = dma_axi[30].rready  ;

  assign m31_axi_awaddr      = dma_axi[31].awaddr  ;
  assign m31_axi_awlen       = dma_axi[31].awlen   ;
  assign m31_axi_awsize      = dma_axi[31].awsize  ;
  assign m31_axi_awburst     = dma_axi[31].awburst ;
  assign m31_axi_awvalid     = dma_axi[31].awvalid ;
  assign dma_axi[31].awready = m31_axi_awready     ;
  assign m31_axi_wdata       = dma_axi[31].wdata   ;
  assign m31_axi_wstrb       = dma_axi[31].wstrb   ;
  assign m31_axi_wlast       = dma_axi[31].wlast   ;
  assign m31_axi_wvalid      = dma_axi[31].wvalid  ;
  assign dma_axi[31].wready  = m31_axi_wready      ;
  assign dma_axi[31].bvalid  = m31_axi_bvalid      ;
  assign m31_axi_bready      = dma_axi[31].bready  ;
  assign m31_axi_araddr      = dma_axi[31].araddr  ;
  assign m31_axi_arlen       = dma_axi[31].arlen   ;
  assign m31_axi_arsize      = dma_axi[31].arsize  ;
  assign m31_axi_arburst     = dma_axi[31].arburst ;
  assign m31_axi_arvalid     = dma_axi[31].arvalid ;
  assign dma_axi[31].arready = m31_axi_arready     ;
  assign dma_axi[31].rdata   = m31_axi_rdata       ;
  assign dma_axi[31].rlast   = m31_axi_rlast       ;
  assign dma_axi[31].rvalid  = m31_axi_rvalid      ;
  assign m31_axi_rready      = dma_axi[31].rready  ;

endmodule
`default_nettype wire
