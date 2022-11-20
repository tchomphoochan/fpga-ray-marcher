`timescale 1ns / 1ps
`default_nettype none

`include "types.svh"
`include "fixed_point_arith.svh"

module fixed_point_alu(
  input fp d0_in,
  input fp d1_in,
  input wire [2:0] sel_in,

  output fp res_out,
  output logic gt_out,
  output logic eq_out
);
  always_comb begin
    eq_out = d1_in == d0_in;
    gt_out = fp_gt(d1_in, d0_in);
    case (sel_in)
      3'b000: res_out = fp_add(d1_in, d0_in);
      3'b100: res_out = fp_sub(d1_in, d0_in);
      3'b001: res_out = fp_mul(d1_in, d0_in);
      3'b110: res_out = fp_min(d1_in, d0_in);
      3'b011: res_out = fp_max(d1_in, d0_in);
      3'b010: res_out = fp_inv_sqrt(d0_in);
      default: res_out = 0;
    endcase
  end

endmodule // fixed_point_alu

`default_nettype wire