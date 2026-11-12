`timescale 1ns / 1ps

`define HUGE_WAIT   300
`define LONG_WAIT   100
`define RESET_TIME   25
`define CLK_PERIOD    4
`define CLK_HALF      2

module kernel_tb();
realtime timing_start_ns;
integer config_writes = 0;

initial begin
  #10000000;
  $fatal(1, "RTL simulation timeout: kernel did not complete within 10 ms");
end
// Functional fixture: N=4096, TP=64, L=2; modulus tables supply Q primes and p.
parameter LOGN  = 12;
parameter LOGQ  = 32;
parameter LOGQH = 15;
parameter LOGTP = 6 ;
parameter EN_ADD= 1 ;
parameter L     = 2 ;

parameter MEM_FILE_WIDTH_USR = (LOGTP == 5) ? 64 : LOGTP == 6 ? 32 : 0;

// parameters for kernel
parameter integer C_S_AXI_CONTROL_ADDR_WIDTH = 12;
parameter integer C_S_AXI_CONTROL_DATA_WIDTH = 32;
parameter integer HBM_ADDR_WIDTH             = 64; // device/CSR width; axi_ram caps storage separately
parameter integer HBM_DATA_WIDTH             = 256;
localparam integer C_M00_AXI_ADDR_WIDTH = HBM_ADDR_WIDTH;
localparam integer C_M00_AXI_DATA_WIDTH = HBM_DATA_WIDTH;
localparam integer C_M01_AXI_ADDR_WIDTH = HBM_ADDR_WIDTH;
localparam integer C_M01_AXI_DATA_WIDTH = HBM_DATA_WIDTH;
localparam integer C_M02_AXI_ADDR_WIDTH = HBM_ADDR_WIDTH;
localparam integer C_M02_AXI_DATA_WIDTH = HBM_DATA_WIDTH;
localparam integer C_M03_AXI_ADDR_WIDTH = HBM_ADDR_WIDTH;
localparam integer C_M03_AXI_DATA_WIDTH = HBM_DATA_WIDTH;
localparam integer C_M04_AXI_ADDR_WIDTH = HBM_ADDR_WIDTH;
localparam integer C_M04_AXI_DATA_WIDTH = HBM_DATA_WIDTH;
localparam integer C_M05_AXI_ADDR_WIDTH = HBM_ADDR_WIDTH;
localparam integer C_M05_AXI_DATA_WIDTH = HBM_DATA_WIDTH;
localparam integer C_M06_AXI_ADDR_WIDTH = HBM_ADDR_WIDTH;
localparam integer C_M06_AXI_DATA_WIDTH = HBM_DATA_WIDTH;
localparam integer C_M07_AXI_ADDR_WIDTH = HBM_ADDR_WIDTH;
localparam integer C_M07_AXI_DATA_WIDTH = HBM_DATA_WIDTH;
localparam integer C_M08_AXI_ADDR_WIDTH = HBM_ADDR_WIDTH;
localparam integer C_M08_AXI_DATA_WIDTH = HBM_DATA_WIDTH;
localparam integer C_M09_AXI_ADDR_WIDTH = HBM_ADDR_WIDTH;
localparam integer C_M09_AXI_DATA_WIDTH = HBM_DATA_WIDTH;
localparam integer C_M10_AXI_ADDR_WIDTH = HBM_ADDR_WIDTH;
localparam integer C_M10_AXI_DATA_WIDTH = HBM_DATA_WIDTH;
localparam integer C_M11_AXI_ADDR_WIDTH = HBM_ADDR_WIDTH;
localparam integer C_M11_AXI_DATA_WIDTH = HBM_DATA_WIDTH;
localparam integer C_M12_AXI_ADDR_WIDTH = HBM_ADDR_WIDTH;
localparam integer C_M12_AXI_DATA_WIDTH = HBM_DATA_WIDTH;
localparam integer C_M13_AXI_ADDR_WIDTH = HBM_ADDR_WIDTH;
localparam integer C_M13_AXI_DATA_WIDTH = HBM_DATA_WIDTH;
localparam integer C_M14_AXI_ADDR_WIDTH = HBM_ADDR_WIDTH;
localparam integer C_M14_AXI_DATA_WIDTH = HBM_DATA_WIDTH;
localparam integer C_M15_AXI_ADDR_WIDTH = HBM_ADDR_WIDTH;
localparam integer C_M15_AXI_DATA_WIDTH = HBM_DATA_WIDTH;
localparam integer C_M16_AXI_ADDR_WIDTH = HBM_ADDR_WIDTH;
localparam integer C_M16_AXI_DATA_WIDTH = HBM_DATA_WIDTH;
localparam integer C_M17_AXI_ADDR_WIDTH = HBM_ADDR_WIDTH;
localparam integer C_M17_AXI_DATA_WIDTH = HBM_DATA_WIDTH;
localparam integer C_M18_AXI_ADDR_WIDTH = HBM_ADDR_WIDTH;
localparam integer C_M18_AXI_DATA_WIDTH = HBM_DATA_WIDTH;
localparam integer C_M19_AXI_ADDR_WIDTH = HBM_ADDR_WIDTH;
localparam integer C_M19_AXI_DATA_WIDTH = HBM_DATA_WIDTH;
localparam integer C_M20_AXI_ADDR_WIDTH = HBM_ADDR_WIDTH;
localparam integer C_M20_AXI_DATA_WIDTH = HBM_DATA_WIDTH;
localparam integer C_M21_AXI_ADDR_WIDTH = HBM_ADDR_WIDTH;
localparam integer C_M21_AXI_DATA_WIDTH = HBM_DATA_WIDTH;
localparam integer C_M22_AXI_ADDR_WIDTH = HBM_ADDR_WIDTH;
localparam integer C_M22_AXI_DATA_WIDTH = HBM_DATA_WIDTH;
localparam integer C_M23_AXI_ADDR_WIDTH = HBM_ADDR_WIDTH;
localparam integer C_M23_AXI_DATA_WIDTH = HBM_DATA_WIDTH;
localparam integer C_M24_AXI_ADDR_WIDTH = HBM_ADDR_WIDTH;
localparam integer C_M24_AXI_DATA_WIDTH = HBM_DATA_WIDTH;
localparam integer C_M25_AXI_ADDR_WIDTH = HBM_ADDR_WIDTH;
localparam integer C_M25_AXI_DATA_WIDTH = HBM_DATA_WIDTH;
localparam integer C_M26_AXI_ADDR_WIDTH = HBM_ADDR_WIDTH;
localparam integer C_M26_AXI_DATA_WIDTH = HBM_DATA_WIDTH;
localparam integer C_M27_AXI_ADDR_WIDTH = HBM_ADDR_WIDTH;
localparam integer C_M27_AXI_DATA_WIDTH = HBM_DATA_WIDTH;
localparam integer C_M28_AXI_ADDR_WIDTH = HBM_ADDR_WIDTH;
localparam integer C_M28_AXI_DATA_WIDTH = HBM_DATA_WIDTH;
localparam integer C_M29_AXI_ADDR_WIDTH = HBM_ADDR_WIDTH;
localparam integer C_M29_AXI_DATA_WIDTH = HBM_DATA_WIDTH;
localparam integer C_M30_AXI_ADDR_WIDTH = HBM_ADDR_WIDTH;
localparam integer C_M30_AXI_DATA_WIDTH = HBM_DATA_WIDTH;
localparam integer C_M31_AXI_ADDR_WIDTH = HBM_ADDR_WIDTH;
localparam integer C_M31_AXI_DATA_WIDTH = HBM_DATA_WIDTH;




// Define internal regs and wires

reg          clk           ;
reg          aresetn       ;
wire         interrupt     ;
reg          done          ;

reg  [ 11:0] axils_araddr  ;
wire         axils_arready ;
reg          axils_arvalid ;
reg  [ 11:0] axils_awaddr  ;
wire         axils_awready ;
reg          axils_awvalid ;
reg          axils_bready  ;
wire [  1:0] axils_bresp   ;
wire         axils_bvalid  ;
wire [ 31:0] axils_rdata   ;
reg          axils_rready  ;
wire [  1:0] axils_rresp   ;
wire         axils_rvalid  ;
reg  [ 31:0] axils_wdata   ;
wire         axils_wready  ;
reg  [  3:0] axils_wstrb   ;
reg          axils_wvalid  ;

wire [159:0] pc_status     ;
wire         pc_asserted   ;

reg [31:0]   status;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////// Axi4 signals ////////////////////////////////////////////////////////////////////////////


wire [C_M00_AXI_ADDR_WIDTH-1:0]          m00_axi_awaddr ;
wire [8-1:0]                             m00_axi_awlen  ;
wire [2:0]                               m00_axi_awsize ;
wire [1:0]                               m00_axi_awburst;
wire                                     m00_axi_awvalid;
wire                                     m00_axi_awready;
wire [C_M00_AXI_DATA_WIDTH-1:0]          m00_axi_wdata  ;
wire [C_M00_AXI_DATA_WIDTH/8-1:0]        m00_axi_wstrb  ;
wire                                     m00_axi_wlast  ;
wire                                     m00_axi_wvalid ;
wire                                     m00_axi_wready ;
wire                                     m00_axi_bvalid ;
wire                                     m00_axi_bready ;
wire [C_M00_AXI_ADDR_WIDTH-1:0]          m00_axi_araddr ;
wire [8-1:0]                             m00_axi_arlen  ;
wire [2:0]                               m00_axi_arsize ;
wire [1:0]                               m00_axi_arburst;
wire                                     m00_axi_arvalid;
wire                                     m00_axi_arready;
wire [C_M00_AXI_DATA_WIDTH-1:0]          m00_axi_rdata  ;
wire                                     m00_axi_rlast  ;
wire                                     m00_axi_rvalid ;
wire                                     m00_axi_rready ;

wire [C_M01_AXI_ADDR_WIDTH-1:0]          m01_axi_awaddr ;
wire [8-1:0]                             m01_axi_awlen  ;
wire [2:0]                               m01_axi_awsize ;
wire [1:0]                               m01_axi_awburst;
wire                                     m01_axi_awvalid;
wire                                     m01_axi_awready;
wire [C_M01_AXI_DATA_WIDTH-1:0]          m01_axi_wdata  ;
wire [C_M01_AXI_DATA_WIDTH/8-1:0]        m01_axi_wstrb  ;
wire                                     m01_axi_wlast  ;
wire                                     m01_axi_wvalid ;
wire                                     m01_axi_wready ;
wire                                     m01_axi_bvalid ;
wire                                     m01_axi_bready ;
wire [C_M01_AXI_ADDR_WIDTH-1:0]          m01_axi_araddr ;
wire [8-1:0]                             m01_axi_arlen  ;
wire [2:0]                               m01_axi_arsize ;
wire [1:0]                               m01_axi_arburst;
wire                                     m01_axi_arvalid;
wire                                     m01_axi_arready;
wire [C_M01_AXI_DATA_WIDTH-1:0]          m01_axi_rdata  ;
wire                                     m01_axi_rlast  ;
wire                                     m01_axi_rvalid ;
wire                                     m01_axi_rready ;

wire [C_M02_AXI_ADDR_WIDTH-1:0]          m02_axi_awaddr ;
wire [8-1:0]                             m02_axi_awlen  ;
wire [2:0]                               m02_axi_awsize ;
wire [1:0]                               m02_axi_awburst;
wire                                     m02_axi_awvalid;
wire                                     m02_axi_awready;
wire [C_M02_AXI_DATA_WIDTH-1:0]          m02_axi_wdata  ;
wire [C_M02_AXI_DATA_WIDTH/8-1:0]        m02_axi_wstrb  ;
wire                                     m02_axi_wlast  ;
wire                                     m02_axi_wvalid ;
wire                                     m02_axi_wready ;
wire                                     m02_axi_bvalid ;
wire                                     m02_axi_bready ;
wire [C_M02_AXI_ADDR_WIDTH-1:0]          m02_axi_araddr ;
wire [8-1:0]                             m02_axi_arlen  ;
wire [2:0]                               m02_axi_arsize ;
wire [1:0]                               m02_axi_arburst;
wire                                     m02_axi_arvalid;
wire                                     m02_axi_arready;
wire [C_M02_AXI_DATA_WIDTH-1:0]          m02_axi_rdata  ;
wire                                     m02_axi_rlast  ;
wire                                     m02_axi_rvalid ;
wire                                     m02_axi_rready ;

wire [C_M03_AXI_ADDR_WIDTH-1:0]          m03_axi_awaddr ;
wire [8-1:0]                             m03_axi_awlen  ;
wire [2:0]                               m03_axi_awsize ;
wire [1:0]                               m03_axi_awburst;
wire                                     m03_axi_awvalid;
wire                                     m03_axi_awready;
wire [C_M03_AXI_DATA_WIDTH-1:0]          m03_axi_wdata  ;
wire [C_M03_AXI_DATA_WIDTH/8-1:0]        m03_axi_wstrb  ;
wire                                     m03_axi_wlast  ;
wire                                     m03_axi_wvalid ;
wire                                     m03_axi_wready ;
wire                                     m03_axi_bvalid ;
wire                                     m03_axi_bready ;
wire [C_M03_AXI_ADDR_WIDTH-1:0]          m03_axi_araddr ;
wire [8-1:0]                             m03_axi_arlen  ;
wire [2:0]                               m03_axi_arsize ;
wire [1:0]                               m03_axi_arburst;
wire                                     m03_axi_arvalid;
wire                                     m03_axi_arready;
wire [C_M03_AXI_DATA_WIDTH-1:0]          m03_axi_rdata  ;
wire                                     m03_axi_rlast  ;
wire                                     m03_axi_rvalid ;
wire                                     m03_axi_rready ;

wire [C_M04_AXI_ADDR_WIDTH-1:0]          m04_axi_awaddr ;
wire [8-1:0]                             m04_axi_awlen  ;
wire [2:0]                               m04_axi_awsize ;
wire [1:0]                               m04_axi_awburst;
wire                                     m04_axi_awvalid;
wire                                     m04_axi_awready;
wire [C_M04_AXI_DATA_WIDTH-1:0]          m04_axi_wdata  ;
wire [C_M04_AXI_DATA_WIDTH/8-1:0]        m04_axi_wstrb  ;
wire                                     m04_axi_wlast  ;
wire                                     m04_axi_wvalid ;
wire                                     m04_axi_wready ;
wire                                     m04_axi_bvalid ;
wire                                     m04_axi_bready ;
wire [C_M04_AXI_ADDR_WIDTH-1:0]          m04_axi_araddr ;
wire [8-1:0]                             m04_axi_arlen  ;
wire [2:0]                               m04_axi_arsize ;
wire [1:0]                               m04_axi_arburst;
wire                                     m04_axi_arvalid;
wire                                     m04_axi_arready;
wire [C_M04_AXI_DATA_WIDTH-1:0]          m04_axi_rdata  ;
wire                                     m04_axi_rlast  ;
wire                                     m04_axi_rvalid ;
wire                                     m04_axi_rready ;

wire [C_M05_AXI_ADDR_WIDTH-1:0]          m05_axi_awaddr ;
wire [8-1:0]                             m05_axi_awlen  ;
wire [2:0]                               m05_axi_awsize ;
wire [1:0]                               m05_axi_awburst;
wire                                     m05_axi_awvalid;
wire                                     m05_axi_awready;
wire [C_M05_AXI_DATA_WIDTH-1:0]          m05_axi_wdata  ;
wire [C_M05_AXI_DATA_WIDTH/8-1:0]        m05_axi_wstrb  ;
wire                                     m05_axi_wlast  ;
wire                                     m05_axi_wvalid ;
wire                                     m05_axi_wready ;
wire                                     m05_axi_bvalid ;
wire                                     m05_axi_bready ;
wire [C_M05_AXI_ADDR_WIDTH-1:0]          m05_axi_araddr ;
wire [8-1:0]                             m05_axi_arlen  ;
wire [2:0]                               m05_axi_arsize ;
wire [1:0]                               m05_axi_arburst;
wire                                     m05_axi_arvalid;
wire                                     m05_axi_arready;
wire [C_M05_AXI_DATA_WIDTH-1:0]          m05_axi_rdata  ;
wire                                     m05_axi_rlast  ;
wire                                     m05_axi_rvalid ;
wire                                     m05_axi_rready ;

wire [C_M06_AXI_ADDR_WIDTH-1:0]          m06_axi_awaddr ;
wire [8-1:0]                             m06_axi_awlen  ;
wire [2:0]                               m06_axi_awsize ;
wire [1:0]                               m06_axi_awburst;
wire                                     m06_axi_awvalid;
wire                                     m06_axi_awready;
wire [C_M06_AXI_DATA_WIDTH-1:0]          m06_axi_wdata  ;
wire [C_M06_AXI_DATA_WIDTH/8-1:0]        m06_axi_wstrb  ;
wire                                     m06_axi_wlast  ;
wire                                     m06_axi_wvalid ;
wire                                     m06_axi_wready ;
wire                                     m06_axi_bvalid ;
wire                                     m06_axi_bready ;
wire [C_M06_AXI_ADDR_WIDTH-1:0]          m06_axi_araddr ;
wire [8-1:0]                             m06_axi_arlen  ;
wire [2:0]                               m06_axi_arsize ;
wire [1:0]                               m06_axi_arburst;
wire                                     m06_axi_arvalid;
wire                                     m06_axi_arready;
wire [C_M06_AXI_DATA_WIDTH-1:0]          m06_axi_rdata  ;
wire                                     m06_axi_rlast  ;
wire                                     m06_axi_rvalid ;
wire                                     m06_axi_rready ;

wire [C_M07_AXI_ADDR_WIDTH-1:0]          m07_axi_awaddr ;
wire [8-1:0]                             m07_axi_awlen  ;
wire [2:0]                               m07_axi_awsize ;
wire [1:0]                               m07_axi_awburst;
wire                                     m07_axi_awvalid;
wire                                     m07_axi_awready;
wire [C_M07_AXI_DATA_WIDTH-1:0]          m07_axi_wdata  ;
wire [C_M07_AXI_DATA_WIDTH/8-1:0]        m07_axi_wstrb  ;
wire                                     m07_axi_wlast  ;
wire                                     m07_axi_wvalid ;
wire                                     m07_axi_wready ;
wire                                     m07_axi_bvalid ;
wire                                     m07_axi_bready ;
wire [C_M07_AXI_ADDR_WIDTH-1:0]          m07_axi_araddr ;
wire [8-1:0]                             m07_axi_arlen  ;
wire [2:0]                               m07_axi_arsize ;
wire [1:0]                               m07_axi_arburst;
wire                                     m07_axi_arvalid;
wire                                     m07_axi_arready;
wire [C_M07_AXI_DATA_WIDTH-1:0]          m07_axi_rdata  ;
wire                                     m07_axi_rlast  ;
wire                                     m07_axi_rvalid ;
wire                                     m07_axi_rready ;

