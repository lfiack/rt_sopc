library ieee;
use ieee.std_logic_1164.all;

package omsp_timerA_pkg is
	component omsp_timerA is
		port (
			irq_ta0 : out std_logic;                       -- Timer A interrupt: TACCR0
			irq_ta1 : out std_logic;                       -- Timer A interrupt: TAIV, TACCR1, TACCR2
			per_dout : out std_logic_vector(15 downto 0);  -- Peripheral data output
			ta_out0 : out std_logic;                       -- Timer A output 0
			ta_out0_en : out std_logic;                    -- Timer A output 0 enable
			ta_out1 : out std_logic;                       -- Timer A output 1
			ta_out1_en : out std_logic;                    -- Timer A output 1 enable
			ta_out2 : out std_logic;                       -- Timer A output 2
			ta_out2_en : out std_logic;                    -- Timer A output 2 enable
			
			aclk_en : in std_logic;                        -- ACLK enable (from CPU)
			dbg_freeze : in std_logic;                     -- Freeze Timer A counter
			inclk : in std_logic;                          -- INCLK external timer clock (SLOW)
			irq_ta0_acc : in std_logic;                    -- Interrupt request TACCR0 accepted
			mclk : in std_logic;                           -- Main system clock
			per_addr : in std_logic_vector(13 downto 0);   -- Peripheral address
			per_din : in std_logic_vector(15 downto 0);    -- Peripheral data input
			per_en : in std_logic;                         -- Peripheral enable (high active)
			per_we : in std_logic_vector(1 downto 0);      -- Peripheral write enable (high active)
			puc_rst : in std_logic;                        -- Main system reset
			smclk_en : in std_logic;                       -- SMCLK enable (from CPU)
			ta_cci0a : in std_logic;                       -- Timer A capture 0 input A
			ta_cci0b : in std_logic;                       -- Timer A capture 0 input B
			ta_cci1a : in std_logic;                       -- Timer A capture 1 input A
			ta_cci1b : in std_logic;                       -- Timer A capture 1 input B
			ta_cci2a : in std_logic;                       -- Timer A capture 2 input A
			ta_cci2b : in std_logic;                       -- Timer A capture 2 input B
			taclk : in std_logic                           -- TACLK external timer clock (SLOW)
		);
	end component omsp_timerA;
end package omsp_timerA_pkg;
