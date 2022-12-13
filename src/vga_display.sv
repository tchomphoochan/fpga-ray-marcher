`timescale 1ns / 1ps
`default_nettype none

`include "types.svh"
`include "hsl2rgb.svh"

module vga_display(
  input wire vga_clk_in,  // assume match vga clock for now
  input wire rst_in,
  // should connect to bram
  input wire [3:0] read_data_in, // 4-bit grayscale
  input wire toggle_hue, input wire toggle_color,
  output logic [`ADDR_BITS-1:0] read_addr_out,
  // connect to vga pins
  output logic [3:0] vga_r, vga_g, vga_b,
  output logic vga_hs, vga_vs
);

  logic [`VGA_H_BITS-1:0] hcount, hcount_mid, hcount_out;
  logic [`VGA_V_BITS-1:0] vcount, vcount_mid, vcount_out;
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

  logic[27:0] hue_counter;
  always_ff @(posedge vga_clk_in) begin
    if (rst_in) begin
      hue_counter <= 0;
    end else begin
      hue_counter <= hue_counter + toggle_hue;
    end
  end
  logic [2:0][7:0] hsl;
  assign hsl = hsl2rgb(hue_counter >> 20, toggle_color ? 8'd165 : 0, read_data_in << 4);

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
    read_addr_out <= ((vcount >> `DISPLAY_SHIFT_SIZE) * `DISPLAY_WIDTH) + (hcount >> `DISPLAY_SHIFT_SIZE);

    // output read data to screen
    vga_r <= blank_out ? 0 : (hsl[0] >> 4); // the board is very strict here for some stupid reason
    vga_g <= blank_out ? 0 : (hsl[1] >> 4);
    vga_b <= blank_out ? 0 : (hsl[2] >> 4);
    vga_hs <= ~hsync_out; // idk why these need to be flipped but iswtg i would never forget this again
    vga_vs <= ~vsync_out; // hours wasted here: 9
  end

endmodule // vga_display

`default_nettype wire