wire [C_M08_AXI_ADDR_WIDTH-1:0]          m08_axi_awaddr ;
wire [8-1:0]                             m08_axi_awlen  ;
wire [2:0]                               m08_axi_awsize ;
wire [1:0]                               m08_axi_awburst;
wire                                     m08_axi_awvalid;
wire                                     m08_axi_awready;
wire [C_M08_AXI_DATA_WIDTH-1:0]          m08_axi_wdata  ;
wire [C_M08_AXI_DATA_WIDTH/8-1:0]        m08_axi_wstrb  ;
wire                                     m08_axi_wlast  ;
wire                                     m08_axi_wvalid ;
wire                                     m08_axi_wready ;
wire                                     m08_axi_bvalid ;
wire                                     m08_axi_bready ;
wire [C_M08_AXI_ADDR_WIDTH-1:0]          m08_axi_araddr ;
wire [8-1:0]                             m08_axi_arlen  ;
wire [2:0]                               m08_axi_arsize ;
wire [1:0]                               m08_axi_arburst;
wire                                     m08_axi_arvalid;
wire                                     m08_axi_arready;
wire [C_M08_AXI_DATA_WIDTH-1:0]          m08_axi_rdata  ;
wire                                     m08_axi_rlast  ;
wire                                     m08_axi_rvalid ;
wire                                     m08_axi_rready ;

wire [C_M09_AXI_ADDR_WIDTH-1:0]          m09_axi_awaddr ;
wire [8-1:0]                             m09_axi_awlen  ;
wire [2:0]                               m09_axi_awsize ;
wire [1:0]                               m09_axi_awburst;
wire                                     m09_axi_awvalid;
wire                                     m09_axi_awready;
wire [C_M09_AXI_DATA_WIDTH-1:0]          m09_axi_wdata  ;
wire [C_M09_AXI_DATA_WIDTH/8-1:0]        m09_axi_wstrb  ;
wire                                     m09_axi_wlast  ;
wire                                     m09_axi_wvalid ;
wire                                     m09_axi_wready ;
wire                                     m09_axi_bvalid ;
wire                                     m09_axi_bready ;
wire [C_M09_AXI_ADDR_WIDTH-1:0]          m09_axi_araddr ;
wire [8-1:0]                             m09_axi_arlen  ;
wire [2:0]                               m09_axi_arsize ;
wire [1:0]                               m09_axi_arburst;
wire                                     m09_axi_arvalid;
wire                                     m09_axi_arready;
wire [C_M09_AXI_DATA_WIDTH-1:0]          m09_axi_rdata  ;
wire                                     m09_axi_rlast  ;
wire                                     m09_axi_rvalid ;
wire                                     m09_axi_rready ;

wire [C_M10_AXI_ADDR_WIDTH-1:0]          m10_axi_awaddr ;
wire [8-1:0]                             m10_axi_awlen  ;
wire [2:0]                               m10_axi_awsize ;
wire [1:0]                               m10_axi_awburst;
wire                                     m10_axi_awvalid;
wire                                     m10_axi_awready;
wire [C_M10_AXI_DATA_WIDTH-1:0]          m10_axi_wdata  ;
wire [C_M10_AXI_DATA_WIDTH/8-1:0]        m10_axi_wstrb  ;
wire                                     m10_axi_wlast  ;
wire                                     m10_axi_wvalid ;
wire                                     m10_axi_wready ;
wire                                     m10_axi_bvalid ;
wire                                     m10_axi_bready ;
wire [C_M10_AXI_ADDR_WIDTH-1:0]          m10_axi_araddr ;
wire [8-1:0]                             m10_axi_arlen  ;
wire [2:0]                               m10_axi_arsize ;
wire [1:0]                               m10_axi_arburst;
wire                                     m10_axi_arvalid;
wire                                     m10_axi_arready;
wire [C_M10_AXI_DATA_WIDTH-1:0]          m10_axi_rdata  ;
wire                                     m10_axi_rlast  ;
wire                                     m10_axi_rvalid ;
wire                                     m10_axi_rready ;

wire [C_M11_AXI_ADDR_WIDTH-1:0]          m11_axi_awaddr ;
wire [8-1:0]                             m11_axi_awlen  ;
wire [2:0]                               m11_axi_awsize ;
wire [1:0]                               m11_axi_awburst;
wire                                     m11_axi_awvalid;
wire                                     m11_axi_awready;
wire [C_M11_AXI_DATA_WIDTH-1:0]          m11_axi_wdata  ;
wire [C_M11_AXI_DATA_WIDTH/8-1:0]        m11_axi_wstrb  ;
wire                                     m11_axi_wlast  ;
wire                                     m11_axi_wvalid ;
wire                                     m11_axi_wready ;
wire                                     m11_axi_bvalid ;
wire                                     m11_axi_bready ;
wire [C_M11_AXI_ADDR_WIDTH-1:0]          m11_axi_araddr ;
wire [8-1:0]                             m11_axi_arlen  ;
wire [2:0]                               m11_axi_arsize ;
wire [1:0]                               m11_axi_arburst;
wire                                     m11_axi_arvalid;
wire                                     m11_axi_arready;
wire [C_M11_AXI_DATA_WIDTH-1:0]          m11_axi_rdata  ;
wire                                     m11_axi_rlast  ;
wire                                     m11_axi_rvalid ;
wire                                     m11_axi_rready ;

wire [C_M12_AXI_ADDR_WIDTH-1:0]          m12_axi_awaddr ;
wire [8-1:0]                             m12_axi_awlen  ;
wire [2:0]                               m12_axi_awsize ;
wire [1:0]                               m12_axi_awburst;
wire                                     m12_axi_awvalid;
wire                                     m12_axi_awready;
wire [C_M12_AXI_DATA_WIDTH-1:0]          m12_axi_wdata  ;
wire [C_M12_AXI_DATA_WIDTH/8-1:0]        m12_axi_wstrb  ;
wire                                     m12_axi_wlast  ;
wire                                     m12_axi_wvalid ;
wire                                     m12_axi_wready ;
wire                                     m12_axi_bvalid ;
wire                                     m12_axi_bready ;
wire [C_M12_AXI_ADDR_WIDTH-1:0]          m12_axi_araddr ;
wire [8-1:0]                             m12_axi_arlen  ;
wire [2:0]                               m12_axi_arsize ;
wire [1:0]                               m12_axi_arburst;
wire                                     m12_axi_arvalid;
wire                                     m12_axi_arready;
wire [C_M12_AXI_DATA_WIDTH-1:0]          m12_axi_rdata  ;
wire                                     m12_axi_rlast  ;
wire                                     m12_axi_rvalid ;
wire                                     m12_axi_rready ;

wire [C_M13_AXI_ADDR_WIDTH-1:0]          m13_axi_awaddr ;
wire [8-1:0]                             m13_axi_awlen  ;
wire [2:0]                               m13_axi_awsize ;
wire [1:0]                               m13_axi_awburst;
wire                                     m13_axi_awvalid;
wire                                     m13_axi_awready;
wire [C_M13_AXI_DATA_WIDTH-1:0]          m13_axi_wdata  ;
wire [C_M13_AXI_DATA_WIDTH/8-1:0]        m13_axi_wstrb  ;
wire                                     m13_axi_wlast  ;
wire                                     m13_axi_wvalid ;
wire                                     m13_axi_wready ;
wire                                     m13_axi_bvalid ;
wire                                     m13_axi_bready ;
wire [C_M13_AXI_ADDR_WIDTH-1:0]          m13_axi_araddr ;
wire [8-1:0]                             m13_axi_arlen  ;
wire [2:0]                               m13_axi_arsize ;
wire [1:0]                               m13_axi_arburst;
wire                                     m13_axi_arvalid;
wire                                     m13_axi_arready;
wire [C_M13_AXI_DATA_WIDTH-1:0]          m13_axi_rdata  ;
wire                                     m13_axi_rlast  ;
wire                                     m13_axi_rvalid ;
wire                                     m13_axi_rready ;

wire [C_M14_AXI_ADDR_WIDTH-1:0]          m14_axi_awaddr ;
wire [8-1:0]                             m14_axi_awlen  ;
wire [2:0]                               m14_axi_awsize ;
wire [1:0]                               m14_axi_awburst;
wire                                     m14_axi_awvalid;
wire                                     m14_axi_awready;
wire [C_M14_AXI_DATA_WIDTH-1:0]          m14_axi_wdata  ;
wire [C_M14_AXI_DATA_WIDTH/8-1:0]        m14_axi_wstrb  ;
wire                                     m14_axi_wlast  ;
wire                                     m14_axi_wvalid ;
wire                                     m14_axi_wready ;
wire                                     m14_axi_bvalid ;
wire                                     m14_axi_bready ;
wire [C_M14_AXI_ADDR_WIDTH-1:0]          m14_axi_araddr ;
wire [8-1:0]                             m14_axi_arlen  ;
wire [2:0]                               m14_axi_arsize ;
wire [1:0]                               m14_axi_arburst;
wire                                     m14_axi_arvalid;
wire                                     m14_axi_arready;
wire [C_M14_AXI_DATA_WIDTH-1:0]          m14_axi_rdata  ;
wire                                     m14_axi_rlast  ;
wire                                     m14_axi_rvalid ;
wire                                     m14_axi_rready ;

wire [C_M15_AXI_ADDR_WIDTH-1:0]          m15_axi_awaddr ;
wire [8-1:0]                             m15_axi_awlen  ;
wire [2:0]                               m15_axi_awsize ;
wire [1:0]                               m15_axi_awburst;
wire                                     m15_axi_awvalid;
wire                                     m15_axi_awready;
wire [C_M15_AXI_DATA_WIDTH-1:0]          m15_axi_wdata  ;
wire [C_M15_AXI_DATA_WIDTH/8-1:0]        m15_axi_wstrb  ;
wire                                     m15_axi_wlast  ;
wire                                     m15_axi_wvalid ;
wire                                     m15_axi_wready ;
wire                                     m15_axi_bvalid ;
wire                                     m15_axi_bready ;
wire [C_M15_AXI_ADDR_WIDTH-1:0]          m15_axi_araddr ;
wire [8-1:0]                             m15_axi_arlen  ;
wire [2:0]                               m15_axi_arsize ;
wire [1:0]                               m15_axi_arburst;
wire                                     m15_axi_arvalid;
wire                                     m15_axi_arready;
wire [C_M15_AXI_DATA_WIDTH-1:0]          m15_axi_rdata  ;
wire                                     m15_axi_rlast  ;
wire                                     m15_axi_rvalid ;
wire                                     m15_axi_rready ;

wire [C_M16_AXI_ADDR_WIDTH-1:0]          m16_axi_awaddr ;
wire [8-1:0]                             m16_axi_awlen  ;
wire [2:0]                               m16_axi_awsize ;
wire [1:0]                               m16_axi_awburst;
wire                                     m16_axi_awvalid;
wire                                     m16_axi_awready;
wire [C_M16_AXI_DATA_WIDTH-1:0]          m16_axi_wdata  ;
wire [C_M16_AXI_DATA_WIDTH/8-1:0]        m16_axi_wstrb  ;
wire                                     m16_axi_wlast  ;
wire                                     m16_axi_wvalid ;
wire                                     m16_axi_wready ;
wire                                     m16_axi_bvalid ;
wire                                     m16_axi_bready ;
wire [C_M16_AXI_ADDR_WIDTH-1:0]          m16_axi_araddr ;
wire [8-1:0]                             m16_axi_arlen  ;
wire [2:0]                               m16_axi_arsize ;
wire [1:0]                               m16_axi_arburst;
wire                                     m16_axi_arvalid;
wire                                     m16_axi_arready;
wire [C_M16_AXI_DATA_WIDTH-1:0]          m16_axi_rdata  ;
wire                                     m16_axi_rlast  ;
wire                                     m16_axi_rvalid ;
wire                                     m16_axi_rready ;

wire [C_M17_AXI_ADDR_WIDTH-1:0]          m17_axi_awaddr ;
wire [8-1:0]                             m17_axi_awlen  ;
wire [2:0]                               m17_axi_awsize ;
wire [1:0]                               m17_axi_awburst;
wire                                     m17_axi_awvalid;
wire                                     m17_axi_awready;
wire [C_M17_AXI_DATA_WIDTH-1:0]          m17_axi_wdata  ;
wire [C_M17_AXI_DATA_WIDTH/8-1:0]        m17_axi_wstrb  ;
wire                                     m17_axi_wlast  ;
wire                                     m17_axi_wvalid ;
wire                                     m17_axi_wready ;
wire                                     m17_axi_bvalid ;
wire                                     m17_axi_bready ;
wire [C_M17_AXI_ADDR_WIDTH-1:0]          m17_axi_araddr ;
wire [8-1:0]                             m17_axi_arlen  ;
wire [2:0]                               m17_axi_arsize ;
wire [1:0]                               m17_axi_arburst;
wire                                     m17_axi_arvalid;
wire                                     m17_axi_arready;
wire [C_M17_AXI_DATA_WIDTH-1:0]          m17_axi_rdata  ;
wire                                     m17_axi_rlast  ;
wire                                     m17_axi_rvalid ;
wire                                     m17_axi_rready ;

wire [C_M18_AXI_ADDR_WIDTH-1:0]          m18_axi_awaddr ;
wire [8-1:0]                             m18_axi_awlen  ;
wire [2:0]                               m18_axi_awsize ;
wire [1:0]                               m18_axi_awburst;
wire                                     m18_axi_awvalid;
wire                                     m18_axi_awready;
wire [C_M18_AXI_DATA_WIDTH-1:0]          m18_axi_wdata  ;
wire [C_M18_AXI_DATA_WIDTH/8-1:0]        m18_axi_wstrb  ;
wire                                     m18_axi_wlast  ;
wire                                     m18_axi_wvalid ;
wire                                     m18_axi_wready ;
wire                                     m18_axi_bvalid ;
wire                                     m18_axi_bready ;
wire [C_M18_AXI_ADDR_WIDTH-1:0]          m18_axi_araddr ;
wire [8-1:0]                             m18_axi_arlen  ;
wire [2:0]                               m18_axi_arsize ;
wire [1:0]                               m18_axi_arburst;
wire                                     m18_axi_arvalid;
wire                                     m18_axi_arready;
wire [C_M18_AXI_DATA_WIDTH-1:0]          m18_axi_rdata  ;
wire                                     m18_axi_rlast  ;
wire                                     m18_axi_rvalid ;
wire                                     m18_axi_rready ;

wire [C_M19_AXI_ADDR_WIDTH-1:0]          m19_axi_awaddr ;
wire [8-1:0]                             m19_axi_awlen  ;
wire [2:0]                               m19_axi_awsize ;
wire [1:0]                               m19_axi_awburst;
wire                                     m19_axi_awvalid;
wire                                     m19_axi_awready;
wire [C_M19_AXI_DATA_WIDTH-1:0]          m19_axi_wdata  ;
wire [C_M19_AXI_DATA_WIDTH/8-1:0]        m19_axi_wstrb  ;
wire                                     m19_axi_wlast  ;
wire                                     m19_axi_wvalid ;
wire                                     m19_axi_wready ;
wire                                     m19_axi_bvalid ;
wire                                     m19_axi_bready ;
wire [C_M19_AXI_ADDR_WIDTH-1:0]          m19_axi_araddr ;
wire [8-1:0]                             m19_axi_arlen  ;
wire [2:0]                               m19_axi_arsize ;
wire [1:0]                               m19_axi_arburst;
wire                                     m19_axi_arvalid;
wire                                     m19_axi_arready;
wire [C_M19_AXI_DATA_WIDTH-1:0]          m19_axi_rdata  ;
wire                                     m19_axi_rlast  ;
wire                                     m19_axi_rvalid ;
wire                                     m19_axi_rready ;

wire [C_M20_AXI_ADDR_WIDTH-1:0]          m20_axi_awaddr ;
wire [8-1:0]                             m20_axi_awlen  ;
wire [2:0]                               m20_axi_awsize ;
wire [1:0]                               m20_axi_awburst;
wire                                     m20_axi_awvalid;
wire                                     m20_axi_awready;
wire [C_M20_AXI_DATA_WIDTH-1:0]          m20_axi_wdata  ;
wire [C_M20_AXI_DATA_WIDTH/8-1:0]        m20_axi_wstrb  ;
wire                                     m20_axi_wlast  ;
wire                                     m20_axi_wvalid ;
wire                                     m20_axi_wready ;
wire                                     m20_axi_bvalid ;
wire                                     m20_axi_bready ;
wire [C_M20_AXI_ADDR_WIDTH-1:0]          m20_axi_araddr ;
wire [8-1:0]                             m20_axi_arlen  ;
wire [2:0]                               m20_axi_arsize ;
wire [1:0]                               m20_axi_arburst;
wire                                     m20_axi_arvalid;
wire                                     m20_axi_arready;
wire [C_M20_AXI_DATA_WIDTH-1:0]          m20_axi_rdata  ;
wire                                     m20_axi_rlast  ;
wire                                     m20_axi_rvalid ;
wire                                     m20_axi_rready ;

wire [C_M21_AXI_ADDR_WIDTH-1:0]          m21_axi_awaddr ;
wire [8-1:0]                             m21_axi_awlen  ;
wire [2:0]                               m21_axi_awsize ;
wire [1:0]                               m21_axi_awburst;
wire                                     m21_axi_awvalid;
wire                                     m21_axi_awready;
wire [C_M21_AXI_DATA_WIDTH-1:0]          m21_axi_wdata  ;
wire [C_M21_AXI_DATA_WIDTH/8-1:0]        m21_axi_wstrb  ;
wire                                     m21_axi_wlast  ;
wire                                     m21_axi_wvalid ;
wire                                     m21_axi_wready ;
wire                                     m21_axi_bvalid ;
wire                                     m21_axi_bready ;
wire [C_M21_AXI_ADDR_WIDTH-1:0]          m21_axi_araddr ;
wire [8-1:0]                             m21_axi_arlen  ;
wire [2:0]                               m21_axi_arsize ;
wire [1:0]                               m21_axi_arburst;
wire                                     m21_axi_arvalid;
wire                                     m21_axi_arready;
wire [C_M21_AXI_DATA_WIDTH-1:0]          m21_axi_rdata  ;
wire                                     m21_axi_rlast  ;
wire                                     m21_axi_rvalid ;
wire                                     m21_axi_rready ;

wire [C_M22_AXI_ADDR_WIDTH-1:0]          m22_axi_awaddr ;
wire [8-1:0]                             m22_axi_awlen  ;
wire [2:0]                               m22_axi_awsize ;
wire [1:0]                               m22_axi_awburst;
wire                                     m22_axi_awvalid;
wire                                     m22_axi_awready;
wire [C_M22_AXI_DATA_WIDTH-1:0]          m22_axi_wdata  ;
wire [C_M22_AXI_DATA_WIDTH/8-1:0]        m22_axi_wstrb  ;
wire                                     m22_axi_wlast  ;
wire                                     m22_axi_wvalid ;
wire                                     m22_axi_wready ;
wire                                     m22_axi_bvalid ;
wire                                     m22_axi_bready ;
wire [C_M22_AXI_ADDR_WIDTH-1:0]          m22_axi_araddr ;
wire [8-1:0]                             m22_axi_arlen  ;
wire [2:0]                               m22_axi_arsize ;
wire [1:0]                               m22_axi_arburst;
wire                                     m22_axi_arvalid;
wire                                     m22_axi_arready;
wire [C_M22_AXI_DATA_WIDTH-1:0]          m22_axi_rdata  ;
wire                                     m22_axi_rlast  ;
wire                                     m22_axi_rvalid ;
wire                                     m22_axi_rready ;

