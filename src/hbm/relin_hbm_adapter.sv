`timescale 1ns / 1ps
`include "relin_if.svh"
`include "relin_mem.svh"
`include "axi.sv"

module relin_hbm_adapter
   #(
        parameter L              = 30,
        parameter LOGN           = 1 ,
        parameter LOGTP          = 32,
        parameter LOGQ           = 64,
        parameter PSI_CC        = (1 << (LOGN - LOGTP)),
        parameter HBM_ADDR_WIDTH = 64,
        parameter HBM_DATA_WIDTH = 256,
        localparam HBM_PCI_COUNT = 24,
        localparam HBM_PCO_COUNT = 8,
        localparam HBM_PC_COUNT = HBM_PCI_COUNT + HBM_PCO_COUNT

    )
    (
        input              clk     ,
        input              rst     ,
        input              start   ,
        input [HBM_ADDR_WIDTH-1:0] dma_address [0:HBM_PC_COUNT-1],
        relin_t.slave      relin_t ,
        axi4_t.master      m_axi [0:HBM_PC_COUNT-1]
    );
reg i_p0_done_int;
reg i_p1_done_int;
reg i_p2_done_int;
reg o_p3_done_int;

/////////////////////////////// parameters //////////////////////////////

localparam PSI_NUM = PSI_CC << LOGTP;
localparam TP = 1 << LOGTP;




// A burst must fit both a polynomial and a twiddle stream on each port.
localparam RAW_POLY_BEATS = (((1 << LOGN) * ((LOGQ <= 32) ? 32 : 64)) / 64) * 8 / HBM_DATA_WIDTH;
localparam MIN_STREAM_BEATS = RAW_POLY_BEATS < PSI_CC ? RAW_POLY_BEATS : PSI_CC;
localparam HBM_BURST_LEN = MIN_STREAM_BEATS < 128 ? MIN_STREAM_BEATS : 128;
localparam LOG_HBM_BURST_NUM  = $clog2(HBM_BURST_LEN);
localparam LOG_HBM_BURST_SIZE = $clog2(HBM_BURST_LEN * (HBM_DATA_WIDTH >> 3));
localparam HBM_LAT        = 20;

localparam FIFO_WIDTH     = 256;

localparam N = 1 << LOGN;
localparam LOGQ_ = (LOGQ <= 32) ? 32 : 64;
localparam QBYTES = (LOGQ == 32) ? 4 : 8;

localparam TPPC = TP / 8;

localparam POLY_SINGLE_PC_SIZE = ((N * LOGQ_) / 8) / 8; // in Bytes
localparam POLY_CC             = (POLY_SINGLE_PC_SIZE * 8) / HBM_DATA_WIDTH;
localparam POLY_BURST_NUM       = POLY_CC / HBM_BURST_LEN;
localparam LOG_POLY_BURST_NUM   = $clog2(POLY_BURST_NUM);
localparam LOG_POLY_SINGLE_PC_SIZE = $clog2(POLY_SINGLE_PC_SIZE);
localparam PSI_SINGLE_PC_SIZE = ((PSI_NUM * LOGQ_) / 8) / 8; // in Bytes
localparam LOG_PSI_SINGLE_PC_SIZE = $clog2(PSI_SINGLE_PC_SIZE);
localparam PSI_BURST_NUM       = PSI_CC / HBM_BURST_LEN;
localparam LOG_PSI_BURST_NUM   = $clog2(PSI_BURST_NUM);

localparam POLY_2_PC_SIZE      = POLY_SINGLE_PC_SIZE * L;
localparam PSI_ADDR_OFFSET     = POLY_2_PC_SIZE;
localparam PSI_PC_SIZE         = PSI_SINGLE_PC_SIZE * (L + 1);
localparam PSI_INV_ADDR_OFFSET = PSI_ADDR_OFFSET + PSI_PC_SIZE;

localparam RLK_0_PC_SIZE      = POLY_SINGLE_PC_SIZE * L * (L + 1);
localparam POLY_0_ADDR_OFFSET = RLK_0_PC_SIZE;
localparam POLY_1_PC_SIZE     = POLY_2_PC_SIZE;
localparam POLY_1_ADDR_OFFSET = POLY_0_ADDR_OFFSET + POLY_1_PC_SIZE;

localparam POLY_1_ADDR_OFFSET_W = POLY_1_ADDR_OFFSET - POLY_0_ADDR_OFFSET;

localparam LOGCTRD = (PSI_CC > POLY_CC) ? $clog2(PSI_CC) : $clog2(POLY_CC);
localparam LOGCTRA_RAW = (PSI_CC > POLY_CC) ? LOG_PSI_BURST_NUM : LOG_POLY_BURST_NUM;
localparam LOGCTRA = LOGCTRA_RAW < 1 ? 1 : LOGCTRA_RAW;
`ifndef SYNTHESIS
initial begin
    if (HBM_BURST_LEN < 1 || (POLY_CC % HBM_BURST_LEN) != 0 || (PSI_CC % HBM_BURST_LEN) != 0)
        $fatal(1, "HBM burst length must divide polynomial and twiddle streams");
    $display("HBM_CONFIG: burst_beats=%0d poly_beats=%0d poly_bursts=%0d psi_bursts=%0d", HBM_BURST_LEN, POLY_CC, POLY_BURST_NUM, PSI_BURST_NUM);
end
`endif

