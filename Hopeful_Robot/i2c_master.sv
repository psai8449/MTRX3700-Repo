`timescale 1ps/1ps
module i2c_master (
	input  clk,       // 20 kHz input clock
	output I2C_SCLK,  // I2C clk
 	inout  I2C_SDAT,  // I2C DATA
	dstream_i2c.in i2c_tx // data interface. The actual data is arranged like so: {SLAVE_ADDR,SUB_ADDR,DATA}
);

  logic SDO=1;  // 1 means send a 1 onto the I2C data line. 0 means send a 0.
	logic SCLK_idle=1; // This sets the I2C clock to the idle high state.
	
	enum logic [3:0] {INIT, START0, SLAVE_ADDR, ACK1, SUB_ADDR0, SUB_ADDR1, ACK2, DATA0, DATA1, ACK3, STOP0, STOP1, STOP2, STOP3} state = INIT, next_state;
		
	assign I2C_SCLK = SCLK_idle | ~clk; // The SCLK is 1 if idle, else it is the clock inverted (this is so that the positive edge of SCLK is in the middle of a data bit).
	
	assign I2C_SDAT = SDO ? 1'bz : 0 ; // I2C: set the data line to the high-impedance Z state when sending a `1`, else set to `0`.

	logic ack_1=0,ack_2=0,ack_3=0;               // Acknowledgement status bits for each separate acknowledgement - after slave address, after register address and after data.
	assign i2c_tx.error = ack_1 | ack_2 | ack_3; // If any of the acknowledgements from the receiver are high, then an error has occured (acknowledge is active-low).
	
	logic [2:0] counter=0; // Use this to count bits.
	
	always_comb begin : next_state_logic
		next_state = INIT;
		case(state)
			INIT:       next_state = i2c_tx.start ? START0 : INIT;     // Move to the START0 state once a 'start' signal has been received.
			START0:     next_state = SLAVE_ADDR;
			SLAVE_ADDR: next_state = counter == 7 ? ACK1 : SLAVE_ADDR; // Send slave address to the device
			ACK1:       next_state = SUB_ADDR0;
			SUB_ADDR0:  next_state = SUB_ADDR1;                        // Here, we use 2 SUB_ADDR states to include an ACK check on the first state (for the previous ACK1 state).
			SUB_ADDR1:  next_state = counter == 7 ? ACK2 : SUB_ADDR1;  // Send the register address to the device
			ACK2:       next_state = DATA0;
			DATA0:      next_state = DATA1;                            // Here, we use 2 DATA states to include an ACK check on the first state (for the previous ACK2 state).
			DATA1:      next_state = counter == 7 ? ACK3 : DATA1;      // Send the data to the device
			ACK3:       next_state = STOP0;
			STOP0:      next_state = STOP1;	                           // Here, we use 4 STOP states to include an ACK check on the first state (for the previous ACK3 state), and also to deal with the SCLK and SDAT stop timings. 
			STOP1:      next_state = STOP2;	
			STOP2:      next_state = STOP3;	
			STOP3:      next_state = INIT;	
		endcase
	end
	
	logic [7:0] slav_addr, sub_addr, data;                         // Temporary variables to split i2c_tx.data into its three respective fields (easier to read).
	assign {slav_addr, sub_addr, data} = i2c_tx.data; // fancy concat operator usage.
	
	always_ff @(posedge clk) begin : bit_counter
		if (state == SLAVE_ADDR || state == SUB_ADDR0 || state == SUB_ADDR1 || state == DATA0 || state == DATA1) begin
			counter <= counter + 1; // Only count bits in these states (i.e. when we are actually sending information)
		end
		else counter <= 0;
	end

	always_ff @(posedge clk) begin
		state <= next_state;
		case (state)
			INIT        : begin ack_1<=0 ; ack_2<=0 ; ack_3<=0 ; i2c_tx.done<=0; SDO<=1; SCLK_idle<=1; end // Reset registers.
			//start
			START0      : begin SDO<=0; end
			//SLAVE ADDR: The address of the slave we wish to write to.
			SLAVE_ADDR  : begin SDO<=slav_addr[7-counter]; SCLK_idle<=0;	end
			ACK1        : SDO<=1'b1;//Puts I2C_SDAT into high-impedance state in order to detect an ACK being sent from the receiver.
			//SUB ADDR: The address of the register we wish to write to. 
			SUB_ADDR0  : begin SDO<=sub_addr[7-counter]; ack_1<=I2C_SDAT; end
			SUB_ADDR1  : SDO<=sub_addr[7-counter];
			ACK2       : SDO<=1'b1;//Puts I2C_SDAT into high-impedance state in order to detect an ACK being sent from the receiver.
			//DATA: The data we wish to write.
			DATA0  : begin SDO<=data[7-counter]; ack_2<=I2C_SDAT; end
			DATA1  : SDO<=data[7-counter];
			ACK3   : SDO<=1'b1;//Puts I2C_SDAT into high-impedance state in order to detect an ACK being sent from the receiver.
			//stop
			STOP0 : begin SDO<=1'b0;	SCLK_idle<=1'b0; ack_3<=I2C_SDAT; end	
			STOP1 : SCLK_idle<=1'b1; 
			STOP2 : begin SDO<=1'b1; i2c_tx.done<=1; end  // Assert a done pulse once the I2C module has finished sending the data.
		endcase
	end

endmodule
