library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture rtl of per_template is
	-- Decoder bit width (defines how many bits are considered for address decoding)
	constant DEC_WD : natural := 3;
	constant REG_NB : natural := 2**(DEC_WD-1);

	type reg_file_t is array (natural range <>) of std_logic_vector(15 downto 0);

	signal addr_match : std_logic;
	signal per_select : std_logic;

	signal local_address : integer;

	signal per_wren : std_logic;
	signal reg_write : std_logic;
	signal reg_read : std_logic;

	signal reg_file : reg_file_t(0 to REG_NB-1);
begin
	-- Are we beeing talked to ?
	addr_match <= '1' when (per_addr(13 downto DEC_WD-1) = BASE_ADDR(14 downto DEC_WD)) else '0';
	per_select <= addr_match and per_en;

--	local_address <= integer(to_unsigned(per_addr(DEC_WD-2 downto 0)));
	local_address <= to_integer(unsigned(per_addr(DEC_WD-2 downto 0)));

	per_wren <= per_we(1) and per_we(0);

	reg_write <= per_select and per_wren;
	reg_read <= per_select and not per_wren;

	p_reg_file : process (mclk, puc_rst)
	begin
		if (puc_rst = '1') then
			for i in 0 to REG_NB-1 loop --(DEC_WD-2 downto 0) loop
				reg_file(i) <= (others => '0');
			end loop;
		elsif rising_edge(mclk) then
			if (reg_write) then
				if (per_we(1) = '1') then
					reg_file(local_address)(15 downto 8) <= per_din(15 downto 8);
				end if;
				if (per_we(0) = '1') then
					reg_file(local_address)(7 downto 0) <= per_din(7 downto 0);
				end if;
			end if;
		end if;
	end process p_reg_file;

	per_dout <= reg_file(local_address) when reg_read = '1' else (others => '0');
end architecture rtl;
