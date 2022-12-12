`timescale 1ns / 1ps
`default_nettype none

`include "vector_arith.svh"

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
  input fp hcount_fp_in,
  input fp vcount_fp_in,
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

  fp mult1_a, mult1_b, mult1_res;
  fp mult2_a, mult2_b, mult2_res;
  fp mult3_a, mult3_b, mult3_res;
  assign mult1_res = fp_mul(mult1_a, mult1_b);
  assign mult2_res = fp_mul(mult2_a, mult2_b);
  assign mult3_res = fp_mul(mult3_a, mult3_b);

  always_comb begin
    mult1_a = 0;
    mult1_b = 0;
    mult2_a = 0;
    mult2_b = 0;
    mult3_a = 0;
    mult3_b = 0;

    if (stage == 1) begin
      // cam_forward.x <= fp_mul(cam_forward.y, fp_neg(cam_forward.x));
      mult1_a = cam_forward.y;
      mult1_b = fp_neg(cam_forward.x);
      // cam_forward.y <= fp_add(fp_mul(cam_forward.z, cam_forward.z), fp_mul(cam_forward.x, cam_forward.x));
      mult2_a = cam_forward.z;
      mult2_b = cam_forward.z;
      mult3_a = cam_forward.x;
      mult3_b = cam_forward.x;
    end else if (stage == 2) begin
      mult1_a = cam_forward.y;
      mult1_b = cam_forward.z;
    // end else if (stage == 3) begin
    //   mult1_a = fp_sub(hcount_fp, `FP_DISPLAY_WIDTH);
    //   mult1_b = `FP_INV_DISPLAY_HEIGHT;
    //   mult2_a = fp_sub(vcount_fp, `FP_DISPLAY_HEIGHT);
    //   mult2_b = `FP_INV_DISPLAY_HEIGHT;
    end else if (stage == 4) begin
      // scaled_right <= vec3_scaled(cam_right, px);
      mult1_a = cam_right.x;
      mult1_b = px;
      mult2_a = cam_right.y;
      mult2_b = px;
      mult3_a = cam_right.z;
      mult3_b = px;
    end else if (stage == 7) begin
      mult1_a = cam_up.x;
      mult1_b = py;
      mult2_a = cam_up.y;
      mult2_b = py;
      mult3_a = cam_up.z;
      mult3_b = py;
    end else if (stage == 6) begin
      // ray_direction_out <= vec3_scaled(rd1, fisf_res_out);
      mult1_a = rd1.x;
      mult1_b = fisf_res_out;
      mult2_a = rd1.y;
      mult2_b = fisf_res_out;
      mult3_a = rd1.z;
      mult3_b = fisf_res_out;
    end
  end

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      stage <= 0;
      valid_out <= 0;
      ready_out <= 1;
      fisf_valid_in <= 0;
    end else if (stage == 0) begin
      // stage 0: input
      valid_out <= 0;
      if (valid_in) begin
        ready_out <= 0;
        hcount <= hcount_in;
        vcount <= vcount_in;
        cam_forward <= cam_forward_in;
        hcount_fp <= (hcount_in << 1) << `NUM_FRAC_DIGITS;
        vcount_fp <= (vcount_in << 1) << `NUM_FRAC_DIGITS;
        px <= hcount_fp_in;
        py <= vcount_fp_in;
        stage <= 1;
      end
    end else if (stage == 1) begin
      // stage 1: cam right
      // cam_right <= vec3_cross(make_vec3(`FP_ZERO, `FP_ONE, `FP_ZERO), cam_forward);
      //  i j k
      //  0 1 0
      //  x y z
      cam_right.x <= cam_forward.z;
      cam_right.y <= 0;
      cam_right.z <= fp_neg(cam_forward.x);
      //  i j k
      //  x y z
      //  z 0 -x
      // cam_forward.x <= fp_mul(cam_forward.y, fp_neg(cam_forward.x));
      // cam_forward.y <= fp_add(fp_mul(cam_forward.z, cam_forward.z), fp_mul(cam_forward.x, cam_forward.x));
      // cam_forward.z <= fp_neg(fp_mul(cam_forward.y, cam_forward.z));
      cam_up.x <= mult1_res;
      cam_up.y <= fp_add(mult2_res, mult3_res);
      // cam_up.z <= fp_neg(fp_mul(cam_forward.y, cam_forward.z)); // TODO: another stage
      // stage <= 2;
      stage <= 2;
    end else if (stage == 2) begin
      // cam_up.z <= fp_neg(fp_mul(cam_forward.y, cam_forward.z)); // TODO: another stage
      cam_up.z <= fp_neg(mult1_res); // TODO: another stage
      stage <= 4;
      // stage 2: cam up
      // cam_up <= vec3_cross(cam_forward, cam_right);
      // stage <= 3;
    end else if (stage == 3) begin
      // stage 3: px, py
      // px <= fp_mul(fp_sub(hcount_fp, `FP_DISPLAY_WIDTH), `FP_INV_DISPLAY_HEIGHT);
      // py <= fp_mul(fp_sub(vcount_fp, `FP_DISPLAY_HEIGHT), `FP_INV_DISPLAY_HEIGHT);
      // px <= mult1_res;
      // py <= mult2_res;
      // stage <= 4;
    end else if (stage == 4) begin
      // stage 4: scaled
      // scaled_right <= vec3_scaled(cam_right, px);
      scaled_right.x <= mult1_res;
      scaled_right.y <= mult2_res;
      scaled_right.z <= mult3_res;
      // scaled_up <= vec3_scaled(cam_up, py); // TODO: another stage
      stage <= 7;
    end else if (stage == 7) begin
      scaled_up.x = mult1_res;
      scaled_up.y = mult2_res;
      scaled_up.z = mult3_res;
      stage <= 5;
    end else if (stage == 5 && fisf_ready_out) begin
      // stage 5: add then norm
      rd1 <= _rd1;
      fisf_valid_in <= 1;
      stage <= 6;
    end else if (stage == 6) begin
      fisf_valid_in <= 0;
      if (fisf_valid_out) begin
          // ray_direction_out <= vec3_scaled(rd1, fisf_res_out);
          ray_direction_out.x <= mult1_res;
          ray_direction_out.y <= fp_neg(mult2_res);
          ray_direction_out.z <= mult3_res;
          valid_out <= 1;
          ready_out <= 1;
          stage <= 0;
      end
    end
  end

endmodule // ray_generator_folded

`default_nettype wire
