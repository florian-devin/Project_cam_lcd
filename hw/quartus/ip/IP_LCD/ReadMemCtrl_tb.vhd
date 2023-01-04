library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ReadMemCtrl_tb is
end ReadMemCtrl_tb;

architecture test of ReadMemCtrl_tb is
	--clock period
	constant CLK_PERIOD : time := 20 ns;
	
	-- delta time between two different inputs
	constant TIME_DELTA : time := 10*CLK_PERIOD;


	signal clk      : std_logic;
	signal nReset   : std_logic;

	signal sim_finished : boolean := false;

	
    -- Inputs
    signal waitrequest              : std_logic;                                 -- Avalon Bus waitrequest
    signal MasterFIFO_empty         : std_logic;                                 -- master FIFO fill info   
    signal globalFIFO_AlmostFull    : std_logic;                                 -- global FIFO fill info
    signal CAMaddress               : std_logic_vector(31 downto 0);             -- Address of the IP_CAM slave register containing the address of meomry read status
	signal startAddress             : std_logic_vector(31 downto 0);             -- First address of the frame in memory
    signal bufferLength             : std_logic_vector(31 downto 0);             -- Number of pixels to read in memory
    signal memWritten               : std_logic;                                 -- Sync signal from IP_CAM
    signal pixCounter               : std_logic_vector(31 downto 0);              -- Nb of pixel read since last start of frame
    signal BurstCounter				: std_logic_vector(3 downto 0);    

	-- Outputs
    signal read            : std_logic;                                        -- Avalon Bus read 
	signal write 		   : std_logic;
	signal isig_read            : std_logic;                                        -- Avalon Bus read 
    signal burstcount      : std_logic_vector(3 downto 0);                     -- Avalon Bus burst count (nb of consecutive reads)
    signal isig_burstcount : std_logic_vector(3 downto 0);                     -- Avalon Bus burst count (nb of consecutive reads)
	signal address         : std_logic_vector(31 downto 0);                    -- Avalon Bus address                                     -- Synchronization with IP_CAM, memory has been read completely by IP_LCD
    signal writedata       : std_logic_vector(31 downto 0); 
	signal nPixToCount     : std_logic_vector(7 downto 0);                     -- Nb of pixel to read in the current burstread           
    signal clrPixCounter   : std_logic;                                        -- Pixel counter reset signal
    signal clrBurstCounter : std_logic;                                         -- Burst counter reset signal
	



begin


	-- Instantiate DUT
	dut : entity work.ReadMemCtrl
	generic map(
        DefaultBurstLength  => x"4"
    )

    port map(
		clk 	=> clk,
		nReset 	=> nReset,

        waitrequest           => waitrequest,          
        MasterFIFO_empty      => MasterFIFO_empty,     
        globalFIFO_AlmostFull => globalFIFO_AlmostFull,
        CAMaddress			  => CAMaddress,
		startAddress          => startAddress,         
        bufferLength          => bufferLength,         
        memWritten            => memWritten,           
        pixCounter            => pixCounter,
		BurstCounter		  => BurstCounter,              
        read                  => read,                 
        write 				  => write,
		im_read				  => isig_read, 
		burstcount            => burstcount,
		im_burstcount         => isig_burstcount,            
        address               => address,
		writedata			  => writedata,                         
        nPixToCount           => nPixToCount,          
        clrPixCounter         => clrPixCounter,        
        clrBurstCounter       => clrBurstCounter      
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
	

	procedure rdloop is
	begin
		wait until rising_edge(clk);

		--Check EOL, pixCounter <= bufferlength
		--SyncGlobalFIFO, globalFIFO_AlmostFull=0
		--GetPointer (check burstCount and pixtocount)
		--SetRdSignals read high and burst counter to 0
		--WaitWaitRequest
		--RealeaseRdSignals read goes low
		--SyncMasterFIFO1, master fifo empty so update address
		--Update address, address should be increased by burstcount
		wait for 2*TIME_DELTA;
		--SyncMasterFIFO2
		MasterFIFO_empty <= '1';
		pixCounter <= std_logic_vector(unsigned(pixCounter) + unsigned(nPixToCount)); 
		BurstCounter <= burstcount;
		wait until rising_edge(clk);
		MasterFIFO_empty <= '0';
		wait for CLK_PERIOD/2;
		wait until rising_edge(clk); 
		
	end procedure rdloop;
	
	
	
	begin
	
	-- Attribute default values
        waitrequest             <= '0';
        MasterFIFO_empty        <= '0';
        globalFIFO_AlmostFull   <= '0';
        CAMaddress              <= x"0000FABC";
		startAddress            <= x"FEFECDCD";
        bufferLength            <= x"00000003";
        memWritten              <= '0';
        pixCounter              <= x"00000000";
        BurstCounter			<= (others => '0');

		wait until rising_edge(clk);
		
	-- Reset the module
		async_reset;
		
		wait for TIME_DELTA;
				
		--memwritten pulses
		memWritten <= '1';
		wait until rising_edge(clk);
		memWritten <= '0';
		wait until rising_edge(clk);

		rdloop;
		rdloop;
		waitrequest <= '1';
		wait for 2*TIME_DELTA;
		waitrequest <= '0';

		wait for 2*TIME_DELTA;

		-- Indicate end of tb
		sim_finished <= true;
		
		wait;
	
	end process simulation;
	
	
end architecture test;
