`timescale 1ns / 1ps
`default_nettype none

`include "types.sv"
`include "fixed_point_arith.sv"
`include "vector_arith.sv"
`include "sdf_primitives.sv"

`define TEST_SDF_PRIMITIVES(func, x1, y1, z1, halfExtents1, distance1) \
  vec = make_vec3(fp_from_real(x1), fp_from_real(y1), fp_from_real(z1)); \
  val = func(vec, fp_from_real(halfExtents1)); \
  $display("Expected: ({%f, %f, %f}, %f) = %f", x1, y1, z1, halfExtents1, distance1); \
  $display("Actual: ({%f, %f, %f}, %f) = %f", fp_to_real(vec.x), fp_to_real(vec.y), fp_to_real(vec.z), halfExtents1, fp_to_real(val)); \
  passed = $abs(fp_to_real(val)-distance1) < 1e-4; \
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
    vec = make_vec3(fp_from_real(0), fp_from_real(0), fp_from_real(0));
    val = sd_box_fast(vec, fp_from_real(0.5));
    $display("Expected: %s({%f, %f, %f}, %f) = %f", "sd_box_fast", 0, 0, 0, 0.5, -0.5);
    $display("Actual: %s({%f, %f, %f}, %f) = %f", "sd_box_fast", fp_to_real(vec.x), fp_to_real(vec.y), fp_to_real(vec.z), 0.5, fp_to_real(val));
    passed = $abs(fp_to_real(val)-(-0.5)) < 1e-4;
    all_passed = all_passed & passed;
    $display("%s", passed ? "PASSED" : "FAILED");
    $display("");
    // `TEST_SDF_PRIMITIVES(sd_box_fast, 0, 0.5, 0, 0.5, 0);
    // `TEST_SDF_PRIMITIVES(sd_box_fast, 0, 0, 1, 0.5, 0.5);

    $display("%s", all_passed ? "ALL PASSED": "SOME FAILED");

    $display("Finishing Si1m");
    $finish;
  end
endmodule // sdf_primitives_tb

`default_nettype wire
