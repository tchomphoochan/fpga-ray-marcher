`timescale 1ns / 1ps
`default_nettype none

`include "vector_arith.sv"

module vector_arith_tb;

  logic all_passed = 1;

  initial begin
    $dumpfile("vector_arith.vcd");
    $dumpvars(0, vector_arith_tb);
    $display("Starting Sim");

    $display("%s", all_passed ? "ALL PASSED": "SOME FAILED");

    $display("Finishing Sim");
    $finish;
  end
endmodule // vector_arith_tb

`default_nettype wire
