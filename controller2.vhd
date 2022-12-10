library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.tetris_types.all;

entity controller is port (
    MAX10_CLK1_50 : in std_logic;
    key : in std_logic_vector(1 downto 0);
    sw : in std_logic_vector(3 downto 0);
    buzzer : inout std_logic;
    potPosition : in std_logic_vector(11 downto 0);
);
end controller;

architecture behavioral of controller is
    
    component b10_accumulator is port (
        clk : in std_logic;
        rst_l : in std_logic;
        add_value : in unsigned(3 downto 0);
        accumulate : in std_logic;
        score : buffer score_digits_array;
    );
    end component b10_accumulator;

    component singer is port (
        clk_50 : in std_logic;
	    rst_l : in std_logic;
	    sw : in std_logic_vector(3 downto 0);
	    sound_selector : unsigned(2 downto 0); --0 = silence, 1 = click1, 2 = click2, 3 = game start, 4 = game over
	    buzzer : out std_logic;
	    play_l : in std_logic
    );
    end component singer;

    component rng is port (
        clk : in std_logic;
		rst_l : in std_logic_vector(1 downto 0);
		rand : out std_logic_vector(3 downto 0)
    );
    end component rng;

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
    end component screen_manager;
    
    signal blockArray : tetris_block_array;
    signal falling_block : unsigned(3 downto 0); -- color of falling block, 0 is no block
    signal falling_block_col : unsigned(3 downto 0) := X"0";
    signal next_col : unsigned(3 downto 0) := X"0";
    signal falling_block_y : unsigned(11 downto 0);
    signal score : score_digits_array;

    type col_heights_type is array (0 to 8) of unsigned(3 downto 0);
    signal stack_heights : col_heights_type := (others => X"0");

    type gamestate_type is (idle, drop, land, check, fall, gameover);
    signal state : gamestate_type := idle;
    signal next_state : gamestate_type := idle;
    
    signal add_value : unsigned(3 downto 0) := X"0";
    signal accumulate : std_logic_vector := '0';

    signal sound_selector : unsigned(2 downto 0) := "000";
    signal play_l : std_logic := '1';

    signal fall_timer : integer := 0;
    signal next_fall_timer : integer := 0;
    
    signal next_block_array : tetris_block_array := (others => (others => X"0"));

    type row_positions_type is array(0 to 13) of unsigned(11 downto 0);
    signal row_positions : row_positions_type := (X"1B0", X"190", X"170", X"150", X"130", X"110", X"0F0", X"0D0", X"0B0", X"090", X"070", X"050", X"030", X"010");


begin

    u0_accumulator : b10_accumulator port map (
        clk => MAX10_CLK1_50,
        rst_l => key(0),
        add_value => add_value,
        accumulate => accumulate,
        score => score
    );

    u1_singer : singer port map (
        clk_50 => MAX10_CLK1_50,
        rst_l => key(0),
        sw => sw,
        sound_selector => sound_selector,
        buzzer => buzzer,
        play_l => play_l
    );

    process(MAX10_CLK1_50, key(0)) begin
        if key(0) = '0' then
            state <= idle;
            falling_block_col <= X"0";
            falling_block <= X"0";
            falling_block_y <= X"000";
            blockArray <= (others => (others => X"0"));
            col_heights <= (others => X"1B0");
        else if rising_edge(MAX10_CLK1_50) then
            state <= next_state;
            falling_block_col <= next_col;
        end if;
    end process;

    process(potPosition, falling_block_col, stack_heights) begin
        case falling_block_col is
            when X"0" =>
                if potPosition > X"1C7" and falling_block_y < row_positions(to_integer(stack_heights(1))) then
                    next_col <= X"1";
                else
                    next_col <= X"0";
                end if;
            when X"1" =>
                if potPosition < X"1C7" and falling_block_y < row_positions(to_integer(stack_heights(0))) then
                    next_col <= X"0";
                else if potPosition > X"38E" and falling_block_y < row_positions(to_integer(stack_heights(2))) then
                    next_col <= X"2";
                else
                    next_col <= X"1";
                end if;
            when X"2" =>
                if potPosition < X"38E" and falling_block_y < row_positions(to_integer(stack_heights(1))) then
                    next_col <= X"1";
                else if potPosition > X"555" and falling_block_y < row_positions(to_integer(stack_heights(3))) then
                    next_col <= X"3";
                else
                    next_col <= X"2";
                end if;
            when X"3" =>
                if potPosition < X"555" and falling_block_y < row_positions(to_integer(stack_heights(2))) then
                    next_col <= X"2";
                else if potPosition > X"71C" and falling_block_y < row_positions(to_integer(stack_heights(4))) then
                    next_col <= X"4";
                else
                    next_col <= X"3";
                end if;
            when X"4" =>
                if potPosition < X"71C" and falling_block_y < row_positions(to_integer(stack_heights(3))) then
                    next_col <= X"3";
                else if potPosition > X"8E3" and falling_block_y < row_positions(to_integer(stack_heights(5))) then
                    next_col <= X"5";
                else
                    next_col <= X"4";
                end if;
            when X"5" =>
                if potPosition < X"8E3" and falling_block_y < row_positions(to_integer(stack_heights(4))) then
                    next_col <= X"4";
                else if potPosition > X"AAB" and falling_block_y < row_positions(to_integer(stack_heights(6))) then
                    next_col <= X"6";
                else
                    next_col <= X"5";
                end if;
            when X"6" =>
                if potPosition < X"AAB" and falling_block_y < row_positions(to_integer(stack_heights(5))) then
                    next_col <= X"5";
                else if potPosition > X"C72" and falling_block_y < row_positions(to_integer(stack_heights(7))) then
                    next_col <= X"7";
                else
                    next_col <= X"6";
                end if;
            when X"7" =>
                if potPosition < X"C72" and falling_block_y < row_positions(to_integer(stack_heights(6))) then
                    next_col <= X"6";
                else if potPosition > X"E39" and falling_block_y < row_positions(to_integer(stack_heights(8))) then
                    next_col <= X"8";
                else
                    next_col <= X"7";
                end if;
            when X"8" =>
                if potPosition < X"E39" and falling_block_y < row_positions(to_integer(stack_heights(7))) then
                    next_col <= X"7";
                else
                    next_col <= X"8";
                end if;
            when others =>
                next_col <= X"0";
    end process
        

    process(state, key(1), falling_block, falling_block_col, falling_block_y, blockArray, col_heights, rand) begin
        case state is
            when idle =>
                if key(1) = '1' then
                    next_state <= drop;
                    falling_block <= rand;
                    falling_block_col <= X"4";
                    falling_block_y <= X"0";
                    next_block_array <= blockArray;
                else
                    next_state <= idle;
                end if;
            when drop =>
                if falling_block_y >= row_positions(to_integer(stack_heights(to_integer(falling_block_col)) + 1)) then
                    next_state <= drop;
                    falling_block_y <= falling_block_y + 1;
                else
                    next_state <= land;
                end if;
            when land =>
                
            when check =>
                
                end