wire [C_M23_AXI_ADDR_WIDTH-1:0]          m23_axi_awaddr ;
wire [8-1:0]                             m23_axi_awlen  ;
wire [2:0]                               m23_axi_awsize ;
wire [1:0]                               m23_axi_awburst;
wire                                     m23_axi_awvalid;
wire                                     m23_axi_awready;
wire [C_M23_AXI_DATA_WIDTH-1:0]          m23_axi_wdata  ;
wire [C_M23_AXI_DATA_WIDTH/8-1:0]        m23_axi_wstrb  ;
wire                                     m23_axi_wlast  ;
wire                                     m23_axi_wvalid ;
wire                                     m23_axi_wready ;
wire                                     m23_axi_bvalid ;
wire                                     m23_axi_bready ;
wire [C_M23_AXI_ADDR_WIDTH-1:0]          m23_axi_araddr ;
wire [8-1:0]                             m23_axi_arlen  ;
wire [2:0]                               m23_axi_arsize ;
wire [1:0]                               m23_axi_arburst;
wire                                     m23_axi_arvalid;
wire                                     m23_axi_arready;
wire [C_M23_AXI_DATA_WIDTH-1:0]          m23_axi_rdata  ;
wire                                     m23_axi_rlast  ;
wire                                     m23_axi_rvalid ;
wire                                     m23_axi_rready ;

wire [C_M24_AXI_ADDR_WIDTH-1:0]          m24_axi_awaddr ;
wire [8-1:0]                             m24_axi_awlen  ;
wire [2:0]                               m24_axi_awsize ;
wire [1:0]                               m24_axi_awburst;
wire                                     m24_axi_awvalid;
wire                                     m24_axi_awready;
wire [C_M24_AXI_DATA_WIDTH-1:0]          m24_axi_wdata  ;
wire [C_M24_AXI_DATA_WIDTH/8-1:0]        m24_axi_wstrb  ;
wire                                     m24_axi_wlast  ;
wire                                     m24_axi_wvalid ;
wire                                     m24_axi_wready ;
wire                                     m24_axi_bvalid ;
wire                                     m24_axi_bready ;
wire [C_M24_AXI_ADDR_WIDTH-1:0]          m24_axi_araddr ;
wire [8-1:0]                             m24_axi_arlen  ;
wire [2:0]                               m24_axi_arsize ;
wire [1:0]                               m24_axi_arburst;
wire                                     m24_axi_arvalid;
wire                                     m24_axi_arready;
wire [C_M24_AXI_DATA_WIDTH-1:0]          m24_axi_rdata  ;
wire                                     m24_axi_rlast  ;
wire                                     m24_axi_rvalid ;
wire                                     m24_axi_rready ;

wire [C_M25_AXI_ADDR_WIDTH-1:0]          m25_axi_awaddr ;
wire [8-1:0]                             m25_axi_awlen  ;
wire [2:0]                               m25_axi_awsize ;
wire [1:0]                               m25_axi_awburst;
wire                                     m25_axi_awvalid;
wire                                     m25_axi_awready;
wire [C_M25_AXI_DATA_WIDTH-1:0]          m25_axi_wdata  ;
wire [C_M25_AXI_DATA_WIDTH/8-1:0]        m25_axi_wstrb  ;
wire                                     m25_axi_wlast  ;
wire                                     m25_axi_wvalid ;
wire                                     m25_axi_wready ;
wire                                     m25_axi_bvalid ;
wire                                     m25_axi_bready ;
wire [C_M25_AXI_ADDR_WIDTH-1:0]          m25_axi_araddr ;
wire [8-1:0]                             m25_axi_arlen  ;
wire [2:0]                               m25_axi_arsize ;
wire [1:0]                               m25_axi_arburst;
wire                                     m25_axi_arvalid;
wire                                     m25_axi_arready;
wire [C_M25_AXI_DATA_WIDTH-1:0]          m25_axi_rdata  ;
wire                                     m25_axi_rlast  ;
wire                                     m25_axi_rvalid ;
wire                                     m25_axi_rready ;

wire [C_M26_AXI_ADDR_WIDTH-1:0]          m26_axi_awaddr ;
wire [8-1:0]                             m26_axi_awlen  ;
wire [2:0]                               m26_axi_awsize ;
wire [1:0]                               m26_axi_awburst;
wire                                     m26_axi_awvalid;
wire                                     m26_axi_awready;
wire [C_M26_AXI_DATA_WIDTH-1:0]          m26_axi_wdata  ;
wire [C_M26_AXI_DATA_WIDTH/8-1:0]        m26_axi_wstrb  ;
wire                                     m26_axi_wlast  ;
wire                                     m26_axi_wvalid ;
wire                                     m26_axi_wready ;
wire                                     m26_axi_bvalid ;
wire                                     m26_axi_bready ;
wire [C_M26_AXI_ADDR_WIDTH-1:0]          m26_axi_araddr ;
wire [8-1:0]                             m26_axi_arlen  ;
wire [2:0]                               m26_axi_arsize ;
wire [1:0]                               m26_axi_arburst;
wire                                     m26_axi_arvalid;
wire                                     m26_axi_arready;
wire [C_M26_AXI_DATA_WIDTH-1:0]          m26_axi_rdata  ;
wire                                     m26_axi_rlast  ;
wire                                     m26_axi_rvalid ;
wire                                     m26_axi_rready ;

wire [C_M27_AXI_ADDR_WIDTH-1:0]          m27_axi_awaddr ;
wire [8-1:0]                             m27_axi_awlen  ;
wire [2:0]                               m27_axi_awsize ;
wire [1:0]                               m27_axi_awburst;
wire                                     m27_axi_awvalid;
wire                                     m27_axi_awready;
wire [C_M27_AXI_DATA_WIDTH-1:0]          m27_axi_wdata  ;
wire [C_M27_AXI_DATA_WIDTH/8-1:0]        m27_axi_wstrb  ;
wire                                     m27_axi_wlast  ;
wire                                     m27_axi_wvalid ;
wire                                     m27_axi_wready ;
wire                                     m27_axi_bvalid ;
wire                                     m27_axi_bready ;
wire [C_M27_AXI_ADDR_WIDTH-1:0]          m27_axi_araddr ;
wire [8-1:0]                             m27_axi_arlen  ;
wire [2:0]                               m27_axi_arsize ;
wire [1:0]                               m27_axi_arburst;
wire                                     m27_axi_arvalid;
wire                                     m27_axi_arready;
wire [C_M27_AXI_DATA_WIDTH-1:0]          m27_axi_rdata  ;
wire                                     m27_axi_rlast  ;
wire                                     m27_axi_rvalid ;
wire                                     m27_axi_rready ;

wire [C_M28_AXI_ADDR_WIDTH-1:0]          m28_axi_awaddr ;
wire [8-1:0]                             m28_axi_awlen  ;
wire [2:0]                               m28_axi_awsize ;
wire [1:0]                               m28_axi_awburst;
wire                                     m28_axi_awvalid;
wire                                     m28_axi_awready;
wire [C_M28_AXI_DATA_WIDTH-1:0]          m28_axi_wdata  ;
wire [C_M28_AXI_DATA_WIDTH/8-1:0]        m28_axi_wstrb  ;
wire                                     m28_axi_wlast  ;
wire                                     m28_axi_wvalid ;
wire                                     m28_axi_wready ;
wire                                     m28_axi_bvalid ;
wire                                     m28_axi_bready ;
wire [C_M28_AXI_ADDR_WIDTH-1:0]          m28_axi_araddr ;
wire [8-1:0]                             m28_axi_arlen  ;
wire [2:0]                               m28_axi_arsize ;
wire [1:0]                               m28_axi_arburst;
wire                                     m28_axi_arvalid;
wire                                     m28_axi_arready;
wire [C_M28_AXI_DATA_WIDTH-1:0]          m28_axi_rdata  ;
wire                                     m28_axi_rlast  ;
wire                                     m28_axi_rvalid ;
wire                                     m28_axi_rready ;

wire [C_M29_AXI_ADDR_WIDTH-1:0]          m29_axi_awaddr ;
wire [8-1:0]                             m29_axi_awlen  ;
wire [2:0]                               m29_axi_awsize ;
wire [1:0]                               m29_axi_awburst;
wire                                     m29_axi_awvalid;
wire                                     m29_axi_awready;
wire [C_M29_AXI_DATA_WIDTH-1:0]          m29_axi_wdata  ;
wire [C_M29_AXI_DATA_WIDTH/8-1:0]        m29_axi_wstrb  ;
wire                                     m29_axi_wlast  ;
wire                                     m29_axi_wvalid ;
wire                                     m29_axi_wready ;
wire                                     m29_axi_bvalid ;
wire                                     m29_axi_bready ;
wire [C_M29_AXI_ADDR_WIDTH-1:0]          m29_axi_araddr ;
wire [8-1:0]                             m29_axi_arlen  ;
wire [2:0]                               m29_axi_arsize ;
wire [1:0]                               m29_axi_arburst;
wire                                     m29_axi_arvalid;
wire                                     m29_axi_arready;
wire [C_M29_AXI_DATA_WIDTH-1:0]          m29_axi_rdata  ;
wire                                     m29_axi_rlast  ;
wire                                     m29_axi_rvalid ;
wire                                     m29_axi_rready ;

wire [C_M30_AXI_ADDR_WIDTH-1:0]          m30_axi_awaddr ;
wire [8-1:0]                             m30_axi_awlen  ;
wire [2:0]                               m30_axi_awsize ;
wire [1:0]                               m30_axi_awburst;
wire                                     m30_axi_awvalid;
wire                                     m30_axi_awready;
wire [C_M30_AXI_DATA_WIDTH-1:0]          m30_axi_wdata  ;
wire [C_M30_AXI_DATA_WIDTH/8-1:0]        m30_axi_wstrb  ;
wire                                     m30_axi_wlast  ;
wire                                     m30_axi_wvalid ;
wire                                     m30_axi_wready ;
wire                                     m30_axi_bvalid ;
wire                                     m30_axi_bready ;
wire [C_M30_AXI_ADDR_WIDTH-1:0]          m30_axi_araddr ;
wire [8-1:0]                             m30_axi_arlen  ;
wire [2:0]                               m30_axi_arsize ;
wire [1:0]                               m30_axi_arburst;
wire                                     m30_axi_arvalid;
wire                                     m30_axi_arready;
wire [C_M30_AXI_DATA_WIDTH-1:0]          m30_axi_rdata  ;
wire                                     m30_axi_rlast  ;
wire                                     m30_axi_rvalid ;
wire                                     m30_axi_rready ;

wire [C_M31_AXI_ADDR_WIDTH-1:0]          m31_axi_awaddr ;
wire [8-1:0]                             m31_axi_awlen  ;
wire [2:0]                               m31_axi_awsize ;
wire [1:0]                               m31_axi_awburst;
wire                                     m31_axi_awvalid;
wire                                     m31_axi_awready;
wire [C_M31_AXI_DATA_WIDTH-1:0]          m31_axi_wdata  ;
wire [C_M31_AXI_DATA_WIDTH/8-1:0]        m31_axi_wstrb  ;
wire                                     m31_axi_wlast  ;
wire                                     m31_axi_wvalid ;
wire                                     m31_axi_wready ;
wire                                     m31_axi_bvalid ;
wire                                     m31_axi_bready ;
wire [C_M31_AXI_ADDR_WIDTH-1:0]          m31_axi_araddr ;
wire [8-1:0]                             m31_axi_arlen  ;
wire [2:0]                               m31_axi_arsize ;
wire [1:0]                               m31_axi_arburst;
wire                                     m31_axi_arvalid;
wire                                     m31_axi_arready;
wire [C_M31_AXI_DATA_WIDTH-1:0]          m31_axi_rdata  ;
wire                                     m31_axi_rlast  ;
wire                                     m31_axi_rvalid ;
wire                                     m31_axi_rready ;



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// Instantiating testbench block design

