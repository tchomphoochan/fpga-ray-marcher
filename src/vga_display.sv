`timescale 1ns / 1ps
`default_nettype none

`include "types.sv"

module vga_display(
  input wire vga_clk_in,  // assume match vga clock for now
  // should connect to bram
  input wire [3:0] read_data_in, // 4-bit grayscale
  output logic [`ADDR_BITS-1:0] read_addr_out,
  // connect to vga pins
  output logic [3:0] vga_r, vga_g, vga_b,
  output logic vga_hs, vga_vs
);

  logic [`H_BITS-1:0] hcount, hcount_mid, hcount_out;
  logic [`V_BITS-1:0] vcount, vcount_mid, vcount_out;
  logic vsync, vsync_mid, vsync_out;
  logic hsync, hsync_mid, hsync_out;
  logic blank, blank_mid, blank_out;

  `VGA_GEN_TYPE vga_gen_inst(
    .pixel_clk_in(vga_clk_in),
    .hcount_out(hcount),
    .vcount_out(vcount),
    .vsync_out(vsync),
    .hsync_out(hsync),
    .blank_out(blank)
  );

  always_ff @(posedge vga_clk_in) begin
    // pipeline for 2 cycle delay due to memory
    hcount_mid <= hcount;
    hcount_out <= hcount_mid;
    vcount_mid <= vcount;
    vcount_out <= vcount_mid;
    vsync_mid <= vsync;
    vsync_out <= vsync_mid;
    hsync_mid <= hsync;
    hsync_out <= hsync_mid;
    blank_mid <= blank;
    blank_out <= blank_mid;
  end

  always_ff @(posedge vga_clk_in) begin
    // request read
    read_addr_out <= vsync * `DISPLAY_WIDTH + hsync;

    // output read data to screen
    vga_r <= blank ? 0 : read_data_in;
    vga_g <= blank ? 0 : read_data_in;
    vga_b <= blank ? 0 : read_data_in;
    vga_hs <= hsync_out;
    vga_vs <= vsync_out;
  end

endmodule // vga_display

`default_nettype wire
