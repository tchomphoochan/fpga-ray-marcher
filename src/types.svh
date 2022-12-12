`timescale 1ns / 1ps
`default_nettype none

`ifndef TYPES_SVH
`define TYPES_SVH

`define KB_FORWARD 7
`define KB_BACKWARD 6
`define KB_TURN_LEFT 5
`define KB_TURN_RIGHT 4
`define KB_TRANS_UP 3
`define KB_TRANS_DOWN 2
`define KB_TRANS_LEFT 1
`define KB_TRANS_RIGHT 0

`define ADDR_BITS           (`H_BITS+`V_BITS)
`define COLOR_BITS          4

`define NUM_WHOLE_DIGITS    8 // including the sign bit
`define NUM_FRAC_DIGITS     16
`define NUM_ALL_DIGITS      (`NUM_WHOLE_DIGITS+`NUM_FRAC_DIGITS)
`define SCALING_FACTOR      (2.0 ** (-`NUM_FRAC_DIGITS))

`define MAX_RAY_DEPTH       31
`define MAX_RAY_DEPTH_SIZE  ($clog2(`MAX_RAY_DEPTH))

`define NUM_CORES           4


// for rendering
`ifndef OVERRIDE_SIZE
    `define USE_400x300
`endif

`ifdef USE_400x300
    `define DISPLAY_WIDTH                   400
    `define DISPLAY_HEIGHT                  300
    `define H_BITS                          9
    `define V_BITS                          9
    `define DISPLAY_SHIFT_SIZE              1

    // should not use these in actual synthesis
    `define FP_DISPLAY_WIDTH                (32'sh19000000 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_INV_DISPLAY_WIDTH            (32'sh00000a3d >> (20 - `NUM_FRAC_DIGITS))
    `define FP_DISPLAY_HEIGHT               (32'sh12c00000 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_INV_DISPLAY_HEIGHT           (32'sh00000da7 >> (20 - `NUM_FRAC_DIGITS))

    // goes from -width/height to width/height. increment by 2/height (same scale as vertical).
    `define FP_HCOUNT_FP_START              (32'shffeaaaaa >> (20 - `NUM_FRAC_DIGITS))
    `define FP_HCOUNT_FP_END                (32'sh00155555 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_HCOUNT_FP_INCREMENT          (32'sh00001b4e >> (20 - `NUM_FRAC_DIGITS))

    // goes from -1 to 1. increment by 2/height.
    `define FP_VCOUNT_FP_START              (32'shfff00000 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_VCOUNT_FP_END                (32'sh00100000 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_VCOUNT_FP_INCREMENT          (32'sh00001b4e >> (20 - `NUM_FRAC_DIGITS))
`endif

`ifdef USE_200x150
    `define DISPLAY_WIDTH                   200
    `define DISPLAY_HEIGHT                  150
    `define H_BITS                          8
    `define V_BITS                          8
    `define DISPLAY_SHIFT_SIZE              2

    // should not use these in actual synthesis
    `define FP_DISPLAY_WIDTH                (32'sh19000000 >> 1 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_INV_DISPLAY_WIDTH            (32'sh00000a3d << 1 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_DISPLAY_HEIGHT               (32'sh12c00000 >> 1 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_INV_DISPLAY_HEIGHT           (32'sh00000da7 << 1 >> (20 - `NUM_FRAC_DIGITS))

    // goes from -width/height to width/height. increment by 2/height (same scale as vertical).
    `define FP_HCOUNT_FP_START              (32'shffeaaaaa >> (20 - `NUM_FRAC_DIGITS))
    `define FP_HCOUNT_FP_END                (32'sh00155555 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_HCOUNT_FP_INCREMENT          (32'sh00001b4e << 1 >> (20 - `NUM_FRAC_DIGITS))

    // goes from -1 to 1. increment by 2/height.
    `define FP_VCOUNT_FP_START              (32'shfff00000 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_VCOUNT_FP_END                (32'sh00100000 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_VCOUNT_FP_INCREMENT          (32'sh00001b4e << 1 >> (20 - `NUM_FRAC_DIGITS))
