`timescale 1ns / 1ps
`default_nettype none

`include "types.sv"
`include "fixed_point_arith.sv"
`include "vector_arith.sv"
`include "sdf_primitives.sv"

`define TEST_SDF_PRIMITIVES(func, x, y, z, halfExtents, distance) \
  vec = make_vec3(fp_from_real(x), fp_from_real(y), fp_from_real(z)); \
  val = func(vec, fp_from_real(halfExtents)); \
  $display("Expected: %s({%f, %f, %f}, %f) = %f", `"func`", x, y, z, halfExtents, distance); \
  $display("Actual: %s({%f, %f, %f}, %f) = %f", `"func`", fp_to_real(vec.x), fp_to_real(vec.y), fp_to_real(vec.z), halfExtents, fp_to_real(val)); \
  passed = $abs(fp_to_real(val)-distance) < 1e-4; \
  all_passed = all_passed & passed; \
  $display("%s", passed ? "PASSED" : "FAILED"); \
  $display(""); \
  #10;

module sdf_primitives_tb;

  vec3 vec;
  fp val;

  logic all_passed = 1;
  logic passed;

  initial begin
    $dumpfile("sdf_primitives.vcd");
    $dumpvars(0, sdf_primitives_tb);
    $display("Starting Sim");

    `TEST_SDF_PRIMITIVES(sd_box_fast, 0, 0, 0, 0.5, -0.5);
  //     vec = make_vec3(fp_from_real(x), fp_from_real(y), fp_from_real(z)); \
  // val = func(vec, fp_from_real(halfExtents)); \
  // $display("Expected: %s({%f, %f, %f}, %f) = %f", `"func`", x, y, z, halfExtents, distance); \
  // $display("Actual: %s({%f, %f, %f}, %f) = %f", `"func`", fp_to_real(vec.x), fp_to_real(vec.y), fp_to_real(vec.z), halfExtents, fp_to_real(val)); \
  // passed = $abs(fp_to_real(val)-distance) < 1e-4; \
  // all_passed = all_passed & passed; \
  // $display("%s", passed ? "PASSED" : "FAILED"); \
  // $display(""); \
    // `TEST_SDF_PRIMITIVES(sd_box_fast, 0, 0.5, 0, 0.5, 0);
    // `TEST_SDF_PRIMITIVES(sd_box_fast, 0, 0, 1, 0.5, 0.5);

    $display("%s", all_passed ? "ALL PASSED": "SOME FAILED");

    $display("Finishing Sim");
    $finish;
  end
endmodule // sdf_primitives_tb

`default_nettype wire
