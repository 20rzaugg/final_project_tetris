library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity acum_test is
		
	port (
		MAX10_CLK1_50 : in std_logic;
		KEY : in std_logic_vector(1 downto 0); --rst_l --add
		SW : in unsigned(9 downto 0);
		HEX0 : out unsigned(7 downto 0);
		HEX1 : out unsigned(7 downto 0);
		HEX2 : out unsigned(7 downto 0);
		HEX3 : out unsigned(7 downto 0);
		HEX4 : out unsigned(7 downto 0);
		HEX5 : out unsigned(7 downto 0)
	);
	
end entity acum_test;
	
architecture behavioral of acum_test is 
	
	--STATE SIGNALS
	type state_type is (ADD, STAY, DELAY);
	signal cur_state : state_type;
	signal next_state : state_type;
	
	signal sum, next_sum : unsigned(23 downto 0); --stores accumulated value
	
	type MY_MEM is array(0 to 9) of unsigned(7 downto 0);
	signal sev_seg : MY_MEM := (X"C0", X"F9", X"A4", X"B0", X"99", X"92", X"83", X"F8", X"80", X"98");--, X"88", X"83", X"C6", X"A1", X"86", X"8E");
	--signal 0 is changed from C0 to FF to denote all off

begin

		HEX0 <= sev_seg(to_integer(sum(3 downto 0)));
		HEX1 <= sev_seg(to_integer(sum(7 downto 4)));
		HEX2 <= sev_seg(to_integer(sum(11 downto 8)));
		HEX3 <= sev_seg(to_integer(sum(15 downto 12)));
		HEX4 <= sev_seg(to_integer(sum(19 downto 16)));
		Hex5 <= sev_seg(to_integer(sum(23 downto 20)));
		
		--LEDR <= SW; --sets LEDS to switches. This is all we need to do with LEDS.
		
	
	
	process (MAX10_CLK1_50)
	begin
		if rising_edge(MAX10_CLK1_50) then
			cur_state <= next_state;
			sum <= next_sum;
		end if;	
	end process;
	
	process(cur_state, KEY, sum, SW)
		begin
		if KEY(0) = '0' then
			next_state <= STAY;
			next_sum <= (others => '0');
		else
			next_sum <= sum;
			case cur_state is
				when STAY =>
					if key(1) = '0' then
						next_state <= ADD;
					else
						next_state <= STAY;
					end if;
				when ADD =>
					--next_sum <= sum + SW;
					next_sum(3 downto 0) <= sum(3 downto 0) + sw(3 downto 0);--b"0001";
				if sum(3 downto 0) + sw(3 downto 0) >= X"A" then
				--if sum(3 downto 0) = X"9" then
					next_sum(7 downto 4) <= sum(7 downto 4) + b"0001";
					next_sum(3 downto 0) <= sum(3 downto 0) + sw(3 downto 0) - X"A";--(others => '0');
					if sum(7 downto 4) = X"9" then
						next_sum(11 downto 8) <= sum(11 downto 8) + b"0001";
						next_sum(7 downto 4) <= (others => '0');
						if sum(11 downto 8) = X"9" then
							next_sum(15 downto 12)<= sum(15 downto 12)+ b"0001";
							next_sum(11 downto 8) <= (others => '0');
							if sum(15 downto 12)= X"5" then
								next_sum(19 downto 16) <= sum(19 downto 16) + b"0001";
								next_sum(15 downto 12)<= (others => '0');
								if sum(19 downto 16) = X"10" then
									next_sum(23 downto 20)(19 downto 16) <= sum(23 downto 20)(19 downto 16) + b"0001";
									next_sum(19 downto 16) <= (others => '0');
									if sum(23 downto 20) = X"10" then
										next_sum(23 downto 20) <= (others => '0');
									end if;
								end if;
							end if;
						end if;
					end if;
				end if;
					next_state <= DELAY;
				when DELAY =>
					if key(1) = '0' then
						next_state <= DELAY;
					else
						next_state <= STAY;
					end if;
				
			end case;
		end if;	
	end process;
end architecture behavioral;