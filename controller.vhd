library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is
		
	port (
		MAX10_CLK1_50 : in std_logic;
		rand : out std_logic_vector(1 downto 0);
	);
	
end entity controller;
	
architecture behavioral of controller is 
	
	--STATE SIGNALS
	type state_type is (ADD, STAY, DELAY);
	signal cur_state : state_type;
	signal next_state : state_type;

begin

	--signal initialization
		
	
	
	process (MAX10_CLK1_50)
	begin
	
	end process;
	
	process()
		begin
		
	end process;
	
end architecture behavioral;