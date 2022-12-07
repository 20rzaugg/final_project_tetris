library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package tetris_types is

	type tetris_block_array is array(0 to 8, 0 to 11) of unsigned(2 downto 0);
	
	type score_digits_array is array(0 to 5) of unsigned(3 downto 0);

end package;