`timescale 1ns / 1ps

module angle_cordic_12b_pmod#(parameter width = 12, CNT = 131072, freq_width = 13) (clk1, reset, freq, r, g, b, hsync, vsync, pwm_data, waveform_sel);

// Inputs
  input clk1;
  input reset;
 // input  wire  mode;
  input [freq_width-1:0] freq;
  input [1:0] waveform_sel;

//Outputs  
output pwm_data;
//output pwm_led;
output wire [1:0]   r;
output wire [1:0]   g;
output wire [1:0]   b;
output wire  hsync;
output wire  vsync;

wire clock = clk1;
// clk_wiz_0 clk_wiz
//   (
    // Clock out ports
//    .clock(clock),     // output clock
//   // Clock in ports
//    .clk1(clk1));      // input clk1
wire resetn = !reset;
reg  reset_reg;
reg [1:0] waveform_sel_reg;
always @ (posedge clock) begin
	reset_reg <= (resetn) ? 1'b1 : 1'b0;
end
always @ (posedge clock) begin
	waveform_sel_reg <= (!reset_reg) ? 2'b00 : waveform_sel;
end

wire  signed [width-1:0] sine;
wire  signed [width-1:0] cosine;
wire signed [width-1:0] tri_amp;
wire signed [width-1:0] sqr_amp;
wire  [width-1:0] sample;	
//wire  [width-5:0] sample;

	angle_cordic_12b#(.width(width), .CNT(CNT), .freq_width(freq_width))  angle_cordic_12b (
     .clock     (clock),
     .resetn     (reset_reg),
	 .freq   (freq),
	 .tri_amp(tri_amp),
	 .sqr_amp(sqr_amp),
	 //.start (start_reg),
	 .SINout       (sine),
	 .COSout       (cosine));
	 
	 assign sample = (waveform_sel_reg == 2'b00) ? sine : (waveform_sel_reg == 2'b01) ? cosine : (waveform_sel_reg == 2'b10) ? tri_amp : sqr_amp;
	 
	 //pmod_cont pmod_cont(.clock(clock),.cs(cs),.sclk(sclk), .resetn(reset_reg), .data(data),.datain(sine));
		 pmod_pwm# (.width(width)) i_pwm(
        .clk(clock),
        .rst_n(reset_reg),

        .sample(sample),

        .pwm(pwm_data)
    );
    
    
	// assign pwm_led = pwm_data;
	 
	 
	vga_top u_vga_top (
        .clk100(clk1),
	.reset(reset_reg),
	.cordic_val(sample),
        .r(r),
        .g(g),
        .b(b),
        .hsync(hsync),
        .vsync(vsync)
    );
    

    

	 

endmodule
