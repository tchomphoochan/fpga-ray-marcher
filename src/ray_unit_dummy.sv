`timescale 1ns / 1ps
`default_nettype none

`include "types.sv"
`include "vector_arith.sv"

module ray_unit_dummy #(
  parameter DISPLAY_WIDTH = `DISPLAY_WIDTH,
  DISPLAY_HEIGHT = `DISPLAY_HEIGHT,
  H_BITS = `H_BITS,
  V_BITS = `V_BITS,
  CORE_IDX = 0
) (
  input wire clk_in,
  input wire rst_in,
  input vec3 ray_origin_in,
  input vec3 ray_direction_in,
  input wire [2:0] fractal_sel_in,
  input wire [H_BITS-1:0] hcount_in,
  input wire [V_BITS-1:0] vcount_in,
  input wire valid_in,

  // rendered output
  output logic [H_BITS-1:0] hcount_out,
  output logic [V_BITS-1:0] vcount_out,
  output logic [3:0] color_out,
  output logic ready_out
);

  logic busy;
  logic [10:0] wait_time;
  assign ready_out = !busy;

  logic [H_BITS-1:0] hcount;
  logic [V_BITS-1:0] vcount;

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      $display("Dummy core %1d reset", CORE_IDX);
      busy <= 0;
    end else if (busy) begin
      if (wait_time == 0) begin
        // done!
        hcount_out <= hcount;
        vcount_out <= vcount;
        color_out <= 0;
        $display("Dummy core %1d done (hcount=%d vcount=%d)", CORE_IDX, hcount, vcount);
        // take in new input immediately
        if (valid_in) begin
          hcount <= hcount_in;
          vcount <= vcount_in;
          busy <= 1'b1;
          wait_time <= $urandom_range(1, 1);
          $display("Dummy core %1d received input hcount=%d vcount=%d", CORE_IDX, hcount_in, vcount_in);
        end else begin
          busy <= 0;
          $display("Dummy core %1d idle now", CORE_IDX);
        end
      end else begin
        $display("Dummy core %1d running, %d cycles left (hcount=%d vcount=%d)", CORE_IDX, wait_time, hcount, vcount);
        // tick down
        wait_time <= wait_time - 1;
      end
    end else begin
      if (valid_in) begin
        hcount <= hcount_in;
        vcount <= vcount_in;
        busy <= 1'b1;
        wait_time <= $urandom_range(20, 1);
        $display("Dummy core %1d received input", CORE_IDX);
        $display("Dummy core %1d running now (hcount_in=%d vcount_in=%d)", CORE_IDX, hcount_in, vcount_in);
      end else begin
        busy <= 1'b0;
        $display("Dummy core %1d idle", CORE_IDX);
      end
    end
  end

endmodule // ray_unit_dummy

`default_nettype wire