kernel #(
    .C_S_AXI_CONTROL_ADDR_WIDTH (C_S_AXI_CONTROL_ADDR_WIDTH),
    .C_S_AXI_CONTROL_DATA_WIDTH (C_S_AXI_CONTROL_DATA_WIDTH),
    .HBM_ADDR_WIDTH             (HBM_ADDR_WIDTH),
    .HBM_DATA_WIDTH             (HBM_DATA_WIDTH),
    .LOGN                       (LOGN),
    .LOGQ                       (LOGQ),
    .LOGQH                      (LOGQH),
    .LOGTP                      (LOGTP),
    .EN_ADD                     (EN_ADD),
    .L                          (L)
) uut (
    .ap_clk                (clk           ),
    .interrupt             (interrupt     ),
    .ap_rst_n              (aresetn       ),
    .s_axi_control_araddr  (axils_araddr  ),
    .s_axi_control_arready (axils_arready ),
    .s_axi_control_arvalid (axils_arvalid ),
    .s_axi_control_awaddr  (axils_awaddr  ),
    .s_axi_control_awready (axils_awready ),
    .s_axi_control_awvalid (axils_awvalid ),
    .s_axi_control_bready  (axils_bready  ),
    .s_axi_control_bresp   (axils_bresp   ),
    .s_axi_control_bvalid  (axils_bvalid  ),
    .s_axi_control_rdata   (axils_rdata   ),
    .s_axi_control_rready  (axils_rready  ),
    .s_axi_control_rresp   (axils_rresp   ),
    .s_axi_control_rvalid  (axils_rvalid  ),
    .s_axi_control_wdata   (axils_wdata   ),
    .s_axi_control_wready  (axils_wready  ),
    .s_axi_control_wstrb   (axils_wstrb   ),
    .s_axi_control_wvalid  (axils_wvalid  ),
    //////////////////////////// axi4 connections ///////////////////////////
    .m00_axi_awaddr        (m00_axi_awaddr),
    .m00_axi_awlen         (m00_axi_awlen ),
    .m00_axi_awsize        (m00_axi_awsize),
    .m00_axi_awburst       (m00_axi_awburst),
    .m00_axi_awvalid       (m00_axi_awvalid),
    .m00_axi_awready       (m00_axi_awready),
    .m00_axi_wdata         (m00_axi_wdata ),
    .m00_axi_wstrb         (m00_axi_wstrb ),
    .m00_axi_wlast         (m00_axi_wlast ),
    .m00_axi_wvalid        (m00_axi_wvalid),
    .m00_axi_wready        (m00_axi_wready),
    .m00_axi_bvalid        (m00_axi_bvalid),
    .m00_axi_bready        (m00_axi_bready),
    .m00_axi_araddr        (m00_axi_araddr),
    .m00_axi_arlen         (m00_axi_arlen ),
    .m00_axi_arsize        (m00_axi_arsize),
    .m00_axi_arburst       (m00_axi_arburst),
    .m00_axi_arvalid       (m00_axi_arvalid),
    .m00_axi_arready       (m00_axi_arready),
    .m00_axi_rdata         (m00_axi_rdata ),
    .m00_axi_rlast         (m00_axi_rlast ),
    .m00_axi_rvalid        (m00_axi_rvalid),
    .m00_axi_rready        (m00_axi_rready),

    .m01_axi_awaddr        (m01_axi_awaddr),
    .m01_axi_awlen         (m01_axi_awlen ),
    .m01_axi_awsize        (m01_axi_awsize),
    .m01_axi_awburst       (m01_axi_awburst),
    .m01_axi_awvalid       (m01_axi_awvalid),
    .m01_axi_awready       (m01_axi_awready),
    .m01_axi_wdata         (m01_axi_wdata ),
    .m01_axi_wstrb         (m01_axi_wstrb ),
    .m01_axi_wlast         (m01_axi_wlast ),
    .m01_axi_wvalid        (m01_axi_wvalid),
    .m01_axi_wready        (m01_axi_wready),
    .m01_axi_bvalid        (m01_axi_bvalid),
    .m01_axi_bready        (m01_axi_bready),
    .m01_axi_araddr        (m01_axi_araddr),
    .m01_axi_arlen         (m01_axi_arlen ),
    .m01_axi_arsize        (m01_axi_arsize),
    .m01_axi_arburst       (m01_axi_arburst),
    .m01_axi_arvalid       (m01_axi_arvalid),
    .m01_axi_arready       (m01_axi_arready),
    .m01_axi_rdata         (m01_axi_rdata ),
    .m01_axi_rlast         (m01_axi_rlast ),
    .m01_axi_rvalid        (m01_axi_rvalid),
    .m01_axi_rready        (m01_axi_rready),

    .m02_axi_awaddr        (m02_axi_awaddr),
    .m02_axi_awlen         (m02_axi_awlen ),
    .m02_axi_awsize        (m02_axi_awsize),
    .m02_axi_awburst       (m02_axi_awburst),
    .m02_axi_awvalid       (m02_axi_awvalid),
    .m02_axi_awready       (m02_axi_awready),
    .m02_axi_wdata         (m02_axi_wdata ),
    .m02_axi_wstrb         (m02_axi_wstrb ),
    .m02_axi_wlast         (m02_axi_wlast ),
    .m02_axi_wvalid        (m02_axi_wvalid),
    .m02_axi_wready        (m02_axi_wready),
    .m02_axi_bvalid        (m02_axi_bvalid),
    .m02_axi_bready        (m02_axi_bready),
    .m02_axi_araddr        (m02_axi_araddr),
    .m02_axi_arlen         (m02_axi_arlen ),
    .m02_axi_arsize        (m02_axi_arsize),
    .m02_axi_arburst       (m02_axi_arburst),
    .m02_axi_arvalid       (m02_axi_arvalid),
    .m02_axi_arready       (m02_axi_arready),
    .m02_axi_rdata         (m02_axi_rdata ),
    .m02_axi_rlast         (m02_axi_rlast ),
    .m02_axi_rvalid        (m02_axi_rvalid),
    .m02_axi_rready        (m02_axi_rready),

    .m03_axi_awaddr        (m03_axi_awaddr),
    .m03_axi_awlen         (m03_axi_awlen ),
    .m03_axi_awsize        (m03_axi_awsize),
    .m03_axi_awburst       (m03_axi_awburst),
    .m03_axi_awvalid       (m03_axi_awvalid),
    .m03_axi_awready       (m03_axi_awready),
    .m03_axi_wdata         (m03_axi_wdata ),
    .m03_axi_wstrb         (m03_axi_wstrb ),
    .m03_axi_wlast         (m03_axi_wlast ),
    .m03_axi_wvalid        (m03_axi_wvalid),
    .m03_axi_wready        (m03_axi_wready),
    .m03_axi_bvalid        (m03_axi_bvalid),
    .m03_axi_bready        (m03_axi_bready),
    .m03_axi_araddr        (m03_axi_araddr),
    .m03_axi_arlen         (m03_axi_arlen ),
    .m03_axi_arsize        (m03_axi_arsize),
    .m03_axi_arburst       (m03_axi_arburst),
    .m03_axi_arvalid       (m03_axi_arvalid),
    .m03_axi_arready       (m03_axi_arready),
    .m03_axi_rdata         (m03_axi_rdata ),
    .m03_axi_rlast         (m03_axi_rlast ),
    .m03_axi_rvalid        (m03_axi_rvalid),
    .m03_axi_rready        (m03_axi_rready),

    .m04_axi_awaddr        (m04_axi_awaddr),
    .m04_axi_awlen         (m04_axi_awlen ),
    .m04_axi_awsize        (m04_axi_awsize),
    .m04_axi_awburst       (m04_axi_awburst),
    .m04_axi_awvalid       (m04_axi_awvalid),
    .m04_axi_awready       (m04_axi_awready),
    .m04_axi_wdata         (m04_axi_wdata ),
    .m04_axi_wstrb         (m04_axi_wstrb ),
    .m04_axi_wlast         (m04_axi_wlast ),
    .m04_axi_wvalid        (m04_axi_wvalid),
    .m04_axi_wready        (m04_axi_wready),
    .m04_axi_bvalid        (m04_axi_bvalid),
    .m04_axi_bready        (m04_axi_bready),
    .m04_axi_araddr        (m04_axi_araddr),
    .m04_axi_arlen         (m04_axi_arlen ),
    .m04_axi_arsize        (m04_axi_arsize),
    .m04_axi_arburst       (m04_axi_arburst),
    .m04_axi_arvalid       (m04_axi_arvalid),
    .m04_axi_arready       (m04_axi_arready),
    .m04_axi_rdata         (m04_axi_rdata ),
    .m04_axi_rlast         (m04_axi_rlast ),
    .m04_axi_rvalid        (m04_axi_rvalid),
    .m04_axi_rready        (m04_axi_rready),

    .m05_axi_awaddr        (m05_axi_awaddr),
    .m05_axi_awlen         (m05_axi_awlen ),
    .m05_axi_awsize        (m05_axi_awsize),
    .m05_axi_awburst       (m05_axi_awburst),
    .m05_axi_awvalid       (m05_axi_awvalid),
    .m05_axi_awready       (m05_axi_awready),
    .m05_axi_wdata         (m05_axi_wdata ),
    .m05_axi_wstrb         (m05_axi_wstrb ),
    .m05_axi_wlast         (m05_axi_wlast ),
    .m05_axi_wvalid        (m05_axi_wvalid),
    .m05_axi_wready        (m05_axi_wready),
    .m05_axi_bvalid        (m05_axi_bvalid),
    .m05_axi_bready        (m05_axi_bready),
    .m05_axi_araddr        (m05_axi_araddr),
    .m05_axi_arlen         (m05_axi_arlen ),
    .m05_axi_arsize        (m05_axi_arsize),
    .m05_axi_arburst       (m05_axi_arburst),
    .m05_axi_arvalid       (m05_axi_arvalid),
    .m05_axi_arready       (m05_axi_arready),
    .m05_axi_rdata         (m05_axi_rdata ),
    .m05_axi_rlast         (m05_axi_rlast ),
    .m05_axi_rvalid        (m05_axi_rvalid),
    .m05_axi_rready        (m05_axi_rready),

    .m06_axi_awaddr        (m06_axi_awaddr),
    .m06_axi_awlen         (m06_axi_awlen ),
    .m06_axi_awsize        (m06_axi_awsize),
    .m06_axi_awburst       (m06_axi_awburst),
    .m06_axi_awvalid       (m06_axi_awvalid),
    .m06_axi_awready       (m06_axi_awready),
    .m06_axi_wdata         (m06_axi_wdata ),
    .m06_axi_wstrb         (m06_axi_wstrb ),
    .m06_axi_wlast         (m06_axi_wlast ),
    .m06_axi_wvalid        (m06_axi_wvalid),
    .m06_axi_wready        (m06_axi_wready),
    .m06_axi_bvalid        (m06_axi_bvalid),
    .m06_axi_bready        (m06_axi_bready),
    .m06_axi_araddr        (m06_axi_araddr),
    .m06_axi_arlen         (m06_axi_arlen ),
    .m06_axi_arsize        (m06_axi_arsize),
    .m06_axi_arburst       (m06_axi_arburst),
    .m06_axi_arvalid       (m06_axi_arvalid),
    .m06_axi_arready       (m06_axi_arready),
    .m06_axi_rdata         (m06_axi_rdata ),
    .m06_axi_rlast         (m06_axi_rlast ),
    .m06_axi_rvalid        (m06_axi_rvalid),
    .m06_axi_rready        (m06_axi_rready),

    .m07_axi_awaddr        (m07_axi_awaddr),
    .m07_axi_awlen         (m07_axi_awlen ),
    .m07_axi_awsize        (m07_axi_awsize),
    .m07_axi_awburst       (m07_axi_awburst),
    .m07_axi_awvalid       (m07_axi_awvalid),
    .m07_axi_awready       (m07_axi_awready),
    .m07_axi_wdata         (m07_axi_wdata ),
    .m07_axi_wstrb         (m07_axi_wstrb ),
    .m07_axi_wlast         (m07_axi_wlast ),
    .m07_axi_wvalid        (m07_axi_wvalid),
    .m07_axi_wready        (m07_axi_wready),
    .m07_axi_bvalid        (m07_axi_bvalid),
    .m07_axi_bready        (m07_axi_bready),
    .m07_axi_araddr        (m07_axi_araddr),
    .m07_axi_arlen         (m07_axi_arlen ),
    .m07_axi_arsize        (m07_axi_arsize),
    .m07_axi_arburst       (m07_axi_arburst),
    .m07_axi_arvalid       (m07_axi_arvalid),
    .m07_axi_arready       (m07_axi_arready),
    .m07_axi_rdata         (m07_axi_rdata ),
    .m07_axi_rlast         (m07_axi_rlast ),
    .m07_axi_rvalid        (m07_axi_rvalid),
    .m07_axi_rready        (m07_axi_rready),

    .m08_axi_awaddr        (m08_axi_awaddr),
    .m08_axi_awlen         (m08_axi_awlen ),
    .m08_axi_awsize        (m08_axi_awsize),
    .m08_axi_awburst       (m08_axi_awburst),
    .m08_axi_awvalid       (m08_axi_awvalid),
    .m08_axi_awready       (m08_axi_awready),
    .m08_axi_wdata         (m08_axi_wdata ),
    .m08_axi_wstrb         (m08_axi_wstrb ),
    .m08_axi_wlast         (m08_axi_wlast ),
    .m08_axi_wvalid        (m08_axi_wvalid),
    .m08_axi_wready        (m08_axi_wready),
    .m08_axi_bvalid        (m08_axi_bvalid),
    .m08_axi_bready        (m08_axi_bready),
    .m08_axi_araddr        (m08_axi_araddr),
    .m08_axi_arlen         (m08_axi_arlen ),
    .m08_axi_arsize        (m08_axi_arsize),
    .m08_axi_arburst       (m08_axi_arburst),
    .m08_axi_arvalid       (m08_axi_arvalid),
    .m08_axi_arready       (m08_axi_arready),
    .m08_axi_rdata         (m08_axi_rdata ),
    .m08_axi_rlast         (m08_axi_rlast ),
    .m08_axi_rvalid        (m08_axi_rvalid),
    .m08_axi_rready        (m08_axi_rready),

    .m09_axi_awaddr        (m09_axi_awaddr),
    .m09_axi_awlen         (m09_axi_awlen ),
    .m09_axi_awsize        (m09_axi_awsize),
    .m09_axi_awburst       (m09_axi_awburst),
    .m09_axi_awvalid       (m09_axi_awvalid),
    .m09_axi_awready       (m09_axi_awready),
    .m09_axi_wdata         (m09_axi_wdata ),
    .m09_axi_wstrb         (m09_axi_wstrb ),
    .m09_axi_wlast         (m09_axi_wlast ),
    .m09_axi_wvalid        (m09_axi_wvalid),
    .m09_axi_wready        (m09_axi_wready),
    .m09_axi_bvalid        (m09_axi_bvalid),
    .m09_axi_bready        (m09_axi_bready),
    .m09_axi_araddr        (m09_axi_araddr),
    .m09_axi_arlen         (m09_axi_arlen ),
    .m09_axi_arsize        (m09_axi_arsize),
    .m09_axi_arburst       (m09_axi_arburst),
    .m09_axi_arvalid       (m09_axi_arvalid),
    .m09_axi_arready       (m09_axi_arready),
    .m09_axi_rdata         (m09_axi_rdata ),
    .m09_axi_rlast         (m09_axi_rlast ),
    .m09_axi_rvalid        (m09_axi_rvalid),
    .m09_axi_rready        (m09_axi_rready),

    .m10_axi_awaddr        (m10_axi_awaddr),
    .m10_axi_awlen         (m10_axi_awlen ),
    .m10_axi_awsize        (m10_axi_awsize),
    .m10_axi_awburst       (m10_axi_awburst),
    .m10_axi_awvalid       (m10_axi_awvalid),
    .m10_axi_awready       (m10_axi_awready),
    .m10_axi_wdata         (m10_axi_wdata ),
    .m10_axi_wstrb         (m10_axi_wstrb ),
    .m10_axi_wlast         (m10_axi_wlast ),
    .m10_axi_wvalid        (m10_axi_wvalid),
    .m10_axi_wready        (m10_axi_wready),
    .m10_axi_bvalid        (m10_axi_bvalid),
    .m10_axi_bready        (m10_axi_bready),
    .m10_axi_araddr        (m10_axi_araddr),
    .m10_axi_arlen         (m10_axi_arlen ),
    .m10_axi_arsize        (m10_axi_arsize),
    .m10_axi_arburst       (m10_axi_arburst),
    .m10_axi_arvalid       (m10_axi_arvalid),
    .m10_axi_arready       (m10_axi_arready),
    .m10_axi_rdata         (m10_axi_rdata ),
    .m10_axi_rlast         (m10_axi_rlast ),
    .m10_axi_rvalid        (m10_axi_rvalid),
    .m10_axi_rready        (m10_axi_rready),

    .m11_axi_awaddr        (m11_axi_awaddr),
    .m11_axi_awlen         (m11_axi_awlen ),
    .m11_axi_awsize        (m11_axi_awsize),
    .m11_axi_awburst       (m11_axi_awburst),
    .m11_axi_awvalid       (m11_axi_awvalid),
    .m11_axi_awready       (m11_axi_awready),
    .m11_axi_wdata         (m11_axi_wdata ),
    .m11_axi_wstrb         (m11_axi_wstrb ),
    .m11_axi_wlast         (m11_axi_wlast ),
    .m11_axi_wvalid        (m11_axi_wvalid),
    .m11_axi_wready        (m11_axi_wready),
    .m11_axi_bvalid        (m11_axi_bvalid),
    .m11_axi_bready        (m11_axi_bready),
    .m11_axi_araddr        (m11_axi_araddr),
    .m11_axi_arlen         (m11_axi_arlen ),
    .m11_axi_arsize        (m11_axi_arsize),
    .m11_axi_arburst       (m11_axi_arburst),
    .m11_axi_arvalid       (m11_axi_arvalid),
    .m11_axi_arready       (m11_axi_arready),
    .m11_axi_rdata         (m11_axi_rdata ),
    .m11_axi_rlast         (m11_axi_rlast ),
    .m11_axi_rvalid        (m11_axi_rvalid),
    .m11_axi_rready        (m11_axi_rready),

    .m12_axi_awaddr        (m12_axi_awaddr),
    .m12_axi_awlen         (m12_axi_awlen ),
    .m12_axi_awsize        (m12_axi_awsize),
    .m12_axi_awburst       (m12_axi_awburst),
    .m12_axi_awvalid       (m12_axi_awvalid),
    .m12_axi_awready       (m12_axi_awready),
    .m12_axi_wdata         (m12_axi_wdata ),
    .m12_axi_wstrb         (m12_axi_wstrb ),
    .m12_axi_wlast         (m12_axi_wlast ),
    .m12_axi_wvalid        (m12_axi_wvalid),
    .m12_axi_wready        (m12_axi_wready),
    .m12_axi_bvalid        (m12_axi_bvalid),
    .m12_axi_bready        (m12_axi_bready),
    .m12_axi_araddr        (m12_axi_araddr),
    .m12_axi_arlen         (m12_axi_arlen ),
    .m12_axi_arsize        (m12_axi_arsize),
    .m12_axi_arburst       (m12_axi_arburst),
    .m12_axi_arvalid       (m12_axi_arvalid),
    .m12_axi_arready       (m12_axi_arready),
    .m12_axi_rdata         (m12_axi_rdata ),
    .m12_axi_rlast         (m12_axi_rlast ),
    .m12_axi_rvalid        (m12_axi_rvalid),
    .m12_axi_rready        (m12_axi_rready),

    .m13_axi_awaddr        (m13_axi_awaddr),
    .m13_axi_awlen         (m13_axi_awlen ),
    .m13_axi_awsize        (m13_axi_awsize),
    .m13_axi_awburst       (m13_axi_awburst),
    .m13_axi_awvalid       (m13_axi_awvalid),
    .m13_axi_awready       (m13_axi_awready),
    .m13_axi_wdata         (m13_axi_wdata ),
    .m13_axi_wstrb         (m13_axi_wstrb ),
    .m13_axi_wlast         (m13_axi_wlast ),
    .m13_axi_wvalid        (m13_axi_wvalid),
    .m13_axi_wready        (m13_axi_wready),
    .m13_axi_bvalid        (m13_axi_bvalid),
    .m13_axi_bready        (m13_axi_bready),
    .m13_axi_araddr        (m13_axi_araddr),
    .m13_axi_arlen         (m13_axi_arlen ),
    .m13_axi_arsize        (m13_axi_arsize),
    .m13_axi_arburst       (m13_axi_arburst),
    .m13_axi_arvalid       (m13_axi_arvalid),
    .m13_axi_arready       (m13_axi_arready),
    .m13_axi_rdata         (m13_axi_rdata ),
    .m13_axi_rlast         (m13_axi_rlast ),
    .m13_axi_rvalid        (m13_axi_rvalid),
    .m13_axi_rready        (m13_axi_rready),

    .m14_axi_awaddr        (m14_axi_awaddr),
    .m14_axi_awlen         (m14_axi_awlen ),
    .m14_axi_awsize        (m14_axi_awsize),
    .m14_axi_awburst       (m14_axi_awburst),
    .m14_axi_awvalid       (m14_axi_awvalid),
    .m14_axi_awready       (m14_axi_awready),
    .m14_axi_wdata         (m14_axi_wdata ),
    .m14_axi_wstrb         (m14_axi_wstrb ),
    .m14_axi_wlast         (m14_axi_wlast ),
    .m14_axi_wvalid        (m14_axi_wvalid),
    .m14_axi_wready        (m14_axi_wready),
    .m14_axi_bvalid        (m14_axi_bvalid),
    .m14_axi_bready        (m14_axi_bready),
    .m14_axi_araddr        (m14_axi_araddr),
    .m14_axi_arlen         (m14_axi_arlen ),
    .m14_axi_arsize        (m14_axi_arsize),
    .m14_axi_arburst       (m14_axi_arburst),
    .m14_axi_arvalid       (m14_axi_arvalid),
    .m14_axi_arready       (m14_axi_arready),
    .m14_axi_rdata         (m14_axi_rdata ),
    .m14_axi_rlast         (m14_axi_rlast ),
    .m14_axi_rvalid        (m14_axi_rvalid),
    .m14_axi_rready        (m14_axi_rready),

    .m15_axi_awaddr        (m15_axi_awaddr),
    .m15_axi_awlen         (m15_axi_awlen ),
    .m15_axi_awsize        (m15_axi_awsize),
    .m15_axi_awburst       (m15_axi_awburst),
    .m15_axi_awvalid       (m15_axi_awvalid),
    .m15_axi_awready       (m15_axi_awready),
    .m15_axi_wdata         (m15_axi_wdata ),
    .m15_axi_wstrb         (m15_axi_wstrb ),
    .m15_axi_wlast         (m15_axi_wlast ),
    .m15_axi_wvalid        (m15_axi_wvalid),
    .m15_axi_wready        (m15_axi_wready),
    .m15_axi_bvalid        (m15_axi_bvalid),
    .m15_axi_bready        (m15_axi_bready),
    .m15_axi_araddr        (m15_axi_araddr),
    .m15_axi_arlen         (m15_axi_arlen ),
    .m15_axi_arsize        (m15_axi_arsize),
    .m15_axi_arburst       (m15_axi_arburst),
    .m15_axi_arvalid       (m15_axi_arvalid),
    .m15_axi_arready       (m15_axi_arready),
    .m15_axi_rdata         (m15_axi_rdata ),
    .m15_axi_rlast         (m15_axi_rlast ),
    .m15_axi_rvalid        (m15_axi_rvalid),
    .m15_axi_rready        (m15_axi_rready),

    .m16_axi_awaddr        (m16_axi_awaddr),
    .m16_axi_awlen         (m16_axi_awlen ),
    .m16_axi_awsize        (m16_axi_awsize),
    .m16_axi_awburst       (m16_axi_awburst),
    .m16_axi_awvalid       (m16_axi_awvalid),
    .m16_axi_awready       (m16_axi_awready),
    .m16_axi_wdata         (m16_axi_wdata ),
    .m16_axi_wstrb         (m16_axi_wstrb ),
    .m16_axi_wlast         (m16_axi_wlast ),
    .m16_axi_wvalid        (m16_axi_wvalid),
    .m16_axi_wready        (m16_axi_wready),
    .m16_axi_bvalid        (m16_axi_bvalid),
    .m16_axi_bready        (m16_axi_bready),
    .m16_axi_araddr        (m16_axi_araddr),
    .m16_axi_arlen         (m16_axi_arlen ),
    .m16_axi_arsize        (m16_axi_arsize),
    .m16_axi_arburst       (m16_axi_arburst),
    .m16_axi_arvalid       (m16_axi_arvalid),
    .m16_axi_arready       (m16_axi_arready),
    .m16_axi_rdata         (m16_axi_rdata ),
    .m16_axi_rlast         (m16_axi_rlast ),
    .m16_axi_rvalid        (m16_axi_rvalid),
    .m16_axi_rready        (m16_axi_rready),

    .m17_axi_awaddr        (m17_axi_awaddr),
    .m17_axi_awlen         (m17_axi_awlen ),
    .m17_axi_awsize        (m17_axi_awsize),
    .m17_axi_awburst       (m17_axi_awburst),
    .m17_axi_awvalid       (m17_axi_awvalid),
    .m17_axi_awready       (m17_axi_awready),
    .m17_axi_wdata         (m17_axi_wdata ),
    .m17_axi_wstrb         (m17_axi_wstrb ),
    .m17_axi_wlast         (m17_axi_wlast ),
    .m17_axi_wvalid        (m17_axi_wvalid),
    .m17_axi_wready        (m17_axi_wready),
    .m17_axi_bvalid        (m17_axi_bvalid),
    .m17_axi_bready        (m17_axi_bready),
    .m17_axi_araddr        (m17_axi_araddr),
    .m17_axi_arlen         (m17_axi_arlen ),
    .m17_axi_arsize        (m17_axi_arsize),
    .m17_axi_arburst       (m17_axi_arburst),
    .m17_axi_arvalid       (m17_axi_arvalid),
    .m17_axi_arready       (m17_axi_arready),
    .m17_axi_rdata         (m17_axi_rdata ),
    .m17_axi_rlast         (m17_axi_rlast ),
    .m17_axi_rvalid        (m17_axi_rvalid),
    .m17_axi_rready        (m17_axi_rready),

    .m18_axi_awaddr        (m18_axi_awaddr),
    .m18_axi_awlen         (m18_axi_awlen ),
    .m18_axi_awsize        (m18_axi_awsize),
    .m18_axi_awburst       (m18_axi_awburst),
    .m18_axi_awvalid       (m18_axi_awvalid),
    .m18_axi_awready       (m18_axi_awready),
    .m18_axi_wdata         (m18_axi_wdata ),
    .m18_axi_wstrb         (m18_axi_wstrb ),
    .m18_axi_wlast         (m18_axi_wlast ),
    .m18_axi_wvalid        (m18_axi_wvalid),
    .m18_axi_wready        (m18_axi_wready),
    .m18_axi_bvalid        (m18_axi_bvalid),
    .m18_axi_bready        (m18_axi_bready),
    .m18_axi_araddr        (m18_axi_araddr),
    .m18_axi_arlen         (m18_axi_arlen ),
    .m18_axi_arsize        (m18_axi_arsize),
    .m18_axi_arburst       (m18_axi_arburst),
    .m18_axi_arvalid       (m18_axi_arvalid),
    .m18_axi_arready       (m18_axi_arready),
    .m18_axi_rdata         (m18_axi_rdata ),
    .m18_axi_rlast         (m18_axi_rlast ),
    .m18_axi_rvalid        (m18_axi_rvalid),
    .m18_axi_rready        (m18_axi_rready),

    .m19_axi_awaddr        (m19_axi_awaddr),
    .m19_axi_awlen         (m19_axi_awlen ),
    .m19_axi_awsize        (m19_axi_awsize),
    .m19_axi_awburst       (m19_axi_awburst),
    .m19_axi_awvalid       (m19_axi_awvalid),
    .m19_axi_awready       (m19_axi_awready),
    .m19_axi_wdata         (m19_axi_wdata ),
    .m19_axi_wstrb         (m19_axi_wstrb ),
    .m19_axi_wlast         (m19_axi_wlast ),
    .m19_axi_wvalid        (m19_axi_wvalid),
    .m19_axi_wready        (m19_axi_wready),
    .m19_axi_bvalid        (m19_axi_bvalid),
    .m19_axi_bready        (m19_axi_bready),
    .m19_axi_araddr        (m19_axi_araddr),
    .m19_axi_arlen         (m19_axi_arlen ),
    .m19_axi_arsize        (m19_axi_arsize),
    .m19_axi_arburst       (m19_axi_arburst),
    .m19_axi_arvalid       (m19_axi_arvalid),
    .m19_axi_arready       (m19_axi_arready),
    .m19_axi_rdata         (m19_axi_rdata ),
    .m19_axi_rlast         (m19_axi_rlast ),
    .m19_axi_rvalid        (m19_axi_rvalid),
    .m19_axi_rready        (m19_axi_rready),

    .m20_axi_awaddr        (m20_axi_awaddr),
    .m20_axi_awlen         (m20_axi_awlen ),
    .m20_axi_awsize        (m20_axi_awsize),
    .m20_axi_awburst       (m20_axi_awburst),
    .m20_axi_awvalid       (m20_axi_awvalid),
    .m20_axi_awready       (m20_axi_awready),
    .m20_axi_wdata         (m20_axi_wdata ),
    .m20_axi_wstrb         (m20_axi_wstrb ),
    .m20_axi_wlast         (m20_axi_wlast ),
    .m20_axi_wvalid        (m20_axi_wvalid),
    .m20_axi_wready        (m20_axi_wready),
    .m20_axi_bvalid        (m20_axi_bvalid),
    .m20_axi_bready        (m20_axi_bready),
    .m20_axi_araddr        (m20_axi_araddr),
    .m20_axi_arlen         (m20_axi_arlen ),
    .m20_axi_arsize        (m20_axi_arsize),
    .m20_axi_arburst       (m20_axi_arburst),
    .m20_axi_arvalid       (m20_axi_arvalid),
    .m20_axi_arready       (m20_axi_arready),
    .m20_axi_rdata         (m20_axi_rdata ),
    .m20_axi_rlast         (m20_axi_rlast ),
    .m20_axi_rvalid        (m20_axi_rvalid),
    .m20_axi_rready        (m20_axi_rready),

    .m21_axi_awaddr        (m21_axi_awaddr),
    .m21_axi_awlen         (m21_axi_awlen ),
    .m21_axi_awsize        (m21_axi_awsize),
    .m21_axi_awburst       (m21_axi_awburst),
    .m21_axi_awvalid       (m21_axi_awvalid),
    .m21_axi_awready       (m21_axi_awready),
    .m21_axi_wdata         (m21_axi_wdata ),
    .m21_axi_wstrb         (m21_axi_wstrb ),
    .m21_axi_wlast         (m21_axi_wlast ),
    .m21_axi_wvalid        (m21_axi_wvalid),
    .m21_axi_wready        (m21_axi_wready),
    .m21_axi_bvalid        (m21_axi_bvalid),
    .m21_axi_bready        (m21_axi_bready),
    .m21_axi_araddr        (m21_axi_araddr),
    .m21_axi_arlen         (m21_axi_arlen ),
    .m21_axi_arsize        (m21_axi_arsize),
    .m21_axi_arburst       (m21_axi_arburst),
    .m21_axi_arvalid       (m21_axi_arvalid),
    .m21_axi_arready       (m21_axi_arready),
    .m21_axi_rdata         (m21_axi_rdata ),
    .m21_axi_rlast         (m21_axi_rlast ),
    .m21_axi_rvalid        (m21_axi_rvalid),
    .m21_axi_rready        (m21_axi_rready),

    .m22_axi_awaddr        (m22_axi_awaddr),
    .m22_axi_awlen         (m22_axi_awlen ),
    .m22_axi_awsize        (m22_axi_awsize),
    .m22_axi_awburst       (m22_axi_awburst),
    .m22_axi_awvalid       (m22_axi_awvalid),
    .m22_axi_awready       (m22_axi_awready),
    .m22_axi_wdata         (m22_axi_wdata ),
    .m22_axi_wstrb         (m22_axi_wstrb ),
    .m22_axi_wlast         (m22_axi_wlast ),
    .m22_axi_wvalid        (m22_axi_wvalid),
    .m22_axi_wready        (m22_axi_wready),
    .m22_axi_bvalid        (m22_axi_bvalid),
    .m22_axi_bready        (m22_axi_bready),
    .m22_axi_araddr        (m22_axi_araddr),
    .m22_axi_arlen         (m22_axi_arlen ),
    .m22_axi_arsize        (m22_axi_arsize),
    .m22_axi_arburst       (m22_axi_arburst),
    .m22_axi_arvalid       (m22_axi_arvalid),
    .m22_axi_arready       (m22_axi_arready),
    .m22_axi_rdata         (m22_axi_rdata ),
    .m22_axi_rlast         (m22_axi_rlast ),
    .m22_axi_rvalid        (m22_axi_rvalid),
    .m22_axi_rready        (m22_axi_rready),

    .m23_axi_awaddr        (m23_axi_awaddr),
    .m23_axi_awlen         (m23_axi_awlen ),
    .m23_axi_awsize        (m23_axi_awsize),
    .m23_axi_awburst       (m23_axi_awburst),
    .m23_axi_awvalid       (m23_axi_awvalid),
    .m23_axi_awready       (m23_axi_awready),
    .m23_axi_wdata         (m23_axi_wdata ),
    .m23_axi_wstrb         (m23_axi_wstrb ),
    .m23_axi_wlast         (m23_axi_wlast ),
    .m23_axi_wvalid        (m23_axi_wvalid),
    .m23_axi_wready        (m23_axi_wready),
    .m23_axi_bvalid        (m23_axi_bvalid),
    .m23_axi_bready        (m23_axi_bready),
    .m23_axi_araddr        (m23_axi_araddr),
    .m23_axi_arlen         (m23_axi_arlen ),
    .m23_axi_arsize        (m23_axi_arsize),
    .m23_axi_arburst       (m23_axi_arburst),
    .m23_axi_arvalid       (m23_axi_arvalid),
    .m23_axi_arready       (m23_axi_arready),
    .m23_axi_rdata         (m23_axi_rdata ),
    .m23_axi_rlast         (m23_axi_rlast ),
    .m23_axi_rvalid        (m23_axi_rvalid),
    .m23_axi_rready        (m23_axi_rready),

    .m24_axi_awaddr        (m24_axi_awaddr),
    .m24_axi_awlen         (m24_axi_awlen ),
    .m24_axi_awsize        (m24_axi_awsize),
    .m24_axi_awburst       (m24_axi_awburst),
    .m24_axi_awvalid       (m24_axi_awvalid),
    .m24_axi_awready       (m24_axi_awready),
    .m24_axi_wdata         (m24_axi_wdata ),
    .m24_axi_wstrb         (m24_axi_wstrb ),
    .m24_axi_wlast         (m24_axi_wlast ),
    .m24_axi_wvalid        (m24_axi_wvalid),
    .m24_axi_wready        (m24_axi_wready),
    .m24_axi_bvalid        (m24_axi_bvalid),
    .m24_axi_bready        (m24_axi_bready),
    .m24_axi_araddr        (m24_axi_araddr),
    .m24_axi_arlen         (m24_axi_arlen ),
    .m24_axi_arsize        (m24_axi_arsize),
    .m24_axi_arburst       (m24_axi_arburst),
    .m24_axi_arvalid       (m24_axi_arvalid),
    .m24_axi_arready       (m24_axi_arready),
    .m24_axi_rdata         (m24_axi_rdata ),
    .m24_axi_rlast         (m24_axi_rlast ),
    .m24_axi_rvalid        (m24_axi_rvalid),
    .m24_axi_rready        (m24_axi_rready),

    .m25_axi_awaddr        (m25_axi_awaddr),
    .m25_axi_awlen         (m25_axi_awlen ),
    .m25_axi_awsize        (m25_axi_awsize),
    .m25_axi_awburst       (m25_axi_awburst),
    .m25_axi_awvalid       (m25_axi_awvalid),
    .m25_axi_awready       (m25_axi_awready),
    .m25_axi_wdata         (m25_axi_wdata ),
    .m25_axi_wstrb         (m25_axi_wstrb ),
    .m25_axi_wlast         (m25_axi_wlast ),
    .m25_axi_wvalid        (m25_axi_wvalid),
    .m25_axi_wready        (m25_axi_wready),
    .m25_axi_bvalid        (m25_axi_bvalid),
    .m25_axi_bready        (m25_axi_bready),
    .m25_axi_araddr        (m25_axi_araddr),
    .m25_axi_arlen         (m25_axi_arlen ),
    .m25_axi_arsize        (m25_axi_arsize),
    .m25_axi_arburst       (m25_axi_arburst),
    .m25_axi_arvalid       (m25_axi_arvalid),
    .m25_axi_arready       (m25_axi_arready),
    .m25_axi_rdata         (m25_axi_rdata ),
    .m25_axi_rlast         (m25_axi_rlast ),
    .m25_axi_rvalid        (m25_axi_rvalid),
    .m25_axi_rready        (m25_axi_rready),

    .m26_axi_awaddr        (m26_axi_awaddr),
    .m26_axi_awlen         (m26_axi_awlen ),
    .m26_axi_awsize        (m26_axi_awsize),
    .m26_axi_awburst       (m26_axi_awburst),
    .m26_axi_awvalid       (m26_axi_awvalid),
    .m26_axi_awready       (m26_axi_awready),
    .m26_axi_wdata         (m26_axi_wdata ),
    .m26_axi_wstrb         (m26_axi_wstrb ),
    .m26_axi_wlast         (m26_axi_wlast ),
    .m26_axi_wvalid        (m26_axi_wvalid),
    .m26_axi_wready        (m26_axi_wready),
    .m26_axi_bvalid        (m26_axi_bvalid),
    .m26_axi_bready        (m26_axi_bready),
    .m26_axi_araddr        (m26_axi_araddr),
    .m26_axi_arlen         (m26_axi_arlen ),
    .m26_axi_arsize        (m26_axi_arsize),
    .m26_axi_arburst       (m26_axi_arburst),
    .m26_axi_arvalid       (m26_axi_arvalid),
    .m26_axi_arready       (m26_axi_arready),
    .m26_axi_rdata         (m26_axi_rdata ),
    .m26_axi_rlast         (m26_axi_rlast ),
    .m26_axi_rvalid        (m26_axi_rvalid),
    .m26_axi_rready        (m26_axi_rready),

    .m27_axi_awaddr        (m27_axi_awaddr),
    .m27_axi_awlen         (m27_axi_awlen ),
    .m27_axi_awsize        (m27_axi_awsize),
    .m27_axi_awburst       (m27_axi_awburst),
    .m27_axi_awvalid       (m27_axi_awvalid),
    .m27_axi_awready       (m27_axi_awready),
    .m27_axi_wdata         (m27_axi_wdata ),
    .m27_axi_wstrb         (m27_axi_wstrb ),
    .m27_axi_wlast         (m27_axi_wlast ),
    .m27_axi_wvalid        (m27_axi_wvalid),
    .m27_axi_wready        (m27_axi_wready),
    .m27_axi_bvalid        (m27_axi_bvalid),
    .m27_axi_bready        (m27_axi_bready),
    .m27_axi_araddr        (m27_axi_araddr),
    .m27_axi_arlen         (m27_axi_arlen ),
    .m27_axi_arsize        (m27_axi_arsize),
    .m27_axi_arburst       (m27_axi_arburst),
    .m27_axi_arvalid       (m27_axi_arvalid),
    .m27_axi_arready       (m27_axi_arready),
    .m27_axi_rdata         (m27_axi_rdata ),
    .m27_axi_rlast         (m27_axi_rlast ),
    .m27_axi_rvalid        (m27_axi_rvalid),
    .m27_axi_rready        (m27_axi_rready),

    .m28_axi_awaddr        (m28_axi_awaddr),
    .m28_axi_awlen         (m28_axi_awlen ),
    .m28_axi_awsize        (m28_axi_awsize),
    .m28_axi_awburst       (m28_axi_awburst),
    .m28_axi_awvalid       (m28_axi_awvalid),
    .m28_axi_awready       (m28_axi_awready),
    .m28_axi_wdata         (m28_axi_wdata ),
    .m28_axi_wstrb         (m28_axi_wstrb ),
    .m28_axi_wlast         (m28_axi_wlast ),
    .m28_axi_wvalid        (m28_axi_wvalid),
    .m28_axi_wready        (m28_axi_wready),
    .m28_axi_bvalid        (m28_axi_bvalid),
    .m28_axi_bready        (m28_axi_bready),
    .m28_axi_araddr        (m28_axi_araddr),
    .m28_axi_arlen         (m28_axi_arlen ),
    .m28_axi_arsize        (m28_axi_arsize),
    .m28_axi_arburst       (m28_axi_arburst),
    .m28_axi_arvalid       (m28_axi_arvalid),
    .m28_axi_arready       (m28_axi_arready),
    .m28_axi_rdata         (m28_axi_rdata ),
    .m28_axi_rlast         (m28_axi_rlast ),
    .m28_axi_rvalid        (m28_axi_rvalid),
    .m28_axi_rready        (m28_axi_rready),

    .m29_axi_awaddr        (m29_axi_awaddr),
    .m29_axi_awlen         (m29_axi_awlen ),
    .m29_axi_awsize        (m29_axi_awsize),
    .m29_axi_awburst       (m29_axi_awburst),
    .m29_axi_awvalid       (m29_axi_awvalid),
    .m29_axi_awready       (m29_axi_awready),
    .m29_axi_wdata         (m29_axi_wdata ),
    .m29_axi_wstrb         (m29_axi_wstrb ),
    .m29_axi_wlast         (m29_axi_wlast ),
    .m29_axi_wvalid        (m29_axi_wvalid),
    .m29_axi_wready        (m29_axi_wready),
    .m29_axi_bvalid        (m29_axi_bvalid),
    .m29_axi_bready        (m29_axi_bready),
    .m29_axi_araddr        (m29_axi_araddr),
    .m29_axi_arlen         (m29_axi_arlen ),
    .m29_axi_arsize        (m29_axi_arsize),
    .m29_axi_arburst       (m29_axi_arburst),
    .m29_axi_arvalid       (m29_axi_arvalid),
    .m29_axi_arready       (m29_axi_arready),
    .m29_axi_rdata         (m29_axi_rdata ),
    .m29_axi_rlast         (m29_axi_rlast ),
    .m29_axi_rvalid        (m29_axi_rvalid),
    .m29_axi_rready        (m29_axi_rready),

    .m30_axi_awaddr        (m30_axi_awaddr),
    .m30_axi_awlen         (m30_axi_awlen ),
    .m30_axi_awsize        (m30_axi_awsize),
    .m30_axi_awburst       (m30_axi_awburst),
    .m30_axi_awvalid       (m30_axi_awvalid),
    .m30_axi_awready       (m30_axi_awready),
    .m30_axi_wdata         (m30_axi_wdata ),
    .m30_axi_wstrb         (m30_axi_wstrb ),
    .m30_axi_wlast         (m30_axi_wlast ),
    .m30_axi_wvalid        (m30_axi_wvalid),
    .m30_axi_wready        (m30_axi_wready),
    .m30_axi_bvalid        (m30_axi_bvalid),
    .m30_axi_bready        (m30_axi_bready),
    .m30_axi_araddr        (m30_axi_araddr),
    .m30_axi_arlen         (m30_axi_arlen ),
    .m30_axi_arsize        (m30_axi_arsize),
    .m30_axi_arburst       (m30_axi_arburst),
    .m30_axi_arvalid       (m30_axi_arvalid),
    .m30_axi_arready       (m30_axi_arready),
    .m30_axi_rdata         (m30_axi_rdata ),
    .m30_axi_rlast         (m30_axi_rlast ),
    .m30_axi_rvalid        (m30_axi_rvalid),
    .m30_axi_rready        (m30_axi_rready),

    .m31_axi_awaddr        (m31_axi_awaddr),
    .m31_axi_awlen         (m31_axi_awlen ),
    .m31_axi_awsize        (m31_axi_awsize),
    .m31_axi_awburst       (m31_axi_awburst),
    .m31_axi_awvalid       (m31_axi_awvalid),
    .m31_axi_awready       (m31_axi_awready),
    .m31_axi_wdata         (m31_axi_wdata ),
    .m31_axi_wstrb         (m31_axi_wstrb ),
    .m31_axi_wlast         (m31_axi_wlast ),
    .m31_axi_wvalid        (m31_axi_wvalid),
    .m31_axi_wready        (m31_axi_wready),
    .m31_axi_bvalid        (m31_axi_bvalid),
    .m31_axi_bready        (m31_axi_bready),
    .m31_axi_araddr        (m31_axi_araddr),
    .m31_axi_arlen         (m31_axi_arlen ),
    .m31_axi_arsize        (m31_axi_arsize),
    .m31_axi_arburst       (m31_axi_arburst),
    .m31_axi_arvalid       (m31_axi_arvalid),
    .m31_axi_arready       (m31_axi_arready),
    .m31_axi_rdata         (m31_axi_rdata ),
    .m31_axi_rlast         (m31_axi_rlast ),
    .m31_axi_rvalid        (m31_axi_rvalid),
    .m31_axi_rready        (m31_axi_rready)

);

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////// AXI HBM Instantiation //////////////////////////////////////////////////////////////////////



