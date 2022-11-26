library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab7 is
		
	port (
		MAX10_CLK1_50 : in std_logic;
		Key : in std_logic_vector(1 downto 0);
		VGA_B : out std_logic_vector(3 downto 0);
		VGA_G : out std_logic_vector(3 downto 0);
		VGA_HS : out std_logic;
		VGA_R : out std_logic_vector(3 downto 0);
		VGA_VS : out std_logic
		rand : in std_logic_vector(1 downto 0);
	);
	
end entity lab7;
	
architecture behavioral of lab7 is

	component pll IS
	PORT
	(
		areset		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC 
	);
	END component; 
	
	component Hsync is
	port
	(
		clk : in std_logic ;
		rst_l : in std_logic ;
		Hpos : out unsigned(11 downto 0);
		Hpulse : out std_logic := '1'
	);
	end component;
	
	component Vsync is 
	port
	(
		clk : in std_logic ;
		rst_l : in std_logic ;
		Vpos : out unsigned(11 downto 0);
		vpulse : out std_logic := '1'
	);
	end component;
	
	component Flags is
	port
	(
		clk : in std_logic;
		change : in std_logic := '1';
		rst_l : in std_logic := '1';
		start : in std_logic := '1';
		Hpos : in unsigned(11 downto 0);
		Vpos : in unsigned(11 downto 0);
		Red : out std_logic_vector(3 downto 0);
		Green : out std_logic_vector(3 downto 0);
		Blue : out std_logic_vector(3 downto 0)
	);
	end component;

signal pcount : unsigned(11 downto 0) := X"000"; --800 pixels per line, change Hstates.
signal pclk : std_logic; --pixel clock, 25Mhz
signal Vpos, Hpos : unsigned(11 downto 0);
signal Reg_Red, Reg_Green, Reg_Blue : std_logic_vector(3 downto 0);
signal Reg_VGA_HS, Reg_VGA_VS : std_logic;
--signal rand : std_logic_vector(1 downto 0);



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
			rst_l => key(0),
			Vpos => Vpos,
			Vpulse => Reg_VGA_VS
		);
	
	u2_Hsync : Hsync
		port map (
			clk => pclk,
			rst_l => key(0),
			Hpos => Hpos,
			Hpulse => Reg_VGA_HS
		);
	
	u3_Flags : Flags
		port map (
			clk => pclk,
			change => key(1),
			rst_l => key(0),
			start => key(1),
			Hpos => Hpos,
			Vpos => Vpos,
			Red => Reg_Red,
			Green => Reg_Green,
			Blue => Reg_Blue,
			rand => rand
		);
		
		process(pclk)
		begin
			if rising_edge(pclk) then
				VGA_R <= Reg_Red;
				VGA_G <= Reg_Green;
				VGA_B <= Reg_Blue;
				VGA_HS <= Reg_VGA_HS;
				VGA_VS <= Reg_VGA_VS;
			end if;
		end process;


end architecture behavioral;