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

  debounce reset_edge(
    .clk(CLOCK_50),
    .button(!KEY[2]),
    .button_edge(reset)
  );

  sensor_driver u0(
    .clk(CLOCK_50),
    .rst(reset),
    .measure(start),
    .echo(echo),
    .trig(trigger), 
    .distance(LEDR)
  );
  
  // Add a timer for measurements
  always @(posedge CLOCK_50) begin
    if (measurement_trigger)
      start <= 1'b1;
    else
      start <= 1'b0;
  end

  reg [31:0] counter = 0;
  parameter COUNT_MAX = 25_000_000; // currently set to pulse every 0.5 seconds

  always @(posedge CLOCK_50) begin
    if (reset) begin
      measurement_trigger <= 1'b0; // Reset the trigger
      counter <= 0;
    end else if (measurement_trigger) begin
      measurement_trigger <= 1'b0; // Reset the trigger
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
