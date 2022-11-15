`timescale 1ns / 1ps
`default_nettype none

`ifndef TYPES_SV
`define TYPES_SV

`define DISPLAY_WIDTH       640
`define DISPLAY_HEIGHT      480
`define H_BITS              10
`define V_BITS              9
`define ADDR_BITS           (`H_BITS+`V_BITS)
`define COLOR_BITS          4

`define NUM_WHOLE_DIGITS    12 // including the sign bit
`define NUM_FRAC_DIGITS     20
`define NUM_ALL_DIGITS      (`NUM_WHOLE_DIGITS+`NUM_FRAC_DIGITS)
`define SCALING_FACTOR      (2.0 ** (-`NUM_FRAC_DIGITS))

typedef logic signed [`NUM_ALL_DIGITS - 1:0] fp;
typedef struct packed { fp x, y, z; } vec3;

`endif

`default_nettype wire