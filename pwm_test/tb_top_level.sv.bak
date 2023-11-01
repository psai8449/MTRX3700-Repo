`timescale 1ns/1ns

module tb_proximity;
  input CLOCK_50;
  inout [35:34] GPIO;
  output [7:0] LEDR;

proximity DUT (
  .CLOCK_50 (CLOCK_50),
  .GPIO (GPIO),
  .LEDR (LEDR)
);

  initial forever #10 CLOCK_50 = ~CLOCK_50;

  initial begin

    $dumpfile("waveform.vcd");
    $dumpvars();
    
    $display("Initialise\n");

    CLOCK_50 = 0;
    GPIO[34] = 0;
    
    #(10);  // wait 1 clock cycle
    $display("distance: %b", LEDR);

    GPIO[34] = 1;
    $display("distance: %b", LEDR);

    #(20);  // wait 1 clock cycle

    GPIO[34] = 0;
    GPIO[35] = 1;
    $display("distance: %b", LEDR);

  end

endmodule