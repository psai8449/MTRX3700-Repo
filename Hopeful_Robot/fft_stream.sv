module fft_stream #(parameter W) (
    input clk,
	input reset,
    dstream.in x,
    dstream.out y
);
    localparam N = 1024;

	 logic           di_en;  //  Input Data Enable
    logic   [W-1:0] di_re;  //  Input Data (Real)
    logic   [W-1:0] di_im;  //  Input Data (Imag)

    logic          do_en;  //  Output Data Enable
    logic  [W-1:0] do_re;  //  Output Data (Real)
    logic  [W-1:0] do_im;  //  Output Data (Imag)

    FFT #(.WIDTH(W)) fft_ip_u (.*, .clock(clk));


    /* FIFO */
    logic empty, full;
    logic handshake;
    assign handshake = x.ready & x.valid;
    assign di_im = 0; // no imaginary parts
    logic read_in;
    logic outbuf_flushed = 1'b1;
    integer n=0;
    assign read_in = (full && outbuf_flushed) || n > 0;
    fifo #(.W(W), .D(1024)) fifo_u (.clk(clk),.rst(reset),.we(handshake),.re(read_in),.data_in(x.data),.data_out(di_re),.empty(empty),.full(full));
    assign x.ready = ~full;
    always_ff @(posedge clk) begin : input_fifo_logic
        if (reset) begin
            n<= 0;
            di_en<=0;
        end else
        if (read_in) begin
            di_en <= 1;
            n <= (n==0) ? 1023 : n-1;
        end
        else begin
            di_en<=0;
        end
    end


    logic signed [W*2:0] magnitude;
    assign magnitude = signed'(do_re)*signed'(do_re) + signed'(do_im)*signed'(do_im);

    logic [W*2:0] output_buffer [0:N-1];
    integer i=0, k;
    assign k = {i[0],i[1],i[2],i[3],i[4],i[5],i[6],i[7],i[8],i[9]}; // bit-reversed index
    integer rd_addr_out = -1;
	 
	 logic initial_en = 1'b1;

    always_ff @(posedge clk) begin : output_buffer_logic
        if (reset) begin
            i <= 0;
            rd_addr_out <= -1;
            outbuf_flushed <= 1'b1;
            y.valid <= 1'b0;
            initial_en <= 1'b1;
        end
        else begin
            if (read_in) outbuf_flushed <= 1'b0;
            if (do_en) begin
                output_buffer[k] <= magnitude;
                i <= i + 1;
            end
            y.valid <= i == 1024;
            if (y.valid && y.ready || initial_en && i == 1024) begin
					 initial_en <= 1'b0;
                y.data <= output_buffer[rd_addr_out+1];
                rd_addr_out <= rd_addr_out + 1;
                if(rd_addr_out == 1022) begin
                    rd_addr_out <= -1;
                    i <= 0;
                end
                if (rd_addr_out == -1 && ~initial_en) outbuf_flushed <= 1'b1;
            end
        end
    end
    assign y.index = rd_addr_out;

endmodule
