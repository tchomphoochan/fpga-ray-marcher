`timescale 1ns / 1ps
`default_nettype none

module top_level(
  input wire clk_100mhz,
  input wire btnc,
  output logic [3:0] vga_r, vga_g, vga_b,
  output logic vga_hs, vga_vs
);

  parameter H_BITS = 10; // TODO make these parameters universal pls
  parameter V_BITS = 9;

  logic sys_rst = btnc;

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
    .eye_vec(TODO),
    .fractal_sel_in(TODO),
    .hcount_out(ray_marcher_hcount),
    .vcount_out(ray_marcher_vcount),
    .color_out(ray_marcher_color),
    .valid_out(ray_marcher_valid),
    .new_frame_out(ray_marcher_new_frame)
  );

  bram_manager #(
    .WIDTH(4),
    .DEPTH(640*480),
    .ADDR_LEN(19)
  ) bram_manager_inst(
    .clk(clk_100mhz),
    .rst(sys_rst),
    .swap_buffers(ray_marcher_new_frame),
    .read_addr(vga_display_read_addr),
    .write_enable(ray_marcher_valid),
    .write_addr(ray_marcher_addr),
    .write_data(ray_marcher_color),
    .read_data_out(vga_display_read_data),
    .which_bram(out)
  );

endmodule // top_level

`default_nettype wire
