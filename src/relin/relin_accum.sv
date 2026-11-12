`timescale 1ns / 1ps
module relin_accum 
   #(
        parameter LOGK      = 10,
        parameter LOGQ      = 60,   
        parameter LOGQH     = 47,
        parameter FF_ADD    = 0 ,
        parameter LOGTP     = 32,
        localparam TP = (1 << LOGTP)
    )
    (
        input              clk       ,
        input              rst       ,
        input              first     ,
        input              ren       ,
        input              wen       ,
        input              load_q    ,
        input  [LOGQH-1:0] qH        ,
        output             o_valid   ,
        output             done      ,
        input  [LOGQ -1:0] A [TP-1:0],
        output [LOGQ -1:0] C [TP-1:0],
        output            wdone     ,
        output            rdone     
    );

///////////////////////////// Parameters ////////////////////////////////


localparam K        = (1 << LOGK);
localparam FF_IN    = 1;
localparam FF_OUT   = 1;
localparam ADD_LAT  = FF_ADD + FF_OUT;

/////////////////////////////////////////////////////////////////////////

///////////////////////// Signal Declarations ///////////////////////////

reg  [LOGQH-1:0] qH_int;
reg  [LOGQ -1:0] A_q          [TP-1:0];

wire [LOGQ -1:0] modadd_in_B  [TP-1:0];
wire [LOGQ -1:0] modadd_out   [TP-1:0];

wire [TP*LOGQ -1:0] bram_in ;
wire [TP*LOGQ -1:0] bram_out;

wire  [LOGK -1:0] read_addr;
wire  [LOGK -1:0] write_addr;
wire  bram_wen;
wire start_read, start_write;

reg  first_q;

/////////////////////////////////////////////////////////////////////////

for (genvar i = 0; i < TP; i++) begin : OUT_GEN
    assign C[i] = bram_out[i*LOGQ +: LOGQ];
end

for (genvar i = 0; i < TP; i++) begin : IN_GEN
    assign modadd_in_B[i] = (first_q) ? {LOGQ{1'b0}} : bram_out[i*LOGQ +: LOGQ];
end

for (genvar i = 0; i < TP; i++) begin : BRAM_IN_GEN
    assign bram_in[i*LOGQ +: LOGQ] = modadd_out[i];
end

assign start_read = ren || (wen && (~first));
assign bram_wen   = start_write || (|write_addr);
assign wdone      = write_addr == {LOGK{1'b1}};
assign rdone      = (read_addr == {LOGK{1'b1}}) && (write_addr == {LOGK{1'b0}}); // write not in progress
assign done       = wdone || rdone;

////////////////////// Modular addition instances ///////////////////////////

// Modular addition instances
for (genvar i = 0; i < TP; i++) begin : MODADD_GEN
    modadd #(
        .LOGQ  (LOGQ  ),
        .LOGQH (LOGQH ),
        .FF_IN (0     ),
        .FF_ADD(FF_ADD),
        .FF_OUT(FF_OUT)
    ) mod_adder_inst (
        .clk(clk          ),
        .A  (A_q[i]       ),
        .B  (modadd_in_B[i]),
        .qH (qH_int       ), 
        .C  (modadd_out[i])
    );
end

/////////////////////////////////////////////////////////////////////////

bram #(
    .WIDTH (LOGQ*TP),
    .LENGTH(K      )
) bram_inst (
    .clk  (clk          ),
    .wen  (bram_wen     ),
    .waddr(write_addr   ), 
    .din  (bram_in      ),
    .raddr(read_addr    ),
    .dout (bram_out     )
);

/////////////////////////////////////////////////////////////////////////


shift_reg #(
    .LAT   (1),
    .WIDTH (1),
    .RST_EN(1)
)
o_valid_shift_reg
(
    .clk    (clk),
    .rst    (rst),
    .i_data (ren),
    .o_data (o_valid)
);


shift_reg #(
    .LAT   (ADD_LAT + 1),
    .WIDTH (1          ),
    .RST_EN(1          )
)
wen_d_shift_reg
(
    .clk    (clk),
    .rst    (rst),
    .i_data (wen),
    .o_data (start_write)
);



counter #(
    .WIDTH(LOGK)
) ctr_read_inst (
    .clk   (clk       ),
    .rst   (rst       ),
    .inc   (start_read),
    .ctr   (read_addr )
);


counter #(
    .WIDTH(LOGK)
) ctr_write_inst (
    .clk   (clk        ),
    .rst   (rst        ),
    .inc   (start_write),
    .ctr   (write_addr )
);


always @(posedge clk) begin
    if (rst) begin
        qH_int <= 0;
    end else if (load_q) begin
        qH_int <= qH;
    end
end


always @(posedge clk) begin
    A_q <= A;
end


always @(posedge clk) begin
    if (rst) begin
        first_q <= 0;
    end
    else if (first) begin
        first_q <= 1;
    end
    else if (wdone) begin
        first_q <= 0;
    end
end


/////////////////////////////////////////////////////////////////////////


endmodule
