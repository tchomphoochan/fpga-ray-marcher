`timescale 1ns / 1ps
`default_nettype none

`include "types.svh"

module keyboard_decoder (
  input wire clk_in,
  input wire rst_in,
  input logic [7:0] code_in,
  input logic code_valid_in,
  output logic [7:0] kb_out
);

  // indices
  localparam FORWARD = 7;
  localparam BACKWARD = 6;
  localparam TURN_LEFT = 5;
  localparam TURN_RIGHT = 4;
  localparam TRANS_UP = 3;
  localparam TRANS_DOWN = 2;
  localparam TRANS_LEFT = 1;
  localparam TRANS_RIGHT = 0;

  typedef enum { READY, READY_ARROW, RELEASING_WASD, RELEASING_ARROW } state_t;

  state_t state;
  logic prev_valid;

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      prev_valid <= 0;
      prev_code <= 0;
      state <= READY;
      kb_out <= 0;
    end else begin
      prev_valid <= code_valid_in;
      // on input rising edge
      if (!prev_valid && code_valid_in) begin
        case (state)
          READY: begin
            case (code_in)
              8'h1D: kb_out[FORWARD] <= 1; // W pressed
              8'h1B: kb_out[BACKWARD] <= 1; // S pressed
              8'h1C: kb_out[TURN_LEFT] <= 1; // A pressed
              8'h23: kb_out[TURN_RIGHT] <= 1; // D pressed
            endcase
            case (code_in)
              8'hE0: state <= READY_ARROW;
              8'hF0: state <= RELEASING_WASD;
              default: state <= READY;
            endcase
          end
          READY_ARROW: begin
            case (code_in)
              8'h75: kb_out[TRANS_UP] <= 1;
              8'h72: kb_out[TRANS_DOWN] <= 1;
              8'h6B: kb_out[TRANS_LEFT] <= 1;
              8'h74: kb_out[TRANS_RIGHT] <= 1;
            endcase
            case (code_in)
              8'hF0: state <= RELEASING_ARROW;
              default: state <= READY;
            endcase
          end
          RELEASING_WASD: begin
            case (code_in)
              8'h1D: kb_out[FORWARD] <= 0; // W released
              8'h1B: kb_out[BACKWARD] <= 0; // S released
              8'h1C: kb_out[TURN_LEFT] <= 0; // A released
              8'h23: kb_out[TURN_RIGHT] <= 0; // D released
            endcase
            state <= READY;
          end
          RELEASING_ARROW: begin
            case (code_in)
              8'h75: kb_out[TRANS_UP] <= 1;
              8'h72: kb_out[TRANS_DOWN] <= 1;
              8'h6B: kb_out[TRANS_LEFT] <= 1;
              8'h74: kb_out[TRANS_RIGHT] <= 1;
            endcase
            state <= READY;
          end
        endcase

      end
    end
  end

endmodule // keyboard_decoder

`default_nettype wire
