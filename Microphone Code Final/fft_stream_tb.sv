module fft_stream_tb;

    localparam N=1024;

    localparam TCLK = 20; // 20 ns
    localparam TCLK_SLOW = 54; // ~18.5 MHz
    localparam W = 32;

    logic clk = 0;    //  Master Clock
	 logic clk_slow = 0;
    logic reset = 1;  //  Active High Asynchronous Reset
    
    dstream #(.N(W)) x ();
    dstream #(.N(W*2+1)) y ();

    fft_stream #(.W(W)) DUT (.*, .clk(clk_slow));

    logic [W-1:0] input_signal [0:N-1];
    initial $readmemh("signal.txt", input_signal);

    always #(TCLK/2) clk = ~clk;
	 always #(TCLK_SLOW/2) clk_slow = ~clk_slow;

    logic start = 1'b0; // Use a start flag.
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars();
        reset = 1'b1;
        #(TCLK_SLOW*5);
        reset = 1'b0;
        #(TCLK_SLOW*5);
        start = 1'b1;
        repeat (3) @(negedge y.valid);
        #(TCLK_SLOW*100);
        $finish();
    end

    // Input Driver
    integer i = 0, next_i;
    assign next_i = i < N-1 ? i + 1 : 0;
    always_ff @(posedge clk_slow) begin
        x.valid <= 1'b0;
        x.data <= input_signal[i];
        if (start) begin
            x.valid <= 1'b1;
            if (x.valid && x.ready) begin
                x.data <= input_signal[next_i];
                i <= next_i;
            end
        end
    end

	 
	 logic [15:0] LEDR;
	 
	 led_fft_view fft_view_u (.fast_clk(clk), // 50 MHz
									  .slow_clk(clk_slow), // 18.432 MHz
									  .fft_out(y),
									  .LEDR(LEDR)
    );


endmodule

