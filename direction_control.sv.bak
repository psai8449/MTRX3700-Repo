module DualMotorControlFinal (
    input logic clk,                // System Clock  
    output logic ina1, inb1, ina2, inb2  // Direction controls for two motors
);

    typedef enum {forwards, backwards, left, right} state;
    state current_state, next_state;

    initial begin
        current_state = forwards;
    end

    logic direction1, direction2;

    // Creating Delay Counter for Each State
    parameter DELAY_COUNT = 20_000_000; // Number of clock cycles for 2 seconds with a 50MHz clock

    logic [31:0] count;    

    always_ff @(posedge clk) begin
        if (count < DELAY_COUNT) begin
            count <= count + 1;
        end
        else begin
            current_state <= next_state;
            count <= 32'b0;
        end
    end

    always_comb begin : next_state_logic
        case(current_state)
            forwards: begin
                direction1 = 1'b1;
                direction2 = 1'b1;
                next_state = backwards;  
            end
            backwards: begin
                direction1 = 1'b0;
                direction2 = 1'b0;
                next_state = left;
            end
            left: begin
                direction1 = 1'b1;
                direction2 = 1'b0;
                next_state = right;
            end
            right: begin
                direction1 = 1'b0;
                direction2 = 1'b1;
                next_state = forwards;
            end
        endcase
    end

    always_comb begin : direction_logic
        // forwards
        if ((direction1 == 1'b1) && (direction2 == 1'b1)) begin
            ina1 = 1'b0;
            inb1 = 1'b1;
            ina2 = 1'b0;
            inb2 = 1'b1;
        end

        // backwards
        else if ((direction1 == 1'b0) && (direction2 == 1'b0)) begin
            ina1 = 1'b1;
            inb1 = 1'b0;
            ina2 = 1'b1;
            inb2 = 1'b0;
        end

        // left
        else if ((direction1 == 1'b1) && (direction2 == 1'b0)) begin
            ina1 = 1'b0;
            inb1 = 1'b1;
            ina2 = 1'b1;
            inb2 = 1'b0;
        end

        // right
        else /* if ((direction1 == 1'b0) && (direction2 == 1'b1)) */ begin
            ina1 = 1'b1;
            inb1 = 1'b0;
            ina2 = 1'b0;
            inb2 = 1'b1;
        end

    end

        
    

endmodule

