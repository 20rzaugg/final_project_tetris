library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity randGenR is
		
	port (
		MAX10_CLK1_50 : in std_logic;
		KEY : in std_logic_vector(1 downto 0);
		HEX0 : out unsigned(7 downto 0);
		HEX1 : out unsigned(7 downto 0);
		HEX2 : out unsigned(7 downto 0);
		HEX3 : out unsigned(7 downto 0);
		HEX4 : out unsigned(7 downto 0);
		HEX5 : out unsigned(7 downto 0)
	);
	
end entity randGenR;
	
architecture behavioral of randGenR is 

	signal first : unsigned(3 downto 0); --1/100
	signal second : unsigned(3 downto 0); --1/10
	signal lfsr : unsigned(11 downto 0);
	signal bitt : std_logic;
	--signal timer : unsigned(27 downto 0);
	
	type MY_MEM is array(0 to 15) of unsigned(7 downto 0);
	signal sev_seg : MY_MEM := (X"C0", X"F9", X"A4", X"B0", X"99", X"92", X"83", X"F8", X"80", X"98", X"88", X"83", X"C6", X"A1", X"86", X"8E");

begin
		HEX0 <= sev_seg(to_integer(first));
		HEX1 <= sev_seg(to_integer(second));
		HEX2 <= X"FF";
		HEX3 <= X"FF";
		HEX4 <= X"FF";
		HEX5 <= X"FF";
		first <= lfsr(3 downto 0);
		second <= lfsr(7 downto 4);
		--bitt <= (((lfsr xor (lfsr(10 downto 0) & "0")) xor (lfsr(9 downto 0) & "00")) xor (lfsr(3 downto 0) & "00000000"));
		bitt <= lfsr(11) xor lfsr(10) xor lfsr(9) xor lfsr(3);
	
	
	process (MAX10_CLK1_50, KEY) 
	
	begin
		if KEY(0) = '0' then
			--lfsr <= X"C42";
			lfsr <= "110001000010";
			--timer <= (others => '0');
			
		elsif rising_edge(MAX10_CLK1_50) and key(1) = '0' then
			--tap at 12,11,10,,4
			--if timer = X"17D7840" then
				--bitt <= (((lfsr xor (lfsr(10 downto 0) & "0")) xor (lfsr(9 downto 0) & "00")) xor (lfsr(3 downto 0) & "00000000"));
				--lfsr <= (lfsr(10 downto 0) & "0") or ("0000000000" & bitt(11));
				lfsr <= lfsr(10 downto 0) & bitt;
				--timer <= (others => '0');
			--end if;
			--timer <= timer + 1;
			--lfsr <= "100010000100";
			--bitt  <= ((lfsr) xor (lfsr sll 1) xor (lfsr sll 2) xor (lfsr sll 8) ) and X"001";
			--lfsr <=  (lfsr sll 1) or (bitt and X"8FF"); --only want most significant bit of bitt
		end if;
	end process;

end architecture behavioral;