module top_level (
	input CLOCK_50,
	output	I2C_SCLK,
	inout		I2C_SDAT,
	input		AUD_ADCDAT,
	input   AUD_BCLK,
	output   AUD_XCK,
	input    AUD_ADCLRCK,
	output  logic [17:0] LEDR
);

	logic adc_clk; adc_pll adc_pll_u (.areset(1'b0),.inclk0(CLOCK_50),.c0(adc_clk)); // generate 18.432 MHz clock
	
	set_audio_encoder set_codec_u (.CLOCK_50(CLOCK_50), .I2C_SCLK(I2C_SCLK), .I2C_SDAT(I2C_SDAT));
		
	logic rst;
	integer reset_timer = 0;
	always_ff @(posedge adc_clk) begin
		reset_timer <= reset_timer < 1_843_000 ? reset_timer + 1 : reset_timer;
	end
	assign rst = reset_timer < 1_843_000; // Wait 0.1 second for i2c config to finish.
	
	// Interfaces:
	dstream #(.N(16)) audio_data_out ();
	dstream #(.N(32)) fft_in ();
	dstream #(.N(32*2+1)) fft_out ();
	
	
	audio_codec_data #(.N(16)) u_audio_codec_data (
    .rst(rst),
    .adclrc(AUD_ADCLRCK),
	 .bclk(AUD_BCLK),
	 .adcdat(AUD_ADCDAT),
    .audio_data_out(audio_data_out) // Note: no handshake mechanism!!!
   );

	/* Downsampling/decimation. Used to fit ~0.5 seconds into the 1024-point FFT and also provides higher frequency resolution within the human voice speaking range.
	 * It is recommended that you turn this into a separate module and test it: */
	assign audio_data_out.ready = fft_in.ready; // Note: audio samples are dropped when fft_in isn't ready (no handshake mechanism in audio_codec_data module).
	logic [5:0] decimation_index = 0; // Used to skip every 64 samples (2^6=64) (downsampling/decimation)
	always_ff @(posedge adc_clk) begin
		if (audio_data_out.valid && audio_data_out.ready) begin
			decimation_index <= decimation_index + 1;
		end
	end	
	assign fft_in.valid = decimation_index == 63 && audio_data_out.valid; // Only input every 64th sample to the FFT (downsampling/decimation)
	assign fft_in.data = {{8{audio_data_out.data[15]}}, audio_data_out.data, {8{1'b0}}}; // Extend audio data to 32-bits. Use sign-extension for the 8 MSB (2's complement).
	

	   /* Use this instead of audio_codec_data to test the FFT with a predefined signal input stored in ROM: */
//    logic [32-1:0] input_signal [0:1024-1];
//    initial $readmemh("simulation/modelsim/signal.txt", input_signal);
//    // Input Driver
//    integer i = 0, next_i;
//    assign next_i = i < 1024-1 ? i + 1 : 0;
//    always_ff @(posedge adc_clk) begin
//        audio_data_out.valid <= 1'b0;
//        audio_data_out.data <= input_signal[i];
//        if (~rst) begin
//            audio_data_out.valid <= 1'b1;
//            if (audio_data_out.valid && audio_data_out.ready) begin
//                audio_data_out.data <= input_signal[next_i];
//                i <= next_i;
//            end
//        end
//    end
	
	assign AUD_XCK = adc_clk;
	
	fft_stream #(.W(32)) fft_stream_u (
    .clk(adc_clk),
	 .reset(rst),
    .x(fft_in),
    .y(fft_out)
	);
	
	 // View the FFT on the LEDs:
	 led_fft_view fft_view_u (.fast_clk(CLOCK_50), // 50 MHz
									  .slow_clk(adc_clk),  // 18.432 MHz
									  .fft_out(fft_out),
									  .frequency_output(LEDR[3:0])
    );

endmodule
