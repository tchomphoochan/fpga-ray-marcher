`timescale 1ns / 1ps
`default_nettype none

module fixed_point_arith;

  localparam NUM_WHOLE_DIGITS = 12; // including the sign bit
  localparam NUM_FRAC_DIGITS = 20;
  localparam NUM_ALL_DIGITS = NUM_WHOLE_DIGITS + NUM_FRAC_DIGITS;
  localparam SCALING_FACTOR = 2.0 ** (-NUM_FRAC_DIGITS);

  typedef logic signed [NUM_ALL_DIGITS-1:0] FP;

  // basic operations
  function automatic FP FP_neg(input FP a);
    return -a;
  endfunction
  function automatic FP FP_add(input FP a, input FP b);
    return a+b;
  endfunction
  function automatic FP FP_sub(input FP a, input FP b);
    return a-b;
  endfunction
  function automatic FP FP_mul(input FP a, input FP b);
    // TODO probably stress test signed multiplication carefully
    logic [2*NUM_ALL_DIGITS-1:0] result;
    result = a*b;
    return $signed(result >> NUM_FRAC_DIGITS);
  endfunction
  // not so basic operations
  function automatic FP FP_div(input FP a, input FP b);
    // TODO
    return a;
  endfunction
  function automatic FP FP_mod(input FP a, input FP b);
    // TODO
    return a;
  endfunction
  function automatic FP FP_sqrt(input FP a);
    // TODO
    return a;
  endfunction

  // comparison
  function automatic logic FP_lt(input FP a, input FP b);
    return a < b;
  endfunction
  function automatic logic FP_gt(input FP a, input FP b);
    return a > b;
  endfunction
  function automatic FP FP_min(input FP a, input FP b);
    return FP_lt(a,b) ? a : b;
  endfunction
  function automatic FP FP_max(input FP a, input FP b);
    return FP_gt(a,b) ? a : b;
  endfunction
  function automatic FP FP_abs(input FP a);
    return a < 0 ? FP_neg(a) : a;
  endfunction

  // conversion
  function automatic FP FP_from_int(input signed [NUM_WHOLE_DIGITS-1:0] a);
    return {a, 20'b0};
  endfunction

  // not synthesizable!
  function automatic FP FP_from_real(input real a);
    logic [NUM_WHOLE_DIGITS-1:0] whole = $floor(a);
    real frac = a-whole;
    logic [NUM_FRAC_DIGITS-1:0] frac_bits = $floor(frac * $itor(1<<NUM_FRAC_DIGITS));
    return {whole, frac_bits};
  endfunction

  // not synthesizable!
  function automatic real FP_to_real(input FP a);
    return $itor(a) * SCALING_FACTOR;
  endfunction

  // some constants for testing
  FP one = FP_from_int(1);
  FP half = one >> 1;
  FP quarter = one >> 2;
  FP c_1_25 = FP_add(one, quarter);
 
  initial
    begin
      real aval = -342;
      real bval = 2.63245;
      FP a = FP_from_real(aval);
      FP b = FP_from_real(bval);
      $display("value is %f", FP_to_real(FP_mul(a,b)));
      $display("value is %f", aval*bval);
      $display("value is %f", FP_to_real(FP_max(a,b)));
      $display("value is %f", FP_to_real(FP_abs(a)));
      $display("value is %f", FP_to_real(FP_abs(b)));
    end

endmodule // fixed_point_arith

`default_nettype wire
