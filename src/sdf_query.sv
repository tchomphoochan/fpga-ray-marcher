`timescale 1ns / 1ps
`default_nettype none

`include "types.sv"
`include "fixed_point_arith.sv"
`include "sdf_primitives.sv"

module sdf_query_cube (
  input vec3 point_in,
  output fp sdf_out,
);
  assign sdf_out = sd_box_fast(sdf_out, fp_from_real(0.5));
endmodule // sdf_query_cube

module sdf_query_sponge (
  input vec3 point_in,
  output fp sdf_out,
);

  // TODO

endmodule // sdf_query_sponge

module sdf_query_sponge_inf (
  input vec3 point_in,
  output fp sdf_out,
);

  // TODO

endmodule // sdf_query_sponge_inf

`default_nettype wire
