`timescale 1ns / 1ps
`default_nettype none

`include "types.svh"

module dummy_ether_tx_sim;

  logic clk_in, rst_in, trigger_in, axiov;
  logic [1:0] axiod;

  always begin
    #5;
    clk_in = !clk_in;
  end

  dummy_ether_tx uut(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .trigger_in(trigger_in),
    .axiov(axiov),
    .axiod(axiod)
  );

  initial begin
    $dumpfile("dummy_ether_tx_sim.vcd");
    $dumpvars(0, dummy_ether_tx_sim);
    $display("Starting Sim");
    // initialize
    clk_in = 0;
    rst_in = 0;
    trigger_in = 0;
    #10;
    rst_in = 1;
    #10;
    rst_in = 0;
    #100;

    trigger_in = 1;
    #10;
    trigger_in = 0;
    for (int i = 0; i < 400; ++i) begin
      $display("[%4d] axiov=%d, axiod=%b", $time, axiov, axiod);
      #10;
    end

    trigger_in = 1;
    #10;
    trigger_in = 0;
    for (int i = 0; i < 400; ++i) begin
      $display("[%4d] axiov=%d, axiod=%b", $time, axiov, axiod);
      #10;
    end

    // for (int i = 0; i < 1000 && (i < 10 || axiov != 0); ++i) begin
    //   $display("[%4d] axiov=%d, axiod=%b", $time, axiov, axiod);
    //   #10;
    // end
    // for (int i = 0; i < 30; ++i) begin
    //   $display("[%4d] axiov=%d, axiod=%b", $time, axiov, axiod);
    //   #10;
    // end

    $display("Finishing Sim");
    $display("Took %f nanoseconds", $time);
    $finish;
  end
endmodule // dummy_ether_tx_sim

`default_nettype wire
