`timescale 1ns / 1ps

module angle_cordic_12b_pmod#(parameter width = 16, CNT = 131072, freq_width = 12) (clk1, reset, freq, mode, r, g, b, hsync, vsync, pwm_data,pwm_led, waveform_sel);

// Inputs
  input clk1;
  input reset;
  input  wire  mode;
  input [freq_width-1:0] freq;
  input [1:0] waveform_sel;

//Outputs  
output pwm_data;
output pwm_led;
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
always @ (posedge clock) begin
	reset_reg <= (resetn) ? 1'b1 : 1'b0;
end

wire  signed [11:0] sine;
wire  signed [11:0] cosine;
wire signed [11:0] tri_amp;
wire signed [11:0] sqr_amp;
wire  [11:0] sample;	
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
	 
	 assign sample = (waveform_sel == 2'b00) ? sine : (waveform_sel == 2'b01) ? cosine : (waveform_sel == 2'b10) ? tri_amp : sqr_amp;
	 
	 //pmod_cont pmod_cont(.clock(clock),.cs(cs),.sclk(sclk), .resetn(reset_reg), .data(data),.datain(sine));
		 pmod_pwm# (.width(width)) i_pwm(
        .clk(clock),
        .rst_n(reset_reg),

        .sample(sample),

        .pwm(pwm_data)
    );
    
    
	 assign pwm_led = pwm_data;
	 
	 
	vga_top u_vga_top (
        .clk100(clk1),
		.reset(reset_reg),
        .mode(mode),
		.cordic_val(sample),
		.cosine_val(cosine),
		.sine_val(sine),
        .r(r),
        .g(g),
        .b(b),
        .hsync(hsync),
        .vsync(vsync)
    );
    

    

	 

endmodule
