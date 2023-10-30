interface dstream #(parameter N, K=10);  // Data stream interface. Parameter N is the bit width of the data.
	logic valid; // We use a handshake protocol just like in AXI-Stream
	logic ready;
	logic [N-1:0] data;
	logic [K-1:0] index;
	
	modport in( // Module that takes the data as input.
		input  valid,
		output ready,
		input  data,
		input  index
	);
	modport out( // Module that outputs the data.
		output valid,
		input  ready,
		output data,
		output index
	);
endinterface

interface dstream_i2c #(parameter N);  // Data stream interface. Parameter N is the bit width of the data.
	logic start;
	logic done;
	logic [N-1:0] data;
	logic error; // Keep track of errors - in I2C, this is when a NACK is received after the data bits - i.e. the lack of an *active-low* ACK from the receiver.
	
	modport in(
		input  start,
		output done,
		input  data,
		output error
	);
	modport out(
		output start,
		input  done,
		output data,
		input  error
	);
endinterface
