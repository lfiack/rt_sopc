library ieee;
use ieee.std_logic_1164.all;

library work;
use work.per_iface_pkg.all;

entity per_iface is
	generic (
		-- Register base address (must be aligned to decoder bit width)
		BASE_ADDR : std_logic_vector(14 downto 0) := 15x"0180";
		-- Number of registers
		REG_NB : positive := 4
	);
	port (
		per_dout : out std_logic_vector(15 downto 0);         -- Peripheral data output
	
		mclk : in std_logic;                                  -- Main system clock
		per_addr : in std_logic_vector(13 downto 0);          -- Peripheral address
		per_din : in std_logic_vector(15 downto 0);           -- Peripheral data input
		per_en : in std_logic;                                -- Peripheral enable (high active)
		per_we : in std_logic_vector(1 downto 0);             -- Peripheral write enable (high active)
		puc_rst : in std_logic;                               -- Main system reset

		reg_file_wren : out std_logic_vector(0 to REG_NB-1);  -- Registers file write enable (high active)
		reg_out : out std_logic_vector(15 downto 0);          -- Registers file output
		reg_file_in : in reg_file_t(0 to REG_NB-1)            -- Registers file input
	);
end entity per_iface;
