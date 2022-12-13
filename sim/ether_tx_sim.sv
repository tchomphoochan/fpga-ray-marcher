`timescale 1ns / 1ps
`default_nettype none

`include "types.svh"

module ether_tx_sim;

  logic clk_in, rst_in, trigger_in, eth_txen, ready_out, data_ready_out, last_dibit_in;
  logic [1:0] data_in, eth_txd;

  always begin
    #5;
    clk_in = !clk_in;
  end

  always begin
    $display("[%4d] ready_out=%d, data_ready_out=%d, eth_txen=%d, eth_txd=%b", $time, ready_out, data_ready_out, eth_txen, eth_txd);
    #10;
  end

  ether_tx uut(
    .clk_in(clk_in),
    .rst_in(rst_in),

    .trigger_in(trigger_in),
    .data_in(data_in),
    .last_dibit_in(last_dibit_in),

    .ready_out(ready_out),
    .data_ready_out(data_ready_out),
    .eth_txen(eth_txen),
    .eth_txd(eth_txd)
  );

  // 80 bits = 10 bytes = 40 dibits
  // logic [79:0] data = 80'hFFFFFFFFFF_1111111111;
  logic [79:0] data = 80'd0;

  initial begin
    $dumpfile("ether_tx_sim.vcd");
    $dumpvars(0, ether_tx_sim);
    $display("Starting Sim");
    // initialize
    clk_in = 0;
    rst_in = 0;
    trigger_in = 0;
    data_in = 0;
    last_dibit_in = 0;
    #10;
    rst_in = 1;
    #10;
    rst_in = 0;
    #100;

    $display("[%4d] set trigger in to 1", $time);
    trigger_in = 1;
    #10;
    trigger_in = 0;

    wait(data_ready_out);
    #5;
    $display("[%4d] data is now ready", $time);
    for (int i = 39; i >= 0; --i) begin
      if (i == 0) last_dibit_in = 1;
      data_in = {data[2*i+1], data[2*i]};
      $display("[%4d] set data_in (dibit %d): %b", $time, i, data_in);
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
endmodule // ether_tx_sim

`default_nettype wire
