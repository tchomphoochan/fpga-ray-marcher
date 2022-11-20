`timescale 1ns / 1ps
`default_nettype none

`include "vector_arith.sv"

module ray_generator_folded #(
  parameter DISPLAY_WIDTH = `DISPLAY_WIDTH,
  DISPLAY_HEIGHT = `DISPLAY_HEIGHT,
  H_BITS = `H_BITS,
  V_BITS = `V_BITS
) (
  input logic clk_in,
  input logic rst_in,
  input logic valid_in,
  input logic [H_BITS-1:0] hcount_in,
  input logic [V_BITS-1:0] vcount_in,
  input vec3 cam_forward_in,
  output logic valid_out,
  output logic ready_out,
  output vec3 ray_direction_out
);

  logic [3:0] stage;

  // stage 0: input
  logic [H_BITS-1:0] hcount;
  logic [V_BITS-1:0] vcount;
  fp hcount_fp, vcount_fp;
  vec3 cam_forward;

  // stage 1: cam right
  vec3 cam_right;
  // stage 2: cam up
  vec3 cam_up;

  // stage 3: px, py
  fp px, py;

  // stage 4: scaled
  vec3 scaled_right;
  vec3 scaled_up;

  // stage 5: add then norm
  vec3 _rd0, _rd1, rd1;
  assign _rd0 = vec3_add(scaled_right, scaled_up);
  assign _rd1 = vec3_add(_rd0, cam_forward);

  logic fisf_valid_in, fisf_valid_out, fisf_ready_out;
  fp fisf_res_out;

  fp_inv_sqrt_folded fisf(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .a_in(vec3_dot(rd1, rd1)),
    .valid_in(fisf_valid_in),
    .res_out(fisf_res_out),
    .valid_out(fisf_valid_out),
    .ready_out(fisf_ready_out)
  );

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      stage <= 0;
      valid_out <= 0;
      ready_out <= 1;
      fisf_valid_in <= 0;
    end else if (stage == 0 && valid_in) begin
      // stage 0: input
      valid_out <= 0;
      ready_out <= 0;
      hcount <= hcount_in;
      vcount <= vcount_in;
      cam_forward <= cam_forward_in;
      hcount_fp <= (hcount_in << 1) << `NUM_FRAC_DIGITS;
      vcount_fp <= (vcount_in << 1) << `NUM_FRAC_DIGITS;
      stage <= 1;
    end else if (stage == 1) begin
      // stage 1: cam right
      cam_right <= vec3_cross(make_vec3(`FP_ZERO, `FP_ONE, `FP_ZERO), cam_forward);
      stage <= 2;
    end else if (stage == 2) begin
      // stage 2: cam up
      cam_up <= vec3_cross(cam_forward, cam_right);
      stage <= 3;
    end else if (stage == 3) begin
      // stage 3: px, py
      px <= fp_mul(fp_sub(hcount_fp, `FP_DISPLAY_WIDTH), `FP_INV_DISPLAY_HEIGHT);
      py <= fp_mul(fp_sub(`FP_DISPLAY_HEIGHT, vcount_fp), `FP_INV_DISPLAY_HEIGHT); // inverted y axis
      stage <= 4;
    end else if (stage == 4) begin
      // stage 4: scaled
      scaled_right <= vec3_scaled(cam_right, px);
      scaled_up <= vec3_scaled(cam_up, py);
      stage <= 5;
    end else if (stage == 5 && fisf_ready_out) begin
      // stage 5: add then norm
      rd1 <= _rd1;
      fisf_valid_in <= 1;
      stage <= 6;
    end else if (stage == 6) begin
      fisf_valid_in <= 0;
      if (fisf_valid_out) begin
          ray_direction_out <= vec3_scaled(rd1, fisf_res_out);
          valid_out <= 1;
          ready_out <= 1;
          stage <= 0;
      end
    end
  end

endmodule // ray_generator_folded

`default_nettype wire
