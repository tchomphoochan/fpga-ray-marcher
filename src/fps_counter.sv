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

  parameter ONE_SECOND_CYCLES = 'd4_000_000;
  parameter WAIT_SECONDS = 'd5;

  logic [WIDTH-1:0] frame_cnt, snd_cnt, cycle_cnt, assigned_frame_cnt, assigned_snd_cnt, quotient, remainder;
  logic valid_in, valid_out, error_out, busy_out;

  divider #(.WIDTH(WIDTH)) divider_inst(
    .rst_in(rst_in),
    .dividend_in(assigned_frame_cnt),
    .divisor_in(assigned_snd_cnt),
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
      snd_cnt <= 0;
    end else begin
      if (valid_out && !error_out) begin
        fps_out <= quotient;
      end
      if (!busy_out && snd_cnt >= WAIT_SECONDS) begin
        assigned_frame_cnt <= frame_cnt;
        assigned_snd_cnt <= snd_cnt;
        frame_cnt <= 0;
        cycle_cnt <= 0;
        snd_cnt <= 0;
        valid_in <= 1;
      end else begin
        valid_in <= 0;
        frame_cnt <= frame_cnt + new_frame_in;
        if (cycle_cnt == ONE_SECOND_CYCLES) begin
          snd_cnt <= snd_cnt + 1;
          cycle_cnt <= 0;
        end else begin
          cycle_cnt <= cycle_cnt+1;
        end
      end
    end
  end
  
endmodule // fps_counter

`default_nettype wire