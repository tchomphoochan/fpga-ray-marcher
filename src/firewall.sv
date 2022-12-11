`default_nettype none
`timescale 1ns / 1ps

module firewall(
  input wire clk,
  input wire rst,
  input wire axiiv,
  input wire [1:0] axiid,

  output logic axiov,
  output logic [1:0] axiod
);

  parameter MAC_ADDR = 48'h88_66_5a_03_48_b0;
  assign axiod = axiid;

  logic [5:0] cnt; // 8*6 + 8 = 56 dibits, need 6 bit counter
  logic [55:0][1:0] header;
  logic [23:0][1:0] dest;
  assign dest = header[55:55-24+1];

  assign axiov = axiiv && cnt == 56 && (dest == MAC_ADDR || dest == 48'hFF_FF_FF_FF_FF_FF);

  always_ff @(posedge clk) begin
    if (rst) begin
      cnt <= 0;
    end else begin
      if (axiiv) begin
        if (cnt <= 55) begin
          header[55-cnt] <= axiid;
          cnt <= cnt+1;
        end
      end else begin
        cnt <= 0;
      end
    end
  end

endmodule // firewall

`default_nettype wire