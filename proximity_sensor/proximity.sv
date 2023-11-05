module proximity(
  input CLOCK_50,
  inout [35:0] GPIO,
  output [7:0] LEDR
);

  logic start, reset, measurement_trigger;
  logic echo, trigger;

  assign echo = GPIO[35];
  assign GPIO[34] = trigger;

  always @(posedge CLOCK_50) begin
    if (measurement_trigger)
      start <= 1'b1;
    else
      start <= 1'b0;
  end

  sensor_driver u0(
    .clk(CLOCK_50),
    .rst(reset),
    .measure(start),
    .echo(echo),
    .trig(trigger), 
    .distance(LEDR)
  );

  reg [31:0] counter = 0;
  parameter COUNT_MAX = 25_000_000; // 0.5 seconds for 50 MHz clock

  // Trigger proximity sensor every 0.5 seconds

  always @(posedge CLOCK_50) begin
    if (reset) begin // Default parameters
      measurement_trigger <= 1'b0;
      counter <= 0;
    end 
    else if (measurement_trigger) begin // Reset trigger in next cycle
      measurement_trigger <= 1'b0;
      counter <= 0;
    end 
    else begin  // Logic to count upto 0.5 seconds
      if (counter == COUNT_MAX) begin
        counter <= 0;
        measurement_trigger <= 1'b1;
      end 
      else begin
        counter <= counter + 1;
      end
    end
  end
  
endmodule