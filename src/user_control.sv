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
  input wire rst_in,
  input wire btnl, btnr, btnu, btnd,
  input wire [15:0] sw,
  output vec3 pos_out
);
  localparam MODE_TRANS_XY = 0;
  localparam MODE_TRANS_XZ = 1;
  localparam MODE_ROTATE = 2;

  logic [2:0] fractal_sel;
  logic [1:0] control_mode;
  logic [2:0] move_speed;
  assign fractal_sel = sw[15:13];
  assign control_mode = sw[1:0];
  assign move_speed = sw[3:2];

  logic [4:0] cycle_counter;

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      pos_out.x <= `FP_ZERO;
      pos_out.y <= `FP_ONE;
      pos_out.z <= fp_neg(`FP_THREE_HALFS);
      cycle_counter <= 0;
    end else begin
      cycle_counter <= cycle_counter + 1;
      if(cycle_counter >> 2 == move_speed) begin
        cycle_counter <= 0;
        case(control_mode) 
          MODE_TRANS_XY: begin
            pos_out.x <= (btnl && !btnr) ? pos_out.x - 1 : (btnr && !btnl) ? pos_out.x + 1 : pos_out.x;
            pos_out.y <= (btnd && !btnu) ? pos_out.y - 1 : (btnu && !btnd) ? pos_out.y + 1 : pos_out.y;
          end
          MODE_TRANS_XZ: begin
            pos_out.x <= (btnl && !btnr) ? pos_out.x - 1 : (btnr && !btnl) ? pos_out.x + 1 : pos_out.x;
            pos_out.z <= (btnd && !btnu) ? pos_out.z - 1 : (btnu && !btnd) ? pos_out.z + 1 : pos_out.z;
          end
          default: begin
          end
        endcase
      end
    end
  end
  
endmodule // user_control

`default_nettype wire
