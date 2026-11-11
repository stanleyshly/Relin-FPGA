// V80 replacement for FIFO Generator fifo_sync.
// Matches the kernel's 256-bit, 2048-entry, common-clock FIFO interface.
module fifo_sync (
  input  wire         clk,
  input  wire         srst,
  input  wire         wr_en,
  input  wire [255:0] din,
  input  wire         rd_en,
  output wire [255:0] dout,
  output wire         full,
  output wire         empty,
  output wire [11:0]  data_count
);
  localparam integer ADDR_WIDTH = 11;
  reg [255:0] mem [0:2047];
  reg [ADDR_WIDTH-1:0] wr_ptr = 0;
  reg [ADDR_WIDTH-1:0] rd_ptr = 0;
  reg [ADDR_WIDTH:0] count = 0;

  wire do_write = wr_en && !full;
  wire do_read  = rd_en && !empty;

  assign full = (count == 12'd2048);
  assign empty = (count == 0);
  assign data_count = count;
  // FIFO Generator is configured First-Word Fall-Through.
  assign dout = mem[rd_ptr];

  always @(posedge clk) begin
    if (srst) begin
      wr_ptr <= 0;
      rd_ptr <= 0;
      count <= 0;
    end else begin
      if (do_write) begin
        mem[wr_ptr] <= din;
        wr_ptr <= wr_ptr + 1'b1;
      end
      if (do_read)
        rd_ptr <= rd_ptr + 1'b1;
      case ({do_write, do_read})
        2'b10: count <= count + 1'b1;
        2'b01: count <= count - 1'b1;
        default: count <= count;
      endcase
    end
  end
endmodule
