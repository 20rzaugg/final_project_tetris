library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity Flags is
		
	port (
		clk : in std_logic;
		change : in std_logic := '1';
		rst_l : in std_logic := '1';
		Hpos : in unsigned(11 downto 0);
		Vpos : in unsigned(11 downto 0);
		Red : out std_logic_vector(3 downto 0);		
		Green : out std_logic_vector(3 downto 0);
		Blue : out std_logic_vector(3 downto 0);
		rand : in std_logic_vector(1 downto 0);
	);
	
end entity Flags;
	
architecture behavioral of Flags is

type colorme is array(0 to 9) of std_logic_vector(11 downto 0); --add more colors if necessary
signal display : colorme := (X"000", X"FFF", X"F00", X"00F", X"FF0", X"080", X"F50", X"A00", X"0C0", X"00A");

type colors is (Black, White, cRed, cBlue, Yellow, cGreen, Orange, lRed, lGreen, lBlue);
signal color, next_color : colors;
signal boxColor : colors

signal color_index, next_color_index : unsigned(11 downto 0);
	

type statetype is (idle, press, debounce);
signal cur_state, next_state : statetype;



begin

	process(rand) --set value for box.
	begin
		case rand is
			when b"00" =>
				boxColor <= cRed;
			when b"01" =>
				boxColor <= cBlue;
			when b"10" =>
				boxColor <= Green;
			when b"11" =>
				boxColor <= Yellow;
		end case;
	end process;
			

	process(color)
	begin
		case color is
			when Black =>
				next_color_index <= X"000";
			when White =>
				next_color_index <= X"001";
			when cRed =>
				next_color_index <= X"002";
			when cBlue =>
				next_color_index <= X"003";
			when Yellow =>
				next_color_index <= X"004";
			when cGreen =>
				next_color_index <= X"005";
			when Orange =>
				next_color_index <= X"006";
			when lRed =>
				next_color_index <= X"007";
			when lGreen =>
				next_color_index <= X"008";
			when lBlue =>
				next_color_index <= X"009";
		end case;
	end process;

	Blue <= display(to_integer(color_index))(3 downto 0);
	Green <= display(to_integer(color_index))(7 downto 4);
	Red <= display(to_integer(color_index))(11 downto 8);

	

	process (clk)
		begin
			if rising_edge(clk) then
				if rst_l = '0' then
					cur_state <= idle;
					cur_flag <= france;
					color_index <= X"000";
				else
					cur_state <= next_state;
					cur_flag <= next_flag;
					color_index <= next_color_index;
				end if;	
			end if;
		end process;
	
	
	process(cur_state, change, cur_flag, Vpos, Hpos, sHpos, sVpos, star_start, star, star_rows, star_cols, star_row_end)
		variable star_index_row : unsigned (11 downto 0) := X"000";
		variable star_index_col : unsigned (11 downto 0) := X"000";
		variable current_index : unsigned (11 downto 0) := X"000";
	begin
		sHpos <= Hpos - X"09F";
		sVpos <= Vpos - X"02D";
		next_flag <= cur_flag;
		next_star_start <= star_start;
		next_star_row <= star_row;
		next_star_column <= star_column;
		--if Vpos < X"02D" or Hpos < X"0A0" then --set anything less than 45 V and 160 H to black
		if Vpos < X"02B" or Hpos < X"0A0" then
		--if Vpos < X"12F" or Hpos < X"0FF" then --test value
			color <= Black;
			--color_index <= X"000";
		else
			color <= Orange; -- default color to be overridden
			case cur_flag is
				when france =>
					if Hpos < X"176" and Hpos > X"09F" then
						color <= lBlue;
					end if;
					if Hpos > X"175" and Hpos < X"24B" then
						color <= White;
					end if;
					if Hpos > X"24A" then
						color <= lRed;
					end if;
				when italy =>
					if Hpos < X"176" and Hpos > X"09F" then
						color <= cGreen;
					end if;
					if Hpos > X"175" and Hpos < X"24B" then
						color <= White;
					end if;
					if Hpos > X"24A" then
						color <= cRed;
					end if;
				when ireland =>
					if Hpos < X"176" and Hpos > X"09F" then
						color <= cGreen;
					end if;
					if Hpos > X"175" and Hpos < X"24B" then
						color <= White;
					end if;
					if Hpos > X"24A" then
						color <= Orange;
					end if;
				when belgium =>
					if Hpos < X"176" and Hpos > X"09F" then
						color <= Black;
					end if;
					if Hpos > X"175" and Hpos < X"24B" then
						color <= Yellow;
					end if;
					if Hpos > X"24A" then
						color <= lRed;
					end if;
				when mali =>
					if Hpos < X"176" and Hpos > X"09F" then
						color <= lGreen;
					end if;
					if Hpos > X"175" and Hpos < X"24B" then
						color <= Yellow;
					end if;
					if Hpos > X"24A" then
						color <= cRed;
					end if;
				when chad =>
					if Hpos < X"176" and Hpos > X"09F" then
						color <= cBlue;
					end if;
					if Hpos > X"175" and Hpos < X"24B" then
						color <= Yellow;
					end if;
					if Hpos > X"24A" then
						color <= cRed;
					end if;
				when nigeria =>
					if Hpos < X"176" and Hpos > X"09F" then
						color <= cGreen;
					end if;
					if Hpos > X"175" and Hpos < X"24B" then
						color <= White;
					end if;
					if Hpos > X"24A" then
						color <= cGreen;
					end if;
				when ivory =>
					if Hpos < X"176" and Hpos > X"09F" then
						color <= Orange;
					end if;
					if Hpos > X"175" and Hpos < X"24B" then
						color <= White;
					end if;
					if Hpos > X"24A" then
						color <= cGreen;
					end if;
				when poland =>
					if Vpos < X"11D" then
						color <= White;
					else
						color <= cRed;
					end if;
					
				when germany =>
					if Vpos < X"0CD" then
						color <= Black;
					end if;
					if Vpos > X"0CC" and Vpos < X"16D"then
						color <= lRed;
					end if;
					if Vpos > X"16C" then
						color <= Yellow;
					end if;
				when austria =>	
					if Vpos < X"0CD" then
						color <= lRed;
					end if;
					if Vpos > X"0CC" and Vpos < X"16D"then
						color <= White;
					end if;
					if Vpos > X"16C" then
						color <= lRed;
				   end if;
				when republic =>
					if (Hpos - X"09F") < (X"1E0" - (Vpos- X"02D")) then
						color <= cGreen;
					end if;
					if (Hpos - X"09F") >= (X"1E0" - (Vpos - X"02D")) and (Hpos - X"9F") <= ((X"27F")-(Vpos- X"02D")) then
						color <= Yellow;
					end if;
					if (Hpos - X"09F") > ((X"27F")-(Vpos- X"02D")) then
						color <= cRed;
					end if;
			end case;
		end if;
			
			
		case cur_state is
			when idle =>
				if change = '0' then
					next_state <= press;
				else
					next_state <= idle;
				end if;
			when press =>
				case cur_flag is
					when france =>
						next_flag <= italy;
					when italy =>
						next_flag <= ireland;
					when ireland =>
						next_flag <= belgium;
					when belgium =>
						next_flag <= mali;
					when mali =>
						next_flag <= chad;
					when chad =>
						next_flag <= nigeria;
					when nigeria =>
						next_flag <= ivory;
					when ivory =>
						next_flag <= poland;
					when poland =>
						next_flag <= germany;
					when germany =>
						next_flag <= austria;
					when austria =>	
						next_flag <= republic;
					when republic =>
						next_flag <= USA;
					when USA =>
						next_flag <= france;
				end case;
				next_state <= debounce;
			when debounce =>
				if change = '0' then
					next_state <= debounce;
				else
					next_state <= idle;
				end if;	
		end case;
	end process;
	 
	
end architecture behavioral;