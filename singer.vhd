library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity singer is port (
	clk_50 : in std_logic;
	rst_l : in std_logic;
	sw : in std_logic_vector(3 downto 0);
	sound_selector : unsigned(2 downto 0); --0 = silence, 1 = click1, 2 = click2, 3 = game start, 4 = game over
	buzzer : out std_logic;
)
end entity;

architecture behavioral of singer is
	signal notes : array(0 to 87) of unsigned(19 downto 0) := (
		X"DDF23", --  0 - A0
		X"D1747", --  1 - A#0
		X"C5B78", --  2 - B0
		X"BAA6E", --  3 - C1
		X"B025D", --  4 - C#1
		X"A6435", --  5 - D1
		X"9CF17", --  6 - D#1
		X"9424C", --  7 - E1
		X"8BD42", --  8 - F1
		X"83F7D", --  9 - F#1
		X"7C8FC", -- 10 - G1
		X"75943", -- 11 - G#1
		X"6EF91", -- 12 - A1
		X"68BED", -- 13 - A#1
		X"62DBC", -- 14 - B1
		X"5D4FD", -- 15 - C2
		X"5812E", -- 16 - C#2
		X"5321B", -- 17 - D2
		X"4E78B", -- 18 - D#2
		X"4A101", -- 19 - E2
		X"45E80", -- 20 - F2
		X"41FBE", -- 21 - F#2
		X"3E47E", -- 22 - G2
		X"3AC8A", -- 23 - G#2
		X"377C9", -- 24 - A2
		X"345F7", -- 25 - A#2
		X"316EE", -- 26 - B2
		X"2EA8D", -- 27 - C3
		X"2C0A4", -- 28 - C#3
		X"29919", -- 29 - D3
		X"273C6", -- 30 - D#3
		X"2508A", -- 31 - E3
		X"22F48", -- 32 - F3
		X"20FDF", -- 33 - F#3
		X"1F23F", -- 34 - G3
		X"1D64B", -- 35 - G#3
		X"1BBE4", -- 36 - A3
		X"1A2FB", -- 37 - A#3
		X"18B77", -- 38 - B3
		X"17543", -- 39 - C4
		X"16052", -- 40 - C#4
		X"14C8C", -- 41 - D4
		X"139E0", -- 42 - D#4
		X"12843", -- 43 - E4
		X"117A2", -- 44 - F4
		X"107F1", -- 45 - F#4
		X"0F920", -- 46 - G4
		X"0EB25", -- 47 - G#4
		X"0DDF2", -- 48 - A4
		X"0D17E", -- 49 - A#4
		X"0C5BC", -- 50 - B4
		X"0BAA2", -- 51 - C5
		X"0B028", -- 52 - C#5
		X"0A646", -- 53 - D5
		X"09CF1", -- 54 - D#5
		X"09422", -- 55 - E5
		X"08BD1", -- 56 - F5
		X"083F8", -- 57 - F#5
		X"07C90", -- 58 - G5
		X"07592", -- 59 - G#5
		X"06EF9", -- 60 - A5
		X"068BF", -- 61 - A#5
		X"062DE", -- 62 - B5
		X"05D51", -- 63 - C6
		X"05814", -- 64 - C#6
		X"05323", -- 65 - D6
		X"04E78", -- 66 - D#6
		X"04A11", -- 67 - E6
		X"045E9", -- 68 - F6
		X"041FC", -- 69 - F#6
		X"03E48", -- 70 - G6
		X"03AC9", -- 71 - G#6
		X"0377D", -- 72 - A6
		X"0345F", -- 73 - A#6
		X"0316F", -- 74 - B6
		X"02EA9", -- 75 - C7
		X"02C0A", -- 76 - C#7
		X"02991", -- 77 - D7
		X"0273C", -- 78 - D#7
		X"02508", -- 79 - E7
		X"022F4", -- 80 - F7
		X"020FE", -- 81 - F#7
		X"01F24", -- 82 - G7
		X"01D65", -- 83 - G#7
		X"01BBE", -- 84 - A7
		X"01A30", -- 85 - A#7
		X"018B7", -- 86 - B7
		X"01754"  -- 87 - C8
	);

	signal frequency_counter : unsigned(19 downto 0) := (others => '0');
	signal volumePWM_counter : unsigned(3 downto 0) := (others => '0');
	
