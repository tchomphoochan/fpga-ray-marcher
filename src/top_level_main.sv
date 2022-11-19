`timescale 1ns / 1ps
`default_nettype none

`include "types.sv"

module top_level_main(
  input wire clk_100mhz,
  input wire btnc,
  input wire btnl, btnr, btnu, btnd,
  input wire [15:0] sw,
  output logic [15:0] led,
  output logic [3:0] vga_r, vga_g, vga_b,
  output logic vga_hs, vga_vs
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

  user_control user_control_inst(
    .clk_in(sys_clk),
    .btnl(btnl),
    .btnr(btnr),
    .btnu(btnu),
    .btnd(btnd),
    .sw(sw)
  ); // isn't really connected to anything right now

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

  logic [`H_BITS-1:0] ray_marcher_hcount;
  logic [`V_BITS-1:0] ray_marcher_vcount;
  logic [`ADDR_BITS-1:0] ray_marcher_addr;
  assign ray_marcher_addr = ray_marcher_vcount * `DISPLAY_WIDTH + ray_marcher_hcount;
  logic [3:0] ray_marcher_color;
  logic ray_marcher_valid;
  logic ray_marcher_new_frame;

  // default values for testing
  vec3 pos_vec_def, dir_vec_def;
  assign pos_vec_def.x = `FP_ZERO;
  assign pos_vec_def.y = `FP_ONE;
  assign pos_vec_def.z = fp_neg(`FP_THREE_HALFS);
  assign dir_vec_def.x = `FP_ZERO;
  assign dir_vec_def.y = `FP_ZERO;
  assign dir_vec_def.z = `FP_ONE;

  ray_marcher ray_marcher_inst(
    .clk_in(sys_clk),
    .rst_in(sys_rst),
    .pos_vec_in(pos_vec_def),
    .dir_vec_in(dir_vec_def),
    .fractal_sel_in(fractal_sel_def),
    .hcount_out(ray_marcher_hcount),
    .vcount_out(ray_marcher_vcount),
    .color_out(ray_marcher_color),
    .valid_out(ray_marcher_valid),
    .new_frame_out(ray_marcher_new_frame)
  );

  bram_manager #(
    .WIDTH(4),
    .DEPTH(`DISPLAY_WIDTH*`DISPLAY_HEIGHT),
    .ADDR_LEN(`ADDR_BITS)
  ) bram_manager_inst(
    .clk(sys_clk),
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