localparam FIFO_READ_LAT_PSI  = (PSI_BURST_NUM  - 1) * HBM_LAT; // number of cycles to read from the fifo
localparam FIFO_READ_LAT_POLY = (POLY_BURST_NUM - 1) * HBM_LAT; // number of cycles to read from the fifo

localparam int PREFILL = (1 << (LOGN - LOGTP));

typedef enum reg[5:0] {
    ST_IDLE       = 6'b000001,
    ST_RW_SINGLE  = 6'b000010,
    ST_RW_MANY_0  = 6'b000100,
    ST_RW_MANY_1  = 6'b001000,
    ST_RW_END     = 6'b010000
} t_state;


/////////////////////////////////////////////////////////////////////////



/////////////////////////////// signals declaration /////////////////////

wire [HBM_ADDR_WIDTH-1:0] rx_address_base_p0_id;
wire [HBM_ADDR_WIDTH-1:0] rx_address_base_p1_id;
wire [HBM_ADDR_WIDTH-1:0] rx_address_base_p2_id;
wire [HBM_ADDR_WIDTH-1:0] tx_address_base_p3_id;
wire [HBM_ADDR_WIDTH-1:0] rx_address_base_p0_idx;
wire [HBM_ADDR_WIDTH-1:0] rx_address_base_p1_idx;
wire [HBM_ADDR_WIDTH-1:0] rx_address_base_p1_idy;
wire [HBM_ADDR_WIDTH-1:0] rx_address_base_p2_idx;
wire [HBM_ADDR_WIDTH-1:0] rx_address_base_p2_idy;
wire [HBM_ADDR_WIDTH-1:0] tx_address_base_p3_idx;

reg [HBM_ADDR_WIDTH-1:0] rx_address_p0;
reg [HBM_ADDR_WIDTH-1:0] rx_address_p1;
reg [HBM_ADDR_WIDTH-1:0] rx_address_p2;
reg [HBM_ADDR_WIDTH-1:0] tx_address_p3;

wire [HBM_PCI_COUNT -1:0] rx_data_valid;
wire [HBM_DATA_WIDTH-1:0] rx_data [HBM_PCI_COUNT-1:0];
wire [HBM_ADDR_WIDTH-1:0] rx_address [HBM_PCI_COUNT -1:0];
wire [HBM_PCI_COUNT -1:0] rx_done;
wire [HBM_PCI_COUNT -1:0] rx_start;

wire [HBM_PCI_COUNT -1:0] fifo_rd_en;
wire [FIFO_WIDTH*HBM_PCI_COUNT-1:0] fifo_dout;
wire [HBM_PCI_COUNT-1:0] fifo_full;
wire [HBM_PCI_COUNT-1:0] fifo_empty;

reg start_q;

wire [HBM_PCO_COUNT-1:0] tx_done;
wire [HBM_ADDR_WIDTH-1:0] tx_address [HBM_PCO_COUNT-1:0];
wire [HBM_PCO_COUNT-1:0] tx_err;
wire [HBM_DATA_WIDTH-1:0] tx_data [HBM_PCO_COUNT-1:0];
wire [HBM_PCO_COUNT -1:0] tx_data_valid;
wire [HBM_PCO_COUNT -1:0] tx_start;

wire p0_fifo_nempty;
reg  [LOGCTRD-1:0] p0_ctr_data;
reg  p0_ctr_data_rst;
reg  p0_ctr_data_inc;
reg  p0_read_started;
reg  [LOGCTRA-1:0] p0_ctr_addr;
reg  p0_ctr_addr_inc;
wire p0_is_poly, p0_is_psi, p0_is_psi_inv;
reg  p0_fifo_rd_en;
reg  p0_rx_start;
wire p0_rx_done;


(* mark_debug = "true" *) t_state p0_state, next_p0_state;



wire p1_fifo_nempty;
reg  [LOGCTRD-1:0] p1_ctr_data;
reg  p1_ctr_data_rst;
reg  p1_ctr_data_inc;
reg  p1_read_started;
reg  [LOGCTRA-1:0] p1_ctr_addr;
reg  p1_ctr_addr_inc;
reg  p1_fifo_rd_en;
reg  p1_rx_start;
wire p1_rx_done;

wire p1_is_rlk, p1_is_poly0, p1_is_poly1;

t_state p1_state, next_p1_state;



wire p2_fifo_nempty;
reg  [LOGCTRD-1:0] p2_ctr_data;
reg  p2_ctr_data_rst;
reg  p2_ctr_data_inc;
reg  p2_read_started;
reg  [LOGCTRA-1:0] p2_ctr_addr;
reg  p2_ctr_addr_inc;
reg  p2_fifo_rd_en;
reg  p2_rx_start;
wire p2_rx_done;

t_state p2_state, next_p2_state;


reg  p3_tx_start;
reg  p3_tx_valid;
reg  [LOGCTRD-1:0] p3_ctr_data;
reg  [LOGCTRA-1:0] p3_ctr_addr;
reg  p3_ctr_addr_inc;

