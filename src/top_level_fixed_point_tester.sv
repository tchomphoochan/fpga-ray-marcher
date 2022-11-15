`timescale 1ns / 1ps
`default_nettype none

`include "types.sv"
`include "fixed_point_arith.sv"

module top_level_fixed_point_tester(
  input wire clk_100mhz,
  input wire btnc,
  input wire btnl, btnr, btnu, btnd,
  input wire [15:0] sw,
  output logic [15:0] led,
  output logic led17_r,
  output logic led16_b
);
  logic sys_rst = btnc;

  fp a, b, c; // assuming Q12.20
  assign a = {8'b0, sw[7:0], 16'b0}; 
  assign b = {8'b0, sw[15:8], 16'b0};
  assign led = c[27:27-16+1];

  fixed_point_alu fixed_point_alu_inst(
    .d0_in(a),
    .d1_in(b),
    .sel_in({btnl, btnu, btnr}),
    .res_out(c),
    .gt_out(led16_b),
    .eq_out(led17_r)
  );

endmodule // top_level_fixed_point_tester

`default_nettype wire
