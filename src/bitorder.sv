`default_nettype none
`timescale 1ns / 1ps

/*
Buffers 4 bytes and returns dibits in reverse order.

Input: Each dibit is MSb internally. Dibits are given in LSb order.
Output: Dibits in MSb order.
Irrelevant: MSB order.
*/
module bitorder(
  input wire clk,
  input wire rst,
  input wire axiiv,
  input wire [1:0] axiid,

  output logic axiov,
  output logic [1:0] axiod
);

  logic rx_which_buf; // which buffer are we reading into
  logic [1:0] rx_cnt; // count which dibit we are reading into
  logic [3:0][1:0] buffer [1:0];

  logic [1:0] tx_cnt; // count which dibit we are reading out
  assign axiod = buffer[!rx_which_buf][tx_cnt];

  always_ff @(posedge clk) begin
    if (rst) begin
      rx_which_buf <= 0;
      rx_cnt <= 0;
      buffer[0] <= 0;
      buffer[1] <= 0;
      tx_cnt <= 0;
      axiov <= 0;
    end else begin
      if (axiiv) begin
        buffer[rx_which_buf][3-rx_cnt] <= axiid;
        if (rx_cnt == 3) begin
          rx_which_buf <= !rx_which_buf;
          tx_cnt <= 0;
          axiov <= 1;
        end else begin
          if (tx_cnt == 3) begin
            axiov <= 0;
          end
          tx_cnt <= tx_cnt+1;
        end
        rx_cnt <= rx_cnt+1;
      end else begin
        if (tx_cnt == 3) begin
          axiov <= 0;
        end
        tx_cnt <= tx_cnt+1;
        rx_cnt <= 0;
      end

    end
  end

endmodule // bitorder

`default_nettype wire