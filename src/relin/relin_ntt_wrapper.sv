`timescale 1ns / 1ps
`include "tp_ntt.svh"

module ntt_wrapper
#(
    parameter LOGQ     = 64,
    parameter LOGQH    = 17,
    parameter LOGN     = 16,
    parameter LOGTP    = 5,
    // Defaults preserve the relinearization configurations. The standalone
    // benchmark may explicitly select the core's supported 1024=32*32 case.
    parameter LOGN1    = LOGTP,
    parameter LOGN2    = LOGQ == 32 ? (LOGN == 12) ? LOGTP : (LOGN == 13 || LOGN == 14 || LOGN == 15 || LOGN == 16) ? LOGN - 2*LOGN1 : 0 : (LOGN == 12 || LOGN == 13 || LOGN == 14 || LOGN == 15) ? LOGN - 2*LOGN1 : 1,
    parameter LOGN3    = LOGQ == 32 ? (LOGN == 12) ? 0 : (LOGN == 13 || LOGN == 14 || LOGN == 15 || LOGN == 16) ? LOGTP : 0 : LOGTP,
        localparam TP = 1 << LOGTP
)
(
    input              clk                  ,
    input              rst                  ,
    input              load_q               ,
    input              load_psi             ,
    input              intt                 ,
    input  [LOGQH-1:0] qH                   ,
    input              i_valid              ,
    input  [LOGQ -1:0] i_poly       [0:TP-1],
    input  [LOGQ -1:0] psi          [0:TP-1],
    output             o_valid              ,
    output [LOGQ -1:0] o_poly       [0:TP-1]
);





localparam tp_ntt_params_t tp_ntt_params = '{LOGN, LOGN1, LOGN2, LOGN3, LOGTP, LOGQ, LOGQH, 1, 0};
localparam LAT = tp_ntt_lat(tp_ntt_params) + (1 << (LOGN - LOGTP)) + 2;

// Simulation-only per-transform timing. Data and scheduling are unchanged.
`ifndef SYNTHESIS
integer profile_inputs = 0;
integer profile_outputs = 0;
integer profile_started = 0;
integer profile_finished = 0;
realtime profile_start [0:1023];
reg profile_inverse [0:1023];
always @(posedge clk) begin
    if (rst) begin
        profile_inputs = 0;
        profile_outputs = 0;
        profile_started = 0;
        profile_finished = 0;
    end else if ($test$plusargs("RELIN_PROFILE")) begin
        if (i_valid) begin
            if ((profile_inputs % (1 << (LOGN - LOGTP))) == 0) begin
                if (profile_started >= 1024) $fatal(1, "NTT profiler capacity exceeded");
                profile_start[profile_started] = $realtime;
                profile_inverse[profile_started] = intt;
                if (profile_started > 0)
                    $display("NTT_PROFILE_START: op=%0d inverse=%0d interval_ns=%0.3f", profile_started,
                             intt, $realtime - profile_start[profile_started-1]);
                profile_started = profile_started + 1;
            end
            profile_inputs = profile_inputs + 1;
        end
        if (o_valid) begin
            profile_outputs = profile_outputs + 1;
            if ((profile_outputs % (1 << (LOGN - LOGTP))) == 0) begin
                if (profile_finished >= profile_started) $fatal(1, "Unmatched NTT output");
                $display("NTT_PROFILE_RESULT: op=%0d inverse=%0d n=%0d tp=%0d latency_ns=%0.3f", profile_finished,
                         profile_inverse[profile_finished], (1 << LOGN), TP,
                         $realtime - profile_start[profile_finished]);
                profile_finished = profile_finished + 1;
            end
        end
    end
end
`endif



reg start;
tp_ntt_op_t op;
wire [LOGQ-1:0]  i_poly_d [0:TP-1];
wire [LOGQ-1:0]  psi_d    [0:TP-1];
wire [LOGQH-1:0] qH_d;
wire [TP*LOGQ-1:0] flat_i_poly;
wire [(TP)*LOGQ-1:0] flat_psi;
wire [TP*LOGQ-1:0] flat_o_poly;



for (genvar i = 0; i < TP; i = i + 1) begin
    assign flat_i_poly[i*LOGQ +: LOGQ] = i_poly_d[TP - i - 1];
end

for (genvar i = 0; i < TP; i = i + 1) begin
    assign flat_psi[i*LOGQ +: LOGQ] = psi_d[TP - i - 1];
end

for (genvar i = 0; i < TP; i = i + 1) begin
    assign o_poly[TP - i - 1] = flat_o_poly[i*LOGQ +: LOGQ];
end



always @(posedge clk) begin
    if (rst) begin
        start <= 0;
        op    <= OP_LOAD_Q; // OP_RFU
    end else begin
        if (load_q) begin
            op    <= OP_LOAD_Q; // OP_LOAD_Q
        end else if (load_psi) begin
            op    <= OP_LOAD_TWIDDLE; // OP_LOAD_TWIDDLE
        end else if (i_valid) begin
            start <= 1;
            op    <= OP_NTT; // OP_NTT
        end else begin
            start <= 0;
            op    <= OP_NTT; // OP_NTT
        end
    end
end



shift_reg #(
    .LAT    (LAT),
    .WIDTH  (1),
    .RST_EN (1)
) o_valid_shift_reg (
    .clk    (clk),
    .rst    (rst),
    .i_data (i_valid),
    .o_data (o_valid)
);


shift_reg_arr #(
    .LAT    (2),
    .WIDTH  (LOGQ),
    .LENGTH (TP)
) i_poly_delay (
    .clk    (clk),
    .rst    (rst),
    .i_data (i_poly),
    .o_data (i_poly_d)
);


shift_reg_arr #(
    .LAT    (2),
    .WIDTH  (LOGQ),
    .LENGTH (TP)
) psi_delay (
    .clk    (clk),
    .rst    (rst),
    .i_data (psi),
    .o_data (psi_d)
);


shift_reg #(
    .LAT    (2),
    .WIDTH  (LOGQH),
    .RST_EN (1)
) qH_delay (
    .clk    (clk),
    .rst    (rst),
    .i_data (qH),
    .o_data (qH_d)
);

tp_ntt_top_w_shuffle #(
        .LOGN    (tp_ntt_params.LOGN    ),
        .LOGN1   (tp_ntt_params.LOGN1   ),
        .LOGN2   (tp_ntt_params.LOGN2   ),
        .LOGN3   (tp_ntt_params.LOGN3   ),
        .LOGTP   (tp_ntt_params.LOGTP   ),
        .LOGQ    (tp_ntt_params.LOGQ    ),
        .LOGQH   (tp_ntt_params.LOGQH   ),
        .NON_STD (tp_ntt_params.NON_STD ),
        .MORE_DSP(tp_ntt_params.MORE_DSP)
    ) uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .op(op),
        .intt(intt),
        .shuffle_mod(1'b0),
        .qH(qH_d),
        .i_poly(flat_i_poly),
        .psi(flat_psi),
        .o_poly(flat_o_poly)
    );


endmodule
