library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Inverter_tb is
end Inverter_tb;

architecture test of Inverter_tb is
	--clock period
	constant CLK_PERIOD : time := 20 ns;
	
	-- delta time between two different inputs
	constant TIME_DELTA : time := 10*CLK_PERIOD;

    --width of counter
    constant CNT_WIDTH : integer := 10;

	signal sim_finished : boolean := false;

	signal clk  : std_logic;
	signal nclk : std_logic;



begin


	-- Instantiate DUT
	dut : entity work.Inverter
    port map(
        i => clk,
        o => nclk 
    );
	
	-- Generate CLK signal
	clk_generation : process
	begin
		if not sim_finished then
			clk <= '1';
			wait for CLK_PERIOD / 2;
			clk <= '0';
			wait for CLK_PERIOD / 2;
		else 
			wait;
		end if;
	end process clk_generation;


-- Simulation
	simulation : process
	
	
	begin
	
    wait for 10*TIME_DELTA;
    sim_finished <= true;
    wait;
	
	end process simulation;
	
	
end architecture test;
