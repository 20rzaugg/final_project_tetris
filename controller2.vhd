library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.tetris_types.all;

entity controller2 is port (
	MAX10_CLK1_50 : in std_logic;
	ADC_CLK_10 : in std_logic;
	KEY : in std_logic_vector(1 downto 0);
	SW : in std_logic_vector(9 downto 0);
	HEX0 : out unsigned(7 downto 0);
	HEX1 : out unsigned(7 downto 0);
	HEX2 : out unsigned(7 downto 0);
	HEX3 : out unsigned(7 downto 0);
	HEX4 : out unsigned(7 downto 0);
	HEX5 : out unsigned(7 downto 0);
	VGA_B : out std_logic_vector(3 downto 0);
	VGA_G : out std_logic_vector(3 downto 0);
	VGA_HS : out std_logic;
	VGA_R : out std_logic_vector(3 downto 0);
	VGA_VS : out std_logic;
	ARDUINO_IO : inout std_logic_vector(15 downto 0);
	ARDUINO_RESET_N : inout std_logic	
);
end controller2;

architecture behavioral of controller2 is
    
    component b10_accumulator is port (
        clk : in std_logic;
        rst_l : in std_logic;
        add_value : in unsigned(3 downto 0);
        accumulate : in std_logic;
        score : buffer score_digits_array
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
		rst_l : in std_logic;
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
		rst_l : in std_logic;-- := '1';
        blockArray : in tetris_block_array;
		falling_block : in unsigned(3 downto 0);
		falling_block_col : in unsigned(3 downto 0);
		falling_block_y : in unsigned(11 downto 0);
		score_in : in score_digits_array
    );
    end component screen_manager;
    
	 
    component potADC is port (
        clk : in std_logic;
        rst_l : in std_logic;
        ARDUINO_IO : inout std_logic_vector(15 downto 0); --input the continuous voltage data on the first pin and command channel.
        ARDUINO_RESET_N : inout std_logic;
        potPosition : out std_logic_vector(11 downto 0)
    );
    end component potADC;

    signal blockArray : tetris_block_array := (others => (others => X"0"));
    signal next_blockArray : tetris_block_array ;
    signal falling_block, next_falling_block : unsigned(3 downto 0); -- color of falling block, 0 is no block
    signal falling_block_col : unsigned(3 downto 0) := X"0";
    signal next_col : unsigned(3 downto 0) := X"0";
    signal falling_block_y, next_falling_block_y : unsigned(11 downto 0);
    signal score : score_digits_array;

    signal potPosition : std_logic_vector(11 downto 0);

    type col_heights_type is array (0 to 8) of unsigned(3 downto 0);
    signal stack_heights : col_heights_type := (others => X"0");
    signal next_stack_heights : col_heights_type := (others => X"0");

    type gamestate_type is (idle, drop, set, gameover);
    signal state : gamestate_type := idle;
    signal next_state : gamestate_type := idle;
    
    signal add_value : unsigned(3 downto 0) := X"0";
    signal accumulate : std_logic := '0';

    signal sound_selector : unsigned(2 downto 0) := "000";
    signal next_sound_selector : unsigned(2 downto 0) := "000";
    signal play_l : std_logic := '1';
    signal next_play_l : std_logic := '1';
    signal col_move : std_logic := '0';
	signal next_col_move : std_logic := '0';
    signal block_settle : std_logic := '0';
    signal block_disappear : std_logic := '0';
    signal next_block_disappear : std_logic := '0';
    signal game_over : std_logic := '0';

    signal fall_timer : integer := 0;
    signal next_fall_timer : integer := 0;
	 
	 signal rand : std_logic_vector(3 downto 0);
	 signal set_block : std_logic; 

    type row_positions_type is array(0 to 13) of unsigned(11 downto 0);
    signal row_positions : row_positions_type := (X"1B0", X"190", X"170", X"150", X"130", X"110", X"0F0", X"0D0", X"0B0", X"090", X"070", X"050", X"030", X"010");

	 
	 
	 type MY_MEM is array(0 to 9) of unsigned(7 downto 0);
    signal sev_seg : MY_MEM := (X"C0", X"F9", X"A4", X"B0", X"99", X"92", X"83", X"F8", X"80", X"98");

