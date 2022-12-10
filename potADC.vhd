library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity potADC is port (
	clk : in std_logic;
	rst_l : in std_logic;
	ARDUINO_IO : inout std_logic_vector(15 downto 0); --input the continuous voltage data on the first pin and command channel.
	ARDUINO_RESET_N : inout std_logic;
	potPosition : out std_logic_vector(11 downto 0)
);
end entity potADC;
	
architecture behavioral of potADC is 
	
	signal pclk : std_logic;		--connections from pll to adc
	signal plocked : std_logic;
	signal ADC_output, clocked_out, prev_out : std_logic_vector(11 downto 0) := X"000";
	signal rst_n : Std_logic := '1';
	
	signal count : unsigned(27 downto 0) := X"0000000";--(19 downto 0); --count to 1 million.
	
	signal command_valid, command_startofpacket, command_endofpacket : std_logic := '1';
	signal command_ready : std_logic;
	signal response_valid, response_startofpacket, response_endofpacket : std_logic;
	signal response_channel : std_logic_vector(4 downto 0);
	
	component ADC is port (
		clock_clk              : in  std_logic                     := '0';             -- clk
		reset_sink_reset_n     : in  std_logic                     := '1';             -- reset_n
		adc_pll_clock_clk      : in  std_logic                     := '0';             -- clk
		adc_pll_locked_export  : in  std_logic                     := '0';             -- export
		command_valid          : in  std_logic                     := '1';             -- valid
		command_channel        : in  std_logic_vector(4 downto 0)  := b"00010"; 	   -- channel
		command_startofpacket  : in  std_logic                     := '1';             -- startofpacket
		command_endofpacket    : in  std_logic                     := '1';             -- endofpacket
		command_ready          : out std_logic;                                        -- ready
		response_valid         : out std_logic;                                        -- valid
		response_channel       : out std_logic_vector(4 downto 0);                     -- channel
		response_data          : out std_logic_vector(11 downto 0);                    -- data
		response_startofpacket : out std_logic;                                        -- startofpacket
		response_endofpacket   : out std_logic                                         -- endofpacket
	);
	end component ADC;
		
		
	component acdpll is port (
		inclk0		: IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC 
	);
	end component ACDpll;
		
begin
		--store response data in a variable and output to hex values.
	potPosition <= clocked_out;

	u0_adc : ADC port map (
		clock_clk => clk,
		reset_sink_reset_n => '1',
		adc_pll_clock_clk => pclk,
		adc_pll_locked_export => plocked,
		command_valid => '1',
		command_channel => b"00011",
		command_startofpacket => '1',
		command_endofpacket => '1',
		command_ready => open,
		response_valid => response_valid,
		response_channel => open,
		response_data => ADC_output,
		response_startofpacket => open,
		response_endofpacket => open
	);
		
	u1_pll : component acdpll port map (
		inclk0 => ADC_CLK_10,
		c0 => pclk,
		locked => plocked
	);
	
	process (clk, KEY) begin
		if rst_l = '0' then
				count <= X"0000000";
		elsif rising_edge(ADC_CLK_10) then
			if count = X"0989680" then --16 times per second
				count <= X"0000000";
				if response_valid = '1' then
					clocked_out <= ADC_output;
				end if;
			else
				count <= count + X"0000001";
				clocked_out <= clocked_out;
			end if;
		end if;
	end process;

end architecture behavioral;