axi_hbm #(
    .HBM_ADDR_WIDTH             (HBM_ADDR_WIDTH),
    .HBM_DATA_WIDTH             (HBM_DATA_WIDTH),
    .L                          (L),
    .LOGN                       (LOGN),
    .MEM_FILE_WIDTH_USR         (MEM_FILE_WIDTH_USR)
) hbm_inst (
    .clk                   (clk           ),
    .rst                   (~aresetn      ),
    .done                  (done          ),
    //////////////////////////// axi4 connections ///////////////////////////
    .m00_axi_awaddr        (m00_axi_awaddr),
    .m00_axi_awlen         (m00_axi_awlen ),
    .m00_axi_awsize        (m00_axi_awsize),
    .m00_axi_awburst       (m00_axi_awburst),
    .m00_axi_awvalid       (m00_axi_awvalid),
    .m00_axi_awready       (m00_axi_awready),
    .m00_axi_wdata         (m00_axi_wdata ),
    .m00_axi_wstrb         (m00_axi_wstrb ),
    .m00_axi_wlast         (m00_axi_wlast ),
    .m00_axi_wvalid        (m00_axi_wvalid),
    .m00_axi_wready        (m00_axi_wready),
    .m00_axi_bvalid        (m00_axi_bvalid),
    .m00_axi_bready        (m00_axi_bready),
    .m00_axi_araddr        (m00_axi_araddr),
    .m00_axi_arlen         (m00_axi_arlen ),
    .m00_axi_arsize        (m00_axi_arsize),
    .m00_axi_arburst       (m00_axi_arburst),
    .m00_axi_arvalid       (m00_axi_arvalid),
    .m00_axi_arready       (m00_axi_arready),
    .m00_axi_rdata         (m00_axi_rdata ),
    .m00_axi_rlast         (m00_axi_rlast ),
    .m00_axi_rvalid        (m00_axi_rvalid),
    .m00_axi_rready        (m00_axi_rready),

    .m01_axi_awaddr        (m01_axi_awaddr),
    .m01_axi_awlen         (m01_axi_awlen ),
    .m01_axi_awsize        (m01_axi_awsize),
    .m01_axi_awburst       (m01_axi_awburst),
    .m01_axi_awvalid       (m01_axi_awvalid),
    .m01_axi_awready       (m01_axi_awready),
    .m01_axi_wdata         (m01_axi_wdata ),
    .m01_axi_wstrb         (m01_axi_wstrb ),
    .m01_axi_wlast         (m01_axi_wlast ),
    .m01_axi_wvalid        (m01_axi_wvalid),
    .m01_axi_wready        (m01_axi_wready),
    .m01_axi_bvalid        (m01_axi_bvalid),
    .m01_axi_bready        (m01_axi_bready),
    .m01_axi_araddr        (m01_axi_araddr),
    .m01_axi_arlen         (m01_axi_arlen ),
    .m01_axi_arsize        (m01_axi_arsize),
    .m01_axi_arburst       (m01_axi_arburst),
    .m01_axi_arvalid       (m01_axi_arvalid),
    .m01_axi_arready       (m01_axi_arready),
    .m01_axi_rdata         (m01_axi_rdata ),
    .m01_axi_rlast         (m01_axi_rlast ),
    .m01_axi_rvalid        (m01_axi_rvalid),
    .m01_axi_rready        (m01_axi_rready),

    .m02_axi_awaddr        (m02_axi_awaddr),
    .m02_axi_awlen         (m02_axi_awlen ),
    .m02_axi_awsize        (m02_axi_awsize),
    .m02_axi_awburst       (m02_axi_awburst),
    .m02_axi_awvalid       (m02_axi_awvalid),
    .m02_axi_awready       (m02_axi_awready),
    .m02_axi_wdata         (m02_axi_wdata ),
    .m02_axi_wstrb         (m02_axi_wstrb ),
    .m02_axi_wlast         (m02_axi_wlast ),
    .m02_axi_wvalid        (m02_axi_wvalid),
    .m02_axi_wready        (m02_axi_wready),
    .m02_axi_bvalid        (m02_axi_bvalid),
    .m02_axi_bready        (m02_axi_bready),
    .m02_axi_araddr        (m02_axi_araddr),
    .m02_axi_arlen         (m02_axi_arlen ),
    .m02_axi_arsize        (m02_axi_arsize),
    .m02_axi_arburst       (m02_axi_arburst),
    .m02_axi_arvalid       (m02_axi_arvalid),
    .m02_axi_arready       (m02_axi_arready),
    .m02_axi_rdata         (m02_axi_rdata ),
    .m02_axi_rlast         (m02_axi_rlast ),
    .m02_axi_rvalid        (m02_axi_rvalid),
    .m02_axi_rready        (m02_axi_rready),

    .m03_axi_awaddr        (m03_axi_awaddr),
    .m03_axi_awlen         (m03_axi_awlen ),
    .m03_axi_awsize        (m03_axi_awsize),
    .m03_axi_awburst       (m03_axi_awburst),
    .m03_axi_awvalid       (m03_axi_awvalid),
    .m03_axi_awready       (m03_axi_awready),
    .m03_axi_wdata         (m03_axi_wdata ),
    .m03_axi_wstrb         (m03_axi_wstrb ),
    .m03_axi_wlast         (m03_axi_wlast ),
    .m03_axi_wvalid        (m03_axi_wvalid),
    .m03_axi_wready        (m03_axi_wready),
    .m03_axi_bvalid        (m03_axi_bvalid),
    .m03_axi_bready        (m03_axi_bready),
    .m03_axi_araddr        (m03_axi_araddr),
    .m03_axi_arlen         (m03_axi_arlen ),
    .m03_axi_arsize        (m03_axi_arsize),
    .m03_axi_arburst       (m03_axi_arburst),
    .m03_axi_arvalid       (m03_axi_arvalid),
    .m03_axi_arready       (m03_axi_arready),
    .m03_axi_rdata         (m03_axi_rdata ),
    .m03_axi_rlast         (m03_axi_rlast ),
    .m03_axi_rvalid        (m03_axi_rvalid),
    .m03_axi_rready        (m03_axi_rready),

    .m04_axi_awaddr        (m04_axi_awaddr),
    .m04_axi_awlen         (m04_axi_awlen ),
    .m04_axi_awsize        (m04_axi_awsize),
    .m04_axi_awburst       (m04_axi_awburst),
    .m04_axi_awvalid       (m04_axi_awvalid),
    .m04_axi_awready       (m04_axi_awready),
    .m04_axi_wdata         (m04_axi_wdata ),
    .m04_axi_wstrb         (m04_axi_wstrb ),
    .m04_axi_wlast         (m04_axi_wlast ),
    .m04_axi_wvalid        (m04_axi_wvalid),
    .m04_axi_wready        (m04_axi_wready),
    .m04_axi_bvalid        (m04_axi_bvalid),
    .m04_axi_bready        (m04_axi_bready),
    .m04_axi_araddr        (m04_axi_araddr),
    .m04_axi_arlen         (m04_axi_arlen ),
    .m04_axi_arsize        (m04_axi_arsize),
    .m04_axi_arburst       (m04_axi_arburst),
    .m04_axi_arvalid       (m04_axi_arvalid),
    .m04_axi_arready       (m04_axi_arready),
    .m04_axi_rdata         (m04_axi_rdata ),
    .m04_axi_rlast         (m04_axi_rlast ),
    .m04_axi_rvalid        (m04_axi_rvalid),
    .m04_axi_rready        (m04_axi_rready),

    .m05_axi_awaddr        (m05_axi_awaddr),
    .m05_axi_awlen         (m05_axi_awlen ),
    .m05_axi_awsize        (m05_axi_awsize),
    .m05_axi_awburst       (m05_axi_awburst),
    .m05_axi_awvalid       (m05_axi_awvalid),
    .m05_axi_awready       (m05_axi_awready),
    .m05_axi_wdata         (m05_axi_wdata ),
    .m05_axi_wstrb         (m05_axi_wstrb ),
    .m05_axi_wlast         (m05_axi_wlast ),
    .m05_axi_wvalid        (m05_axi_wvalid),
    .m05_axi_wready        (m05_axi_wready),
    .m05_axi_bvalid        (m05_axi_bvalid),
    .m05_axi_bready        (m05_axi_bready),
    .m05_axi_araddr        (m05_axi_araddr),
    .m05_axi_arlen         (m05_axi_arlen ),
    .m05_axi_arsize        (m05_axi_arsize),
    .m05_axi_arburst       (m05_axi_arburst),
    .m05_axi_arvalid       (m05_axi_arvalid),
    .m05_axi_arready       (m05_axi_arready),
    .m05_axi_rdata         (m05_axi_rdata ),
    .m05_axi_rlast         (m05_axi_rlast ),
    .m05_axi_rvalid        (m05_axi_rvalid),
    .m05_axi_rready        (m05_axi_rready),

    .m06_axi_awaddr        (m06_axi_awaddr),
    .m06_axi_awlen         (m06_axi_awlen ),
    .m06_axi_awsize        (m06_axi_awsize),
    .m06_axi_awburst       (m06_axi_awburst),
    .m06_axi_awvalid       (m06_axi_awvalid),
    .m06_axi_awready       (m06_axi_awready),
    .m06_axi_wdata         (m06_axi_wdata ),
    .m06_axi_wstrb         (m06_axi_wstrb ),
    .m06_axi_wlast         (m06_axi_wlast ),
    .m06_axi_wvalid        (m06_axi_wvalid),
    .m06_axi_wready        (m06_axi_wready),
    .m06_axi_bvalid        (m06_axi_bvalid),
    .m06_axi_bready        (m06_axi_bready),
    .m06_axi_araddr        (m06_axi_araddr),
    .m06_axi_arlen         (m06_axi_arlen ),
    .m06_axi_arsize        (m06_axi_arsize),
    .m06_axi_arburst       (m06_axi_arburst),
    .m06_axi_arvalid       (m06_axi_arvalid),
    .m06_axi_arready       (m06_axi_arready),
    .m06_axi_rdata         (m06_axi_rdata ),
    .m06_axi_rlast         (m06_axi_rlast ),
    .m06_axi_rvalid        (m06_axi_rvalid),
    .m06_axi_rready        (m06_axi_rready),

    .m07_axi_awaddr        (m07_axi_awaddr),
    .m07_axi_awlen         (m07_axi_awlen ),
    .m07_axi_awsize        (m07_axi_awsize),
    .m07_axi_awburst       (m07_axi_awburst),
    .m07_axi_awvalid       (m07_axi_awvalid),
    .m07_axi_awready       (m07_axi_awready),
    .m07_axi_wdata         (m07_axi_wdata ),
    .m07_axi_wstrb         (m07_axi_wstrb ),
    .m07_axi_wlast         (m07_axi_wlast ),
    .m07_axi_wvalid        (m07_axi_wvalid),
    .m07_axi_wready        (m07_axi_wready),
    .m07_axi_bvalid        (m07_axi_bvalid),
    .m07_axi_bready        (m07_axi_bready),
    .m07_axi_araddr        (m07_axi_araddr),
    .m07_axi_arlen         (m07_axi_arlen ),
    .m07_axi_arsize        (m07_axi_arsize),
    .m07_axi_arburst       (m07_axi_arburst),
    .m07_axi_arvalid       (m07_axi_arvalid),
    .m07_axi_arready       (m07_axi_arready),
    .m07_axi_rdata         (m07_axi_rdata ),
    .m07_axi_rlast         (m07_axi_rlast ),
    .m07_axi_rvalid        (m07_axi_rvalid),
    .m07_axi_rready        (m07_axi_rready),

    .m08_axi_awaddr        (m08_axi_awaddr),
    .m08_axi_awlen         (m08_axi_awlen ),
    .m08_axi_awsize        (m08_axi_awsize),
    .m08_axi_awburst       (m08_axi_awburst),
    .m08_axi_awvalid       (m08_axi_awvalid),
    .m08_axi_awready       (m08_axi_awready),
    .m08_axi_wdata         (m08_axi_wdata ),
    .m08_axi_wstrb         (m08_axi_wstrb ),
    .m08_axi_wlast         (m08_axi_wlast ),
    .m08_axi_wvalid        (m08_axi_wvalid),
    .m08_axi_wready        (m08_axi_wready),
    .m08_axi_bvalid        (m08_axi_bvalid),
    .m08_axi_bready        (m08_axi_bready),
    .m08_axi_araddr        (m08_axi_araddr),
    .m08_axi_arlen         (m08_axi_arlen ),
    .m08_axi_arsize        (m08_axi_arsize),
    .m08_axi_arburst       (m08_axi_arburst),
    .m08_axi_arvalid       (m08_axi_arvalid),
    .m08_axi_arready       (m08_axi_arready),
    .m08_axi_rdata         (m08_axi_rdata ),
    .m08_axi_rlast         (m08_axi_rlast ),
    .m08_axi_rvalid        (m08_axi_rvalid),
    .m08_axi_rready        (m08_axi_rready),

    .m09_axi_awaddr        (m09_axi_awaddr),
    .m09_axi_awlen         (m09_axi_awlen ),
    .m09_axi_awsize        (m09_axi_awsize),
    .m09_axi_awburst       (m09_axi_awburst),
    .m09_axi_awvalid       (m09_axi_awvalid),
    .m09_axi_awready       (m09_axi_awready),
    .m09_axi_wdata         (m09_axi_wdata ),
    .m09_axi_wstrb         (m09_axi_wstrb ),
    .m09_axi_wlast         (m09_axi_wlast ),
    .m09_axi_wvalid        (m09_axi_wvalid),
    .m09_axi_wready        (m09_axi_wready),
    .m09_axi_bvalid        (m09_axi_bvalid),
    .m09_axi_bready        (m09_axi_bready),
    .m09_axi_araddr        (m09_axi_araddr),
    .m09_axi_arlen         (m09_axi_arlen ),
    .m09_axi_arsize        (m09_axi_arsize),
    .m09_axi_arburst       (m09_axi_arburst),
    .m09_axi_arvalid       (m09_axi_arvalid),
    .m09_axi_arready       (m09_axi_arready),
    .m09_axi_rdata         (m09_axi_rdata ),
    .m09_axi_rlast         (m09_axi_rlast ),
    .m09_axi_rvalid        (m09_axi_rvalid),
    .m09_axi_rready        (m09_axi_rready),

    .m10_axi_awaddr        (m10_axi_awaddr),
    .m10_axi_awlen         (m10_axi_awlen ),
    .m10_axi_awsize        (m10_axi_awsize),
    .m10_axi_awburst       (m10_axi_awburst),
    .m10_axi_awvalid       (m10_axi_awvalid),
    .m10_axi_awready       (m10_axi_awready),
    .m10_axi_wdata         (m10_axi_wdata ),
    .m10_axi_wstrb         (m10_axi_wstrb ),
    .m10_axi_wlast         (m10_axi_wlast ),
    .m10_axi_wvalid        (m10_axi_wvalid),
    .m10_axi_wready        (m10_axi_wready),
    .m10_axi_bvalid        (m10_axi_bvalid),
    .m10_axi_bready        (m10_axi_bready),
    .m10_axi_araddr        (m10_axi_araddr),
    .m10_axi_arlen         (m10_axi_arlen ),
    .m10_axi_arsize        (m10_axi_arsize),
    .m10_axi_arburst       (m10_axi_arburst),
    .m10_axi_arvalid       (m10_axi_arvalid),
    .m10_axi_arready       (m10_axi_arready),
    .m10_axi_rdata         (m10_axi_rdata ),
    .m10_axi_rlast         (m10_axi_rlast ),
    .m10_axi_rvalid        (m10_axi_rvalid),
    .m10_axi_rready        (m10_axi_rready),

    .m11_axi_awaddr        (m11_axi_awaddr),
    .m11_axi_awlen         (m11_axi_awlen ),
    .m11_axi_awsize        (m11_axi_awsize),
    .m11_axi_awburst       (m11_axi_awburst),
    .m11_axi_awvalid       (m11_axi_awvalid),
    .m11_axi_awready       (m11_axi_awready),
    .m11_axi_wdata         (m11_axi_wdata ),
    .m11_axi_wstrb         (m11_axi_wstrb ),
    .m11_axi_wlast         (m11_axi_wlast ),
    .m11_axi_wvalid        (m11_axi_wvalid),
    .m11_axi_wready        (m11_axi_wready),
    .m11_axi_bvalid        (m11_axi_bvalid),
    .m11_axi_bready        (m11_axi_bready),
    .m11_axi_araddr        (m11_axi_araddr),
    .m11_axi_arlen         (m11_axi_arlen ),
    .m11_axi_arsize        (m11_axi_arsize),
    .m11_axi_arburst       (m11_axi_arburst),
    .m11_axi_arvalid       (m11_axi_arvalid),
    .m11_axi_arready       (m11_axi_arready),
    .m11_axi_rdata         (m11_axi_rdata ),
    .m11_axi_rlast         (m11_axi_rlast ),
    .m11_axi_rvalid        (m11_axi_rvalid),
    .m11_axi_rready        (m11_axi_rready),

    .m12_axi_awaddr        (m12_axi_awaddr),
    .m12_axi_awlen         (m12_axi_awlen ),
    .m12_axi_awsize        (m12_axi_awsize),
    .m12_axi_awburst       (m12_axi_awburst),
    .m12_axi_awvalid       (m12_axi_awvalid),
    .m12_axi_awready       (m12_axi_awready),
    .m12_axi_wdata         (m12_axi_wdata ),
    .m12_axi_wstrb         (m12_axi_wstrb ),
    .m12_axi_wlast         (m12_axi_wlast ),
    .m12_axi_wvalid        (m12_axi_wvalid),
    .m12_axi_wready        (m12_axi_wready),
    .m12_axi_bvalid        (m12_axi_bvalid),
    .m12_axi_bready        (m12_axi_bready),
    .m12_axi_araddr        (m12_axi_araddr),
    .m12_axi_arlen         (m12_axi_arlen ),
    .m12_axi_arsize        (m12_axi_arsize),
    .m12_axi_arburst       (m12_axi_arburst),
    .m12_axi_arvalid       (m12_axi_arvalid),
    .m12_axi_arready       (m12_axi_arready),
    .m12_axi_rdata         (m12_axi_rdata ),
    .m12_axi_rlast         (m12_axi_rlast ),
    .m12_axi_rvalid        (m12_axi_rvalid),
    .m12_axi_rready        (m12_axi_rready),

    .m13_axi_awaddr        (m13_axi_awaddr),
    .m13_axi_awlen         (m13_axi_awlen ),
    .m13_axi_awsize        (m13_axi_awsize),
    .m13_axi_awburst       (m13_axi_awburst),
    .m13_axi_awvalid       (m13_axi_awvalid),
    .m13_axi_awready       (m13_axi_awready),
    .m13_axi_wdata         (m13_axi_wdata ),
    .m13_axi_wstrb         (m13_axi_wstrb ),
    .m13_axi_wlast         (m13_axi_wlast ),
    .m13_axi_wvalid        (m13_axi_wvalid),
    .m13_axi_wready        (m13_axi_wready),
    .m13_axi_bvalid        (m13_axi_bvalid),
    .m13_axi_bready        (m13_axi_bready),
    .m13_axi_araddr        (m13_axi_araddr),
    .m13_axi_arlen         (m13_axi_arlen ),
    .m13_axi_arsize        (m13_axi_arsize),
    .m13_axi_arburst       (m13_axi_arburst),
    .m13_axi_arvalid       (m13_axi_arvalid),
    .m13_axi_arready       (m13_axi_arready),
    .m13_axi_rdata         (m13_axi_rdata ),
    .m13_axi_rlast         (m13_axi_rlast ),
    .m13_axi_rvalid        (m13_axi_rvalid),
    .m13_axi_rready        (m13_axi_rready),

    .m14_axi_awaddr        (m14_axi_awaddr),
    .m14_axi_awlen         (m14_axi_awlen ),
    .m14_axi_awsize        (m14_axi_awsize),
    .m14_axi_awburst       (m14_axi_awburst),
    .m14_axi_awvalid       (m14_axi_awvalid),
    .m14_axi_awready       (m14_axi_awready),
    .m14_axi_wdata         (m14_axi_wdata ),
    .m14_axi_wstrb         (m14_axi_wstrb ),
    .m14_axi_wlast         (m14_axi_wlast ),
    .m14_axi_wvalid        (m14_axi_wvalid),
    .m14_axi_wready        (m14_axi_wready),
    .m14_axi_bvalid        (m14_axi_bvalid),
    .m14_axi_bready        (m14_axi_bready),
    .m14_axi_araddr        (m14_axi_araddr),
    .m14_axi_arlen         (m14_axi_arlen ),
    .m14_axi_arsize        (m14_axi_arsize),
    .m14_axi_arburst       (m14_axi_arburst),
    .m14_axi_arvalid       (m14_axi_arvalid),
    .m14_axi_arready       (m14_axi_arready),
    .m14_axi_rdata         (m14_axi_rdata ),
    .m14_axi_rlast         (m14_axi_rlast ),
    .m14_axi_rvalid        (m14_axi_rvalid),
    .m14_axi_rready        (m14_axi_rready),

    .m15_axi_awaddr        (m15_axi_awaddr),
    .m15_axi_awlen         (m15_axi_awlen ),
    .m15_axi_awsize        (m15_axi_awsize),
    .m15_axi_awburst       (m15_axi_awburst),
    .m15_axi_awvalid       (m15_axi_awvalid),
    .m15_axi_awready       (m15_axi_awready),
    .m15_axi_wdata         (m15_axi_wdata ),
    .m15_axi_wstrb         (m15_axi_wstrb ),
    .m15_axi_wlast         (m15_axi_wlast ),
    .m15_axi_wvalid        (m15_axi_wvalid),
    .m15_axi_wready        (m15_axi_wready),
    .m15_axi_bvalid        (m15_axi_bvalid),
    .m15_axi_bready        (m15_axi_bready),
    .m15_axi_araddr        (m15_axi_araddr),
    .m15_axi_arlen         (m15_axi_arlen ),
    .m15_axi_arsize        (m15_axi_arsize),
    .m15_axi_arburst       (m15_axi_arburst),
    .m15_axi_arvalid       (m15_axi_arvalid),
    .m15_axi_arready       (m15_axi_arready),
    .m15_axi_rdata         (m15_axi_rdata ),
    .m15_axi_rlast         (m15_axi_rlast ),
    .m15_axi_rvalid        (m15_axi_rvalid),
    .m15_axi_rready        (m15_axi_rready),

    .m16_axi_awaddr        (m16_axi_awaddr),
    .m16_axi_awlen         (m16_axi_awlen ),
    .m16_axi_awsize        (m16_axi_awsize),
    .m16_axi_awburst       (m16_axi_awburst),
    .m16_axi_awvalid       (m16_axi_awvalid),
    .m16_axi_awready       (m16_axi_awready),
    .m16_axi_wdata         (m16_axi_wdata ),
    .m16_axi_wstrb         (m16_axi_wstrb ),
    .m16_axi_wlast         (m16_axi_wlast ),
    .m16_axi_wvalid        (m16_axi_wvalid),
    .m16_axi_wready        (m16_axi_wready),
    .m16_axi_bvalid        (m16_axi_bvalid),
    .m16_axi_bready        (m16_axi_bready),
    .m16_axi_araddr        (m16_axi_araddr),
    .m16_axi_arlen         (m16_axi_arlen ),
    .m16_axi_arsize        (m16_axi_arsize),
    .m16_axi_arburst       (m16_axi_arburst),
    .m16_axi_arvalid       (m16_axi_arvalid),
    .m16_axi_arready       (m16_axi_arready),
    .m16_axi_rdata         (m16_axi_rdata ),
    .m16_axi_rlast         (m16_axi_rlast ),
    .m16_axi_rvalid        (m16_axi_rvalid),
    .m16_axi_rready        (m16_axi_rready),

    .m17_axi_awaddr        (m17_axi_awaddr),
    .m17_axi_awlen         (m17_axi_awlen ),
    .m17_axi_awsize        (m17_axi_awsize),
    .m17_axi_awburst       (m17_axi_awburst),
    .m17_axi_awvalid       (m17_axi_awvalid),
    .m17_axi_awready       (m17_axi_awready),
    .m17_axi_wdata         (m17_axi_wdata ),
    .m17_axi_wstrb         (m17_axi_wstrb ),
    .m17_axi_wlast         (m17_axi_wlast ),
    .m17_axi_wvalid        (m17_axi_wvalid),
    .m17_axi_wready        (m17_axi_wready),
    .m17_axi_bvalid        (m17_axi_bvalid),
    .m17_axi_bready        (m17_axi_bready),
    .m17_axi_araddr        (m17_axi_araddr),
    .m17_axi_arlen         (m17_axi_arlen ),
    .m17_axi_arsize        (m17_axi_arsize),
    .m17_axi_arburst       (m17_axi_arburst),
    .m17_axi_arvalid       (m17_axi_arvalid),
    .m17_axi_arready       (m17_axi_arready),
    .m17_axi_rdata         (m17_axi_rdata ),
    .m17_axi_rlast         (m17_axi_rlast ),
    .m17_axi_rvalid        (m17_axi_rvalid),
    .m17_axi_rready        (m17_axi_rready),

    .m18_axi_awaddr        (m18_axi_awaddr),
    .m18_axi_awlen         (m18_axi_awlen ),
    .m18_axi_awsize        (m18_axi_awsize),
    .m18_axi_awburst       (m18_axi_awburst),
    .m18_axi_awvalid       (m18_axi_awvalid),
    .m18_axi_awready       (m18_axi_awready),
    .m18_axi_wdata         (m18_axi_wdata ),
    .m18_axi_wstrb         (m18_axi_wstrb ),
    .m18_axi_wlast         (m18_axi_wlast ),
    .m18_axi_wvalid        (m18_axi_wvalid),
    .m18_axi_wready        (m18_axi_wready),
    .m18_axi_bvalid        (m18_axi_bvalid),
    .m18_axi_bready        (m18_axi_bready),
    .m18_axi_araddr        (m18_axi_araddr),
    .m18_axi_arlen         (m18_axi_arlen ),
    .m18_axi_arsize        (m18_axi_arsize),
    .m18_axi_arburst       (m18_axi_arburst),
    .m18_axi_arvalid       (m18_axi_arvalid),
    .m18_axi_arready       (m18_axi_arready),
    .m18_axi_rdata         (m18_axi_rdata ),
    .m18_axi_rlast         (m18_axi_rlast ),
    .m18_axi_rvalid        (m18_axi_rvalid),
    .m18_axi_rready        (m18_axi_rready),

    .m19_axi_awaddr        (m19_axi_awaddr),
    .m19_axi_awlen         (m19_axi_awlen ),
    .m19_axi_awsize        (m19_axi_awsize),
    .m19_axi_awburst       (m19_axi_awburst),
    .m19_axi_awvalid       (m19_axi_awvalid),
    .m19_axi_awready       (m19_axi_awready),
    .m19_axi_wdata         (m19_axi_wdata ),
    .m19_axi_wstrb         (m19_axi_wstrb ),
    .m19_axi_wlast         (m19_axi_wlast ),
    .m19_axi_wvalid        (m19_axi_wvalid),
    .m19_axi_wready        (m19_axi_wready),
    .m19_axi_bvalid        (m19_axi_bvalid),
    .m19_axi_bready        (m19_axi_bready),
    .m19_axi_araddr        (m19_axi_araddr),
    .m19_axi_arlen         (m19_axi_arlen ),
    .m19_axi_arsize        (m19_axi_arsize),
    .m19_axi_arburst       (m19_axi_arburst),
    .m19_axi_arvalid       (m19_axi_arvalid),
    .m19_axi_arready       (m19_axi_arready),
    .m19_axi_rdata         (m19_axi_rdata ),
    .m19_axi_rlast         (m19_axi_rlast ),
    .m19_axi_rvalid        (m19_axi_rvalid),
    .m19_axi_rready        (m19_axi_rready),

    .m20_axi_awaddr        (m20_axi_awaddr),
    .m20_axi_awlen         (m20_axi_awlen ),
    .m20_axi_awsize        (m20_axi_awsize),
    .m20_axi_awburst       (m20_axi_awburst),
    .m20_axi_awvalid       (m20_axi_awvalid),
    .m20_axi_awready       (m20_axi_awready),
    .m20_axi_wdata         (m20_axi_wdata ),
    .m20_axi_wstrb         (m20_axi_wstrb ),
    .m20_axi_wlast         (m20_axi_wlast ),
    .m20_axi_wvalid        (m20_axi_wvalid),
    .m20_axi_wready        (m20_axi_wready),
    .m20_axi_bvalid        (m20_axi_bvalid),
    .m20_axi_bready        (m20_axi_bready),
    .m20_axi_araddr        (m20_axi_araddr),
    .m20_axi_arlen         (m20_axi_arlen ),
    .m20_axi_arsize        (m20_axi_arsize),
    .m20_axi_arburst       (m20_axi_arburst),
    .m20_axi_arvalid       (m20_axi_arvalid),
    .m20_axi_arready       (m20_axi_arready),
    .m20_axi_rdata         (m20_axi_rdata ),
    .m20_axi_rlast         (m20_axi_rlast ),
    .m20_axi_rvalid        (m20_axi_rvalid),
    .m20_axi_rready        (m20_axi_rready),

    .m21_axi_awaddr        (m21_axi_awaddr),
    .m21_axi_awlen         (m21_axi_awlen ),
    .m21_axi_awsize        (m21_axi_awsize),
    .m21_axi_awburst       (m21_axi_awburst),
    .m21_axi_awvalid       (m21_axi_awvalid),
    .m21_axi_awready       (m21_axi_awready),
    .m21_axi_wdata         (m21_axi_wdata ),
    .m21_axi_wstrb         (m21_axi_wstrb ),
    .m21_axi_wlast         (m21_axi_wlast ),
    .m21_axi_wvalid        (m21_axi_wvalid),
    .m21_axi_wready        (m21_axi_wready),
    .m21_axi_bvalid        (m21_axi_bvalid),
    .m21_axi_bready        (m21_axi_bready),
    .m21_axi_araddr        (m21_axi_araddr),
    .m21_axi_arlen         (m21_axi_arlen ),
    .m21_axi_arsize        (m21_axi_arsize),
    .m21_axi_arburst       (m21_axi_arburst),
    .m21_axi_arvalid       (m21_axi_arvalid),
    .m21_axi_arready       (m21_axi_arready),
    .m21_axi_rdata         (m21_axi_rdata ),
    .m21_axi_rlast         (m21_axi_rlast ),
    .m21_axi_rvalid        (m21_axi_rvalid),
    .m21_axi_rready        (m21_axi_rready),

    .m22_axi_awaddr        (m22_axi_awaddr),
    .m22_axi_awlen         (m22_axi_awlen ),
    .m22_axi_awsize        (m22_axi_awsize),
    .m22_axi_awburst       (m22_axi_awburst),
    .m22_axi_awvalid       (m22_axi_awvalid),
    .m22_axi_awready       (m22_axi_awready),
    .m22_axi_wdata         (m22_axi_wdata ),
    .m22_axi_wstrb         (m22_axi_wstrb ),
    .m22_axi_wlast         (m22_axi_wlast ),
    .m22_axi_wvalid        (m22_axi_wvalid),
    .m22_axi_wready        (m22_axi_wready),
    .m22_axi_bvalid        (m22_axi_bvalid),
    .m22_axi_bready        (m22_axi_bready),
    .m22_axi_araddr        (m22_axi_araddr),
    .m22_axi_arlen         (m22_axi_arlen ),
    .m22_axi_arsize        (m22_axi_arsize),
    .m22_axi_arburst       (m22_axi_arburst),
    .m22_axi_arvalid       (m22_axi_arvalid),
    .m22_axi_arready       (m22_axi_arready),
    .m22_axi_rdata         (m22_axi_rdata ),
    .m22_axi_rlast         (m22_axi_rlast ),
    .m22_axi_rvalid        (m22_axi_rvalid),
    .m22_axi_rready        (m22_axi_rready),

    .m23_axi_awaddr        (m23_axi_awaddr),
    .m23_axi_awlen         (m23_axi_awlen ),
    .m23_axi_awsize        (m23_axi_awsize),
    .m23_axi_awburst       (m23_axi_awburst),
    .m23_axi_awvalid       (m23_axi_awvalid),
    .m23_axi_awready       (m23_axi_awready),
    .m23_axi_wdata         (m23_axi_wdata ),
    .m23_axi_wstrb         (m23_axi_wstrb ),
    .m23_axi_wlast         (m23_axi_wlast ),
    .m23_axi_wvalid        (m23_axi_wvalid),
    .m23_axi_wready        (m23_axi_wready),
    .m23_axi_bvalid        (m23_axi_bvalid),
    .m23_axi_bready        (m23_axi_bready),
    .m23_axi_araddr        (m23_axi_araddr),
    .m23_axi_arlen         (m23_axi_arlen ),
    .m23_axi_arsize        (m23_axi_arsize),
    .m23_axi_arburst       (m23_axi_arburst),
    .m23_axi_arvalid       (m23_axi_arvalid),
    .m23_axi_arready       (m23_axi_arready),
    .m23_axi_rdata         (m23_axi_rdata ),
    .m23_axi_rlast         (m23_axi_rlast ),
    .m23_axi_rvalid        (m23_axi_rvalid),
    .m23_axi_rready        (m23_axi_rready),

    .m24_axi_awaddr        (m24_axi_awaddr),
    .m24_axi_awlen         (m24_axi_awlen ),
    .m24_axi_awsize        (m24_axi_awsize),
    .m24_axi_awburst       (m24_axi_awburst),
    .m24_axi_awvalid       (m24_axi_awvalid),
    .m24_axi_awready       (m24_axi_awready),
    .m24_axi_wdata         (m24_axi_wdata ),
    .m24_axi_wstrb         (m24_axi_wstrb ),
    .m24_axi_wlast         (m24_axi_wlast ),
    .m24_axi_wvalid        (m24_axi_wvalid),
    .m24_axi_wready        (m24_axi_wready),
    .m24_axi_bvalid        (m24_axi_bvalid),
    .m24_axi_bready        (m24_axi_bready),
    .m24_axi_araddr        (m24_axi_araddr),
    .m24_axi_arlen         (m24_axi_arlen ),
    .m24_axi_arsize        (m24_axi_arsize),
    .m24_axi_arburst       (m24_axi_arburst),
    .m24_axi_arvalid       (m24_axi_arvalid),
    .m24_axi_arready       (m24_axi_arready),
    .m24_axi_rdata         (m24_axi_rdata ),
    .m24_axi_rlast         (m24_axi_rlast ),
    .m24_axi_rvalid        (m24_axi_rvalid),
    .m24_axi_rready        (m24_axi_rready),

    .m25_axi_awaddr        (m25_axi_awaddr),
    .m25_axi_awlen         (m25_axi_awlen ),
    .m25_axi_awsize        (m25_axi_awsize),
    .m25_axi_awburst       (m25_axi_awburst),
    .m25_axi_awvalid       (m25_axi_awvalid),
    .m25_axi_awready       (m25_axi_awready),
    .m25_axi_wdata         (m25_axi_wdata ),
    .m25_axi_wstrb         (m25_axi_wstrb ),
    .m25_axi_wlast         (m25_axi_wlast ),
    .m25_axi_wvalid        (m25_axi_wvalid),
    .m25_axi_wready        (m25_axi_wready),
    .m25_axi_bvalid        (m25_axi_bvalid),
    .m25_axi_bready        (m25_axi_bready),
    .m25_axi_araddr        (m25_axi_araddr),
    .m25_axi_arlen         (m25_axi_arlen ),
    .m25_axi_arsize        (m25_axi_arsize),
    .m25_axi_arburst       (m25_axi_arburst),
    .m25_axi_arvalid       (m25_axi_arvalid),
    .m25_axi_arready       (m25_axi_arready),
    .m25_axi_rdata         (m25_axi_rdata ),
    .m25_axi_rlast         (m25_axi_rlast ),
    .m25_axi_rvalid        (m25_axi_rvalid),
    .m25_axi_rready        (m25_axi_rready),

    .m26_axi_awaddr        (m26_axi_awaddr),
    .m26_axi_awlen         (m26_axi_awlen ),
    .m26_axi_awsize        (m26_axi_awsize),
    .m26_axi_awburst       (m26_axi_awburst),
    .m26_axi_awvalid       (m26_axi_awvalid),
    .m26_axi_awready       (m26_axi_awready),
    .m26_axi_wdata         (m26_axi_wdata ),
    .m26_axi_wstrb         (m26_axi_wstrb ),
    .m26_axi_wlast         (m26_axi_wlast ),
    .m26_axi_wvalid        (m26_axi_wvalid),
    .m26_axi_wready        (m26_axi_wready),
    .m26_axi_bvalid        (m26_axi_bvalid),
    .m26_axi_bready        (m26_axi_bready),
    .m26_axi_araddr        (m26_axi_araddr),
    .m26_axi_arlen         (m26_axi_arlen ),
    .m26_axi_arsize        (m26_axi_arsize),
    .m26_axi_arburst       (m26_axi_arburst),
    .m26_axi_arvalid       (m26_axi_arvalid),
    .m26_axi_arready       (m26_axi_arready),
    .m26_axi_rdata         (m26_axi_rdata ),
    .m26_axi_rlast         (m26_axi_rlast ),
    .m26_axi_rvalid        (m26_axi_rvalid),
    .m26_axi_rready        (m26_axi_rready),

    .m27_axi_awaddr        (m27_axi_awaddr),
    .m27_axi_awlen         (m27_axi_awlen ),
    .m27_axi_awsize        (m27_axi_awsize),
    .m27_axi_awburst       (m27_axi_awburst),
    .m27_axi_awvalid       (m27_axi_awvalid),
    .m27_axi_awready       (m27_axi_awready),
    .m27_axi_wdata         (m27_axi_wdata ),
    .m27_axi_wstrb         (m27_axi_wstrb ),
    .m27_axi_wlast         (m27_axi_wlast ),
    .m27_axi_wvalid        (m27_axi_wvalid),
    .m27_axi_wready        (m27_axi_wready),
    .m27_axi_bvalid        (m27_axi_bvalid),
    .m27_axi_bready        (m27_axi_bready),
    .m27_axi_araddr        (m27_axi_araddr),
    .m27_axi_arlen         (m27_axi_arlen ),
    .m27_axi_arsize        (m27_axi_arsize),
    .m27_axi_arburst       (m27_axi_arburst),
    .m27_axi_arvalid       (m27_axi_arvalid),
    .m27_axi_arready       (m27_axi_arready),
    .m27_axi_rdata         (m27_axi_rdata ),
    .m27_axi_rlast         (m27_axi_rlast ),
    .m27_axi_rvalid        (m27_axi_rvalid),
    .m27_axi_rready        (m27_axi_rready),

    .m28_axi_awaddr        (m28_axi_awaddr),
    .m28_axi_awlen         (m28_axi_awlen ),
    .m28_axi_awsize        (m28_axi_awsize),
    .m28_axi_awburst       (m28_axi_awburst),
    .m28_axi_awvalid       (m28_axi_awvalid),
    .m28_axi_awready       (m28_axi_awready),
    .m28_axi_wdata         (m28_axi_wdata ),
    .m28_axi_wstrb         (m28_axi_wstrb ),
    .m28_axi_wlast         (m28_axi_wlast ),
    .m28_axi_wvalid        (m28_axi_wvalid),
    .m28_axi_wready        (m28_axi_wready),
    .m28_axi_bvalid        (m28_axi_bvalid),
    .m28_axi_bready        (m28_axi_bready),
    .m28_axi_araddr        (m28_axi_araddr),
    .m28_axi_arlen         (m28_axi_arlen ),
    .m28_axi_arsize        (m28_axi_arsize),
    .m28_axi_arburst       (m28_axi_arburst),
    .m28_axi_arvalid       (m28_axi_arvalid),
    .m28_axi_arready       (m28_axi_arready),
    .m28_axi_rdata         (m28_axi_rdata ),
    .m28_axi_rlast         (m28_axi_rlast ),
    .m28_axi_rvalid        (m28_axi_rvalid),
    .m28_axi_rready        (m28_axi_rready),

    .m29_axi_awaddr        (m29_axi_awaddr),
    .m29_axi_awlen         (m29_axi_awlen ),
    .m29_axi_awsize        (m29_axi_awsize),
    .m29_axi_awburst       (m29_axi_awburst),
    .m29_axi_awvalid       (m29_axi_awvalid),
    .m29_axi_awready       (m29_axi_awready),
    .m29_axi_wdata         (m29_axi_wdata ),
    .m29_axi_wstrb         (m29_axi_wstrb ),
    .m29_axi_wlast         (m29_axi_wlast ),
    .m29_axi_wvalid        (m29_axi_wvalid),
    .m29_axi_wready        (m29_axi_wready),
    .m29_axi_bvalid        (m29_axi_bvalid),
    .m29_axi_bready        (m29_axi_bready),
    .m29_axi_araddr        (m29_axi_araddr),
    .m29_axi_arlen         (m29_axi_arlen ),
    .m29_axi_arsize        (m29_axi_arsize),
    .m29_axi_arburst       (m29_axi_arburst),
    .m29_axi_arvalid       (m29_axi_arvalid),
    .m29_axi_arready       (m29_axi_arready),
    .m29_axi_rdata         (m29_axi_rdata ),
    .m29_axi_rlast         (m29_axi_rlast ),
    .m29_axi_rvalid        (m29_axi_rvalid),
    .m29_axi_rready        (m29_axi_rready),

    .m30_axi_awaddr        (m30_axi_awaddr),
    .m30_axi_awlen         (m30_axi_awlen ),
    .m30_axi_awsize        (m30_axi_awsize),
    .m30_axi_awburst       (m30_axi_awburst),
    .m30_axi_awvalid       (m30_axi_awvalid),
    .m30_axi_awready       (m30_axi_awready),
    .m30_axi_wdata         (m30_axi_wdata ),
    .m30_axi_wstrb         (m30_axi_wstrb ),
    .m30_axi_wlast         (m30_axi_wlast ),
    .m30_axi_wvalid        (m30_axi_wvalid),
    .m30_axi_wready        (m30_axi_wready),
    .m30_axi_bvalid        (m30_axi_bvalid),
    .m30_axi_bready        (m30_axi_bready),
    .m30_axi_araddr        (m30_axi_araddr),
    .m30_axi_arlen         (m30_axi_arlen ),
    .m30_axi_arsize        (m30_axi_arsize),
    .m30_axi_arburst       (m30_axi_arburst),
    .m30_axi_arvalid       (m30_axi_arvalid),
    .m30_axi_arready       (m30_axi_arready),
    .m30_axi_rdata         (m30_axi_rdata ),
    .m30_axi_rlast         (m30_axi_rlast ),
    .m30_axi_rvalid        (m30_axi_rvalid),
    .m30_axi_rready        (m30_axi_rready),

    .m31_axi_awaddr        (m31_axi_awaddr),
    .m31_axi_awlen         (m31_axi_awlen ),
    .m31_axi_awsize        (m31_axi_awsize),
    .m31_axi_awburst       (m31_axi_awburst),
    .m31_axi_awvalid       (m31_axi_awvalid),
    .m31_axi_awready       (m31_axi_awready),
    .m31_axi_wdata         (m31_axi_wdata ),
    .m31_axi_wstrb         (m31_axi_wstrb ),
    .m31_axi_wlast         (m31_axi_wlast ),
    .m31_axi_wvalid        (m31_axi_wvalid),
    .m31_axi_wready        (m31_axi_wready),
    .m31_axi_bvalid        (m31_axi_bvalid),
    .m31_axi_bready        (m31_axi_bready),
    .m31_axi_araddr        (m31_axi_araddr),
    .m31_axi_arlen         (m31_axi_arlen ),
    .m31_axi_arsize        (m31_axi_arsize),
    .m31_axi_arburst       (m31_axi_arburst),
    .m31_axi_arvalid       (m31_axi_arvalid),
    .m31_axi_arready       (m31_axi_arready),
    .m31_axi_rdata         (m31_axi_rdata ),
    .m31_axi_rlast         (m31_axi_rlast ),
    .m31_axi_rvalid        (m31_axi_rvalid),
    .m31_axi_rready        (m31_axi_rready)

);





