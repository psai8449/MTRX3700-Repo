

module troubleshoot (
    input logic [6:0] data,
    output logic [6:0] segments
);

    always @(data) begin
        case (data)
            7'b0000001: segments = 7'b1000000;
            7'b0000010: segments = 7'b1111001;
            7'b0000100: segments = 7'b0100100;
            7'b0001000: segments = 7'b0110000;
            7'b0010000: segments = 7'b0011001;
            7'b0100000: segments = 7'b0010010;
            7'b1000000: segments = 7'b0000010;
            default: segments = 7'b1111111;     // off state
		endcase
	end

endmodule


