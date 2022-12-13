`timescale 1ns / 1ps
`default_nettype none

`include "types.svh"

module ether_export(
  input wire clk_in,
  input wire rst_in,
  input wire trigger_in,
  // should connect to bram
  input wire [3:0] read_data_in, // 4-bit grayscale
  output logic [`ADDR_BITS-1:0] read_addr_out,
  // connect to ethernet pins
  output logic running,
  output logic eth_txen,
  output logic [1:0] eth_txd
);

  typedef enum { ready, start_frame, frame_check, start_row, pixels, end_row } state_t;
  state_t state;

  logic eth_trigger_in, eth_last_dibit_in, eth_data_ready, eth_ready;
  logic [1:0] eth_data_in;
  logic [15:0] cnt;

  logic [15:0] read_row, read_col;
  assign read_addr_out = (read_row << `H_BITS) + read_col;

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      state <= ready;
      eth_trigger_in <= 0;
      // running <= 0;
      // eth_last_dibit_in = 0;
      cnt <= 0;
    end else begin
      case (state)
        ready: begin
          // running <= 0;
          if (trigger_in && eth_ready) begin
            // running <= 1;
            eth_trigger_in <= 1; // start sending preamble
            state <= start_frame;
            read_row <= 0;
            cnt <= 0;
          end
        end
        start_frame: begin
          // wait for premable to be done
          eth_trigger_in <= 0;
          if (eth_data_ready) begin
            // send 50 bytes of 1s (100 dibits)
            // eth_data_in = 2'b11;
            if (cnt == 99) begin
              // eth_last_dibit_in = 1;
              state <= frame_check;
              cnt <= 0;
            end else begin
              cnt <= cnt+1;
            end
          end
        end
        frame_check: begin
          // wait until ethernet is done sending frame-start message - start sending preamble
          // eth_last_dibit_in = 0;
          if (eth_ready) begin
            if (read_row == `DISPLAY_HEIGHT) begin
              state <= ready;
            end else begin
              eth_trigger_in <= 1;
              state <= start_row;
              cnt <= 0;
            end
          end
        end
        start_row: begin
          // wait for premable to be done
          eth_trigger_in <= 0;
          if (eth_data_ready) begin
            // send row number as two bytes (8 dibits)
            if (cnt < 8) begin
              // eth_data_in = {read_row[2*cnt+1], read_row[2*cnt]};
            end
            // start requesting data
            // if (cnt == 6 || cnt == 7) begin
            //   read_col <= 0;
            // end
            // row number done
            if (cnt == 7) begin
              cnt <= 2;
              state <= pixels;
            end else begin
              cnt <= cnt+1;
            end
          end
        end
        pixels: begin
          // scheme:
          // request address col=0 (already done)
          // request address col=0 (already done)
          // col=0 answer came back (4 bits). put in two bits. request address col=1
          // put in another two bits. request address col=1
          // col=1 answer came back (4 bits). put in two bits. request address col=2
          // put in another two bits. request address col=2
          // ...
          if ((cnt>>1) < `DISPLAY_WIDTH) begin
            if ((cnt & 1'b1) == 0) begin
              // eth_data_in = read_data_in[3:2];
            end else begin
              // eth_data_in = read_data_in[1:0];
            end
            // read_col <= cnt>>1;
            cnt <= cnt+1;
          end else begin
            cnt <= 0;
            state <= end_row;
          end
        end
        end_row: begin
          // send the last two dibits of the row
          if (cnt == 0) begin
            // eth_data_in = read_data_in[3:2];
            cnt <= cnt+1;
          end else begin
            // eth_data_in = read_data_in[1:0];
            // eth_last_dibit_in = 1;
            cnt <= cnt+1;
            read_row <= read_row+1;
            state <= frame_check;
          end
        end
      endcase
    end
  end

  always_comb begin
    eth_last_dibit_in = 0;
    read_col = 0;
    eth_data_in = 0;
    if (rst_in) begin
      eth_last_dibit_in = 0;
    end else begin
      case (state)
        ready: begin
          if (trigger_in && eth_ready) begin
          end
        end
        start_frame: begin
          // wait for premable to be done
          if (eth_data_ready) begin
            // send 50 bytes of 1s (100 dibits)
            eth_data_in = 2'b11;
            if (cnt == 99) begin
              eth_last_dibit_in = 1;
            end else begin
            end
          end
        end
        frame_check: begin
          eth_last_dibit_in = 0;
          if (eth_ready) begin
            if (read_row == `DISPLAY_HEIGHT) begin
            end else begin
            end
          end
        end
        start_row: begin
          // wait for premable to be done
          if (eth_data_ready) begin
            // send row number as two bytes (8 dibits)
            if (cnt < 8) begin
              eth_data_in = {read_row[2*cnt+1], read_row[2*cnt]};
            end
            // start requesting data
            if (cnt == 6 || cnt == 7) begin
              read_col = 0;
            end
            // row number done
            if (cnt == 7) begin
            end else begin
            end
          end
        end
        pixels: begin
          // scheme:
          // request address col=0 (already done)
          // request address col=0 (already done)
          // col=0 answer came back (4 bits). put in two bits. request address col=1
          // put in another two bits. request address col=1
          // col=1 answer came back (4 bits). put in two bits. request address col=2
          // put in another two bits. request address col=2
          // ...
          if ((cnt>>1) < `DISPLAY_WIDTH) begin
            if ((cnt & 1'b1) == 0) begin
              eth_data_in = read_data_in[3:2];
            end else begin
              eth_data_in = read_data_in[1:0];
            end
            read_col = cnt>>1;
          end else begin
          end
        end
        end_row: begin
          // send the last two dibits of the row
          if (cnt == 0) begin
            eth_data_in = read_data_in[3:2];
          end else begin
            eth_data_in = read_data_in[1:0];
            eth_last_dibit_in = 1;
          end
        end
      endcase
    end
  end

  ether_tx ether_tx_inst(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .trigger_in(eth_trigger_in),
    .data_in(eth_data_in),
    .last_dibit_in(eth_last_dibit_in),
    .ready_out(eth_ready),
    .data_ready_out(eth_data_ready),
    .axiov(eth_txen),
    .axiod(eth_txd)
  );

endmodule // ether_export

`default_nettype wire