t_state p3_state, next_p3_state;

/////////////////////////////////////////////////////////////////////////




///////////////////////// input dma and fifo instances //////////////////

wire [11:0] fifo_rd_count [0:HBM_PCI_COUNT-1];


for (genvar g = 0; g < HBM_PCI_COUNT; g = g + 1) begin

    dma_rx #(
        .C_M_AXI_ADDR_WIDTH ( HBM_ADDR_WIDTH               ),
        .C_M_AXI_DATA_WIDTH ( HBM_DATA_WIDTH               ),
        .C_M_AXI_BURST_LEN  ( HBM_BURST_LEN                )
    ) inst_dma_rx (
        .ap_clk             ( clk                          ),
        .ap_rst_n           ( ~rst                         ),
        // HBM <- DMA
        .m_axi              ( m_axi[g]                     ),
        // DMA -> COMP
        .dma_data_valid     ( rx_data_valid[g]             ),
        .dma_data_counter   (                              ),
        .dma_data           ( rx_data[g]                   ),
        // DMA <-> COMP
        .dma_start          ( rx_start[g]                  ),
        .dma_done           ( rx_done[g]                   ),
        .dma_address        ( rx_address[g]                )
    );

    fifo_sync FIFOi (
        .clk                ( clk                          ),
        .srst               ( rst                          ),
        .wr_en              ( rx_data_valid[g]             ),
        .din                ( rx_data[g]                   ),
        .rd_en              ( fifo_rd_en[g]                ),
        .dout               ( fifo_dout[(g*FIFO_WIDTH)+:FIFO_WIDTH]),
        .full               ( fifo_full[g]                 ),
        .empty              ( fifo_empty[g]                ),
        .data_count         ( fifo_rd_count[g]             ) 
    );

end


/////////////////////////////////////////////////////////////////////////




///////////////////////// output dma instances //////////////////////////

for (genvar g = 0; g < HBM_PCO_COUNT; g = g + 1) begin

    dma_tx #(
        .C_M_AXI_ADDR_WIDTH ( HBM_ADDR_WIDTH               ),
        .C_M_AXI_DATA_WIDTH ( HBM_DATA_WIDTH               ),
        .C_M_AXI_TX_LEN     ( HBM_DATA_WIDTH               ),
        .C_M_AXI_BURST_LEN  ( HBM_BURST_LEN                )
    ) inst_dma_tx (
        .ap_clk             ( clk                          ),
        .ap_rst_n           ( ~rst                         ),
        // Reset Output FIFO
        .fifo_reset         ( start_q                      ),
        // HBM -> DMA
        .m_axi              ( m_axi[g + HBM_PCI_COUNT]     ),
        // DMA <- COMP
        .dma_data_valid     ( tx_data_valid[g]             ),
        .dma_data           ( tx_data[g]                   ),
        // DMA <-> COMP
        .dma_start          ( tx_start[g]                  ),
        .dma_done           ( tx_done[g]                   ),
        .dma_address        ( tx_address[g]                ),
        .dma_err_fifo_full  ( tx_err[g]                    )
    );

end

/////////////////////////////////////////////////////////////////////////





/////////////////////////////////// p0 //////////////////////////////////

