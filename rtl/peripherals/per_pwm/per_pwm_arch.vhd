library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.per_pwm_pkg.all;
use work.per_iface_pkg.all;
use work.pwm_pkg.all;

--entity per_pwm is
--	generic (
--		-- Register base address (must be aligned to decoder bit width)
--		BASE_ADDR : std_logic_vector(14 downto 0) := 15x"0100"
--	);
--	port (
--		per_dout : out std_logic_vector(15 downto 0);  -- Peripheral data output
--
--		mclk : in std_logic;                           -- Main system clock
--		per_addr : in std_logic_vector(13 downto 0);   -- Peripheral address
--		per_din : in std_logic_vector(15 downto 0);    -- Peripheral data input
--		per_en : in std_logic;                         -- Peripheral enable (high active)
--		per_we : in std_logic_vector(1 downto 0);      -- Peripheral write enable (high active)
--		puc_rst : in std_logic;                        -- Main system reset
--
--		pwm_a : out std_logic;
--		pwm_b : out std_logic
--	);
--end entity per_pwm;

architecture rtl of per_pwm is
	signal reg_file_wren : std_logic_vector(0 to 3);
	signal reg_out : std_logic_vector(15 downto 0);
	signal reg_file_in : reg_file_t(0 to 3);

	signal ctrl_wren : std_logic;
	signal period_wren : std_logic;
	signal duty_wren : std_logic;
	signal dead_band_wren : std_logic;

	signal reg_ctrl : std_logic_vector(15 downto 0);
	signal reg_period : std_logic_vector(15 downto 0);
	signal reg_duty : std_logic_vector(15 downto 0);
	signal reg_dead_band : std_logic_vector(15 downto 0);
begin
	interface: per_iface
		generic map (
			-- Register base address (must be aligned to decoder bit width)
			BASE_ADDR => BASE_ADDR,
			-- Number of registers
			REG_NB => 4
		)
		port map (
			per_dout => per_dout,
	
			mclk => mclk,
			per_addr => per_addr,
			per_din => per_din,
			per_en => per_en,
			per_we => per_we,
			puc_rst => puc_rst,

			reg_file_wren => reg_file_wren,
			reg_out => reg_out,
			reg_file_in => reg_file_in
		);

	pwm0: pwm
		port map (
			clock => mclk,
			reset => puc_rst,
			enable => reg_ctrl(0),
			
			period => unsigned(reg_period),
			duty => unsigned(reg_duty),
			dead_band => unsigned(reg_dead_band),
	
			pwm_a => pwm_a,
			pwm_b => pwm_b
		);

	ctrl_wren <= reg_file_wren(0);
	period_wren <= reg_file_wren(1);
	duty_wren <= reg_file_wren(2);
	dead_band_wren <= reg_file_wren(3);

	p_regs : process(puc_rst, mclk)
	begin
		if (puc_rst = '1') then
			reg_ctrl <= (others => '0');
			reg_period <= (others => '0');
			reg_duty <= (others => '0');
			reg_dead_band <= (others => '0');
		elsif rising_edge(mclk) then
			if (ctrl_wren = '1') then
				reg_ctrl <= reg_out;
			end if;
			if (period_wren = '1') then
				reg_period <= reg_out;
			end if;
			if (duty_wren = '1') then
				reg_duty <= reg_out;
			end if;
			if (dead_band_wren = '1') then
				reg_dead_band <= reg_out;
			end if;
		end if;
	end process p_regs;

	reg_file_in(0) <= reg_ctrl;
	reg_file_in(1) <= reg_period;
	reg_file_in(2) <= reg_duty;
	reg_file_in(3) <= reg_dead_band;
end architecture rtl;
