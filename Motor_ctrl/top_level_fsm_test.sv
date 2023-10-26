module top_level_fsm_test (
    input logic CLOCK_50,
    output logic [9:2] GPIO
);

    assign pwm1 = 1'b1;
	assign pwm2 = 1'b1;

    assign GPIO[2] = 1;
    assign GPIO[3] = 1;
    assign GPIO[8] = pwm1;
    assign GPIO[9] = pwm2;

    fsm_test motorDriver(
            .clk(CLOCK_50),  
            .ina1(GPIO[4]), 
            .inb1(GPIO[6]),
            .ina2(GPIO[5]),
            .inb2(GPIO[7])
        );

endmodule
