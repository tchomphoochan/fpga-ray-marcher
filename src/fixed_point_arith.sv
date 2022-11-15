`timescale 1ns / 1ps
`default_nettype none

package fixed_point_arith;

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

endpackage // fixed_point_arith

`default_nettype wire
