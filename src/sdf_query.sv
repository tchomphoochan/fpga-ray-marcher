`timescale 1ns / 1ps
`default_nettype none

`include "types.svh"
`include "fixed_point_arith.svh"
`include "vector_arith.svh"
`include "sdf_primitives.svh"

// latency: 1 clock cycle
module sdf_query_cube (
  input logic clk_in, rst_in,
  input vec3 point_in,
  output fp sdf_out
);
  always_ff @(posedge clk_in) begin
    sdf_out <= sd_box_fast(point_in, `FP_HALF);
  end
endmodule // sdf_query_cube

// latency: 1 clock cycle
module sdf_query_cube_infinite (
  input logic clk_in, rst_in,
  input vec3 point_in,
  output fp sdf_out
);
  vec3 hhh;
  assign hhh = make_vec3(`FP_HALF, `FP_HALF, `FP_HALF);
  always_ff @(posedge clk_in) begin
    sdf_out <= sd_box_fast(vec3_sub(vec3_fract(vec3_add(point_in, hhh)), hhh), `FP_QUARTER);
  end
endmodule // sdf_cube_infinite

module sdf_query_sponge (
  input logic clk_in, rst_in,
  input vec3 point_in,
  output fp sdf_out
);

  // TODO

endmodule // sdf_query_sponge

/*
    // Infinite Menger Sponge Base-2
    // Layer one. The ".05" on the end varies the hole size.
    vec3 p = abs(fract(q/2.)*2. - 1.);
    float d = min(max(p.x, p.y), min(max(p.y, p.z), max(p.x, p.z))) - .5 + .05;
    
    // Layer two.
    p =  abs(fract(q) - .5);
 	  d = max(d, min(max(p.x, p.y), min(max(p.y, p.z), max(p.x, p.z))) - 1./3. + .05);
   
    // Layer three. 3D space is divided by two, instead of three, to give some variance.
    p =  abs(fract(q*2.)/2. - .25);
 	  d = max(d, min(max(p.x, p.y), min(max(p.y, p.z), max(p.x, p.z))) - .5/3. - .015); 

    // Layer four. The little holes, for fine detailing.
    p =  abs(fract(q*8.)/8. - 1./16.);
 	  return max(d, min(max(p.x, p.y), min(max(p.y, p.z), max(p.x, p.z))) - 1./20.);
*/

// latency: 4 clock cycle, pipelined
module sdf_query_sponge_inf (
  input logic clk_in, rst_in,
  input vec3 point_in,
  output fp sdf_out
);
  vec3 p1, p2, p3, p4;
  fp d1, d2, d3;
  fp d1_, d2_, d3_, sdf_out_;
  
  // Layer one. The ".05" on the end varies the hole size.
  assign p1 = vec3_abs(vec3_sub(vec3_sl(vec3_fract(vec3_sr(point_in, 1)), 1), make_vec3(`FP_ONE, `FP_ONE, `FP_ONE)));
  assign d1_ = fp_add(fp_min(fp_max(p1.x, p1.y), fp_min(fp_max(p1.y, p1.z), fp_max(p1.x, p1.z))), `FP_MAGIC_NUMBER_A);

  // Layer two.
  assign p2 = vec3_abs(vec3_sub(vec3_fract(point_in), make_vec3(`FP_HALF, `FP_HALF, `FP_HALF)));
  assign d2_ = fp_max(d1, fp_add(fp_min(fp_max(p2.x, p2.y), fp_min(fp_max(p2.y, p2.z), fp_max(p2.x, p2.z))), `FP_MAGIC_NUMBER_B));

  // Layer three. 3D space is divided by two, instead of three, to give some variance.
  assign p3 = vec3_abs(vec3_sub(vec3_sr(vec3_fract(vec3_sl(point_in, 1)), 1), make_vec3(`FP_QUARTER, `FP_QUARTER, `FP_QUARTER)));
  assign d3_ = fp_max(d2, fp_add(fp_min(fp_max(p3.x, p3.y), fp_min(fp_max(p3.y, p3.z), fp_max(p3.x, p3.z))), `FP_MAGIC_NUMBER_C));

  // Layer four. The little holes, for fine detailing.
  assign p4 = vec3_abs(vec3_sub(vec3_sr(vec3_fract(vec3_sl(point_in, 3)), 3), make_vec3(`FP_ONE_SIXTEENTHS, `FP_ONE_SIXTEENTHS, `FP_ONE_SIXTEENTHS)));
  assign sdf_out_ = fp_max(d3, fp_add(fp_min(fp_max(p4.x, p4.y), fp_min(fp_max(p4.y, p4.z), fp_max(p4.x, p4.z))), `FP_MAGIC_NUMBER_D));

  always_ff @(posedge clk_in) begin
    d1 <= d1_;
    d2 <= d2_;
    d3 <= d3_;
    sdf_out <= sdf_out_;
  end

endmodule // sdf_query_sponge_inf

`default_nettype wire
