library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memoryAcc_wrapper_tb is
end memoryAcc_wrapper_tb;

architecture test of memoryAcc_wrapper_tb is
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
    -- Slave signals                             -- global FIFO fill info
    signal CAMaddress            : std_logic_vector(31 downto 0);       
    signal startAddress            : std_logic_vector(31 downto 0);             -- First address of the frame in memory
    signal bufferLength            : std_logic_vector(31 downto 0);             -- Number of pixels to read in memory
    -- IP_CAM signal
    signal memWritten              : std_logic;                                 -- Sync signal from IP_CAM
    -- LCD controller signal
    signal gFIFO_rdreq		       : STD_LOGIC ;

    -- To Avalon Bus
    signal read                : std_logic;                                            -- Avalon Bus read 
    signal write                : std_logic;
    signal burstcount          : std_logic_vector(3 downto 0);                         -- Avalon Bus burst count (nb of consecutive reads)
    signal address             : std_logic_vector(31 downto 0);                        -- Avalon Bus address
   
    -- To LCD controller
    signal gFIFO_empty_LCD     : STD_LOGIC ;
    signal gFIFO_q		        : STD_LOGIC_VECTOR (15 DOWNTO 0);
    -- To Slave
    signal gFIFO_almost_empty	: STD_LOGIC ;
    signal gFIFO_almost_full	: STD_LOGIC ;
    signal gFIFO_empty		    : STD_LOGIC ;
    signal gFIFO_full		    : STD_LOGIC;



begin


	-- Instantiate DUT
	dut : entity work.memoryAcc_wrapper
    port map(
		clk     => clk,
		nReset  => nReset,


        readdatavalid           => readdatavalid,           
        waitrequest             => waitrequest,             
        readdata                => readdata,                
        CAMaddress              => CAMaddress,
        startAddress            => startAddress,            
        bufferLength            => bufferLength,            
        memWritten              => memWritten,              
        gFIFO_rdreq		        => gFIFO_rdreq,		        
        read                    => read,                    
        write                   => write,
        burstcount              => burstcount,              
        address                 => address,                   
        gFIFO_empty_LCD         => gFIFO_empty_LCD,         
        gFIFO_q		            => gFIFO_q,		            
        gFIFO_almost_empty	    => gFIFO_almost_empty,	    
		gFIFO_almost_full	    => gFIFO_almost_full,	    
		gFIFO_empty		        => gFIFO_empty,		        
		gFIFO_full		        => gFIFO_full		        
           
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
        wait for CLK_PERIOD;
        -- simulate read data valid fom Avalon Bus
        readdatavalid<= '1';
        wait for CLK_PERIOD;
		readdatavalid <= '0';
        wait until rising_edge(clk);


	end procedure buflen9;


    procedure gFIFO_rd is
	begin 

        gFIFO_rdreq <= '1';
        wait for CLK_PERIOD;
        gFIFO_rdreq <= '0';
        wait until rising_edge(clk);

	end procedure gFIFO_rd;
	
	
	begin
	
	-- Attribute default values
        readdatavalid   <= '0';
        waitrequest     <= '0';
        readdata        <= x"12345678";
        CAMaddress      <= x"0000FABC";
        startAddress    <= x"ABAB3B3B";
        bufferLength    <= x"00000000";
        memWritten      <= '0';
        gFIFO_rdreq     <= '0';
        
        wait until rising_edge(clk);
		
	-- Reset the module
		async_reset;

		wait for TIME_DELTA;

        buflen3;

        wait until rising_edge(write);
        wait for CLK_PERIOD;
        
        buflen8;

        wait until rising_edge(write);
        wait for CLK_PERIOD;
        
        buflen9;

        wait until rising_edge(write);
        wait for 5*TIME_DELTA;

        gFIFO_rd;
        wait for TIME_DELTA;

		-- Indicate end of tb
		sim_finished <= true;
		
		wait;
	
	end process simulation;
	
	
end architecture test;
