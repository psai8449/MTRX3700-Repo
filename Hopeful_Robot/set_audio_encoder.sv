module set_audio_encoder (
	input 	CLOCK_50,  // 50Mhz clock
	//input    i2c_clk, // Assuming a 20 kHz clock is input (for testbench)
	output	I2C_SCLK,
	inout		I2C_SDAT
);
	// Use the below when running on the DE2-115 with the 50 MHz CLOCK_50. Make sure to create the PLL correctly!
	logic i2c_clk; i2c_pll pll_u (.areset(1'b0),.inclk0(CLOCK_50),.c0(i2c_clk)); // generate 20 kHz i2c clock
		
	// Instantiate interface:	
	dstream_i2c #(.N(24)) i2c_tx ();
	initial i2c_tx.start = 1'b0;

	// Instantiate I2C master module (see code for an explanation)
	i2c_master 	u0	(.clk(i2c_clk), .*);

	// Now, let's use a FSM to control the I2C master module.
	// We will feed the I2C module a set of instructions that determine the registers to set and values to set them to (see always_comb block at the bottom).
	enum logic [1:0] {LOAD, WAIT, NEXT} state = LOAD, next_state; 

	always_comb begin : fsm_next_state
		next_state = LOAD;
		case (state)
			LOAD: next_state = WAIT;
			WAIT: next_state = i2c_tx.done ? (i2c_tx.error === 1 ? LOAD : NEXT) : WAIT;  // Wait until the I2C module is finished sending bits. If it finished but there was an error, try again by restarting from the LOAD state.
			NEXT: next_state = LOAD; 
		endcase
	end
														
	logic [3:0] initialise_index = 0;
	logic [15:0]	reg_and_data=0;
							
	always_ff @(posedge i2c_clk) begin : fsm_ff
		state <= next_state;
		if(initialise_index < 11) begin  // Stop sending to the audio encoder chip after we step through all initialisation commands.
			case(state)
			LOAD:	begin
					i2c_tx.data	<=	{7'h1A,1'b0,reg_and_data};     // 0x1A is the 7-bit address of the Audio Encoder chip. The 1-bit is R/W=0 for writing. Now, reg_and_data is 7bits reg address and 9bits data to write into that register.
					i2c_tx.start <= 1'b1;                     // Pulse start to get the I2C module to start sending.
				end
			WAIT: i2c_tx.start <= 1'b0;                   // Pulse start to get the I2C module to start sending.
			NEXT:	begin
					initialise_index	<=	initialise_index+1; // Increment the initialise index to read the next initialisation command from the sequence.
				end
			endcase
		end
	end


	always_comb begin : config_data_cmds
		case(initialise_index)
			//	Audio Config Data       // Format: {7 bits for reg, 9 bits for value}
			1:        reg_and_data	<=	{7'h00, 9'hFF}/* Set the SET_LIN_L	 register here! */;
			2:        reg_and_data	<=	{7'h01, 9'hFF}/* Set the SET_LIN_R	 register here! */;
			3:        reg_and_data	<=	{7'h02, 9'hFD}/* Set the SET_HEAD_L	 register here! */;
			4:        reg_and_data	<=	{7'h03, 9'hFD}/* Set the SET_HEAD_R	 register here! */;
			5:        reg_and_data	<=	{7'h04, 9'h3D}/* Set the A_PATH_CTRL register here! */;
			6:        reg_and_data	<=	{7'h05, 9'h00}/* Set the D_PATH_CTRL register here! */;
			7:        reg_and_data	<=	{7'h06, 9'h00}; // POWER_DOWN disable all power down options.	   
			8:        reg_and_data	<=	{7'h07, 9'h41}; // SET_FORMAT	 MSB-first, left-justified, 16 bit audio data length, MASTER mode, etc
			9:        reg_and_data	<=	{7'h08, 9'h02}; // SAMPLE_CTRL	set BOSR to 384fs
			10:	      reg_and_data	<=	{7'h09, 9'h01}; // SET_ACTIVE	register to Active
			default : reg_and_data	<=	16'd0 ;
		endcase
	end
endmodule