assign p0_is_poly    = (relin_t.i_p0_id == `POLY_2 );
assign p0_is_psi     = (relin_t.i_p0_id == `PSI    );
assign p0_is_psi_inv = (relin_t.i_p0_id == `PSI_INV);

assign rx_address_base_p0_id = (p0_is_poly )    ? 0                   : 
                               (p0_is_psi  )    ? PSI_ADDR_OFFSET     :
                            /* (p0_is_psi_inv) */   PSI_INV_ADDR_OFFSET ;

assign rx_address_base_p0_idx = (p0_is_poly )    ? relin_t.i_p0_idx << LOG_POLY_SINGLE_PC_SIZE :
                             /* (p0_is_psi  ) */   relin_t.i_p0_idx * PSI_SINGLE_PC_SIZE;

always @(posedge clk) begin
   rx_address_p0 <= rx_address_base_p0_id + rx_address_base_p0_idx + (p0_ctr_addr << LOG_HBM_BURST_SIZE); 
end

for (genvar g = 0; g < 8; g = g + 1) begin
    assign rx_address[g] = dma_address[g] + rx_address_p0;
    for (genvar i = 0; i < TPPC; i = i + 1) begin
        assign relin_t.i_p0_data[g*TPPC + i] = fifo_dout[(g*TPPC + i)*LOGQ_ +: LOGQ_];
    end
    assign fifo_rd_en[g] = p0_fifo_rd_en;
    assign rx_start[g] = p0_rx_start;
end

assign p0_fifo_nempty = fifo_empty[7:0] == 8'd0;

assign p0_rx_done = rx_done[7:0] == {8{1'b1}};


always @(posedge clk) begin
    if (rst) begin
        p0_ctr_data <= 0;
    end
    else if (p0_ctr_data_inc) begin
        p0_ctr_data <= p0_ctr_data + 1;
    end
    else if (p0_ctr_data_rst) begin
        p0_ctr_data <= 1;
    end
    else if (relin_t.i_p0_done) begin
        p0_ctr_data <= 0;
    end
end


always @(posedge clk) begin
    if (rst) begin
        p0_ctr_addr <= 0;
    end
    else if (p0_ctr_addr_inc) begin
        p0_ctr_addr <= p0_ctr_addr + 1;
    end
    else if (relin_t.i_p0_done) begin
        p0_ctr_addr <= 0;
    end
end


always @(posedge clk) begin
    if (rst) begin
        p0_read_started <= 0;
    end
    else if (relin_t.i_p0_done) begin
        p0_read_started <= 0;
    end
    else if (p0_fifo_rd_en) begin
        p0_read_started <= 1;
    end
end

reg [7:0] ctr_wait_p0;

always @(posedge clk) begin
    if (rst) begin
        ctr_wait_p0 <= 0;
    end
    else if (p0_state == ST_RW_SINGLE) begin
        if (ctr_wait_p0 < 8'd51) begin
            ctr_wait_p0 <= ctr_wait_p0 + 8'd1;
        end else begin
            ctr_wait_p0 <= 8'd0;
        end
        
    end
    else begin
        ctr_wait_p0 <= '0;
    end
end


wire p0_prefill_ready_w =
    (fifo_rd_count[0] >= PREFILL) &
    (fifo_rd_count[1] >= PREFILL) &
    (fifo_rd_count[2] >= PREFILL) &
    (fifo_rd_count[3] >= PREFILL) &
    (fifo_rd_count[4] >= PREFILL) &
    (fifo_rd_count[5] >= PREFILL) &
    (fifo_rd_count[6] >= PREFILL) &
    (fifo_rd_count[7] >= PREFILL);

reg p0_prefill_ready;
always @(posedge clk) begin
  if (rst) p0_prefill_ready <= 1'b0;
  else if(p0_state == ST_RW_SINGLE || p0_state == ST_RW_MANY_0 || p0_state == ST_RW_MANY_1)
       p0_prefill_ready <= p0_prefill_ready_w; // register it (stability)
  else p0_prefill_ready <= 1'b0;
end


always @(posedge clk) begin
    if (rst) begin
        p0_state <= ST_IDLE;
    end
    else begin
        p0_state <= next_p0_state;
    end
end


always @(*) begin
    next_p0_state = p0_state;
    //relin_t.i_p0_done = 0;
    relin_t.i_p0_valid = 0;
    p0_fifo_rd_en = 0;

    p0_rx_start = 0;

    p0_ctr_addr_inc = 0;
    p0_ctr_data_inc = 0;
    p0_ctr_data_rst = 0;

    i_p0_done_int = 0;

    case (p0_state)
        ST_IDLE: begin
            if (relin_t.i_p0_en) begin
                p0_rx_start = 1;
                if ((~p0_is_poly && (FIFO_READ_LAT_PSI == 0)) || (p0_is_poly && (FIFO_READ_LAT_POLY == 0))) begin
                    next_p0_state = ST_RW_SINGLE;
                end 
                else begin
                    next_p0_state = ST_RW_MANY_0;
                end
            end
        end
        ST_RW_SINGLE: begin
            if (p0_fifo_nempty && p0_prefill_ready) begin
                p0_fifo_rd_en = 1;
                p0_ctr_data_inc = 1;
                relin_t.i_p0_valid = 1;
                next_p0_state = ST_RW_END;   
            end
        end
        ST_RW_MANY_0: begin // to ensure that we read without gaps from the fifo
            if (p0_rx_done) begin
                if ((~p0_is_poly && ((PSI_BURST_NUM - 1) == p0_ctr_addr)) || (p0_is_poly && ((POLY_BURST_NUM - 1) == p0_ctr_addr))) begin
                    if (p0_prefill_ready) begin
                        next_p0_state = ST_RW_END;
                    end else begin
                        next_p0_state = ST_RW_MANY_0;
                    end
                    
                end
                else begin
                    p0_ctr_addr_inc = 1;
                    next_p0_state = ST_RW_MANY_1;
                end
            end

            // fifo
            if (p0_read_started) begin
                p0_fifo_rd_en = 1;
                p0_ctr_data_inc = 1;
            end
            else if ((~p0_is_poly && (p0_prefill_ready)) || (p0_is_poly && (p0_prefill_ready))) begin
                p0_fifo_rd_en = 1;
                relin_t.i_p0_valid = 1;
                p0_ctr_data_rst = 1;
            end
            else if (p0_fifo_nempty) begin
                p0_ctr_data_inc = 1;
            end

        end
        ST_RW_MANY_1: begin
            p0_rx_start = 1;
            next_p0_state = ST_RW_MANY_0;
            
            // fifo
            if (p0_read_started) begin
                p0_fifo_rd_en = 1;
                p0_ctr_data_inc = 1;
            end
            else if ((~p0_is_poly && (p0_prefill_ready)) || (p0_is_poly && (p0_prefill_ready))) begin
                p0_fifo_rd_en = 1;
                p0_ctr_data_rst = 1;
                relin_t.i_p0_valid = 1;
            end
            else if (p0_fifo_nempty) begin
                p0_ctr_data_inc = 1;
            end
        end
        ST_RW_END: begin
            p0_fifo_rd_en = 1;
            if ((~p0_is_poly && (p0_ctr_data == (PSI_CC - 1))) || (p0_is_poly && (p0_ctr_data == (POLY_CC - 1)))) begin
                //relin_t.i_p0_done = 1;
                i_p0_done_int = 1;
                next_p0_state = ST_IDLE;
            end
            else begin
                p0_ctr_data_inc = 1;
            end
        end
        default: begin
            next_p0_state = ST_IDLE;
        end
    endcase
end


wire i_p0_done_d10;

always @(*) begin
    relin_t.i_p0_done = i_p0_done_d10;
end

shift_reg #(
    .LAT   (10),
    .WIDTH (1)
)
i_p0_done_shift_regd10
(
    .clk    (clk         ),
    .rst    (rst         ),
    .i_data (i_p0_done_int  ),
    .o_data (i_p0_done_d10)
);




/////////////////////////////////////////////////////////////////////////




/////////////////////////////////// p1 //////////////////////////////////

assign p1_is_poly0   = (relin_t.i_p1_id == `POLY_0 );
assign p1_is_poly1   = (relin_t.i_p1_id == `POLY_1 );
assign p1_is_rlk     = (relin_t.i_p1_id == `RLK_0  );

