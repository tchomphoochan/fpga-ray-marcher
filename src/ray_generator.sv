`timescale 1ns / 1ps
`default_nettype none

`include "vector_arith.svh"

module ray_generator #(
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
  vec3 ray_direction;
  assign ready_out = 1;
  assign valid_out = valid_in;

//   vec3 cam_ww = normalize(cam_target - cam_pos); // cam_forward

// get normalized camera vectors
//   vec3 cam_uu = normalize(cross(vec3(0,1,0), cam_ww)); // cam_right
//   vec3 cam_vv = normalize(cross(cam_ww, cam_uu)); // cam_up
  vec3 cam_right, cam_up;
  assign cam_right = vec3_cross(make_vec3(`FP_ZERO, `FP_ONE, `FP_ZERO), cam_forward_in);
  assign cam_up = vec3_cross(cam_forward_in, cam_right);
// map y to about 0..1
// 	 vec2 p = (2.0 * fragCoord - iResolution.xy) / iResolution.y;
  fp hcount_fp, vcount_fp;
  assign hcount_fp = (hcount_in << 1) << `NUM_FRAC_DIGITS;
  assign vcount_fp = (vcount_in << 1) << `NUM_FRAC_DIGITS;
  fp px, py;
  // assign px = fp_mul(fp_sub(hcount_fp, `FP_DISPLAY_WIDTH), `FP_INV_DISPLAY_HEIGHT);
  // assign py = fp_mul(fp_sub(vcount_fp, `FP_DISPLAY_HEIGHT), `FP_INV_DISPLAY_HEIGHT);
  assign px = hcount_fp_in;
  assign py = vcount_fp_in;
// calculate ray direction
//   float h = 1.0; // tan(fov/2.0)
//   vec3 rd = normalize(p.x * h * cam_uu + p.y * h * cam_vv + cam_ww);
  vec3 scaled_right, scaled_up;
  assign scaled_right = vec3_scaled(cam_right, px);
  assign scaled_up = vec3_scaled(cam_up, py);

  vec3 rd0, rd1;
  assign rd0 = vec3_add(scaled_right, scaled_up);
  assign rd1 = vec3_add(rd0, cam_forward_in);
  assign ray_direction = vec3_normed(rd1);

  assign ray_direction_out.x = ray_direction.x;
  assign ray_direction_out.y = fp_neg(ray_direction.y);
  assign ray_direction_out.z = ray_direction.z;

endmodule // ray_generator

`default_nettype wire
