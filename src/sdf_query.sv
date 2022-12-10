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

// latency: 4 clock cycle
module sdf_query_cube_noise (
  input logic clk_in, rst_in,
  input vec3 point_in,
  output fp sdf_out
);
  vec3 hhh, cube, _poke, poke, octa1, octa2, _octa3, octa3, octa4, octa5, _id, id;
  fp box, hash, x, y;

  assign hhh = make_vec3(`FP_HALF, `FP_HALF, `FP_HALF);

  assign cube = vec3_add(vec3_floor(point_in), hhh); // get cube id (vec3)
  assign _poke = vec3_sub(point_in, cube); // divide space into cubes, same as vec3_fract(point_in) - .5

  assign octa1 = vec3_abs(poke);  // get octahedron id (vec3)
  assign octa2 = vec3_step(make_vec3(octa1.y, octa1.z, octa1.x), octa1);
  assign _octa3 = vec3_step(make_vec3(octa1.z, octa1.x, octa1.y), octa1);
  assign octa4 = vec3_scaled(octa2, octa3); // && instead maybe?
  assign octa5 = vec3_apply_sign(octa4, poke);

  assign _id = vec3_add(octa5, cube);
  assign hash = fp_fract(vec3_dot(id, make_vec3(`FP_THREE_HALFS, `FP_THIRD, `FP_QUARTER)));

  assign x = fp_abs(fp_gt(hash, `FP_THIRD) ? fp_gt(hash, `FP_HALF) ? poke.x : poke.y : poke.x);
  assign y = fp_abs(fp_gt(hash, `FP_THIRD) ? fp_gt(hash, `FP_HALF) ? poke.z : poke.z : poke.y);

  always_ff @(posedge clk_in) begin
    poke <= _poke;
    octa3 <= _octa3;
    id <= _id;
    sdf_out <= fp_sub(fp_max(x, y), `FP_QUARTER);
  end
endmodule // sdf_query_cube_noise

// latency: 6 clock cycle
// module sdf_query_sponge #(
//   parameter ITERATIONS = 3
// ) (
//   input logic clk_in, rst_in,
//   input vec3 point_in,
//   output fp sdf_out
// );
//   fp scales [5];
//   assign scales[0] = `FP_ONE;
//   assign scales[1] = `FP_THREE;
//   assign scales[2] = `FP_NINE;
//   assign scales[3] = `FP_TWENTY_SEVEN;
//   assign scales[4] = `FP_EIGHTY_ONE;
//   fp inv_scales [5];
//   assign inv_scales[0] = `FP_ONE;
//   assign inv_scales[1] = `FP_THIRD;
//   assign inv_scales[2] = `FP_NINTH;
//   assign inv_scales[3] = `FP_TWENTY_SEVENTH;
//   assign inv_scales[4] = `FP_EIGHTY_ONETH;

//   fp distances[ITERATIONS + 1];
//   vec3 a[ITERATIONS + 1];
//   vec3 r[ITERATIONS + 1];
//   fp bounds;
//   assign bounds = sd_box_fast(point_in, `FP_ONE);

//   vec3 hhh;
//   assign hhh = make_vec3(`FP_ONE, `FP_ONE, `FP_ONE);

//   // cycle 0: compute a[1]
//   // cycle 1: compute a[2], r[1]
//   // cycle 2: compute a[3], r[2], distances[1]
//   // cycle 3: compute a[4], r[3], distances[2]
//   // cycle 4: compute       r[4], distances[3]
//   // cycle 5: compute             distances[4]
//   always_ff @(posedge clk_in) begin
//     for (int i = 1; i < ITERATIONS + 1; i = i + 1) begin
//       a[i] <= vec3_sub(vec3_sl(vec3_fract(vec3_sr(vec3_scaled(point_in, scales[i - 1]), 1)), 1), hhh);
//       r[i] <= vec3_sub(hhh, vec3_scaled(vec3_abs(a[i]), `FP_THREE));
//       distances[i] <= fp_max(i == 1 ? bounds : distances[i - 1], fp_mul(
//           fp_sub(fp_min(fp_max(r[i].x, r[i].y), fp_min(fp_max(r[i].y, r[i].z), fp_max(r[i].x, r[i].z))), `FP_ONE),
//           inv_scales[i]
//         ));
//     end
//   end
  
//   assign sdf_out = distances[ITERATIONS];
// endmodule 

// sdf_query_sponge
module sdf_query_sponge #(
  parameter ITERATIONS = 3
) (
  input logic clk_in, rst_in,
  input vec3 point_in,
  output fp sdf_out
);
  fp scales [5];
  assign scales[0] = `FP_ONE;
  assign scales[1] = `FP_THREE;
  assign scales[2] = `FP_NINE;
  assign scales[3] = `FP_TWENTY_SEVEN;
  assign scales[4] = `FP_EIGHTY_ONE;
  fp inv_scales [5];
  assign inv_scales[0] = `FP_ONE;
  assign inv_scales[1] = `FP_THIRD;
  assign inv_scales[2] = `FP_NINTH;
  assign inv_scales[3] = `FP_TWENTY_SEVENTH;
  assign inv_scales[4] = `FP_EIGHTY_ONETH;

  fp distances [4];
  fp bounds;
  assign bounds = sd_box_fast(point_in, `FP_ONE);

  vec3 hhh;
  assign hhh = make_vec3(`FP_ONE, `FP_ONE, `FP_ONE);

  generate
    genvar i;
    for (i = 1; i < ITERATIONS + 1; i = i + 1)
      begin : sdf_query_sponge_loop
        vec3 a, r;
        assign a = vec3_sub(vec3_sl(vec3_fract(vec3_sr(vec3_scaled(point_in, scales[i - 1]), 1)), 1), hhh);
        assign r = vec3_abs(vec3_sub(hhh, vec3_scaled_3(vec3_abs(a))));
        always_ff @(posedge clk_in) begin
          distances[i] <= fp_max(i == 1 ? bounds : distances[i - 1], fp_mul(
            fp_sub(fp_min(fp_max(r.x, r.y), fp_min(fp_max(r.y, r.z), fp_max(r.x, r.z))), `FP_ONE),
            inv_scales[i]));
        end
      end
  endgenerate
  
  assign sdf_out = distances[ITERATIONS];
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
