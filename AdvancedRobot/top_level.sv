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



//**************************** FSM *************************************

assign LEDG = send;
logic [2:0] motor_stat;


FSM u2(

	.CLK				(CLOCK_50),
	.PROX_STAT		(prox_status),
	.HEX_DATA		(hex_data),
	.RX_BYTE			(rx_byte),
	
	.DUTY				(duty),
	.SEND				(send),
	.MOTOR_STAT		(motor_stat)
	
);

//**********************************************************************

//**************************** Motor Control ***************************
logic [6:0] duty;

Motor_ctrl_redone  		motor1 (

    .clk			(CLOCK_50),                // System Clock  
    .IR_input	(send),
	 
	 .enable1		(GPIO[3]),
	 .pwm1			(GPIO[9]),
    .ina1			(GPIO[5]),
	 .inb1			(GPIO[7]),
	 .duty_cycle_1	(duty),
	 
	 .enable2		(GPIO[2]),
	 .pwm2			(GPIO[8]),
	 .ina2			(GPIO[4]),
	 .inb2			(GPIO[6]),  // Direction controls for two motors
	 .duty_cycle_2	(duty)
	 
);

//**********************************************************************

//**************************** IR stuff ********************************

logic [31:0] hex_data;
logic [7:0] send;
logic [11:0] prev_data;

logic clk50;

pll1 u0(								// not sure what exactly this module does might want to delete it
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



//***********************************************************************

//************************** UART stuff *********************************

logic [7:0] rx_byte;
logic [7:0] tx_byte;


uart_rx #(.CLKS_PER_BIT(50_000_000/9600)) uart_rx_u (
	.clk				(CLOCK_50), 
	.rx				(EX_IO[1]), 
	.valid			(rx_valid), 
	.ready			(rx_ready),
	.data_received	(rx_byte)
); // Receive on GPIO[7].


logic tx_valid;         // handshake
logic tx_ready;         // handshake

logic rx_valid;         // handshake
logic rx_ready = 1'b1;  // handshake. We are always ready to receive.

always_ff @(posedge CLOCK_50) begin
	tx_valid <= (tx_valid && !tx_ready);  // tx_valid stays high if uart_rx is not ready yet, else go low (can be overriden to high by case 0x82 below).
	if (rx_valid & rx_ready) begin        // Handshake: uart_rx has got data for us.
		tx_valid <= 1'b1;
	end
end

assign LEDR[16:9] = rx_byte;
assign LEDR[7:0] = tx_byte;



logic [3:0] prox_status;

always_comb begin
	prox_status = ( proximity_stat > 4'b1111) ? 4'b1111 : ( (proximity_stat < 3'b100) ? 4'b0000 : proximity_stat[5:2] ); 
end

assign tx_byte = {prox_status[3:0], motor_stat, 1'b1};


uart_tx #(.CLKS_PER_BIT(50_000_000/9600)) u3 (
	.clk 				(CLOCK_50),
	.tx				(EX_IO[2]),
	.valid			(tx_valid),
	.ready			(tx_ready),
	.data_to_send	(tx_byte)
);

//*************************************************************************

//************************ Proximity **************************************


proximity u100(
	.CLOCK_50		(CLOCK_50),
	.GPIO_35			(GPIO[35]),
	.GPIO_34			(GPIO[34]),
	.LEDR				(proximity_stat)
);


logic [7:0] proximity_stat;

//**************************************************************************


endmodule


