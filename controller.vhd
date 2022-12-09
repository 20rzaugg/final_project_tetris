library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.tetris_types.all;

entity controller is
		
	port (
		MAX10_CLK1_50 : in std_logic;
		Key : in std_logic_vector(1 downto 0);
		BoxPosition : in std_logic_vector(11 downto 0);
		blockArray : buffer tetris_block_array;
		falling_block : out unsigned(3 downto 0); -- color of falling block, 0 is no block
		falling_block_col : out unsigned(3 downto 0);
		falling_block_row : out unsigned(3 downto 0);
		score : out unsigned(19 downto 0);
		rand : in std_logic_vector(1 downto 0)
	);
	
end entity controller;
	
architecture behavioral of controller is 
	
	--STATE SIGNALS
	type statetype is (play, game_over, initial);
	signal cur_state, next_state : statetype;
	--Other Signals
	signal row, col, next_row, next_col : unsigned(3 downto 0);
	signal timer : integer;
	signal checkArray, next_checkArray : boolean := False;
	signal Barray, next_Barray : tetris_block_array;
	signal fBlock, next_fBlock : unsigned(3 downto 0);
	signal scorn, next_scorn : unsigned(19 downto 0);
	signal createBlock, next_createBlock : boolean := false;

begin

	--signal initialization
	falling_block_col <= col;
	falling_block_row <= row;
	blockArray <= Barray;
	falling_block <= fBlock;
	score <= scorn;
		
	
	
	process (MAX10_CLK1_50)
	begin
		if key(0) = '0' then
			cur_state <= initial;
		else
			fBlock <= next_fBlock;
			Barray <= next_Barray;
			checkArray <= next_checkArray;
			row <= next_row;
			col <= next_col;
			cur_state <= next_state;
			scorn <= next_scorn;
			createBlock <= next_createBlock;
		end if;
	end process;
	
	
	process(col, row, Barray, checkArray, fBlock)
		begin
		next_fBlock <= fBlock;
		next_Barray <= Barray;
		next_checkArray <= checkArray;
		next_row <= row;
		next_col <= col;
		next_state <= cur_state;
		next_scorn <= scorn;
		next_createBlock <= createBlock;
		
		case cur_state is
			when initial =>
				for i in 0 to 11 loop
					for j in 0 to 8 loop
						next_bArray(i,j) <= X"0";
					end loop;
				end loop;
				
				next_scorn <= X"00000";
				
				if key(1) = '0' then
					next_state <= play;
					next_createBlock <= true;
				end if;
			
			when play =>
			
				--initialize falling block
				if createBlock = true then
					next_fBlock <= b"00"&unsigned(rand);
					next_row <= X"D";
					next_col <= X"4";
					next_createBlock <= false;
				end if;
		
				--col logic
				--case BoxPosition is
					--when => >X"1C7"
					if BoxPosition > X"1C7" then
						if Barray(0, to_integer(row)) = X"0" then
							next_col <= X"0";
						else
							next_col <= col;
						end if;
					end if;
					--when => <=X"1C7" and >X"38E"
					if BoxPosition <= X"1C7" and BoxPosition > X"38E" then
						if Barray(1, to_integer(row)) = X"0" then
							next_col <= X"1";
						else
							next_col <= col;
						end if;
					end if;
					--when => <=X"38E" and >X"555"
					if BoxPosition <= X"38E" and BoxPosition > X"555" then
						if Barray(2, to_integer(row)) = X"0" then
							next_col <= X"2";
						else
							next_col <= col;
						end if;
					end if;
					--when => <=X"555" and >X"71C"
					if BoxPosition <= X"555" and BoxPosition > X"71C" then
						if Barray(3, to_integer(row)) = X"0" then
							next_col <= X"3";
						else
							next_col <= col;
						end if;
					end if;
					--when => <=X"71C" and >X"8E3"
					if BoxPosition <= X"71C" and BoxPosition > X"8E3" then
						if Barray(4, to_integer(row)) = X"0" then
							next_col <= X"4";
						else
							next_col <= col;
						end if;
					end if;
					--when => <=X"8E3" and >X"AAA"
					if BoxPosition <= X"8E3" and BoxPosition > X"AAA" then
						if Barray(5, to_integer(row)) = X"0" then
							next_col <= X"5";
						else
							next_col <= col;
						end if;
					end if;
					--when => <=X"AAA" and >X"C71"
					if BoxPosition <= X"AAA" and BoxPosition > X"C71" then
						if Barray(6, to_integer(row)) = X"0" then
							next_col <= X"6";
						else
							next_col <= col;
						end if;
					end if;
					--when => <=X"C71" and >X"E38"
					if BoxPosition <= X"C71" and BoxPosition > X"E38" then
						if Barray(7, to_integer(row)) = X"0" then
							next_col <= X"7";
						else
							next_col <= col;
						end if;
					end if;
					--when => <=X"E38" and >=X"FFF"
					if BoxPosition <= X"E38" and BoxPosition >= X"FFF" then
						if Barray(8, to_integer(row)) = X"0" then
							next_col <= X"8";
						else
							next_col <= col;
						end if;
					end if;
				--end case;
				
				--row logic
				if (timer = 25000000) then
					next_row <= row - X"1";
					timer <= 0;
					if (row = X"0" or Barray(to_integer(col), to_integer(row - X"1")) /= X"0") then --0 means black, if not black it is filled.
						next_BArray(to_integer(col), to_integer(row)) <= fBlock;
						next_checkArray <= true;
						next_createBlock <= true;
					end if;
					if Barray(to_integer(col), to_integer(row)) = X"C" then --check the array if at 12, switch state to game over.
						next_state <= game_over;
					end if;
				else
					timer <= timer + 1;
				end if;
				
				--array Management
				if checkArray = true then
					for j in 0 to 11 loop--for(int i = 0; i < 8; i++) --check rows
						for i in 0 to 8 loop--for(int j = 0; j < 11; j++)--check cols
							if j < 7 then
								if blockArray(i,j) /= X"0" and blockArray(i,j) = blockArray(i, j + 1) and blockArray(i,j) = blockArray(i, j + 2) then
									if j < 6 then
										if blockArray(i, j + 3) = blockArray(i,j) then
											if j < 5 then
												if blockArray(i, j + 4) = blockArray(i,j) then
													next_scorn <= scorn + X"5";
												else 
													next_scorn <= scorn + X"4";
												end if;
											end if;
										else
											next_scorn <= scorn + X"3";
										end if;
									end if;
								end if;
							--end if;
							if i < 10 then
								if blockArray(i,j) /= X"0" and blockArray(i,j) = blockArray(i + 1, j) and blockArray(i,j) = blockArray(i + 2, j) then
									if i < 9 then
										if blockArray( i , j ) = blockArray( i + 3, j ) then
											next_scorn <= scorn + X"4";
										else
											next_scorn <= scorn + X"3";
										end if;
									end if;
								end if;
							end if;
							if j > 1 and blockArray(i,j) /= X"0" and blockArray(i ,j - 1) = X"0" then
								next_bArray(i, j - 1) <= blockArray(i,j);
								next_bArray(i,j) <= X"0";
							end if;
						end if; --may not be necessary
						end loop;
					end loop;
					next_checkArray <= False;
				end if;
				
			when game_over =>
				next_fBlock <= X"0";
				next_row <= X"D";
				next_col <= X"4";
				next_createBlock <= false;	
		end case;
		
	end process;
	
end architecture behavioral;