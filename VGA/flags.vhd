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
		Blue : out std_logic_vector(3 downto 0)
	);
	
end entity Flags;
	
architecture behavioral of Flags is

type colorme is array(0 to 9) of std_logic_vector(11 downto 0); --add more colors if necessary
signal display : colorme := (X"000", X"FFF", X"F00", X"00F", X"FF0", X"080", X"F50", X"A00", X"0C0", X"00A");

type colors is (Black, White, cRed, cBlue, Yellow, cGreen, Orange, lRed, lGreen, lBlue);
signal color, next_color : colors;

signal color_index, next_color_index : unsigned(11 downto 0);
	

type flags is (france, italy, ireland, belgium, mali, chad, nigeria, ivory, poland, germany, austria, republic, USA);
signal cur_flag, next_flag : flags := france;

type statetype is (idle, press, debounce);
signal cur_state, next_state : statetype;

signal sHpos : unsigned(11 downto 0) := X"000";
signal sVpos : unsigned(11 downto 0) := X"000";
--signal star_column : unsigned( 28 downto 0 ) := X"000";
signal star_column, next_star_column : natural range 0 to 28 := 0;
--signal star_row : unsigned(36 downto 0) := X"000";
signal star_row, next_star_row : integer range 0 to 36 := 0;
signal star_start, next_star_start, star_row_end, next_star_row_end : std_logic := '1';

type Tstar_rows is array(0 to 49) of unsigned(11 downto 0);
signal star_rows : Tstar_rows := (
    X"00B", --row 0 (px 11) (6)
    X"00B",
    X"00B",
    X"00B",
    X"00B",
    X"00B",
    X"025", --row 1 (px 37) (5)
    X"025",
    X"025",
    X"025",
    X"025",
    X"03F", --row 2 (px 63) (6)
    X"03F",
    X"03F",
    X"03F",
    X"03F",
    X"03F",
    X"059", --row 3 (px 89) (5)
    X"059",
    X"059",
    X"059",
    X"059",
    X"073", --row 4 (px 115) (6)
    X"073",
    X"073",
    X"073",
    X"073",
    X"073",
    X"08D", --row 5 (px 141) (5)
    X"08D",
    X"08D",
    X"08D",
    X"08D",
    X"0A7", --row 6 (px 167) (6)
    X"0A7",
    X"0A7",
    X"0A7",
    X"0A7",
    X"0A7",
    X"0C1", --row 7 (px 193) (5)
    X"0C1",
    X"0C1",
    X"0C1",
    X"0C1",
    X"0DB", --row 8 (px 219) (6)
    X"0DB",
    X"0DB",
    X"0DB",
    X"0DB",
    X"0DB"
);


type Tstar_cols is array(0 to 49) of unsigned(11 downto 0);
signal star_cols : Tstar_cols := (
    X"00B", --col 0 (px 11) (6) - 0
    X"036", --col 1 (px 54) (6) - 1
    X"061", --col 2 (px 97) (6) - 2
    X"08C", --col 3 (px 140) (6) - 3
    X"0B7", --col 4 (px 183) (6) - 4
    X"0E2", --col 5 (px 226) (6) - 5
    X"020", --col 0 (px 32) (5) - 6
    X"04B", --col 1 (px 75) (5) - 7
    X"076", --col 2 (px 118) (5) - 8
    X"0A1", --col 3 (px 161) (5) - 9
    X"0CC", --col 4 (px 204) (5) - 10
    X"00B", --col 0 (px 11) (6) - 11
    X"036", --col 1 (px 54) (6) - 12
    X"061", --col 2 (px 97) (6) - 13
    X"08C", --col 3 (px 140) (6) - 14
    X"0B7", --col 4 (px 183) (6) - 15
    X"0E2", --col 5 (px 226) (6) - 16
    X"020", --col 0 (px 32) (5) - 17
    X"04B", --col 1 (px 75) (5) - 18
    X"076", --col 2 (px 118) (5) - 19
    X"0A1", --col 3 (px 161) (5) - 20 
    X"0CC", --col 4 (px 204) (5) - 21
    X"00B", --col 0 (px 11) (6) - 22
    X"036", --col 1 (px 54) (6) - 23
    X"061", --col 2 (px 97) (6) - 24
    X"08C", --col 3 (px 140) (6) - 25
    X"0B7", --col 4 (px 183) (6) - 26
    X"0E2", --col 5 (px 226) (6) - 27
    X"020", --col 0 (px 32) (5) - 28
    X"04B", --col 1 (px 75) (5) - 29
    X"076", --col 2 (px 118) (5) - 30
    X"0A1", --col 3 (px 161) (5) - 31
    X"0CC", --col 4 (px 204) (5) - 32
    X"00B", --col 0 (px 11) (6) - 33
    X"036", --col 1 (px 54) (6) - 34
    X"061", --col 2 (px 97) (6) - 35
    X"08C", --col 3 (px 140) (6) - 36
    X"0B7", --col 4 (px 183) (6) - 37
    X"0E2", --col 5 (px 226) (6) - 38
    X"020", --col 0 (px 32) (5) - 39
    X"04B", --col 1 (px 75) (5) - 40
    X"076", --col 2 (px 118) (5) - 41
    X"0A1", --col 3 (px 161) (5) - 42
    X"0CC", --col 4 (px 204) (5) - 43
    X"00B", --col 0 (px 11) (6) - 44
    X"036", --col 1 (px 54) (6) - 45
    X"061", --col 2 (px 97) (6) - 46
    X"08C", --col 3 (px 140) (6) - 47
    X"0B7", --col 4 (px 183) (6) - 48
    X"0E2" --col 5 (px 226) (6) - 49
	);

