library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_top_tb is
-- Testbench has no ports
end entity;

architecture behavior of vga_top_tb is

    -- Component declaration for your VGA module under test
    component vga_top
        port (
        clk100    : in  std_logic;
        reset    : in  std_logic;
        mode     : in  std_logic; -- '0' = waveform, '1' = vector mode
        wave_bit : in  std_logic; -- from CORDIC
        vec_bit  : in  std_logic; -- from CORDIC or vector endpoint strobe
        r        : out std_logic_vector(1 downto 0); -- VGA Red[1:0]
        g        : out std_logic_vector(1 downto 0); -- VGA Green[1:0]
        b        : out std_logic_vector(1 downto 0); -- VGA Blue[1:0]
        hsync    : out std_logic;
        vsync    : out std_logic
        );
    end component;

    -- Testbench signals
    signal clk100_tb   : std_logic := '0';
    signal reset_tb    : std_logic := '1';
    signal mode_tb     : std_logic := '0';  -- start in waveform mode
    signal sine_bit_tb : std_logic := '0';
    signal cos_bit_tb  : std_logic := '0';
    signal r_tb        : std_logic_vector(1 downto 0);
    signal g_tb        : std_logic_vector(1 downto 0);
    signal b_tb        : std_logic_vector(1 downto 0);
    signal hsync_tb    : std_logic;
    signal vsync_tb    : std_logic;

    -- Constants for simulation timing
    constant CLK_PERIOD : time := 10 ns; -- 100 MHz

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: vga_top
        port map (
            clk100   => clk100_tb,
            reset    => reset_tb,
            mode     => mode_tb,
            wave_bit => sine_bit_tb,
            vec_bit  => cos_bit_tb,
            r        => r_tb,
            g        => g_tb,
            b        => b_tb,
            hsync    => hsync_tb,
            vsync    => vsync_tb
        );

    -- Clock generation: 100MHz
    clk_process : process
    begin
        while true loop
            clk100_tb <= '0';
            wait for CLK_PERIOD/2;
            clk100_tb <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process;

    -- Reset generation
    reset_process : process
    begin
        reset_tb <= '1';
        wait for 100 ns;
        reset_tb <= '0';
        wait;
    end process;

    -- Stimulus process: drives sine_bit and cos_bit signals and mode toggling
    stimulus_process : process
        -- To simulate pixel clock enable, we assume pixel_clk_en triggers every 4 cycles of clk100.
        -- We'll artificially toggle sine_bit and cos_bit accordingly to simulate waveform and vector traces.
        
        -- A simple counter to simulate horizontal pixel counter for 640 pixels
        variable pixel_x : integer := 0;
    begin
        wait until reset_tb = '0';  -- wait for reset release
        mode_tb <= '1'; -- Start in Vector mode

        -- Simulate 3 frames of waveform mode with sine_bit toggling as a simple pattern
        for frame in 0 to 10 loop
            for i in 0 to 639 loop -- simulate 640 pixels per line
                -- Generate sine_bit pattern: toggle bit every 10 pixels to simulate wave dots
                if (i mod 20) < 10 then
                    sine_bit_tb <= '1';
                else
                    sine_bit_tb <= '0';
                end if;
                cos_bit_tb <= '0';
                wait for CLK_PERIOD*4;  -- Wait 4 clock cycles = 25 MHz pixel clock enable period
            end loop;
        end loop;

        -- Switch to waveform Mode
        mode_tb <= '0';

        -- Simulate vector endpoint pulses at fixed pixel_x, pixel_y - simplified example
        -- For simplicity, we will simulate just the vector endpoint strobe at CENTER_X, CENTER_Y. 
        -- Since we don't have internal access to counters here, just pulse cos_bit every ~800*525 pixels.

        for frame in 0 to 3 loop
            for i in 0 to 639 loop
                sine_bit_tb <= '0';
                -- Pulse cos_bit once every 100 cycles to simulate vector endpoint trigger
                if (i = 320) then
                    cos_bit_tb <= '1';
                else
                    cos_bit_tb <= '0';
                end if;
                wait for CLK_PERIOD*4;  -- pixel clock enable period
            end loop;
        end loop;

        -- End simulation
        wait for 1 us;
        assert false report "End of simulation" severity note;
        wait;
    end process;

end architecture;
