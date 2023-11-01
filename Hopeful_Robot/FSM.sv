//main fsm

module FSM (

	input logic CLK,
	input logic [3:0] PROX_STAT,
	input logic [31:0] HEX_DATA,
	input logic [7:0] RX_BYTE,
	
	output logic [6:0] DUTY,
	output logic [7:0] SEND,
	output logic [2:0] MOTOR_STAT
	
);

logic [7:0] prev_data;

always_comb begin
	
	DUTY = (PROX_STAT > 4'b1111) ? 6'b11_1100 : 6'b10_1000;		// if distance is greater than 4'b1111 duty cycle = 60%
																					// if distance is greater than 4'b1111 duty cycle = 20%
end



always_ff @( CLK ) begin
	
	if ( {HEX_DATA[27:24], HEX_DATA[19:16]} != prev_data ) begin
	
		case( {HEX_DATA[27:24], HEX_DATA[19:16]} ) 
			8'b1101_0010: begin		// 2	Forwards
				SEND[7:0] <= 8'b0000_0010;
			end
			
			8'b1011_0100: begin		// 4	Left
				SEND[7:0] <= 8'b0000_1000;
			end
			
			8'b1010_0101: begin		// 5	Brake??
				SEND[7:0] <= 8'b0001_0000;
			end
			
			12'b1001_0110: begin		// 6	Right
				SEND[7:0] <= 8'b0010_0000;
			end
			
			12'b0111_1000: begin		// 8	Balckwards
				SEND[7:0] <= 8'b1000_0000; // needs change
			end
			
			default: begin
				SEND[7:0] <= 8'b0000_0000;
			end
				
		endcase
		
		prev_data <= HEX_DATA;
		
	end
	
	else if ( RX_BYTE != prev_data ) begin
		
		case( RX_BYTE ) 
		
			8'b0110_0001: begin		// 2	Forwards
				SEND[7:0] <= 8'b0000_0010;
			end
			
			8'b0110_0010: begin		// 4	Left
				SEND[7:0] <= 8'b0000_1000;
			end
			
			8'b0110_0011: begin		// 5	Brake??
				SEND[7:0] <= 8'b0001_0000;
			end
			
			8'b0110_0100: begin		// 6	Right
				SEND[7:0] <= 8'b0010_0000;
			end
			
			8'b0110_0101: begin		// 8	Backwards
				SEND[7:0] <= 8'b1000_0000;
			end
			
			default: begin
				SEND[7:0] <= 8'b0000_0000;
			end
				
		endcase
		
		prev_data <= RX_BYTE;

	end
	
	
end


always @( * ) begin
  case (SEND)
    8'b0000_0000: MOTOR_STAT = 3'b000;		// default
    8'b0000_0010: MOTOR_STAT = 3'b001;		// forwards	
    8'b0000_1000: MOTOR_STAT = 3'b010;		// left
    8'b0001_0000: MOTOR_STAT = 3'b011;		// brake
    8'b0010_0000: MOTOR_STAT = 3'b100;		// right
    8'b1000_0000: MOTOR_STAT = 3'b101;		// backwards
    default: MOTOR_STAT = 3'b111; // Default case, you can choose any value
  endcase
end


endmodule


