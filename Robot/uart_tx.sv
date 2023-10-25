// Example of a UART TX module. Use this as inspiration for your RX module!
module  uart_tx  #(parameter CLKS_PER_BIT) (
	input  clk, 
	input  rst, 
	output  logic  tx, // the TX pin
	input  [7:0]  data_to_send,   
	input  valid,         // handshake
	output  logic  ready  // handshake
); 

	localparam NCLK = CLKS_PER_BIT;
	
	logic  [7:0]  data_to_send_temp; 
	integer count;
	logic  [2:0]  bit_index; 
	
	enum logic [1:0] {IDLE,  START,  DATA,  STOP}  state,  next_state;
	
	always_comb  begin  :  fsm_next_state 
		case  (state) 
			IDLE:     next_state  =  valid & ready  ?  START  :  IDLE; // Handshake
			START:    next_state  =  count == CLKS_PER_BIT-1 ? DATA : START; 
			DATA:     next_state  =  count == CLKS_PER_BIT-1 ? (bit_index  ==  7  ?  STOP  :  DATA) : DATA; 
			STOP:     next_state  =  count == CLKS_PER_BIT-1 ? IDLE : STOP; 
			default:  next_state  =  IDLE; 
		endcase 
	end 
	always_ff  @(  posedge  clk  )  begin  :  fsm_ff 
		if  (rst)  begin 
			state  <=  IDLE; 
			data_to_send_temp  <=  0; 
			bit_index  <=  0; 
			count <= 0;
		end 
		else  begin 
			state  <=  next_state;
			count  <=  count == CLKS_PER_BIT-1 ? 0 : count + 1; 
			case  (state) 
				IDLE:  begin  //  idle 
					data_to_send_temp  <=  data_to_send; 
					bit_index  <=  0; 
			      count <= 0;
				end 
				DATA:  begin  //  data  transfer 
					bit_index  <=  count == CLKS_PER_BIT-1 ? bit_index  +  1 : bit_index; 
				end 
			endcase 
		end 
	end 
	always_comb  begin  :  fsm_output 
		tx  =  1'b1; 
		ready  =  1'b0; 
		case  (state) 
			IDLE:      begin 
				ready  =  1'b1; // Ready for data
			end 
			DATA:        begin 
				tx  =  data_to_send_temp[bit_index]; 
			end 
			START:      begin 
				tx  =  1'b0; 
			end 
			STOP:        begin 
				tx  =  1'b1; 
			end 
		endcase 
	end
endmodule 


