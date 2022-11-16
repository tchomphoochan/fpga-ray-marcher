`timescale 1ns / 1ps
`default_nettype none

`include "types.sv"
`include "vector_arith.sv"

module march_ray (
  input vec3 ray_origin_in,
  input vec3 ray_direction_in,
  input fp t_in,
  output vec3 ray_origin_out,
);
  vec3 scaled_dir;
  scaled_dir = vec3_scaled(ray_direction_in, t_in);
  ray_origin_out = vec3_add(ray_origin_in, scaled_dir);
endmodule

module ray_unit #(
  parameter DISPLAY_WIDTH = `DISPLAY_WIDTH,
  DISPLAY_HEIGHT = `DISPLAY_HEIGHT,
  H_BITS = `H_BITS,
  V_BITS = `V_BITS
) (
  input wire clk_in,
  input wire rst_in,
  input vec3 ray_origin_in,
  input vec3 ray_direction_in,
  input wire [2:0] fractal_sel_in,
  input wire [H_BITS-1:0] hcount_in,
  input wire [V_BITS-1:0] vcount_in,
  input wire valid_in

  // rendered output
  output wire [H_BITS-1:0] hcount_out,
  output wire [V_BITS-1:0] vcount_out,
  output wire [3:0] color_out,
  output wire ready_out
);

  RayUnitState state, next_state = RU_Ready;
  logic [H_BITS-1:0] hcount;
  logic [V_BITS-1:0] vcount;
  vec3 ray_origin, next_ray_origin;
  vec3 ray_direction;
  logic [MAX_RAY_DEPTH_SIZE-1:0] ray_depth;

  // Output of SDF Query
  fp sdf_dist;

  // Output of Ray March
  vec3 ray_march_origin;

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      ray_depth = 0;
      next_state <= RU_Ready;
    end else begin
      state = next_state;
      ray_origin = next_ray_origin;

      case (State)
        RU_Ready: begin
          if (valid_in) begin
            hcount = hcount_in;
            vcount = vcount_in;
            ray_direction = ray_direction_in;
            ray_depth = 0;
            next_ray_origin <= ray_origin_in;
            next_state <= RU_Busy;
          end
        end
        RU_Busy: begin
          if (sdf_dist < 0.01 || ray_depth == MAX_RAY_DEPTH) begin
            color_out = ray_depth == MAX_RAY_DEPTH ? 4'd0 : 4'd1;
            next_state <= RU_Ready;
          end else begin
            next_ray_origin <= ray_march_origin;
            ray_depth = ray_depth + 1;
          end
        end
      endcase
    end
  end

  march_ray raymarcher (
    .ray_origin_in(next_ray_origin),
    .ray_direction_in(ray_direction),
    .t_in(sdf_dist),
    .ray_origin_out(ray_march_origin)
  );

  sdf_query_cube sdf_query (
    .point_in(next_ray_origin),
    .sdf_out(sdf_dist)
  );

  assign ready_out = (next_state == RU_Ready);
endmodule // ray_unit

`default_nettype wire
