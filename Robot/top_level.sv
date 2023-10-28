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

logic [31:0] hex_data;
logic [7:0] send;
logic [11:0] prev_data;

logic clk50;

pll1 u0(
	.inclk0		(CLOCK_50),
	//irda clock 50M 
	.c0			(clk50),          
//	.c1			()
);

IR_RECEIVE u1(
	///clk 50MHz////
	.iCLK			(clk50), 
	//reset          
	.iRST_n		(KEY[0]),        
	//IRDA code input
	.iIRDA		(IRDA_RXD), 
	//read command      
	//.iREAD(data_read),
	//data ready      					
	.oDATA_READY(data_ready),
	//decoded data 32bit
	.oDATA		(hex_data)        
);

assign LEDR[11:0] = hex_data[27:16];
//assign LEDG[7:0] = send[7:0];

always_ff @( CLOCK_50 ) begin
	
	if ( hex_data != prev_data ) begin
		case(hex_data[27:16]) 
			12'b1101_0000_0010: begin		// 2
				send[7:0] = 8'b0000_0010;
			end
			
			12'b1011_0000_0100: begin		// 4
				send[7:0] = 8'b0000_1000;
			end
			
			12'b1010_0000_0101: begin		// 5
				send[7:0] = 8'b0001_0000;
			end
			
			12'b1001_0000_0110: begin		// 6
				send[7:0] = 8'b0010_0000;
			end
			
			12'b0111_0000_1000: begin		// 8
				send[7:0] = 8'b1000_0000;
			end
			
			12'b1111_0000_0000: begin		// 0 
				send[7:0] = 8'b0000_0001;
			end
			
			default: begin
				send[7:0] = 8'b0000_0000;
			end
				
		endcase
		
		prev_data <= hex_data;
		
	end
	
	else begin
	
		prev_data <= 16'b0000_0000_0000_0000;
		send[7:0] = 8'b0000_0000;
		
	end
	
end


logic [2:0] binary;

always @( * ) begin
  case (send)
    8'b00000001: binary = 3'b000;
    8'b00000010: binary = 3'b001;
    8'b00000100: binary = 3'b010;
    8'b00001000: binary = 3'b011;
    8'b00010000: binary = 3'b100;
    8'b00100000: binary = 3'b101;
    8'b01000000: binary = 3'b110;
    8'b10000000: binary = 3'b111;
    default: binary = 3'b000; // Default case, you can choose any value
  endcase
end


	
	
//***********************************************************************

//************************** UART stuff *********************************

//logic [7:0] rx_byte;
//logic rx_valid;         // handshake
//logic rx_ready = 1'b1;  // handshake. We are always ready to receive.
//logic [7:0] current_data;
//
//
//uart_rx #(.CLKS_PER_BIT(50_000_000/9600)) uart_rx_u (
//	.clk				(CLOCK_50), 
//	.rx				(EX_IO[1]), 
//	.valid			(rx_valid), 
//	.ready			(rx_ready),
//	.data_received	(rx_byte)
//); // Receive on GPIO[7].

logic [7:0] tx_byte;
logic tx_valid;
logic tx_ready;

assign tx_valid = 1'b1;
assign tx_byte = {SW[7:6], binary, 3'b000};
assign LEDG = tx_byte;

uart_tx #(.CLKS_PER_BIT(50_000_000/9600)) uart_tx_u (
	.clk 				(CLOCK_50),
	.tx				(EX_IO[2]),
	.valid			(tx_valid),
	.ready			(tx_ready),
	.data_to_send	(tx_byte),
);



endmodule