/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// Generate Clock
initial begin
    clk = 0;
    forever #`CLK_HALF clk = ~clk;
end

// Initialize signals to zero
initial begin
  axils_araddr  <= 'b0;
  axils_arvalid <= 'b0;
  axils_awaddr  <= 'b0;
  axils_awvalid <= 'b0;
  axils_bready  <= 'b0;
  axils_rready  <= 'b0;
  axils_wdata   <= 'b0;
  axils_wstrb   <= 'b0;
  axils_wvalid  <= 'b0;
end

// Reset the circuit
initial begin
    aresetn = 0;
    #`RESET_TIME
    aresetn = 1;
end

localparam
  ADDR_AP_CTRL         = 9'h000,
  ADDR_GIE             = 9'h004,
  ADDR_IER             = 9'h008,
  ADDR_ISR             = 9'h00c,
  ADDR_AP_CONTROL      = 9'h010,
  ADDR_AP_STATUS       = 9'h014,
  ADDR_AP_DEBUG        = 9'h018,
  ADDR_AP_TIMING       = 9'h01c,
  ADDR_HBM_PARAMS_0    = 9'h020,
  ADDR_HBM_PARAMS_1    = 9'h024,
  ADDR_HBM_ADDR00_0    = 9'h028,
  ADDR_HBM_ADDR00_1    = 9'h02c,
  ADDR_HBM_ADDR01_0    = 9'h030,
  ADDR_HBM_ADDR01_1    = 9'h034,
  ADDR_HBM_ADDR02_0    = 9'h038,
  ADDR_HBM_ADDR02_1    = 9'h03c,
  ADDR_HBM_ADDR03_0    = 9'h040,
  ADDR_HBM_ADDR03_1    = 9'h044,
  ADDR_HBM_ADDR04_0    = 9'h048,
  ADDR_HBM_ADDR04_1    = 9'h04c,
  ADDR_HBM_ADDR05_0    = 9'h050,
  ADDR_HBM_ADDR05_1    = 9'h054,
  ADDR_HBM_ADDR06_0    = 9'h058,
  ADDR_HBM_ADDR06_1    = 9'h05c,
  ADDR_HBM_ADDR07_0    = 9'h060,
  ADDR_HBM_ADDR07_1    = 9'h064,
  ADDR_HBM_ADDR08_0    = 9'h068,
  ADDR_HBM_ADDR08_1    = 9'h06c,
  ADDR_HBM_ADDR09_0    = 9'h070,
  ADDR_HBM_ADDR09_1    = 9'h074,
  ADDR_HBM_ADDR10_0    = 9'h078,
  ADDR_HBM_ADDR10_1    = 9'h07c,
  ADDR_HBM_ADDR11_0    = 9'h080,
  ADDR_HBM_ADDR11_1    = 9'h084,
  ADDR_HBM_ADDR12_0    = 9'h088,
  ADDR_HBM_ADDR12_1    = 9'h08c,
  ADDR_HBM_ADDR13_0    = 9'h090,
  ADDR_HBM_ADDR13_1    = 9'h094,
  ADDR_HBM_ADDR14_0    = 9'h098,
  ADDR_HBM_ADDR14_1    = 9'h09c,
  ADDR_HBM_ADDR15_0    = 9'h0a0,
  ADDR_HBM_ADDR15_1    = 9'h0a4,
  ADDR_HBM_ADDR16_0    = 9'h0a8,
  ADDR_HBM_ADDR16_1    = 9'h0ac,
  ADDR_HBM_ADDR17_0    = 9'h0b0,
  ADDR_HBM_ADDR17_1    = 9'h0b4,
  ADDR_HBM_ADDR18_0    = 9'h0b8,
  ADDR_HBM_ADDR18_1    = 9'h0bc,
  ADDR_HBM_ADDR19_0    = 9'h0c0,
  ADDR_HBM_ADDR19_1    = 9'h0c4,
  ADDR_HBM_ADDR20_0    = 9'h0c8,
  ADDR_HBM_ADDR20_1    = 9'h0cc,
  ADDR_HBM_ADDR21_0    = 9'h0d0,
  ADDR_HBM_ADDR21_1    = 9'h0d4,
  ADDR_HBM_ADDR22_0    = 9'h0d8,
  ADDR_HBM_ADDR22_1    = 9'h0dc,
  ADDR_HBM_ADDR23_0    = 9'h0e0,
  ADDR_HBM_ADDR23_1    = 9'h0e4,
  ADDR_HBM_ADDR24_0    = 9'h0e8,
  ADDR_HBM_ADDR24_1    = 9'h0ec,
  ADDR_HBM_ADDR25_0    = 9'h0f0,
  ADDR_HBM_ADDR25_1    = 9'h0f4,
  ADDR_HBM_ADDR26_0    = 9'h0f8,
  ADDR_HBM_ADDR26_1    = 9'h0fc,
  ADDR_HBM_ADDR27_0    = 9'h100,
  ADDR_HBM_ADDR27_1    = 9'h104,
  ADDR_HBM_ADDR28_0    = 9'h108,
  ADDR_HBM_ADDR28_1    = 9'h10c,
  ADDR_HBM_ADDR29_0    = 9'h110,
  ADDR_HBM_ADDR29_1    = 9'h114,
  ADDR_HBM_ADDR30_0    = 9'h118,
  ADDR_HBM_ADDR30_1    = 9'h11c,
  ADDR_HBM_ADDR31_0    = 9'h120,
  ADDR_HBM_ADDR31_1    = 9'h124;

