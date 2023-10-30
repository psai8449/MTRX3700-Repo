module MotorControl (
    input logic clk,                // System Clock  
    input [7:0] IR_input,
	// input [6:0] duty_cycle_1,
	// input [6:0] duty_cycle_2,
	 
    output logic pwm1,
	output logic pwm2,
	output logic enable1, enable2,
    output logic ina1, inb1, ina2, inb2  // Direction controls for two motors
);

    logic [6:0] duty_cycle_1;
    logic [6:0] duty_cycle_2;

	pwm PWM1 (	
		.clk_50			(clk), // 50MHz clock
		.DUTY_CYCLE		(duty_cycle_1),					//	<-- duty_cycle_1
		.pwm_out			(pwm1) // pwm output	
	);
	pwm PWM2 (
		.clk_50			(clk), // 50MHz clock
		.DUTY_CYCLE		(duty_cycle_2),					//	<-- duty_cycle_2
		.pwm_out			(pwm2) // pwm output	
	);

    typedef enum {idle, forwards, backwards, left, right, up_speed, down_speed} state;
    state current_state, next_state;

    initial begin
        current_state = idle;
        duty_cycle_1 = 7'd20;
        duty_cycle_2 = 7'd20;
    end

    always_ff @(posedge clk) begin
        current_state <= next_state;
        if (current_state == up_speed) begin
                duty_cycle_1 <= duty_cycle_1 + 5;
                duty_cycle_2 <= duty_cycle_2 + 5;
        end
        if (current_state == down_speed) begin
                duty_cycle_1 <= duty_cycle_1 - 5;
                duty_cycle_2 <= duty_cycle_2 - 5;
        end
    end

    always_comb begin : next_state_logic
        case(current_state)
            idle: begin
                if (IR_input[7:0] == 8'b00000010) begin
                    next_state = forwards;
                end
                else if (IR_input[7:0] == 8'b10000000) begin
                    next_state = backwards;
                end
                else if (IR_input[7:0] == 8'b00001000) begin
                    next_state = left;
                end
                else if (IR_input[7:0] == 8'b00100000) begin
                    next_state = right;
                end
                else if (IR_input[7:0] == 8'b00000001) begin
                    next_state = up_speed;
                end
                else if (IR_input[7:0] == 8'b01000000) begin
                    next_state = down_speed;
                end
                else begin
                    next_state = idle;
                end
            end
            forwards: begin
                if (IR_input[7:0] == 8'b00010000) begin
                    next_state = idle;
                end
                else if (IR_input[7:0] == 8'b10000000) begin
                    next_state = backwards;
                end
                else if (IR_input[7:0] == 8'b00001000) begin
                    next_state = left;
                end
                else if (IR_input[7:0] == 8'b00100000) begin
                    next_state = right;
                end
                else if (IR_input[7:0] == 8'b00000001) begin
                    next_state = up_speed;
                end
                else if (IR_input[7:0] == 8'b01000000) begin
                    next_state = down_speed;
                end
                else begin
                    next_state = forwards;
                end
            end
            backwards: begin
                if (IR_input[7:0] == 8'b00010000) begin
                    next_state = idle;
                end
                else if (IR_input[7:0] == 8'b00000010) begin
                    next_state = forwards;
                end
                else if (IR_input[7:0] == 8'b00001000) begin
                    next_state = left;
                end
                else if (IR_input[7:0] == 8'b00100000) begin
                    next_state = right;
                end
                else if (IR_input[7:0] == 8'b00000001) begin
                    next_state = up_speed;
                end
                else if (IR_input[7:0] == 8'b01000000) begin
                    next_state = down_speed;
                end
                else begin
                    next_state = backwards;
                end
            end
            left: begin
                if (IR_input[7:0] == 8'b00010000) begin
                    next_state = idle;
                end
                else if (IR_input[7:0] == 8'b00000010) begin
                    next_state = forwards;
                end
                else if (IR_input[7:0] == 8'b10000000) begin
                    next_state = backwards;
                end
                else if (IR_input[7:0] == 8'b00100000) begin
                    next_state = right;
                end
                else if (IR_input[7:0] == 8'b00000001) begin
                    next_state = up_speed;
                end
                else if (IR_input[7:0] == 8'b01000000) begin
                    next_state = down_speed;
                end
                else begin
                    next_state = left;
                end
            end
            right: begin
                if (IR_input[7:0] == 8'b00010000) begin
                    next_state = idle;
                end
                else if (IR_input[7:0] == 8'b00000010) begin
                    next_state = forwards;
                end
                else if (IR_input[7:0] == 8'b10000000) begin
                    next_state = backwards;
                end
                else if (IR_input[7:0] == 8'b00001000) begin
                    next_state = left;
                end
                else if (IR_input[7:0] == 8'b00000001) begin
                    next_state = up_speed;
                end
                else if (IR_input[7:0] == 8'b01000000) begin
                    next_state = down_speed;
                end
                else begin
                    next_state = right;
                end
            end
            up_speed: begin
                next_state = idle;
            end
            down_speed: begin
                next_state = idle;
            end

        endcase
    end

    always_comb begin : fsm_output
        case(current_state)
            idle: begin
                ina1 = 1'b0;
                inb1 = 1'b0;
                ina2 = 1'b0;
                inb2 = 1'b0; 
            end
            forwards: begin
                ina1 = 1'b0;
                inb1 = 1'b1;
                ina2 = 1'b0;
                inb2 = 1'b1;
            end
            backwards: begin
                ina1 = 1'b1;
                inb1 = 1'b0;
                ina2 = 1'b1;
                inb2 = 1'b0; 
            end
            left: begin
                ina1 = 1'b1;
                inb1 = 1'b0;
                ina2 = 1'b0;
                inb2 = 1'b1;
            end
            right: begin
                ina1 = 1'b0;
                inb1 = 1'b1;
                ina2 = 1'b1;
                inb2 = 1'b0;
            end
            default: begin
                ina1 = 1'b0;
                inb1 = 1'b0;
                ina2 = 1'b0;
                inb2 = 1'b0; 
            end
        endcase
    end

    assign enable1 = 1'b1;
	assign enable2 = 1'b1;

endmodule
