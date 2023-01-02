library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity master_wrapper_tb is
end master_wrapper_tb;

architecture test of master_wrapper_tb is
	--clock period
	constant CLK_PERIOD : time := 20 ns;
	
	-- delta time between two different inputs
	constant TIME_DELTA : time := 10*CLK_PERIOD;

    signal clk      : std_logic;
	signal nReset   : std_logic;

	signal sim_finished : boolean := false;

	-- Avalon Bus signals
    signal readdatavalid           : std_logic;
    signal waitrequest             : std_logic;
    signal readdata                : std_logic_vector(31 downto 0);
    -- Slave signals
    signal globalFIFO_AlmostFull   : std_logic;                                 -- global FIFO fill info
    signal startAddress            : std_logic_vector(31 downto 0);             -- First address of the frame in memory
    signal bufferLength            : std_logic_vector(31 downto 0);             -- Number of pixels to read in memory
    -- IP_CAM signal
    signal memWritten              : std_logic;                                 -- Sync signal from IP_CAM
    -- gFIFO signals
    signal gFIFO_wrfull            : std_logic;

    -- To Avalon Bus
    signal read        : std_logic;                                            -- Avalon Bus read 
    signal burstcount  : std_logic_vector(3 downto 0);                         -- Avalon Bus burst count (nb of consecutive reads)
    signal address     : std_logic_vector(31 downto 0);                        -- Avalon Bus address
    -- To IP_CAM
    signal memRed      : std_logic;                                            -- Synchronization with IP_CAM, memory has been read completely by IP_LCD
    -- To global FIFO
    signal gFIFO_wrreq : std_logic;                                            -- Write request to global FIFO
    signal gFIFO_data  : std_logic_vector(15 downto 0);                                         -- Burst counter reset signal
	



begin


	-- Instantiate DUT
	dut : entity work.master_wrapper
    port map(
		clk     => clk,
		nReset  => nReset,

        readdatavalid           => readdatavalid,           
        waitrequest             => waitrequest,             
        readdata                => readdata,                
        globalFIFO_AlmostFull   => globalFIFO_AlmostFull,   
        startAddress            => startAddress,            
        bufferLength            => bufferLength,            
        memWritten              => memWritten,              
        gFIFO_wrfull            => gFIFO_wrfull,            
        read                    => read,                    
        burstcount              => burstcount,              
        address                 => address,                 
        memRed                  => memRed,                  
        gFIFO_wrreq             => gFIFO_wrreq,             
        gFIFO_data              => gFIFO_data              
           
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
	

    procedure buflen3 is
	begin 
        bufferLength <= x"00000003";
        wait for 2*CLK_PERIOD;

        memWritten<= '1';
        wait until rising_edge(clk);
		memWritten <= '0';
        wait until rising_edge(clk);
		
        wait for 2*TIME_DELTA;
        -- simulate read data valid fom Avalon Bus
        readdatavalid<= '1';
        wait for CLK_PERIOD;
		readdatavalid <= '0';
        wait until rising_edge(clk);

        wait for 500 ns;
        -- simulate read data valid fom Avalon Bus
        readdatavalid<= '1';
        wait for CLK_PERIOD;
		readdatavalid <= '0';
        wait until rising_edge(clk);
	end procedure buflen3;



    procedure buflen8 is
	begin 
        bufferLength <= x"00000008";
        wait for 2*CLK_PERIOD;

        memWritten<= '1';
        wait for CLK_PERIOD;
		memWritten <= '0';
        wait until rising_edge(clk);
		
        wait for 2*TIME_DELTA;
        
        -- simulate read data valid fom Avalon Bus
        readdatavalid<= '1';
        wait for CLK_PERIOD;
		readdatavalid <= '0';
        wait until rising_edge(clk);

        wait for TIME_DELTA;
        -- simulate read data valid fom Avalon Bus
        readdatavalid<= '1';
        wait for CLK_PERIOD;
		readdatavalid <= '0';
        wait until rising_edge(clk);

        wait for TIME_DELTA;
        -- simulate read data valid fom Avalon Bus
        readdatavalid<= '1';
        wait for CLK_PERIOD;
		readdatavalid <= '0';
        wait until rising_edge(clk);

        wait for TIME_DELTA;
        -- simulate read data valid fom Avalon Bus
        readdatavalid<= '1';
        wait for CLK_PERIOD;
		readdatavalid <= '0';
        wait until rising_edge(clk);


	end procedure buflen8;
	


        procedure buflen9 is
	begin 
        bufferLength <= x"00000009";
        wait for 2*CLK_PERIOD;

        memWritten<= '1';
        wait for CLK_PERIOD;
		memWritten <= '0';
        wait until rising_edge(clk);
		
        wait for 2*TIME_DELTA;
        
        -- simulate read data valid fom Avalon Bus
        readdatavalid<= '1';
        wait for CLK_PERIOD;
		readdatavalid <= '0';
        wait until rising_edge(clk);

        wait for TIME_DELTA;
        -- simulate read data valid fom Avalon Bus
        readdatavalid<= '1';
        wait for CLK_PERIOD;
		readdatavalid <= '0';
        wait until rising_edge(clk);

        wait for TIME_DELTA;
        -- simulate read data valid fom Avalon Bus
        readdatavalid<= '1';
        wait for CLK_PERIOD;
		readdatavalid <= '0';
        wait until rising_edge(clk);

        wait for TIME_DELTA;
        -- simulate read data valid fom Avalon Bus
        readdatavalid<= '1';
        wait for CLK_PERIOD;
		readdatavalid <= '0';
        waitrequest <= '1';
        wait until rising_edge(clk);

        wait for 10*TIME_DELTA;
        waitrequest <= '0';
        wait until rising_edge (clk);
        -- simulate read data valid fom Avalon Bus
        readdatavalid<= '1';
        wait for CLK_PERIOD;
		readdatavalid <= '0';
        wait until rising_edge(clk);


	end procedure buflen9;
	
	
	begin
	
	-- Attribute default values
        readdatavalid            <= '0';
        waitrequest              <= '0';
        readdata                 <= x"12345678";
        globalFIFO_AlmostFull    <= '0';
        startAddress             <= (others => '0');
        bufferLength             <= x"00000000";
        memWritten               <= '0';
        gFIFO_wrfull             <= '0';
        
        wait until rising_edge(clk);
		
	-- Reset the module
		async_reset;

		wait for TIME_DELTA;

        buflen3;

        wait until rising_edge(memRed);
        wait for CLK_PERIOD;
        
        buflen8;

        wait until rising_edge(memRed);
        wait for CLK_PERIOD;
        
        buflen9;

        wait until rising_edge(memRed);
        wait for 5*TIME_DELTA;

		-- Indicate end of tb
		sim_finished <= true;
		
		wait;
	
	end process simulation;
	
	
end architecture test;
