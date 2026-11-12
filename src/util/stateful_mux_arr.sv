`timescale 1ns / 1ps
module stateful_mux_arr
    #(   
        parameter WIDTH   = 1,
        parameter LENGTH  = 0
    )
    (
        input                   clk                  ,
        input                   rst                  ,
        input                   sel_A                ,
        input                   sel_B                ,
        input      [WIDTH-1:0]  i_data_A [0:LENGTH-1],
        input      [WIDTH-1:0]  i_data_B [0:LENGTH-1],
        output reg [WIDTH-1:0]  o_data   [0:LENGTH-1]
    );


generate
    for (genvar i = 0; i < LENGTH; i = i + 1) begin
        stateful_mux #(
            .WIDTH(WIDTH)
        ) stateful_mux_inst (
            .clk      (clk        ),
            .rst      (rst        ),
            .sel_A    (sel_A      ),
            .sel_B    (sel_B      ),
            .i_data_A (i_data_A[i]),
            .i_data_B (i_data_B[i]),
            .o_data   (o_data  [i])
        );
    end
endgenerate


endmodule