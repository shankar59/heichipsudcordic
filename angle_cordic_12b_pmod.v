
`timescale 1ns / 1ps



module angle_cordic_12b_pmod#(parameter width = 12, CNT = 65536, freq_width = 16) (clk1, resetn, freq, pwm_data, pwm_led, waveform_sel);

  
// Inputs
  input clk1;
  input resetn;
  input [freq_width-1:0] freq;
  input waveform_sel;

//Outputs  
output pwm_data;
output pwm_led;
wire clock = clk1;
// clk_wiz_0 clk_wiz
//   (
    // Clock out ports
//    .clock(clock),     // output clock
//   // Clock in ports
//    .clk1(clk1));      // input clk1
//wire resetn = !resetn1;
reg  reset_reg;
reg pwm_data_reg;
reg pwm_pulse;
reg [29:0] counter;
always @ (posedge clock) begin
reset_reg <= (resetn) ? 1'b0 : 1'b1;
end

wire  signed [width-1:0] sine;
wire  signed [width-1:0] cosine;
wire  [width-5:0] sample;

	angle_cordic_12b#(.width(width), .CNT(CNT), .freq_width(freq_width))  angle_cordic_12b (
     .clock     (clock),
     .resetn     (reset_reg),
	 .freq   (freq),
	 //.start (start_reg),
	 .SINout       (sine),
	 .COSout       (cosine));
	 
	 assign sample = (waveform_sel == 1'b1) ? sine[11:4] : cosine[11:4];
	 
	 //pmod_cont pmod_cont(.clock(clock),.cs(cs),.sclk(sclk), .resetn(reset_reg), .data(data),.datain(sine));
	 pmod_pwm i_pwm(
        .clk(clock),
        .rst_n(reset_reg),

        .sample(sample),

        .pwm(pwm_data)
    );
    
    
    always @ (posedge clock)
    begin
         pwm_pulse <= !reset_reg ? 1'b0 : pwm_data ? ~pwm_pulse : pwm_pulse;    
    end    
    assign pwm_led = pwm_pulse;
	 
endmodule