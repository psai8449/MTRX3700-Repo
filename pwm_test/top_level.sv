 
 
 module top_level (
 
	input logic CLOCK_50,
	
	output logic LEDG[8:0]
 
 );
 
 
 pwm u1 (
	.clk		( CLOCK_50 ),
	.pwm_out	( LEDG[0] )
 );
 
 endmodule
 
 