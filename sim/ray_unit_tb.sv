`timescale 1ns / 1ps
`default_nettype none

`define TESTING_RAY_UNIT

module ray_unit_tb;

  parameter DISPLAY_WIDTH = 400;
  parameter DISPLAY_HEIGHT = 300;
  parameter H_BITS = 9;
  parameter V_BITS = 9;

  logic clk_in;
  logic rst_in;
  logic valid_in;
  vec3 ray_origin_in;
  vec3 ray_direction_in;
  logic [2:0] fractal_sel_in;
  logic [H_BITS-1:0] hcount_in;
  logic [V_BITS-1:0] vcount_in;
  // rendered output
  logic [H_BITS-1:0] hcount_out;
  logic [V_BITS-1:0] vcount_out;
  logic [3:0] color_out;
  logic ready_out;

  ray_unit #(
    .DISPLAY_WIDTH(DISPLAY_WIDTH),
    .DISPLAY_HEIGHT(DISPLAY_HEIGHT),
    .H_BITS(H_BITS),
    .V_BITS(V_BITS)
  ) uut(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .valid_in(valid_in),
    .ray_origin_in(ray_origin_in),
    .ray_direction_in(ray_direction_in),
    .fractal_sel_in(fractal_sel_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .hcount_out(hcount_out),
    .vcount_out(vcount_out),
    .color_out(color_out),
    .ready_out(ready_out)
  );

  logic all_passed = 1;

  always begin
    #5;
    clk_in = !clk_in;
  end

  initial begin
    $dumpfile("ray_unit.vcd");
    $dumpvars(0, ray_unit_tb);
    $display("Starting Sim");
    // initialize
    clk_in = 0;
    rst_in = 0;
    ray_origin_in = make_vec3(fp_from_real(0), fp_from_real(0), fp_from_real(-2));
    ray_direction_in = make_vec3(fp_from_real(0), fp_from_real(0), fp_from_real(1));
    fractal_sel_in = 0;
    hcount_in = 150;
    vcount_in = 140;
    #10;

    // reset machine
    valid_in = 1;
    rst_in = 1;
    #10;
    rst_in = 0;
    #10;
    valid_in = 0;

    #10;
    // first cycle starts here

    wait(ready_out);
    #100;

    // $display("%s", all_passed ? "ALL PASSED": "SOME FAILED");

    $display("Finishing Sim");
    $finish;
  end
endmodule // ray_unit_tb

`default_nettype wire
