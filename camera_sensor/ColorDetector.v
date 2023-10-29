module ColorDetector (
  input wire [7:0] red,
  input wire [7:0] green,
  input wire [7:0] blue,
  output wire tape_detected,
  output wire [9:0] x_position,
  output wire [9:0] y_position
);

  // Define the acceptable RGB range for yellow
  parameter YELLOW_MIN_R = 180;
  parameter YELLOW_MAX_R = 255;
  parameter YELLOW_MIN_G = 180;
  parameter YELLOW_MAX_G = 255;
  parameter YELLOW_MIN_B = 0;
  parameter YELLOW_MAX_B = 80;

  // Define parameters for tape region
  parameter TAPE_X_START = 200;
  parameter TAPE_X_END = 800;
  parameter TAPE_Y_START = 200;
  parameter TAPE_Y_END = 600;

  wire is_yellow;

  assign is_yellow = (
    (red >= YELLOW_MIN_R) && (red <= YELLOW_MAX_R) &&
    (green >= YELLOW_MIN_G) && (green <= YELLOW_MAX_G) &&
    (blue >= YELLOW_MIN_B) && (blue <= YELLOW_MAX_B)
  );

  wire is_in_tape_region;

  assign is_in_tape_region = (
    (x_position >= TAPE_X_START) && (x_position <= TAPE_X_END) &&
    (y_position >= TAPE_Y_START) && (y_position <= TAPE_Y_END)
  );

  // Logic for tape detection and position
  assign tape_detected = is_yellow && is_in_tape_region;
  assign x_position = is_in_tape_region ? x_position : 10'b0;
  assign y_position = is_in_tape_region ? y_position : 10'b0;

endmodule