library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.log2_pkg.all;

architecture rtl of per_iface is
	-- Decoder bit width (defines how many bits are considered for address decoding)
	constant DEC_WD : natural := log2ceil(REG_NB) + 1;

	signal addr_match : std_logic;
	signal per_select : std_logic;

	signal local_address : integer range 0 to REG_NB-1;

	signal per_wren : std_logic;
	signal reg_write : std_logic;
	signal reg_read : std_logic;
begin
	-- Are we beeing talked to ?
	addr_match <= '1' when (per_addr(13 downto DEC_WD-1) = BASE_ADDR(14 downto DEC_WD)) else '0';
	per_select <= addr_match and per_en;

	-- Local address decoder
	local_address <= to_integer(unsigned(per_addr(DEC_WD-2 downto 0)));

	-- Enable a write
	per_wren <= per_we(1) and per_we(0);

	-- A register is being written
	reg_write <= per_select and per_wren;
	-- A register is being read
	reg_read <= per_select and not per_wren;

	-- Connections with the peripheral
	g_demux: for i in reg_file_wren'range generate
		reg_file_wren(i) <= reg_write when (i = local_address) else '0';
	end generate g_demux;
	reg_out <= per_din;
	per_dout <= reg_file_in(local_address) when reg_read = '1' else (others => '0');
end architecture rtl;
