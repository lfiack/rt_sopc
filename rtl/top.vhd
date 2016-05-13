library ieee;
use ieee.std_logic_1164.all;

library work;
use work.openMSP430_pkg.all;
use work.omsp_gpio_pkg.all;
use work.omsp_timerA_pkg.all;
use work.omsp_ram_pkg.all;
use work.io_mux_pkg.all;

entity top is
	port (
		-- Clock Input
		CLOCK_24 : in std_logic_vector(1 downto 0);
		CLOCK_27 : in std_logic_vector(1 downto 0);
		CLOCK_50 : in std_logic;
		EXT_CLOCK : in std_logic;
		-- Push Button
		KEY : in std_logic_vector(3 downto 0);
		-- DPDT Switch
		SW : in std_logic_vector(9 downto 0);
		-- 7-SEG Display
		HEX0 : out std_logic_vector(6 downto 0);
		HEX1 : out std_logic_vector(6 downto 0);
		HEX2 : out std_logic_vector(6 downto 0);
		HEX3 : out std_logic_vector(6 downto 0);
		-- LED
		LEDG : out std_logic_vector(7 downto 0);
		LEDR : out std_logic_vector(9 downto 0);
		-- UART
		UART_TXD : out std_logic;
		UART_RXD : in std_logic;
		-- SDRAM Interface
		DRAM_DQ : inout std_logic_vector(15 downto 0);
		DRAM_ADDR : out std_logic_vector(11 downto 0);
		DRAM_LDQM : out std_logic;
		DRAM_UDQM : out std_logic;
		DRAM_WE_N : out std_logic;
		DRAM_CAS_N : out std_logic;
		DRAM_RAS_N : out std_logic;
		DRAM_CS_N : out std_logic;
		DRAM_BA_0 : out std_logic;
		DRAM_BA_1 : out std_logic;
		DRAM_CLK : out std_logic;
		DRAM_CKE : out std_logic;
		-- Flash Interface
		FL_DQ : inout std_logic_vector(7 downto 0);
		FL_ADDR : out std_logic_vector(21 downto 0);
		FL_WE_N : out std_logic;
		FL_RST_N : out std_logic;
		FL_OE_N : out std_logic;
		FL_CE_N : out std_logic;
		-- SRAM Interface
		SRAM_DQ : inout std_logic_vector(15 downto 0);
	    SRAM_ADDR : out std_logic_vector(27 downto 0);
	    SRAM_UB_N : out std_logic;
	    SRAM_LB_N : out std_logic;
	    SRAM_WE_N : out std_logic;
	    SRAM_CE_N : out std_logic;
	    SRAM_OE_N : out std_logic;
		-- SD Card Interface
		SD_DAT : inout std_logic;
		SD_DAT3 : inout std_logic;
		SD_CMD : inout std_logic;
		SD_CLK : out std_logic;
		-- I2C
		I2C_SDAT : inout std_logic;
		I2C_SCLK : out std_logic;
		-- PS2
		PS2_DAT : in std_logic;
		PS2_CLK : in std_logic;
		-- USB JTAG link
		TDI : in std_logic;
		TCK : in std_logic;
		TCS : in std_logic;
		TDO : out std_logic;
		-- VGA
		VGA_HS : out std_logic;
		VGA_VS : out std_logic;
		VGA_R : out std_logic_vector(3 downto 0);
		VGA_G : out std_logic_vector(3 downto 0);
		VGA_B : out std_logic_vector(3 downto 0);
		-- Audio CODEC
		AUD_ADCLRCK : out std_logic;
		AUD_ADCDAT : in std_logic;
		AUD_DACLRCK : out std_logic;
		AUD_DACDAT : out std_logic;
		AUD_BCLK : inout std_logic;
		AUD_XCK : out std_logic;
		-- GPIO
		GPIO_0 : inout std_logic_vector(35 downto 0);
		GPIO_1 : inout std_logic_vector(35 downto 0)
	);
end entity top;

