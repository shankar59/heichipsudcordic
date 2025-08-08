`timescale 1ns/1ps

module angle_cordic_pmod_tb;

  // Parameters
  parameter width = 16;
  parameter CNT = 131072;
  parameter freq_width = 12;

  // Inputs
  reg clk1;
  reg reset;
  reg [freq_width-1:0] freq;
  reg waveform_sel;

  // Outputs
  wire pwm_data;
  wire pwm_led;

  // Clock generation (10ns period => 100MHz)
  always #5 clk1 = ~clk1;

  // DUT instantiation
  angle_cordic_12b_pmod #(
    .width(width),
    .CNT(CNT),
    .freq_width(freq_width)
  ) dut (
    .clk1(clk1),
    .reset(reset),
    .freq(freq),
    .pwm_data(pwm_data),
    .pwm_led(pwm_led),
    .waveform_sel(waveform_sel)
  );

  initial begin
    // Initialize inputs
    clk1 = 0;
    reset = 1;
    freq = 12'd4095;
    waveform_sel = 1;

    // Apply reset
    #1000 reset = 0;

    // Test case 1: Set frequency low, waveform = 0 (e.g., sine)
    waveform_sel = 0;
   // Finish simulation
  //  $finish;
  end

endmodule
