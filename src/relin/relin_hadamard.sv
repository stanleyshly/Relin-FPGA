`timescale 1ns / 1ps
/*

    Computes T[i] = A[i] * B[i] mod q for i = 0 to TP-1

*/
module relin_hadamard
    #(
        parameter LOGQ     = 32,
        parameter LOGQH    = 15,
        parameter FF_IN    = 1 ,
        parameter FF_MUL   = 1 ,
        parameter FF_SUM   = 0 ,
        parameter FF_SUB   = 0 ,
        parameter FF_OUT   = 1 ,
        parameter USE_CSA  = 1 ,
        parameter FF_CSA   = 1 ,
        parameter MORE_DSP = 0 ,
        parameter NON_STD  = 1 ,
        parameter TP       = 32
    )
    (
        input               clk         ,
        input               rst         ,
        input               load_q      ,
        input               i_valid     ,
        input  [LOGQ  -1:0] A   [TP-1:0],
        input  [LOGQ  -1:0] B   [TP-1:0],
        input  [LOGQH -1:0] qH          ,
        output              o_valid     ,
        output [LOGQ - 1:0] C   [TP-1:0]
    );

`include "modmul_wlm.svh"



localparam W = LOGQ - LOGQH;

localparam modmul_wlm_params_t params = '{LOGQ, LOGQH, 1, FF_IN, FF_MUL, FF_SUM, FF_SUB, FF_OUT, USE_CSA, FF_CSA, MORE_DSP, NON_STD};
localparam LAT = modmul_wlm_lat(params);

reg [LOGQH -1:0] qH_int;

always @(posedge clk) begin
    if (rst) begin
        qH_int <= 0;
    end
    if (load_q) begin
        qH_int <= qH;
    end
end

for (genvar i = 0; i < TP; i++) begin
    modmul_wlm #(
        .LOGQ    (LOGQ    ),
        .LOGQH   (LOGQH   ),
        .CORRECT (1       ),
        .FF_IN   (FF_IN   ),
        .FF_MUL  (FF_MUL  ),
        .FF_SUM  (FF_SUM  ),
        .FF_SUB  (FF_SUB  ),
        .FF_OUT  (FF_OUT  ),
        .USE_CSA (USE_CSA ),
        .FF_CSA  (FF_CSA  ),
        .MORE_DSP(MORE_DSP),
        .NON_STD (NON_STD )
    ) modmul_inst (
        .clk(clk   ),
        .A  (A[i]  ),
        .B  (B[i]  ),
        .qH (qH_int),
        .T  (C[i]  )
    );
end


shift_reg #(
    .LAT   (LAT),
    .WIDTH (1),
    .RST_EN(1)
)
o_valid_shift_reg
(
    .clk    (clk),
    .rst    (rst),
    .i_data (i_valid),
    .o_data (o_valid)
);


endmodule