`timescale 1ns / 1ps
`default_nettype none

`include "types.svh"

module ether_full_test;

  logic clk_in, rst_in, trigger_in, axiov, ready_out, data_ready_out, started, last_dibit_in;
  logic [1:0] axiod, data_in;

  logic eth_axiov;
  logic [31:0] eth_axiod;

  always begin
    #5;
    clk_in = !clk_in;
  end

  always begin
    #10;
    // if (started)
    //   $display("[%4d] ready_out=%d, data_ready_out=%d, axiov=%d, axiod=%b", $time, ready_out, data_ready_out, axiov, axiod);
    $display("[%4d] OUTPUT eth_axiov=%d, eth_axiod=%h", $time, eth_axiov, eth_axiod);
  end

  ether_tx tx_uut(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .trigger_in(trigger_in),
    .data_in(data_in),
    .last_dibit_in(last_dibit_in),
    .ready_out(ready_out),
    .data_ready_out(data_ready_out),

    .axiov(axiov),
    .axiod(axiod)
  );

  ether_rx_driver rx_uut(
    .clk(clk_in),
    .rst(rst_in),
    .eth_crsdv(axiov),
    .eth_rxd(axiod),
    .axiod(eth_axiod),
    .axiov(eth_axiov)
  );

  // 80 bits = 10 bytes = 40 dibits
  logic [79:0] data = 80'hFFFFFFFFFF_1111111111;

  initial begin
    $dumpfile("ether_full_test.vcd");
    $dumpvars(0, ether_full_test);
    $display("Starting Sim");
    // initialize
    clk_in = 0;
    rst_in = 0;
    trigger_in = 0;
    data_in = 0;
    started = 0;
    last_dibit_in = 0;
    #10;
    rst_in = 1;
    #10;
    rst_in = 0;
    #100;

    trigger_in = 1;
    started = 1;
    #10;
    trigger_in = 0;

    wait(data_ready_out);
    for (int i = 39; i >= 0; --i) begin
      data_in = {data[2*i+1], data[2*i]};
      if (i == 0) last_dibit_in = 1;
      #10;
    end
    last_dibit_in = 0;

    for (int i = 0; i < 100; ++i) begin
      #10;
    end

    $display("Finishing Sim");
    $display("Took %f nanoseconds", $time);
    $finish;
  end
endmodule // ether_full_test

`default_nettype wire
