`default_nettype none
`timescale 1ns / 1ps

module aggregate(
  input wire clk,
  input wire rst,
  input wire axiiv,
  input wire [1:0] axiid,

  output logic axiov,
  output logic [31:0] axiod
);

  logic [31:0][1:0] buffer;
  logic [5:0] cnt;

  always_ff @(posedge clk) begin
    if (rst) begin
      buffer <= 0;
      cnt <= 0;
      axiov <= 0;
    end else begin

      if (axiiv) begin
        if (cnt < 31) begin
          buffer[31-cnt] <= axiid;
          cnt <= cnt+1;
        end else if (cnt == 31) begin
          cnt <= cnt+1;
          axiov <= 1;
          axiod <= buffer[31:16];
          buffer[31-cnt] <= axiid;
        end else begin
          axiov <= 0;
        end
        
      end else begin
        cnt <= 0;
        axiov <= 0;
      end

    end
  end


endmodule // aggregate

`default_nettype wire