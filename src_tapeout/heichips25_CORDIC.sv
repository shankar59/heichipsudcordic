// SPDX-FileCopyrightText: © 2025 XXX Authors
// SPDX-License-Identifier: Apache-2.0

// Adapted from the Tiny Tapeout template

`default_nettype none

module heichips25_CORDIC (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    wire reset = !rst_n;
    
    wire [12:0] freq_in = {uio_in[4:0],ui_in[7:0]};
    wire [1:0] waveform_sel = {uio_in[6:5]};
    wire pwm_data = {uio_in[7]};
    
    wire [1:0] r_sig = uo_out[1:0];
    wire [1:0] g_sig = uo_out[3:2];
    wire [1:0] b_sig = uo_out[5:4];
    wire hsync_sig = uo_out[6];
    wire vsync_sig = uo_out[7];
    // Instantiate angle_cordic_12b_pmod
    angle_cordic_12b_pmod #(
    .width(12),       // Data width
    .CNT(131072),     // Counter max
    .freq_width(13)   // Frequency input width
)   u_angle_cordic_12b_pmod (
    .clk1        (clk),        // Connect your clock signal
    .reset       (reset),       // Connect your reset signal
    .freq        (freq_in),        // [12:0] frequency input
    .waveform_sel(waveform_sel),// [1:0] waveform select

    .pwm_data    (pwm_data),    // PWM output
 //   .pwm_led     (pwm_led_sig),     // PWM LED output
    .r           (r_sig),           // [1:0] red output
    .g           (g_sig),           // [1:0] green output
    .b           (b_sig),           // [1:0] blue output
    .hsync       (hsync_sig),       // Horizontal sync
    .vsync       (vsync_sig)        // Vertical sync
);

    assign uio_oe  = 8'b10000000;


endmodule