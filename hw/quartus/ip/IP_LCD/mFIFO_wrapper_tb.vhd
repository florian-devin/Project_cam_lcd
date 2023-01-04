library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mFIFO_wrapper_tb is
end mFIFO_wrapper_tb;

architecture test of mFIFO_wrapper_tb is
	--clock period
	constant CLK_PERIOD : time := 20 ns;
	
	-- delta time between two different inputs
	constant TIME_DELTA : time := 10*CLK_PERIOD;


	signal clk      : std_logic;
	signal nReset   : std_logic;

	signal sim_finished : boolean := false;

    signal data     : STD_LOGIC_VECTOR (31 DOWNTO 0);
    signal rdreq    : STD_LOGIC ;
    signal wrreq	: STD_LOGIC ;                                        -- write full status from global FIFO

    signal q		: STD_LOGIC_VECTOR (15 DOWNTO 0);
    signal rdempty	: STD_LOGIC;                                            -- Burst counter reset signal
	



begin


	-- Instantiate DUT
	dut : entity work.mFIFO_wrapper
    port map(
		clk     => clk,
		nReset  => nReset,
        data    => data,
		rdreq   => rdreq,
		wrreq   => wrreq,
		q		=> q,
		rdempty	=> rdempty
           
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
	
-- Reset procedure	
	procedure async_reset is
	begin 
		wait until rising_edge(clk);
		wait for CLK_PERIOD/4;
		nReset <= '0';
		
		wait for CLK_PERIOD/2;
		nReset <= '1';
	end procedure async_reset;
	

	procedure wrfifo is
	begin
        wrreq <= '1';
        wait until rising_edge(clk);
        wrreq <= '0';
        wait until rising_edge(clk);
		
	end procedure wrfifo;

    procedure rdfifo is
	begin
        --wait until rdempty = '0';
        wait until rising_edge(clk);
        rdreq <= '1';
        wait until rising_edge(clk);
        rdreq <= '0';
        wait until rising_edge(clk);
		
	end procedure rdfifo;
	
	
	
	begin
	
	-- Attribute default values
        data  <= x"12345678";
	    rdreq <= '0';
	    wrreq <= '0';
        
		wait until rising_edge(clk);
		
	-- Reset the module
		async_reset;
		
        wait until rising_edge(clk);

        wrfifo;
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);

        rdfifo;
        wait until rising_edge(clk);
        rdfifo;
        wait until rising_edge(clk);
        async_reset;

		wait for TIME_DELTA;
		
		-- Indicate end of tb
		sim_finished <= true;
		
		wait;
	
	end process simulation;
	
	
end architecture test;
