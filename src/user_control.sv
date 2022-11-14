`timescale 1ns / 1ps
`default_nettype none

module user_control #(
  parameter DISPLAY_WIDTH = 640,
  DISPLAY_HEIGHT = 480,
  H_BITS = 10,
  V_BITS = 9
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
