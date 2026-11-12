`timescale 1ns / 1ps
module relin_q_loader
   #(   
        parameter LOGN     = 16,
        parameter L        = 30, // number of primes
        parameter LOGQ     = 64,
        parameter LOGQH    = 17,
        parameter DELAY_G1_A  = 2,
        parameter DELAY_G1_B  = 2,
        parameter DELAY_G1_C  = 2,
        parameter DELAY_G2_A  = 2
    )
    (
        input                  clk     ,
        input                  rst     ,
        input                  load_q_g1,
        input                  load_q_g2,
        output [LOGQH-1:0]     qH_g1_A ,
        output [LOGQH-1:0]     qH_g1_B ,
        output [LOGQH-1:0]     qH_g1_C ,
        output [LOGQH-1:0]     qH_g2_A ,
        output [LOGQ -1:0]     half_g2_A,
        output [LOGQ -1:0]     q_inv_g2_A,
        output                 done_g1 ,
        output                 done_g2 ,
        output                 load_q_g1_A,
        output                 load_q_g1_B,
        output                 load_q_g1_C,
        output                 load_q_g2_A
    );

localparam LOGL = $rtoi($ceil($clog2(L + 1)));
localparam MAX_G1_AB = (DELAY_G1_A > DELAY_G1_B) ? DELAY_G1_A : DELAY_G1_B;
localparam DELAY_G1  = (MAX_G1_AB > DELAY_G1_C) ? MAX_G1_AB : DELAY_G1_C;
localparam DELAY_G2  = DELAY_G2_A;


wire [LOGQH-1:0] qH;
wire [LOGQH-1:0] qH_D_int;
wire [LOGQ -1:0] half;
wire [LOGQ -1:0] q_inv;


wire [LOGL-1:0] ctr;
wire  ctr_inc;
wire  ctr_rst;
wire [LOGL-1:0] ctr_;


////////////////////////////// CTR //////////////////////////////////////////


assign ctr_inc = load_q_g2 && (ctr != (L));
assign ctr_rst = load_q_g2 && (ctr == (L));
assign ctr_    = (ctr == 0) ? L : ctr - 1;


counter #(
    .WIDTH   (LOGL),
    .AUTO_INC(0   )
) ctr_L_inst (
    .clk(clk),
    .rst(rst | ctr_rst),
    .inc(ctr_inc),
    .ctr(ctr)
);


///////////////////////////// MUXES /////////////////////////////////////////


relin_q_mux #(
    .LOGN(LOGN),
    .LOGL(LOGL),
    .LOGQ(LOGQ),
    .LOGQH(LOGQH)
) relin_q_mux_ABC_inst (
    .clk(clk),
    .rst(rst),
    .i(ctr_),
    .qH(qH)
);



relin_half_mux #(
    .LOGN(LOGN),
    .LOGL(LOGL),
    .LOGQ(LOGQ)
) relin_half_mux_inst (
    .clk(clk),
    .rst(rst),
    .i(ctr_),
    .half(half)
);


relin_q_inv_mux #(
    .LOGN(LOGN),
    .LOGL(LOGL),
    .LOGQ(LOGQ)
) relin_q_inv_mux_inst (
    .clk(clk),
    .rst(rst),
    .i(ctr_),
    .q_inv(q_inv)
);



/////////////////////////////////////////////// Group 1 /////////////////////////////////////////



shift_reg #(
    .LAT   (DELAY_G1_A),
    .WIDTH (1)
) load_q_shift_reg_0 (
    .clk    (clk),
    .rst    (rst),
    .i_data (load_q_g1),
    .o_data (load_q_g1_A)
);


shift_reg #(
    .LAT   (DELAY_G1_A),
    .WIDTH (LOGQH),
    .RST_EN(0)
) qH_shift_reg_0 (
    .clk    (clk),
    .i_data (qH),
    .o_data (qH_g1_A)
);


///////////////////////////////////////////////


shift_reg #(
    .LAT   (DELAY_G1_B),
    .WIDTH (1)
) load_q_shift_reg_1 (
    .clk    (clk),
    .rst    (rst),
    .i_data (load_q_g1),
    .o_data (load_q_g1_B)
);


shift_reg #(
    .LAT   (DELAY_G1_B),
    .WIDTH (LOGQH),
    .RST_EN(0)
) qH_shift_reg_1 (
    .clk    (clk),
    .i_data (qH),
    .o_data (qH_g1_B)
);


///////////////////////////////////////////////


shift_reg #(
    .LAT   (DELAY_G1_C),
    .WIDTH (1)
) load_q_shift_reg_2 (
    .clk    (clk),
    .rst    (rst),
    .i_data (load_q_g1),
    .o_data (load_q_g1_C)
);


shift_reg #(
    .LAT   (DELAY_G1_C),
    .WIDTH (LOGQH),
    .RST_EN(0)
) qH_shift_reg_2 (
    .clk    (clk),
    .i_data (qH),
    .o_data (qH_g1_C)
);





///////////////////////////////////////// Group 2 /////////////////////////////////////




shift_reg #(
    .LAT   (DELAY_G2_A),
    .WIDTH (1)
) load_q_shift_reg_3 (
    .clk    (clk),
    .rst    (rst),
    .i_data (load_q_g2),
    .o_data (load_q_g2_A)
);


shift_reg #(
    .LAT   (DELAY_G2_A),
    .WIDTH (LOGQH),
    .RST_EN(0)
) qH_shift_reg_3 (
    .clk    (clk),
    .i_data (qH),
    .o_data (qH_g2_A)
);


shift_reg #(
    .LAT   (DELAY_G2_A),
    .WIDTH (LOGQ),
    .RST_EN(0)
) half_shift_reg (
    .clk    (clk),
    .i_data (half),
    .o_data (half_g2_A)
);


shift_reg #(
    .LAT   (DELAY_G2_A),
    .WIDTH (LOGQ),
    .RST_EN(0)
) q_inv_shift_reg (
    .clk    (clk),
    .i_data (q_inv),
    .o_data (q_inv_g2_A)
);



///////////////////////////////////////// DONE SIGNALS /////////////////////////////////////////


shift_reg #(
    .LAT   (DELAY_G1),
    .WIDTH (1)
) done_g1_shift_reg (
    .clk    (clk),
    .rst    (rst),
    .i_data (load_q_g1),
    .o_data (done_g1)
);


shift_reg #(
    .LAT   (DELAY_G2),
    .WIDTH (1)
) done_g2_shift_reg (
    .clk    (clk),
    .rst    (rst),
    .i_data (load_q_g2),
    .o_data (done_g2)
);



endmodule