`timescale 1ns / 1ps
module relin_cu_p0_ntt
   #(   
        parameter L               = 30,
        parameter ID_WIDTH        = 4,
        parameter DEPTH           = 128,
        localparam LOGL = $rtoi($ceil($clog2(L + 1)))
    )
    (
        input                     clk          ,
        input                     rst          ,
        input                     start        ,
        input                     i_p0_valid   ,
        input                     i_p0_done    ,
        output reg                i_p0_en      ,
        output reg [ID_WIDTH-1:0] i_p0_id      ,
        output reg [LOGL    -1:0] i_p0_idx     ,
        output reg                ntt_i_valid  ,
        output reg                psi_i_valid  ,
        output reg                psi_inv_i_valid  ,
        output reg                intt_ready

    );

`include "relin_mem.svh"




typedef enum reg[15:0] {
    ST_IDLE                      = 16'b0000000000000001,
    ST_LOAD_PSI_START            = 16'b0000000000000100,
    ST_LOAD_PSI_WAIT_DONE        = 16'b0000000000001000,
    ST_LOAD_POLY_START           = 16'b0000000000010000,
    ST_LOAD_POLY_WAIT_DONE       = 16'b0000000000100000,

    ST_WAIT_BEFORE_IPSI          = 16'b0010000000000000,
    ST_WAIT_BEFORE_PSI          = 16'b0001000000000000,

    ST_LOAD_IPSI_START           = 16'b0000000001000000,
    ST_LOAD_IPSI_WAIT_DONE       = 16'b0000000010000000,
    ST_INTT_READY                = 16'b0000001000000000
} t_state;

(* fsm_encoding = "none" *) t_state state;
t_state next_state;


localparam integer PSI_INV_WAIT_CYCLES = 4*DEPTH;
localparam integer WAITW = $clog2(PSI_INV_WAIT_CYCLES + 1);

localparam integer PSI_WAIT_CYCLES = 4*DEPTH;
localparam integer WAITW2 = $clog2(PSI_WAIT_CYCLES + 1);

reg  [WAITW-1:0] wait_ctr;
reg              wait_ctr_inc;
reg              wait_ctr_rst;

reg  [WAITW2-1:0] wait_ctr2;
reg              wait_ctr_inc2;
reg              wait_ctr_rst2;



wire [LOGL-1:0] ctr_L;
wire [LOGL-1:0] ctr_L_;
reg  ctr_L_inc;
reg  ctr_L_rst;

wire [LOGL-1:0] ctr_poly;
reg  ctr_poly_inc;
reg  ctr_poly_rst;


assign ctr_L_ = (ctr_L == 0) ? L : ctr_L - 1;


counter #(
    .WIDTH   (LOGL),
    .AUTO_INC(0   )
) ctr_inst (
    .clk(clk),
    .rst(rst | ctr_poly_rst),
    .inc(ctr_poly_inc),
    .ctr(ctr_poly)
);


counter #(
    .WIDTH   (LOGL),
    .AUTO_INC(0   )
) ctr_L_inst (
    .clk(clk),
    .rst(rst | ctr_L_rst),
    .inc(ctr_L_inc),
    .ctr(ctr_L)
);


always @(posedge clk) begin
    if (rst | wait_ctr_rst)
        wait_ctr <= '0;
    else if (wait_ctr_inc)
        wait_ctr <= wait_ctr + 1'b1;
end

always @(posedge clk) begin
    if (rst | wait_ctr_rst2)
        wait_ctr2 <= '0;
    else if (wait_ctr_inc2)
        wait_ctr2 <= wait_ctr2 + 1'b1;
end



always @(posedge clk) begin
    if (rst) begin
        state <= ST_IDLE;
    end
    else begin
        state <= next_state;
    end
end


always @(*) begin

    next_state = state;
    ctr_poly_inc = 1'b0;
    ctr_poly_rst = 1'b0;
    ctr_L_inc = 1'b0;
    ctr_L_rst = 1'b0;
    i_p0_en = 1'b0;
    i_p0_id = `POLY_2;
    i_p0_idx = ctr_L_;
    ntt_i_valid = 1'b0;
    psi_i_valid = 1'b0;
    psi_inv_i_valid = 1'b0;

    intt_ready = 1'b0;

    wait_ctr_inc = 1'b0;
    wait_ctr_rst = 1'b0;

    wait_ctr_inc2 = 1'b0;
    wait_ctr_rst2 = 1'b0;


    case (state)
        ST_IDLE: begin
            if (start) begin
                next_state = ST_WAIT_BEFORE_PSI;
            end
        end
        ST_WAIT_BEFORE_PSI: begin
            if (wait_ctr2 == PSI_WAIT_CYCLES - 1) begin
                next_state   = ST_LOAD_PSI_START;
                wait_ctr_rst2 = 1;
            end
            else begin
                wait_ctr_inc2 = 1;
            end
        end
        ST_LOAD_PSI_START: begin
            i_p0_id = `PSI;
            i_p0_idx = ctr_L_;
            i_p0_en = 1;
            next_state = ST_LOAD_PSI_WAIT_DONE;
        end
        ST_LOAD_PSI_WAIT_DONE: begin
            i_p0_id = `PSI;
            i_p0_idx = ctr_L_;
            psi_i_valid = i_p0_valid;
            if (i_p0_done) begin
                next_state = ST_LOAD_POLY_START;
            end
        end
        ST_LOAD_POLY_START: begin
            i_p0_id = `POLY_2;
            i_p0_idx = ctr_poly;
            i_p0_en = 1;
            next_state = ST_LOAD_POLY_WAIT_DONE;
        end
        ST_LOAD_POLY_WAIT_DONE: begin
            i_p0_id = `POLY_2;
            i_p0_idx = ctr_poly;            
            ntt_i_valid = i_p0_valid;
            if (i_p0_done) begin
                if (ctr_poly < (L - 1)) begin
                    next_state = ST_LOAD_POLY_START;
                    ctr_poly_inc = 1;
                end
                else begin
                    next_state   = ST_WAIT_BEFORE_IPSI;
                    ctr_poly_rst = 1;
                    wait_ctr_rst = 1;   // reset wait counter when entering wait state
                end
            end
        end
        ST_WAIT_BEFORE_IPSI: begin
            if (wait_ctr == PSI_INV_WAIT_CYCLES - 1) begin
                next_state   = ST_LOAD_IPSI_START;
                wait_ctr_rst = 1;
            end
            else begin
                wait_ctr_inc = 1;
            end
        end
        ST_LOAD_IPSI_START: begin
            i_p0_id = `PSI_INV;
            i_p0_idx = ctr_L_;
            i_p0_en = 1;
            next_state = ST_LOAD_IPSI_WAIT_DONE;
        end
        ST_LOAD_IPSI_WAIT_DONE: begin
            i_p0_id = `PSI_INV;
            i_p0_idx = ctr_L_;
            psi_inv_i_valid = i_p0_valid;
            if (i_p0_done) begin
                next_state = ST_INTT_READY;
            end
        end
        ST_INTT_READY: begin
            intt_ready = 1'b1;
            next_state = ST_IDLE;
            if (ctr_L == (L)) begin
                ctr_L_rst = 1;
            end
            else begin
                ctr_L_inc = 1;
            end
        end
    endcase
end


endmodule