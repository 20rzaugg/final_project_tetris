library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.tetris_types.all;


entity tetris is
		
	port (
		MAX10_CLK1_50 : in std_logic;
		ADC_CLK_10 : in std_logic;
		KEY : in std_logic_vector(1 downto 0); --rst_l --add
		VGA_B : out std_logic_vector(3 downto 0);
		VGA_G : out std_logic_vector(3 downto 0);
		VGA_HS : out std_logic;
		VGA_R : out std_logic_vector(3 downto 0);
		VGA_VS : out std_logic;
		ARDUINO_IO : inout std_logic_vector(15 downto 0); --input the continuous voltage data on the first pin and command channel.
	   	ARDUINO_RESET_N : inout std_logic	
	);
	
end entity tetris;
	
architecture behavioral of tetris is 

	component buzzer
	port (
		clk_50 : in std_logic;
		rst_l : in std_logic;
		sw : in std_logic_vector(3 downto 0);
		sound_selector : unsigned(2 downto 0); --0 = silence, 1 = click1, 2 = click2, 3 = game start, 4 = game over
		buzzer : out std_logic
	);
	end component;
			
	component controller port (
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
	end component;
	
	component lab8 --ADC
		PORT
	(
		ADC_CLK_10 : in std_logic;
		KEY : in std_logic_vector(1 downto 0);
		ARDUINO_IO : inout std_logic_vector(15 downto 0); --input the continuous voltage data on the first pin and command channel.
	   	ARDUINO_RESET_N : inout std_logic;
		BoxPosition : out std_logic_vector(11 downto 0)
	);
	end component;
	
	component screen_manager is port (
        MAX10_CLK1_50 : in std_logic;
		Blue : out std_logic_vector(3 downto 0);
		Green : out std_logic_vector(3 downto 0);
		Red : out std_logic_vector(3 downto 0);
		VGA_HS : out std_logic;
		VGA_VS : out std_logic;
		rst_l : in std_logic := '1';
        blockArray : in tetris_block_array;
		falling_block : in unsigned(3 downto 0);
		falling_block_col : in unsigned(3 downto 0);
		falling_block_row : in unsigned(3 downto 0);
		score_in : in unsigned(19 downto 0)
	);
	end component;
	
	component rng
		PORT
	(
		MAX10_CLK1_50 : in std_logic;
		KEY : in std_logic_vector(1 downto 0);
		rand : out std_logic_vector(1 downto 0)
	);
	END component;
	
	
	
	signal rand : std_logic_vector(1 downto 0);
	signal BoxPosition : std_logic_vector(11 downto 0);
	signal blockArray : tetris_block_array;
	signal score : unsigned(19 downto 0);
	signal falling_block_row : unsigned(3 downto 0);
	signal falling_block_col : unsigned(3 downto 0);
	signal falling_block : unsigned(3 downto 0);
	--signal rst : std_logic;
	--signal clk5, clk12 :std_logic;
	--signal fifo_re, fifo_we, fifo_mt : std_logic ;  --?????????????????????? consider not initializing this line
	--signal fifo_level : std_logic_vector(2 downto 0);
	--signal fifo_wdata, fifo_rdata : std_logic_vector(9 downto 0);

begin
		
		
		--u0_buzzer : buzzer
		--	port map (
		--		);
				
		u1_controller : controller port map (
			MAX10_CLK1_50 => MAX10_CLK1_50,
			Key => key,
			BoxPosition => BoxPosition,
			blockArray => blockArray,
			falling_block => falling_block,
			falling_block_col => falling_block_col,
			falling_block_row => falling_block_row,
			score => score,
			rand => rand
		);
				
		u2_lab8 : lab8 --ADC
			port map (
				ADC_CLK_10 => ADC_CLK_10,
				KEY => KEY,
				ARDUINO_IO => ARDUINO_IO,
				ARDUINO_RESET_N => ARDUINO_RESET_N,
				BoxPosition => BoxPosition
			);
				
		u3_vga : screen_manager --VGA
			port map (
            MAX10_CLK1_50 => MAX10_CLK1_50,
		       Blue => VGA_B,
		       Green => VGA_G,
		       Red => VGA_R,
		       VGA_HS => VGA_HS,
		       VGA_VS => VGA_VS,
		       rst_l => key(0),
             blockArray => blockArray,
		       falling_block => falling_block,
		       falling_block_col => falling_block_col,
		       falling_block_row => falling_block_row,
		       score_in => score
	);
				
		u4_rng : rng port map (
			MAX10_CLK1_50 => MAX10_CLK1_50,
			KEY => KEY,
			rand => rand
		);
				
	
end architecture behavioral;