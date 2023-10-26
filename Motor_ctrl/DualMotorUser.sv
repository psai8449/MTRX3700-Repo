module direction_control (
    input logic clk,                // System Clock  
    input [7:0] IR_input,
    output logic ina1, inb1, ina2, inb2  // Direction controls for two motors
);

    typedef enum {idle, forwards, backwards, left, right} state;
    state current_state, next_state;

    initial begin
        current_state = idle;
    end

    logic direction1, direction2, brake;

    // Creating Delay Counter for Each State
    parameter DELAY_COUNT = 100_000_000; // Number of clock cycles for 2 seconds with a 50MHz clock

    logic [31:0] count;    

    always_ff @(posedge clk) begin
        if (IR_input != 8'b00000000) begin
           if (count < DELAY_COUNT) begin
                count <= count + 1;
            end
            else begin
                current_state <= next_state;
                count <= 32'b0;
            end 
        end  
    end

    always_comb begin : next_state_logic
        case(current_state)
            idle: begin
                brake = 1'b1;
                next_state = (IR_input = 8'b00000010) ? forwards : idle;
                next_state = (IR_input = 8'b10000000) ? backwards : idle;
                next_state = (IR_input = 8'b00001000) ? left : idle;
                next_state = (IR_input = 8'b00100000) ? right : idle;
            end
            forwards: begin
                idle = 1'b0;
                direction1 = 1'b1;
                direction2 = 1'b1;
                next_state = idle;  
            end
            backwards: begin
                idle = 1'b0;
                direction1 = 1'b0;
                direction2 = 1'b0;
                next_state = idle;
            end
            left: begin
                idle = 1'b0;
                direction1 = 1'b1;
                direction2 = 1'b0;
                next_state = idle;
            end
            right: begin
                idle = 1'b0;
                direction1 = 1'b0;
                direction2 = 1'b1;
                next_state = idle;
            end
        endcase
    end

    always_comb begin : direction_logic
        if (brake == 1'b1) begin
            ina1 = 1'b0;
            inb1 = 1'b0;
            ina2 = 1'b0;
            inb2 = 1'b0;
        end
        
        // forwards
        else if ((direction1 == 1'b1) && (direction2 == 1'b1)) begin
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

