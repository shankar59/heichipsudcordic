`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/07/2025 06:42:12 PM
// Design Name: 
// Module Name: pmod_pwm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module pmod_pwm (
    input wire clk,
    input wire rst_n,
    input wire signed [7:0] sample,

    output reg pwm
);

    reg signed [7:0] sample_reg;
    localparam SAMPLE = 122;
    always @(posedge clk)
         begin
            sample_reg <= !rst_n ? 8'h0 : sample;
            pwm <= !rst_n ? 1'b0 : (sample < sample_reg) ? (sample_reg >= SAMPLE) ? 1'b1 : 1'b0 : 1'b0;

    end

endmodule
