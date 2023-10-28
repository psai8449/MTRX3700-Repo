module top_level(
  input CLOCK_50,
  inout [35:0] GPIO,
  input [3:0] KEY,
  output [7:0] LEDR
);

  logic start, reset, measurement_trigger;
  logic echo, trigger;

  assign echo = GPIO[35];
  assign GPIO[34] = trigger;

  // Add a timer for measurements
  always @(posedge CLOCK_50) begin
    if (measurement_trigger)
      start <= 1'b1;
    else
      start <= 1'b0;
  end

  debounce reset_edge(
    .clk(CLOCK_50),
    .button(!KEY[2]),  // Changed to KEY[2] for reset
    .button_edge(reset)
  );

  sensor_driver u0(
    .clk(CLOCK_50),
    .rst(reset),
    .measure(start), // Measure on trigger
    .echo(echo),
    .trig(trigger), 
    .distance(LEDR)
  );

  // Add a 0.5-second timer
  reg [31:0] counter = 0;
  parameter COUNT_MAX = 25_000_000; // Adjust for your CLOCK_50 frequency

  always @(posedge CLOCK_50) begin
    if (reset) begin
      measurement_trigger <= 1'b0; // Reset the measurement trigger
      counter <= 0;
    end else if (measurement_trigger) begin
      measurement_trigger <= 1'b0; // Reset the trigger after measurement
      counter <= 0;
    end else begin
      if (counter == COUNT_MAX) begin
        counter <= 0;
        measurement_trigger <= 1'b1; // Trigger measurement every 0.5 seconds
      end else begin
        counter <= counter + 1;
      end
    end
  end

endmodule
