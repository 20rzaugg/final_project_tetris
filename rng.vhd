library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity randGenR is
		
	port (
		MAX10_CLK1_50 : in std_logic;
		KEY : in std_logic_vector(1 downto 0);
		rand : out std_logic_vector(1 downto 0);
	);
	
end entity randGenR;
	
architecture behavioral of randGenR is 

	signal lfsr : unsigned(11 downto 0);
	signal bitt : std_logic;
	signal timer : integer;--(27 downto 0);
	signal randnum : std_logic_vector(1 downto 0);
	

begin

		bitt <= lfsr(11) xor lfsr(10) xor lfsr(9) xor lfsr(3);
		rand <= randnum;
		randnum <= lsfr mod 4;
	
	
	process (MAX10_CLK1_50, KEY) 
	
	begin
		if KEY(0) = '0' then

			timer <= 0;
			randnum <= b"00";
			
		elsif rising_edge(MAX10_CLK1_50) then
			if timer = 25000000;
				lfsr <= lfsr(10 downto 0) & bitt;
			else
				timer <= timer + 1;
			end if;
		
		end if;
	end process;

end architecture behavioral;