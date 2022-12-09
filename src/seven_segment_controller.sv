`default_nettype none

module seven_segment_controller #(parameter COUNT_TO = 'd100_000)
                        (input wire         clk_in,
                         input wire         rst_in,
                         input wire [31:0]  val_in,
                         output logic[6:0]   cat_out,
                         output logic[7:0]   an_out
                        );
  logic [7:0]	segment_state;
  logic [31:0]	segment_counter;
  logic [3:0]	routed_vals;
  logic [6:0]	led_out;
  /* TODO: wire up routed_vals (-> x_in) with your input, val_in
   * Note that x_in is a 4 bit input, and val_in is 32 bits wide
   * Adjust accordingly, based on what you know re. which digits
   * are displayed when...
   */
  always_comb begin
    routed_vals = 0;
    for (integer i = 0; i < 8; i += 1) begin
      if (segment_state == (8'b01 << i)) begin
        routed_vals = {val_in[i*4+3], val_in[i*4+2], val_in[i*4+1], val_in[i*4]};
      end
    end

    // case (segment_state)
    //   8'b0000_0001: routed_vals = {val_in[3], val_in[2], val_in[1], val_in[0]};
    //   8'b0000_0010: routed_vals = {val_in[7], val_in[6], val_in[5], val_in[4]};
    //   8'b0000_0100: routed_vals = {val_in[11], val_in[10], val_in[9], val_in[8]};
    //   8'b0000_1000: routed_vals = {val_in[15], val_in[14], val_in[13], val_in[12]};
    //   8'b0001_0000: routed_vals = {val_in[19], val_in[18], val_in[17], val_in[16]};
    //   8'b0010_0000: routed_vals = {val_in[23], val_in[22], val_in[21], val_in[20]};
    //   8'b0100_0000: routed_vals = {val_in[27], val_in[26], val_in[25], val_in[24]};
    //   8'b1000_0000: routed_vals = {val_in[31], val_in[30], val_in[29], val_in[28]};
    // endcase
  end

  bto7s mbto7s (.x_in(routed_vals), .s_out(led_out));
  assign cat_out = ~led_out; //<--note this inversion is needed
  assign an_out = ~segment_state; //note this inversion is needed
  always_ff @(posedge clk_in)begin
    if (rst_in)begin
      segment_state <= 8'b0000_0001;
      segment_counter <= 32'b0;
    end else begin
      if (segment_counter == COUNT_TO) begin
        segment_counter <= 32'd0;
        segment_state <= {segment_state[6:0],segment_state[7]};
    	end else begin
    	  segment_counter <= segment_counter +1;
    	end
    end
  end
endmodule // seven_segment_controller

`default_nettype wire