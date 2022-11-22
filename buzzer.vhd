library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity buzzer is
		
	port (
	
	);
	
end entity buzzer;
	
architecture behavioral of buzzer is 
	
	--STATE SIGNALS
	type state_type is (--ADD, STAY, DELAY);
	signal cur_state : state_type;
	signal next_state : state_type;

begin

		--signal initialization
	
	--processes
	process (MAX10_CLK1_50)
	begin
		
	end process;
	
	process (cur_state)
	begin
	
	end process;
	
end architecture behavioral;