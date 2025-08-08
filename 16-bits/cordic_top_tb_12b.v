`timescale 1ns / 1ps
module cordic_top_tb_12b ();

parameter width =12;
parameter CNT = 131072;
parameter freq_width = 12; 
      reg clk,rst,start;  
	  reg [freq_width-1:0] freq;
//    reg [width-1:0] x_start,y_start,angle;
	wire  [width-1:0] angle;

	wire  [width-1:0] sine,cosine;
	wire [7:0] sine_u = sine[11:4];
	wire [7:0] cosine_u = cosine[11:4];
angle_cordic_12b#(.width(width), .CNT(CNT), .freq_width(freq_width))  angle_cordic_12b (
     .clock     (clk),
     .resetn     (rst),
	 .freq   (freq),
//	 .start    (start),
//	 .angle      (angle),
	 .SINout       (sine),
	 .COSout  (cosine));
     
      initial
        begin
		clk = 1'b0;
		rst = 1'b1;
		start = 1'b0;
		freq = 12'd4095;
	#(1000) rst= 1'b0;
	#(1000) start= 1'b1;
	#(100) start= 1'b0;
		end

     always #5 clk = ~clk;
endmodule