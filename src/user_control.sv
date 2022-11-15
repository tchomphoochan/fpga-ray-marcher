`timescale 1ns / 1ps
`default_nettype none

`include "types.sv"

module user_control #(
  parameter DISPLAY_WIDTH = `DISPLAY_WIDTH,
  DISPLAY_HEIGHT = `DISPLAY_HEIGHT,
  H_BITS = `H_BITS,
  V_BITS = `V_BITS,
  ADDR_BITS = `ADDR_BITS
) (
  input wire clk_in,
  input wire btnl, btnr, btnu, btnd,
  input wire [15:0] sw
);
  localparam MODE_TRANS_XY = 0;
  localparam MODE_TRANS_XZ = 1;
  localparam MODE_ROTATE = 2;

  logic [2:0] fractal_sel;
  logic [1:0] control_mode;
  assign fractal_sel = sw[15:13];
  assign control_mode = sw[1:0];

  // TODO

endmodule // user_control

`default_nettype wire