architecture rtl of top is
	-- overall clock
	signal clk_sys : std_logic;
	-- reset
	signal reset_n : std_logic;
	-- openMSP430 output buses
	signal per_addr : std_logic_vector(13 downto 0);
	signal per_din : std_logic_vector(15 downto 0);
	signal per_we : std_logic_vector(1 downto 0);
	signal dmem_addr : std_logic_vector(DMEM_MSB downto 0); -- Arbitrary 16x512
	signal dmem_din : std_logic_vector(15 downto 0);
	signal dmem_wen : std_logic_vector(1 downto 0);
	signal dmem_wren : std_logic;
	signal pmem_addr : std_logic_vector(PMEM_MSB downto 0); -- Arbitrary 16x2048
	signal pmem_din : std_logic_vector(15 downto 0);
	signal pmem_wen : std_logic_vector(1 downto 0);
	signal pmem_wren : std_logic;
	signal irq_acc : std_logic_vector(13 downto 0);
	-- openMSP430 input buses
	signal irq_bus : std_logic_vector(13 downto 0);
	signal per_dout : std_logic_vector(15 downto 0);
	signal dmem_dout : std_logic_vector(15 downto 0);
	signal pmem_dout : std_logic_vector(15 downto 0);
	-- GPIO
	signal p1_din : std_logic_vector(7 downto 0);
	signal p1_dout : std_logic_vector(7 downto 0);
	signal p1_dout_en : std_logic_vector(7 downto 0);
	signal p1_sel : std_logic_vector(7 downto 0);
	signal p2_din : std_logic_vector(7 downto 0);
	signal p2_dout : std_logic_vector(7 downto 0);
	signal p2_dout_en : std_logic_vector(7 downto 0);
	signal p2_sel : std_logic_vector(7 downto 0);
	signal p3_din : std_logic_vector(7 downto 0);
	signal p3_dout : std_logic_vector(7 downto 0);
	signal p3_dout_en : std_logic_vector(7 downto 0);
	signal p3_sel : std_logic_vector(7 downto 0);
	signal per_dout_dio : std_logic_vector(15 downto 0);
	-- Timer A
	signal per_dout_tA : std_logic_vector(15 downto 0);
	-- 7 segment driver
	signal per_dout_7seg : std_logic_vector(15 downto 0);
	-- Others
	signal reset_pin : std_logic;

	-- TODO sort that shit
	signal aclk_en : std_logic;
	signal dbg_freeze : std_logic;
	signal dbg_uart_txd : std_logic;
	signal dmem_cen : std_logic;
	signal mclk : std_logic;
	signal per_en : std_logic;
	signal pmem_cen : std_logic;
	signal puc_rst : std_logic;
	signal smclk_en : std_logic;
	signal dbg_uart_rxd : std_logic;
	signal nmi : std_logic;
	signal irq_port1 : std_logic;
	signal irq_port2 : std_logic;
	signal irq_ta0 : std_logic;
	signal irq_ta1 : std_logic;
	signal ta_out0 : std_logic;
	signal ta_out0_en : std_logic;
	signal ta_out1 : std_logic;
	signal ta_out1_en : std_logic;
	signal ta_out2 : std_logic;
	signal ta_out2_en : std_logic;
	signal inclk : std_logic;
	signal ta_cci0a : std_logic;
	signal ta_cci0b : std_logic;

	signal ta_cci1a : std_logic;
	signal ta_cci2a : std_logic;
	signal taclk : std_logic;

