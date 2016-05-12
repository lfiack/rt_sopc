library ieee;
use ieee.std_logic_1164.all;

package omsp_gpio_pkg is
	component omsp_gpio is
		generic (
			P1_EN : std_logic_vector(0 downto 0) := "1";   -- Enable Port 1
			P2_EN : std_logic_vector(0 downto 0) := "1";   -- Enable Port 2
			P3_EN : std_logic_vector(0 downto 0) := "0";   -- Enable Port 3
			P4_EN : std_logic_vector(0 downto 0) := "0";   -- Enable Port 4
			P5_EN : std_logic_vector(0 downto 0) := "0";   -- Enable Port 5
			P6_EN : std_logic_vector(0 downto 0) := "0"    -- Enable Port 6
		);
		port (
			irq_port1 : out std_logic;                         -- Port 1 interrupt
			irq_port2 : out std_logic;                         -- Port 2 interrupt
			p1_dout : out std_logic_vector(7 downto 0);        -- Port 1 data output
			p1_dout_en : out std_logic_vector(7 downto 0);     -- Port 1 data output enable
			p1_sel : out std_logic_vector(7 downto 0);         -- Port 1 function select
			p2_dout : out std_logic_vector(7 downto 0);        -- Port 2 data output
			p2_dout_en : out std_logic_vector(7 downto 0);     -- Port 2 data output enable
			p2_sel : out std_logic_vector(7 downto 0);         -- Port 2 function select
			p3_dout : out std_logic_vector(7 downto 0);        -- Port 3 data output
			p3_dout_en : out std_logic_vector(7 downto 0);     -- Port 3 data output enable
			p3_sel : out std_logic_vector(7 downto 0);         -- Port 3 function select
			p4_dout : out std_logic_vector(7 downto 0);        -- Port 4 data output
			p4_dout_en : out std_logic_vector(7 downto 0);     -- Port 4 data output enable
			p4_sel : out std_logic_vector(7 downto 0);         -- Port 4 function select
			p5_dout : out std_logic_vector(7 downto 0);        -- Port 5 data output
			p5_dout_en : out std_logic_vector(7 downto 0);     -- Port 5 data output enable
			p5_sel : out std_logic_vector(7 downto 0);         -- Port 5 function select
			p6_dout : out std_logic_vector(7 downto 0);        -- Port 6 data output
			p6_dout_en : out std_logic_vector(7 downto 0);     -- Port 6 data output enable
			p6_sel : out std_logic_vector(7 downto 0);         -- Port 6 function select
			per_dout : out std_logic_vector(15 downto 0);      -- Peripheral data output

			mclk : in std_logic;                               -- Main system clock
			p1_din : in std_logic_vector(7 downto 0);          -- Port 1 data input
			p2_din : in std_logic_vector(7 downto 0);          -- Port 2 data input
			p3_din : in std_logic_vector(7 downto 0);          -- Port 3 data input
			p4_din : in std_logic_vector(7 downto 0);          -- Port 4 data input
			p5_din : in std_logic_vector(7 downto 0);          -- Port 5 data input
			p6_din : in std_logic_vector(7 downto 0);          -- Port 6 data input
			per_addr : in std_logic_vector(13 downto 0);       -- Peripheral address
			per_din : in std_logic_vector(15 downto 0);        -- Peripheral data input
			per_en : in std_logic;                             -- Peripheral enable (high active)
			per_we : in std_logic_vector(1 downto 0);          -- Peripheral write enable (high active)
			puc_rst : in std_logic                             -- Main system reset
		);
	end component omsp_gpio;
end package omsp_gpio_pkg;
