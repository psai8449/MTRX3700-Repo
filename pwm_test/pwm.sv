

module pwm (
    input logic clk, // 50MHz clock
    input logic rst, // reset signal
    output logic pwm_out // pwm output
);

    // parameters
    localparam CNT_MAX = 5000; // counter max value for 10KHz frequency
    localparam DUTY_CYCLE = 50; // duty cycle percentage

    // internal signals
    logic [12:0] cnt; // counter
    logic cmp; // compare flag

    always_ff @(posedge clk) begin

			if (cnt == CNT_MAX - 1) begin
				 cnt <= 0;
				 cmp <= ~cmp;
			end 
			else begin
				 cnt <= cnt + 1;
			end

    end

    assign pwm_out = (cmp) ? (cnt < (DUTY_CYCLE * CNT_MAX / 100)) : (cnt > ((100 - DUTY_CYCLE) * CNT_MAX / 100));
	 
	 
endmodule
 
