`default_nettype none
`timescale 1ns / 1ps

module ether_tx(
  input wire clk_in,
  input wire rst_in,

  // for module driving it
  input logic trigger_in,
  input logic [1:0] data_in, // MSB MSb
  input logic last_dibit_in,
  output logic ready_out,
  output logic data_ready_out,

  // for ethernet
  output logic axiov,
  output logic [1:0] axiod
);

  parameter FPGA_MAC_ADDR = 48'h69_2C_08_30_75_FD;
  parameter LAPTOP_MAC_ADDR = 48'h88_66_5a_03_48_b0;

  typedef enum { ready, preamble, dest, src, ethertype, data, crc_wait, crc, finish } state_t;
  logic [10:0] cnt;
  state_t state;

  logic datav;
  logic [1:0] datad;
  logic outcrcv;
  logic [1:0] outcrcd;

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      datav <= 0;
      datad <= 0;
      data_ready_out <= 0;
      ready_out <= 1;
      state <= ready;
    end else begin
      if (state == ready) begin
        if (trigger_in) begin
          state <= preamble;
          datav <= 1;
          datad <= 2'b01;
          ready_out <= 0;
          cnt <= 1;
        end
      end else if (state == preamble) begin
        datad <= cnt == 28 ? 2'b11 : 2'b01;
        if (cnt == 31) begin
          state <= dest;
          cnt <= 46;
          $display("goto dest");
        end else begin
          cnt <= cnt+1;
        end
      end else if (state == dest) begin
        datad <= {LAPTOP_MAC_ADDR[cnt+1], LAPTOP_MAC_ADDR[cnt]};
        if (cnt == 0) begin
          state <= src;
          cnt <= 46;
          $display("goto src");
        end else begin
          cnt <= cnt-2;
        end
      end else if (state == src) begin
        datad <= {FPGA_MAC_ADDR[cnt+1], FPGA_MAC_ADDR[cnt]};
        if (cnt == 0) begin
          state <= ethertype;
          cnt <= 0;
          $display("goto ethertype");
        end else begin
          cnt <= cnt-2;
        end
      end else if (state == ethertype) begin
        datad <= 0;
        if (cnt == 7) begin
          state <= data;
          data_ready_out <= 1;
          cnt <= 0;
          $display("goto data");
        end else begin
          cnt <= cnt+1;
        end
      end else if (state == data) begin
        datad <= data_in;
        if (last_dibit_in) begin
          state <= crc_wait;
          data_ready_out <= 0;
          cnt <= 0;
          $display("goto crc_wait");
        end else begin
          cnt <= cnt+1;
        end
      end else if (state == crc_wait) begin
        // need to wait for bitorder to output stuff and feed things into crc
        datav <= 0;
        datad <= 0;
        if (cnt == 3) begin
          state <= crc;
          cnt <= 15;
          $display("goto crc");
        end else begin
          cnt <= cnt+1;
        end
      end else if (state == crc) begin
        // crc is now ready, so we output it directly (see assign axiov/axiod)
        if (cnt == 0) begin
          state <= finish;
          cnt <= 0;
          $display("goto finish");
        end else begin
          cnt <= cnt-1;
        end
      end else if (state == finish) begin
        state <= ready;
        ready_out <= 1;
      end
    end
  end

  always_comb begin
    if (state == crc) begin
      outcrcd = {crc32_axiod[2*cnt+1], crc32_axiod[2*cnt]};
      outcrcv = 1;
    end else begin
      outcrcd = 0;
      outcrcv = 0;
    end
  end

  bitorder bitorder_inst(
    .clk(clk_in),
    .rst(rst_in),
    .axiiv(datav),
    .axiid(datad),
    .axiov(crc32_axiiv),
    .axiod(crc32_axiid)
  );

  assign axiov = state != crc ? crc32_axiiv : outcrcv;
  assign axiod = state != crc ? crc32_axiid : outcrcd;

  logic crc32_axiiv;
  logic [1:0] crc32_axiid;
  logic crc32_axiov;
  logic [31:0] crc32_axiod;
  crc32 crc32_inst(
    .clk(clk_in),
    .rst(rst_in || (state == ready && !trigger_in) || state == finish),
    .axiiv(crc32_axiiv),
    .axiid(crc32_axiid),
    .axiov(crc32_axiov),
    .axiod(crc32_axiod)
  );

endmodule // ether_tx

`default_nettype wire