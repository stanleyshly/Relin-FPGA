`timescale 1ns / 1ps
module relin_final_op_wrapper
   #(
        parameter LOGK       = 10,
        parameter LOGQ       = 64,
        parameter LOGQH      = 48,
        parameter LOGTP      = 5 ,
        parameter FIFO_M     = 2 ,
        parameter EN_ADD     = 1 ,
        parameter FF_IN      = 1 ,
        parameter FF_MUL     = 1 ,
        parameter FF_SUM     = 0 ,
        parameter FF_SUB     = 0 ,
        parameter FF_ADDSUB  = 0 ,
        parameter USE_CSA    = 1 ,
        parameter FF_CSA     = 1 ,
        parameter MORE_DSP   = 0 ,
        parameter NON_STD    = 1 ,      
        parameter L          = 30,
        localparam TP = 1 << LOGTP
    )
    (
        input                   clk       ,
        input                   rst       ,
        input                   i_valid   ,
        input                   load_q    ,
        input      [LOGQH -1:0] qH        ,
        input      [LOGQ  -1:0] q_inv     ,
        input      [LOGQ  -1:0] halfmod   ,
        input      [LOGQ  -1:0] A [0:TP-1],
        input      [LOGQ  -1:0] B [0:TP-1],
        output                  i_done    ,
        output reg              o_valid   ,
        output reg [LOGQ  -1:0] C [0:TP-1]
    );


localparam LOGL = $rtoi($ceil($clog2(L + 1)));

localparam LOGN = LOGK + LOGTP;


wire [LOGL-1:0] ctr;
reg ctr_inc;
reg ctr_rst;

wire [LOGL-1:0] ctr_L;
reg ctr_L_inc;
reg ctr_L_rst;


reg last_q;
reg last_set;
reg last_rst;

reg i_done_int;

counter #(
    .WIDTH   (LOGL),
    .AUTO_INC(0   )
) ctr_inst (
    .clk(clk),
    .rst(rst | ctr_rst),
    .inc(ctr_inc      ),
    .ctr(ctr          )
);


counter #(
    .WIDTH   (LOGL),
    .AUTO_INC(0   )
) ctr_L_inst (
    .clk(clk),
    .rst(rst | ctr_L_rst),
    .inc(ctr_L_inc      ),
    .ctr(ctr_L          )
);


shift_reg #(
    .LAT   (1),
    .WIDTH (1)
)
i_done_shift_reg
(
    .clk    (clk),
    .rst    (rst),
    .i_data (i_done_int),
    .o_data (i_done    )
);


relin_final_op #(
    .LOGQ (LOGQ      ),
    .LOGQH(LOGQH     ),
    .LOGK (LOGK      ),
    .LOGTP(LOGTP     ),
    .EN_ADD(EN_ADD   ),
    .FF_IN(FF_IN     ),
    .FF_MUL(FF_MUL   ),
    .FF_SUM(FF_SUM   ),
    .FF_SUB(FF_SUB   ),
    .FF_ADDSUB(FF_ADDSUB),
    .FF_CSA(FF_CSA   ),
    .USE_CSA(USE_CSA ),
    .MORE_DSP(MORE_DSP),
    .NON_STD(NON_STD )
) relin_final_op_inst (
    .clk    (clk          ),
    .rst    (rst          ),
    .i_valid(i_valid      ),
    .last   (last_q       ),
    .load_q (load_q       ),
    .qH     (qH           ),
    .q_inv  (q_inv        ),
    .halfmod(halfmod      ),
    .A      (A            ),
    .B      (B            ),
    .C      (C            ),
    .o_valid(o_valid      )
);



always @(posedge clk) begin
    if (rst) begin
        last_q <= 1;
    end else if (last_set) begin
        last_q <= 1;
    end else if (last_rst) begin
        last_q <= 0;
    end
end


always @(*) begin
    ctr_rst = 0;
    ctr_inc = 0;
    last_set = 0;
    last_rst = 0;
    i_done_int = 0;
    if (i_valid) begin
        if (ctr == 1) begin
            ctr_rst = 1;
            if (ctr_L == L) begin
                last_set = 1;
            end else begin
                last_rst = 1;
            end
            i_done_int = 1;
        end else begin
            ctr_inc = 1;
        end
    end
end


endmodule