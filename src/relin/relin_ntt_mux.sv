`timescale 1ns / 1ps
module relin_ntt_mux
   #(   
        parameter LOGQ           = 64,
        parameter LOGQH          = 17,
        parameter LOGN           = 16,
        parameter LOGTP          = 5 ,
        parameter INTT_DELAY     = 2 ,
        parameter PSI_CC        = (1 << (LOGN - LOGTP)),
        localparam TP = 1 << LOGTP
    )
    (
        input              clk                  ,
        input              rst                  ,
        input              load_q               ,
        input              psi_valid            ,
        input              psi_inv_valid        ,
        input              feed_psi             ,
        input  [LOGQH-1:0] qH                   ,
        input              i_valid_ntt          ,
        input              i_valid_intt         ,
        input  [LOGQ -1:0] i_poly_ntt   [0:TP-1],
        input  [LOGQ -1:0] i_poly_intt  [0:TP-1],
        input  [LOGQ -1:0] psi          [0:TP-1],
        output             o_valid_ntt          ,
        output             o_valid_intt         ,
        output reg         psi_r_done           ,
        output [LOGQ -1:0] o_poly       [0:TP-1]
    );



localparam LOGK = (LOGN - LOGTP);

wire [LOGQ-1:0] i_poly [0:TP-1];
wire [LOGQ-1:0] i_poly_intt_d [0:TP-1];
wire i_valid_intt_d;
wire i_valid;
wire o_valid;

reg intt_q;

wire intt;

wire psi_valid_t;

shift_reg_arr #(
    .LAT    (INTT_DELAY),
    .WIDTH  (LOGQ      ),
    .LENGTH (TP        ),
    .RST_EN (0         )
) i_poly_intt_A_shift_reg (
    .clk    (clk          ),
    .rst (rst),
    .i_data (i_poly_intt  ),
    .o_data (i_poly_intt_d)
);


shift_reg #(
    .LAT   (INTT_DELAY),
    .WIDTH (1         )
) i_valid_intt_shift_reg (
    .clk    (clk          ),
    .rst    (rst          ),
    .i_data (i_valid_intt ),
    .o_data (i_valid_intt_d)
);


assign i_poly  = intt ? i_poly_intt_d  : i_poly_ntt;
assign i_valid = i_valid_intt_d | i_valid_ntt;

assign intt = i_valid_intt_d | intt_q;

assign o_valid_ntt  = o_valid & (~intt_q);
assign o_valid_intt = o_valid &   intt_q ;


assign psi_valid_t = psi_inv_valid | psi_valid;


ntt_wrapper #(
    .LOGQ (LOGQ ),
    .LOGQH(LOGQH),
    .LOGN (LOGN ),
    .LOGTP(LOGTP)
) ntt_wrapper_inst (
    .clk     (clk     ),
    .rst     (rst     ),
    .load_q  (load_q  ),
    .load_psi(psi_valid_t  ),
    .intt    (intt    ),
    .qH      (qH      ),
    .i_valid (i_valid ),
    .i_poly  (i_poly  ),
    .psi     (psi     ),
    .o_valid (o_valid ),
    .o_poly  (o_poly  )
);


always @(posedge clk) begin
    if (rst) begin
        intt_q <= 0;
    end
    else begin
        if (i_valid_intt_d)
            intt_q <= 1;
        else if(psi_inv_valid)
            intt_q <= 1;
        else if (i_valid_ntt)
            intt_q <= 0;
        else if (psi_valid)
            intt_q <= 0;
    end
end


endmodule