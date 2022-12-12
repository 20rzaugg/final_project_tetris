library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.tetris_types.all;

entity b10_accumulator is port (
    clk : in std_logic;
    rst_l : in std_logic;
    add_value : in unsigned(3 downto 0);
    accumulate : in std_logic;
    score : buffer score_digits_array
	 
);
end b10_accumulator;

architecture behavioral of b10_accumulator is
    signal score_reg : score_digits_array := (others => X"0");
    type state_type is (idle, adding, debounce);
    signal state : state_type := idle;
    signal next_state : state_type := idle;
begin
    
        process(clk, rst_l)
        begin
            if rst_l = '0' then
                score <= (others => X"0");
            elsif rising_edge(clk) then
                if accumulate = '1' then
                    score <= score_reg;
                end if;
            end if;
        end process;

    process(state, accumulate, add_value) begin
        case state is
            when idle =>
                if accumulate = '1' then
                    next_state <= adding;
                    score_reg <= score;
                end if;
            when adding =>
                if score(5) + add_value > 9 then
                    score_reg(5) <= score(5) + add_value - 10;
                    if score(4) = 9 then
                        score_reg(4) <= X"0";
                        if score(3) = 9 then
                            score_reg(3) <= X"0";
                            if score(2) = 9 then
                                score_reg(2) <= X"0";
                                if score(1) = 9 then
                                    score_reg(1) <= X"0";
                                    if score(0) = 9 then
                                        score_reg(0) <= X"0";
                                    else
                                        score_reg(0) <= score(0) + 1;
                                    end if;
                                else
                                    score_reg(1) <= score(1) + 1;
                                end if;
                            else
                                score_reg(2) <= score(2) + 1;
                            end if;
                        else
                            score_reg(3) <= score(3) + 1;
                        end if;
                    else
                    score_reg(4) <= score(4) + 1;
						  end if;
                else
                    score_reg(5) <= score(5) + add_value;
                end if;    
                next_state <= debounce;
            when debounce =>
                score_reg <= score;
                if accumulate = '1' then
                    next_state <= debounce;
                else
                    next_state <= idle;
                end if;
        end case;
    end process;
end architecture;