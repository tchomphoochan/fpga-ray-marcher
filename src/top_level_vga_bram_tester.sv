`timescale 1ns / 1ps
`default_nettype none

`include "types.svh"

module top_level_vga_bram_tester(
  input wire clk_100mhz,
  input wire btnc,
  input wire btnu,
  output logic [3:0] vga_r, vga_g, vga_b,
  output logic vga_hs, vga_vs,
  output logic [15:0] led
);

  logic sys_clk;
  logic vga_clk;
  assign vga_clk = sys_clk;
  logic sys_rst = btnc;
  `CLK_CONVERTER_TYPE clk_converter(
    .clk_in1(clk_100mhz),
    .clk_out1(sys_clk),
    .reset(sys_rst)
  );

  logic [`ADDR_BITS-1:0] vga_display_read_addr;
  logic [3:0] vga_display_read_data;

  vga_display vga_display_inst(
    .vga_clk_in(vga_clk),
    .read_data_in(vga_display_read_data),
    .read_addr_out(vga_display_read_addr),
    .vga_r(vga_r),
    .vga_g(vga_g),
    .vga_b(vga_b),
    .vga_hs(vga_hs),
    .vga_vs(vga_vs)
  );
  logic which_bram;

  bram_manager #(
    .WIDTH(4),
    .DEPTH(`DISPLAY_WIDTH*`DISPLAY_HEIGHT),
    .ADDR_LEN(`ADDR_BITS)
  ) bram_manager_inst(
    .clk(sys_clk),
    .rst(sys_rst),
    .swap_buffers(btnu),
    .read_addr(vga_display_read_addr),
    .write_enable(0),
    .write_addr(0),
    .write_data(0),
    .read_data_out(vga_display_read_data),
    .which_bram_out(which_bram)
  );

endmodule // top_level_fixed_point_tester

`default_nettype wire
