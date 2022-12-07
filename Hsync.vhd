library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Hsync is
		
	port (
		clk : in std_logic ;
		rst_l : in std_logic ;
		Hpos : out unsigned(11 downto 0);
		Hpulse : out std_logic := '1'
	);
	
end entity Hsync;
	
architecture behavioral of Hsync is

type state_type is (A,B,C,D);
signal cur_state, next_state : state_type := A;
signal colnum, next_colnum : unsigned(11 downto 0) := X"000";
signal pulse, next_pulse : std_logic ;

begin

	Hpos <= colnum;
	Hpulse <= pulse;

--process bring future to present
	process (clk, rst_l, next_state, next_colnum)
	begin
	if rst_l = '0' then
		cur_state <= A;
		colnum <= X"000";
		pulse <= '1';
	else
		if rising_edge(clk) then
			cur_state <= next_state;
			--colnum <= colnum + X"001"; --next_colnum;
			colnum <= next_colnum;
			pulse <= next_pulse;
		end if;
	end if;
	end process;
	
--process set future
	process (cur_state, colnum)
	begin
	next_colnum <= colnum + X"001";
	next_pulse <= '1';
		case cur_state is
			when A =>	--A is 16 pixel widths, 0-15, 0x00f
				--next_pulse <= '1';
				if colnum = X"00F" then 
					next_state <= B;
					--next_pulse <= '0';
				else
					next_state <= A;
				end if;
			when B =>						--B is 96 pixel widths, 16 - 111, 0x06f
				next_pulse <= '0';
				if colnum = X"06F" then
					next_state <= C;
					--next_pulse <= '1';
				else
					next_state <= B;
					--next_pulse <= '0';
				end if;
			when C =>						--C is 48 pixel widths, 112 - 159, 0x09F
				next_pulse <= '1';				--try C at 144 pixels, 112 - 255
				if colnum = X"09F" then
				--if colnum = X"0FF" then --TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT
					next_state <= D;
				else
					next_state <= C;
				end if;
			when D =>						--D is 640 pixel widths, 160 - 799, 0x31F  
				--next_pulse <= '1';
				if colnum = X"31F" then
					next_state <= A;
					next_colnum <= X"000";
				else
					next_state <= D;
				end if;
		end case;
	end process;

	
end architecture behavioral;