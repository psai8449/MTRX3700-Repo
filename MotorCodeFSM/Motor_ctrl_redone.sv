// Motor_ctrl_Redone

module Motor_ctrl_redone (
    input logic clk,                // System Clock  
    input [7:0] IR_input,
	 input [6:0] duty_cycle_1,
	 input [6:0] duty_cycle_2,
	 
	 
    output logic pwm1,
	 output logic pwm2,
	 output logic enable1, enable2,
    output logic ina1, inb1, ina2, inb2  // Direction controls for two motors
);
	
	pwm PWM1 (
	
		.clk_50			(clk), // 50MHz clock
		.DUTY_CYCLE		(duty_cycle_1),					//	<-- duty_cycle_1
		.pwm_out			(pwm1) // pwm output
		
	);
	
	pwm PWM2 (
	
		.clk_50			(clk), // 50MHz clock
		.DUTY_CYCLE		(duty_cycle_2),					//	<-- duty_cycle_2
		.pwm_out			(pwm2) // pwm output
		
	);


	assign enable1 = 1'b1;
	assign enable2 = 1'b1;

	always_comb begin : direction_logic
	
		case(IR_input)
			8'b0001_0000: begin		// brake
				ina1 = 1'b0;
				inb1 = 1'b0;
				ina2 = 1'b0;
				inb2 = 1'b0;
			end

			8'b0000_0010: begin		// forwards
				ina1 = 1'b0;
            inb1 = 1'b1;
            ina2 = 1'b0;
            inb2 = 1'b1;
			 end
		
			8'b0000_1000: begin		// left
				ina1 = 1'b0;
            inb1 = 1'b1;
            ina2 = 1'b1;
            inb2 = 1'b0;
			end
			
			8'b0010_0000: begin		// right
				ina1 = 1'b1;
            inb1 = 1'b0;
            ina2 = 1'b0;
            inb2 = 1'b1;
			end
			
			8'b1000_0000: begin		// backward
				ina1 = 1'b1;
            inb1 = 1'b0;
            ina2 = 1'b1;
            inb2 = 1'b0;
			end
			
			default: begin				// Default another break
				ina1 = 1'b1;
            inb1 = 1'b1;
            ina2 = 1'b1;
            inb2 = 1'b1;
			end
			
		endcase

    end


endmodule