initial begin
  forever begin
    #10000;
    $display("RTL_PROGRESS: time_ns=%0.0f configured_writes=%0d done=%b status=%h", $realtime, config_writes, done, status);
  end
end

task perform_read;
  input [11:0] reg_address;
  output [31:0] reg_data;
  begin
    // Channel AR
    axils_araddr  <= reg_address;
    axils_arvalid <= 1'b1;
    wait (axils_arready);
    #`CLK_PERIOD;
    axils_arvalid <= 1'b0;
    // Channel R
    axils_rready  <= 1'b1;
    wait (axils_rvalid);
    reg_data <= axils_rdata;
    #`CLK_PERIOD;
    axils_rready  <= 1'b0;
    #`CLK_PERIOD;
    #`RESET_TIME;
    config_writes = config_writes + 1;
    if ((config_writes % 16) == 0)
      $display("AXIL_PROGRESS: completed_writes=%0d time_ns=%0.0f", config_writes, $realtime);
  end
endtask

task perform_write;
  input [11:0] reg_address;
  input [31:0] reg_data;
  begin
    // Channel AW
    axils_awaddr <= reg_address;
    axils_awvalid <= 1'b1;
    // Channel W
    axils_wdata  <= reg_data;
    axils_wstrb  <= 4'b1111;
    axils_wvalid <= 1'b1;
    // Channel AW
    wait (axils_awready);
    #`CLK_PERIOD;
    axils_awvalid <= 1'b0;
    // Channel W
    wait (axils_wready);
    #`CLK_PERIOD;
    axils_wvalid <= 1'b0;
    // Channel B
    axils_bready <= 1'b1;
    wait (axils_bvalid);
    #`CLK_PERIOD;
    axils_bready <= 1'b0;
    #`CLK_PERIOD;
    #`RESET_TIME;
  end
