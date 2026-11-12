`timescale 1ns / 1ps
module bram
   #(
        parameter WIDTH  = 32  ,
        parameter LENGTH = 1024,
        parameter FF_OUT = 1,
        parameter DEPTH = (LENGTH > 1) ? $clog2(LENGTH) : 1
    )
    (   input                  clk,
        input                  wen,
        input      [DEPTH-1:0] waddr,
        input      [WIDTH-1:0] din,
        input      [DEPTH-1:0] raddr,
        output     [WIDTH-1:0] dout
    );





wire [WIDTH-1:0] dout_int;
reg  [WIDTH-1:0] dout_q;


/*(* ram_style="block" *) */reg [WIDTH-1:0] blockram [LENGTH-1:0] = '{default: {WIDTH{1'b0}}};;


always @(posedge clk) begin
    if(wen)
        blockram[waddr] <= din;
end


assign dout_int = blockram[raddr];


if (FF_OUT) begin
    always @(posedge clk) begin
        dout_q <= dout_int;
    end
    assign dout = dout_q;
end else begin
    assign dout = dout_int;
end


endmodule