library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Vsync is
		
	port (
		clk : in std_logic ;
		rst_l : in std_logic ;
		Vpos : out unsigned(11 downto 0);
		vpulse : out std_logic := '1'
	);
	
end entity Vsync;
	
architecture behavioral of Vsync is

type state_type is (A,B,C,D);
signal cur_state, next_state : state_type := A;
signal rownum, next_rownum : unsigned(11 downto 0) := X"000";
signal pulse, next_pulse : std_logic ;
signal count, next_count : unsigned(11 downto 0) := X"000";

begin

	Vpos <= rownum;
	vpulse <= pulse;
	--one line = 800 clk cycles
	--A, 10 lines
	--B, 2 lines
	--C, 33 lines
	--D, 480 lines

--process bring future to present
	process (clk, rst_l)
	begin
	if rst_l = '0' then
			cur_state <= A;
			rownum <= X"000";
			count <= X"000";
			pulse <= '1';
	else 
		if rising_edge(clk) then
			cur_state <= next_state;
			count <= next_count;-- + X"001";
			--if count = X"31F" then              --799 for hdata
			rownum <= next_rownum; --rownum + X"001";
			pulse <= next_pulse;
			--end if;
		end if;
	end if;
	end process;
	
--process set future
	process (cur_state, rownum, count)
	begin
		next_pulse <= '1';
		next_count <= count + X"001";
		if count = X"31F" then
			next_rownum <= rownum + X"001";
			next_count <= X"000";
		else
			next_rownum <= rownum;
		end if;
		
		case cur_state is
			when A =>				--A lasts from rows 0-9
				if rownum = X"009" then
					next_state <= B;
				else
					next_state <= A;
				end if;
			when B =>				--B lasts from 10 - 11
				next_pulse <= '0';
				if rownum = X"00B" then --changed from B
					next_state <= C;
				else
					next_state <= B;
					next_pulse <= '0';
				end if;
			when C =>				--C lasts from 12 - 44
				next_pulse <= '1';
				if rownum = X"02C" then
					next_state <= D;
				else
					next_state <= C;
				end if;
			when D =>				--D lasts from 45 - 524
				if rownum = X"20C" then
					next_state <= A;
					next_rownum <= X"000";
					--next_count <= X"000"; messed the whole thing up.
				else
					next_state <= D;
				end if;
		end case;
	
	end process;

	
end architecture behavioral;