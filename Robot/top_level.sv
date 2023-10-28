//top level

module top_level (
	input logic [17:0] SW,
	input logic [3:0] KEY,
	input logic CLOCK_50,
	input logic IRDA_RXD,
	
	inout logic [6:0] EX_IO,
	inout logic [35:0] GPIO,
	
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

//**************************** Motor Control ***************************


Motor_ctrl_redone motor1 (
    .clk			(CLOCK_50),                // System Clock  
    .IR_input	(send),
	 
	 .enable1	(GPIO[3]),
	 .pwm1		(GPIO[9]),
    .ina1		(GPIO[5]),
	 .inb1		(GPIO[7]),
	 
	 .enable2	(GPIO[2]),
	 .pwm2		(GPIO[8]),
	 .ina2		(GPIO[4]),
	 .inb2		(GPIO[6])  // Direction controls for two motors
);

//**********************************************************************

//**************************** IR stuff ********************************

logic [31:0] hex_data;
logic [7:0] send;
logic [11:0] prev_data;

logic clk50;

pll1 u0(
	.inclk0		(CLOCK_50),
	//irda clock 50M 
	.c0			(clk50)        
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
assign LEDG = send;

always_ff @( CLOCK_50 ) begin
	
	if ( hex_data != prev_data ) begin
		case(hex_data[27:16]) 
			12'b1101_0000_0010: begin		// 2	Forwards
				send[7:0] <= 8'b0000_0010;
			end
			
			12'b1011_0000_0100: begin		// 4	Left
				send[7:0] <= 8'b0000_1000;
			end
			
			12'b1010_0000_0101: begin		// 5	Brake??
				send[7:0] <= 8'b0001_0000;
			end
			
			12'b1001_0000_0110: begin		// 6	Right
				send[7:0] <= 8'b0010_0000;
			end
			
			12'b0111_0000_1000: begin		// 8	Backwards
				send[7:0] <= 8'b1000_0000;
			end
			
			default: begin
				send[7:0] <= 8'b0000_0000;
			end
				
		endcase
		
		prev_data <= hex_data;
		
	end
	
	
end


logic [2:0] motor_stat;

always @( * ) begin
  case (send)
    8'b0000_0000: motor_stat = 3'b000;
    8'b0000_0010: motor_stat = 3'b001;
    8'b0000_1000: motor_stat = 3'b010;
    8'b0001_0000: motor_stat = 3'b011;
    8'b0010_0000: motor_stat = 3'b100;
    8'b1000_0000: motor_stat = 3'b101;
    default: motor_stat = 3'b111; // Default case, you can choose any value
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
assign tx_byte = {motor_stat, ,1'b0};


uart_tx #(.CLKS_PER_BIT(50_000_000/9600)) uart_tx_u (
	.clk 				(CLOCK_50),
	.tx				(EX_IO[2]),
	.valid			(tx_valid),
	.ready			(tx_ready),
	.data_to_send	(tx_byte)
);



endmodule

