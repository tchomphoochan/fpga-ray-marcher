`timescale 1ns / 1ps
`default_nettype none

`include "types.svh"

module top_level_main(
  input wire clk_100mhz,
  input wire btnc, cpu_resetn,
  input wire btnl, btnr, btnu, btnd,
  input wire [15:0] sw,
  input wire ps2_clk,
  input wire ps2_data,
  output logic [15:0] led,
  output logic [3:0] vga_r, vga_g, vga_b,
  output logic vga_hs, vga_vs,
  output logic ca, cb, cc, cd, ce, cf, cg,
  output logic [7:0] an,
  output logic eth_rstn, eth_txen, eth_refclk,
  output logic [1:0] eth_txd
);

  logic sys_clk;
  logic vga_clk;
  assign vga_clk = sys_clk;
  logic sys_rst = !cpu_resetn;
  assign eth_rst_n = !sys_rst;
  assign eth_refclk = sys_clk;

  `CLK_CONVERTER_TYPE clk_converter(
    .clk_in1(clk_100mhz),
    .clk_out1(sys_clk),
    .reset(sys_rst)
  );

  // fpga buttons stuff
  logic up, down, left, right;
  debouncer dbncr(.clk_in(sys_clk), .rst_in(sys_rst), .dirty_in(btnr), .clean_out(right));
  debouncer dbncl(.clk_in(sys_clk), .rst_in(sys_rst), .dirty_in(btnl), .clean_out(left));
  debouncer dbncu(.clk_in(sys_clk), .rst_in(sys_rst), .dirty_in(btnu), .clean_out(up));
  debouncer dbncd(.clk_in(sys_clk), .rst_in(sys_rst), .dirty_in(btnd), .clean_out(down));

  // keyboard stuff
  // ps2 synchronizer
  logic [1:0] ps2b_c;
  logic [1:0] ps2b_d;
  always_ff @(posedge sys_clk)begin
    ps2b_c[0] <= ps2_clk;
    ps2b_d[0] <= ps2_data;
    ps2b_c[1] <= ps2b_c[0];
    ps2b_d[1] <= ps2b_d[0];
  end
  // ps2
  logic [7:0] ps2_code, kb;
  logic ps2_code_valid;
  ps2_decoder ps2_decoder_inst(
    .clk_in(sys_clk),
    .rst_in(sys_rst),
    .ps_data_in(ps2b_d[1]),
    .ps_clk_in(ps2b_c[1]),
    .code_out(ps2_code),
    .code_valid_out(ps2_code_valid)
  );
  logic [7:0] ps2_buffer [3:0];
  // keyboard
  keyboard_decoder keyboard_decoder_inst(
    .clk_in(sys_clk),
    .rst_in(sys_rst),
    .code_in(ps2_code),
    .code_valid_in(ps2_code_valid),
    .kb_out(kb)
  );
  // 7seg
  seven_segment_controller mssc(.clk_in(sys_clk),
                              .rst_in(sys_rst),
                              .val_in({ps2_buffer[3], ps2_buffer[2], ps2_buffer[1], ps2_buffer[0]}),
                              .cat_out({cg, cf, ce, cd, cc, cb, ca}),
                              .an_out(an));

  vec3 pos_vec, dir_vec;
  logic [2:0] fractal_sel;
  logic toggle_hue, toggle_color, toggle_checker, toggle_dither;
  user_control user_control_inst(
    .clk_in(sys_clk),
    .rst_in(sys_rst),
    .btnl(left),
    .btnr(right),
    .btnu(up),
    .btnd(down),
    .sw(sw),
    .kb_in(kb),
    .pos_out(pos_vec),
    .dir_out(dir_vec),
    .fractal_sel_out(fractal_sel),
    .toggle_hue_out(toggle_hue),
    .toggle_color_out(toggle_color),
    .toggle_checker_out(toggle_checker),
    .toggle_dither_out(toggle_dither)
  );

  logic [`ADDR_BITS-1:0] vga_display_read_addr;
  logic [`ADDR_BITS-1:0] ether_read_addr;
  logic [3:0] bram_read_data;

  vga_display vga_display_inst(
    .vga_clk_in(vga_clk),
    .rst_in(sys_rst),
    .read_data_in(eth_txen ? 4'b0 : bram_read_data),
    .read_addr_out(vga_display_read_addr),
    .toggle_hue(toggle_hue),
    .toggle_color(toggle_color),
    .vga_r(vga_r),
    .vga_g(vga_g),
    .vga_b(vga_b),
    .vga_hs(vga_hs),
    .vga_vs(vga_vs)
  );

  ether_export ether_export_inst(
    .clk_in(sys_clk),
    .rst_in(rst_in),
    .trigger_in(btnc),
    .read_data_in(bram_read_data),
    .read_addr_out(ether_read_addr),
    .eth_txen(eth_txen),
    .eth_txd(eth_txd)
  );

  logic [`H_BITS-1:0] ray_marcher_hcount;
  logic [`V_BITS-1:0] ray_marcher_vcount;
  logic [`ADDR_BITS-1:0] ray_marcher_addr;
  assign ray_marcher_addr = ray_marcher_vcount * `DISPLAY_WIDTH + ray_marcher_hcount;
  logic [3:0] ray_marcher_color;
  logic ray_marcher_valid;
  logic ray_marcher_new_frame;
  logic [31:0] fps;
  assign led = fps[15:0];

  ray_marcher ray_marcher_inst(
    .clk_in(sys_clk),
    .rst_in(sys_rst),
    .pos_vec_in(pos_vec),
    .dir_vec_in(dir_vec),
    .toggle_checker_in(toggle_checker),
    .toggle_dither_in(toggle_dither),
    .fractal_sel_in(fractal_sel),
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
    .read_addr(eth_txen ? ether_read_addr : vga_display_read_addr),
    .write_enable(ray_marcher_valid),
    .write_addr(ray_marcher_addr),
    .write_data(ray_marcher_color),
    .read_data_out(bram_read_data),
    .which_bram_out(out)
  );

  fps_counter fps_counter_inst(
    .clk_in(sys_clk),
    .rst_in(sys_rst),
    .new_frame_in(ray_marcher_new_frame),
    .fps_out(fps)
  );

  always_ff @(posedge sys_clk) begin
    if (sys_rst) begin
      ps2_buffer[0] <= 0;
      ps2_buffer[1] <= 0;
      ps2_buffer[2] <= 0;
      ps2_buffer[3] <= 0;
    end else if (ps2_code_valid) begin
      ps2_buffer[0] <= ps2_code;
      ps2_buffer[1] <= ps2_buffer[0];
      ps2_buffer[2] <= ps2_buffer[1];
      ps2_buffer[3] <= ps2_buffer[2];
    end
  end

endmodule // top_level_main

`default_nettype wire
