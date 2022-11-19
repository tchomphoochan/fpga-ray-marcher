`timescale 1ns / 1ps
`default_nettype none

`include "types.sv"
`include "fixed_point_arith.sv"

module fp_inv_sqrt_folded(
  input logic clk_in,
  input logic rst_in,
  input fp a_in,
  input logic valid_in,
  output fp res_out,
  output logic valid_out,
  output logic ready_out
);

  parameter MAX_NEWTON_ITER = 2;

  logic [3:0] stage;
  logic [2:0] newton_iter; // 0,1
  logic [2:0] newton_iter_step; // 0,1,2

  // constant
  fp slope = fp_mul(`FP_TWO, fp_sub(`FP_SQRT_TWO, `FP_ONE));

  // step 0: receive input
  fp original;
  // step 1: count leading zero and shift
  logic [$clog2(`NUM_WHOLE_DIGITS):0] diff, _diff;
  assign _diff = `NUM_WHOLE_DIGITS - fp_count_leading_zeros(original);
  // step 2: first approximation
  fp x;
  // step 3: perform newton
  fp x_mult;
  // step 4: shift answer, output
  fp x_shifted;
  assign x_shifted = x >> (diff >> 1);

  assign res_out = x;

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      stage <= 0;
      valid_out <= 0;
      ready_out <= 1;
    end else if (stage == 0 && valid_in) begin
      valid_out <= 0;
      ready_out <= 0;
      // step 0: receive input
      original <= a_in;
      stage <= 1;
    end else if (stage == 1) begin
      // step 1: count leading zero and shift
      diff <= _diff;
      original <= original >> _diff;
      stage <= 2;
    end else if (stage == 2) begin
      // step 2: first approximation
      x <= fp_sub(`FP_SQRT_TWO,
                  fp_mul(slope,
                         fp_sub(original, `FP_HALF)));
      stage <= 3;
      newton_iter <= 0;
      newton_iter_step <= 0;
    end else if (stage == 3) begin
      // step 3: newton
      if (newton_iter_step == 0) begin
        x_mult <= fp_mul(x,x);
        newton_iter_step <= 1;
      end else if (newton_iter_step == 1) begin
        x_mult <= fp_mul(original>>1, x_mult);
        newton_iter_step <= 2;
      end else if (newton_iter_step == 2) begin
        x <= fp_mul(x, fp_sub(`FP_THREE_HALFS, x_mult));
        newton_iter_step <= 0;
        newton_iter <= newton_iter + 1;
        if (newton_iter+1 == MAX_NEWTON_ITER)begin
          stage <= 4;
        end
      end
    end else if (stage == 4) begin
      // step 4: shift answer, output
      x <= (diff & 1) ? fp_mul(x_shifted, `FP_INV_SQRT_TWO) : x_shifted;
      valid_out <= 1;
      ready_out <= 1;
      stage <= 0;
    end
  end

endmodule // fv_inv_sqrt_folded

`default_nettype wire
