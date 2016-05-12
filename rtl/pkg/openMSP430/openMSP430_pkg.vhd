library ieee;
use ieee.std_logic_1164.all;

package openMSP430_pkg is
	-- `define DMEM_SIZE_1_KB
	constant DMEM_AWIDTH : positive := 9;
	-- `define PMEM_SIZE_4_KB
	constant PMEM_AWIDTH : positive := 11;
	-- `define IRQ_16
	constant IRQ_NR : positive := 16;

	constant DMEM_MSB : positive := DMEM_AWIDTH-1;
	constant PMEM_MSB : positive := PMEM_AWIDTH-1;

	component openMSP430 is
		generic (
			INST_NR : std_logic_vector(7 downto 0) := (others => '0'); -- Current oMSP instance number     (for multicore systems)
			TOTAL_NR : std_logic_vector(7 downto 0) := (others => '0') -- Total number of oMSP instances-1 (for multicore systems)
		);
		port (
			aclk : out std_logic;                                -- ASIC ONLY: ACLK
			aclk_en : out std_logic;                             -- FPGA ONLY: ACLK enable
			dbg_freeze : out std_logic;                          -- Freeze peripherals
			dbg_i2c_sda_out : out std_logic;                     -- Debug interface: I2C SDA OUT
			dbg_uart_txd : out std_logic;                        -- Debug interface: UART TXD
			dco_enable : out std_logic;                          -- ASIC ONLY: Fast oscillator enable
			dco_wkup : out std_logic;                            -- ASIC ONLY: Fast oscillator wake-up (asynchronous)
			dmem_addr : out std_logic_vector(DMEM_MSB downto 0); -- Data Memory address
			dmem_cen : out std_logic;                            -- Data Memory chip enable (low active)
			dmem_din : out std_logic_vector(15 downto 0);        -- Data Memory data input
			dmem_wen : out std_logic_vector(1 downto 0);         -- Data Memory write byte enable (low active)
			irq_acc : out std_logic_vector(IRQ_NR-3 downto 0);   -- Interrupt request accepted (one-hot signal)
			lfxt_enable : out std_logic;                         -- ASIC ONLY: Low frequency oscillator enable
			lfxt_wkup : out std_logic;                           -- ASIC ONLY: Low frequency oscillator wake-up (asynchronous)
			mclk : out std_logic;                                -- Main system clock
			dma_dout : out std_logic_vector(15 downto 0);        -- Direct Memory Access data output
			dma_ready : out std_logic;                           -- Direct Memory Access is complete
			dma_resp : out std_logic;                            -- Direct Memory Access response (0:Okay / 1:Error)
			per_addr : out std_logic_vector(13 downto 0);        -- Peripheral address
			per_din : out std_logic_vector(15 downto 0);         -- Peripheral data input
			per_en : out std_logic;                              -- Peripheral enable (high active)
			per_we : out std_logic_vector(1 downto 0);           -- Peripheral write byte enable (high active)
			pmem_addr : out std_logic_vector(PMEM_MSB downto 0); -- Program Memory address
			pmem_cen : out std_logic;                            -- Program Memory chip enable (low active)
			pmem_din : out std_logic_vector(15 downto 0);        -- Program Memory data input (optional)
			pmem_wen : out std_logic_vector(1 downto 0);         -- Program Memory write enable (low active) (optional)
			puc_rst : out std_logic;                             -- Main system reset
			smclk : out std_logic;                               -- ASIC ONLY: SMCLK
			smclk_en : out std_logic;                            -- FPGA ONLY: SMCLK enable

			cpu_en : in std_logic;                               -- Enable CPU code execution (asynchronous and non-glitchy)
			dbg_en : in std_logic;                               -- Debug interface enable (asynchronous and non-glitchy)
			dbg_i2c_addr : in std_logic_vector(6 downto 0);      -- Debug interface: I2C Address
			dbg_i2c_broadcast : in std_logic_vector(6 downto 0); -- Debug interface: I2C Broadcast Address (for multicore systems)
			dbg_i2c_scl : in std_logic;                          -- Debug interface: I2C SCL
			dbg_i2c_sda_in : in std_logic;                       -- Debug interface: I2C SDA IN
			dbg_uart_rxd : in std_logic;                         -- Debug interface: UART RXD (asynchronous)
			dco_clk : in std_logic;                              -- Fast oscillator (fast clock)
			dmem_dout : in std_logic_vector(15 downto 0);        -- Data Memory data output
			irq : in std_logic_vector(IRQ_NR-3 downto 0);        -- Maskable interrupts (14, 30 or 62)
			lfxt_clk : in std_logic;                             -- Low frequency oscillator (typ 32kHz)
			dma_addr : in std_logic_vector(15 downto 1);         -- Direct Memory Access address
			dma_din : in std_logic_vector(15 downto 0);          -- Direct Memory Access data input
			dma_en : in std_logic;                               -- Direct Memory Access enable (high active)
			dma_priority : in std_logic;                         -- Direct Memory Access priority (0:low / 1:high)
			dma_we : in std_logic_vector(1 downto 0);            -- Direct Memory Access write byte enable (high active)
			dma_wkup : in std_logic;                             -- ASIC ONLY: DMA Wake-up (asynchronous and non-glitchy)
			nmi : in std_logic;                                  -- Non-maskable interrupt (asynchronous and non-glitchy)
			per_dout : in std_logic_vector(15 downto 0);         -- Peripheral data output
			pmem_dout : in std_logic_vector(15 downto 0);        -- Program Memory data output
			reset_n : in std_logic;                              -- Reset Pin (active low, asynchronous and non-glitchy)
			scan_enable : in std_logic;                          -- ASIC ONLY: Scan enable (active during scan shifting)
			scan_mode : in std_logic;                            -- ASIC ONLY: Scan mode
			wkup : in std_logic                                  -- ASIC ONLY: System Wake-up (asynchronous and non-glitchy)
		);
	end component openMSP430;
end package openMSP430_pkg;
