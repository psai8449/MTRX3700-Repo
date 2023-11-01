`timescale 1ns/1ns

module tb_proximity;
  input CLOCK_50;
  output [7:0] LEDG;

top_level DUT (
  .CLOCK_50 (CLOCK_50),
  .LEDG (LEDG)
);

  initial forever #10 CLOCK_50 = ~CLOCK_50;

  initial begin

    $dumpfile("waveform.vcd");
    $dumpvars();
    
    $display("Initialise\n");

    CLOCK_50 = 0;
    GPIO[34] = 0;
    
    #(10);  // wait 1 clock cycle
    $display("pwm: %b", LEDG);

    GPIO[34] = 1;
    $display("pwm: %b", LEDG);

    #(20);  // wait 1 clock cycle

    GPIO[34] = 0;
    GPIO[35] = 1;
    $display("pwm: %b", LEDG);

  end

endmodule