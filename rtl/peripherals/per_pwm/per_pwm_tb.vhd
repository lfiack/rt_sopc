library ieee;
use ieee.std_logic_1164.all;

library work;
use work.per_pwm_pkg.all;

entity per_pwm_tb is
end entity per_pwm_tb;

architecture testbench of per_pwm_tb is
--	constant MCLK_FREQ : real := 24_000_000;

	constant TB_BASE_ADDR : std_logic_vector(14 downto 0) := 15x"0100";

	signal tb_per_dout : std_logic_vector(15 downto 0);   -- Peripheral data output
	signal tb_mclk : std_logic;                           -- Main system clock
	signal tb_per_addr : std_logic_vector(13 downto 0);   -- Peripheral address
	signal tb_per_din : std_logic_vector(15 downto 0);    -- Peripheral data input
	signal tb_per_en : std_logic;                         -- Peripheral enable (high active)
	signal tb_per_we : std_logic_vector(1 downto 0);      -- Peripheral write enable (high active)
	signal tb_puc_rst : std_logic;                        -- Main system reset

	signal tb_pwm_a : std_logic;
	signal tb_pwm_b : std_logic;

	signal simu_ended : boolean := false;

begin
	-- @0x0180 -> 0x0187
	cut: per_pwm
		generic map (
			-- Register base address (must be aligned to decoder bit width)
			BASE_ADDR => TB_BASE_ADDR
		)
		port map (
			per_dout => tb_per_dout,
	
			mclk => tb_mclk,
			per_addr => tb_per_addr,
			per_din => tb_per_din,
			per_en => tb_per_en,
			per_we => tb_per_we,
			puc_rst => tb_puc_rst,

			pwm_a => tb_pwm_a,
			pwm_b => tb_pwm_b
		);

	p_mclk: process
	begin
		while (simu_ended = false) loop
			tb_mclk <= '0'; wait for 5 ns;
			tb_mclk <= '1'; wait for 5 ns;
		end loop;
		wait;
	end process p_mclk;

	p_testbench: process
		procedure per_write (
			per_addr : std_logic_vector(14 downto 0);
			per_din : std_logic_vector(15 downto 0)
		) is
		begin
			tb_per_addr <= per_addr(14 downto 1) after 2 ns;
			tb_per_din <= per_din after 2 ns;
			tb_per_en <= '1' after 2 ns;
			tb_per_we <= "11" after 2 ns;

			wait until rising_edge(tb_mclk);

			tb_per_addr <= (others => '0') after 2 ns;
			tb_per_din <= (others => '0') after 2 ns;
			tb_per_en <= '0' after 2 ns;
			tb_per_we <= "00" after 2 ns;
		end procedure per_write;

		procedure per_read (
			per_addr : std_logic_vector(14 downto 0)
		) is
		begin
			tb_per_addr <= per_addr(14 downto 1) after 2 ns;
			tb_per_en <= '1' after 2 ns;
			tb_per_we <= "00" after 2 ns;

			wait until rising_edge(tb_mclk);

			tb_per_addr <= (others => '0') after 2 ns;
			tb_per_en <= '0' after 2 ns;
			tb_per_we <= "00" after 2 ns;
		end procedure per_read;
	begin
		tb_puc_rst <= '0';

		tb_per_addr <= (others => '0');
		tb_per_din <= (others => '0');
		tb_per_en <= '0';
		tb_per_we <= (others => '0');

		tb_puc_rst <= '1' after 2 ns;

		for i in 0 to 9 loop
			wait until rising_edge(tb_mclk);
		end loop;

		tb_puc_rst <= '0' after 2 ns;

		for i in 0 to 9 loop
			wait until rising_edge(tb_mclk);
		end loop;

		per_write(15x"0102", x"0040");
		per_read(15x"0102");

		per_write(15x"0104", x"0010");
		per_read(15x"0104");

		per_write(15x"0106", x"0002");
		per_read(15x"0106");

		per_write(15x"0100", x"0001");
		per_read(15x"0100");

		for i in 0 to 128 loop
			wait until rising_edge(tb_mclk);
		end loop;

		per_write(15x"0104", x"0020");
		per_read(15x"0104");

		for i in 0 to 128 loop
			wait until rising_edge(tb_mclk);
		end loop;

		per_write(15x"0104", x"0030");
		per_read(15x"0104");

		for i in 0 to 128 loop
			wait until rising_edge(tb_mclk);
		end loop;

		per_write(15x"0100", x"0000");
		per_read(15x"0100");

		for i in 0 to 256 loop
			wait until rising_edge(tb_mclk);
		end loop;
		
		simu_ended <= true;
		wait;
	end process p_testbench;
end architecture testbench;