`endif

`ifdef USE_100x75
    `define DISPLAY_WIDTH                   100
    `define DISPLAY_HEIGHT                  75
    `define H_BITS                          7
    `define V_BITS                          7
    `define DISPLAY_SHIFT_SIZE              3

    // should not use these in actual synthesis
    `define FP_DISPLAY_WIDTH                (32'sh19000000 >> 2 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_INV_DISPLAY_WIDTH            (32'sh00000a3d << 2 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_DISPLAY_HEIGHT               (32'sh12c00000 >> 2 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_INV_DISPLAY_HEIGHT           (32'sh00000da7 << 2 >> (20 - `NUM_FRAC_DIGITS))

    // goes from -width/height to width/height. increment by 2/height (same scale as vertical).
    `define FP_HCOUNT_FP_START              (32'shffeaaaaa >> (20 - `NUM_FRAC_DIGITS))
    `define FP_HCOUNT_FP_END                (32'sh00155555 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_HCOUNT_FP_INCREMENT          (32'sh00001b4e << 2 >> (20 - `NUM_FRAC_DIGITS))

    // goes from -1 to 1. increment by 2/height.
    `define FP_VCOUNT_FP_START              (32'shfff00000 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_VCOUNT_FP_END                (32'sh00100000 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_VCOUNT_FP_INCREMENT          (32'sh00001b4e << 2 >> (20 - `NUM_FRAC_DIGITS))
`endif

// actual vga output
`define USE_VGA_800x600
`ifdef USE_VGA_640x480
    `define VGA_DISPLAY_WIDTH           640
    `define VGA_DISPLAY_HEIGHT          480
    `define VGA_H_BITS                  10
    `define VGA_V_BITS                  9
    `define VGA_GEN_TYPE                vga_gen_640x480
    `define CLK_CONVERTER_TYPE          clk_100_to_25p175_mhz_clk_wiz
    `define FP_VGA_DISPLAY_WIDTH        (32'sh28000000 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_INV_VGA_DISPLAY_WIDTH    (32'sh00000666 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_VGA_DISPLAY_HEIGHT       (32'sh1e000000 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_INV_VGA_DISPLAY_HEIGHT   (32'sh00000888 >> (20 - `NUM_FRAC_DIGITS))
`elsif USE_VGA_800x600
    `define VGA_DISPLAY_WIDTH           800
    `define VGA_DISPLAY_HEIGHT          600
    `define VGA_H_BITS                  10
    `define VGA_V_BITS                  10
    `define VGA_GEN_TYPE                vga_gen_800x600
    `define CLK_CONVERTER_TYPE          clk_100_to_40_mhz_clk_wiz
    `define FP_VGA_DISPLAY_WIDTH        (32'sh32000000 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_INV_VGA_DISPLAY_WIDTH    (32'sh0000051e >> (20 - `NUM_FRAC_DIGITS))
    `define FP_VGA_DISPLAY_HEIGHT       (32'sh25800000 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_INV_VGA_DISPLAY_HEIGHT   (32'sh000006d3 >> (20 - `NUM_FRAC_DIGITS))
`elsif USE_VGA_1024x768
    `define VGA_DISPLAY_WIDTH           1024
    `define VGA_DISPLAY_HEIGHT          768
    `define VGA_H_BITS                  11
    `define VGA_V_BITS                  10
    `define VGA_GEN_TYPE                vga_gen_1024x768
    `define CLK_CONVERTER_TYPE          clk_100_to_65_mhz_clk_wiz
    `define FP_VGA_DISPLAY_WIDTH        (32'sh40000000 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_INV_VGA_DISPLAY_WIDTH    (32'sh00000400 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_VGA_DISPLAY_HEIGHT       (32'sh30000000 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_INV_VGA_DISPLAY_HEIGHT   (32'sh00000555 >> (20 - `NUM_FRAC_DIGITS))
`elsif USE_VGA_1080x1024
    `define VGA_DISPLAY_WIDTH           1280
    `define VGA_DISPLAY_HEIGHT          1024
    `define VGA_H_BITS                  11
    `define VGA_V_BITS                  11
    `define VGA_GEN_TYPE                vga_gen_1280x1024
    `define CLK_CONVERTER_TYPE          clk_100_to_108_mhz_clk_wiz
    `define FP_VGA_DISPLAY_WIDTH        (32'sh50000000 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_INV_VGA_DISPLAY_WIDTH    (32'sh00000333 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_VGA_DISPLAY_HEIGHT       (32'sh40000000 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_INV_VGA_DISPLAY_HEIGHT   (32'sh00000400 >> (20 - `NUM_FRAC_DIGITS))
`elsif USE_VGA_1280x720
    `define VGA_DISPLAY_WIDTH           1280
    `define VGA_DISPLAY_HEIGHT          720
    `define VGA_H_BITS                  11
    `define VGA_V_BITS                  11
    `define VGA_GEN_TYPE                vga_gen_1280x720
    `define CLK_CONVERTER_TYPE          clk_100_to_75p25_mhz_clk_wiz
    `define FP_VGA_DISPLAY_WIDTH        (32'sh50000000 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_INV_VGA_DISPLAY_WIDTH    (32'sh00000333 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_VGA_DISPLAY_HEIGHT       (32'sh2d000000 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_INV_VGA_DISPLAY_HEIGHT   (32'sh000005b0 >> (20 - `NUM_FRAC_DIGITS))
`elsif USE_VGA_1920x1080
    `define VGA_DISPLAY_WIDTH           1920
    `define VGA_DISPLAY_HEIGHT          1080
    `define VGA_H_BITS                  11
    `define VGA_V_BITS                  11
    `define VGA_GEN_TYPE                vga_gen_1920x1080
    `define CLK_CONVERTER_TYPE          clk_100_to_148p5_mhz_clk_wiz
    `define FP_VGA_DISPLAY_WIDTH        (32'sh78000000 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_INV_VGA_DISPLAY_WIDTH    (32'sh00000222 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_VGA_DISPLAY_HEIGHT       (32'sh43800000 >> (20 - `NUM_FRAC_DIGITS))
    `define FP_INV_VGA_DISPLAY_HEIGHT   (32'sh000003ca >> (20 - `NUM_FRAC_DIGITS))
