`timescale 1ns / 1ps
`default_nettype none

module fps_counter_tb;

  parameter WIDTH = 32;
  parameter ONE_SECOND_CYCLES = 'd1000;
  parameter WAIT_SECONDS = 'd10;

  parameter PROB_NUMER = 1;
  parameter PROB_DENOM = 10;

  logic clk_in;
  logic rst_in;
  logic new_frame_in;
  logic [WIDTH-1:0] fps_out;

  fps_counter #(
    .WIDTH(WIDTH),
    .ONE_SECOND_CYCLES(ONE_SECOND_CYCLES),
    .WAIT_SECONDS(WAIT_SECONDS)
  ) uut(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .new_frame_in(new_frame_in),
    .fps_out(fps_out)
  );

  logic all_passed = 1;

  always begin
    #5;
    clk_in = !clk_in;
  end

  initial begin
    $dumpfile("fps_counter.vcd");
    $dumpvars(0, fps_counter_tb);
    $display("Starting Sim");
    // initialize
    clk_in = 0;
    rst_in = 0;
    new_frame_in = 0;
    #10;
    // reset machine
    rst_in = 1;
    #10;
    rst_in = 0;
    $display("Running %1d cycles per seconds.\nProbability: %1d/%1d, expected: %1d", ONE_SECOND_CYCLES, PROB_NUMER, PROB_DENOM, ONE_SECOND_CYCLES*PROB_NUMER/PROB_DENOM);
    $monitor("FPS: %5d", fps_out);
    for (int i = 0; i < ONE_SECOND_CYCLES * WAIT_SECONDS * 30; ++i) begin
      new_frame_in = $urandom_range(PROB_DENOM-1, 0) < PROB_NUMER;
      #10;
    end
    $display("Ran %1d cycles per seconds.\nProbability: %1d/%1d, expected: %1d", ONE_SECOND_CYCLES, PROB_NUMER, PROB_DENOM, ONE_SECOND_CYCLES*PROB_NUMER/PROB_DENOM);

    $display("Finishing Sim");
    $finish;
  end
endmodule // fps_counter_tb

`default_nettype wire