assign rx_address_base_p1_id = (p1_is_rlk   )    ? 0                   : 
                               (p1_is_poly0 )    ? POLY_0_ADDR_OFFSET  :
                            /* (p1_is_poly1 ) */   POLY_1_ADDR_OFFSET  ;

assign rx_address_base_p1_idx = (p1_is_rlk) ? (relin_t.i_p1_idx << LOG_POLY_SINGLE_PC_SIZE)*L : (relin_t.i_p1_idx << LOG_POLY_SINGLE_PC_SIZE);

assign rx_address_base_p1_idy = (p1_is_rlk) ? (relin_t.i_p1_idy << LOG_POLY_SINGLE_PC_SIZE) : 0;

always @(posedge clk) begin
   rx_address_p1 <= rx_address_base_p1_id + rx_address_base_p1_idx + rx_address_base_p1_idy + (p1_ctr_addr << LOG_HBM_BURST_SIZE); 
end


for (genvar g = 8; g < 16; g = g + 1) begin
    assign rx_address[g] = dma_address[g] + rx_address_p1;
    for (genvar i = 0; i < TPPC; i = i + 1) begin
        assign relin_t.i_p1_data[(g - 8)*TPPC + i] = fifo_dout[(g*TPPC + i)*LOGQ_ +: LOGQ_];
    end
    assign fifo_rd_en[g] = p1_fifo_rd_en;
    assign rx_start[g] = p1_rx_start;
end

assign p1_fifo_nempty = fifo_empty[15:8] == 8'd0;

