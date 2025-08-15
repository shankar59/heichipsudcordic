`timescale 1ns / 1ps



module angle_gen_12b#(parameter width = 12, CNT = 131072, freq_width = 13) (clock, resetn, freq, angle, x_start, y_start, tri_amp, sqr_amp);

  

// Inputs
  input clock;
  input resetn;
  input [freq_width-1:0] freq;
 
//Outputs
	output reg  [width-1:0] x_start,y_start; 
	output reg  [width-1:0] angle;
    output reg signed [width-1:0] tri_amp, sqr_amp;
    wire [width-1:0] An = 1215; //2000*0.6073
	
	reg [freq_width-1:0] freq_reg;
	
	reg [freq_width+4:0] cnt;
	
	wire [freq_width+4:0] cnt_sum = CNT-(freq_reg<<5);
	
	always @ (posedge clock)
		begin
			freq_reg <= (!resetn) ? 0 : freq;

		end	
	
	
	always @ (posedge clock)
	begin
		cnt <= (!resetn) ? 0: (cnt == cnt_sum) ? 0 : cnt+1'b1;
	end
	
	always @ (posedge clock)
	begin
		angle <= (!resetn) ? 0 : (cnt == cnt_sum) ? angle +12'd31 : angle;
	end
	
	always @ (posedge clock)
	begin
		x_start <= (!resetn) ? 0 : An;
		y_start <= (!resetn) ? 0 : 0;
	end
	
	reg up;
	   always @ (posedge clock)
	begin
	if(!resetn)
	up <= 1;
	else
	begin
	   if(tri_amp>=1875) //2000-stepsize
		  up <= 0;
	   else if (tri_amp < -1875) //-(2000-stepsize)
		  up <= 1;
	   else up <= up;
     end
	end
	always @ (posedge clock)
	begin
	if(!resetn)
	tri_amp <= 0;
	else
	begin
	   if(up)
		tri_amp <= (cnt == cnt_sum) ? tri_amp + 8'd63 : tri_amp; //stepsize = 2000/no.of points from 0 to 2000; currently 2000/16 = 125
	   else 
	    tri_amp <= (cnt == cnt_sum) ? tri_amp - 8'd63 : tri_amp;
     end
	end	
	
	always@(posedge clock)
	begin
	if(!resetn)
    sqr_amp <=  12'd0;
    else if(tri_amp>=0)
    sqr_amp <= 12'd1999;
    else if (tri_amp<0)
    sqr_amp <= -12'd2000;
    else sqr_amp <= 12'd0;
	end
	
endmodule