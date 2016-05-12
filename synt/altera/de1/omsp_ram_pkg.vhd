library ieee;
use ieee.std_logic_1164.all;

package omsp_ram_pkg is
	component ram16x512 is
		port (
			address : in std_logic_vector(8 downto 0);
	        clken : in std_logic;
	        clock : in std_logic;
	        data : in std_logic_vector(15 downto 0);
	        q : out std_logic_vector(15 downto 0);
	        wren : in std_logic;
	        byteena : in std_logic_vector(1 downto 0)
		);
	end component ram16x512;

	component ram16x2048 is
		port (
			address : in std_logic_vector(10 downto 0);
	        clken : in std_logic;
	        clock : in std_logic;
	        data : in std_logic_vector(15 downto 0);
	        q : out std_logic_vector(15 downto 0);
	        wren : in std_logic;
	        byteena : in std_logic_vector(1 downto 0)
		);
	end component ram16x2048;
end package omsp_ram_pkg;
