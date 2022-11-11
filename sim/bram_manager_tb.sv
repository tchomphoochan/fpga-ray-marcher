`timescale 1ns / 1ps
`default_nettype none

module bram_manager_tb;
  parameter WIDTH = 32;
  parameter DEPTH = 32;
  parameter ADDR_LEN = 5;

  logic cycle;
  logic clk;
  logic rst;

  logic swap_buffers;
  logic [ADDR_LEN-1:0] read_addr;
  logic [ADDR_LEN-1:0] write_addr;
  logic write_enable;
  logic [WIDTH-1:0] write_data;
  logic [WIDTH-1:0] read_data_out;
  logic which_bram_out;

  bram_manager #(.WIDTH(WIDTH), .DEPTH(DEPTH), .ADDR_LEN(ADDR_LEN)) uut(
    .clk(clk),
    .rst(rst),
    .swap_buffers(swap_buffers),
    .read_addr(read_addr),
    .write_enable(write_enable),
    .write_addr(write_addr),
    .write_data(write_data),
    .read_data_out(read_data_out),
    .which_bram_out(which_bram_out)
  );

  always begin
    #5;
    clk = !clk;
  end

  // always begin
  //   #1;
  //   $display("[%8d] rst=%d, swap_buffers=%d, read_addr=%d, write_addr=%d, write_enable=%d, write_data=%x, read_data_out=%x, which_bram_out=%d",
  //     $time, rst, swap_buffers, read_addr, write_addr, write_enable, write_data, read_data_out, which_bram_out);
  //   #9;
  // end

  initial begin
    $dumpfile("bram_manager.vcd");
    $dumpvars(0, bram_manager_tb);
    $display("Starting Sim");
    clk = 0;
    rst = 0;
    swap_buffers = 0;
    write_enable = 0;
    #10;
    rst = 1;
    #10;
    rst = 0;

    for (int i = 0; i < 1000; ++i) begin
      write_addr = i;
      read_addr = i;
      write_enable = 1;
      write_data = i;
      swap_buffers = i%79 == 0;
      $display("[%8d] rst=%d, swap_buffers=%d, read_addr=%d, write_addr=%d, write_enable=%d, write_data=%x, read_data_out=%x, which_bram_out=%d",
        $time, rst, swap_buffers, read_addr, write_addr, write_enable, write_data, read_data_out, which_bram_out);
      #10;
    end

    $display("Finishing Sim");
    $finish;
  end
endmodule // bram_manager_tb

`default_nettype wire
