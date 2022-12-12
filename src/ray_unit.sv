`timescale 1ns / 1ps
`default_nettype none

`include "types.svh"
`include "fixed_point_arith.svh"
`include "vector_arith.svh"

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

module brick_texture (
  input vec3 point_in,
  input wire [$clog2(`MAX_RAY_DEPTH)-1:0] ray_depth_in,
  output logic [$clog2(`MAX_RAY_DEPTH)-1:0] color_out
);
  vec3 scaled_point;
  fp u, v, o, ex, ey;
  assign scaled_point = vec3_sl(point_in, 4);

  assign o = fp_fract(fp_mul_half(fp_floor(fp_sub(scaled_point.y, `FP_HALF))));
  assign u = fp_add(fp_fract(fp_add(fp_mul_half(scaled_point.x), fp_mul_half(scaled_point.z))), o);
  assign v = fp_fract(scaled_point.y);

  assign ex = fp_sub(fp_abs(fp_sub(u, `FP_HALF)), `FP_TENTH);
  assign ey = fp_sub(fp_abs(fp_sub(v, `FP_HALF)), `FP_TENTH);

  assign color_out = fp_gt(fp_min(ex, ey), `FP_ZERO) ? ray_depth_in - 2 : ray_depth_in;
endmodule

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
  input fp hcount_fp_in,
  input fp vcount_fp_in,
  input wire toggle_dither_in,
  input wire toggle_texture_in,
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
  logic [2:0] current_fractal;
  fp hcount_fp, vcount_fp;
  vec3 ray_origin, ray_direction;
  logic [$clog2(MAX_RAY_DEPTH)-1:0] ray_depth;

  // Input, Output of Ray Generator
  logic gen_valid_in, gen_valid_out, gen_ready_out;
  vec3 cam_forward_in, ray_direction_out;

  // Output of SDF Query
  fp sdf_dist;
  logic [5:0] sdf_wait_max, sdf_wait;

  logic [$clog2(MAX_RAY_DEPTH)-1:0] current_color;
  logic [$clog2(MAX_RAY_DEPTH)-1:0] texture_out;
  assign current_color = toggle_texture_in ? texture_out : ray_depth;

  // Output of Ray March
  vec3 next_pos_vec;

`ifdef TESTING_RAY_UNIT
  always begin
    #10;
    $display("state: %d, depth: %d", state, ray_depth);
    $display("ray: (%f, %f, %f) -> (%f, %f, %f)", fp_to_real(ray_origin.x), fp_to_real(ray_origin.y), fp_to_real(ray_origin.z), fp_to_real(ray_direction.x), fp_to_real(ray_direction.y), fp_to_real(ray_direction.z));
    $display("eye_dir: (%f, %f, %f), hcount: %d, vcount: %d", fp_to_real(cam_forward_in.x), fp_to_real(cam_forward_in.y), fp_to_real(cam_forward_in.z), hcount, vcount);
    $display("next pos: (%f, %f, %f)", fp_to_real(next_pos_vec.x), fp_to_real(next_pos_vec.y), fp_to_real(next_pos_vec.z));
    $display("dist: %f", fp_to_real(sdf_dist));
    $display("gen_valid_in: %d, gen_valid_out: %d, gen_ready_out: %d", gen_valid_in, gen_valid_out, gen_ready_out);
  end
`endif

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      ray_depth <= 0;
      state <= RU_Ready;
      gen_valid_in <= 0;
    end else begin
      case (state)
        RU_Ready: begin
          if (valid_in) begin
            hcount <= hcount_in;
            vcount <= vcount_in;
            hcount_fp <= hcount_fp_in;
            vcount_fp <= vcount_fp_in;
            ray_origin <= ray_origin_in;
            current_fractal <= fractal_sel_in;
            ray_depth <= 0;
            cam_forward_in <= ray_direction_in;
            gen_valid_in <= 1;
            state <= RU_Setup;
          end
        end
        RU_Setup: begin
          gen_valid_in <= 0;
          if (gen_valid_out) begin
            ray_direction <= ray_direction_out;
            state <= RU_Busy_1;
            sdf_wait <= 0;
          end
        end
        RU_Busy_1: begin
          // waiting for sdf_dist to complete
          sdf_wait <= sdf_wait+1;
          state <= (sdf_wait+1 == sdf_wait_max) ? RU_Busy_2 : RU_Busy_1;
        end
        RU_Busy_2: begin
          // sdf_dist completed. use it to make decision / fill the next iteration's input.
          ray_origin <= next_pos_vec;
          
          if (fp_lt(sdf_dist, (`FP_HUNDREDTH>>1)) || fp_gt(sdf_dist, `FP_FIVE) || ray_depth == MAX_RAY_DEPTH) begin
            color_out <= fp_lt(sdf_dist, (`FP_HUNDREDTH>>1)) ? (4'hF - (current_color >> 1) - ((current_color >> 1) != 4'hF & toggle_dither_in & current_color[0] & (hcount[0] ^ vcount[0]))) : 4'd0;
            hcount_out <= hcount;
            vcount_out <= vcount;
            state <= RU_Ready;
          end else begin
            ray_depth <= ray_depth + 1;
            state <= RU_Busy_1;
            sdf_wait <= 0;
          end
        end
      endcase
    end
  end

  ray_generator_folded #(
    .DISPLAY_WIDTH(DISPLAY_WIDTH),
    .DISPLAY_HEIGHT(DISPLAY_HEIGHT),
    .H_BITS(H_BITS),
    .V_BITS(V_BITS)
  ) ray_gen (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .valid_in(gen_valid_in),
    .hcount_in(hcount),
    .vcount_in(vcount),
    .hcount_fp_in(hcount_fp),
    .vcount_fp_in(vcount_fp),
    .cam_forward_in(cam_forward_in),
    .ray_direction_out(ray_direction_out),
    .valid_out(gen_valid_out),
    .ready_out(gen_ready_out)
  );

  sdf_query scene (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .point_in(ray_origin),
    .fractal_sel_in(current_fractal),
    .sdf_out(sdf_dist),
    .sdf_wait_max_out(sdf_wait_max)
  );

  brick_texture texture (
    .point_in(ray_origin),
    .ray_depth_in(ray_depth),
    .color_out(texture_out)
  );

  march_ray marcher (
    .ray_origin_in(ray_origin),
    .ray_direction_in(ray_direction),
    .t_in(sdf_dist),
    .ray_origin_out(next_pos_vec)
  );

  assign ready_out = (state == RU_Ready);
endmodule // ray_unit

`default_nettype wire
