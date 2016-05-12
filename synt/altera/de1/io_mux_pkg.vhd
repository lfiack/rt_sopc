library ieee;
use ieee.std_logic_1164.all;

package io_mux_pkg is
	component io_mux is
		generic (
			WIDTH : positive := 8
		);
		port (
			-- Function A (typically GPIO)
			a_din : out std_logic_vector(WIDTH-1 downto 0);
			a_dout : in std_logic_vector(WIDTH-1 downto 0);
			a_dout_en : in std_logic_vector(WIDTH-1 downto 0);

			-- Function B (Timer A, ...)
			b_din : out std_logic_vector(WIDTH-1 downto 0);
			b_dout : in std_logic_vector(WIDTH-1 downto 0);
			b_dout_en : in std_logic_vector(WIDTH-1 downto 0);

			-- IO Cell
			io_din : in std_logic_vector(WIDTH-1 downto 0);
			io_dout : out std_logic_vector(WIDTH-1 downto 0);
			io_dout_en : out std_logic_vector(WIDTH-1 downto 0);

			-- Function selection (0=A, 1=B)
			sel : in std_logic_vector(WIDTH-1 downto 0)
		);
	end component io_mux;
end package io_mux_pkg;
