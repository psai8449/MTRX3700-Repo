
module top_level (
	input logic CLOCK_50,
	input logic IRDA_RXD,
	input KEY[0],
	
	inout [35:0] GPIO,
	
	output logic [7:0] LEDG,
	output logic [17:0] LEDR
);


	// MOTOR Control
	// logic [6:0] duty_cycle_left, duty_cycle_right;

	// assign duty_cycle_left = 7'd20;
	// assign duty_cycle_right = 7'd20;


	MotorControl  		DualMotor (

		.clk			(CLOCK_50),                // System Clock  
		.IR_input	(IR_8Bit),
		
		.enable1		(GPIO[3]),
		.pwm1			(GPIO[9]),
		.ina1			(GPIO[5]),
		.inb1			(GPIO[7]),
		// .duty_cycle_1	(duty_cycle_left),
		
		.enable2		(GPIO[2]),
		.pwm2			(GPIO[8]),
		.ina2			(GPIO[4]),
		.inb2			(GPIO[6])  // Direction controls for two motors
		// .duty_cycle_2	(duty_cycle_right)
		
	);



	// IR Sensor
	logic clk50;
	logic data_ready;
	logic [31:0] IR_input;
	logic [31:0] hex_data;
	logic [7:0] IR_8Bit;
	logic [11:0] prev_data;

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



	always_ff @( CLOCK_50 ) begin

		if ( hex_data != prev_data ) begin
			case(hex_data[27:16]) 
				12'b1101_0000_0010: begin		  // IR REMOTE NUMBER
					IR_8Bit[7:0] <= 8'b0000_0010; // 2
				end
				
				12'b1011_0000_0100: begin	
					IR_8Bit[7:0] <= 8'b0000_1000; //
				end
				
				12'b1010_0000_0101: begin		
					IR_8Bit[7:0] <= 8'b0001_0000;
				end
				
				12'b1001_0000_0110: begin		
					IR_8Bit[7:0] <= 8'b0010_0000;
				end
				
				12'b0111_0000_1000: begin		
					IR_8Bit[7:0] <= 8'b1000_0000;
				end

				12'b0101_0001_1010: begin		
					IR_8Bit[7:0] <= 8'b0000_0001; // Channel Up
				end

				12'b0001_0001_1110: begin		
					IR_8Bit[7:0] <= 8'b0100_0000; // Channel Down
				end
				


				default: begin
					IR_8Bit[7:0] <= 8'b0000_0000;
				end
					
			endcase
			
			prev_data <= hex_data;
			
		end
		
		
	end

	assign LEDG = IR_8Bit;
	// assign LEDR[11:0] = hex_data[27:16];


endmodule
