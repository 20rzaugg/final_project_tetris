library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--consider only looking at least significant 2 bits instead of modulo.
--Do not modulo. Do not divide.

entity rng is
		
	port (
		clk : in std_logic;
		rst_l : in std_logic;
		rand : out std_logic_vector(3 downto 0)
	);
	
end entity rng;
	
architecture behavioral of rng is 

	signal lfsr : unsigned(11 downto 0) := X"1FA"; --seed value
	signal bitt : std_logic;
	signal timer : integer := 0;
	

begin

		bitt <= lfsr(11) xor lfsr(10) xor lfsr(9) xor lfsr(3);
		--random number 1-4
		rand <= std_logic_vector("00"&lfsr(1 downto 0) + 1);
	
	
	process (clk, rst_l) begin
		if rst_l = '0' then
			timer <= 0;
			lfsr <= X"1FA";
		else if rising_edge(clk) and rst_l /= '0' then
			if timer = 2500000 then
				lfsr <= lfsr(10 downto 0) & bitt;
				timer <= 0;
			else
				timer <= timer + 1;
			end if;
		end if;
		end if;
	end process;

end architecture behavioral;