library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture rtl of pwm is
	signal counter : unsigned(15 downto 0) := (others => '0');
	
	signal local_pwm_a : std_logic;
	signal local_pwm_b : std_logic;

	signal reg_wren : std_logic;
	signal reg_enable : std_logic;
	signal reg_period: unsigned(15 downto 0);
	signal reg_duty : unsigned(15 downto 0);
	signal reg_dead_band : unsigned(15 downto 0);
begin
	reg_wren <= '1' when (reg_enable = '0') or (counter = reg_period) else '0';

	p_regs : process (reset, clock)
	begin
		if (reset = '1') then
			reg_enable <= '0';
			reg_duty <= (others => '0');
			reg_period <= (others => '0');
			reg_dead_band <= (others => '0');
		elsif rising_edge(clock) then
			if (reg_enable = '0') then
				reg_period <= period;
				reg_dead_band <= dead_band;
			end if;
			if (reg_wren = '1') then
				reg_enable <= enable;
				reg_duty <= duty;
			end if;
		end if;
	end process p_regs;

	p_counter : process (reset, clock)
	begin
		if (reset = '1') then
			counter <= (others => '0');
		elsif rising_edge(clock) then
			if (reg_enable = '1') then
				if (counter < reg_period) then
					counter <= counter + 1;
				else
					counter <= (others => '0');
				end if;
			end if;
		end if;
	end process p_counter;

	local_pwm_a <= '1' when (counter < reg_duty) else '0';
	local_pwm_b <= '1' when ((counter < reg_period-reg_dead_band) and (counter > reg_duty+reg_dead_band)) else '0';

	pwm_a <= local_pwm_a when (reg_enable = '1') else '0';
	pwm_b <= local_pwm_b when (reg_enable = '1') else '0';
end architecture rtl;
