`timescale 1ns / 1ps
`default_nettype none

`ifndef TYPES_SV
`define TYPES_SV

`define USE_VGA_800x600

`ifdef USE_VGA_640x480
    `define DISPLAY_WIDTH       640
    `define DISPLAY_HEIGHT      480
    `define H_BITS              10
    `define V_BITS              9
    `define VGA_GEN_TYPE        vga_gen_640x480
    `define CLK_CONVERTER_TYPE  clk_100_to_25p175_mhz_clk_wiz
    `define FP_DISPLAY_WIDTH 32'h28000000
    `define FP_INV_DISPLAY_WIDTH 32'h00000666
    `define FP_DISPLAY_HEIGHT 32'h1e000000
    `define FP_INV_DISPLAY_HEIGHT 32'h00000888
`elsif USE_VGA_800x600
    `define DISPLAY_WIDTH       800
    `define DISPLAY_HEIGHT      600
    `define H_BITS              10
    `define V_BITS              10
    `define VGA_GEN_TYPE        vga_gen_800x600
    `define CLK_CONVERTER_TYPE  clk_100_to_40_mhz_clk_wiz
    `define FP_DISPLAY_WIDTH 32'h32000000
    `define FP_INV_DISPLAY_WIDTH 32'h0000051e
    `define FP_DISPLAY_HEIGHT 32'h25800000
    `define FP_INV_DISPLAY_HEIGHT 32'h000006d3
`elsif USE_VGA_1024x768
    `define DISPLAY_WIDTH       1024
    `define DISPLAY_HEIGHT      768
    `define H_BITS              11
    `define V_BITS              10
    `define VGA_GEN_TYPE        vga_gen_1024x768
    `define CLK_CONVERTER_TYPE  clk_100_to_65_mhz_clk_wiz
    `define FP_DISPLAY_WIDTH 32'h40000000
    `define FP_INV_DISPLAY_WIDTH 32'h00000400
    `define FP_DISPLAY_HEIGHT 32'h30000000
    `define FP_INV_DISPLAY_HEIGHT 32'h00000555
`elsif USE_VGA_1080x1024
    `define DISPLAY_WIDTH       1280
    `define DISPLAY_HEIGHT      1024
    `define H_BITS              11
    `define V_BITS              11
    `define VGA_GEN_TYPE        vga_gen_1280x1024
    `define CLK_CONVERTER_TYPE  clk_100_to_108_mhz_clk_wiz
    `define FP_DISPLAY_WIDTH 32'h50000000
    `define FP_INV_DISPLAY_WIDTH 32'h00000333
    `define FP_DISPLAY_HEIGHT 32'h40000000
    `define FP_INV_DISPLAY_HEIGHT 32'h00000400
`elsif USE_VGA_1280x720
    `define DISPLAY_WIDTH       1280
    `define DISPLAY_HEIGHT      720
    `define H_BITS              11
    `define V_BITS              11
    `define VGA_GEN_TYPE        vga_gen_1280x720
    `define CLK_CONVERTER_TYPE  clk_100_to_75p25_mhz_clk_wiz
    `define FP_DISPLAY_WIDTH 32'h50000000
    `define FP_INV_DISPLAY_WIDTH 32'h00000333
    `define FP_DISPLAY_HEIGHT 32'h2d000000
    `define FP_INV_DISPLAY_HEIGHT 32'h000005b0
`elsif USE_VGA_1920x1080
    `define DISPLAY_WIDTH       1920
    `define DISPLAY_HEIGHT      1080
    `define H_BITS              11
    `define V_BITS              11
    `define VGA_GEN_TYPE        vga_gen_1920x1080
    `define CLK_CONVERTER_TYPE  clk_100_to_148p5_mhz_clk_wiz
    `define FP_DISPLAY_WIDTH 32'h78000000
    `define FP_INV_DISPLAY_WIDTH 32'h00000222
    `define FP_DISPLAY_HEIGHT 32'h43800000
    `define FP_INV_DISPLAY_HEIGHT 32'h000003ca
`endif


`define ADDR_BITS           (`H_BITS+`V_BITS)
`define COLOR_BITS          4

`define NUM_WHOLE_DIGITS    12 // including the sign bit
`define NUM_FRAC_DIGITS     20
`define NUM_ALL_DIGITS      (`NUM_WHOLE_DIGITS+`NUM_FRAC_DIGITS)
`define SCALING_FACTOR      (2.0 ** (-`NUM_FRAC_DIGITS))

`define MAX_RAY_DEPTH       10
`define MAX_RAY_DEPTH_SIZE  ($clog2(`MAX_RAY_DEPTH))

`define NUM_CORES           1

typedef logic signed [`NUM_ALL_DIGITS - 1:0] fp;
typedef struct packed { fp x, y, z; } vec3;
typedef enum logic [3:0] {
    RU_Ready                = 4'd0,
    RU_Busy                 = 4'd1
} RayUnitState;

// constants in Q12.20 format
`define FP_ZERO 32'h00000000
`define FP_ONE 32'h00100000
`define FP_TWO 32'h00200000
`define FP_THREE 32'h00300000
`define FP_THREE_HALFS 32'h00180000
`define FP_HALF 32'h00080000
`define FP_QUARTER 32'h00040000
`define FP_THIRD 32'h00055555
`define FP_THIRD 32'h00055555
`define FP_SQRT_TWO 32'h0016a09e
`define FP_INV_SQRT_TWO 32'h000b504f
`define FP_TENTH 32'h00019999
`define FP_HUNDREDTH 32'h000028f5

// assuming 640x480

`endif

`default_nettype wire