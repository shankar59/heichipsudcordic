module vga_top(
    input         clk100,
    input         reset,
    input  signed [11:0] cordic_val, 
    output reg [1:0] r,
    output reg [1:0] g,
    output reg [1:0] b,
    output reg hsync,
    output reg vsync
);

    localparam H_ACTIVE = 640;
    localparam H_FP     = 16;
    localparam H_SYNC   = 96;
    localparam H_BP     = 48;
    localparam H_TOTAL  = 800;

    localparam V_ACTIVE = 480;
    localparam V_FP     = 10;
    localparam V_SYNC   = 2;
    localparam V_BP     = 33;
    localparam V_TOTAL  = 525;

    localparam CENTER_X = 320;
    localparam CENTER_Y = 240;
    localparam AMPLITUDE_SCALE = 150;

    reg [10:0] h_cnt = 0, v_cnt = 0;
    reg [1:0] pixel_r, pixel_g, pixel_b;
    reg active_video;
    reg pixel_clk_en;
    reg [1:0] clk_div_cnt = 0;
    reg signed [11:0] v_pos;

    always @(posedge clk100) begin
        if (!reset) begin
            clk_div_cnt <= 0;
            pixel_clk_en <= 0;
        end else begin
            if (clk_div_cnt == 3) begin
                clk_div_cnt <= 0;
                pixel_clk_en <= 1;
            end else begin
                clk_div_cnt <= clk_div_cnt + 1;
                pixel_clk_en <= 0;
            end
        end
    end

    always @(posedge clk100) begin
        if (!reset) begin
            h_cnt <= 0;
            v_cnt <= 0;
        end else if (pixel_clk_en) begin
            if (h_cnt == H_TOTAL-1) begin
                h_cnt <= 0;
                if (v_cnt == V_TOTAL-1)
                    v_cnt <= 0;
                else
                    v_cnt <= v_cnt + 1;
            end else begin
                h_cnt <= h_cnt + 1;
            end
        end
    end

    always @(*) begin
        hsync = (h_cnt >= H_ACTIVE + H_FP && h_cnt < H_ACTIVE + H_FP + H_SYNC) ? 0 : 1;
        vsync = (v_cnt >= V_ACTIVE + V_FP && v_cnt < V_ACTIVE + V_FP + V_SYNC) ? 0 : 1;
        active_video = (h_cnt < H_ACTIVE && v_cnt < V_ACTIVE);
    end

    always @(posedge clk100) begin
        if (pixel_clk_en) begin
            v_pos = CENTER_Y - (cordic_val * AMPLITUDE_SCALE / 2048);

            if (v_pos < 0)
                v_pos = 0;
            else if (v_pos >= V_ACTIVE)
                v_pos = V_ACTIVE - 1;
        end
    end

    always @(posedge clk100) begin
        if (pixel_clk_en) begin
            if (active_video) begin
                if (h_cnt == CENTER_X || h_cnt == CENTER_X + 1 || v_cnt == CENTER_Y || v_cnt == CENTER_Y + 1) begin
                    pixel_r <= 2'b11;
                    pixel_g <= 2'b00;
                    pixel_b <= 2'b00;
                end else if (v_cnt == v_pos) begin
                    pixel_r <= 2'b00;
                    pixel_g <= 2'b11;
                    pixel_b <= 2'b00;
                end else begin
                    pixel_r <= 2'b00;
                    pixel_g <= 2'b00;
                    pixel_b <= 2'b00;
                end
            end else begin
                pixel_r <= 2'b00;
                pixel_g <= 2'b00;
                pixel_b <= 2'b00;
            end
        end
    end

    always @(*) begin
        r = pixel_r;
        g = pixel_g;
        b = pixel_b;
    end

endmodule
