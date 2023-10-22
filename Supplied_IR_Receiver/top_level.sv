
module top_level (
	output logic [7:0] LEDG,
	input logic CLOCK_50,
	input logic IRDA_RXD
);

IR coms (
	.clk		( CLOCK_50 ),
	.IR		( IRDA_RXD ),
	.led_db	( LEDG[7:0] )
);


endmodule