assign p1_rx_done = rx_done[15:8] == {8{1'b1}};

always @(posedge clk) begin
    if (rst) begin
        p1_ctr_data <= 0;
    end
    else if (p1_ctr_data_inc) begin
        p1_ctr_data <= p1_ctr_data + 1;
    end
    else if (p1_ctr_data_rst) begin
        p1_ctr_data <= 1;
    end
    else if (relin_t.i_p1_done) begin
        p1_ctr_data <= 0;
    end
end


always @(posedge clk) begin
    if (rst) begin
        p1_ctr_addr <= 0;
    end
    else if (p1_ctr_addr_inc) begin
        p1_ctr_addr <= p1_ctr_addr + 1;
    end
    else if (relin_t.i_p1_done) begin
        p1_ctr_addr <= 0;
    end
end


always @(posedge clk) begin
    if (rst) begin
        p1_read_started <= 0;
    end
    else if (relin_t.i_p1_done) begin
        p1_read_started <= 0;
    end
    else if (p1_fifo_rd_en) begin
        p1_read_started <= 1;
    end
end

reg [7:0] ctr_wait_p1;

always @(posedge clk) begin
    if (rst) begin
        ctr_wait_p1 <= 0;
    end
    else if (p1_state == ST_RW_SINGLE) begin
        if (ctr_wait_p1 < 8'd51) begin
            ctr_wait_p1 <= ctr_wait_p1 + 8'd1;
        end else begin
            ctr_wait_p1 <= 8'd0;
        end
        
    end
    else begin
        ctr_wait_p1 <= '0;
    end
end


wire p1_prefill_ready_w =
    (fifo_rd_count[8] >= PREFILL) &
    (fifo_rd_count[9] >= PREFILL) &
    (fifo_rd_count[10] >= PREFILL) &
    (fifo_rd_count[11] >= PREFILL) &
    (fifo_rd_count[12] >= PREFILL) &
    (fifo_rd_count[13] >= PREFILL) &
    (fifo_rd_count[14] >= PREFILL) &
    (fifo_rd_count[15] >= PREFILL);

reg p1_prefill_ready;
always @(posedge clk) begin
  if (rst) p1_prefill_ready <= 1'b0;
  else if(p1_state == ST_RW_SINGLE || p1_state == ST_RW_MANY_0 || p1_state == ST_RW_MANY_1)   
    p1_prefill_ready <= p1_prefill_ready_w; // register it (stability)
  else p1_prefill_ready <= 1'b0;
end


always @(posedge clk) begin
    if (rst) begin
        p1_state <= ST_IDLE;
    end
    else begin
        p1_state <= next_p1_state;
    end
end


always @(*) begin
    next_p1_state = p1_state;
    //relin_t.i_p1_done = 0;
    relin_t.i_p1_valid = 0;
    p1_fifo_rd_en = 0;

    p1_rx_start = 0;

    p1_ctr_addr_inc = 0;
    p1_ctr_data_inc = 0;
    p1_ctr_data_rst = 0;

    i_p1_done_int = 0;

    case (p1_state)
        ST_IDLE: begin
            if (relin_t.i_p1_en) begin
                p1_rx_start = 1;
                if (FIFO_READ_LAT_POLY == 0) begin
                    next_p1_state = ST_RW_SINGLE;
                end 
                else begin
                    next_p1_state = ST_RW_MANY_0;
                end
            end
        end
        ST_RW_SINGLE: begin
            if (p1_fifo_nempty && p1_prefill_ready) begin
                p1_fifo_rd_en = 1;
                p1_ctr_data_inc = 1;
                relin_t.i_p1_valid = 1;
                next_p1_state = ST_RW_END;   
            end
        end
        ST_RW_MANY_0: begin // to ensure that we read without gaps from the fifo
            if (p1_rx_done) begin
                if ((POLY_BURST_NUM - 1) == p1_ctr_addr) begin
                    if (p1_prefill_ready) begin
                        next_p1_state = ST_RW_END;
                    end else begin
                        next_p1_state = ST_RW_MANY_0;
                    end
                end
                else begin
                    p1_ctr_addr_inc = 1;
                    next_p1_state = ST_RW_MANY_1;
                end
            end

            // fifo
            if (p1_read_started) begin
                p1_fifo_rd_en = 1;
                p1_ctr_data_inc = 1;
            end
            else if (p1_prefill_ready) begin
                p1_fifo_rd_en = 1;
                relin_t.i_p1_valid = 1;
                p1_ctr_data_rst = 1;
            end
            else if (p1_fifo_nempty) begin
                p1_ctr_data_inc = 1;
            end

        end
        ST_RW_MANY_1: begin
            p1_rx_start = 1;
            next_p1_state = ST_RW_MANY_0;
            
            // fifo
            if (p1_read_started) begin
                p1_fifo_rd_en = 1;
                p1_ctr_data_inc = 1;
            end
            else if (p1_prefill_ready) begin
                p1_fifo_rd_en = 1;
                p1_ctr_data_rst = 1;
                relin_t.i_p1_valid = 1;
            end
            else if (p1_fifo_nempty) begin
                p1_ctr_data_inc = 1;
            end
        end
        ST_RW_END: begin
            p1_fifo_rd_en = 1;
            if (p1_ctr_data == (POLY_CC - 1)) begin
                //relin_t.i_p1_done = 1;
                i_p1_done_int = 1;
                next_p1_state = ST_IDLE;
            end
            else begin
                p1_ctr_data_inc = 1;
            end
        end
        default: begin
            next_p1_state = ST_IDLE;
        end
    endcase
end


wire i_p1_done_d10;

always @(*) begin
    relin_t.i_p1_done = i_p1_done_d10;
end

shift_reg #(
    .LAT   (10),
    .WIDTH (1)
)
i_p1_done_shift_regd10
(
    .clk    (clk         ),
    .rst    (rst         ),
    .i_data (i_p1_done_int  ),
    .o_data (i_p1_done_d10)
);


/////////////////////////////////////////////////////////////////////////




/////////////////////////////////// p2 //////////////////////////////////

assign rx_address_base_p2_id  = 0;
assign rx_address_base_p2_idx = (relin_t.i_p2_idx << LOG_POLY_SINGLE_PC_SIZE)*L;
assign rx_address_base_p2_idy = relin_t.i_p2_idy << LOG_POLY_SINGLE_PC_SIZE;

always @(posedge clk) begin
   rx_address_p2 <= rx_address_base_p2_id + rx_address_base_p2_idx + rx_address_base_p2_idy + (p2_ctr_addr << LOG_HBM_BURST_SIZE);
end

assign p2_fifo_nempty = fifo_empty[23:16] == 8'd0;

for (genvar g = 16; g < 24; g = g + 1) begin
    assign rx_address[g] = dma_address[g] + rx_address_p2;
    for (genvar i = 0; i < TPPC; i = i + 1) begin
        assign relin_t.i_p2_data[(g - 16)*TPPC + i] = fifo_dout[(g*TPPC + i)*LOGQ_ +: LOGQ_];
    end
    assign fifo_rd_en[g] = p2_fifo_rd_en;
    assign rx_start[g] = p2_rx_start;
end

assign p2_rx_done = rx_done[23:16] == {8{1'b1}};

always @(posedge clk) begin
    if (rst) begin
        p2_ctr_data <= 0;
    end
    else if (p2_ctr_data_inc) begin
        p2_ctr_data <= p2_ctr_data + 1;
    end
    else if (p2_ctr_data_rst) begin
        p2_ctr_data <= 1;
    end
    else if (relin_t.i_p2_done) begin
        p2_ctr_data <= 0;
    end
end


always @(posedge clk) begin
    if (rst) begin
        p2_ctr_addr <= 0;
    end
    else if (p2_ctr_addr_inc) begin
        p2_ctr_addr <= p2_ctr_addr + 1;
    end
    else if (relin_t.i_p2_done) begin
        p2_ctr_addr <= 0;
    end
end


always @(posedge clk) begin
    if (rst) begin
        p2_read_started <= 0;
    end
    else if (relin_t.i_p2_done) begin
        p2_read_started <= 0;
    end
    else if (p2_fifo_rd_en) begin
        p2_read_started <= 1;
    end
end


always @(posedge clk) begin
    if (rst) begin
        p2_state <= ST_IDLE;
    end
    else begin
        p2_state <= next_p2_state;
    end
end

reg [7:0] ctr_wait_p2;

always @(posedge clk) begin
    if (rst) begin
        ctr_wait_p2 <= 0;
    end
    else if (p2_state == ST_RW_SINGLE) begin
        if (ctr_wait_p2 < 8'd51) begin
            ctr_wait_p2 <= ctr_wait_p2 + 8'd1;
        end else begin
            ctr_wait_p2 <= 8'd0;
        end
        
    end
    else begin
        ctr_wait_p2 <= '0;
    end
end

wire p2_prefill_ready_w =
    (fifo_rd_count[16] >= PREFILL) &
    (fifo_rd_count[17] >= PREFILL) &
    (fifo_rd_count[18] >= PREFILL) &
    (fifo_rd_count[19] >= PREFILL) &
    (fifo_rd_count[20] >= PREFILL) &
    (fifo_rd_count[21] >= PREFILL) &
    (fifo_rd_count[22] >= PREFILL) &
    (fifo_rd_count[23] >= PREFILL);

reg p2_prefill_ready;
always @(posedge clk) begin
  if (rst) p2_prefill_ready <= 1'b0;
  else if(p2_state == ST_RW_SINGLE || p2_state == ST_RW_MANY_0 || p2_state == ST_RW_MANY_1)   
        p2_prefill_ready <= p2_prefill_ready_w; // register it (stability)
  else p2_prefill_ready <= 1'b0;
end



always @(*) begin
    next_p2_state = p2_state;
    //relin_t.i_p2_done = 0;
    relin_t.i_p2_valid = 0;
    p2_fifo_rd_en = 0;

    p2_rx_start = 0;

    p2_ctr_addr_inc = 0;
    p2_ctr_data_inc = 0;
    p2_ctr_data_rst = 0;

    i_p2_done_int = 0;

    case (p2_state)
        ST_IDLE: begin
            if (relin_t.i_p2_en) begin
                p2_rx_start = 1;
                if (FIFO_READ_LAT_POLY == 0) begin
                    next_p2_state = ST_RW_SINGLE;
                end 
                else begin
                    next_p2_state = ST_RW_MANY_0;
                end
            end
        end
        ST_RW_SINGLE: begin
            if (p2_fifo_nempty && p2_prefill_ready) begin
                p2_fifo_rd_en = 1;
                p2_ctr_data_inc = 1;
                relin_t.i_p2_valid = 1;
                next_p2_state = ST_RW_END;   
            end
        end
        ST_RW_MANY_0: begin // to ensure that we read without gaps from the fifo
            if (p2_rx_done) begin
                if ((POLY_BURST_NUM - 1) == p2_ctr_addr) begin
                    if (p2_prefill_ready) begin
                        next_p2_state = ST_RW_END;
                    end else begin
                        next_p2_state = ST_RW_MANY_0;
                    end
                end
                else begin
                    p2_ctr_addr_inc = 1;
                    next_p2_state = ST_RW_MANY_1;
                end
            end

            // fifo
            if (p2_read_started) begin
                p2_fifo_rd_en = 1;
                p2_ctr_data_inc = 1;
            end
            else if (p2_prefill_ready) begin
                p2_fifo_rd_en = 1;
                relin_t.i_p2_valid = 1;
                p2_ctr_data_rst = 1;
            end
            else if (p2_fifo_nempty) begin
                p2_ctr_data_inc = 1;
            end

        end
        ST_RW_MANY_1: begin
            p2_rx_start = 1;
            next_p2_state = ST_RW_MANY_0;
            
            // fifo
            if (p2_read_started) begin
                p2_fifo_rd_en = 1;
                p2_ctr_data_inc = 1;
            end
            else if (p2_prefill_ready) begin
                p2_fifo_rd_en = 1;
                p2_ctr_data_rst = 1;
                relin_t.i_p2_valid = 1;
            end
            else if (p2_fifo_nempty) begin
                p2_ctr_data_inc = 1;
            end
        end
        ST_RW_END: begin
            p2_fifo_rd_en = 1;
            if (p2_ctr_data == (POLY_CC - 1)) begin
                //relin_t.i_p2_done = 1;
                i_p2_done_int = 1;
                next_p2_state = ST_IDLE;
            end
            else begin
                p2_ctr_data_inc = 1;
            end
        end
        default: begin
            next_p2_state = ST_IDLE;
        end
    endcase
end



wire i_p2_done_d10;

always @(*) begin
    relin_t.i_p2_done = i_p2_done_d10;
end

shift_reg #(
    .LAT   (10),
    .WIDTH (1)
)
i_p2_done_shift_regd10
(
    .clk    (clk         ),
    .rst    (rst         ),
    .i_data (i_p2_done_int  ),
    .o_data (i_p2_done_d10)
);


/////////////////////////////////////////////////////////////////////////




/////////////////////////////////// p3 //////////////////////////////////

assign tx_address_base_p3_id =  (relin_t.o_p3_id == `POLY_0) ?    0                     : 
                             /* (relin_t.o_p3_id == `POLY_1) ? */ POLY_1_ADDR_OFFSET_W  ;

assign tx_address_base_p3_idx = (relin_t.o_p3_idx << LOG_POLY_SINGLE_PC_SIZE);

always @(posedge clk) begin
    tx_address_p3 <= tx_address_base_p3_id + tx_address_base_p3_idx + (p3_ctr_addr << LOG_HBM_BURST_SIZE);    
end


for (genvar g = 0; g < 8; g = g + 1) begin
    assign tx_address[g] = dma_address[g + 24] + tx_address_p3;
    for (genvar i = 0; i < TPPC; i = i + 1) begin
        assign tx_data[g][i*LOGQ_ +: LOGQ_] = relin_t.o_p3_data[g*TPPC + i];
    end
    assign tx_start[g] = p3_tx_start;
    assign tx_data_valid[g] = p3_tx_valid;
end


always @(posedge clk) begin
    if (rst) begin
        p3_state <= ST_IDLE;
    end
    else begin
        p3_state <= next_p3_state;
    end
end



always @(posedge clk) begin
    if (rst) begin
        p3_ctr_addr <= 0;
    end
    else if (p3_ctr_addr_inc) begin
        p3_ctr_addr <= p3_ctr_addr + 1;
    end
    else if (relin_t.o_p3_done) begin
        p3_ctr_addr <= 0;
    end
end



// always @(posedge clk) begin
//     if (rst) begin
//         p3_state <= ST_IDLE;
//     end
//     else begin
//         p3_state <= next_p3_state;
//     end
// end


always @(posedge clk) begin
    if (rst) begin
        p3_ctr_data      <= 0;
    end
    else if (p3_ctr_data == (POLY_CC - 1)) begin
        p3_ctr_data      <= 0;
    end
    else if (p3_tx_valid) begin
        p3_ctr_data      <= p3_ctr_data + 1;
    end
end


always @(*) begin
    next_p3_state = p3_state;

    //relin_t.o_p3_done = 0;

    p3_tx_start = 0;

    p3_ctr_addr_inc = 0;

    p3_tx_valid = relin_t.o_p3_en || (p3_ctr_data != 0);

    o_p3_done_int = 0;

    case (p3_state)
        ST_IDLE: begin
            if (relin_t.o_p3_en) begin
                p3_tx_start = 1;
                if (FIFO_READ_LAT_POLY == 0) begin
                    next_p3_state = ST_RW_SINGLE;
                end 
                else begin
                    next_p3_state = ST_RW_MANY_0;
                end
            end
        end
        ST_RW_SINGLE: begin
            if (p3_ctr_data == (POLY_CC - 1)) begin
                next_p3_state = ST_RW_END;   
            end
        end
        ST_RW_MANY_0: begin // to ensure that we read without gaps from the fifo
            if (tx_done == {HBM_PCO_COUNT{1'b1}}) begin
                if ((POLY_BURST_NUM - 1) == p3_ctr_addr) begin
                    next_p3_state = ST_RW_END;
                end
                else begin
                    p3_ctr_addr_inc = 1;
                    next_p3_state = ST_RW_MANY_1;
                end
            end
        end
        ST_RW_MANY_1: begin
            p3_tx_start = 1;
            next_p3_state = ST_RW_MANY_0;
        end
        ST_RW_END: begin
            if (tx_done == {HBM_PCO_COUNT{1'b1}}) begin
                //relin_t.o_p3_done = 1;
                o_p3_done_int = 1;
                next_p3_state = ST_IDLE;
            end
        end
        default: begin
            next_p3_state = ST_IDLE;
        end
    endcase
end


wire o_p3_done_d10;

always @(*) begin
    relin_t.o_p3_done = o_p3_done_d10;
end

shift_reg #(
    .LAT   (10),
    .WIDTH (1)
)
o_p3_done_shift_regd10
(
    .clk    (clk         ),
    .rst    (rst         ),
    .i_data (o_p3_done_int  ),
    .o_data (o_p3_done_d10)
);



/////////////////////////////////////////////////////////////////////////


///////////////////////// misc. sequential logic ////////////////////////

always @(posedge clk) begin
    if (rst) begin
        start_q <= 0;
    end
    else begin
        start_q <= start;
    end
end  

/////////////////////////////////////////////////////////////////////////

endmodule