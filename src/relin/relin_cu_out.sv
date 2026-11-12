`timescale 1ns / 1ps
module relin_cu_out
   #(   
        parameter L           = 30,
        parameter ID_WIDTH    = 4// ,
, // parameter START_DELAY = 2
        localparam LOGL = $rtoi($ceil($clog2(L + 1)))
    )
    (
        input                     clk         ,
        input                     rst         ,
        // input                     start       ,
        input                     o_valid     ,
        input                     o_p3_done   ,
        output reg [ID_WIDTH-1:0] o_p3_id     ,
        output reg [LOGL    -1:0] o_p3_idx    ,
        output reg                o_p3_en     ,
        output reg                done      
    );

`include "relin_mem.svh"





typedef enum reg[10:0] {
    ST_IDLE                       = 11'b00000000001,
    ST_POLY_0_WRITE_START         = 11'b00000000010,
    ST_POLY_0_WRITE_WAIT_DONE     = 11'b00000000100,
    ST_POLY_1_WRITE_START         = 11'b00000001000,
    ST_POLY_1_WRITE_WAIT_DONE     = 11'b00000010000,
    ST_END                        = 11'b00000100000
} t_state;

(* fsm_encoding = "none" *) t_state state;
t_state next_state;


wire [LOGL-1:0] ctr;
reg  ctr_inc;
reg  ctr_rst;


counter #(
    .WIDTH   (LOGL),
    .AUTO_INC(0   )
) ctr_inst (
    .clk(clk),
    .rst(rst | ctr_rst),
    .inc(ctr_inc),
    .ctr(ctr)
);



always @(posedge clk) begin
    if (rst) begin
        state <= ST_POLY_0_WRITE_START;
    end
    else begin
        state <= next_state;
    end
end


always @(*) begin

    next_state  = state;
    done        = 1'b0;
    ctr_inc     = 1'b0;
    ctr_rst     = 1'b0;
    o_p3_en     = 1'b0;
    o_p3_id     = `POLY_0;
    o_p3_idx    = ctr;

    case (state)
        ST_POLY_0_WRITE_START: begin
            o_p3_id = `POLY_0;
            if (o_valid) begin
                o_p3_en = 1'b1;
                next_state = ST_POLY_0_WRITE_WAIT_DONE;                    
            end
        end
        ST_POLY_0_WRITE_WAIT_DONE: begin
            o_p3_id = `POLY_0;
            if (o_p3_done) begin
                next_state = ST_POLY_1_WRITE_START;
            end
        end
        ST_POLY_1_WRITE_START: begin
            o_p3_id = `POLY_1;
            if (o_valid) begin
                o_p3_en = 1'b1;
                next_state = ST_POLY_1_WRITE_WAIT_DONE;                    
            end
        end
        ST_POLY_1_WRITE_WAIT_DONE: begin
            o_p3_id = `POLY_1;
            if (o_p3_done) begin
                next_state = ST_END;
            end
        end
        ST_END: begin
            next_state = ST_POLY_0_WRITE_START;
            done       = 1;
            if (ctr == (L - 1)) begin
                ctr_rst     = 1;
            end
            else begin
                ctr_inc = 1;
            end
        end
    endcase
end


endmodule