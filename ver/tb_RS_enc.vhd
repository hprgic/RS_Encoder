library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library rs_enc_lib;
use rs_enc_lib.all;

entity tb_RS_enc is
   generic (
      C_RANDOM_READY : integer := 0;   -- 0=always ready, 1=random backpressure
      C_RANDOM_INPUT : integer := 0    -- 0=incrementing, 1=random
   );
end entity;

architecture sim of tb_RS_enc is

   --------------------------------------------------------------------
   -- Constants
   --------------------------------------------------------------------
   constant C_SYMB_W : integer := 26;
   constant C_CODE_N : integer := 255;
   constant C_SYMB_K : integer := 223;

   constant C_PARITY : integer := C_CODE_N - C_SYMB_K;

   --------------------------------------------------------------------
   -- Clock
   --------------------------------------------------------------------
   constant CLK_PERIOD : time := 10 ns;

   signal clk : std_logic := '0';
   signal rst : std_logic := '0';

   --------------------------------------------------------------------
   -- DUT interface
   --------------------------------------------------------------------
   signal in_valid  : std_logic := '0';
   signal in_ready  : std_logic;

   signal in_data   : std_logic_vector(C_SYMB_W-1 downto 0) := (others=>'0');

   signal out_valid : std_logic;
   signal out_ready : std_logic := '1';

   signal out_data  : std_logic_vector(C_PARITY*C_SYMB_W-1 downto 0);

begin


   --------------------------------------------------------------------
   -- DUT
   --------------------------------------------------------------------
   dut : entity rs_enc_lib.rs_composite_parity_gen
   generic map
   (
      C_SPARE_FF => true,
      C_MUL_ARCH => 2,
      C_USE_COMP => true,
      C_SYMB_W   => C_SYMB_W,
      C_FIRST_ROOT => 0,
      C_CODE_N   => C_CODE_N,
      C_SYMB_K   => C_SYMB_K
   )
   port map
   (
      clk       => clk,
      rst       => rst,

      in_valid  => in_valid,
      in_ready  => in_ready,
      in_data   => in_data,

      out_valid => out_valid,
      out_ready => out_ready,
      out_data  => out_data
   );

   --------------------------------------------------------------------
   -- Clock generation
   --------------------------------------------------------------------
   p_clk : process
   begin

      clk <= '0';
      wait for 10*CLK_PERIOD;

      -- run
      for I in 0 to 49 loop
         clk <= '0'; wait for CLK_PERIOD/2;
         clk <= '1'; wait for CLK_PERIOD/2;
      end loop;

      -- stop
      clk <= '0';
      wait for 5*CLK_PERIOD;

      -- run again forever
      while true loop
         clk <= '0'; wait for CLK_PERIOD/2;
         clk <= '1'; wait for CLK_PERIOD/2;
      end loop;

   end process;


   --------------------------------------------------------------------
   -- Reset generation
   --------------------------------------------------------------------
   p_rst : process
   begin

      rst <= '1';

      -----------------------------------------------------------------
      -- Initial reset
      -----------------------------------------------------------------
      wait for 5*CLK_PERIOD;

      rst <= '0';

      -----------------------------------------------------------------
      -- Later reset pulse
      -----------------------------------------------------------------
      wait for 20*CLK_PERIOD;

      rst <= '1';
      wait for 2*CLK_PERIOD;
      rst <= '0';

      wait;

   end process;

   --------------------------------------------------------------------
   -- Stimulus
   --------------------------------------------------------------------
   p_stimulus : process
   variable data_cnt : unsigned(C_SYMB_W-1 downto 0);
   variable seed     : unsigned(31 downto 0);
   variable tmp      : unsigned(63 downto 0);
begin
   in_valid <= '0';
   in_data  <= (others => '0');

   loop
      ----------------------------------------------------------------
      -- Wait for reset release
      ----------------------------------------------------------------
      wait until rst = '0';

      data_cnt := (others => '0');
      seed     := resize(to_unsigned(12345, 16), seed'length);

      in_valid <= '1';

      ----------------------------------------------------------------
      -- Run until next reset
      ----------------------------------------------------------------
      while rst = '0' loop
         wait until rising_edge(clk);

         if rst = '1' then
            exit;
         end if;

         if in_ready = '1' then
            if C_RANDOM_INPUT = 0 then
               in_data  <= std_logic_vector(resize(data_cnt, C_SYMB_W));
               data_cnt := resize(data_cnt + 1, data_cnt'length);
            else
               ----------------------------------------------------------------
               -- 32-bit LCG:
               -- seed = seed * 1103515245 + 12345
               ----------------------------------------------------------------
               tmp :=
                  resize(seed, tmp'length) *
                  resize(to_unsigned(1103515245, 32), tmp'length) +
                  resize(to_unsigned(12345, 16), tmp'length);

               seed := resize(tmp, seed'length);

               in_data <= std_logic_vector(
                             resize(seed, C_SYMB_W)
                          );
            end if;
         end if;
      end loop;

      ----------------------------------------------------------------
      -- Reset active
      ----------------------------------------------------------------
      in_valid <= '0';
      in_data  <= (others => '0');
   end loop;
end process;
   
   --------------------------------------------------------------------
   -- Output ready generation
   --------------------------------------------------------------------
   p_out_ready : process
      variable seed       : integer := 12345;
      variable hold_cycles : integer;
   begin
      if C_RANDOM_READY = 0 then
         out_ready <= '1';
         wait;
      end if;
      loop
         seed := (seed * 1103515245 + 12345) mod 2147483647;
         ----------------------------------------------------------------
         -- Ready burst
         ----------------------------------------------------------------
         out_ready <= '1';
         hold_cycles := (seed mod 8) + 1;
         for I in 1 to hold_cycles loop
            wait until rising_edge(clk);
         end loop;
         ----------------------------------------------------------------
         -- Backpressure burst
         ----------------------------------------------------------------
         out_ready <= '0';
         hold_cycles := (seed mod 4) + 1;
         for I in 1 to hold_cycles loop
            wait until rising_edge(clk);
         end loop;
      end loop;
   end process;

end architecture;