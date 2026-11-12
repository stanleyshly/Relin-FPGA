`timescale 1ns / 1ps
module shift_reg
    #(   
        parameter LAT     = 1,
        parameter WIDTH   = 1,
        parameter RST_EN  = 1
    )
    (
        input               clk   ,
        input               rst   ,
        input  [WIDTH-1:0]  i_data,
        output [WIDTH-1:0]  o_data
    );


reg [WIDTH-1:0] data [0:LAT-1];


if (LAT == 0) begin

    assign o_data = i_data;

end
else begin


    always @(posedge clk) begin
        data[0] <= (RST_EN && rst) ? {WIDTH{1'b0}} : i_data;
    end

    for (genvar i = 1; i < LAT; i++) begin
        always @(posedge clk) begin
                data[i] <= (RST_EN && rst) ? {WIDTH{1'b0}} : data[i - 1];
        end
    end

    assign o_data = data[LAT - 1];

end


endmodule