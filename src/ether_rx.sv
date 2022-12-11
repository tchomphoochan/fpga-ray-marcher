`default_nettype none
`timescale 1ns / 1ps

module ether_rx(
  input wire clk,
  input wire rst,
  input wire [1:0] rxd,
  input wire crsdv,

  output logic axiov,
  output logic [1:0] axiod
);

  // state: ready
  // state: validating preamble, 8 bytes = 32 dibits
  // state: false carrier
  // state: consuming data

  enum { ready, validating, fail, working } state;
  logic [4:0] count;

  always_ff @(posedge clk) begin
    if (rst) begin
      state <= ready;
      count <= 0;
      axiov <= 0;
    end else if (state == ready) begin
      if (crsdv && rxd == 2'b01) begin
        state <= validating;
        count <= 1;
      end else begin
        state <= ready;
      end
    end else if (state == validating) begin
      if (!crsdv) begin
        state <= ready;
      end
      if (rxd == (count == 31 ? 2'b11 : 2'b01)) begin
        state <= count == 31 ? working : validating;
        count <= count+1;
      end else begin
        state <= fail;
      end
    end else if (state == fail) begin
      if (!crsdv) begin
        state <= ready;
      end
    end else if (state == working) begin
      axiov <= 1;
      axiod <= rxd;
      if (!crsdv) begin
        state <= ready;
        axiov <= 0;
      end
    end
  end

endmodule // ether_rx

`default_nettype wire