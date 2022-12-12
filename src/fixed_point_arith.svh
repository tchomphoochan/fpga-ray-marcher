`timescale 1ns / 1ps
`default_nettype none

`ifndef FIXED_POINT_ARITH_SVH
`define FIXED_POINT_ARITH_SVH

`include "types.svh"

// basic operations
function automatic fp fp_neg(input fp a);
  return -a;
endfunction
function automatic fp fp_add(input fp a, input fp b);
  return a+b;
endfunction
function automatic fp fp_sub(input fp a, input fp b);
  return a-b;
endfunction
function automatic fp fp_mul(input fp a, input fp b);
  // TODO probably stress test signed multiplication carefully
  logic signed [2*`NUM_ALL_DIGITS-1:0] result;
  result = $signed(a)*$signed(b);
  return $signed(result >> $signed(`NUM_FRAC_DIGITS));
endfunction

// comparison
function automatic logic fp_lt(input fp a, input fp b);
  return a < b;
endfunction
function automatic logic fp_gt(input fp a, input fp b);
  return a > b;
endfunction
function automatic fp fp_min(input fp a, input fp b);
  return fp_lt(a,b) ? a : b;
endfunction
function automatic fp fp_max(input fp a, input fp b);
  return fp_gt(a,b) ? a : b;
endfunction
function automatic fp fp_abs(input fp a);
  return $signed(a) < $signed(0) ? fp_neg(a) : a;
endfunction
function automatic fp fp_apply_sign(input fp a, input fp b);
  return $signed(b) < $signed(0) ? fp_neg(a) : a;
endfunction
function automatic fp fp_sign(input fp a);
  return fp_apply_sign(`FP_ONE, a);
endfunction

function automatic fp fp_mul_half(input fp a);
  return $signed(a) >> $signed(1);
endfunction
function automatic fp fp_sl(input fp a, int b);
  return $signed(a) << $signed(b);
endfunction
function automatic fp fp_sr(input fp a, int b);
  return $signed(a) >> $signed(b);
endfunction
function automatic fp fp_mul_2(input fp a);
  return a << 1;
endfunction
function automatic fp fp_mul_3(input fp a);
  return fp_add(a << 1, a);
endfunction
function automatic fp fp_mul_4(input fp a);
  return a << 2;
endfunction
function automatic fp fp_mul_5(input fp a);
  return fp_add(a << 2, a);
endfunction
function automatic fp fp_mul_6(input fp a);
  return fp_add(a << 2, a << 1);
endfunction
function automatic fp fp_mul_7(input fp a);
  return fp_sub(a << 3, a);
endfunction
function automatic fp fp_mul_8(input fp a);
  return a << 3;
endfunction

// conversion
// not synthesizable!
function automatic fp fp_from_real(input real a);
  logic [`NUM_WHOLE_DIGITS-1:0] whole = $floor(a);
  real frac = a-whole;
  logic [`NUM_FRAC_DIGITS-1:0] frac_bits = $floor(frac * $itor(1<<`NUM_FRAC_DIGITS));
  return {whole, frac_bits};
endfunction

function automatic [$clog2(`NUM_WHOLE_DIGITS):0] fp_count_leading_zeros(input fp a);
  for (int i = 0; i < `NUM_WHOLE_DIGITS; i++) begin
    if (a[`NUM_ALL_DIGITS-1-i] == 1)
      return i;
  end
  return `NUM_WHOLE_DIGITS;
endfunction

// not so basic operations
// should not synthesize this
`ifdef USE_FAKE_INV_SQRT
function automatic fp fp_inv_sqrt(input fp a);
  return fp_from_real(1/$sqrt(fp_to_real(a)));
endfunction
`else
function automatic fp fp_inv_sqrt(input fp _a);
  // 0.5 should have `NUM_WHOLE_DIGITS leading zeros
  logic [$clog2(`NUM_WHOLE_DIGITS):0] cnt = fp_count_leading_zeros(_a);
  logic [$clog2(`NUM_WHOLE_DIGITS):0] diff = `NUM_WHOLE_DIGITS - cnt;
  fp a = _a >> diff; // if has less than that (i.e. number is too large), must shift
  // work with that number
  fp slope = fp_mul(`FP_TWO, fp_sub(`FP_SQRT_TWO, `FP_ONE));
  fp x = fp_sub(`FP_SQRT_TWO,
                fp_mul(slope,
                       fp_sub(a, `FP_HALF))); // first approximation, good for a in [0.5,1]
  x = fp_mul(x,
             fp_sub(`FP_THREE_HALFS,
                    fp_mul(fp_mul(`FP_HALF, a),
                           fp_mul(x, x)))); // one newton iteration
  x = fp_mul(x,
             fp_sub(`FP_THREE_HALFS,
                    fp_mul(fp_mul(`FP_HALF, a),
                           fp_mul(x, x)))); // one newton iteration
  // must shift answer properly
  x = x >> (diff >> 1);
  x = (diff & 1) ? fp_mul(x, `FP_INV_SQRT_TWO) : x;
  return x;
endfunction
`endif

function automatic fp fp_mod(input fp a, input fp b);
  // TODO
  return a;
endfunction
function automatic fp fp_floor(input fp a);
  return ($signed(a) >> $signed(`NUM_FRAC_DIGITS)) << `NUM_FRAC_DIGITS;
endfunction
function automatic fp fp_fract(input fp a);
  return fp_sub(a, fp_floor(a));
endfunction

// not synthesizable!
function automatic real fp_to_real(input fp a);
  return $itor(a) * `SCALING_FACTOR;
endfunction

`endif

`default_nettype wire
