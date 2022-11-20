`default_nettype none
`timescale 1ns / 1ps

module fps_counter #(
  parameter WIDTH = 32
) (
  input wire clk_in,
  input wire rst_in,
  input wire new_frame_in,
  output logic [WIDTH-1:0] fps_out
);

  logic [WIDTH-1:0] frame_cnt, cycle_cnt, assigned_frame_cnt, assigned_cycle_cnt, quotient, remainder;
  logic valid_in, valid_out, error_out, busy_out;

  divider #(.WIDTH(WIDTH)) divider_inst(
    .rst_in(rst_in),
    .dividend_in(assigned_frame_cnt),
    .divisor_in(assigned_cycle_cnt),
    .data_valid_in(valid_in),
    .quotient_out(quotient),
    .remainder_out(remainder),
    .data_valid_out(valid_out),
    .error_out(error_out),
    .busy_out(busy_out)
  );

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      frame_cnt <= 0;
      cycle_cnt <= 0;
      valid_in <= 0;
      fps_out <= 0;
    end else begin
      if (valid_out && !error_out) begin
        fps_out <= quotient;
      end
      if (!busy_out) begin
        assigned_frame_cnt <= frame_cnt;
        assigned_cycle_cnt <= cycle_cnt;
        frame_cnt <= 0;
        cycle_cnt <= 0;
        valid_in <= 1;
      end else begin
        valid_in <= 0;
        frame_cnt <= frame_cnt + new_frame_in;
        cycle_cnt <= cycle_cnt+1;
      end
    end
  end
  
endmodule // fps_counter

`default_nettype wire