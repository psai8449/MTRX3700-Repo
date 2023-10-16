//IR main

module IR_main (
//	input logic GPIO,
	input logic CLOCK_50,
	input logic SW[3:0],
	
	output logic LEDR
);

logic [31:0] timer_count;
logic IR_signal, timer_reset;

logic [31:0] tempCode, code;
logic [7:0] bitIndex, cmd, cmdli;

cont_timer IR_timer (	//starts counting immediately
	.clk					( CLOCK_50 ),
	.start_timer		(  ),
	
	.counter				( timer_count ),
	.overflow			(  )
);
	


//may want to reduce the delay val for debounce given the speed of the IR signal

debounce IR_rising_edge_detect (
	.clk					( CLOCK_50 ),
	.button				( GPIO ),
	.button_pressed	( IR_signal )
);


always_ff @(posedge GPIO) begin

	if ( timer_count > 8000 ) begin
		tempCode = 0;
		bitIndex = 0;
	end
	
	else if ( timer_count > 1700 ) begin
		tempCode = tempCode | (1 << (31 - bitIndex));		//write 1
		bitIndex = bitIndex + 1;
	end
	
	else if ( timer_count > 1000 ) begin
		tempCode = tempCode & ~(1 << (31 - bitIndex));	//write 0
		bitIndex = bitIndex + 1;
	end
	
	
	if (bitIndex == 32) begin
		cmdli = ~tempCode[7:0];	// Logical inverted last 8 bits
		cmd = tempCode[15:8];		// Second last 8 bits
		
		if (cmdli == cmd)	begin//	check for errors
			code = tempCode;
			
//			case(code) begin
//			
//			//FILL IN
//			endcase
			
		end
		
		bitIndex = 0;
		
	end
	
	timer_reset = 1;
	
end


always_ff @(posedge CLOCK_50) begin

	if (timer_reset == 1) begin
		timer_reset <= 0;
	end	
	
end

endmodule