-- P1.0/TACLK      I/O pin / Timer_A, clock signal TACLK input
-- P1.1/TA0        I/O pin / Timer_A, capture: CCI0A input, compare: Out0 output
-- P1.2/TA1        I/O pin / Timer_A, capture: CCI1A input, compare: Out1 output
-- P1.3/TA2        I/O pin / Timer_A, capture: CCI2A input, compare: Out2 output
-- P1.4/SMCLK      I/O pin / SMCLK signal output
-- P1.5/TA0        I/O pin / Timer_A, compare: Out0 output
-- P1.6/TA1        I/O pin / Timer_A, compare: Out1 output
-- P1.7/TA2        I/O pin / Timer_A, compare: Out2 output
	signal p1_io_mux_b_unconnected : std_logic_vector(7 downto 0);
	signal p1_io_dout : std_logic_vector(7 downto 0);
	signal p1_io_dout_en : std_logic_vector(7 downto 0);
	signal p1_io_din : std_logic_vector(7 downto 0);

	signal p1_b_din : std_logic_vector(7 downto 0);
	signal p1_b_dout : std_logic_vector(7 downto 0);
	signal p1_b_dout_en : std_logic_vector(7 downto 0);

-- P2.0/ACLK       I/O pin / ACLK output
-- P2.1/INCLK      I/O pin / Timer_A, clock signal at INCLK
-- P2.2/TA0        I/O pin / Timer_A, capture: CCI0B input
-- P2.3/TA1        I/O pin / Timer_A, compare: Out1 output
-- P2.4/TA2        I/O pin / Timer_A, compare: Out2 output
	signal p2_io_mux_b_unconnected : std_logic_vector(7 downto 0);
	signal p2_io_dout : std_logic_vector(7 downto 0);
	signal p2_io_dout_en : std_logic_vector(7 downto 0);
	signal p2_io_din : std_logic_vector(7 downto 0);

	signal p2_b_din : std_logic_vector(7 downto 0);
	signal p2_b_dout : std_logic_vector(7 downto 0);
	signal p2_b_dout_en : std_logic_vector(7 downto 0);
