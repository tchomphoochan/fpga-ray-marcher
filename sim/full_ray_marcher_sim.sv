`timescale 1ns / 1ps
`default_nettype none

`include "types.svh"

module full_ray_marcher_sim;

  // for testing
  vec3 pos_vec_def, dir_vec_def;
  assign pos_vec_def.x = `FP_ZERO;
  assign pos_vec_def.y = `FP_ONE;
  assign pos_vec_def.z = fp_neg(`FP_THREE_HALFS);
  assign dir_vec_def.x = `FP_ZERO;
  assign dir_vec_def.y = `FP_ZERO;
  assign dir_vec_def.z = `FP_ONE;

  logic clk_in;
  logic rst_in;
  vec3 pos_vec_in;
  vec3 dir_vec_in;
  logic [2:0] fractal_sel_in;
  logic toggle_checker_in;

  // rendered output
  logic [`H_BITS-1:0] hcount_out;
  logic [`V_BITS-1:0] vcount_out;
  logic [3:0] color_out;
  logic valid_out;
  logic new_frame_out;

  assign toggle_checker_in = 0;
  assign toggle_dither_in = 1;
  assign pos_vec_in = pos_vec_def;
  assign dir_vec_in = dir_vec_def;
  assign fractal_sel_in = 0;

  ray_marcher #(
    .DISPLAY_WIDTH(`DISPLAY_WIDTH),
    .DISPLAY_HEIGHT(`DISPLAY_HEIGHT),
    .H_BITS(`H_BITS),
    .V_BITS(`V_BITS),
    .COLOR_BITS(4),
    .NUM_CORES(`NUM_CORES)
  ) uut(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .pos_vec_in(pos_vec_in),
    .dir_vec_in(dir_vec_in),
    .toggle_checker_in(toggle_checker_in),
    .toggle_dither_in(toggle_dither_in),
    .fractal_sel_in(fractal_sel_in),
    .hcount_out(hcount_out),
    .vcount_out(vcount_out),
    .color_out(color_out),
    .valid_out(valid_out),
    .new_frame_out(new_frame_out)
  );

  always begin
    #5;
    clk_in = !clk_in;
  end

  initial begin
    $dumpfile("full_ray_marcher_sim.vcd");
    $dumpvars(0, full_ray_marcher_sim);
    $display("Starting Sim");
    // initialize
    clk_in = 0;
    rst_in = 0;
    #10;
    rst_in = 1;
    #10;
    rst_in = 0;
    #100;
    $display("Simulating until finish rendering this frame");
    wait(new_frame_out);
    $display("Finishing Sim");
    $display("Took %f nanoseconds", $time);
    $finish;
  end
endmodule // ray_marcher_tb

`default_nettype wire
