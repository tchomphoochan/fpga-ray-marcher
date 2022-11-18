`timescale 1ns / 1ps
`default_nettype none

`include "types.sv"
`include "fixed_point_arith.sv"
`include "vector_arith.sv"
`include "sdf_primitives.sv"

module sdf_query_cube (
  input vec3 point_in,
  output fp sdf_out
);
  assign sdf_out = sd_box_fast(point_in, `FP_HALF);
endmodule // sdf_query_cube

module sdf_query_sponge (
  input vec3 point_in,
  output fp sdf_out
);

  // TODO

endmodule // sdf_query_sponge

/*
    // Infinite Menger Sponge
    FixedPoint32 map(in Vec3Fixed q)
    {
        // Layer one. The ".05" on the end varies the hole size.
        Vec3Fixed p = abs(mod((q.scaleByConst(new FixedPoint32(1.0 / 3.0))), new FixedPoint32(1.0)).scaleByConst(3.0) - (new Vec3Fixed(1.0, 1.0, 1.0).scaleByConst(new FixedPoint32(1.5))));
        FixedPoint32 d = min(max(p.x, p.y), min(max(p.y, p.z), max(p.x, p.z))) - new FixedPoint32(1.0) + new FixedPoint32(0.05);
        
        // Layer two.
        p = abs(mod(q, new FixedPoint32(1.0)) - new Vec3Fixed(0.5, 0.5, 0.5));
        d = max(d, min(max(p.x, p.y), min(max(p.y, p.z), max(p.x, p.z))) - new FixedPoint32(1.0 / 3.0) + new FixedPoint32(0.05));

        // Layer three. 3D space is divided by two, instead of three, to give some variance.
        p = abs(mod(q.scaleByConst(new FixedPoint32(2.0)), new FixedPoint32(1.0)).scaleByConst(new FixedPoint32(0.5)) - new Vec3Fixed(0.25, 0.25, 0.25));
        d = max(d, min(max(p.x, p.y), min(max(p.y, p.z), max(p.x, p.z))) - new FixedPoint32(0.5 / 3.0) - new FixedPoint32(0.015));

        // Layer four. The little holes, for fine detailing.
        p = abs(mod(q.scaleByConst(new FixedPoint32(3.0 / 0.5)), new FixedPoint32(1.0)).scaleByConst(new FixedPoint32(0.5 / 3.0)) - new Vec3Fixed(0.5 / 6.0, 0.5 / 6.0, 0.5 / 6.0));
        return max(d, min(max(p.x, p.y), min(max(p.y, p.z), max(p.x, p.z))) - new FixedPoint32(1.0 / 18.0) - new FixedPoint32(0.015));
    }
*/

module sdf_query_sponge_inf (
  input vec3 point_in,
  output fp sdf_out
);
  // vec3 p;
  // fp d;
  
  // // Layer one. The ".05" on the end varies the hole size.
  // assign p = vec3_abs(vec3_fract((point_in * `FP_1_3)) * `FP_3 - make_vec3(`FP_1_5, `FP_1_5, `FP_1_5));
  // assign d = min(max(p.x, p.y), min(max(p.y, p.z), max(p.x, p.z))) - `FP_1 + `FP_0_05;

  // // Layer two.
  // assign p = vec3_abs(vec3_fract(point_in) - make_vec3(`FP_0_5, `FP_0_5, `FP_0_5));
  // assign d = max(d, min(max(p.x, p.y), min(max(p.y, p.z), max(p.x, p.z))) - `FP_1_3 + `FP_0_05);

  // // Layer three. 3D space is divided by two, instead of three, to give some variance.
  // assign p = vec3_abs(vec3_fract(point_in * `FP_2) * `FP_0_5 - make_vec3(`FP_0_25, `FP_0_25, `FP_0_25));
  // assign d = max(d, min(max(p.x, p.y), min(max(p.y, p.z), max(p.x, p.z))) - `FP_0_5_3 - `FP_0_015);

  // // Layer four. The little holes, for fine detailing.
  // assign p = vec3_abs(vec3_fract(point_in * `FP_3_0_5) * `FP_0_5_3 - make_vec3(`FP_0_5_6, `FP_0_5_6, `FP_0_5_6));
  // assign sdf_out = max(d, min(max(p.x, p.y), min(max(p.y, p.z), max(p.x, p.z))) - `FP_1_18 - `FP_0_015);
endmodule // sdf_query_sponge_inf

`default_nettype wire
