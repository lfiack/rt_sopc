library ieee;
use ieee.std_logic_1164.all;

package omsp_uart_pkg is
	-- Can't use a previously declarated parameter in generic as in verilog :(
	constant C_DEC_WD : positive := 3;

	component omsp_uart is
		generic (
			-- Register base address (must be aligned to decoder bit width)
			BASE_ADDR : std_logic_vector(14 downto 0) := x"0080";
			-- Decoder bit width (defines how many bits are considered for address decoding)
			DEC_WD : positive := 3;
			-- Register addresses offset
			CTRL : std_logic_vector(C_DEC_WD-1 downto 0) := 3x"0";
			STATUS : std_logic_vector(C_DEC_WD-1 downto 0) := 3x"1";
			BAUD_LO : std_logic_vector(C_DEC_WD-1 downto 0) := 3x"2";
			BAUD_HI : std_logic_vector(C_DEC_WD-1 downto 0) := 3x"3";
			DATA_TX : std_logic_vector(C_DEC_WD-1 downto 0) := 3x"4";
			DATA_RX : std_logic_vector(C_DEC_WD-1 downto 0) := 3x"5"
		);
		port (
			irq_uart_rx : out std_logic;                   -- UART receive interrupt
			irq_uart_tx : out std_logic;                   -- UART transmit interrupt
			per_dout : out std_logic_vector(15 downto 0);  -- Peripheral data output
			uart_txd : out std_logic;                      -- UART Data Transmit (TXD)

			mclk : in std_logic;                           -- Main system clock
			per_addr : in std_logic_vector(13 downto 0);   -- Peripheral address
			per_din : in std_logic_vector(15 downto 0);    -- Peripheral data input
			per_en : in std_logic;                         -- Peripheral enable (high active)
			per_we : in std_logic_vector(1 downto 0);      -- Peripheral write enable (high active)
			puc_rst : in std_logic;                        -- Main system reset
			smclk_en : in std_logic;                       -- SMCLK enable (from CPU)
			uart_rxd : in std_logic                        -- UART Data Receive (RXD)
		);
	end component omsp_uart;
end package omsp_uart_pkg;
