

module pwm (
    input logic clk_50, // 50MHz clock
	 input logic rst,
	 input logic [6:0] DUTY_CYCLE,
	 
    output logic pwm_out // pwm output
);

	logic [16:0] counter = 17'b0;
	
	always_ff @(posedge clk_50) begin
	
		
		if (rst || counter == 100_000) begin
			counter <= 17'b0;
			pwm_out <= 1'b0;
		end
		
		else begin
			counter <= counter + 1;
			if (counter < DUTY_CYCLE * 1000) begin
				pwm_out <= 1'b1;
			end
			else begin
				pwm_out <= 1'b0;
			end
			
		end
		
	end
		
	 
 endmodule
 