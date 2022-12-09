library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab8 is
		
	port (
		ADC_CLK_10 : in std_logic;
		KEY : in std_logic_vector(1 downto 0);
		ARDUINO_IO : inout std_logic_vector(15 downto 0); --input the continuous voltage data on the first pin and command channel.
	   ARDUINO_RESET_N : inout std_logic;
		BoxPosition : out std_logic_vector(11 downto 0)
	);
	
end entity lab8;
	
architecture behavioral of lab8 is 
	
	type MY_MEM is array(0 to 15) of unsigned(7 downto 0);
	signal sev_seg : MY_MEM := (X"C0", X"F9", X"A4", X"B0", X"99", X"92", X"83", X"F8", X"80", X"98", X"88", X"83", X"C6", X"A1", X"86", X"8E");
	
	signal pclk : std_logic;		--connections from pll to adc
	signal plocked : std_logic;
	signal ADC_output, clocked_out, prev_out : std_logic_vector(11 downto 0) := X"000";
	signal rst_n : Std_logic := '1';
	
	signal count : unsigned(27 downto 0) := X"0000000";--(19 downto 0); --count to 1 million.
	
	signal command_valid, command_startofpacket, command_endofpacket : std_logic := '1';
	signal command_ready : std_logic;
	signal response_valid, response_startofpacket, response_endofpacket : std_logic;
	signal response_channel : std_logic_vector(4 downto 0);
	
	component ADC is
		port (
			clock_clk              : in  std_logic                     := '0';             -- clk
			reset_sink_reset_n     : in  std_logic                     := '1';             -- reset_n
			adc_pll_clock_clk      : in  std_logic                     := '0';             -- clk
			adc_pll_locked_export  : in  std_logic                     := '0';             -- export
			command_valid          : in  std_logic                     := '1';             -- valid
			command_channel        : in  std_logic_vector(4 downto 0)  := b"00010"; -- channel
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
		
		
		component acdpll IS
			PORT
			(
				inclk0		: IN STD_LOGIC  := '0';
				c0		: OUT STD_LOGIC ;
				locked		: OUT STD_LOGIC 
			);
		END component ACDpll;
		
begin
		--store response data in a variable and output to hex values.
			BoxPosition <= clocked_out;
		
		u0	: component ADC
		port map (
			clock_clk              => ADC_CLK_10,--CONNECTED_TO_clock_clk,              --          clock.clk
			reset_sink_reset_n     => '1',     --     reset_sink.reset_n
			adc_pll_clock_clk      => pclk,      --CONNECTED_TO_adc_pll_clock_clk,      --  adc_pll_clock.clk
			adc_pll_locked_export  => plocked,   --CONNECTED_TO_adc_pll_locked_export,  -- adc_pll_locked.export
			command_valid          => '1',          --        command.valid
			command_channel        => b"00011",--use channel 1. Code to adc_in_1 --Map to arduino in0--CONNECTED_TO_command_channel,        --               .channel
			command_startofpacket  => '1',--command_startofpacket,--CONNECTED_TO_command_startofpacket,  --               .startofpacket
			command_endofpacket    => '1',--command_endofpacket,--CONNECTED_TO_command_endofpacket,    --               .endofpacket
			command_ready          => open,-- send for a clack cycle. --ready to recieve command--CONNECTED_TO_command_ready,          --               .ready
			response_valid         => response_valid,--CONNECTED_TO_response_valid,         --       response.valid
			response_channel       => open,--CONNECTED_TO_response_channel,       --               .channel
			response_data          => ADC_output,--CONNECTED_TO_response_data,          --               .data
			response_startofpacket => open,--response_startofpacket,--CONNECTED_TO_response_startofpacket, --               .startofpacket
			response_endofpacket   => open--response_endofpacket--CONNECTED_TO_response_endofpacket    --               .endofpacket
		);
		
		u1_pll : component acdpll
		port map (
			inclk0 =>	ADC_CLK_10,
			c0 =>			pclk,
			locked =>	plocked
			);
	
	process (ADC_CLK_10, KEY) 
	
	begin
		if KEY(0) = '0' then
				count <= X"0000000";
		elsif rising_edge(ADC_CLK_10) then
			if count = X"0989680" then
				count <= X"0000000";
				if response_valid = '1' then
					clocked_out <= ADC_output;
				end if;
			else
				count <= count + X"0000001";
				--clocked_out <= clocked_out;
			end if;
		end if;
	end process;

end architecture behavioral;