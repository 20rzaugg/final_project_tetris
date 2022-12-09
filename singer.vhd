library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity singer is port (
	clk_50 : in std_logic;
	rst_l : in std_logic;
	sw : in std_logic_vector(3 downto 0);
	sound_selector : unsigned(2 downto 0); --0 = silence, 1 = click1, 2 = click2, 3 = game start, 4 = game over
	buzzer : out std_logic
);
end entity;

architecture behavioral of singer is
	type notes_array is array(0 to 88) of unsigned(19 downto 0);
	signal notes : notes_array := (
		X"00000", --  0 - silence
		X"DDF23", --  1 - A0
		X"D1747", --  2 - A#0
		X"C5B78", --  3 - B0
		X"BAA6E", --  4 - C1
		X"B025D", --  5 - C#1
		X"A6435", --  6 - D1
		X"9CF17", --  7 - D#1
		X"9424C", --  8 - E1
		X"8BD42", --  9 - F1
		X"83F7D", -- 10 - F#1
		X"7C8FC", -- 11 - G1
		X"75943", -- 12 - G#1
		X"6EF91", -- 13 - A1
		X"68BED", -- 14 - A#1
		X"62DBC", -- 15 - B1
		X"5D4FD", -- 16 - C2
		X"5812E", -- 17 - C#2
		X"5321B", -- 18 - D2
		X"4E78B", -- 19 - D#2
		X"4A101", -- 20 - E2
		X"45E80", -- 21 - F2
		X"41FBE", -- 22 - F#2
		X"3E47E", -- 23 - G2
		X"3AC8A", -- 24 - G#2
		X"377C9", -- 25 - A2
		X"345F7", -- 26 - A#2
		X"316EE", -- 27 - B2
		X"2EA8D", -- 28 - C3
		X"2C0A4", -- 29 - C#3
		X"29919", -- 30 - D3
		X"273C6", -- 31 - D#3
		X"2508A", -- 32 - E3
		X"22F48", -- 33 - F3
		X"20FDF", -- 34 - F#3
		X"1F23F", -- 35 - G3
		X"1D64B", -- 36 - G#3
		X"1BBE4", -- 37 - A3
		X"1A2FB", -- 38 - A#3
		X"18B77", -- 39 - B3
		X"17543", -- 40 - C4
		X"16052", -- 41 - C#4
		X"14C8C", -- 42 - D4
		X"139E0", -- 43 - D#4
		X"12843", -- 44 - E4
		X"117A2", -- 45 - F4
		X"107F1", -- 46 - F#4
		X"0F920", -- 47 - G4
		X"0EB25", -- 48 - G#4
		X"0DDF2", -- 49 - A4
		X"0D17E", -- 50 - A#4
		X"0C5BC", -- 51 - B4
		X"0BAA2", -- 52 - C5
		X"0B028", -- 53 - C#5
		X"0A646", -- 54 - D5
		X"09CF1", -- 55 - D#5
		X"09422", -- 56 - E5
		X"08BD1", -- 57 - F5
		X"083F8", -- 58 - F#5
		X"07C90", -- 59 - G5
		X"07592", -- 60 - G#5
		X"06EF9", -- 61 - A5
		X"068BF", -- 62 - A#5
		X"062DE", -- 63 - B5
		X"05D51", -- 64 - C6
		X"05814", -- 65 - C#6
		X"05323", -- 66 - D6
		X"04E78", -- 67 - D#6
		X"04A11", -- 68 - E6
		X"045E9", -- 69 - F6
		X"041FC", -- 70 - F#6
		X"03E48", -- 71 - G6
		X"03AC9", -- 72 - G#6
		X"0377D", -- 73 - A6
		X"0345F", -- 74 - A#6
		X"0316F", -- 75 - B6
		X"02EA9", -- 76 - C7
		X"02C0A", -- 77 - C#7
		X"02991", -- 78 - D7
		X"0273C", -- 79 - D#7
		X"02508", -- 80 - E7
		X"022F4", -- 81 - F7
		X"020FE", -- 82 - F#7
		X"01F24", -- 83 - G7
		X"01D65", -- 84 - G#7
		X"01BBE", -- 85 - A7
		X"01A30", -- 86 - A#7
		X"018B7", -- 87 - B7
		X"01754"  -- 88 - C8
	);

	type game_over_notes_type is array (0 to 14) of unsigned(7 downto 0);
	signal game_over_notes : game_over_notes_type := (
		X"34", -- 52 (C5)
		X"00", -- 0 (rest)
		X"2F", -- 47 (G4)
		X"00", -- 0 (rest)
		X"2B", -- 43 (E4)
		X"00", -- 0 (rest)
		X"31", -- 49 (A4)
		X"33", -- 51 (B4)
		X"31", -- 49 (A4)
		X"00", -- 0 (rest)
		X"30", -- 48 (G#4)
		X"32", -- 50 (A#4)
		X"30", -- 48 (G#4)
		X"00", -- 0 (rest)
		X"2F" -- 47 (G4)
	);
	type game_over_beats_type is array (0 to 14) of unsigned(3 downto 0);
	signal game_over_beats : game_over_beats_type := (
		X"1", -- 1/4 C5
		X"3", -- 3/4 rst
		X"1", -- 1/4 G4
		X"3", -- 3/4 rst
		X"1", -- 1/4 E4
		X"2", -- 2/4 rst
		X"2", -- 2/4 A4
		X"1",  -- 1/4 B4
		X"1",  -- 1/4 A4
		X"1",  -- 1/4 rst
		X"3",  -- 3/4 G#4
		X"2",  -- 2/4 A#4
		X"2",  -- 2/4 G#4
		X"1",  -- 1/4 rst
		X"4"  -- 4/4 G4
	);

	signal frequency_counter : unsigned(19 downto 0) := (others => '0');
	signal volume_logic : std_logic := '0';
	signal frequency_logic : std_logic := '0';
	signal volumePWM_counter : unsigned(3 downto 0) := (others => '0');
	signal note_index : unsigned(7 downto 0) := (others => '0');
	signal game_over_index : unsigned(3 downto 0) := (others => '0');

	signal beatCounter : unsigned(23 downto 0) := (others => '0');
	signal beats : unsigned(3 downto 0) := X"0";

	type state_type is (idle, move, settle, disappear, game_over);
	signal state : state_type := idle;
	signal next_state : state_type := idle;

	signal prev_sound_selector : unsigned(2 downto 0) := (others => '0');
	
begin

	process(clk_50, rst_l) begin
		if rst_l = '0' then
			frequency_counter <= (others => '0');
			volumePWM_counter <= (others => '0');
		elsif rising_edge(clk_50) then
			if frequency_counter >= notes(to_integer(note_index)) then
				frequency_counter <= (others => '0');
				frequency_logic <= not frequency_logic;
			else
				frequency_counter <= frequency_counter + 1;
			end if;
			if volumePWM_counter = X"F" then
				volumePWM_counter <= (others => '0');
			else
				volumePWM_counter <= volumePWM_counter + 1;
			end if;
			if note_index > 0 then
				buzzer <= frequency_logic and volume_logic;
			end if;
			state <= next_state;
		end if;
	end process;

	process(volumePWM_counter) begin
		if volumePWM_counter <= unsigned(sw) then
			volume_logic <= '1';
		else
			volume_logic <= '0';
		end if;
	end process;

	process(sound_selector, state, clk_50) begin
		if (sound_selector /= prev_sound_selector) then
			case sound_selector is
				when "000" => 
						beats <= X"0";
						next_state <= idle;
						beatCounter <= (others => '0');
				when "001" => 
					next_state <= move;
					beatCounter <= (others => '0');
					beats <= X"0";
				when "010" => 
					next_state <= settle;
					beatCounter <= (others => '0');
					beats <= X"0";
				when "011" => 
					next_state <= disappear;
				when "100" => 
					next_state <= game_over;
					game_over_index <= (others => '0');
					beatCounter <= (others => '0');
					beats <= X"0";
				when others => 
					next_state <= idle;
			end case;
			prev_sound_selector <= sound_selector;
		else
			case state is
				when idle => 
					next_state <= idle;
					beatCounter <= (others => '0');
					note_index <= X"00";
				when move =>
					if beatCounter < 5000000 then
						beatCounter <= beatCounter + 1;
						note_index <= X"1C"; --C3
						next_state <= move;
					else
						next_state <= idle;
					end if;

				when settle =>
				if beatCounter < 10000000 then
					beatCounter <= beatCounter + 1;
					note_index <= X"04"; --C0
					next_state <= settle;
				else
					next_state <= idle;
				end if;
				when disappear =>
					next_state <= idle;
				when game_over =>
					if game_over_index <= 14 then
						if beatCounter >= 10000000 then
							beatCounter <= (others => '0');
							if beats >= game_over_beats(to_integer(game_over_index)) then
								beats <= X"0";
								game_over_index <= game_over_index + 1;
							else
								beats <= beats + 1;
							end if;
						end if;
						note_index <= game_over_notes(to_integer(game_over_index));
						next_state <= game_over;
					else
						next_state <= idle;
					end if;
				when others => next_state <= idle;
			end case;
		end if;
	end process;

end architecture behavioral;
	
