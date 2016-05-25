library ieee;
use ieee.std_logic_1164.all;

library work;
use work.per_iface_pkg.all;

entity per_iface_tb is
end entity per_iface_tb;

architecture testbench of per_iface_tb is
--	constant MCLK_FREQ : real := 24_000_000;

	constant TB_BASE_ADDR : std_logic_vector(14 downto 0) := 15x"0180";
	constant TB_REG_NB : positive := 4;

	signal tb_per_dout : std_logic_vector(15 downto 0);   -- Peripheral data output
	signal tb_mclk : std_logic;                           -- Main system clock
	signal tb_per_addr : std_logic_vector(13 downto 0);   -- Peripheral address
	signal tb_per_din : std_logic_vector(15 downto 0);    -- Peripheral data input
	signal tb_per_en : std_logic;                         -- Peripheral enable (high active)
	signal tb_per_we : std_logic_vector(1 downto 0);      -- Peripheral write enable (high active)
	signal tb_puc_rst : std_logic;                        -- Main system reset

	signal tb_reg_file_wren : std_logic_vector(0 to TB_REG_NB-1);   -- Registers file write enable (high active)
	signal tb_reg_out : std_logic_vector(15 downto 0);
	signal tb_reg_file_in : reg_file_t(0 to TB_REG_NB-1);    -- Registers file input

	signal reg_file : reg_file_t(0 to TB_REG_NB-1);

	signal simu_ended : boolean := false;
begin
	-- @0x0180 -> 0x0187
	cut: per_iface
		generic map (
			-- Register base address (must be aligned to decoder bit width)
			BASE_ADDR => TB_BASE_ADDR,
			-- Number of registers
			REG_NB => TB_REG_NB
		)
		port map (
			per_dout => tb_per_dout,
	
			mclk => tb_mclk,
			per_addr => tb_per_addr,
			per_din => tb_per_din,
			per_en => tb_per_en,
			per_we => tb_per_we,
			puc_rst => tb_puc_rst,

			reg_file_wren => tb_reg_file_wren,
			reg_out => tb_reg_out,
			reg_file_in => tb_reg_file_in
		);

	p_reg_file : process (tb_puc_rst, tb_mclk)
	begin
		if (tb_puc_rst = '1') then
			for i in reg_file'range loop
				reg_file(i) <= (others => '0');
			end loop;
		elsif rising_edge(tb_mclk) then
			for i in reg_file'range loop
				if (tb_reg_file_wren(i) = '1') then
					reg_file(i) <= tb_reg_out;
				end if;
			end loop;
		end if;
	end process p_reg_file;

	tb_reg_file_in <= reg_file;

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

		per_write(15x"0180", x"1234");
		per_read(15x"0180");

		per_write(15x"0200", x"5678");
		per_read(15x"0200");
		
		simu_ended <= true;
		wait;
	end process p_testbench;
end architecture testbench;
