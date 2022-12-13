`default_nettype none
`timescale 1ns / 1ps

module ether_tx(
  input wire clk_in,
  input wire rst_in,

  input wire trigger_in,
  input wire [1:0] data_in, // MSB MSb
  input wire last_dibit_in, // should come with last dibit

  output logic ready_out,
  output logic data_ready_out,
  output logic eth_txen,
  output logic [1:0] eth_txd
);

  logic [23:0][1:0] FPGA_MAC_ADDR = 48'h11_11_11_11_11_11;
  logic [23:0][1:0] LAPTOP_MAC_ADDR = 48'h88_66_5a_03_48_b0;

  typedef enum { ready, preamble, dest, src, ethertype, data, crc_wait, crc, finish } state_t;
  logic [20:0] cnt;
  state_t state;

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      state <= ready;
    end else begin
      case (state)
        ready: begin
          if (trigger_in) begin
            state <= preamble;
            cnt <= 0;
          end
        end

        preamble: begin
          if (cnt == 31) begin
            state <= dest;
            cnt <= 23;
          end else begin
            cnt <= cnt+1;
          end
        end

        dest: begin
          if (cnt == 0) begin
            state <= src;
            cnt <= 23;
          end else begin
            cnt <= cnt-1;
          end
        end
        src: begin
          if (cnt == 0) begin
            state <= ethertype;
            cnt <= 3;
          end else begin
            cnt <= cnt-1;
          end
        end

        ethertype: begin
          if (cnt == 0) begin
            state <= data;
          end else begin
            cnt <= cnt-1;
          end
        end

        data: begin
          if (last_dibit_in) begin
            state <= crc_wait;
            cnt <= 3;
          end
        end

        crc_wait: begin
          if (cnt == 0) begin
            state <= crc;
            cnt <= 15;
          end else begin
            cnt <= cnt-1;
          end
        end

        crc: begin
          if (cnt == 0) begin
            state <= finish;
            cnt <= 59;
          end else begin
            cnt <= cnt-1;
          end
        end

        finish: begin
          if (cnt == 0) begin
            state <= ready;
          end else begin
            cnt <= cnt-1;
          end
        end

      endcase
    end
  end

  always_comb begin
    ready_out = 0;
    bitorder_data_in = 0;
    bitorder_valid_in = 0;
    data_ready_out = 0;
    eth_txen = bitorder_valid_out;
    eth_txd = bitorder_data_out;
    case (state)
      ready: begin
        ready_out = 1;
      end
      preamble: begin
        bitorder_valid_in = 1;
        bitorder_data_in = cnt == 28 ? 2'b11 : 2'b01;
      end
      dest: begin
        bitorder_valid_in = 1;
        bitorder_data_in = LAPTOP_MAC_ADDR[cnt];
      end
      src: begin
        bitorder_valid_in = 1;
        bitorder_data_in = FPGA_MAC_ADDR[cnt];
      end
      ethertype: begin
        bitorder_valid_in = 1;
        bitorder_data_in = 2'b00;
      end
      data: begin
        data_ready_out = 1;
        bitorder_valid_in = 1;
        bitorder_data_in = data_in;
      end
      crc_wait: begin
        data_ready_out = 0;
        bitorder_valid_in = 0;
      end
      crc: begin
        eth_txen = crc32_valid_out;
        {eth_txd[0], eth_txd[1]} = crc32_data_out[cnt];
      end
      finish: begin
        eth_txen = 0;
      end

    endcase
  end

  logic bitorder_valid_in, bitorder_valid_out;
  logic [1:0] bitorder_data_in, bitorder_data_out;
  bitorder bitorder_inst(
    .clk(clk_in),
    .rst(rst_in),
    .axiiv(bitorder_valid_in),
    .axiid(bitorder_data_in),
    .axiov(bitorder_valid_out),
    .axiod(bitorder_data_out)
  );

  logic crc32_valid_out;
  logic [15:0][1:0] crc32_data_out;
  crc32 crc32_inst(
    .clk(clk_in),
    .rst(rst_in || state == ready), // TODO
    .axiiv(bitorder_valid_out && state != ready && state != preamble && (state != dest || cnt < 20)),
    .axiid(bitorder_data_out),
    .axiov(crc32_valid_out),
    .axiod(crc32_data_out)
  );

endmodule // ether_tx

`default_nettype wire