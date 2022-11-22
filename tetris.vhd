library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity tetris is
		
	port (
		MAX10_CLK1_50 : in std_logic;
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
			);
			end component;
			
	component controller
		port (
			MAX10_CLK1_50 : in std_logic;
			
			);
			end component;
	
	component lab8 --ADC
	
		PORT
	(
	);
	end component;
	
	component lab7 --VGA
		PORT
	(

		rand : in std_logic_vector(1 downto 0);
	);
	END component;
	
	component rng
		PORT
	(
		MAX10_CLK1_50 : in std_logic;
		KEY : in std_logic_vector(1 downto 0);
		rand : out std_logic_vector(1 downto 0);
	);
	END component;
	
	signal rand : std_logic_vector(1 downto 0);
	--signal rst : std_logic;
	--signal clk5, clk12 :std_logic;
	--signal fifo_re, fifo_we, fifo_mt : std_logic ;  --?????????????????????? consider not initializing this line
	--signal fifo_level : std_logic_vector(2 downto 0);
	--signal fifo_wdata, fifo_rdata : std_logic_vector(9 downto 0);

begin
		
		
		u0_buzzer : buzzer
			port map (
				);
				
		u1_controller : controller
			port map (
				MAX10_CLK1_50 => MAX10_CLK1_50,
				rand => rand,
				);
				
		u2_lab8 : lab8 --ADC
			port map (
				);
				
		u3_lab7 : lab7 --VGA
			port map (
			
				rand => rand
				);
				
		u4_rng : rng 
			port map (
				MAX10_CLK1_50 => MAX10_CLK1_50,
				KEY => KEY,
				rand => rand
				);
				
		
	
	
	
	
end architecture behavioral;