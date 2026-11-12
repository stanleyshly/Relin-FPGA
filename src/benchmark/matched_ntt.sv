`timescale 1ns / 1ps
`include "axi.sv"

// Standalone benchmark adapter. Arithmetic, DMA and FIFOs are existing Relin
// modules. This controller is new and is not the relinearization controller.
module matched_ntt #(parameter LOGTP=4, localparam TP=1<<LOGTP, PORTS=TP/8) (
    input wire clk,
    input wire rst,
    input wire start,
    output reg halt,
    output reg [63:0] cycles,
    output reg [63:0] core_cycles,
    axi4_t.master m_axi [0:3*PORTS-1]
);
    localparam N=1024, ROWS=N/TP, COUNT_BITS=$clog2(ROWS)+1;
    typedef enum logic [3:0] {IDLE, READ_WAIT, Q_LOAD, Q_GAP,
        PSI_LOAD, PSI_SEND, PSI_GAP, INPUT_SEND, OUTPUT_WAIT,
        TX_START, TX_WAIT, DONE} state_t;
    state_t state;
    reg [COUNT_BITS-1:0] row;
    wire [2*PORTS-1:0] rx_valid, rx_done;
    wire [255:0] rx_data [0:2*PORTS-1];
    wire [PORTS-1:0] tx_done, tx_error;
    reg [255:0] in_buffer [0:2*PORTS-1][0:ROWS-1];
    reg [COUNT_BITS-1:0] rx_count [0:2*PORTS-1];
    reg [31:0] out_buffer [0:N-1];
    reg [COUNT_BITS-1:0] out_count;
    wire rx_start = state == IDLE && start;
    wire tx_start = state == TX_START;
    wire load_q = state == Q_LOAD;
    wire load_psi = state == PSI_LOAD;
    wire i_valid = state == INPUT_SEND;
    wire o_valid;
    wire [31:0] o_poly [0:TP-1];
    wire [31:0] i_poly [0:TP-1];
    wire [31:0] psi [0:TP-1];
    wire [255:0] tx_data [0:PORTS-1];
    wire tx_valid = state == TX_WAIT && row < ROWS;
    reg [63:0] core_start;
    reg core_started;
    // The supported 32*32, 16*4*16 and 8*2*8*8 schedules emit bit-reversed frequencies. This
    // wiring changes storage addresses, with no host-side reorder excluded
    // from timing. The vector generator independently checks this schedule.
    function automatic [9:0] reverse10(input [9:0] index);
        for (integer bit_index=0; bit_index<10; bit_index=bit_index+1)
            reverse10[bit_index] = index[9-bit_index];
    endfunction

    for (genvar p=0; p<2*PORTS; p=p+1) begin : rx
        dma_rx #(.C_M_AXI_BURST_LEN(ROWS), .C_M_AXI_TX_LEN(ROWS)) dma (
            .ap_clk(clk), .ap_rst_n(~rst), .m_axi(m_axi[p]),
            .dma_data_valid(rx_valid[p]), .dma_data_counter(),
            .dma_data(rx_data[p]), .dma_start(rx_start),
            .dma_done(rx_done[p]), .dma_address(64'd0)
        );
        always @(posedge clk) begin
            if (rst || rx_start) rx_count[p] <= 0;
            else if (rx_valid[p]) begin
                if (rx_count[p] >= ROWS) $fatal(1, "Too many RX beats");
                in_buffer[p][rx_count[p]] <= rx_data[p];
                rx_count[p] <= rx_count[p] + 1;
            end
        end
    end
    for (genvar p=0; p<PORTS; p=p+1) begin : tx
        for (genvar j=0; j<8; j=j+1) begin : pack
            assign tx_data[p][32*j+:32] = row < ROWS ? out_buffer[row*TP+p*8+j] : 32'd0;
        end
        dma_tx #(.C_M_AXI_BURST_LEN(ROWS), .C_M_AXI_TX_LEN(ROWS)) dma (
            .ap_clk(clk), .ap_rst_n(~rst), .m_axi(m_axi[p+2*PORTS]),
            .fifo_reset(rst || rx_start), .dma_data_valid(tx_valid),
            .dma_data(tx_data[p]), .dma_start(tx_start),
            .dma_done(tx_done[p]), .dma_address(64'd0),
            .dma_err_fifo_full(tx_error[p])
        );
    end
    for (genvar j=0; j<TP; j=j+1) begin : lanes
        assign i_poly[j] = row < ROWS ? in_buffer[j/8][row][32*(j%8)+:32] : 32'd0;
        assign psi[j] = row < ROWS ? in_buffer[PORTS+j/8][row][32*(j%8)+:32] : 32'd0;
    end
    ntt_wrapper #(.LOGN(10), .LOGTP(LOGTP), .LOGQ(32), .LOGQH(15),
                  .LOGN1(LOGTP), .LOGN2(LOGTP == 5 ? 5 : LOGTP == 4 ? 2 : 1), .LOGN3(LOGTP == 5 ? 0 : LOGTP)) core (
        .clk(clk), .rst(rst), .load_q(load_q), .load_psi(load_psi),
        .intt(1'b0), .qH(15'd24576), .i_valid(i_valid),
        .i_poly(i_poly), .psi(psi), .o_valid(o_valid), .o_poly(o_poly)
    );

    // cycles is an edge difference: start acceptance is zero; halt edge
    // includes reception of all AXI write responses. No polling or oracle
    // runs inside this measured interval.
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE; row <= 0; out_count <= 0;
            halt <= 0; cycles <= 0; core_cycles <= 0;
            core_started <= 0; core_start <= 0;
        end else begin
            if (state != IDLE && state != DONE) cycles <= cycles+1;
            if (|tx_error) $fatal(1, "Output DMA FIFO overflow");
            if (i_valid && !core_started) begin
                core_started <= 1;
                core_start <= cycles;
            end
            if (o_valid) begin
                if (out_count >= ROWS) $fatal(1, "Too many NTT output rows");
                for (integer j=0; j<TP; j=j+1)
                    out_buffer[reverse10(10'(out_count*TP+j))] <= o_poly[j];
                out_count <= out_count+1;
                if (out_count == ROWS-1) core_cycles <= cycles-core_start;
            end
            case (state)
                IDLE: if (start) begin
                    state <= READ_WAIT; cycles <= 0; halt <= 0;
                    core_started <= 0; out_count <= 0;
                end
                // dma_rx registers both done and its final data-valid on
                // the last AXI handshake. That beat reaches in_buffer on
                // the following edge. Drain this register before checking
                // counts or letting the core consume the buffer.
                READ_WAIT: if ((&rx_done) && !(|rx_valid)) begin
                    for (integer p=0; p<2*PORTS; p=p+1)
                        if (rx_count[p] != ROWS)
                            $fatal(1, "Incomplete input DMA: port=%0d received=%0d expected=%0d", p, rx_count[p], ROWS);
                    state <= Q_LOAD;
                end
                Q_LOAD: state <= Q_GAP;
                Q_GAP: state <= PSI_LOAD;
                // Row zero is already on psi while load_psi is asserted.
                // ntt_wrapper registers the command once and data twice;
                // twiddle_load then registers its state. Thus its ctr=0
                // consumes this cycle's row, not the next cycle's row.
                // Advance now so the packed stream does not repeat row 0.
                PSI_LOAD: begin row <= 1; state <= PSI_SEND; end
                PSI_SEND: if (row == ROWS-1) begin row <= 0; state <= PSI_GAP; end
                          else row <= row+1;
                PSI_GAP: state <= INPUT_SEND;
                INPUT_SEND: if (row == ROWS-1) begin row <= 0; state <= OUTPUT_WAIT; end
                            else row <= row+1;
                OUTPUT_WAIT: if (out_count == ROWS) state <= TX_START;
                TX_START: begin row <= 0; state <= TX_WAIT; end
                TX_WAIT: begin
                    if (row < ROWS) row <= row+1;
                    if (&tx_done) begin halt <= 1; state <= DONE; end
                end
                DONE: ;
                default: $fatal(1, "Invalid benchmark state");
            endcase
        end
    end
endmodule
