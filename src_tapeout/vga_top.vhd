library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_top is
    port (
        clk100    : in  std_logic;
        reset    : in  std_logic;
        mode     : in  std_logic; -- '0' = waveform, '1' = vector mode
        cordic_val : in signed(11 downto 0); -- -128 to +127
        cosine_val : in signed(11 downto 0); -- e.g. from CORDIC output
        sine_val   : in signed(11 downto 0);
        r        : out std_logic_vector(1 downto 0); -- VGA Red[1:0]
        g        : out std_logic_vector(1 downto 0); -- VGA Green[1:0]
        b        : out std_logic_vector(1 downto 0); -- VGA Blue[1:0]
        hsync    : out std_logic;
        vsync    : out std_logic
    );
end vga_top;

architecture rtl of vga_top is
    -- VGA timing for 640x480 @ 60Hz
    constant H_ACTIVE : integer := 640;
    constant H_FP     : integer := 16;
    constant H_SYNC   : integer := 96;
    constant H_BP     : integer := 48;
    constant H_TOTAL  : integer := 800;

    constant V_ACTIVE : integer := 480;
    constant V_FP     : integer := 10;
    constant V_SYNC   : integer := 2;
    constant V_BP     : integer := 33;
    constant V_TOTAL  : integer := 525;

    constant CENTER_X : integer := 320;
    constant CENTER_Y : integer := 240;
    constant RADIUS : integer := 150;
    constant AMPLITUDE_SCALE : integer := 150;

    signal h_cnt, v_cnt         : integer range 0 to H_TOTAL-1 := 0;
    signal pixel_r, pixel_g, pixel_b : std_logic_vector(1 downto 0) := (others => '0');
    signal active_video         : std_logic;
    signal v_pos                : integer range 0 to V_ACTIVE-1;
    signal pixel_clk_en         : std_logic := '0';
    signal wave_bit             : std_logic := '0';
    signal vec_bit              : std_logic := '0';
    signal clk_div_cnt          : integer range 0 to 3 := 0;
    signal x_pos                : integer range 0 to H_ACTIVE - 1;
    signal y_pos                : integer range 0 to V_ACTIVE - 1;

begin

    process(clk100, pixel_clk_en)
    begin
        if rising_edge(clk100) and pixel_clk_en = '1' then
            v_pos <= CENTER_Y - (to_integer(cordic_val) * AMPLITUDE_SCALE / 2048);
            if v_cnt = v_pos then
                wave_bit <= '1'; 
            else 
                 wave_bit <= '0';
            end if;
    
            x_pos <= CENTER_X + (to_integer(cosine_val) * RADIUS / 2048);
            y_pos <= CENTER_Y - (to_integer(sine_val) * RADIUS / 2048);
            
            if (h_cnt = x_pos) and (v_cnt = y_pos) then
                vec_bit <= '1'; 
            else
                 vec_bit <= '0';
            end if;
            
            if v_pos < 0 then
                v_pos <= 0;
            elsif v_pos >= V_ACTIVE then
                v_pos <= V_ACTIVE - 1;
            end if;
            
            if x_pos < 0 then
                x_pos <= 0;
            elsif x_pos >= H_ACTIVE then
                x_pos <= H_ACTIVE - 1;
            end if;
            
            if y_pos < 0 then
                y_pos <= 0;
            elsif y_pos >= V_ACTIVE then
                y_pos <= V_ACTIVE -1;
            end if;
            
        end if;
    end process;

    process(clk100)
    begin
        if rising_edge(clk100) then
            if reset = '0' then
                clk_div_cnt <= 0;
                pixel_clk_en <= '0';
            else
                if clk_div_cnt = 3 then
                    clk_div_cnt <= 0;
                    pixel_clk_en <= '1';
                else
                    clk_div_cnt <= clk_div_cnt + 1;
                    pixel_clk_en <= '0';
                end if;
            end if;
        end if;
    end process;

    process(clk100, pixel_clk_en)
    begin
        if rising_edge(clk100) then 
            if reset = '0' then
                h_cnt <= 0;
                v_cnt <= 0;
            elsif pixel_clk_en = '1' then 
                if h_cnt = H_TOTAL - 1 then
                    h_cnt <= 0;
                    if v_cnt = V_TOTAL - 1 then
                        v_cnt <= 0;
                    else
                        v_cnt <= v_cnt + 1;
                    end if;
                else
                    h_cnt <= h_cnt + 1;
                end if;
            end if;
        end if;
    end process;

    hsync <= '0' when (h_cnt >= H_ACTIVE + H_FP and h_cnt < H_ACTIVE + H_FP + H_SYNC) else '1';
    vsync <= '0' when (v_cnt >= V_ACTIVE + V_FP and v_cnt < V_ACTIVE + V_FP + V_SYNC) else '1';
    active_video <= '1' when (h_cnt < H_ACTIVE and v_cnt < V_ACTIVE) else '0';

   process(clk100)
    begin
        if rising_edge(clk100) and pixel_clk_en = '1' then
            if active_video = '1' then
                if (h_cnt = CENTER_X) or (h_cnt = CENTER_X + 1) or (v_cnt = CENTER_Y) or (v_cnt = CENTER_Y + 1) then
                    pixel_r <= "11";
                    pixel_g <= "00";
                    pixel_b <= "00";
                elsif mode = '0' and wave_bit = '1' then
                    pixel_r <= "00";
                    pixel_g <= "11";
                    pixel_b <= "00";
                elsif mode = '1' and vec_bit = '1' then
                    pixel_r <= "00";
                    pixel_g <= "00";
                    pixel_b <= "11";
                else
                    pixel_r <= "00";
                    pixel_g <= "00";
                    pixel_b <= "00";
                end if;
            else
                pixel_r <= "00";
                pixel_g <= "00";
                pixel_b <= "00";
            end if;
        end if;
    end process;

    r <= pixel_r;
    g <= pixel_g;
    b <= pixel_b;

end architecture;
