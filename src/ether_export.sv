`timescale 1ns / 1ps
`default_nettype none

`include "types.svh"

module ether_export(
  input wire clk_in,
  input wire rst_in,
  input wire export_trigger_in,
  input wire [3:0] read_data_in, // 4-bit grayscale
  output logic [`ADDR_BITS-1:0] read_addr_out,
  output logic eth_txen,
  output logic [1:0] eth_txd,
  output logic export_ready_out
);

  localparam FRAME_DIBIT_COUNT = 4*50; // 50 bytes

  assign export_ready_out = state == ready && eth_ready_out;

  typedef enum { ready, start_frame, frame_check, start_row, pixels } state_t;
  state_t state;

  logic [31:0] row, col;
  logic [31:0] cnt;
  logic parity;

  logic [1:0] eth_data_in;
  logic eth_last_dibit_in;
  logic eth_ready_out;
  logic eth_data_ready_out;
  logic eth_trigger_in;

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      state <= ready;
    end else begin
      case (state)
        ready: begin
          if (eth_ready_out && export_trigger_in) begin
            state <= start_frame;
            cnt <= FRAME_DIBIT_COUNT-1;
            row <= 0;
          end
        end
        start_frame: begin
          if (eth_data_ready_out) begin
            if (cnt == 0) begin
              state <= frame_check;
            end else begin
              cnt <= cnt-1;
            end
          end
        end
        frame_check: begin
          if (eth_ready_out) begin
            state <= start_row;
            cnt <= 15; // send 4 bytes of row, i.e. 16 dibits
          end
        end
        start_row: begin
          if (eth_data_ready_out) begin
            if (cnt == 0) begin
              state <= pixels;
              cnt <= 0;
            end else begin
              cnt <= cnt-1;
            end
          end
        end
        pixels: begin
          if (cnt+1 == `DISPLAY_WIDTH*2) begin
            if (row+1 == `DISPLAY_WIDTH) begin
              state <= ready;
            end else begin
              state <= frame_check;
              row <= row+1;
            end
          end else begin
            cnt <= cnt+1;
          end
        end
      endcase
    end
  end

  always_comb begin
    eth_trigger_in = 0;
    eth_data_in = 0;
    eth_last_dibit_in = 0;
    read_addr_out = 0;
    parity = 0;

    case (state)
      ready: begin
        if (eth_ready_out && export_trigger_in) begin
          eth_trigger_in = 1;
        end
      end
      start_frame: begin
        if (eth_data_ready_out) begin
          eth_data_in = 2'b11;
          if (cnt == 0) eth_last_dibit_in = 1;
        end
      end
      frame_check: begin
        if (eth_ready_out) begin
          eth_trigger_in = 1;
        end
      end
      start_row: begin
        if (eth_data_ready_out) begin
          eth_data_in = {row[2*cnt+1], row[2*cnt]};
        end
        if (cnt <= 1) begin
          read_addr_out = row*`DISPLAY_WIDTH + 0;
        end
      end
      pixels: begin
        col = cnt>>1;
        parity = cnt&1;
        eth_data_in = parity == 0 ? read_data_in[3:2] : read_data_in[1:0];
        read_addr_out = row*`DISPLAY_WIDTH + (col+1);
        if (cnt+1 == `DISPLAY_WIDTH*2) begin
          eth_last_dibit_in = 1;
        end
      end

    endcase
  end

  ether_tx ether_tx_inst(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .trigger_in(eth_trigger_in),
    .data_in(eth_data_in),
    .last_dibit_in(eth_last_dibit_in),
    .ready_out(eth_ready_out),
    .data_ready_out(eth_data_ready_out),
    .eth_txen(eth_txen),
    .eth_txd(eth_txd)
  );

endmodule // ether_export

`default_nettype wire