type starmap is array(0 to 36, 0 to 28) of std_logic;

signal star : starmap := (
('0','0','0','0','0','0','0','0','0','0','0','0','0','0','1','0','0','0','0','0','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','0','0','0','0','0','1','0','0','0','0','0','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','0','0','0','0','0','1','0','0','0','0','0','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','0','0','0','0','1','1','1','0','0','0','0','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','0','0','0','0','1','1','1','0','0','0','0','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','0','0','0','0','1','1','1','0','0','0','0','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','0','0','0','1','1','1','1','1','0','0','0','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','0','0','0','1','1','1','1','1','0','0','0','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','0','0','0','1','1','1','1','1','0','0','0','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','0','0','0','1','1','1','1','1','0','0','0','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','0','0','1','1','1','1','1','1','1','0','0','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','0','0','1','1','1','1','1','1','1','0','0','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','0','0','1','1','1','1','1','1','1','0','0','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','0','0','1','1','1','1','1','1','1','0','0','0','0','0','0','0','0','0','0','0'),
('1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1'),
('0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0'),
('0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0'),
('0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0'),
('0','0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0','0'),
('0','0','0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0','0','0'),
('0','0','0','0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','1','1','1','1','1','1','1','1','1','1','1','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','1','1','1','1','1','1','1','1','1','1','1','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','1','1','1','1','1','1','1','0','1','1','1','1','1','1','1','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','1','1','1','1','1','1','0','0','0','1','1','1','1','1','1','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','1','1','1','1','1','0','0','0','0','0','1','1','1','1','1','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','1','1','1','1','0','0','0','0','0','0','0','1','1','1','1','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','1','1','1','0','0','0','0','0','0','0','0','0','1','1','1','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','1','1','1','0','0','0','0','0','0','0','0','0','0','0','1','1','1','0','0','0','0','0','0'),
('0','0','0','0','0','0','1','1','0','0','0','0','0','0','0','0','0','0','0','0','0','1','1','0','0','0','0','0','0'),
('0','0','0','0','0','0','1','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','1','0','0','0','0','0','0')
);

begin

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
				when USA =>
					--Stripes
					if Vpos > X"02A" and Vpos < X"052" then
						color <= lRed;
					end if;
					if Vpos >= X"052" and Vpos < X"077" then
						color <= White;
					end if;
					if Vpos >= X"077" and Vpos < X"09C" then
						color <= lRed;
					end if;
					if Vpos >= X"09C" and Vpos < X"0C1" then
						color <= White;
					end if;
					if Vpos >= X"0C1" and Vpos < X"0E6" then
						color <= lRed;
					end if;
					if Vpos >= X"0E6" and Vpos < X"10B" then
						color <= White;
					end if;
					if Vpos >= X"10B" and Vpos < X"130" then
						color <= lRed;
					end if;
					if Vpos >= X"130" and Vpos < X"155" then
						color <= White;
					end if;
					if Vpos >= X"155" and Vpos < X"17A" then
						color <= lRed;
					end if;
					if Vpos >= X"17A" and Vpos < X"19F" then
						color <= White;
					end if;
					if Vpos >= X"19F" and Vpos < X"1C4" then
						color <= lRed;
					end if;
					if Vpos >= X"1C4" and Vpos < X"1E9" then
						color <= White;
					end if;
					if Vpos >= X"1E6" then
						color <= lRed;
					end if;
					
					--Blue Box
					if Hpos > X"09F" and Hpos < X"19F" and Vpos > X"02A" and Vpos < X"130" then
						color <= cBlue;
					end if;
					
					----stars 25 x 36 should be 37
					
					for i in 0 to 49 loop
						if (Hpos-X"09F") > star_cols(i) and (Hpos-X"09F") < (star_cols(i) + X"1D") and (Vpos-X"02D") > star_rows(i) and (Vpos-X"02D") < star_rows(i) + X"24" then
							current_index := star_cols(i);
							star_index_col := (Hpos - X"09F") - current_index;
							current_index := star_rows(i);
							star_index_row := (Vpos - X"02D") - current_index;
							if star(to_integer(star_index_row),to_integer(star_index_col)) = '1' then
								color <= White;
							end if;
						end if;
					end loop;
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