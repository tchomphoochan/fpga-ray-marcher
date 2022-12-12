`default_nettype none
`timescale 1ns / 1ps

`include "types.svh"
`include "iverilog_hack.svh"

module bram_manager #(
  parameter WIDTH = `COLOR_BITS,
  DEPTH = 1<<`ADDR_BITS,
  ADDR_LEN = `ADDR_BITS
) (
  input wire clk,
  input wire rst,
  input wire swap_buffers, // should be set to 1 for one cycle synchronously with writing to a new bram
  input wire [ADDR_LEN-1:0] read_addr,
  input wire write_enable,
  input wire [ADDR_LEN-1:0] write_addr,
  input wire [WIDTH-1:0] write_data,
  output logic [WIDTH-1:0] read_data_out,
  output logic which_bram_out
);

  logic [WIDTH-1:0] bram0_douta;
  logic [WIDTH-1:0] bram0_doutb;
  logic [WIDTH-1:0] bram1_douta;
  logic [WIDTH-1:0] bram1_doutb;

  logic which_bram_in;
  logic which_bram_mid; // 0 or 1 
  logic which_bram_end; // next pipeline stage
  assign which_bram_in = swap_buffers ? !which_bram_mid : which_bram_mid;
  assign which_bram_out = !which_bram_end;
  assign read_data_out = !which_bram_out ? bram0_doutb : bram1_doutb;

  always_ff @(posedge clk) begin
    if (rst) begin
      which_bram_mid <= 0;
      which_bram_end <= 0;
    end else begin
      which_bram_mid <= which_bram_in;
      which_bram_end <= which_bram_mid;
    end
  end

  // BRAM has delay of 2 cycles
  xilinx_true_dual_port_read_first_1_clock_ram #(
    .RAM_WIDTH(WIDTH),
    .RAM_DEPTH(DEPTH)
    // , .INIT_FILE(`FPATH(pop_cat.mem))
  ) bram0(
    .addra(write_addr),
    .addrb(read_addr),
    .dina(write_data),
    .dinb(0),
    .clka(clk),
    .wea(write_enable && which_bram_in == 1'b0),
    .web(1'b0),
    .ena(1'b1),
    .enb(1'b1),
    .rsta(rst),
    .rstb(rst),
    .regcea(1'b1),
    .regceb(1'b1),
    .douta(bram0_douta),
    .doutb(bram0_doutb)
  );
  xilinx_true_dual_port_read_first_1_clock_ram #(
    .RAM_WIDTH(WIDTH),
    .RAM_DEPTH(DEPTH)
    // , .INIT_FILE(`FPATH(pleading_face.mem))
  ) bram1(
    .addra(write_addr),
    .addrb(read_addr),
    .dina(write_data),
    .dinb(0),
    .clka(clk),
    .wea(write_enable && which_bram_in == 1'b1),
    .web(1'b0),
    .ena(1'b1),
    .enb(1'b1),
    .rsta(rst),
    .rstb(rst),
    .regcea(1'b1),
    .regceb(1'b1),
    .douta(bram1_douta),
    .doutb(bram1_doutb)
  );

endmodule // bram_manager

`default_nettype wire