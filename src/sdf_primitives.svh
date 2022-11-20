`timescale 1ns / 1ps
`default_nettype none

`ifndef SDF_PRIMITIVES_SVH
`define SDF_PRIMITIVES_SVH

`include "types.svh"
`include "fixed_point_arith.svh"

function automatic fp sd_box_fast(input vec3 point, input fp halfExtents);
  fp x_abs, y_abs, z_abs, xy_max, xyz_max;

  x_abs = fp_abs(point.x);             // float x_abs = abs(point.x)
  y_abs = fp_abs(point.y);             // float y_abs = abs(point.y)
  z_abs = fp_abs(point.z);             // float z_abs = abs(point.z)
  xy_max = fp_max(x_abs, y_abs);       // float xy_max = max(x_abs, y_abs)
  xyz_max = fp_max(xy_max, z_abs);     // float xyz_max = max(xy_max, z_abs)
  return fp_sub(xyz_max, halfExtents); // return xyz_max - halfExtents
endfunction

`endif 

`default_nettype wire
