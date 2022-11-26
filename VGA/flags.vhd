library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity Flags is
		
	port (
		clk : in std_logic;
		change : in std_logic := '1';
		rst_l : in std_logic := '1';
		start : in std_logic := '1';
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
	

type statetype is (initial, play, terminate);
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

	
	--bring future to present
	process (clk)
		begin
			if rising_edge(clk) then
				if rst_l = '0' then
					cur_state <= start;
					--color_index <= X"000";
				else
					cur_state <= next_state;
					--color_index <= next_color_index;
				end if;	
			end if;
		end process;
	
	--set the future
	process()
	begin
		case cur_state is
			when initial =>
			next_state <= initial;
				--set the screen dimensions and initial cube
				if start = '0' then
					next_state <= play;
				end if;
			when play =>
			next_state <= play;
				--set play logic
				
				if --end conditions met--
					next_state <= terminate;
				end if;
			
			
			when terminate =>
			next_state <= terminate;
				--set terminate logic
				--no logic required to transition as it is handled in reset above.
				
			when others =>
				next_state <= initial;
			end case;
	end process;
	 
	
end architecture behavioral;