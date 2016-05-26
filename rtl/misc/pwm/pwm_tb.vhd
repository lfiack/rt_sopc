library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pwm_pkg.all;

entity pwm_tb is
end entity pwm_tb;

architecture testbench of pwm_tb is
	signal tb_clock : std_logic;
	signal tb_reset : std_logic;
	signal tb_enable : std_logic;

	signal tb_period : unsigned(15 downto 0);
	signal tb_duty : unsigned(15 downto 0);
	signal tb_dead_band : unsigned(15 downto 0);

	signal tb_pwm_a : std_logic;
	signal tb_pwm_b : std_logic;

	signal simu_ended : boolean := false;
begin
	cut: pwm
		port map (
			clock => tb_clock,
			reset => tb_reset,
			enable => tb_enable,
			
			period => tb_period,
			duty => tb_duty,
			dead_band => tb_dead_band,
	
			pwm_a => tb_pwm_a,
			pwm_b => tb_pwm_b
		);

	p_clock: process
	begin
		while (simu_ended = false) loop
			tb_clock <= '0'; wait for 5 ns;
			tb_clock <= '1'; wait for 5 ns;
		end loop;
		wait;
	end process p_clock;

	p_testbench: process
	begin
		tb_reset <= '0';

		tb_enable <= '0';
		tb_period <= (others => '0');
		tb_duty <= (others => '0');
		tb_dead_band <= (others => '0');

		tb_reset <= '1' after 2 ns;

		for i in 0 to 9 loop
			wait until rising_edge(tb_clock);
		end loop;

		tb_reset <= '0' after 2 ns;

		for i in 0 to 9 loop
			wait until rising_edge(tb_clock);
		end loop;

		tb_period <= x"0040" after 2 ns;
		tb_duty <= x"0010" after 2 ns;
		tb_dead_band <= x"0002" after 2 ns;
		
		for i in 0 to 9 loop
			wait until rising_edge(tb_clock);
		end loop;

		tb_enable <= '1' after 2 ns;

		for i in 0 to 128 loop
			wait until rising_edge(tb_clock);
		end loop;

		tb_period <= x"0040" after 2 ns;
		tb_duty <= x"0020" after 2 ns;
		tb_dead_band <= x"0002" after 2 ns;

		for i in 0 to 80 loop
			wait until rising_edge(tb_clock);
		end loop;

		tb_period <= x"0040" after 2 ns;
		tb_duty <= x"0030" after 2 ns;
		tb_dead_band <= x"0002" after 2 ns;

		for i in 0 to 168 loop
			wait until rising_edge(tb_clock);
		end loop;

		tb_enable <= '0' after 2 ns;

		for i in 0 to 64 loop
			wait until rising_edge(tb_clock);
		end loop;

		simu_ended <= true;
		wait;
	end process p_testbench;
end architecture testbench;
