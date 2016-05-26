library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pwm_pkg.all;

entity pwm is
	port (
		clock : in std_logic;
		reset : in std_logic;
		enable : in std_logic;
		
		period : in unsigned(15 downto 0);
		duty : in unsigned(15 downto 0);
		dead_band : in unsigned(15 downto 0);

		pwm_a : out std_logic;
		pwm_b : out std_logic
	);
end entity pwm;
