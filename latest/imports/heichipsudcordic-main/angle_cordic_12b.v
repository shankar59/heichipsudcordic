`timescale 1ns / 1ps



module angle_cordic_12b#(parameter width = 16, CNT = 131072, freq_width = 12) (clock, resetn, freq, SINout, COSout,tri_amp, sqr_amp);

  
// Inputs
  input clock;
  input resetn;
  input [freq_width-1:0] freq;
  
  output reg signed [width-1:0] SINout;
  output reg signed [width-1:0] COSout;
  output reg signed [width-1:0] tri_amp;
  output reg signed [width-1:0] sqr_amp;
  wire [width-1:0] x_start,y_start;
  
  wire [width-1:0] angle;
  
  wire [width-1:0] SINout_wire;
  
  wire [width-1:0] COSout_wire;
  
  wire [width-1:0] tri_amp_wire, sqr_amp_wire;
  
  angle_gen_12b#(.width(width), .CNT(CNT), .freq_width(freq_width)) angle_gen(.clock(clock), .resetn(resetn), .freq(freq), .angle(angle), .x_start(x_start), .y_start(y_start),  .tri_amp(tri_amp_wire), .sqr_amp(sqr_amp_wire));
  
 cordic_12b#(.width(width)) cordic(.clk(clock), .resetn(resetn), .SINout(SINout_wire), .COSout(COSout_wire), .x_start(x_start), .y_start(y_start), .angle(angle));
 
  always @ (posedge clock)
		begin
			SINout <= (!resetn) ? 0 : SINout_wire;
			COSout <= (!resetn) ? 0 : COSout_wire;
			tri_amp <= (!resetn) ? 0 : tri_amp_wire;
			sqr_amp <= (!resetn) ? 0 : sqr_amp_wire;
		end
		
//ila_0 ila (
//	.clk(clock), // input wire clk


//	.probe0(resetn), // input wire [0:0]  probe0  
//	.probe1(start), // input wire [0:0]  probe1 
//	.probe2(freq), // input wire [15:0]  probe2 
//	.probe3(angle), // input wire [11:0]  probe3 
//	.probe4(SINout) // input wire [11:0]  probe4
//);		
		
endmodule
