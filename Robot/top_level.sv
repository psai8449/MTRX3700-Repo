//top level

module top_level (
	input logic [17:0] SW,
	input logic [3:0] KEY,
	input logic CLOCK_50,
	input logic IRDA_RXD,
	
	inout logic [6:0] EX_IO,
	
	output logic [8:0] LEDG,
	output logic [17:0] LEDR
);

logic data_ready;
logic [31:0] IR_input;

//
//BRAM_IP ram1 (
//	.clock 		( CLOCK_50 ),
//	.data			(  ),
//	.rdaddress	(  ),
//	.wraddess	(  ),
//	.wren			(  ),
//	.q				(  )
//);


//**************************** IR stuff ********************************
	//pll1 u0 (
	//	.inclk0		(CLOCK_50),
	//	//irda clock 50M 
	//	.c0			(clk50),          
	//	.c1			()
	//);
	//
	//IR_RECEIVE u1(
	//	///clk 50MHz////
	//	.iCLK			(clk50), 
	//	//reset          
	//	.iRST_n		(KEY[0]),        
	//	//IRDA code input
	//	.iIRDA		(IRDA_RXD), 
	//	//read command      
	//	//.iREAD(data_read),
	//	//data ready      					
	//	.oDATA_READY(data_ready),
	//	//decoded data 32bit
	//	.oDATA		( IR_input )        
	//);
	//
	//ir_interpreter translator (
	//	.ir_input 	( IR_input ),
	//	
	//	.ir_command	(  )
	//);
	
//***********************************************************************

//************************** UART stuff *********************************

logic [7:0] rx_byte;
logic rx_valid;         // handshake
logic rx_ready = 1'b1;  // handshake. We are always ready to receive.
logic [7:0] current_data;


uart_rx #(.CLKS_PER_BIT(50_000_000/9600)) uart_rx_u (
	.clk				(CLOCK_50), 
	.rx				(EX_IO[1]), 
	.valid			(rx_valid), 
	.ready			(rx_ready),
	.data_received	(rx_byte)
); // Receive on GPIO[7].

assign LEDR[7:0] = current_data[7:0];

always_ff @(posedge CLOCK_50) begin

	if (rx_valid & rx_ready) begin        // Handshake: uart_rx has got data for us.
//		case(rx_byte)
//			7'b0001011: current_data <= 8'b00001011; // Increment count if we receive 0x81.
//			7'b0001010: current_data <= 8'b00001010;   // Set tx_valid high if we receive 0x82.
//			default: current_data <= 8'b0000_0000;
//		endcase
		current_data <= rx_byte;
	
	end
	
end


endmodule

