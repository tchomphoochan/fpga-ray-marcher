`timescale 1ns / 1ps
`default_nettype none

`include "types.sv"
`include "vector_arith.sv"

`ifndef TESTING_RAY_MARCHER
`define RAY_UNIT_TYPE ray_unit
`else
`define RAY_UNIT_TYPE ray_unit_dummy
`endif

module ray_marcher #(
  parameter DISPLAY_WIDTH = `DISPLAY_WIDTH, // BE CAREFUL: should NOT be powers of two!!
  DISPLAY_HEIGHT = `DISPLAY_HEIGHT,
  H_BITS = `H_BITS,
  V_BITS = `V_BITS,
  COLOR_BITS = `COLOR_BITS,
  NUM_CORES = `NUM_CORES
) (
  input wire clk_in,
  input wire rst_in,
  input vec3 pos_vec_in,
  input vec3 dir_vec_in,
  input wire [2:0] fractal_sel_in,
  // rendered output
  output logic [H_BITS-1:0] hcount_out,
  output logic [V_BITS-1:0] vcount_out,
  output logic [3:0] color_out,
  output logic valid_out,
  output logic new_frame_out
);

  // stored input for the current frame being processed
  vec3 current_pos_vec;
  vec3 current_dir_vec;
  logic [2:0] current_fractal;

  // internal state: which pixel/machine to assign next?
  logic [H_BITS-1:0] hcount, assign_hcount;
  logic [V_BITS-1:0] vcount, assign_vcount;
  logic [$clog2(NUM_CORES)-1:0] core_idx, assign_to;

  // instantiate cores
  // MODIFY THESE VARIABLES FOR TESTING
  logic assigning;
  logic [H_BITS-1:0] core_hcount_out [NUM_CORES-1:0];
  logic [V_BITS-1:0] core_vcount_out [NUM_CORES-1:0];
  logic [COLOR_BITS-1:0] core_color_out [NUM_CORES-1:0];
  logic [NUM_CORES-1:0] core_ready_out;
  generate
    genvar i;
    for (i = 0; i < NUM_CORES; ++i) begin : ray_marcher_core_decl
      logic core_rst;
      assign core_rst = rst_in;

      `RAY_UNIT_TYPE #(
        .DISPLAY_WIDTH(DISPLAY_WIDTH),
        .DISPLAY_HEIGHT(DISPLAY_HEIGHT),
        .H_BITS(H_BITS),
        .V_BITS(V_BITS)
`ifdef TESTING_RAY_MARCHER
        , .CORE_IDX(i)
`endif
      ) ray_unit_inst(
        .clk_in(clk_in),
        .rst_in(core_rst),
        .ray_origin_in(current_pos_vec),
        .ray_direction_in(current_dir_vec),
        .fractal_sel_in(current_fractal),
        .hcount_in(assign_hcount),
        .vcount_in(assign_vcount),
        .valid_in(assign_to == i && assigning),
        .hcount_out(core_hcount_out[i]),
        .vcount_out(core_vcount_out[i]),
        .color_out(core_color_out[i]),
        .ready_out(core_ready_out[i])
      );
    end
  endgenerate
  logic all_cores_ready; // just for convenience
  assign all_cores_ready = &core_ready_out;

  // assign work
  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      hcount <= 0;
      vcount <= DISPLAY_HEIGHT;
      new_frame_out <= 0;
      assigning <= 0;
      core_idx <= 0;
    end else begin

      if (vcount == DISPLAY_HEIGHT) begin
        // no more pixels to be assigned
        $display("No more pixels to be assigned. At machine %d.", core_idx);
        if (all_cores_ready) begin
          $display("Taking in new inputs: pos_vec_in=%s, dir_vec_in=%s, fractal_sel_in=%d",
            vec3_to_str(pos_vec_in), vec3_to_str(dir_vec_in), fractal_sel_in);
          // every machine is done
          // end frame by getting new input
          current_pos_vec <= pos_vec_in;
          current_dir_vec <= dir_vec_in;
          current_fractal <= fractal_sel_in;
          // start the frame
          hcount <= 0;
          vcount <= 0;
          new_frame_out <= 1; // (beware: don't end when copying the last pixel!)
        end
        assigning <= 0;
        // otherwise just wait
      end else if (hcount == DISPLAY_WIDTH) begin
        $display("hcount = %d, vcount = %d: row exhausted.", hcount, vcount);
        // exhausted current row, go onto the next
        // nothing to do here really
        vcount <= vcount+1;
        hcount <= 0;
        assigning <= 0;
      end else begin
        $write("hcount = %d, vcount = %d, ", hcount, vcount);
        new_frame_out <= 0; // started computing new frame, so set back to zero
        // pixel ready to assign
        if (core_ready_out[core_idx]) begin
          $display("core %d free - assigning on next cycle", core_idx);
          // assign to machine
          assigning <= 1;
          assign_to <= core_idx;
          assign_hcount <= hcount;
          assign_vcount <= vcount;
          // increment to the next pixel
          hcount <= hcount+1;
        end else begin
          assigning <= 0;
          $display("core %d busy", core_idx);
        end
      end
      core_idx <= (core_idx + 1) % NUM_CORES; // cycle to the next machine all the time

    end
  end

  // copy stuff into memory
  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      // nothing to do
    end else begin
      if (core_ready_out[core_idx]) begin
        $display("Dummy core %1d data available (Saved to memory: hcount=%d, vcount=%d, color=%d)",
          core_idx, core_hcount_out[core_idx], core_vcount_out[core_idx], core_color_out[core_idx]);
        // copy data into bram
        hcount_out <= core_hcount_out[core_idx];
        vcount_out <= core_vcount_out[core_idx];
        color_out <= core_color_out[core_idx];
        valid_out <= 1'b1;
      end else begin
        valid_out <= 1'b0;
      end
    end
  end

endmodule // ray_marcher

`default_nettype wire