begin
	-- All inout port turn to tri-state
	DRAM_DQ <= (others => 'Z');
	FL_DQ <= (others => 'Z');
	SD_DAT <= 'Z';
	I2C_SDAT <= 'Z';
	GPIO_0 <= (others => 'Z');
	GPIO_1 <= (others => 'Z');
	-- SDRAM blocking
	DRAM_CS_N <= '1';
	DRAM_CKE <= '0';
	-- FLASH blocking
	FL_RST_N <= '1';
	FL_CE_N <= '1';
	FL_OE_N <= '1';
	FL_WE_N <= '1';

	clk_sys <= CLOCK_24(0); -- no PLL for now
	reset_n <= KEY(3);

	cpu_0: openMSP430
		generic map (
			INST_NR => (others => '0'),
			TOTAL_NR => (others => '0')
		)
		port map (
			aclk => open,
			aclk_en => aclk_en,
			dbg_freeze => dbg_freeze,
			dbg_i2c_sda_out => open,
			dbg_uart_txd => dbg_uart_txd,
			dco_enable => open,
			dco_wkup => open,
			dmem_addr => dmem_addr,
			dmem_cen => dmem_cen,
			dmem_din => dmem_din,
			dmem_wen => dmem_wen,
			irq_acc => irq_acc,
			lfxt_enable => open,
			lfxt_wkup => open,
			mclk => mclk,
			dma_dout => open,
			dma_ready => open,
			dma_resp => open,
			per_addr => per_addr,
			per_din => per_din,
			per_en => per_en,
			per_we => per_we,
			pmem_addr => pmem_addr,
			pmem_cen => pmem_cen,
			pmem_din => pmem_din,
			pmem_wen => pmem_wen,
			puc_rst => puc_rst,
			smclk => open,
			smclk_en => smclk_en,

			cpu_en => '1',
			dbg_en => '1',
			dbg_i2c_addr => (others => '0'),
			dbg_i2c_broadcast => (others => '0'),
			dbg_i2c_scl => '1',
			dbg_i2c_sda_in => '1',
			dbg_uart_rxd => dbg_uart_rxd,
			dco_clk => clk_sys,
			dmem_dout => dmem_dout,
			irq => irq_bus,
			lfxt_clk => '0',
			dma_addr => (others => '0'),
			dma_din =>(others => '0') ,
			dma_en => '0',
			dma_priority => '0',
			dma_we =>(others => '0') ,
			dma_wkup => '0',
			nmi => nmi,
			per_dout => per_dout,
			pmem_dout => pmem_dout,
			reset_n => reset_n,
			scan_enable => '0',
			scan_mode => '0',
			wkup => '0'
		);

	c_gpio_0: omsp_gpio
		generic map (
			P1_EN => "1",
			P2_EN => "1",
			P3_EN => "1",
			P4_EN => "0",
			P5_EN => "0",
			P6_EN => "0"
		)
		port map (
			irq_port1 => irq_port1,
			irq_port2 => irq_port2,
			p1_dout => p1_dout,
			p1_dout_en => p1_dout_en,
			p1_sel => p1_sel,
			p2_dout => p2_dout,
			p2_dout_en => p2_dout_en,
			p2_sel => p2_sel,
			p3_dout => p3_dout,
			p3_dout_en => p3_dout_en,
			p3_sel => p3_sel,
			p4_dout => open,
			p4_dout_en => open,
			p4_sel => open,
			p5_dout => open,
			p5_dout_en => open,
			p5_sel => open,
			p6_dout => open,
			p6_dout_en => open,
			p6_sel => open,
			per_dout => per_dout_dio,

			mclk => mclk,
			p1_din => p1_din,
			p2_din => p2_din,
			p3_din => p3_din,
			p4_din => (others => '0'),
			p5_din => (others => '0'),
			p6_din => (others => '0'),
			per_addr => per_addr,
			per_din => per_din,
			per_en => per_en,
			per_we => per_we,
			puc_rst => puc_rst
		);

	timerA_0: omsp_timerA
		port map(
			irq_ta0 => irq_ta0,
			irq_ta1 => irq_ta1,
			per_dout => per_dout_tA,
			ta_out0 => ta_out0,
			ta_out0_en => ta_out0_en,
			ta_out1 => ta_out1,
			ta_out1_en => ta_out1_en,
			ta_out2 => ta_out2,
			ta_out2_en => ta_out2_en,
			
			aclk_en => aclk_en,
			dbg_freeze => dbg_freeze,
			inclk => inclk,
			irq_ta0_acc => irq_acc(9),
			mclk => mclk,
			per_addr => per_addr,
			per_din => per_din,
			per_en => per_en,
			per_we => per_we,
			puc_rst => puc_rst,
			smclk_en => smclk_en,
			ta_cci0a => ta_cci0a,
			ta_cci0b => ta_cci0b,
			ta_cci1a => ta_cci1a,
			ta_cci1b => '0',
			ta_cci2a => ta_cci2a,
			ta_cci2b => '0',
			taclk => taclk
		);