begin
		
		
	 HEX0 <= sev_seg(to_integer(add_value));
	 
	 
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
        sw => sw(3 downto 0),
        sound_selector => sound_selector,
        buzzer => ARDUINO_IO(11),
        play_l => play_l
    );
    
    u2_rng : rng port map (
        clk => MAX10_CLK1_50,
        rst_l => key(0),
        rand => rand
    );

    u3_screen_manager : screen_manager port map (
        MAX10_CLK1_50 => MAX10_CLK1_50,
        Blue => vga_B,
        Green => vga_G,
        Red => vga_R,
        VGA_HS => VGA_HS,
        VGA_VS => VGA_VS,
        rst_l => key(0),
        blockArray => blockArray,
        falling_block => falling_block,
        falling_block_col => falling_block_col,
        falling_block_y => falling_block_y,
        score_in => score
    );

    u4_potADC : potADC port map (
        clk => ADC_CLK_10,
        rst_l => key(0),
        ARDUINO_IO => ARDUINO_IO,
        ARDUINO_RESET_N => ARDUINO_RESET_N,
        potPosition => potPosition
    );

    --manages signal updates on the clock cycle and reset
    process(MAX10_CLK1_50, key(0)) begin
        if key(0) = '0' then
            state <= idle;
            falling_block_col <= falling_block_col;
            fall_timer <= 0;
            play_l <= '1';
            blockArray <= (others => (others => X"0"));
            stack_heights <= (others => X"0");
            falling_block <= X"0";
            falling_block_y <= X"000";
            col_move <= '0';
            sound_selector <= "000";
            accumulate <= '0';
            block_disappear <= '0';
        else 
			if rising_edge(MAX10_CLK1_50) then
                state <= next_state;
                falling_block_col <= next_col;
                fall_timer <= next_fall_timer;
                play_l <= next_play_l;
                blockArray <= next_blockArray;
                stack_heights <= next_stack_heights;
				falling_block <= next_falling_block;
				falling_block_y <= next_falling_block_y;
				col_move <= next_col_move;
                sound_selector <= next_sound_selector;
                accumulate <= not accumulate;
                block_disappear <= next_block_disappear;
			
            else
                state <= state;
                falling_block_col <= falling_block_col;
                fall_timer <= fall_timer;
                play_l <= play_l;
                blockArray <= blockArray;
                stack_heights <= stack_heights;
				falling_block <= falling_block;
				falling_block_y <= falling_block_y;
				col_move <= col_move;
                accumulate <= accumulate;
                block_disappear <= block_disappear;
            end if;
        end if;
    end process;

    --manages the column of the falling block
    process(potPosition, falling_block_col, stack_heights, falling_block_y, row_positions) 
	begin
        case falling_block_col is
            --brute force method of moving the block left and right, can only move one column per clock cycle
            when X"0" =>
                --if the column next to the current column has blocks stacked higher than the block's current position, we can't move the block
                if potPosition > X"1C7" and falling_block_y < row_positions(to_integer(stack_heights(1))) then
                    next_col <= X"1";
					next_col_move <= '1';
                else
                    next_col <= X"0";
					next_col_move <= '0';
                end if;
            when X"1" =>
                if potPosition < X"1C7" and falling_block_y < row_positions(to_integer(stack_heights(0))) then
                    next_col <= X"0";
						  next_col_move <= '1';
                else if potPosition > X"38E" and falling_block_y < row_positions(to_integer(stack_heights(2))) then
                    next_col <= X"2";
						  next_col_move <= '1';
                else
                    next_col <= X"1";
						  next_col_move <= '0';
					 end if;
                end if;
            when X"2" =>
                if potPosition < X"38E" and falling_block_y < row_positions(to_integer(stack_heights(1))) then
                    next_col <= X"1";
						  next_col_move <= '1';
                else if potPosition > X"555" and falling_block_y < row_positions(to_integer(stack_heights(3))) then
                    next_col <= X"3";
						  next_col_move <= '1';
                else
                    next_col <= X"2";
						  next_col_move <= '0';
                end if;
				end if;
            when X"3" =>
                if potPosition < X"555" and falling_block_y < row_positions(to_integer(stack_heights(2))) then
                    next_col <= X"2";
						  next_col_move <= '1';
                else if potPosition > X"71C" and falling_block_y < row_positions(to_integer(stack_heights(4))) then
                    next_col <= X"4";
						  next_col_move <= '1';
                else
                    next_col <= X"3";
						  next_col_move <= '0';
                end if;
				end if;
            when X"4" =>
                if potPosition < X"71C" and falling_block_y < row_positions(to_integer(stack_heights(3))) then
                    next_col <= X"3";
						  next_col_move <= '1';
                else if potPosition > X"8E3" and falling_block_y < row_positions(to_integer(stack_heights(5))) then
                    next_col <= X"5";
						  next_col_move <= '1';
                else
                    next_col <= X"4";
						  next_col_move <= '0';
                end if;
				end if;
            when X"5" =>
                if potPosition < X"8E3" and falling_block_y < row_positions(to_integer(stack_heights(4))) then
                    next_col <= X"4";
						  next_col_move <= '1';
                else if potPosition > X"AAB" and falling_block_y < row_positions(to_integer(stack_heights(6))) then
                    next_col <= X"6";
						  next_col_move <= '1';
                else
                    next_col <= X"5";
						  next_col_move <= '0';
                end if;
				end if;
            when X"6" =>
                if potPosition < X"AAB" and falling_block_y < row_positions(to_integer(stack_heights(5))) then
                    next_col <= X"5";
						  next_col_move <= '1';
                else if potPosition > X"C72" and falling_block_y < row_positions(to_integer(stack_heights(7))) then
                    next_col <= X"7";
						  next_col_move <= '1';
                else
                    next_col <= X"6";
						  next_col_move <= '0';
                end if;
					 end if;
            when X"7" =>
                if potPosition < X"C72" and falling_block_y < row_positions(to_integer(stack_heights(6))) then
                    next_col <= X"6";
						  next_col_move <= '1';
                else if potPosition > X"E39" and falling_block_y < row_positions(to_integer(stack_heights(8))) then
                    next_col <= X"8";
						  next_col_move <= '1';
                else
                    next_col <= X"7";
						  next_col_move <= '0';
                end if;
					 end if;
            when X"8" =>
                if potPosition < X"E39" and falling_block_y < row_positions(to_integer(stack_heights(7))) then
                    next_col <= X"7";
						  next_col_move <= '1';
                else
                    next_col <= X"8";
						  next_col_move <= '0';
					 end if;
            when others =>
                next_col <= X"0";
			end case;
    end process;
    
    --checks if we need to play a sound
    process(block_disappear, block_settle, game_over, col_move, sound_selector, play_l) begin
        --game over sound has the highest priority
        if game_over = '1' then
            next_sound_selector <= "100";
            next_play_l <= '0';
        else
            --block disappear has the second highest priority
            if block_disappear = '1' then
                next_sound_selector <= "011";
                next_play_l <= '0';
            else
                --next priority is the block settle sound
                if block_settle = '1' then
                    next_sound_selector <= "010";
                    next_play_l <= '0';
                else
                    --last priority is the column move sound
                    if col_move = '1' then
                        next_sound_selector <= "001";
                        next_play_l <= '0';
                    else
                        next_sound_selector <= "000";
                        next_play_l <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;

    --game state manager and falling block logic
    process(state, key, falling_block, falling_block_col, falling_block_y, stack_heights, rand, row_positions, fall_timer, stack_heights, falling_block, falling_block_col) begin
        case state is
            when idle =>
                -- if idle, start the game if the start button is pressed
                if key(1) = '0' then
                    next_state <= drop;
                    next_falling_block <= unsigned(rand);
                    next_falling_block_y <= X"000";
                else
                    next_state <= idle;
					next_falling_block <= X"0";
					next_falling_block_y <= X"000";
                end if;
            when drop =>
                if falling_block_y >= row_positions(to_integer(stack_heights(to_integer(falling_block_col))+1)) then
                    if stack_heights(to_integer(falling_block_col)) >= 12 then
						next_state <= gameover;
						game_over <= '1';
					else
						next_state <= set;
						set_block <= '1';
					end if;
                else
                    next_state <= drop;
                    set_block <= '0';
                    if fall_timer >= 500000 then
                        next_falling_block_y <= falling_block_y + 1;
                        next_fall_timer <= 0;
                    else
                        next_fall_timer <= fall_timer + 1;
                        block_settle <= '1';
                    end if;
                end if;
            when set =>
                next_state <= drop;
                next_falling_block <= unsigned(rand);
                next_falling_block_y <= X"000";
                block_settle <= '0';
            when gameover =>
					 next_falling_block_y <= X"000";
					 next_falling_block <= X"0";
                next_state <= idle;
					 next_fall_timer <= 0;
					 game_over <= '0';
        end case;
    end process;

	 
    process(blockArray, set_block, stack_heights, falling_block, falling_block_col) 
        variable score_modifier : integer := 0;
        variable x : unsigned(3 downto 0) := X"0";
    begin
        next_blockArray <= blockArray;
        score_modifier := 0;
        next_block_disappear <= '0';
        if(set_block = '1') then
            next_blockArray(to_integer(stack_heights(to_integer(falling_block_col))), to_integer(falling_block_col)) <= falling_block;
            next_stack_heights(to_integer(falling_block_col)) <= stack_heights(to_integer(falling_block_col));
        else
            --check for horizontal matches
            for i in 0 to 11 loop
                for j in 0 to 8 loop
                    if j < 7 then
                        if blockArray(i,j) = blockArray(i,j+1) and blockArray(i,j) = blockArray(i,j+2) then
                            next_blockArray(i,j) <= X"0";
									 next_stack_heights(j) <= stack_heights(j) - 1;
                            next_blockArray(i,j+1) <= X"0";
									 next_stack_heights(j+2) <= stack_heights(j+1) - 1;
                            next_blockArray(i,j+2) <= X"0";
									 next_stack_heights(j+2) <= stack_heights(j+2) - 1;
                            score_modifier := score_modifier + 3;
                            next_block_disappear <= '1';
                            if j < 6 then
                                if blockArray(i,j) = blockArray(i,j+3) then
                                    next_blockArray(i, j+3) <= X"0";
												next_stack_heights(j+3) <= stack_heights(j+3) - 1;
                                    score_modifier := score_modifier + 1;
                                    if j < 5 then
                                        if blockArray(i,j) = blockArray(i,j+4) then
                                            next_blockArray(i, j+4) <= X"0";
														  next_stack_heights(j+4) <= stack_heights(j+4) - 1;
                                            score_modifier := score_modifier + 1;
                                        end if;
                                    end if;
                                end if;
                            end if;  
                        end if;
                    end if;
                end loop;
            end loop;
            --check for vertical matches
            for j in 0 to 8 loop
                for i in 0 to 11 loop
                    if i < 10 then
                        if blockArray(i,j) = blockArray(i+1,j) and blockArray(i,j) = blockArray(i+2,j) then
                            next_blockArray(i,j) <= X"0";
                            next_blockArray(i+1,j) <= X"0";
                            next_blockArray(i+2,j) <= X"0";
                            score_modifier := score_modifier + 3;
                            next_block_disappear <= '1';
                            if i < 9 then
                                if blockArray(i,j) = blockArray(i+3,j) then
                                    next_blockArray(i+3, j) <= X"0";
                                    score_modifier := score_modifier + 1;
                                end if;
                            end if;
                        end if;
                    end if;
                end loop;
            end loop;
            --check for columns that need to be shifted
            for j in 0 to 8 loop
                for i in 0 to 11 loop
						if i < 11 then
                    if blockArray(i,j) = X"0" and blockArray(i+1, j) /= X"0" then
                       if blockArray(i+1,j) /= X"0" then
                           next_blockArray(i,j) <= blockArray(i+1,j);
                           next_blockArray(i+1,j) <= X"0";
                       end if;
                    end if;
						end if;
                end loop;
            end loop;
        end if;
        for j in 0 to 8 loop
            x := X"0";
            for i in 0 to 11 loop
                if blockArray(i,j) /= X"0" then
                    x := x + 1;
                end if;
            end loop;
            next_stack_heights(j) <= x;
        end loop;
        add_value <= to_unsigned(score_modifier, 4); --probably an error
    end process;
end architecture behavioral;