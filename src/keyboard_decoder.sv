`timescale 1ns / 1ps
`default_nettype none

`include "types.svh"

module keyboard_decoder (
  input wire clk_in,
  input wire rst_in,
  input wire [7:0] code_in,
  input wire code_valid_in,
  output logic [7:0] kb_out
);
  typedef enum { READY, READY_ARROW, RELEASING_WASD, RELEASING_ARROW } state_t;

  state_t state;

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      state <= READY;
      kb_out <= 0;
    end else begin
      // on input rising edge
      if (code_valid_in) begin
        case (state)
          READY: begin
            case (code_in)
              8'h1D: kb_out[`KB_FORWARD] <= 1; // W pressed
              8'h1B: kb_out[`KB_BACKWARD] <= 1; // S pressed
              8'h1C: kb_out[`KB_TURN_LEFT] <= 1; // A pressed
              8'h23: kb_out[`KB_TURN_RIGHT] <= 1; // D pressed
              8'h75: kb_out[`KB_TRANS_UP] <= 1;
              8'h72: kb_out[`KB_TRANS_DOWN] <= 1;
              8'h6B: kb_out[`KB_TRANS_LEFT] <= 1;
              8'h74: kb_out[`KB_TRANS_RIGHT] <= 1;
              default: begin end
            endcase
            case (code_in)
              8'hE0: state <= READY_ARROW;
              8'hF0: state <= RELEASING_WASD;
              default: state <= READY;
            endcase
          end
          READY_ARROW: begin
            case (code_in)
              8'h75: kb_out[`KB_TRANS_UP] <= 1;
              8'h72: kb_out[`KB_TRANS_DOWN] <= 1;
              8'h6B: kb_out[`KB_TRANS_LEFT] <= 1;
              8'h74: kb_out[`KB_TRANS_RIGHT] <= 1;
              default: begin end
            endcase
            case (code_in)
              8'hF0: state <= RELEASING_ARROW;
              default: state <= READY;
            endcase
          end
          RELEASING_WASD: begin
            case (code_in)
              8'h1D: kb_out[`KB_FORWARD] <= 0; // W released
              8'h1B: kb_out[`KB_BACKWARD] <= 0; // S released
              8'h1C: kb_out[`KB_TURN_LEFT] <= 0; // A released
              8'h23: kb_out[`KB_TURN_RIGHT] <= 0; // D released
              8'h75: kb_out[`KB_TRANS_UP] <= 0;
              8'h72: kb_out[`KB_TRANS_DOWN] <= 0;
              8'h6B: kb_out[`KB_TRANS_LEFT] <= 0;
              8'h74: kb_out[`KB_TRANS_RIGHT] <= 0;
              default: begin end
            endcase
            state <= READY;
          end
          RELEASING_ARROW: begin
            case (code_in)
              8'h75: kb_out[`KB_TRANS_UP] <= 0;
              8'h72: kb_out[`KB_TRANS_DOWN] <= 0;
              8'h6B: kb_out[`KB_TRANS_LEFT] <= 0;
              8'h74: kb_out[`KB_TRANS_RIGHT] <= 0;
              default: begin end
            endcase
            state <= READY;
          end
        endcase

      end
    end
  end

endmodule // keyboard_decoder

`default_nettype wire
