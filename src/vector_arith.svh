`timescale 1ns / 1ps
`default_nettype none

`ifndef VECTOR_ARITH_SVH
`define VECTOR_ARITH_SVH

`include "fixed_point_arith.svh"
`include "types.svh"

function automatic vec3 make_vec3(input fp x, input fp y, input fp z);
  make_vec3.x = x;
  make_vec3.y = y;
  make_vec3.z = z;
endfunction

function automatic vec3 vec3_neg(input vec3 a);
  vec3_neg.x = fp_neg(a.x);
  vec3_neg.y = fp_neg(a.y);
  vec3_neg.z = fp_neg(a.z);
endfunction
function automatic vec3 vec3_add(input vec3 a, input vec3 b);
  vec3_add.x = fp_add(a.x, b.x);
  vec3_add.y = fp_add(a.y, b.y);
  vec3_add.z = fp_add(a.z, b.z);
endfunction
function automatic vec3 vec3_sub(input vec3 a, input vec3 b);
  vec3_sub.x = fp_sub(a.x, b.x);
  vec3_sub.y = fp_sub(a.y, b.y);
  vec3_sub.z = fp_sub(a.z, b.z);
endfunction
function automatic vec3 vec3_min(input vec3 a, input vec3 b);
  vec3_min.x = fp_min(a.x, b.x);
  vec3_min.y = fp_min(a.y, b.y);
  vec3_min.z = fp_min(a.z, b.z);
endfunction
function automatic vec3 vec3_max(input vec3 a, input vec3 b);
  vec3_max.x = fp_max(a.x, b.x);
  vec3_max.y = fp_max(a.y, b.y);
  vec3_max.z = fp_max(a.z, b.z);
endfunction
function automatic fp vec3_dot(input vec3 a, input vec3 b);
  fp x2 = fp_mul(a.x, b.x);
  fp y2 = fp_mul(a.y, b.y);
  fp z2 = fp_mul(a.z, b.z);
  fp sum = fp_add(x2, fp_add(y2, z2));
  return sum;
endfunction
function automatic vec3 vec3_cross(input vec3 a, input vec3 b);
  vec3_cross.x = fp_sub(fp_mul(a.y, b.z), fp_mul(a.z, b.y));
  vec3_cross.y = fp_sub(fp_mul(a.z, b.x), fp_mul(a.x, b.z));
  vec3_cross.z = fp_sub(fp_mul(a.x, b.y), fp_mul(a.y, b.x));
endfunction
function automatic vec3 vec3_scaled(input vec3 a, fp s);
  vec3_scaled.x = fp_mul(a.x, s);
  vec3_scaled.y = fp_mul(a.y, s);
  vec3_scaled.z = fp_mul(a.z, s);
endfunction
function automatic vec3 vec3_scaled_half(input vec3 a);
  vec3_scaled_half.x = fp_mul_half(a.x);
  vec3_scaled_half.y = fp_mul_half(a.y);
  vec3_scaled_half.z = fp_mul_half(a.z);
endfunction
function automatic vec3 vec3_scaled_2(input vec3 a);
  vec3_scaled_2.x = fp_mul_2(a.x);
  vec3_scaled_2.y = fp_mul_2(a.y);
  vec3_scaled_2.z = fp_mul_2(a.z);
endfunction
function automatic vec3 vec3_scaled_3(input vec3 a);
  vec3_scaled_3.x = fp_mul_3(a.x);
  vec3_scaled_3.y = fp_mul_3(a.y);
  vec3_scaled_3.z = fp_mul_3(a.z);
endfunction
function automatic vec3 vec3_modded(input vec3 a, fp s);
  vec3_modded.x = fp_mod(a.x, s);
  vec3_modded.y = fp_mod(a.y, s);
  vec3_modded.z = fp_mod(a.z, s);
endfunction
function automatic vec3 vec3_normed(input vec3 a);
  fp sum = vec3_dot(a, a);
  fp factor = fp_inv_sqrt(sum);
  return vec3_scaled(a, factor);
endfunction
function automatic vec3 vec3_fract(input vec3 a);
  vec3_fract.x = fp_fract(a.x);
  vec3_fract.y = fp_fract(a.y);
  vec3_fract.z = fp_fract(a.z);
endfunction
function automatic vec3 vec3_abs(input vec3 a);
  vec3_abs.x = fp_abs(a.x);
  vec3_abs.y = fp_abs(a.y);
  vec3_abs.z = fp_abs(a.z);
endfunction
function automatic vec3 vec3_floor(input vec3 a);
  vec3_floor.x = fp_floor(a.x);
  vec3_floor.y = fp_floor(a.y);
  vec3_floor.z = fp_floor(a.z);
endfunction
function automatic vec3 vec3_step(input vec3 b, input vec3 a);
  vec3_step.x = fp_lt(a.x, b.x) ? `FP_ZERO : `FP_ONE;
  vec3_step.y = fp_lt(a.y, b.y) ? `FP_ZERO : `FP_ONE;
  vec3_step.z = fp_lt(a.z, b.z) ? `FP_ZERO : `FP_ONE;
endfunction
function automatic vec3 vec3_sign(input vec3 a);
  vec3_sign.x = fp_sign(a.x);
  vec3_sign.y = fp_sign(a.y);
  vec3_sign.z = fp_sign(a.z);
endfunction
function automatic vec3 vec3_apply_sign(input vec3 a, input vec3 b);
  vec3_apply_sign.x = fp_apply_sign(a.x, b.x);
  vec3_apply_sign.y = fp_apply_sign(a.y, b.y);
  vec3_apply_sign.z = fp_apply_sign(a.z, b.z);
endfunction
function automatic vec3 vec3_sr(input vec3 a, input integer b);
  vec3_sr.x = $signed(a.x) >> $signed(b);
  vec3_sr.y = $signed(a.y) >> $signed(b);
  vec3_sr.z = $signed(a.z) >> $signed(b);
endfunction
function automatic vec3 vec3_sl(input vec3 a, input integer b);
  vec3_sl.x = $signed(a.x) << $signed(b);
  vec3_sl.y = $signed(a.y) << $signed(b);
  vec3_sl.z = $signed(a.z) << $signed(b);
endfunction

// not synthesizable!
function automatic vec3 vec3_from_reals(input real a, input real b, input real c);
  return make_vec3(fp_from_real(a), fp_from_real(b), fp_from_real(c));
endfunction
function automatic string vec3_to_str(input vec3 a);
  return $sformatf("(%f,%f,%f)", fp_to_real(a.x), fp_to_real(a.y), fp_to_real(a.z));
endfunction

`endif

`default_nettype wire
