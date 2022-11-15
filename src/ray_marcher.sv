`timescale 1ns / 1ps
`default_nettype none

`include "./src/types.h"

module ray_marcher #(
  parameter DISPLAY_WIDTH = `DISPLAY_WIDTH,
  DISPLAY_HEIGHT = `DISPLAY_HEIGHT,
) (
  parameter H_BITS = $clog2(DISPLAY_WIDTH);
  parameter V_BITS = $clog2(DISPLAY_HEIGHT);

  input wire clk_in,
  input wire eye_vec, // TODO
  input wire [2:0] fractal_sel_in,
  // rendered output
  output wire [H_BITS-1:0] hcount_out,
  output wire [V_BITS-1:0] vcount_out,
  output wire [3:0] color_out,
  output wire valid_out,
  output wire new_frame_out
);

  // TODO

endmodule // ray_marcher

`default_nettype wire
