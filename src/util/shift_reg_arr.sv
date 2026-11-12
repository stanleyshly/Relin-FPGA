`timescale 1ns / 1ps
module shift_reg_arr
    #(   
        parameter LAT     = 1,
        parameter WIDTH   = 1,
        parameter LENGTH  = 0,
        parameter RST_EN  = 1
    )
    (
        input               clk                ,
        input               rst                ,
        input  [WIDTH-1:0]  i_data [0:LENGTH-1],
        output [WIDTH-1:0]  o_data [0:LENGTH-1]
    );

generate
    for (genvar i = 0; i < LENGTH; i = i + 1) begin
        shift_reg #(
            .LAT   (LAT   ),
            .WIDTH (WIDTH ),
            .RST_EN(RST_EN)
        ) shift_reg_inst (
            .clk   (clk      ),
            .rst   (rst      ),
            .i_data(i_data[i]),
            .o_data(o_data[i])
        );
    end
endgenerate


endmodule