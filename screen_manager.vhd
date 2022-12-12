library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
library work;
use work.tetris_types.all;

entity screen_manager is
		
	port (

        MAX10_CLK1_50 : in std_logic;
		Blue : out std_logic_vector(3 downto 0);
		Green : out std_logic_vector(3 downto 0);
		Red : out std_logic_vector(3 downto 0);
		VGA_HS : out std_logic;
		VGA_VS : out std_logic;
		rst_l : in std_logic;
        blockArray : in tetris_block_array;
		falling_block : in unsigned(3 downto 0);
		falling_block_col : in unsigned(3 downto 0);
		falling_block_y : in unsigned(11 downto 0);
		score_in : in score_digits_array
	);
	
end entity screen_manager;
	
architecture behavioral of screen_manager is

    component vgapll is port (
        areset : in std_logic := '0';
        inclk0 : in std_logic := '0';
        c0 : out std_logic 
    );
    end component; 
        
    component Hsync is port (
        clk : in std_logic;
        rst_l : in std_logic;
        Hpos : out unsigned(11 downto 0);
        Hpulse : out std_logic := '1'
    );
    end component;
        
    component Vsync is port (
        clk : in std_logic ;
        rst_l : in std_logic ;
        Vpos : out unsigned(11 downto 0);
        vpulse : out std_logic := '1'
    );
    end component;
	
type colorme is array(0 to 5) of std_logic_vector(11 downto 0); --add more colors if necessary
signal display : colorme := (X"000", X"FFF", X"F00", X"00F", X"080", X"FF0");

type colors is (Black, White, cRed, cBlue, cGreen, Yellow);
signal color : colors;
signal next_color : colors;
signal boxColor : colors;
signal color_index, next_color_index : unsigned(11 downto 0);

signal Hpos : unsigned(11 downto 0);
signal Vpos : unsigned(11 downto 0);
signal pclk : std_logic; --pixel clock, 25Mhz

signal score_digits : score_digits_array;
signal x : unsigned(11 downto 0);
signal y : unsigned(11 downto 0);

