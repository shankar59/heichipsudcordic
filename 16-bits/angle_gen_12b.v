`timescale 1ns / 1ps



module angle_gen_12b#(parameter width = 16, CNT = 131072, freq_width = 12) (clock, resetn, freq, angle, x_start, y_start);

  

// Inputs
  input clock;
  input resetn;
  input [freq_width-1:0] freq;
 
//Outputs
	output reg  [width-1:0] x_start,y_start; 
	output reg  [width-1:0] angle;
    
    wire [width-1:0] An = 1215; //2000*0.6073
	
	reg [freq_width-1:0] freq_reg;
	
	reg [freq_width+5:0] cnt;
	
	wire [freq_width+5:0] cnt_sum = CNT-(freq_reg<<5);
	
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
		angle <= (!resetn) ? 0 : (cnt == cnt_sum) ? angle +12'h07F : angle;
	end
	
	always @ (posedge clock)
	begin
		x_start <= (!resetn) ? 0 : An;
		y_start <= (!resetn) ? 0 : 0;
	end
	
	
endmodule