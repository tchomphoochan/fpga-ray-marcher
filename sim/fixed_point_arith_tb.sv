`timescale 1ns / 1ps
`default_nettype none

`include "types.svh"
`include "fixed_point_arith.svh"

function automatic real fract(input real a);
  return a-$floor(a);
endfunction

`define TEST_FP_OP_1(op, func, v1) \
  aval = v1; \
  cval = op(aval); \
  a = fp_from_real(aval); \
  c = func(a); \
  $display("Expected: %s(%f) = %f", `"op`", aval, cval); \
  $display("Actual: %s(%f) = %f  (32'h%h)", `"func`", fp_to_real(a), fp_to_real(c), c); \
  passed = $abs(fp_to_real(c)-cval) < tolerance; \
  all_passed = all_passed & passed; \
  $display("%s", passed ? "PASSED" : "FAILED"); \
  $display(""); \
  #10; \

`define TEST_FP_OP_2(op, func, v1, v2) \
  aval = v1; \
  bval = v2; \
  cval = aval op bval; \
  a = fp_from_real(aval); \
  b = fp_from_real(bval); \
  c = func(a, b); \
  $display("Expected: %f %s %f = %f", aval, `"op`", bval, cval); \
  $display("Actual: %s(%f, %f) = %f  (32'h%h)", `"func`", fp_to_real(a), fp_to_real(b), fp_to_real(c), c); \
  passed = $abs(fp_to_real(c)-cval) < tolerance; \
  all_passed = all_passed & passed; \
  $display("%s", passed ? "PASSED" : "FAILED"); \
  $display(""); \
  #10; \

`define TEST_FP_FUNC_2(op, func, v1, v2) \
  aval = v1; \
  bval = v2; \
  cval = op(aval, bval); \
  a = fp_from_real(aval); \
  b = fp_from_real(bval); \
  c = func(a, b); \
  $display("Expected: %s(%f, %f) = %f", `"op`", aval, bval, cval); \
  $display("Actual: %s(%f, %f) = %f  (32'h%h)", `"func`", fp_to_real(a), fp_to_real(b), fp_to_real(c), c); \
  passed = $abs(fp_to_real(c)-cval) < tolerance; \
  all_passed = all_passed & passed; \
  $display("%s", passed ? "PASSED" : "FAILED"); \
  $display(""); \
  #10; \

module fixed_point_arith_tb;

  real aval, bval, cval, tolerance;
  fp a, b, c;

  logic all_passed = 1;
  logic passed;

  initial begin
    $dumpfile("fixed_point_arith.vcd");
    $dumpvars(0, fixed_point_arith_tb);
    $display("Starting Sim");

    tolerance = 1e-4;
    `TEST_FP_OP_1(-, fp_neg, 3.14159);
    `TEST_FP_OP_1(-, fp_neg, -3.14159);
    `TEST_FP_OP_1($abs, fp_abs, 3.14159);
    `TEST_FP_OP_1($abs, fp_abs, -3.14159);
    `TEST_FP_OP_2(+, fp_add, 3.242, 958.21434);
    `TEST_FP_OP_2(-, fp_sub, 3.242, 958.21434);
    `TEST_FP_OP_2(*, fp_mul, 3.242, 98.21434);
    `TEST_FP_OP_2(-, fp_sub, 0, 1024);
    `TEST_FP_OP_2(-, fp_sub, 0, 2047);
    `TEST_FP_OP_2(-, fp_sub, 0, -2047);
    `TEST_FP_OP_2(+, fp_add, 0.00001, 2047.999);
    `TEST_FP_OP_2(*, fp_mul, 69.696969, 3.111111);
    `TEST_FP_OP_2(*, fp_mul, -69.696969, 3.111111);
    `TEST_FP_OP_2(*, fp_mul, -69.696969, -3.111111);
    `TEST_FP_OP_2(*, fp_mul, 69.696969, -3.111111);
    `TEST_FP_FUNC_2($min, fp_min, 69.696969, -3.111111);
    `TEST_FP_FUNC_2($max, fp_max, 69.696969, -3.111111);

    `TEST_FP_OP_1(1/$sqrt, fp_inv_sqrt, 0.5);
    `TEST_FP_OP_1(1/$sqrt, fp_inv_sqrt, 0.6);
    `TEST_FP_OP_1(1/$sqrt, fp_inv_sqrt, 0.7);
    `TEST_FP_OP_1(1/$sqrt, fp_inv_sqrt, 0.8);
    `TEST_FP_OP_1(1/$sqrt, fp_inv_sqrt, 0.9);
    `TEST_FP_OP_1(1/$sqrt, fp_inv_sqrt, 1.0);
    `TEST_FP_OP_1(1/$sqrt, fp_inv_sqrt, 3.7);
    `TEST_FP_OP_1(1/$sqrt, fp_inv_sqrt, 5.8);
    `TEST_FP_OP_1(1/$sqrt, fp_inv_sqrt, 1.5);
    `TEST_FP_OP_1(1/$sqrt, fp_inv_sqrt, 6.9);

    `TEST_FP_OP_1($floor, fp_floor, 0.5);
    `TEST_FP_OP_1($floor, fp_floor, -0.6);
    `TEST_FP_OP_1($floor, fp_floor, 1.6);
    `TEST_FP_OP_1($floor, fp_floor, -2.4);

    `TEST_FP_OP_1(fract, fp_fract, 0.5);
    `TEST_FP_OP_1(fract, fp_fract, -0.6);
    `TEST_FP_OP_1(fract, fp_fract, 1.6);
    `TEST_FP_OP_1(fract, fp_fract, -2.4);

    $display("%s", all_passed ? "ALL PASSED": "SOME FAILED");

    $display("Finishing Sim");
    $finish;
  end
endmodule // fixed_point_arith_tb

`default_nettype wire
