`default_nettype none
`timescale 1ns / 1ps

module cksum(
  input wire clk,
  input wire rst,
  input wire axiiv,
  input wire [1:0] axiid,

  output logic done,
  output logic kill
);

  localparam MAGIC_CHECK = 32'h38_fb_22_84;

  logic crc32_axiov;
  logic [31:0] crc32_axiod;

  crc32 crc32_inst(
    .clk(clk),
    .rst(rst || !axiiv),
    .axiiv(axiiv),
    .axiid(axiid),
    .axiov(crc32_axiov),
    .axiod(crc32_axiod)
  );

  logic prev_axiiv;

  always_ff @(posedge clk) begin
    if (rst) begin
      prev_axiiv <= 0;
      done <= 0;
      kill <= 0;
    end else begin
      if (axiiv && !prev_axiiv) begin
        done <= 0;
        kill <= 0;
      end else if (!axiiv && prev_axiiv) begin
        done <= 1;
        kill <= crc32_axiod != MAGIC_CHECK;
      end

      prev_axiiv <= axiiv;
    end
  end

endmodule // cksum

`default_nettype wire