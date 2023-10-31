module fifo #(parameter W, D) (
  input        clk,
  input        rst,
  input        we,
  input        re,
  input        [W-1:0] data_in,
  output reg   [W-1:0] data_out,
  output       empty,
  output       full
);
    localparam a_width = int'($clog2(D));

    reg [W-1:0]       ram [2**a_width-1:0];
    reg [a_width:0] rd_ptr, wr_ptr;

    always @(posedge clk) begin
        if (rst) begin
            wr_ptr <= '0;
            rd_ptr <= '0;  
        end
        else begin
            if (we & ~full) begin
                ram[wr_ptr[a_width-1:0]] <= data_in;
                wr_ptr <= wr_ptr + 1;
            end
            if (re & ~empty) begin
                data_out <= ram[rd_ptr[a_width-1:0]];
                rd_ptr <= rd_ptr + 1;
            end
        end
    end

    assign empty = wr_ptr == rd_ptr;
    assign full = wr_ptr[a_width-1:0] == rd_ptr[a_width-1:0] & wr_ptr[a_width:a_width] != rd_ptr[a_width:a_width]; 
endmodule
