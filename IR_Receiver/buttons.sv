

module buttons (
	input clk,
	input [3:0] KEYS,
	output logic [3:0] User_Buttons

);

	
	logic [3:0] button_pressed, button_q0_K;
	integer j;
	
	genvar i;
	 generate
		for (i = 0; i < 4; i = i + 1) begin: debounce_generation
			debounce deb_ (
				.clk(clk), 
				.button(KEYS[i]), 
				.button_pressed(button_pressed[i])
			);
		end
	endgenerate
	
	
	always_comb begin

		for (j = 0; j < 4; j = j + 1) begin
			User_Buttons[j] = (button_pressed[j] > button_q0_K[j]);
		end
	end
	
	always_ff @(posedge clk) begin: edge_detect
		button_q0_K <= button_pressed;
	end
		
	
endmodule
	
	