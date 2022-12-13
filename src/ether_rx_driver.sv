`timescale 1ns / 1ps
`default_nettype none

// adapted from lab 05 top_level.sv
module ether_rx_driver(
  input wire clk,
  input wire rst,
  input wire eth_crsdv,
  input wire [1:0] eth_rxd,
  output logic axiov,
  output logic [31:0] axiod
);

  // instantiate the module
  logic eth_axiov;
  logic [1:0] eth_axiod;
  ether_rx ether_inst(
    .clk(clk),
    .rst(rst),
    .rxd(eth_rxd),
    .crsdv(eth_crsdv),
    .axiov(eth_axiov),
    .axiod(eth_axiod)
  );

  logic bit_axiov;
  logic [1:0] bit_axiod;
  bitorder bitorder_inst(
    .clk(clk),
    .rst(rst),
    .axiiv(eth_axiov),
    .axiid(eth_axiod),
    .axiov(bit_axiov),
    .axiod(bit_axiod)
  );

  logic fw_axiov;
  logic [1:0] fw_axiod;
  firewall firewall_inst(
    .clk(clk),
    .rst(rst),
    .axiiv(bit_axiov),
    .axiid(bit_axiod),
    .axiov(fw_axiov),
    .axiod(fw_axiod)
  );

  logic done;
  logic kill;
  cksum cksum_inst(
    .clk(clk),
    .rst(rst),
    .axiiv(eth_axiov),
    .axiid(eth_axiod),
    .done(done),
    .kill(kill)
  );

  // display first 32 bits
  logic agg_axiov;
  logic [31:0] agg_axiod;
  aggregate aggregate_inst(
    .clk(clk),
    .rst(rst),
    .axiiv(fw_axiov),
    .axiid(fw_axiod),
    .axiov(agg_axiov),
    .axiod(agg_axiod)
  );

  logic prev_done;
  logic is_okay;
  always_ff @(posedge clk) begin
    if (rst) begin
      prev_done <= 0;
      is_okay <= 0;
    end else begin
      if (done && !prev_done) begin
        is_okay <= !kill;
      end
      prev_done <= done;
    end
  end

  assign axiov = is_okay;
  assign axiod = agg_axiod;

endmodule

`default_nettype wire
