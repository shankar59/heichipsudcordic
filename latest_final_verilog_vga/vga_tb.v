`timescale 1ns/1ps

module vga_tb;
    reg clk100_tb;
    reg reset_tb;
    reg signed [11:0] cordic_val_tb;

    wire [1:0] r, g, b;
    wire hsync, vsync;

    vga_top uut (
        .clk100(clk100_tb),
        .reset(reset_tb),
        .cordic_val(cordic_val_tb),
        .r(r), .g(g), .b(b),
        .hsync(hsync), .vsync(vsync)
    );

    initial begin
        clk100_tb = 0;
        forever #5 clk100_tb = ~clk100_tb;
    end

    real t_ns = 0.0;
    real freq = 1000.0; 
    real pi = 3.1415926535;

    initial begin
        reset_tb = 0;
        cordic_val_tb = 0;
        #100;           
        reset_tb = 1;

        forever begin
            cordic_val_tb = $rtoi(127.0 * $sin(2.0 * pi * freq * (t_ns * 1e-9)));
            t_ns = t_ns + 10.0;
            #10;
        end
    end

endmodule
