package body log2_pkg is
	function log2ceil (n : natural) return natural is
		variable n_bit : unsigned(31 downto 0);
	begin  -- log2ceil
		if n = 0 then
			return 0;
		end if;
		n_bit := to_unsigned(n-1,32);
		for i in 31 downto 0 loop
			if n_bit(i) = '1' then
				return i+1;
			end if;
		end loop;  -- i
		return 1;
	end function log2ceil;
end package body log2_pkg;
