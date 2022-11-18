`timescale 1ns / 1ps
`default_nettype none

`include "types.sv"

// this one just dispatches to other test programs
// the real top_level is in top_level_main

module top_level(
  input wire clk_100mhz,
  input wire btnc,
  input wire btnl, btnr, btnu, btnd,
  input wire [15:0] sw,
  output logic [15:0] led,
  output logic led17_r,
  output logic led16_b,
  output logic [3:0] vga_r, vga_g, vga_b,
  output logic vga_hs, vga_vs
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

  top_level_main top_level_main_inst(
    .clk_100mhz(clk_100mhz),
    .btnc(btnc),
    .btnl(btnl),
    .btnr(btnr),
    .btnu(btnu),
    .btnd(btnd),
    .sw(sw),
    .vga_r(vga_r),
    .vga_g(vga_g),
    .vga_hs(vga_hs),
    .vga_vs(vga_vs)
  );

  assign led17_r = 0;
  assign led16_b = 0;

endmodule // top_level

`default_nettype wire
