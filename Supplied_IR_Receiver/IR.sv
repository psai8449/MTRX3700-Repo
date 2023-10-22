


module IR(clk,rst_n,IR,led_cs,led_db);

  input   clk;
  input   rst_n;
  input   IR;
  output [3:0] led_cs;
  output [7:0] led_db;
 
  logic [3:0] led_cs;
  logic [7:0] led_db;
 
  logic [7:0] led1,led2,led3,led4;
  logic [15:0] irda_data;    // save irda data,than send to 7 segment led
  logic [31:0] get_data;     // use for saving 32 bytes irda data
  logic [5:0]  data_cnt;     // 32 bytes irda data counter
  logic [2:0]  cs,ns;
  logic error_flag;          // 32 bytes data期间，数据错误标志

  //----------------------------------------------------------------------------
  logic irda_logic0;       //为了避免亚稳态,避免驱动多个寄存器，这一个不使用。
  logic irda_logic1;       //这个才可以使用，以下程序中代表irda的状态
  logic irda_logic2;       //为了确定irda的边沿，再打一次寄存器，以下程序中代表irda的前一状态
  logic irda_neg_pulse; //确定irda的下降沿
  logic irda_pos_pulse; //确定irda的上升沿
  logic irda_chang;     //确╥rda的跳变沿
  
  logic[15:0] cnt_scan;//扫描频率计数器
   
  always @ (posedge clk) 
    if(!rst_n)
      begin
        irda_logic0 <= 1'b0;
        irda_logic1 <= 1'b0;
        irda_logic2 <= 1'b0;
      end
    else
      begin
        led_cs <= 4'b0000; 
        irda_logic0 <= IR;
        irda_logic1 <= irda_logic0;
        irda_logic2 <= irda_logic1;
      end
     
  assign irda_chang = irda_neg_pulse | irda_pos_pulse;  
  assign irda_neg_pulse = irda_logic2 & (~irda_logic1);  
  assign irda_pos_pulse = (~irda_logic2) & irda_logic1;      


  logic [10:0] counter;  //分频1750次
  logic [8:0]  counter2; 
  logic check_9ms;  // check leader 9ms time
  logic check_4ms;  // check leader 4.5ms time
  logic low;        // check  data="0" time
  logic high;       // check  data="1" time
 
  //----------------------------------------------------------------------------
  //分频1750计数
  always @ (posedge clk)
    if (!rst_n)
      counter <= 11'd0;
    else if (irda_chang)  //irda
      counter <= 11'd0;
    else if (counter == 11'd1750)
      counter <= 11'd0;
    else
      counter <= counter + 1'b1;
  
  //---------------------------------------------------------------------------- 
  always_ff @(posedge clk)
    if (!rst_n)
      counter2 <= 9'd0;
    else if (irda_chang)  
      counter2 <= 9'd0;
    else if (counter == 11'd1750)
      counter2 <= counter2 +1'b1;
  

  assign check_9ms = ((217 < counter2) & (counter2 < 297)); 
  //257  
  assign check_4ms = ((88 < counter2) & (counter2 < 168));  //128
  assign low  = ((6 < counter2) & (counter2 < 26));         // 16
  assign high = ((38 < counter2) & (counter2 < 58));        // 48

  //----------------------------------------------------------------------------
  // generate statemachine  
    parameter IDLE       = 3'b000, 
              LEADER_9   = 3'b001, //9ms
              LEADER_4   = 3'b010, //4ms
              DATA_STATE = 3'b100; 
 
  always_ff @(posedge clk)
    if (!rst_n)
      cs <= IDLE;
    else
      cs <= ns; //状态位
     
  always_comb
    case (cs)
      IDLE:
        if (~irda_logic1)
          ns = LEADER_9;
        else
          ns = IDLE;
   
      LEADER_9:
        if (irda_pos_pulse)   //leader 9ms check
          begin
            if (check_9ms)
              ns = LEADER_4;
            else
              ns = IDLE;
          end
        else  //完备的if---else--- ;防止生成latch
          ns =LEADER_9;
   
      LEADER_4:
        if (irda_neg_pulse)  // leader 4.5ms check
          begin
            if (check_4ms)
              ns = DATA_STATE;
            else
              ns = IDLE;
          end
        else
          ns = LEADER_4;
   
      DATA_STATE:
        if ((data_cnt == 6'd32) & irda_logic2 & irda_logic1)
          ns = IDLE;
        else if (error_flag)
          ns = IDLE;
        else
          ns = DATA_STATE;
      default:
        ns = IDLE;
    endcase

  always_ff @(posedge clk)
    if (!rst_n)
      begin
        data_cnt <= 6'd0;
        get_data <= 32'd0;
        error_flag <= 1'b0;
      end
  
    else if (cs == IDLE)
      begin
        data_cnt <= 6'd0;
        get_data <= 32'd0;
        error_flag <= 1'b0;
      end
  
    else if (cs == DATA_STATE)
      begin
        if (irda_pos_pulse)  // low 0.56ms check
          begin
            if (!low)  //error
              error_flag <= 1'b1;
          end
        else if (irda_neg_pulse)  //check 0.56ms/1.68ms data 0/1
          begin
            if (low)
              get_data[0] <= 1'b0;
            else if (high)
              get_data[0] <= 1'b1;
            else
              error_flag <= 1'b1;
             
            get_data[31:1] <= get_data[30:0];
            data_cnt <= data_cnt + 1'b1;
          end
      end

  always_ff @(posedge clk)
    if (!rst_n)
      irda_data <= 16'd0;
    else if ((data_cnt ==6'd32) & irda_logic1)
  begin
   led1 <= get_data[7:0];  
   led2 <= get_data[15:8]; 
   led3 <= get_data[23:16];
   led4 <= get_data[31:24];
  end
 

always_ff @(posedge led2) 
begin
	case(led2)
	
	                   
      8'b00001111: 
			led_db=8'b1100_0000; 

		8'b00110000: 
			led_db=8'b1111_1001;  

		8'b00011000: 
			led_db=8'b1010_0100;  

		8'b01111010: 
			led_db=8'b1011_0000;  

		8'b00010000: 
			led_db=8'b1001_1001; 

		8'b00111000: 
			led_db=8'b1001_0010; 

		8'b01011010: 
			led_db=8'b1000_0010;  

		8'b01000010: 
			led_db=8'b1111_1000;  

		8'b01001010: 
			led_db=8'b1000_0000;  

		8'b01010010: 
			led_db=8'b1001_0000;  
			
	  
	   default: led_db=8'b1000_1110;

	 endcase
end

endmodule 