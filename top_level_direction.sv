


module top_level_test (
    input logic CLOCK_50,
    output logic [9:2] GPIO
);

    assign GPIO[2] = 1;
    assign GPIO[3] = 1;
    // assign GPIO[8] = pwm1;
    // assign GPIO[9] = pwm2;

    integer clk_counter = 0;
    integer counter_threshold = 50'd500000;
    integer slow_clk = 0;


    always_ff @(posedge CLOCK_50) begin
        clk_counter <= clk_counter + 1;
        if (clk_counter == counter_threshold) begin
            slow_clk <= ~slow_clk;
            clk_counter <= 0;
        end
    end

    integer x = 0;
    assign GPIO[8] = x;
    assign GPIO[9] = x;

    logic [31:0] counter;
    logic [9:0] threshold = 9'd1000;
    logic [9:0] percent_duty = 9'd0100;  // 4'd1000 is 100%, 4'b0100

    always_ff @(posedge slow_clk) begin
        counter <= counter + 1;
        if (counter == threshold) begin
                x <= ~x;
                counter <= 0;
            end
        else if (counter == percent_duty) begin
                x <= ~x;
            end 
    end  

    DualMotorControlFinal motorDriver(
            .clk(CLOCK_50),
            .ina1(GPIO[4]), 
            .inb1(GPIO[6]),
            .ina2(GPIO[5]),
            .inb2(GPIO[7])
    );



endmodule




