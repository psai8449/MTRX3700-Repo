//top level

module top_level (
	input logic [17:0] SW,
	input logic [3:0] KEY,
	input logic CLOCK_50,
	input logic IRDA_RXD,
	
	inout logic [6:0] EX_IO,
	inout [35:0] GPIO,
	
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

//assign LEDR[11:0] = hex_data[27:16];
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
    8'b0000_0000: motor_stat = 3'b000;		// default
    8'b0000_0010: motor_stat = 3'b001;		// forwards	
    8'b0000_1000: motor_stat = 3'b010;		// left
    8'b0001_0000: motor_stat = 3'b011;		// brake
    8'b0010_0000: motor_stat = 3'b100;		// right
    8'b1000_0000: motor_stat = 3'b101;		// backwards
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

logic [7:0] proximity_stat;
assign LEDR[3:0] = prox_status;

logic [3:0] prox_status;

always_comb begin
	prox_status = ( proximity_stat > 6'b111111) ? 4'b1111 : ( (proximity_stat < 3'b100) ? 4'b0000 : proximity_stat[5:2] ); 
end

assign tx_byte = {prox_status[3:0], motor_stat, 1'b1};

//assign tx_byte = SW[7:0];

uart_tx #(.CLKS_PER_BIT(50_000_000/9600)) uart_tx_u (
	.clk 				(CLOCK_50),
	.tx				(EX_IO[2]),
	.valid			(tx_valid),
	.ready			(tx_ready),
	.data_to_send	(tx_byte)
);

//*************************************************************************

//************************ Proximity **************************************


  proximity u100(
  .CLOCK_50(CLOCK_50),
  .GPIO_35(GPIO[35]),
  .GPIO_34(GPIO[34]),
  .LEDR(proximity_stat)
  );
  logic start, reset, measurement_trigger;
  logic echo, trigger;
  logic [7:0] proximity_stat;

  assign echo = GPIO[35];
  assign GPIO[34] = trigger;

  // Add a timer for measurements
  always @(posedge CLOCK_50) begin
    if (measurement_trigger)
      start <= 1'b1;
    else
      start <= 1'b0;
  end



  sensor_driver u2(
    .clk			(CLOCK_50),
    .rst			(reset),
    .measure	(start), // Measure on trigger
    .echo		(echo),
    .trig		(trigger), 
    .distance	(proximity_stat)

  );
  
  //**************************************************************************


endmodule

