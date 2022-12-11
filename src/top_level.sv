`timescale 1ns / 1ps
`default_nettype none

`include "types.svh"

// this one just dispatches to other test programs
// the real top_level is in top_level_main

module top_level(
  input wire clk_100mhz,
  input wire btnc,
  input wire btnl, btnr, btnu, btnd, cpu_resetn,
  input wire [15:0] sw,
  input wire ps2_clk,
  input wire ps2_data,
  output logic [15:0] led,
  output logic led17_r,
  output logic led16_b,
  output logic [3:0] vga_r, vga_g, vga_b,
  output logic vga_hs, vga_vs,
  output logic ca, cb, cc, cd, ce, cf, cg,
  output logic [7:0] an,
  output logic eth_rstn, eth_txen, eth_refclk,
  output logic [1:0] eth_txd
);

  // top_level_fixed_point_tester top_level_fixed_point_tester_inst(
  //   .clk_100mhz(clk_100mhz),
  //   .btnc(btnc),
  //   .btnl(btnl),
  //   .btnr(btnr),
  //   .btnu(btnu),
  //   .btnd(btnd),
  //   .sw(sw),
  //   .led(led),
  //   .led17_r(led17_r),
  //   .led16_b(led16_b)
  // );

  // top_level_vga_bram_tester top_level_vga_bram_tester_inst(
  //   .clk_100mhz(clk_100mhz),
  //   .btnc(btnc),
  //   .btnu(btnu),
  //   .vga_r(vga_r),
  //   .vga_g(vga_g),
  //   .vga_b(vga_b),
  //   .vga_hs(vga_hs),
  //   .vga_vs(vga_vs),
  //   .led(led)
  // );

  top_level_main top_level_main_inst(
    .clk_100mhz(clk_100mhz),
    .btnc(btnc),
    .btnl(btnl),
    .btnr(btnr),
    .btnu(btnu),
    .btnd(btnd),
    .cpu_resetn(cpu_resetn),
    .sw(sw),
    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data),
    .vga_r(vga_r),
    .vga_g(vga_g),
    .vga_b(vga_b),
    .vga_hs(vga_hs),
    .vga_vs(vga_vs),
    .led(led),
    .ca(ca), .cb(cb), .cc(cc), .cd(cd), .ce(ce), .cf(cf), .cg(cg),
    .an(an),
    .eth_rstn(eth_rstn), .eth_txen(eth_txen), .eth_refclk(eth_refclk),
    .eth_txd(eth_txd)
  );


endmodule // top_level

`default_nettype wire
