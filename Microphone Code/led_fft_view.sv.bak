module led_fft_view (
    input fast_clk,  // 50 MHz - for quickly flickering the LEDs
    input slow_clk,  // 18.432 MHz - for receiving the FFT data and counting the frequency bins.
    dstream.in fft_out,  // The FFT output stream.
    output logic [3:0] frequency_output, // The 4 LEDs, brightness reflecting closeness to desired frequency.
    output logic [7:0] LEDG  // The LED to be controlled based on the dimness of the LEDs.
);

    localparam N = 1024;
    localparam W = 65; // 2*32+1
    localparam W_SUM = $clog2(N/(2*16)) + W;

    logic [W_SUM-1:0] led_bins [0:15];
    logic [W_SUM-1:0] led_value  [0:15];

    always_ff @(posedge slow_clk) begin : bin_counting
        if (fft_out.valid & fft_out.ready) begin
            if (~fft_out.index[9]) begin
                if (fft_out.index[4:0] == 0) led_bins[fft_out.index[8:5]] <= fft_out.data;
                else led_bins[fft_out.index[8:5]] <= led_bins[fft_out.index[8:5]] + fft_out.data;
            end
            if (fft_out.index == 512) begin
                for (integer k=0; k<16; k++) begin
                    led_value[k] <= led_bins[k];
                end
            end
        end
    end

    assign fft_out.ready = 1'b1;

    logic [12:0] led_dimming_count = 0;
    logic [W_SUM-1:0] on_threshold;

    always_ff @(posedge fast_clk) begin : led_value_logic
        if (led_dimming_count == 0) on_threshold <= {(32){1'b1}};
        else on_threshold <= on_threshold - 2**32/2**13;

        if (fft_out.index == 512) led_dimming_count <= 0;
        else led_dimming_count <= led_dimming_count + 1;

        if (led_value[15] > on_threshold) begin
            LEDR_temp <= 16'b1111111111111111;
        end
        else LEDR_temp <= 16'b0000000000000000;

    end

    logic [15:0] LEDR_temp;

    always_ff @(posedge slow_clk) begin : count_max
        if (LEDR_temp > 16'b0001111111111111) begin     
            frequency_output[3:0] <= 16'b1111;
				LEDG[7:0] <= 8'b11111111;
        end 
        

        else begin
            frequency_output[3:0] <= 16'b0000;
				LEDG[7:0] <= 8'b00001111;
        end
    end

endmodule

