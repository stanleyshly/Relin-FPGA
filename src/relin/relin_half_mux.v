`timescale 1ns / 1ps
module relin_half_mux #(
    parameter LOGN = 16,
    parameter LOGL     = 30, // number of primes
    parameter LOGQ = 64
)(
    input                 clk,
    input                 rst,
    input      [LOGL-1:0] i  ,
    output     [LOGQ-1:0] half
);

localparam [LOGQ-1:0] HALF_VAL =
    (LOGQ == 60) ? (
        (LOGN == 12) ? 64'h0400d40000000000 :
        (LOGN == 13) ? 64'h0401900000000000 :
        (LOGN == 14) ? 64'h0402e40000000000 :
        (LOGN == 15) ? 64'h0405d40000000000 :
        (LOGN == 16) ? 64'h040a240000000000 :
                       64'h0400d40000000000
    ) :
    (LOGQ == 32) ? (
        (LOGN == 12) ? 32'h401a0000 : // floor(p/2), p=0x80340001, L=2
        (LOGN == 13) ? 32'h40430000 : 
        (LOGN == 14) ? 32'h40a00000 :
        (LOGN == 15) ? 32'h414c0000 : 
        (LOGN == 16) ? 32'h428f0000 :
                       32'h401a0000
    ) :
    {LOGQ{1'b0}};

assign half = HALF_VAL;



endmodule