`endif


typedef logic signed [`NUM_ALL_DIGITS - 1:0] fp;
typedef struct packed { fp x, y, z; } vec3;
typedef enum logic [3:0] {
    RU_Ready                = 4'd0,
    RU_Setup                = 4'd1,
    RU_Busy_1               = 4'd2,
    RU_Busy_2               = 4'd3,
    RU_Shading              = 4'd4
} RayUnitState;

// constants in Q12.20 format
`define FP_ZERO             (32'sh00000000 >> (20 - `NUM_FRAC_DIGITS))
`define FP_ONE              (32'sh00100000 >> (20 - `NUM_FRAC_DIGITS))
`define FP_TWO              (32'sh00200000 >> (20 - `NUM_FRAC_DIGITS))
`define FP_THREE            (32'sh00300000 >> (20 - `NUM_FRAC_DIGITS))
`define FP_FIVE             (32'sh00500000 >> (20 - `NUM_FRAC_DIGITS))
`define FP_THREE_HALFS      (32'sh00180000 >> (20 - `NUM_FRAC_DIGITS))
`define FP_HALF             (32'sh00080000 >> (20 - `NUM_FRAC_DIGITS))
`define FP_QUARTER          (32'sh00040000 >> (20 - `NUM_FRAC_DIGITS))
`define FP_THIRD            (32'sh00055555 >> (20 - `NUM_FRAC_DIGITS))
`define FP_ONE_SIXTEENTHS   (32'sh00010000 >> (20 - `NUM_FRAC_DIGITS))
`define FP_NINTH            (32'sh0001c71c >> (20 - `NUM_FRAC_DIGITS))
`define FP_TWENTY_SEVENTH   (32'sh000097b4 >> (20 - `NUM_FRAC_DIGITS))
`define FP_EIGHTY_ONETH     (32'sh00003291 >> (20 - `NUM_FRAC_DIGITS))
`define FP_NINE             (32'sh00900000 >> (20 - `NUM_FRAC_DIGITS))
`define FP_TWENTY_SEVEN     (32'sh01b00000 >> (20 - `NUM_FRAC_DIGITS))
`define FP_EIGHTY_ONE       (32'sh05100000 >> (20 - `NUM_FRAC_DIGITS))
`define FP_MAGIC_NUMBER_A   (32'shfff8cccc >> (20 - `NUM_FRAC_DIGITS))
`define FP_MAGIC_NUMBER_B   (32'shfffb7777 >> (20 - `NUM_FRAC_DIGITS))
`define FP_MAGIC_NUMBER_C   (32'shfffd17e4 >> (20 - `NUM_FRAC_DIGITS))
`define FP_MAGIC_NUMBER_D   (32'shffff3333 >> (20 - `NUM_FRAC_DIGITS))
`define FP_COS_HUNDREDTH    (32'sh000fffcb >> (20 - `NUM_FRAC_DIGITS))
`define FP_SIN_HUNDREDTH    (32'sh000028f5 >> (20 - `NUM_FRAC_DIGITS))
`define FP_SQRT_TWO         (32'sh0016a09e >> (20 - `NUM_FRAC_DIGITS))
`define FP_INV_SQRT_TWO     (32'sh000b504f >> (20 - `NUM_FRAC_DIGITS))
`define FP_TENTH            (32'sh00019999 >> (20 - `NUM_FRAC_DIGITS))
`define FP_HUNDREDTH        (32'sh000028f5 >> (20 - `NUM_FRAC_DIGITS))

// 2 * (sqrt(2) - 1)
`define FP_INTERP_SLOPE     (32'sh000d413c >> (20 - `NUM_FRAC_DIGITS))


`endif

`default_nettype wire