endtask

task wait_CmdDone;
  begin
    #`CLK_PERIOD;
    perform_read(ADDR_AP_STATUS, status);
    while (status[0]==1'b0)
    begin
      #`LONG_WAIT;
      perform_read(ADDR_AP_STATUS, status);
    end
    #`CLK_PERIOD;
  end
endtask

task wait_ApDone;
  begin
    #`CLK_PERIOD;
    perform_read(ADDR_AP_CTRL, status);
    while (status[1]==1'b0)
    begin
      #`LONG_WAIT;
      perform_read(ADDR_AP_CTRL, status);
    end
    #`CLK_PERIOD;
  end
endtask



localparam
  CMD_EXIT = 32'hFFFFFFFF;


initial begin
  done = 1'b0;

  #`RESET_TIME
  perform_write(ADDR_HBM_ADDR00_0, 32'h00000000); // Mem Addr Low
  perform_write(ADDR_HBM_ADDR00_1, 32'h00000000); // Mem Addr High
  perform_write(ADDR_HBM_ADDR01_0, 32'h00000000); // Mem Addr Low
  perform_write(ADDR_HBM_ADDR01_1, 32'h00000000); // Mem Addr High
  perform_write(ADDR_HBM_ADDR02_0, 32'h00000000); // Mem Addr Low
  perform_write(ADDR_HBM_ADDR02_1, 32'h00000000); // Mem Addr High
  perform_write(ADDR_HBM_ADDR03_0, 32'h00000000); // Mem Addr Low
  perform_write(ADDR_HBM_ADDR03_1, 32'h00000000); // Mem Addr High
  perform_write(ADDR_HBM_ADDR04_0, 32'h00000000); // Mem Addr Low
  perform_write(ADDR_HBM_ADDR04_1, 32'h00000000); // Mem Addr High
  perform_write(ADDR_HBM_ADDR05_0, 32'h00000000); // Mem Addr Low
  perform_write(ADDR_HBM_ADDR05_1, 32'h00000000); // Mem Addr High
  perform_write(ADDR_HBM_ADDR06_0, 32'h00000000); // Mem Addr Low
  perform_write(ADDR_HBM_ADDR06_1, 32'h00000000); // Mem Addr High
  perform_write(ADDR_HBM_ADDR07_0, 32'h00000000); // Mem Addr Low
  perform_write(ADDR_HBM_ADDR07_1, 32'h00000000); // Mem Addr High
  perform_write(ADDR_HBM_ADDR08_0, 32'h00000000); // Mem Addr Low
  perform_write(ADDR_HBM_ADDR08_1, 32'h00000000); // Mem Addr High
  perform_write(ADDR_HBM_ADDR09_0, 32'h00000000); // Mem Addr Low
  perform_write(ADDR_HBM_ADDR09_1, 32'h00000000); // Mem Addr High
  perform_write(ADDR_HBM_ADDR10_0, 32'h00000000); // Mem Addr Low
  perform_write(ADDR_HBM_ADDR10_1, 32'h00000000); // Mem Addr High
  perform_write(ADDR_HBM_ADDR11_0, 32'h00000000); // Mem Addr Low
  perform_write(ADDR_HBM_ADDR11_1, 32'h00000000); // Mem Addr High
  perform_write(ADDR_HBM_ADDR12_0, 32'h00000000); // Mem Addr Low
  perform_write(ADDR_HBM_ADDR12_1, 32'h00000000); // Mem Addr High
  perform_write(ADDR_HBM_ADDR13_0, 32'h00000000); // Mem Addr Low
  perform_write(ADDR_HBM_ADDR13_1, 32'h00000000); // Mem Addr High
  perform_write(ADDR_HBM_ADDR14_0, 32'h00000000); // Mem Addr Low
  perform_write(ADDR_HBM_ADDR14_1, 32'h00000000); // Mem Addr High
  perform_write(ADDR_HBM_ADDR15_0, 32'h00000000); // Mem Addr Low
  perform_write(ADDR_HBM_ADDR15_1, 32'h00000000); // Mem Addr High
  perform_write(ADDR_HBM_ADDR16_0, 32'h00000000); // Mem Addr Low
  perform_write(ADDR_HBM_ADDR16_1, 32'h00000000); // Mem Addr High
  perform_write(ADDR_HBM_ADDR17_0, 32'h00000000); // Mem Addr Low
  perform_write(ADDR_HBM_ADDR17_1, 32'h00000000); // Mem Addr High
  perform_write(ADDR_HBM_ADDR18_0, 32'h00000000); // Mem Addr Low
  perform_write(ADDR_HBM_ADDR18_1, 32'h00000000); // Mem Addr High
  perform_write(ADDR_HBM_ADDR19_0, 32'h00000000); // Mem Addr Low
  perform_write(ADDR_HBM_ADDR19_1, 32'h00000000); // Mem Addr High
  perform_write(ADDR_HBM_ADDR20_0, 32'h00000000); // Mem Addr Low
  perform_write(ADDR_HBM_ADDR20_1, 32'h00000000); // Mem Addr High
  perform_write(ADDR_HBM_ADDR21_0, 32'h00000000); // Mem Addr Low
  perform_write(ADDR_HBM_ADDR21_1, 32'h00000000); // Mem Addr High
  perform_write(ADDR_HBM_ADDR22_0, 32'h00000000); // Mem Addr Low
  perform_write(ADDR_HBM_ADDR22_1, 32'h00000000); // Mem Addr High
  perform_write(ADDR_HBM_ADDR23_0, 32'h00000000); // Mem Addr Low
  perform_write(ADDR_HBM_ADDR23_1, 32'h00000000); // Mem Addr High
  perform_write(ADDR_HBM_ADDR24_0, 32'h00000000); // Mem Addr Low
  perform_write(ADDR_HBM_ADDR24_1, 32'h00000000); // Mem Addr High
  perform_write(ADDR_HBM_ADDR25_0, 32'h00000000); // Mem Addr Low
  perform_write(ADDR_HBM_ADDR25_1, 32'h00000000); // Mem Addr High
  perform_write(ADDR_HBM_ADDR26_0, 32'h00000000); // Mem Addr Low
  perform_write(ADDR_HBM_ADDR26_1, 32'h00000000); // Mem Addr High
  perform_write(ADDR_HBM_ADDR27_0, 32'h00000000); // Mem Addr Low
  perform_write(ADDR_HBM_ADDR27_1, 32'h00000000); // Mem Addr High
  perform_write(ADDR_HBM_ADDR28_0, 32'h00000000); // Mem Addr Low
  perform_write(ADDR_HBM_ADDR28_1, 32'h00000000); // Mem Addr High
  perform_write(ADDR_HBM_ADDR29_0, 32'h00000000); // Mem Addr Low
  perform_write(ADDR_HBM_ADDR29_1, 32'h00000000); // Mem Addr High
  perform_write(ADDR_HBM_ADDR30_0, 32'h00000000); // Mem Addr Low
  perform_write(ADDR_HBM_ADDR30_1, 32'h00000000); // Mem Addr High
  perform_write(ADDR_HBM_ADDR31_0, 32'h00000000); // Mem Addr Low
  perform_write(ADDR_HBM_ADDR31_1, 32'h00000000); // Mem Addr High

  ////////////////////////////////////////////////////////////////////////////

  timing_start_ns = $realtime;
  $display("KERNEL_START: time_ns=%0.0f", $realtime);
  perform_write(ADDR_AP_CTRL     , 32'h00000001);
  // perform_write(ADDR_AP_CONTROL  , 32'h00000000);

  ////////////////////////////////////////////////////////////////////////////

  wait_ApDone();
  // #`HUGE_WAIT
  if ($test$plusargs("RELIN_TIMING_ONLY"))
    $display("TIMING_ONLY_RESULT: relinearization control-start-to-polled-done latency_ns=%0.3f cycles=%0.0f; synthetic zero data; arithmetic unverified; not standalone NTT latency or steady-state throughput",
             $realtime - timing_start_ns, ($realtime - timing_start_ns) / `CLK_PERIOD);
  done = 1'b1;
  ////////////////////////////////////////////////////////////////////////////

  perform_write(ADDR_AP_CONTROL  , CMD_EXIT);
  #`HUGE_WAIT
  $finish;

end

endmodule
