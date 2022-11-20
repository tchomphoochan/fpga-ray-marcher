`timescale 1ns / 1ps
`default_nettype none

`include "types.sv"
`include "fixed_point_arith.sv"
`include "vector_arith.sv"

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
  vec3 ray_origin, ray_direction;
  logic [$clog2(MAX_RAY_DEPTH)-1:0] ray_depth;

  // Input, Output of Ray Generator
  logic gen_valid_in, gen_valid_out, gen_ready_out;
  vec3 cam_forward_in, ray_direction_out;

  // Output of SDF Query
  fp sdf_dist;

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
            ray_origin <= ray_origin_in;
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
            state <= RU_Busy;
          end
        end
        RU_Busy: begin
          ray_origin <= next_pos_vec;
          
          if (fp_lt(sdf_dist, (`FP_HUNDREDTH>>1)) || ray_depth == MAX_RAY_DEPTH) begin
            color_out <= ray_depth == MAX_RAY_DEPTH ? 4'd0 : (4'hF - (ray_depth >> 1));
            hcount_out <= hcount;
            vcount_out <= vcount;
            state <= RU_Ready;
          end else begin
            ray_depth <= ray_depth + 1;
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
    .cam_forward_in(cam_forward_in),
    .ray_direction_out(ray_direction_out),
    .valid_out(gen_valid_out),
    .ready_out(gen_ready_out)
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
