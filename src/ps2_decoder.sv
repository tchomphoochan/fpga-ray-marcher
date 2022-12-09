module ps2_decoder(input wire clk_in,
  input wire rst_in,
  input wire ps_data_in,
  input wire ps_clk_in,
  output logic [7:0] code_out,
  output logic code_valid_out
);
  logic prev_ps_clk_in;
  logic [3:0] counter;
  logic is_valid;

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      prev_ps_clk_in <= 1;
      counter <= 0;
      code_out <= 0;
      code_valid_out <= 0;
      is_valid <= 0;
    end else if (is_valid) begin
      // ensure code_valid_out is 1 for only a cycle
      code_valid_out <= 0;
      is_valid <= 0;
    end else begin
      if (prev_ps_clk_in == 1 && ps_clk_in == 0) begin
        if (counter == 0) begin
          // start bit
          if (ps_data_in == 0) begin
            counter <= counter+1;
          end
          // otherwise do nothing
        end else if (counter <= 8) begin
          // 8 bit of data
          code_out[counter-1] <= ps_data_in;
          counter <= counter+1;
        end else if (counter == 9) begin
          // parity bit
          if (~(^code_out) == ps_data_in) begin
            code_valid_out <= 1;
            is_valid <= 1; // will turn to 0 
          end
          counter <= counter+1;
        end else if (counter == 10) begin
          // stop bit
          code_valid_out <= 0;
          counter <= 0;
        end
      end
      prev_ps_clk_in <= ps_clk_in;
    end

  end

endmodule
