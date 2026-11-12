`timescale 1ns / 1ps
module stateful_mux
    #(   
        parameter WIDTH = 1
    )
    (
        input                   clk     ,
        input                   rst     ,
        input                   sel_A   ,
        input                   sel_B   ,
        input      [WIDTH-1:0]  i_data_A,
        input      [WIDTH-1:0]  i_data_B,
        output reg [WIDTH-1:0]  o_data  
    );


typedef enum reg[1:0] {
    ST_A = 2'b01,
    ST_B = 2'b10
} t_state;

(* fsm_encoding = "none" *) t_state state;
t_state next_state;


reg ren;


always @(posedge clk) begin
    if (rst) begin
        state <= ST_A;
    end
    else begin
        state <= next_state;
    end
end


always @(*) begin

    o_data = i_data_A;
    next_state = state;

    case (state)
        ST_A: begin // todo: add default state
            if (sel_B) begin
                next_state = ST_B;
            end
        end
        ST_B: begin
            o_data = i_data_B;
            if (sel_A) begin
                next_state = ST_A;
            end
        end
    endcase
end


endmodule