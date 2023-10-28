module top_level_test (
    input logic CLOCK_50,
    output logic [9:2] GPIO
);

    fsm_test motorDriver(
            .clk(CLOCK_50), 
            .en1(GPIO[2]),
            .en2(GPIO[3]),
            .pwm1(GPIO[8]),
            .pwm2(GPIO[9]), 
            .ina1(GPIO[4]), 
            .inb1(GPIO[6]),
            .ina2(GPIO[5]),
            .inb2(GPIO[7])
    );

endmodule
