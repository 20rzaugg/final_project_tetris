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
	signal checkArray : boolean := False;

begin

	--signal initialization
	falling_block_col <= col;
	falling_block_row <= row;
		
	
	
	process (MAX10_CLK1_50)
	begin
	
		--col logic
		case BoxPosition is
			when => >X"1C7"
				if blockArray(X"0", row) = X"0" then
					col <= X"0";
				else
					col <= col;
				end if;
			when => <=X"1C7" and >X"38E"
				if blockArray(X"1", row) = X"0" then
					col <= X"1";
				else
					col <= col;
				end if;
			when => <=X"38E" and >X"555"
				if blockArray(X"2", row) = X"0" then
					col <= X"2";
				else
					col <= col;
				end if;
			when => <=X"555" and >X"71C"
				if blockArray(X"3", row) = X"0" then
					col <= X"3";
				else
					col <= col;
				end if;
			when => <=X"71C" and >X"8E3"
				if blockArray(X"4", row) = X"0" then
					col <= X"4";
				else
					col <= col;
				end if;
			when => <=X"8E3" and >X"AAA"
				if blockArray(X"5", row) = X"0" then
					col <= X"5";
				else
					col <= col;
				end if;
			when => <=X"AAA" and >X"C71"
				if blockArray(X"6", row) = X"0" then
					col <= X"6";
				else
					col <= col;
				end if;
			when => <=X"C71" and >X"E38"
				if blockArray(X"7", row) = X"0" then
					col <= X"7";
				else
					col <= col;
				end if;
			when => <=X"E38" and >=X"FFF"
				if blockArray(X"8", row) = X"0" then
					col <= X"8";
				else
					col <= col;
				end if;
		end case;
		
		--row logic
		if timer = 25000000 then
			row <= row - X"1";
			if row = X"0" or blockArray(col, row - 1) != X"0" then --0 means black, if not black it is filled.
				blockArray(col, row) <= falling_block;
				checkArray <= true;
				falling_block <= rand;
			end if;
		end if;
		
		--array Management
		if checkArray = true then
			for(int i = 0; i < 8; i++) --check rows
				for(int j = 0; j < 11; j++)--check cols
					if blockArray(i,j) != X"0" and blockArray(i,j) = blockArray(i + 1, j) and blockArray(i,j) = blockArray(i + 2, j) then
						score <= score + X"3";
					
					
	

			
	
	end process;
	
	
	process()
		begin
		
	end process;
	
end architecture behavioral;