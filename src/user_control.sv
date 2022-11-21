`timescale 1ns / 1ps
`default_nettype none

`include "types.svh"

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
  output vec3 pos_out,
  output vec3 dir_out,
  output logic [2:0] fractal_sel_out,
  output logic toggle_hue_out,
  output logic toggle_color_out,
  output logic toggle_checker_out,
  output logic toggle_dither_out
);
  localparam CLK_PERIOD_NS = 20;
  localparam DELTA_TIME_MS = 1;
  localparam COUNTER_SIZE = int'($ceil(DELTA_TIME_MS*1_000_000/CLK_PERIOD_NS));
  localparam COUNTER_WIDTH = $clog2(COUNTER_SIZE);

  
  localparam MODE_WALK = 0;
  localparam MODE_TRANS_XY = 1;
  localparam MODE_TRANS_XZ = 2;

  vec3 dir;
  assign dir_out = dir;

  logic [1:0] control_mode;
  logic [2:0] move_speed;
  assign control_mode = sw[1:0];
  assign move_speed = sw[3:2];

  assign fractal_sel_out = sw[15:13];
  assign toggle_hue_out = sw[4];
  assign toggle_color_out = sw[5];
  assign toggle_checker_out = sw[12];
  assign toggle_dither_out = sw[11];

  logic [COUNTER_WIDTH+2:0] cycle_counter;
  
  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      pos_out.x <= `FP_ZERO;
      pos_out.y <= `FP_ONE;
      pos_out.z <= fp_neg(`FP_THREE_HALFS);
      dir.x <= `FP_ZERO;
      dir.y <= `FP_ZERO;
      dir.z <= `FP_ONE;
      cycle_counter <= 0;
    end else begin
      if(cycle_counter >> COUNTER_WIDTH == move_speed + 1) begin
        cycle_counter <= 0;

        case(control_mode) 
          MODE_TRANS_XY: begin
            pos_out.x <= (btnl && !btnr) ? fp_sub(pos_out.x, `FP_HUNDREDTH) : (btnr && !btnl) ? fp_add(pos_out.x, `FP_HUNDREDTH) : pos_out.x;
            pos_out.y <= (btnd && !btnu) ? fp_sub(pos_out.y, `FP_HUNDREDTH) : (btnu && !btnd) ? fp_add(pos_out.y, `FP_HUNDREDTH) : pos_out.y;
          end
          MODE_TRANS_XZ: begin
            pos_out.x <= (btnl && !btnr) ? fp_sub(pos_out.x, `FP_HUNDREDTH) : (btnr && !btnl) ? fp_add(pos_out.x, `FP_HUNDREDTH) : pos_out.x;
            pos_out.z <= (btnd && !btnu) ? fp_sub(pos_out.z, `FP_HUNDREDTH) : (btnu && !btnd) ? fp_add(pos_out.z, `FP_HUNDREDTH) : pos_out.z;
          end
          MODE_WALK: begin
            pos_out.x <= (btnd && !btnu) ? fp_sub(pos_out.x, fp_mul(dir.x, `FP_HUNDREDTH)) : (btnu && !btnd) ? fp_add(pos_out.x, fp_mul(dir.x, `FP_HUNDREDTH)) : pos_out.x;
            pos_out.z <= (btnd && !btnu) ? fp_sub(pos_out.z, fp_mul(dir.z, `FP_HUNDREDTH)) : (btnu && !btnd) ? fp_add(pos_out.z, fp_mul(dir.z, `FP_HUNDREDTH)) : pos_out.z;

            if(btnl || btnr) begin
              fp m00 = `FP_COS_HUNDREDTH;
              fp m01 = btnl ? fp_neg(`FP_SIN_HUNDREDTH) : `FP_SIN_HUNDREDTH;
              dir.x <= fp_add(fp_mul(dir.x, m00), fp_mul(dir.z, m01));
              dir.z <= fp_add(fp_mul(dir.x, fp_neg(m01)), fp_mul(dir.z, m00));
            end
          end
          default: begin
          end
        endcase
      end else begin
        cycle_counter <= cycle_counter + 1;
      end
    end
  end
  
endmodule // user_control

`default_nettype wire
