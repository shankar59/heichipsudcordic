module vga_top (
    input  wire        clk100,
    input  wire        reset, // active high
    input  wire        mode,  // '0' = waveform, '1' = vector mode
    input  wire signed [11:0] cordic_val, // -2048 to +2047 (scaled)
    input  wire signed [11:0] cosine_val,
    input  wire signed [11:0] sine_val,
    output reg  [1:0]  r,
    output reg  [1:0]  g,
    output reg  [1:0]  b,
    output wire        hsync,
    output wire        vsync
);

    // Dummy assignments for compilation
    assign hsync = 1'b1;
    assign vsync = 1'b1;

    always @(posedge clk100 or negedge reset) begin
        if (!reset) begin
            r <= 2'b00;
            g <= 2'b00;
            b <= 2'b00;
        end else begin
            // Simple cycling colors for test
            r <= r + 1;
            g <= g + 1;
            b <= b + 1;
        end
    end

endmodule
