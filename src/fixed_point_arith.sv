`timescale 1ns / 1ps
`default_nettype none

`ifndef FIXED_POINT_ARITH_SV
`define FIXED_POINT_ARITH_SV

`include "types.sv"

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
  logic [2*`NUM_ALL_DIGITS-1:0] result;
  result = a*b;
  return $signed(result >> `NUM_FRAC_DIGITS);
endfunction
// not so basic operations
// should not synthesize this
function automatic fp fp_inv_sqrt(input fp a);
  fp half = fp_from_real(0.5);
  fp threehalfs = fp_from_real(1.5);
  fp sqrttwo = fp_from_real($sqrt(2.0));
  fp slope = fp_from_real(2*($sqrt(2.0) - 1));
  fp x = fp_sub(sqrttwo,
                fp_mul(slope,
                       fp_sub(a, half))); // first approximation, good for a in [0.5,1]
  x = fp_mul(x,
             fp_sub(threehalfs,
                    fp_mul(fp_mul(half, a),
                           fp_mul(x, x))));
  x = fp_mul(x,
             fp_sub(threehalfs,
                    fp_mul(fp_mul(half, a),
                           fp_mul(x, x))));
  return x;
endfunction
function automatic fp fp_mod(input fp a, input fp b);
  // TODO
  return a;
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
  return a < 0 ? fp_neg(a) : a;
endfunction

// conversion
// not synthesizable!
function automatic fp fp_from_real(input real a);
  logic [`NUM_WHOLE_DIGITS-1:0] whole = $floor(a);
  real frac = a-whole;
  logic [`NUM_FRAC_DIGITS-1:0] frac_bits = $floor(frac * $itor(1<<`NUM_FRAC_DIGITS));
  return {whole, frac_bits};
endfunction

// not synthesizable!
function automatic real fp_to_real(input fp a);
  return $itor(a) * `SCALING_FACTOR;
endfunction

`endif

`default_nettype wire
