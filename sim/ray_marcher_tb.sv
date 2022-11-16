`timescale 1ns / 1ps
`default_nettype none

module ray_marcher_tb;

  parameter H_BITS = 4;
  parameter V_BITS = 3;

  logic clk_in;
  logic rst_in;
  vec3 pos_vec_in;
  vec3 dir_vec_in;
  wire [2:0] fractal_sel_in;
  // rendered output
  logic [H_BITS-1:0] hcount_out;
  logic [V_BITS-1:0] vcount_out;
  logic [3:0] color_out;
  logic valid_out;
  logic new_frame_out;

  ray_marcher #(
    .DISPLAY_WIDTH(10),
    .DISPLAY_HEIGHT(5),
    .H_BITS(H_BITS),
    .V_BITS(V_BITS),
    .COLOR_BITS(4),
    .NUM_CORES(4)
  ) uut(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .pos_vec_in(pos_vec_in),
    .dir_vec_in(dir_vec_in),
    .fractal_sel_in(fractal_sel_in),
    .hcount_out(hcount_out),
    .vcount_out(vcount_out),
    .color_out(color_out),
    .valid_out(valid_out),
    .new_frame_out(new_frame_out)
  );

  logic all_passed = 1;

  always begin
    #5;
    clk_in = !clk_in;
  end

  always begin
    #1;
    $monitor("");
  end

  initial begin
    $dumpfile("ray_marcher.vcd");
    $dumpvars(0, ray_marcher_tb);
    $display("Starting Sim");

    $display("%s", all_passed ? "ALL PASSED": "SOME FAILED");

    $display("Finishing Sim");
    $finish;
  end
endmodule // ray_marcher_tb

`default_nettype wire
