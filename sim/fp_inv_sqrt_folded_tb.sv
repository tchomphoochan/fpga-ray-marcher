`timescale 1ns / 1ps
`default_nettype none

`include "types.sv"
`include "fixed_point_arith.sv"

`define TEST_FP_OP_1(op, func, v1) \
  wait(ready_out); \
  inval = v1; \
  outval = op(inval); \
  infp = fp_from_real(inval); \
  valid_in = 1; \
  #10; \
  #10; \
  wait(valid_out); \
  $display("Expected: %s(%f) = %f", `"op`", inval, outval); \
  $display("Actual: %s(%f) = %f  (32'h%h)", `"func`", fp_to_real(infp), fp_to_real(outfp), outfp); \
  passed = $abs(fp_to_real(outfp)-outval) < tolerance; \
  all_passed = all_passed & passed; \
  $display("%s", passed ? "PASSED" : "FAILED"); \
  $display("");

module fp_inv_sqrt_folded_tb;
  logic clk, rst;

  real inval, outval, tolerance;
  fp infp, outfp;
  logic valid_in, ready_out, valid_out;

  logic all_passed = 1;
  logic passed;

  fp_inv_sqrt_folded uut(
    .clk_in(clk),
    .rst_in(rst),
    .a_in(infp),
    .valid_in(valid_in),
    .res_out(outfp),
    .valid_out(valid_out),
    .ready_out(ready_out)
  );

  always begin
    #5;
    clk = !clk;
  end

  initial begin
    $dumpfile("fp_inv_sqrt_folded.vcd");
    $dumpvars(0, fp_inv_sqrt_folded_tb);
    $display("Starting Sim");

    // initialize
    clk = 0;
    rst = 0;
    valid_in = 0;
    #10;
    // reset machine
    rst = 1;
    #10;
    // start
    rst = 0;
    #100;

    tolerance = 1e-4;
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

    $display("%s", all_passed ? "ALL PASSED": "SOME FAILED");

    $display("Finishing Sim");
    $finish;
  end
endmodule // fp_inv_sqrt_folded_tb

`default_nettype wire
