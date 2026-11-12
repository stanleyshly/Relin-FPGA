`timescale 1ns / 1ps
`include "axi.sv"
module matched_ntt_tb;
    parameter LOGTP=4;
    parameter MEMORY_READ_LATENCY=8;
    localparam TP=1<<LOGTP, PORTS=TP/8, ROWS=1024/TP;
    reg clk=0, rst=1, start=0;
    always #2 clk=~clk;
    wire halt;
    wire [63:0] cycles, core_cycles;
    axi4_t bus [0:3*PORTS-1] ();
    matched_ntt #(.LOGTP(LOGTP)) dut(.clk(clk), .rst(rst), .start(start), .halt(halt),
                    .cycles(cycles), .core_cycles(core_cycles), .m_axi(bus));
    reg [31:0] expected [0:1023];
    reg [31:0] expected_twiddle [0:1023];
    string vector_dir;
    integer repeat_count=11;
    integer errors=0;
    integer run_number;
    event verify;
    integer twiddle_row = -1;

    // Verify the integration boundary before arithmetic: the existing
    // twiddle loader must see each packed row exactly at its matching ctr.
    // This catches command/data pipeline skew independently of NTT output.
    always @(posedge clk) begin
        if (rst) twiddle_row <= -1;
        else begin
            // The loader enters LOAD one edge after the registered wrapper
            // command. Track that public command rather than referring to
            // vendor-dependent unnamed generate-block hierarchy.
            if (dut.core.op == 1) twiddle_row <= 0;
            else if (twiddle_row >= 0 && twiddle_row < ROWS)
                twiddle_row <= twiddle_row + 1;
            if (twiddle_row >= 0 && twiddle_row < ROWS) begin
                for (integer j=0; j<TP; j=j+1)
                    if (dut.core.flat_psi[(TP-j)*32-1-:32] !== expected_twiddle[twiddle_row*TP+j])
                        $fatal(1, "Twiddle stream mismatch: row=%0d lane=%0d expected=%h got=%h",
                            twiddle_row, j, expected_twiddle[twiddle_row*TP+j],
                            dut.core.flat_psi[(TP-j)*32-1-:32]);
            end
        end
    end

    for (genvar p=0; p<3*PORTS; p=p+1) begin : ports
        integer port_cycle=0, read_start_cycle=0;
        reg waiting_first_read=0;
        always @(posedge clk) begin
            if (rst) begin
                port_cycle <= 0;
                waiting_first_read <= 0;
            end else begin
                port_cycle <= port_cycle+1;
                if (bus[p].arvalid && bus[p].arready) begin
                    read_start_cycle <= port_cycle;
                    waiting_first_read <= 1;
                end
                if (waiting_first_read && bus[p].rvalid) begin
                    if (port_cycle-read_start_cycle != (MEMORY_READ_LATENCY == 1 ? 1 : MEMORY_READ_LATENCY+1))
                        $fatal(1,"RAM read latency mismatch: port=%0d measured=%0d configured=%0d",
                            p,port_cycle-read_start_cycle,MEMORY_READ_LATENCY);
                    $display("MATCHED_NTT_MEMORY: port=%0d read_latency_cycles=%0d",p,port_cycle-read_start_cycle);
                    waiting_first_read <= 0;
                end
            end
        end
        axi_ram #(.DATA_WIDTH(256), .ADDR_WIDTH(64), .ID_WIDTH(1),
                  .MEM_ADDR_WIDTH(12), .READ_LATENCY(MEMORY_READ_LATENCY),
                  .SRAM_READ_ON_ADDRESS(MEMORY_READ_LATENCY == 1)) ram (
            .clk(clk), .rst(rst), .s_axi_awid(1'b0),
            .s_axi_awaddr(bus[p].awaddr), .s_axi_awlen(bus[p].awlen),
            .s_axi_awsize(bus[p].awsize), .s_axi_awburst(bus[p].awburst),
            .s_axi_awlock(1'b0), .s_axi_awcache(4'b0011), .s_axi_awprot(3'b000),
            .s_axi_awvalid(bus[p].awvalid), .s_axi_awready(bus[p].awready),
            .s_axi_wdata(bus[p].wdata), .s_axi_wstrb(bus[p].wstrb),
            .s_axi_wlast(bus[p].wlast), .s_axi_wvalid(bus[p].wvalid),
            .s_axi_wready(bus[p].wready), .s_axi_bid(), .s_axi_bresp(),
            .s_axi_bvalid(bus[p].bvalid), .s_axi_bready(bus[p].bready),
            .s_axi_arid(1'b0), .s_axi_araddr(bus[p].araddr),
            .s_axi_arlen(bus[p].arlen), .s_axi_arsize(bus[p].arsize),
            .s_axi_arburst(bus[p].arburst), .s_axi_arlock(1'b0),
            .s_axi_arcache(4'b0011), .s_axi_arprot(3'b000),
            .s_axi_arvalid(bus[p].arvalid), .s_axi_arready(bus[p].arready),
            .s_axi_rid(), .s_axi_rdata(bus[p].rdata), .s_axi_rresp(),
            .s_axi_rlast(bus[p].rlast), .s_axi_rvalid(bus[p].rvalid),
            .s_axi_rready(bus[p].rready)
        );
        initial begin
            #1;
            if (!$value$plusargs("VECTOR_DIR=%s", vector_dir))
                $fatal(1, "VECTOR_DIR is required");
            if (p<PORTS) $readmemh($sformatf("%s/input-port%0d.txt", vector_dir,p), ram.mem,0,ROWS-1);
            else if (p<2*PORTS) $readmemh($sformatf("%s/twiddle-port%0d.txt", vector_dir,p-PORTS), ram.mem,0,ROWS-1);
        end
        always @(verify) begin
            if (p>=2*PORTS) begin
                for (integer row=0; row<ROWS; row=row+1)
                    for (integer j=0; j<8; j=j+1)
                        if (ram.mem[row][32*j+:32] !== expected[row*TP+(p-2*PORTS)*8+j]) begin
                            errors=errors+1;
                            $display("MISMATCH: port=%0d row=%0d lane=%0d expected=%h got=%h",
                                p,row,j,expected[row*TP+(p-2*PORTS)*8+j],ram.mem[row][32*j+:32]);
                        end
            end
            if (bus[p].arvalid && bus[p].arsize != 5) $fatal(1,"Bad AXI read size");
        end
    end

    initial begin
        if (!$value$plusargs("VECTOR_DIR=%s", vector_dir)) $fatal(1, "VECTOR_DIR is required");
        if ($value$plusargs("REPEATS=%d", repeat_count)) begin end
        if (repeat_count < 1) $fatal(1,"REPEATS must be positive");
        $readmemh({vector_dir,"/expected.txt"}, expected);
        $readmemh({vector_dir,"/twiddle.txt"}, expected_twiddle);
        for (run_number=0; run_number<repeat_count; run_number=run_number+1) begin
            rst=1;
            repeat(8) @(negedge clk);
            rst=0;
            repeat(8) @(negedge clk);
            start=1;
            @(negedge clk);
            start=0;
            wait(halt);
            @(negedge clk);
            errors=0;
            ->verify;
            #0.001;
            if (errors) $fatal(1,"NTT output check failed: %0d mismatches",errors);
            $display("MATCHED_NTT_RESULT: run=%0d n=1024 q=3221225473 tp=%0d cycles=%0d core_cycles=%0d checked=1024 PASS",
                     run_number, TP, cycles, core_cycles);
        end
        $display("MATCHED_NTT_PASS: repeats=%0d",repeat_count);
        $finish;
    end
    initial begin
        #1000000;
        $fatal(1,"Matched NTT watchdog expired");
    end
endmodule
