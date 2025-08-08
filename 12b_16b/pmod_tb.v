`timescale 1ns / 1ps

module pmod_tb();

    // Inputs
    reg clk;
    reg rst_n;
    reg signed [7:0] sample;

    // Output
    wire pwm;

    // Instantiate the Unit Under Test (UUT)
    pmod_pwm uut (
        .clk(clk),
        .rst_n(rst_n),
        .sample(sample),
        .pwm(pwm)
    );

    // Clock generation: 10ns period (100MHz)
    always #5 clk = ~clk;

    integer i;

    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        sample = 0;

        // Reset pulse
        #1000;
        rst_n = 1;
        

        // Hold the last value
    end
        always @ (posedge clk)
        begin
            sample <= !rst_n ? -128: sample+1;   // cast to 8-bit signed
        end
endmodule
