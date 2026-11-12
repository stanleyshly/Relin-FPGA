`timescale 1ns / 1ps
module relin_accum_wrapper 
   #(
        parameter L         = 30,
        parameter LOGK      = 7,
        parameter LOGQ      = 60,
        parameter LOGQH     = 17,
        parameter FF_ADD    = 0 ,
        parameter LOGTP     = 5 ,
        parameter READ_DELAY  = 10, // between two reads
        parameter START_DELAY = 2, // for start_read and write_done
        localparam TP = (1 << LOGTP)

    )
    (
        input              clk              ,
        input              rst              ,
        input              start_read       ,
        input              load_q           ,
        input  [LOGQH-1:0] qH               ,
        input  [LOGQ -1:0] i_poly_0 [0:TP-1],
        input  [LOGQ -1:0] i_poly_1 [0:TP-1],
        input              i_valid_0        ,
        input              i_valid_1        ,
        output [LOGQ -1:0] o_poly   [0:TP-1],
        output             o_valid
    );




localparam LOGL = $rtoi($ceil($clog2(L + 1)));


////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////// FSM FOR INPUT DATA /////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

typedef enum reg[4:0] {
    ST_NTT                      = 5'b00001,
    ST_NTT2                     = 5'b00101,
    ST_NTT3                     = 5'b00111,
    ST_INTT_0                   = 5'b00010,
    ST_INTT_1                   = 5'b00100,
    ST_INTT_2                   = 5'b01000,
    ST_INTT_3                   = 5'b10000
} t_state_i;


(* fsm_encoding = "none" *) t_state_i state_i;
t_state_i next_state_i;


wire [LOGL-1:0] ctr_0;
wire [LOGL-1:0] ctr_1;
reg  ctr_0_inc;
reg  ctr_0_rst;
reg  ctr_1_inc;
reg  ctr_1_rst;

reg  ren_0;
reg  ren_1;
wire ren_1_d;

wire done_0;
wire done_1;

wire first_0;
wire first_1;

wire start_read_d;
reg start_read_q;
reg start_read_clr;

// reg write_done_int;

shift_reg #(
    .LAT   (START_DELAY),
    .WIDTH (1)
)
start_read_shift_reg
(
    .clk    (clk),
    .rst    (rst),
    .i_data (start_read  ),
    .o_data (start_read_d)
);


shift_reg #(
    .LAT   (READ_DELAY),
    .WIDTH (1)
)
ren_shift_reg
(
    .clk    (clk),
    .rst    (rst),
    .i_data (ren_1  ),
    .o_data (ren_1_d)
);


counter #(
    .WIDTH   (LOGL),
    .AUTO_INC(0   )
) ctr_inst_0 (
    .clk(clk),
    .rst(rst | ctr_0_rst),
    .inc(ctr_0_inc),
    .ctr(ctr_0)
);


counter #(
    .WIDTH   (LOGL),
    .AUTO_INC(0   )
) ctr_inst_1 (
    .clk(clk),
    .rst(rst | ctr_1_rst),
    .inc(ctr_1_inc),
    .ctr(ctr_1)
);


always @(posedge clk) begin
    if (rst) begin
        state_i <= ST_NTT;
    end
    else begin
        state_i <= next_state_i;
    end
end


always @(posedge clk) begin
    if (rst) begin
        start_read_q <= 1'b0;
    end
    else if (start_read_d) begin
        start_read_q <= 1'b1;
    end
    else if (start_read_clr) begin
        start_read_q <= 1'b0;
    end
end



assign first_0 = i_valid_0 && (ctr_0 == {LOGL{1'b0}});
assign first_1 = i_valid_1 && (ctr_1 == {LOGL{1'b0}});


always @(*) begin

    next_state_i = state_i;
    // write_done_int = 1'b0;
    ctr_0_inc = 1'b0;
    ctr_0_rst = 1'b0;
    ctr_1_inc = 1'b0;
    ctr_1_rst = 1'b0;

    ren_0 = 1'b0;
    ren_1 = 1'b0;

    start_read_clr = 1'b0;

    case (state_i)
        ST_NTT: begin
            if ((ctr_0 == L) && (ctr_1 == L)) begin
                next_state_i = ST_INTT_1;
                ctr_0_rst = 1;
                ctr_1_rst = 1;
            end
            else begin
                if (done_0 && (ctr_0 < L)) begin
                    ctr_0_inc = 1'b1;
                end
                if (done_1 && (ctr_1 < L)) begin
                    ctr_1_inc = 1'b1;
                end
            end
        end
        ST_INTT_1: begin
            if (start_read_q) begin
                ren_0 = 1;
                next_state_i = ST_INTT_2;
                start_read_clr = 1'b1;
            end
        end
        ST_INTT_2: begin
            if (done_0) begin
                ren_1 = 1;
                next_state_i = ST_INTT_3;
            end
        end
        ST_INTT_3: begin
            if (done_1) begin
                next_state_i = ST_NTT;
            end
        end
    endcase
end


////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////// ACCUMULATOR INSTANCES //////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////


wire [LOGQ -1:0] o_poly_0 [0:TP-1];
wire [LOGQ -1:0] o_poly_1 [0:TP-1];
wire o_valid_0;
wire o_valid_1;

relin_accum #(
    .LOGK     (LOGK     ),
    .LOGQ     (LOGQ     ),
    .LOGQH    (LOGQH    ),
    .FF_ADD   (FF_ADD   ),
    .LOGTP    (LOGTP    )
) relin_accum_inst_0 (
    .clk      (clk      ),
    .rst      (rst      ),
    .first    (first_0  ),
    .ren      (ren_0    ),
    .wen      (i_valid_0),
    .load_q   (load_q   ),
    .qH       (qH       ),
    .o_valid  (o_valid_0),
    .done     (done_0   ),
    .A        (i_poly_0 ),
    .C        (o_poly_0 ),
    .wdone    (wdone0   ),
    .rdone    (rdone0   )
);


relin_accum #(
    .LOGK     (LOGK     ),
    .LOGQ     (LOGQ     ),
    .LOGQH    (LOGQH    ),
    .FF_ADD   (FF_ADD   ),
    .LOGTP    (LOGTP    )
) relin_accum_inst_1 (
    .clk      (clk      ),
    .rst      (rst      ),
    .first    (first_1  ),
    .ren      (ren_1_d  ),
    .wen      (i_valid_1),
    .load_q   (load_q   ),
    .qH       (qH       ),
    .o_valid  (o_valid_1),
    .done     (done_1   ),
    .A        (i_poly_1 ),
    .C        (o_poly_1 ),
    .wdone    (wdone1   ),
    .rdone    (rdone1   )
);

///////////////////////////////////////////////////
// ren, done, first, wen are used by input FSM
// o_valid and C are used by output FSM
// A, wen, load_q, qH are module inputs
///////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////// FSM FOR OUTPUT DATA ////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////


typedef enum reg[1:0] {
    ST_0                      = 2'b01,
    ST_1                      = 2'b10
} t_state_o;


(* fsm_encoding = "none" *) t_state_o state_o;
t_state_o next_state_o;

wire [LOGQ -1:0] o_poly_0_d [0:TP-1];
wire [LOGQ -1:0] o_poly_1_d [0:TP-1];
wire o_valid_0_d;
wire o_valid_1_d;


shift_reg_arr #(
    .LAT    (1   ),
    .WIDTH  (LOGQ),
    .LENGTH (TP  ),
    .RST_EN (0   )    
) o_poly_shift_reg_0 (
    .clk    (clk       ),
    .rst (rst),
    .i_data (o_poly_0  ),
    .o_data (o_poly_0_d)
);


shift_reg_arr #(
    .LAT    (1   ),
    .WIDTH  (LOGQ),
    .LENGTH (TP  ),
    .RST_EN (0   )    
) o_poly_shift_reg_1 (
    .clk    (clk       ),
    .rst (rst),
    .i_data (o_poly_1  ),
    .o_data (o_poly_1_d)
);



shift_reg #(
    .LAT    (1   ),
    .WIDTH  (1)
) o_valid_shift_reg_0 (
    .clk    (clk       ),
    .rst    (rst       ),
    .i_data (o_valid_0 ),
    .o_data (o_valid_0_d)
);


shift_reg #(
    .LAT    (1   ),
    .WIDTH  (1)
) o_valid_shift_reg_1 (
    .clk    (clk       ),
    .rst    (rst       ),
    .i_data (o_valid_1 ),
    .o_data (o_valid_1_d)
);



assign o_poly  = (state_o == ST_1) ? o_poly_1_d   : o_poly_0_d ;
assign o_valid = (state_o == ST_1) ? o_valid_1_d  : o_valid_0_d;


always @(posedge clk) begin
    if (rst) begin
        state_o <= ST_0;
    end
    else begin
        state_o <= next_state_o;
    end
end


always @(*) begin

    next_state_o = state_o;

    case (state_o)
        ST_0: begin
            if (o_valid_1) begin
                next_state_o = ST_1;
            end
        end
        ST_1: begin
            if (o_valid_0) begin
                next_state_o = ST_0;
            end
        end
    endcase
end

endmodule