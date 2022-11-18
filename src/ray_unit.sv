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

  // Output of SDF Query
  fp sdf_dist;

  // Output of Ray March
  vec3 next_pos_vec;

  always begin
    #10;
    $display("state: %d, depth: %d", state, ray_depth);
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

  march_ray raymarcher (
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
