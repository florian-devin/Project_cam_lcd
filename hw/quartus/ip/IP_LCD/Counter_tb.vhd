library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Counter_tb is
end Counter_tb;

architecture test of Counter_tb is
	--clock period
	constant CLK_PERIOD : time := 20 ns;
	
	-- delta time between two different inputs
	constant TIME_DELTA : time := 10*CLK_PERIOD;

    --width of counter
    constant CNT_WIDTH : integer := 10;

	signal sim_finished : boolean := false;

	signal clk      : std_logic;
	signal nReset   : std_logic;
    signal trigger1 : std_logic :='0';
	--signal trigger2 : std_logic :='0';
    signal clr     : std_logic;
    signal cnt     : std_logic_vector(CNT_WIDTH-1 downto 0);



begin


	-- Instantiate DUT
	dut : entity work.Counter
	generic map(
        cnt_width  => CNT_WIDTH
    )

    port map(
        nReset  => nReset,
        trigger1 => trigger1,
		trigger2 => '1',--trigger2,
        clr     => clr,
        cnt     => cnt    
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
	
    -- Generate trigger signal
	trigger1_generation : process
	begin
		if not sim_finished then
			trigger1 <= '1';
			wait for 5*CLK_PERIOD / 2;
			trigger1 <= '0';
			wait for 5*CLK_PERIOD / 2;
		else 
			wait;
		end if;
	end process trigger1_generation;


-- Simulation
	simulation : process
	
-- Reset procedure	
	procedure async_reset is
	begin 
		wait until rising_edge(clk);
		wait for CLK_PERIOD/4;
		nReset <= '0';
		
		wait for CLK_PERIOD/2;
		nReset <= '1';
	end procedure async_reset;




	
	
	begin
	
	-- Attribute default values
		nReset 	<= '1';
        --trigger2 <= '1';
        clr     <= '0';
        
		wait until rising_edge(clk);
		
	-- Reset the module
		async_reset;
		
		wait for 10*TIME_DELTA;
    
        clr <= '1';

        wait for TIME_DELTA;

        clr <='0';

        wait for 10*TIME_DELTA;

		--trigger2 <= '0';

		wait for 10*TIME_DELTA;

        sim_finished <= true;
		wait;
	
	end process simulation;
	
	
end architecture test;