--	timerA_0: omsp_timerA
--		port map(
--			irq_ta0 => irq_ta0,
--			irq_ta1 => irq_ta1,
--			per_dout => per_dout_tA,
----			ta_out0 => ta_out0,
----			ta_out0_en => ta_out0_en,
----			ta_out1 => ta_out1,
----			ta_out1_en => ta_out1_en,
----			ta_out2 => ta_out2,
----			ta_out2_en => ta_out2_en,
--			
--			aclk_en => aclk_en,
--			dbg_freeze => dbg_freeze,
--			inclk => '0',
--			irq_ta0_acc => irq_acc(9),
--			mclk => mclk,
--			per_addr => per_addr,
--			per_din => per_din,
--			per_en => per_en,
--			per_we => per_we,
--			puc_rst => puc_rst,
--			smclk_en => smclk_en,
--			ta_cci0a => '0',
--			ta_cci0b => '0',
--			ta_cci1a => '0',
--			ta_cci1b => '0',
--			ta_cci2a => '0',
--			ta_cci2b => '0',
--			taclk => '0'
--		);

	-- Combine peripheral data buses
	---------------------------------
	per_dout <= per_dout_dio or per_dout_tA;

	-- Assign interrupts
	---------------------------------
	nmi <= '0';
	irq_bus <= 
		'0' &        -- Vector 13  (0xFFFA)
		'0' &        -- Vector 12  (0xFFF8)
		'0' &        -- Vector 11  (0xFFF6)
		'0' &        -- Vector 10  (0xFFF4) - Watchdog -
		irq_ta0 &    -- Vector  9  (0xFFF2)
		irq_ta1 &    -- Vector  8  (0xFFF0)
		'0' &        -- Vector  7  (0xFFEE)
		'0' &        -- Vector  6  (0xFFEC)
		'0' &        -- Vector  5  (0xFFEA)
		'0' &        -- Vector  4  (0xFFE8)
		irq_port2 &  -- Vector  3  (0xFFE6)
		irq_port1 &  -- Vector  2  (0xFFE4)
		'0' &        -- Vector  1  (0xFFE2)
		'0';         -- Vector  0  (0xFFE0)

	dmem_wren <= not (dmem_wen(1) and dmem_wen(0));
	dram: ram16x512
		port map (
			address => dmem_addr(8 downto 0),
	        clken => not dmem_cen,
	        clock => clk_sys,
	        data => dmem_din,
	        q => dmem_dout,
	        wren => dmem_wren,
	        byteena => not dmem_wen
		);

	pmem_wren <= not (pmem_wen(1) and pmem_wen(0));
	pram: ram16x2048
		port map (
			address => pmem_addr(10 downto 0),
	        clken => not pmem_cen,
	        clock => clk_sys,
	        data => pmem_din,
	        q => pmem_dout,
	        wren => pmem_wren,
	        byteena => not pmem_wen
		);

	p1_b_din <= p1_io_mux_b_unconnected(7 downto 4) & ta_cci2a & ta_cci1a & ta_cci0a & taclk;
	p1_b_dout <= ta_out2 & ta_out1 & ta_out0 & (smclk_en and mclk) & ta_out2 & ta_out1 & ta_out0 & '0';
	p1_b_dout_en <= ta_out2_en & ta_out1_en & ta_out0_en & '1' & ta_out2_en & ta_out1_en & ta_out0_en & '0';

	io_mux_p1: io_mux
		generic map (
			WIDTH => 8
		)
		port map (
			a_din => p1_din,
			a_dout => p1_dout,
			a_dout_en => p1_dout_en,

			b_din => p1_b_din,
			b_dout => p1_b_dout,
			b_dout_en => p1_b_dout_en,

			io_din => p1_io_din,
			io_dout => p1_io_dout,
			io_dout_en => p1_io_dout_en,
			
			sel => p1_sel
		);

	p2_b_din <= p2_io_mux_b_unconnected(7 downto 3) & ta_cci0b & inclk & p2_io_mux_b_unconnected(0);
	p2_b_dout <= "000" & ta_out2 & ta_out1 & "00" & (aclk_en and mclk);
	p2_b_dout_en <= "000" & ta_out2_en & ta_out1_en & "001";

	io_mux_p2: io_mux
		generic map (
			WIDTH => 8
		)
		port map (
			a_din => p2_din,
			a_dout => p2_dout,
			a_dout_en => p2_dout_en,
			
			b_din => p2_b_din,
			b_dout => p2_b_dout,
			b_dout_en => p2_b_dout_en,
			
			io_din => p2_io_din,
			io_dout => p2_io_dout,
			io_dout_en => p2_io_dout_en,
			
			sel => p2_sel
		);

	p3_din(7 downto 0) <= SW(7 downto 0);
	LEDR(7 downto 0) <= p3_dout(7 downto 0) and p3_dout_en(7 downto 0);

	-- RS-232 Port
	------------------------
	-- P1.1 (TX) and P2.2 (RX)
	p1_io_din <= (others => '0');
	p2_io_din(7 downto 3) <= (others => '0');
	p2_io_din(1 downto 0) <= (others => '0');

	UART_TXD <= dbg_uart_txd;
	dbg_uart_rxd <= UART_RXD;
end architecture rtl;
--//
--// GPIO Function selection
--//--------------------------