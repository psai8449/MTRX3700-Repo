module sensor_driver#(parameter ten_us = 10'd500)(
  input clk,
  input rst,
  input measure,
  input echo,
  output trig,
  output [7:0] distance
  );

localparam IDLE = 3'b000,
          TRIGGER = 3'b010,
          WAIT = 3'b011,
          COUNTECHO = 3'b100,
          DISPLAY_DISTANCE = 3'b101;

wire inIDLE, inTRIGGER, inWAIT, inCOUNTECHO, inDISPLAY;
reg [9:0] counter;
reg [21:0] distanceRAW = 0; // cycles in COUNTECHO
reg [31:0] distanceRAW_in_cm = 0;
wire trigcountDONE, counterDONE;

logic [2:0] state;
logic ready;

// Ready
assign ready = inIDLE;

// Decode states
assign inIDLE = (state == IDLE);
assign inTRIGGER = (state == TRIGGER);
assign inWAIT = (state == WAIT);
assign inCOUNTECHO = (state == COUNTECHO);
assign inDISPLAY = (state == DISPLAY_DISTANCE);

// State transitions
always @(posedge clk or posedge rst) begin
  if (rst) begin
    state <= IDLE;
  end
  else begin
    case (state)
      IDLE: begin
          state <= (measure & ready) ? TRIGGER : state;
        end
      TRIGGER: begin
          state <= (trigcountDONE) ? WAIT : state;
        end
      WAIT: begin
          state <= (echo) ? COUNTECHO : state;
        end
      COUNTECHO: begin
          state <= (echo) ? state : DISPLAY_DISTANCE;
        end
      DISPLAY_DISTANCE: begin
          state <= IDLE;
        end
    endcase
  end
end

// Trigger
assign trig = inTRIGGER;

// Counter
always @(posedge clk) begin
  if (inIDLE) begin
    counter <= 10'd0;
  end
  else begin
    counter <= counter + {9'd0, (|counter | inTRIGGER)};
  end
end

assign trigcountDONE = (counter == ten_us);

// Get distance
always @(posedge clk) begin
  if (inWAIT) begin
    distanceRAW <= 22'd0;
  end
  else begin
    distanceRAW <= distanceRAW + {21'd0, inCOUNTECHO};
  end
end

// Calculate distance in cm
always @(posedge clk) begin
  if (inDISPLAY) begin
    distanceRAW_in_cm <= distanceRAW * 32'h1648;
  end
end

assign distance = distanceRAW_in_cm[31:24];

endmodule
