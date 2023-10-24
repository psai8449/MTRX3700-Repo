//memory ctrl


module memory_ctrl (

	input logic CLOCK_50,
//	input logic RX,
	input [3:0] KEY,
	input logic [17:0] SW,
	
	output logic [17:0] LEDR,
	output logic [8:0] LEDG
);

BRAM_IP ram1 (
	.clock		( CLOCK_50 ),
	.data			( data ),
	.rdaddress	( read_address ),
	.wraddress	( write_address ),
	.wren			( write_en ),
	.q				( LEDG[7:0] )
);

debounce U1 (
	.clk				( CLOCK_50 ),
	.button			( KEY[0] ),
	.button_pressed( write_en )
);

logic [7:0] data;
logic [4:0] write_address;
logic [4:0] read_address;
logic write_en;

assign data = SW[7:0];
//assign LEDG[7:0] = SW[7:0];
assign LEDR[7:0] = SW[7:0];
assign LEDG[8] = KEY[0];
assign LEDR[12:8] = write_address;
assign LEDR[17:13] = read_address;

initial begin

	write_address = 0;
	read_address = 0;
	write_en = 1'b1;
	
end

always_ff @(posedge KEY[0]) begin
	
	write_address <= write_address + 1;
	read_address <= write_address;
	
end

endmodule