type numberfont is array(0 to 9, 0 to 16, 0 to 11) of std_logic;
signal numbers : numberfont := (
    (
        --0
        ('0','0','0','0','1','1','1','1','0','0','0','0'),
        ('0','0','0','1','1','1','1','1','1','0','0','0'),
        ('0','0','1','1','0','0','0','0','1','1','0','0'),
        ('0','1','1','1','0','0','0','0','1','1','1','0'),
        ('0','1','1','0','0','0','0','0','1','1','1','0'),
        ('0','1','1','0','0','0','0','1','1','1','1','0'),
        ('1','1','1','0','0','0','1','1','1','1','1','1'),
        ('1','1','1','0','0','1','1','1','1','1','1','1'),
        ('1','1','1','0','1','1','1','1','0','1','1','1'),
        ('1','1','1','1','1','1','1','0','0','1','1','1'),
        ('1','1','1','1','1','1','0','0','0','1','1','1'),
        ('0','1','1','1','1','0','0','0','0','1','1','0'),
        ('0','1','1','1','0','0','0','0','0','1','1','0'),
        ('0','1','1','1','0','0','0','0','1','1','1','0'),
        ('0','0','1','1','0','0','0','0','1','1','0','0'),
        ('0','0','0','1','1','1','1','1','1','0','0','0'),
        ('0','0','0','0','1','1','1','1','0','0','0','0')
    ),
    (
        --1
        ('0','0','0','1','1','1','1','0','0','0','0','0'),
        ('0','0','0','1','1','1','1','0','0','0','0','0'),
        ('0','0','0','0','0','1','1','0','0','0','0','0'),
        ('0','0','0','0','0','1','1','0','0','0','0','0'),
        ('0','0','0','0','0','1','1','0','0','0','0','0'),
        ('0','0','0','0','0','1','1','0','0','0','0','0'),
        ('0','0','0','0','0','1','1','0','0','0','0','0'),
        ('0','0','0','0','0','1','1','0','0','0','0','0'),
        ('0','0','0','0','0','1','1','0','0','0','0','0'),
        ('0','0','0','0','0','1','1','0','0','0','0','0'),
        ('0','0','0','0','0','1','1','0','0','0','0','0'),
        ('0','0','0','0','0','1','1','0','0','0','0','0'),
        ('0','0','0','0','0','1','1','0','0','0','0','0'),
        ('0','0','0','0','0','1','1','0','0','0','0','0'),
        ('0','0','0','0','0','1','1','0','0','0','0','0'),
        ('0','0','0','1','1','1','1','1','1','0','0','0'),
        ('0','0','0','1','1','1','1','1','1','0','0','0')
    ),
    (
        --2
        ('0','0','0','0','1','1','1','1','0','0','0','0'),
        ('0','0','1','1','1','1','1','1','1','1','0','0'),
        ('0','1','1','1','0','0','0','1','1','1','0','0'),
        ('0','1','1','0','0','0','0','0','1','1','1','0'),
        ('0','1','1','0','0','0','0','0','1','1','1','0'),
        ('0','1','1','0','0','0','0','0','1','1','1','0'),
        ('0','0','0','0','0','0','0','0','1','1','0','0'),
        ('0','0','0','0','0','0','0','1','1','1','0','0'),
        ('0','0','0','0','0','1','1','1','1','0','0','0'),
        ('0','0','0','0','1','1','1','0','0','0','0','0'),
        ('0','0','0','1','1','1','0','0','0','0','0','0'),
        ('0','0','1','1','1','0','0','0','0','1','1','0'),
        ('0','1','1','1','0','0','0','0','0','1','1','0'),
        ('0','1','1','0','0','0','0','0','0','1','1','0'),
        ('0','1','1','0','0','0','0','0','0','1','1','0'),
        ('0','1','1','1','1','1','1','1','1','1','1','0'),
        ('0','1','1','1','1','1','1','1','1','1','1','0')
    ),
    (
        --3
        ('0','0','0','0','1','1','1','1','0','0','0','0'),
        ('0','0','1','1','1','1','1','1','1','1','0','0'),
        ('0','0','1','1','0','0','0','0','1','1','0','0'),
        ('0','1','1','1','0','0','0','0','1','1','1','0'),
        ('0','1','1','0','0','0','0','0','0','1','1','0'),
        ('0','0','0','0','0','0','0','0','1','1','1','0'),
        ('0','0','0','0','0','0','0','0','1','1','0','0'),
        ('0','0','0','0','1','1','1','1','1','0','0','0'),
        ('0','0','0','0','1','1','1','1','1','0','0','0'),
        ('0','0','0','0','0','0','0','0','1','1','1','0'),
        ('0','0','0','0','0','0','0','0','0','1','1','0'),
        ('1','1','0','0','0','0','0','0','0','1','1','1'),
        ('1','1','1','0','0','0','0','0','0','1','1','1'),
        ('0','1','1','0','0','0','0','0','0','1','1','0'),
        ('0','1','1','1','0','0','0','0','1','1','1','0'),
        ('0','0','1','1','1','1','1','1','1','1','0','0'),
        ('0','0','0','0','1','1','1','1','0','0','0','0')
    ),
    (
        --4
        ('0','0','0','0','0','0','0','1','1','0','0','0'),
        ('0','0','0','0','0','0','1','1','1','0','0','0'),
        ('0','0','0','0','0','1','1','1','1','0','0','0'),
        ('0','0','0','0','0','1','1','1','1','0','0','0'),
        ('0','0','0','0','1','1','0','1','1','0','0','0'),
        ('0','0','0','1','1','1','0','1','1','0','0','0'),
        ('0','0','0','1','1','0','0','1','1','0','0','0'),
        ('0','0','1','1','0','0','0','1','1','0','0','0'),
        ('0','1','1','1','0','0','0','1','1','0','0','0'),
        ('0','1','1','0','0','0','0','1','1','0','0','0'),
        ('1','1','1','1','1','1','1','1','1','1','1','0'),
        ('0','1','1','1','1','1','1','1','1','1','1','0'),
        ('0','0','0','0','0','0','0','1','1','0','0','0'),
        ('0','0','0','0','0','0','0','1','1','0','0','0'),
        ('0','0','0','0','0','0','0','1','1','0','0','0'),
        ('0','0','0','0','0','1','1','1','1','1','0','0'),
        ('0','0','0','0','0','1','1','1','1','1','0','0')
    ),
    (
        --5
        ('0','0','1','1','1','1','1','1','1','1','1','0'),
        ('0','1','1','1','1','1','1','1','1','1','1','0'),
        ('0','1','1','0','0','0','0','0','0','0','0','0'),
        ('0','1','1','0','0','0','0','0','0','0','0','0'),
        ('0','1','1','0','0','0','0','0','0','0','0','0'),
        ('0','1','1','0','0','0','0','0','0','0','0','0'),
        ('0','1','1','0','0','0','0','0','0','0','0','0'),
        ('0','1','1','0','1','1','1','1','1','0','0','0'),
        ('0','1','1','1','1','1','1','1','1','1','0','0'),
        ('0','1','1','1','0','0','0','0','1','1','1','0'),
        ('0','0','1','0','0','0','0','0','0','1','1','0'),
        ('0','0','0','0','0','0','0','0','0','1','1','0'),
        ('0','1','1','0','0','0','0','0','0','1','1','1'),
        ('0','1','1','0','0','0','0','0','0','1','1','0'),
        ('0','1','1','1','0','0','0','0','1','1','1','0'),
        ('0','0','1','1','1','1','1','1','1','1','0','0'),
        ('0','0','0','0','1','1','1','1','0','0','0','0')
    ),
    (
        --6
        ('0','0','0','0','1','1','1','1','0','0','0','0'),
        ('0','0','0','1','1','1','1','1','1','1','0','0'),
        ('0','0','1','1','0','0','0','0','1','1','0','0'),
        ('0','0','1','1','0','0','0','0','0','1','1','0'),
        ('0','1','1','0','0','0','0','0','0','1','1','0'),
        ('0','1','1','0','0','0','0','0','0','0','0','0'),
        ('0','1','1','0','0','1','1','1','0','0','0','0'),
        ('0','1','1','1','1','1','1','1','1','1','0','0'),
        ('0','1','1','1','1','1','1','1','1','1','1','0'),
        ('0','1','1','1','0','0','0','0','0','1','1','0'),
        ('0','1','1','0','0','0','0','0','0','1','1','0'),
        ('0','1','1','0','0','0','0','0','0','1','1','0'),
        ('0','1','1','0','0','0','0','0','0','1','1','0'),
        ('0','0','1','1','0','0','0','0','0','1','1','0'),
        ('0','0','1','1','1','0','0','0','1','1','0','0'),
        ('0','0','0','1','1','1','1','1','1','1','0','0'),
        ('0','0','0','0','1','1','1','1','0','0','0','0')
    ),
    (
        --7
        ('0','1','1','1','1','1','1','1','1','1','1','0'),
        ('0','1','1','1','1','1','1','1','1','1','1','0'),
        ('0','1','1','0','0','0','0','0','1','1','1','0'),
        ('0','1','1','0','0','0','0','0','1','1','0','0'),
        ('0','1','1','0','0','0','0','1','1','1','0','0'),
        ('0','0','0','0','0','0','0','1','1','0','0','0'),
        ('0','0','0','0','0','0','1','1','1','0','0','0'),
        ('0','0','0','0','0','0','1','1','0','0','0','0'),
        ('0','0','0','0','0','0','1','1','0','0','0','0'),
        ('0','0','0','0','0','1','1','1','0','0','0','0'),
        ('0','0','0','0','0','1','1','0','0','0','0','0'),
        ('0','0','0','0','0','1','1','0','0','0','0','0'),
        ('0','0','0','0','0','1','1','0','0','0','0','0'),
        ('0','0','0','0','1','1','1','0','0','0','0','0'),
        ('0','0','0','0','1','1','1','0','0','0','0','0'),
        ('0','0','1','1','1','1','1','1','1','0','0','0'),
        ('0','0','1','1','1','1','1','1','1','0','0','0')
    ),
    (
        --8
        ('0','0','0','0','1','1','1','1','1','0','0','0'),
        ('0','0','1','1','1','1','1','1','1','1','0','0'),
        ('0','1','1','1','0','0','0','0','1','1','1','0'),
        ('0','1','1','0','0','0','0','0','0','1','1','0'),
        ('0','1','1','0','0','0','0','0','0','1','1','0'),
        ('0','1','1','0','0','0','0','0','0','1','1','0'),
        ('0','1','1','1','0','0','0','0','1','1','1','0'),
        ('0','0','1','1','1','1','1','1','1','1','0','0'),
        ('0','0','0','1','1','1','1','1','1','0','0','0'),
        ('0','1','1','1','0','0','0','0','1','1','1','0'),
        ('0','1','1','0','0','0','0','0','0','1','1','0'),
        ('1','1','1','0','0','0','0','0','0','1','1','1'),
        ('1','1','1','0','0','0','0','0','0','1','1','1'),
        ('1','1','1','0','0','0','0','0','0','1','1','1'),
        ('0','1','1','1','0','0','0','0','1','1','1','0'),
        ('0','0','1','1','1','1','1','1','1','1','0','0'),
        ('0','0','0','0','1','1','1','1','0','0','0','0')
    ),
    (
        --9
        ('0','0','0','1','1','1','1','1','0','0','0','0'),
        ('0','0','1','1','1','1','1','1','1','0','0','0'),
        ('0','1','1','1','0','0','0','1','1','1','0','0'),
        ('0','1','1','0','0','0','0','0','1','1','0','0'),
        ('1','1','1','0','0','0','0','0','1','1','1','0'),
        ('1','1','1','0','0','0','0','0','0','1','1','0'),
        ('1','1','1','0','0','0','0','0','0','1','1','0'),
        ('0','1','1','0','0','0','0','0','1','1','1','0'),
        ('0','1','1','1','1','1','1','1','1','1','1','0'),
        ('0','0','1','1','1','1','1','1','0','1','1','0'),
        ('0','0','0','0','1','1','0','0','0','1','1','0'),
        ('0','0','0','0','0','0','0','0','0','1','1','0'),
        ('0','1','1','0','0','0','0','0','1','1','1','0'),
        ('0','1','1','0','0','0','0','0','1','1','0','0'),
        ('0','1','1','1','0','0','0','1','1','1','0','0'),
        ('0','0','1','1','1','1','1','1','1','0','0','0'),
        ('0','0','0','1','1','1','1','1','0','0','0','0')
    )
);
type col_positions_type is array(0 to 8) of unsigned(11 downto 0);
signal col_positions : col_positions_type := (X"0B2", X"0D2", X"0F2", X"112", X"132", X"152", X"172", X"192", X"1B2");

