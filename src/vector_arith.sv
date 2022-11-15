`timescale 1ns / 1ps
`default_nettype none

package vector_arith;
  import fixed_point_arith::*;

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
    // TODO
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
  function automatic vec3 vec3_modded(input vec3 a, fp s);
    vec3_modded.x = fp_mod(a.x, s);
    vec3_modded.y = fp_mod(a.y, s);
    vec3_modded.z = fp_mod(a.z, s);
  endfunction
  function automatic vec3 vec3_normed(input vec3 a);
    // TODO
  endfunction
  
endpackage // vector_arith

`default_nettype wire
