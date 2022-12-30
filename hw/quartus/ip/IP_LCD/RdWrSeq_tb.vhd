library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RdWrSeq_tb is
end RdWrSeq_tb;

architecture test of RdWrSeq_tb is
	--clock period
	constant CLK_PERIOD : time := 20 ns;
	
	-- delta time between two different inputs
	constant TIME_DELTA : time := 10*CLK_PERIOD;


	signal clk      : std_logic;
	signal nReset   : std_logic;

	signal sim_finished : boolean := false;

	
		--Inputs
        signal AM_read         : std_logic;                                         -- Avalon Master read request
        signal burstcount      : std_logic_vector(3 downto 0);                      -- Avalon Bus burst count for this burst read(nb of consecutive reads)
        signal BurstCounter    : std_logic_vector(3 downto 0);                      -- Avalon Bus bursts counted in the current burstread 
        signal nPixToCount     : std_logic_vector(7 downto 0);                      -- Nb of pixel to read in the current burstread
        signal mFIFO_q         : std_logic_vector(15 downto 0);                     -- Output of the master FIFO
        signal mFIFO_rdempty   : std_logic;                                         -- read empty status from master FIFO
        signal gFIFO_wrfull    : std_logic;                                         -- write full status from global FIFO

        --Outputs
        signal gFIFO_wrreq : std_logic;                                            -- Write request to global FIFO
        signal gFIFO_data  : std_logic_vector(15 downto 0);                        -- Data to push in global FIFO
        signal mFIFO_rdreq : std_logic;                                            -- Burst counter reset signal
	



begin


	-- Instantiate DUT
	dut : entity work.RdWrSeq
    port map(
		clk 	=> clk,
		nReset 	=> nReset,

        AM_read       => AM_read,        
        burstcount    => burstcount,     
        BurstCounter  => BurstCounter,   
        nPixToCount   => nPixToCount,    
        mFIFO_q       => mFIFO_q,        
        mFIFO_rdempty => mFIFO_rdempty,  
        gFIFO_wrfull  => gFIFO_wrfull,   

        gFIFO_wrreq => gFIFO_wrreq, 
        gFIFO_data  => gFIFO_data, 
        mFIFO_rdreq => mFIFO_rdreq 
           
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
	
-- Avalon Bus read test procedure
	procedure WrRdloop is
	begin
		wait until rising_edge(clk);

   		AM_read <= '1';
		wait until rising_edge(clk);
		AM_read <= '0';
		wait until rising_edge(clk);


		--Init
        wait for TIME_DELTA;
        --waitBurstCompletion
		BurstCounter <= burstcount;
        wait until rising_edge(clk);
        --rise/fall mFIFO rdreq, i_gFIFO_data ?
        --check gFIFO wrfull
        --rise/fall gFIFO wrreq 
        --check curpix
        --loop rise fall mFIFOrdreq *nPixtoCount

        --check curpix and curpix = 0
        --check mFIFO rdempty, is empty here TEST CASE WHEN NOT EMPTY
        --back to IDLE
		
	end procedure WrRdloop;
	
	
	
	begin
	
	-- Attribute default values
        AM_read       <= '0';        
        burstcount    <= x"4";   
        BurstCounter  <= x"0";   
        nPixToCount   <= x"08";    
        mFIFO_q       <= x"1234";        
        mFIFO_rdempty <= '0';  
        gFIFO_wrfull  <= '0';  
        
		wait until rising_edge(clk);
		
	-- Reset the module
		async_reset;
		
		wait for TIME_DELTA;
				
		--memwritten pulses

		WrRdloop;


		wait for 2*TIME_DELTA;

		-- Indicate end of tb
		sim_finished <= true;
		
		wait;
	
	end process simulation;
	
	
end architecture test;
