library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is
		
	port (
		MAX10_CLK1_50 : in std_logic;
		Key : in std_logic(1 downto 0);
		BoxPostition : in std_logic_vector(11 downto 0);
		blockArray : out array(0 to 8, 0 to 11) of unsigned(2 downto 0);
		falling_block : out unsigned(2 downto 0); -- color of falling block, 0 is no block
		falling_block_col : out unsigned(3 downto 0);
		falling_block_row : out unsigned(3 downto 0);
		score : out unsigned(19 downto 0);
		rand : in std_logic_vector(1 downto 0);
	);
	
end entity controller;
	
architecture behavioral of controller is 
	
	--STATE SIGNALS
	type state_type is ();
	signal cur_state : state_type;
	signal next_state : state_type;
	signal row, col : unsigned(3 downto 0);
	signal timer : integer;

begin

	--signal initialization
	falling_block_col <= col;
	falling_block_row <= row;
		
	
	
	process (MAX10_CLK1_50)
	begin
	
		--col logic
		case BoxPosition is
			when => >X"1C7"
				col <= X"0";
			when => <=X"1C7" and >X"38E"
				col <= X"1";
			when => <=X"38E" and >X"555"
				col <= X"2";
			when => <=X"555" and >X"71C"
				col <= X"3";
			when => <=X"71C" and >X"8E3"
				col <= X"4";
			when => <=X"8E3" and >X"AAA"
				col <= X"5";
			when => <=X"AAA" and >X"C71"
				col <= X"6";
			when => <=X"C71" and >X"E38"
				col <= X"7";
			when => <=X"E38" and >=X"FFF"
				col <= X"8";
		end case;
		
		--row logic
		if timer = 25000000 then
			row <= row - X"1";
			if row = X"0" then
				blockArray
			
	
	end process;
	
	
	process()
		begin
		
	end process;
	
end architecture behavioral;