type row_positions_type is array(0 to 13) of unsigned(11 downto 0);
    signal row_positions : row_positions_type := (X"1B0", X"190", X"170", X"150", X"130", X"110", X"0F0", X"0D0", X"0B0", X"090", X"070", X"050", X"030", X"010");

begin			
	
    u0_pll : VGApll
		port map (
			areset => '0',
			inclk0 => MAX10_CLK1_50,
			c0 => pclk
		);
	u1_Vsync : Vsync
		port map (
			clk => pclk,
			rst_l => rst_l,
			Vpos => Vpos,
			Vpulse => VGA_VS
		);
	
	u2_Hsync : Hsync
		port map (
			clk => pclk,
			rst_l => rst_l,
			Hpos => Hpos,
			Hpulse => VGA_HS
		);

	x <= Hpos-X"09F";
	y <= Vpos-X"02D";
	
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
			when cGreen =>
				next_color_index <= X"004";
			when Yellow =>
				next_color_index <= X"005";
		end case;
	end process;

	Blue <= display(to_integer(color_index))(3 downto 0);
	Green <= display(to_integer(color_index))(7 downto 4);
	Red <= display(to_integer(color_index))(11 downto 8);

	
	--bring future to present
	process (pclk)
		begin
			if rising_edge(pclk) then
				if rst_l = '0' then
					color_index <= X"000";
				else
					color_index <= next_color_index;
				end if;	
			end if;
		end process;
	

	--set the future
	process(Hpos, x, y, Vpos, numbers, score_digits, blockArray, falling_block, falling_block_y, falling_block_col) 
        variable lh_X : integer := 0;
        variable lh_Y : integer := 0;
    begin
		if Vpos < X"02B" or Hpos < X"0A0" then
			color <= Black;
		else
				color <= Black;
				--1px U shape
				if (x = 176 and y >= 16 and y <= 463) then
					color <= White;
				end if;
				if (x = 465 and y >= 16 and y <= 463) then	
					color <= White;
				end if;
				if (y = 464 and x >= 176 and x <= 464) then
					color <= White;
				end if;
				--hundred_thousands digit
				if (y >= 231 and y < 248 and x >= 506 and x <= 517) then
					if (numbers(to_integer(score_digits(0)), to_integer(y-X"0E7"), to_integer(x-X"1FA")) = '1') then
						color <= White;
					end if;
				end if;
				--ten_thousands digit
				if (y >= 231 and y < 248 and x >= 522 and x <= 533) then
					if (numbers(to_integer(score_digits(1)), to_integer(y-X"0E7"), to_integer(x-X"20A")) = '1') then
						color <= White;
					end if;
				end if;
				--thousands digit
				if (y >= 231 and y < 248 and x >= 538 and x <= 549) then
					if numbers(to_integer(score_digits(2)), to_integer(y-X"0E7"), to_integer(x-X"21A")) = '1' then
						color <= White;
					end if;
				end if;
				--hundreds digit
				if (y >= 231 and y < 248 and x >= 554 and x <= 565) then
					if (numbers(to_integer(score_digits(3)), to_integer(y-X"0E7"), to_integer(x-X"22A")) = '1') then
						color <= White;
					end if;
				end if;
				--tens digit
				if (y >= 231 and y < 248 and x >= 570 and x <= 581) then
					if (numbers(to_integer(score_digits(4)), to_integer(y-X"0E7"), to_integer(x-X"23A")) = '1') then
						color <= White;
					end if;
				end if;
				--ones digit
				if (y >= 231 and y < 248 and x >= 586 and x <= 597) then
					if (numbers(to_integer(score_digits(5)), to_integer(y-X"0E7"), to_integer(x-X"24A")) = '1') then
						color <= White;
					end if;
				end if;

               --paint blocks in block array
               for i in 0 to 11 loop
                   for j in 0 to 8 loop
                       if(y >= row_positions(i) and y <= row_positions(i)+X"1D" and x >= col_positions(j) and x <= col_positions(j)+X"1D") then
                           case blockArray(i, j) is
                               when X"0" =>
                                   color <= Black;
                               when X"1" =>
                                   color <= cRed;
                               when X"2" =>
                                   color <= cBlue;
                               when X"3" =>
                                   color <= cGreen;
                               when X"4" =>
                                   color <= Yellow;
										  when others =>
												color <= Black;
                           end case;
                       end if;
                       lh_X := lh_X + 16;
                   end loop;
                   lh_Y := lh_Y + 16;
               end loop;
               --paint falling block
               if(y >= falling_block_y and y <= falling_block_y+X"1D" and x >= col_positions(to_integer(falling_block_col)) and x <= col_positions(to_integer(falling_block_col))+X"1D") then
                   case falling_block is
                       when X"0" =>
                           color <= Black;
                       when X"1" =>
                           color <= cRed;
                       when X"2" =>
                           color <= cBlue;
                       when X"3" =>
                           color <= cGreen;
                       when X"4" =>
                           color <= Yellow;
					   when others =>
						   color <= Black;
                   end case;
               end if;
			end if;
	end process;
	 
end architecture behavioral;