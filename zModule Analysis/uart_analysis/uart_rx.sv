module uart_rx #(parameter CLKS_PER_BIT)
(
	input  clk, 
	input  rst, 
	input  rx,          // The RX pin
	output logic [7:0]  data_received, 
	output valid,       // handshake
	input  ready        // handshake
);
   
  // Synchoronizer:
  logic rx_q0, rx_q1; // Important: only use rx_q1 in your code as this is the synchronizer output!
  always @(posedge clk)
    begin
      rx_q0   <= rx;      // 2 flip-flops in series.
      rx_q1   <= rx_q0;
    end
   
	localparam NCLK = CLKS_PER_BIT;

	integer count;
	logic  [2:0]  bit_index;
	enum logic [2:0] {IDLE,  START_BIT, WAIT, DATA_BITS,  STOP_BIT, CLEANUP}  state,  next_state;
	always_comb  begin  :  fsm_next_state 
		case  (state) 
			IDLE:       next_state  =  rx_q0 == 0            ?  START_BIT : IDLE; 
			START_BIT:  next_state  =  count == NCLK/2-1  ?  WAIT      : START_BIT; 
			WAIT:       next_state  =  count == NCLK-2    ?  DATA_BITS : WAIT; 
			DATA_BITS:  next_state  =  bit_index == 7     ?  STOP_BIT  : WAIT; 
			STOP_BIT:   next_state  =  count == NCLK-1    ?  CLEANUP   : STOP_BIT; 
			CLEANUP:    next_state  =  valid & ready      ?  IDLE      : CLEANUP;    // Handshake 
			default:    next_state  =  IDLE; 
		endcase 
	end 
	
	always_ff  @(  posedge  clk  )  begin  :  fsm_ff 
		if  (rst)  begin 
			state  <=  IDLE; 
			count  <=  0; 
		end 
		else  begin 
			state  <=  next_state;
			case  (state) 
				IDLE:  begin  //  idle 
					count  <=  0; 
					bit_index <= 0;
				end 
				START_BIT:  begin  //  idle 
					count  <=  count == NCLK/2-1 ? 0 : count + 1; 
				end 
				WAIT:  begin  //  idle 
					count  <=  count == NCLK-2 ? 0 : count + 1; 
				end 
				DATA_BITS:  begin  //  data  transfer 
					bit_index  <=  bit_index == 7 ? 0 : bit_index  +  1; 
					data_received[bit_index] <= rx_q0;
				end  
				STOP_BIT:  begin  //  idle 
					count  <=  count == NCLK-1 ? 0 : count + 1;
				end 
			endcase 
		end 
	end 
	
	assign valid  =  state == CLEANUP; 
	
endmodule 


