//new timer


`timescale 1ns/1ns

module cont_timer (
	input logic clk,    
	input logic start_timer,  

	output logic [31:0] counter,
	output logic overflow
);


	logic start, active;
	 
	debounce trigger (
		.clk					( clk ),
		.button 				( start_timer ),
		.button_pressed	( start )
	);

	
	always_ff @(posedge clk) begin
		
		counter <= counter+1;

		if ( start ) begin
		
			counter <= 0;
			
		end
		
		overflow <= ( counter == 32'hFFFFFFFF ) ? 1 : 0;

	end

endmodule

