`timescale 1ns/1ns

module debounce (
    input logic clk,
    input logic button,
    output logic button_pressed
);

    localparam delay_val = 2500; // 50us with clk period 20ns is 2500 counts

    // Your code here!
    reg [11:0] count;
    reg n;

    always @(posedge clk) begin
        count <= count + 1;
        if (button != n) begin
            count <= 0;
        end
        else if (count >= delay_val) begin
            button_pressed <= button;
        end
        n <= button;
    end

endmodule


