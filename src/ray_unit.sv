`timescale 1ns / 1ps
`default_nettype none

`include "types.sv"
`include "fixed_point_arith.sv"
`include "vector_arith.sv"
`include "sdf_query.sv"

module march_ray (
  input vec3 ray_origin_in,
  input vec3 ray_direction_in,
  input fp t_in,
  output vec3 ray_origin_out
);
  vec3 scaled_dir;
  assign scaled_dir = vec3_scaled(ray_direction_in, t_in);
  assign ray_origin_out = vec3_add(ray_origin_in, scaled_dir);
endmodule // march_ray

module ray_generator #(
  parameter DISPLAY_WIDTH = `DISPLAY_WIDTH,
  DISPLAY_HEIGHT = `DISPLAY_HEIGHT,
  H_BITS = `H_BITS,
  V_BITS = `V_BITS
) (
  input wire [H_BITS-1:0] hcount_in,
  input wire [V_BITS-1:0] vcount_in,
  input vec3 cam_pos,
  input vec3 cam_forward,

  output vec3 ray_direction_out
);
  parameter DISPLAY_HEIGHT_INV = 1.0/$itor(`DISPLAY_HEIGHT);
//   vec3 cam_ww = normalize(cam_target - cam_pos); // cam_forward

// get normalized camera vectors
//   vec3 cam_uu = normalize(cross(vec3(0,1,0), cam_ww)); // cam_right
//   vec3 cam_vv = normalize(cross(cam_ww, cam_uu)); // cam_up
  vec3 cam_right, cam_up;
  assign cam_right = vec3_cross(make_vec3(fp_from_real(0), fp_from_real(1), fp_from_real(0)), cam_forward);
  assign cam_up = vec3_cross(cam_forward, cam_right);
// map y to about 0..1
// 	 vec2 p = (2.0 * fragCoord - iResolution.xy) / iResolution.y;
  fp hcount_fp, vcount_fp;
  assign hcount_fp = {hcount_in << 1, `NUM_FRAC_DIGITS'b0};
  assign vcount_fp = {hcount_in << 1, `NUM_FRAC_DIGITS'b0};
  fp px, py;
  assign px = fp_mul(fp_sub(hcount_fp, DISPLAY_WIDTH), fp_from_real(DISPLAY_HEIGHT_INV));
  assign py = fp_mul(fp_sub(vcount_fp, DISPLAY_HEIGHT), fp_from_real(DISPLAY_HEIGHT_INV));
// calculate ray direction
//   float h = 1.0; // tan(fov/2.0)
//   vec3 rd = normalize(p.x * h * cam_uu + p.y * h * cam_vv + cam_ww);
  vec3 scaled_right, scaled_up;
  assign scaled_right = vec3_scaled(cam_right, px);
  assign scaled_up = vec3_scaled(cam_up, py);

  vec3 rd0, rd1;
  assign rd0 = vec3_add(scaled_right, scaled_up);
  assign rd1 = vec3_add(rd0, cam_forward);
  assign ray_direction_out = vec3_normed(rd1);
endmodule // ray_generator

module ray_unit #(
  parameter DISPLAY_WIDTH = `DISPLAY_WIDTH,
  DISPLAY_HEIGHT = `DISPLAY_HEIGHT,
  H_BITS = `H_BITS,
  V_BITS = `V_BITS,
  MAX_RAY_DEPTH = `MAX_RAY_DEPTH
) (
  input wire clk_in,
  input wire rst_in,
  input vec3 ray_origin_in,
  input vec3 ray_direction_in,
  input wire [2:0] fractal_sel_in,
  input wire [H_BITS-1:0] hcount_in,
  input wire [V_BITS-1:0] vcount_in,
  input wire valid_in,

  // rendered output
  output logic [H_BITS-1:0] hcount_out,
  output logic [V_BITS-1:0] vcount_out,
  output logic [3:0] color_out,
  output logic ready_out
);

  RayUnitState state = RU_Ready;
  logic [H_BITS-1:0] hcount;
  logic [V_BITS-1:0] vcount;
  vec3 ray_origin;
  vec3 ray_direction;
  logic [$clog2(MAX_RAY_DEPTH)-1:0] ray_depth;

  // Output of Ray Generator
  vec3 next_dir_vec;

  // Output of SDF Query
  fp sdf_dist;

  // Output of Ray March
  vec3 next_pos_vec;

  always begin
    #10;
    $display("state: %s, depth: %d", state.name(), ray_depth);
    $display("ray: (%f, %f, %f) -> (%f, %f, %f)", fp_to_real(ray_origin.x), fp_to_real(ray_origin.y), fp_to_real(ray_origin.z), fp_to_real(ray_direction.x), fp_to_real(ray_direction.y), fp_to_real(ray_direction.z));
    $display("next pos: (%f, %f, %f)", fp_to_real(next_pos_vec.x), fp_to_real(next_pos_vec.y), fp_to_real(next_pos_vec.z));
    $display("dist: %f", fp_to_real(sdf_dist));
  end

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      ray_depth <= 0;
      state <= RU_Ready;
    end else begin
      case (state)
        RU_Ready: begin
          if (valid_in) begin
            hcount <= hcount_in;
            vcount <= vcount_in;
            ray_origin <= ray_origin_in;
            ray_direction <= ray_direction_in;
            ray_depth <= 0;
            state <= RU_Busy;
          end
        end
        // TODO: add a state to wait for the ray generator to finish
        RU_Busy: begin
          ray_origin <= next_pos_vec;
          
          if (sdf_dist < 0.01 || ray_depth == MAX_RAY_DEPTH) begin
            color_out <= ray_depth == MAX_RAY_DEPTH ? 4'd0 : 4'd1;
            state <= RU_Ready;
          end else begin
            ray_depth <= ray_depth + 1;
          end
        end
      endcase
    end
  end

  ray_generator #(
    .DISPLAY_WIDTH(DISPLAY_WIDTH),
    .DISPLAY_HEIGHT(DISPLAY_HEIGHT),
    .H_BITS(H_BITS),
    .V_BITS(V_BITS)
  ) generator (
    .hcount_in(hcount),
    .vcount_in(vcount),
    .cam_pos(ray_origin),
    .cam_forward(ray_direction),
    .ray_direction_out(next_dir_vec)
  );

  march_ray marcher (
    .ray_origin_in(ray_origin),
    .ray_direction_in(ray_direction),
    .t_in(sdf_dist),
    .ray_origin_out(next_pos_vec)
  );

  sdf_query_cube sdf_query (
    .point_in(ray_origin),
    .sdf_out(sdf_dist)
  );

  assign ready_out = (state == RU_Ready);
endmodule // ray_unit

`default_nettype wire
