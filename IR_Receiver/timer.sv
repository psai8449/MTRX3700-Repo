`timescale 1ns/1ns

module timer (
	input logic clk,    
	input logic start_timer,  
	output logic turn_on,
	output logic [31:0] counter
);
    
    localparam TWO_SECONDS = 25_000_000; // 50 MHz * 0.5 seconds


    //must be careful to set duration == 0 if we want the timer to operate for two seconds

    
    always_ff @(posedge clk) begin

			if (start_timer) 
			begin
				 if (counter < TWO_SECONDS) begin
					  counter <= counter+1;
					  turn_on <= 0;
				 end
				 else if (counter >= TWO_SECONDS) begin
					  counter <= 0;
					  turn_on <= 1;
				 end
			end
			else begin
				 counter <= 0;
				 turn_on <= 0;
			end

    end

endmodule


