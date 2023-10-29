`timescale 1ps/1ps
module audio_codec_data #(parameter N) (
    input rst,
    input adclrc,
	input bclk, // Assume a 18.432 MHz clock
	input adcdat,
   dstream.out audio_data_out
);
    // Assume that i2c has already configured the CODEC.

    logic redge_adclrc, adclrc_q; // Rising edge detect on ADCLRC to sense left channel
    always_ff @(posedge  bclk) begin : adclrc_rising_edge_ff
        adclrc_q <= adclrc;
    end
    assign redge_adclrc = ~adclrc_q & adclrc; // rising edge detected!


    integer bit_index;
    always_ff @(posedge bclk) begin : bit_index_logic
        if (rst) begin
            bit_index <= 0;
        end
        else begin
            if (redge_adclrc) begin
                bit_index <= 1; // reset as ADCLRC has just risen
            end
            else if (bit_index == 0) begin
                bit_index <= 0;
            end
            else if (bit_index < N+1) begin  // Extra index N used for FIFO write enable.
                bit_index <= bit_index + 1;
            end
        end
    end

    logic [N-1:0] temp_rx_data;
    always_ff @(posedge bclk) begin : rx_logic
        if (redge_adclrc) begin
            temp_rx_data[N-1] <= adcdat;
        end
        else if (bit_index < N) begin
            temp_rx_data[N-1-bit_index] <= adcdat;
        end
    end

	assign audio_data_out.data = temp_rx_data;
	assign audio_data_out.valid = bit_index == N;
	// Note: no handshake mechanism!!!
	
endmodule

