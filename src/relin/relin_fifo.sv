`timescale 1ns / 1ps
module relin_fifo
   #(   
        parameter K     = 1 ,
        parameter M     = 1 ,
        parameter TP    = 32,
        parameter LOGQ  = 64,
        localparam LOGK = $rtoi($ceil($clog2(K))),
        localparam LOGM = $rtoi($ceil($clog2(M)))
    )
    (
        input                       clk            ,
        input                       rst            ,
        input                       ren            ,
        input                       wen            ,
        output     [LOGK+LOGM-1:0]  ctr_i          ,
        input      [LOGQ     -1:0]  i_data [0:TP-1],
        output     [LOGK+LOGM-1:0]  ctr_o          ,
        output     [LOGQ     -1:0]  o_data [0:TP-1]
    );





wire bram_wen;
wire bram_ren;

wire [LOGQ*TP-1:0] bram_in;
wire [LOGQ*TP-1:0] bram_out;



assign bram_wen = wen | (|ctr_i[LOGK-1:0]);
assign bram_ren = ren | (|ctr_o[LOGK-1:0]);


counter #(
    .WIDTH (LOGK+LOGM),
    .AUTO_WIDTH (LOGK),
    .MAX   (K*M   - 1) 
) ctr_i_inst (
    .clk   (clk   ),
    .rst   (rst   ),
    .inc   (wen   ),
    .ctr   (ctr_i )
);

counter #(
    .WIDTH (LOGK+LOGM),
    .AUTO_WIDTH (LOGK),
    .MAX   (K*M - 1  )
) ctr_o_inst (
    .clk   (clk   ),
    .rst   (rst   ),
    .inc   (ren   ),
    .ctr   (ctr_o )
);


bram #(
    .WIDTH (LOGQ*TP),
    .LENGTH(K*M   ),
    .FF_OUT(1   )
) bram_inst (
    .clk  (clk      ),
    .wen  (bram_wen ),
    .waddr(ctr_i    ),
    .din  (bram_in  ),
    .raddr(ctr_o    ),
    .dout (bram_out )
);


for (genvar i = 0; i < TP; i = i + 1) begin
    assign bram_in[i*LOGQ +: LOGQ] = i_data[i];
end




for (genvar i = 0; i < TP; i = i + 1) begin : O_DATA_GEN
    assign o_data[i] = bram_out[i*LOGQ +: LOGQ];
end


endmodule