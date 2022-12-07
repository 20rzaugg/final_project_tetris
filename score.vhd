library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.tetris_types.all;

entity score is 
    port (
        clk, rst_l : in std_logic;
        score : in unsigned(20 downto 0);
        score_digits : out score_digits_array
    );
end entity score;

architecture behavioral of score is

    component divider is port (
        denom : IN STD_LOGIC_VECTOR (19 DOWNTO 0);
        numer : IN STD_LOGIC_VECTOR (19 DOWNTO 0);
        quotient : OUT STD_LOGIC_VECTOR (19 DOWNTO 0);
        remain : OUT STD_LOGIC_VECTOR (19 DOWNTO 0)
    );
    end component;

    type state is (delay, set);
    signal state, nextstate : state := delay;
    signal score_reg : std_logic_vector(19 downto 0);
    signal denominator_reg : std_logic_vector(19 downto 0) := X"00001";
    signal quotient_reg : std_logic_vector(19 downto 0);
    signal remainder_reg : std_logic_vector(19 downto 0);
    signal digit : unsigned(3 downto 0) := X"0";

begin

    --instantiate divider module
    U1_divider : divider port map (
        denom => denominator_reg,
        numer => score_reg,
        quotient => quotient_reg,
        remain => remainder_reg
    );
    
    --state machine, bring the future to the present
    process(clk, rst_l)
    begin
        if rst_l = '0' then
            state <= delay;
            score_reg <= (others => '0');
        elsif rising_edge(clk) then
            state <= nextstate;
        end if;
    end process;

    process(state)
    begin
        case state is
            when delay =>
                if(digit < X"5") then
                    nextstate <= set;
                else
                    nextstate <= delay;
                end if;
            when set =>
                case digit is
                    when X"0" =>
                        --save the hundred-thousands digit
                        score_digits(0) <= unsigned(quotient_reg(3 downto 0));
                        score_reg <= remainder_reg;
                        --divide the remainder by 10k
                        denominator_reg <= X"02710"; --10000
                        digit <= digit + X"1";
                        nextstate <= delay;
                    when X"1" =>
                        --save the ten-thousands digit
                        score_digits(1) <= unsigned(quotient_reg(3 downto 0));
                        score_reg <= remainder_reg;
                        --divide the remainder by 1k
                        denominator_reg <= X"003E8"; --1000
                        digit <= digit + X"1";
                        nextstate <= delay;
                    when X"2" =>
                        --save the thousands digit
                        score_digits(2) <= unsigned(quotient_reg(3 downto 0));
                        score_reg <= remainder_reg;
                        --divide the remainder by 100
                        denominator_reg <= X"00064"; --100
                        digit <= digit + X"1";
                        nextstate <= delay;
                    when X"3" =>
                        --save the hundreds digit
                        score_digits(3) <= unsigned(quotient_reg(3 downto 0));
                        score_reg <= remainder_reg;
                        --divide the remainder by 10
                        denominator_reg <= X"0000A"; --10
                        digit <= digit + X"1";
                        nextstate <= delay;
                    when X"4" =>
                        --save the tens digit and ones digit
                        score_digits(4) <= unsigned(quotient_reg(3 downto 0));
                        score_digits(5) <= unsigned(remainder_reg(3 downto 0));
                        score_reg <= X"00000";
                        denominator_reg <= X"00001"; --1
                        digit <= digit + X"1";
                        nextstate <= delay;
                    when others =>
                        nextstate <= delay;
                end case; 
        end case;
    end process;

    --when the score changes, start the state machine
    process(score)
    begin
        digit <= X"0";
        score_reg <= std_logic_vector(score);
        --divide the score by 100k
        denominator_reg <= X"186A0"; --100,000

    end process;

end behavioral;