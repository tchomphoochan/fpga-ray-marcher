`timescale 1ns / 1ps
`default_nettype none

`include "types.svh"

module ether_export_test;

  logic clk_in, rst_in, trigger_in;
  logic eth_txen;
  logic [1:0] eth_txd;
  logic [`ADDR_BITS-1:0] ether_read_addr;
  logic [3:0] bram_read_data;
  // assign bram_read_data = 4'b1111;

  always begin
    #10;
    $display("[%4d] OUTPUT eth_txen=%d, eth_txd=%b", $time, eth_txen, eth_txd);
  end

  always begin
    #5;
    clk_in = !clk_in;
  end

  ether_export ether_export_uut(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .export_trigger_in(trigger_in),
    .read_data_in(bram_read_data),
    .read_addr_out(ether_read_addr),
    .eth_txen(eth_txen),
    .eth_txd(eth_txd)
  );

  bram_manager #(
    .WIDTH(4),
    .DEPTH(`BRAM_SIZE),
    .ADDR_LEN(`ADDR_BITS)
  ) bram_manager_inst(
    .clk(clk_in),
    .rst(rst_in),
    .swap_buffers(1'b0),
    .read_addr(ether_read_addr),
    .write_enable(1'b0),
    .read_data_out(bram_read_data)
  );

  initial begin
    $dumpfile("ether_export_test.vcd");
    $dumpvars(0, ether_export_test);
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
    #10;

    for (int i = 0; i < 1000; ++i) begin
      #10;
    end

    $display("Finishing Sim");
    $display("Took %f nanoseconds", $time);
    $finish;
  end
endmodule // ether_export_test

`default_nettype wire
