`timescale 1ns / 1ps
`default_nettype none

`include "types.sv"

module top_level_main(
  input wire clk_100mhz,
  input wire btnc,
  input wire btnl, btnr, btnu, btnd,
  input wire [15:0] sw,
  output logic [3:0] vga_r, vga_g, vga_b,
  output logic vga_hs, vga_vs
);

  parameter DISPLAY_WIDTH = `DISPLAY_WIDTH;
  parameter DISPLAY_HEIGHT = `DISPLAY_HEIGHT;
  parameter H_BITS = $clog2(DISPLAY_WIDTH);
  parameter V_BITS = $clog2(DISPLAY_HEIGHT);
  parameter ADDR_BITS = H_BITS+V_BITS;

  logic sys_rst = btnc;

  user_control user_control_inst(
    .clk_in(clk_100mhz),
    .btnl(btnl),
    .btnr(btnr),
    .btnu(btnu),
    .btnd(btnd),
    .sw(sw)
  );

  // TODO: handle clock domain crossing!
  logic vga_clk = clk_100mhz;

  logic [18:0] vga_display_read_addr;
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

  logic [H_BITS-1:0] ray_marcher_hcount;
  logic [V_BITS-1:0] ray_marcher_vcount;
  logic [3:0] ray_marcher_color;
  logic ray_marcher_valid;
  logic ray_marcher_new_frame;

  ray_marcher ray_marcher_inst(
    .clk_in(clk_100mhz),
    .rst_in(sys_rst),
    // .pos_vec_in(TODO),
    // .dir_vec_in(TODO),
    // .fractal_sel_in(TODO),
    .hcount_out(ray_marcher_hcount),
    .vcount_out(ray_marcher_vcount),
    .color_out(ray_marcher_color),
    .valid_out(ray_marcher_valid),
    .new_frame_out(ray_marcher_new_frame)
  );

  bram_manager #(
    .WIDTH(4),
    .DEPTH(DISPLAY_WIDTH*DISPLAY_HEIGHT),
    .ADDR_LEN(ADDR_BITS)
  ) bram_manager_inst(
    .clk(clk_100mhz),
    .rst(sys_rst),
    .swap_buffers(ray_marcher_new_frame),
    .read_addr(vga_display_read_addr),
    .write_enable(ray_marcher_valid),
    .write_addr(ray_marcher_addr),
    .write_data(ray_marcher_color),
    .read_data_out(vga_display_read_data),
    .which_bram_out(out)
  );

endmodule // top_level_main

`default_nettype wire
