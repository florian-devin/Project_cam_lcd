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
    signal masterFIFO_empty         : std_logic;                                 -- master FIFO fill info   
    signal globalFIFO_AlmostFull    : std_logic;                                 -- global FIFO fill info
    signal startAddress             : std_logic_vector(31 downto 0);             -- First address of the frame in memory
    signal bufferLength             : std_logic_vector(31 downto 0);             -- Number of pixels to read in memory
    signal memWritten               : std_logic;                                 -- Sync signal from IP_CAM
    signal pixCounter               : std_logic_vector(31 downto 0);              -- Nb of pixel read since last start of frame
        

	-- Outputs
    signal read            : std_logic;                                        -- Avalon Bus read 
    signal burstcount      : std_logic_vector(3 downto 0);                     -- Avalon Bus burst count (nb of consecutive reads)
    signal address         : std_logic_vector(31 downto 0);                    -- Avalon Bus address
    signal memRed          : std_logic;                                        -- Synchronization with IP_CAM, memory has been read completely by IP_LCD
    signal nPixToCount     : std_logic_vector(1 downto 0);                     -- Nb of pixel to read in the current burstread           
    signal clrPixCounter   : std_logic;                                        -- Pixel counter reset signal
    signal clrBurstCounter : std_logic                                         -- Burst counter reset signal
	



begin
²

	-- Instantiate DUT
	dut : entity work.SlaveInterface
	generic map(
        DefaultBurstLength  => 4
    )

    port map(
        waitrequest           => waitrequest,          
        masterFIFO_empty      => masterFIFO_empty,     
        globalFIFO_AlmostFull => globalFIFO_AlmostFull,
        startAddress          => startAddress,         
        bufferLength          => bufferLength,         
        memWritten            => memWritten,           
        pixCounter            => pixCounter,              
        read                  => read,                 
        burstcount            => burstcount,           
        address               => address,              
        memRed                => memRed,               
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
	
-- Avalon Bus read test procedure
	procedure IO_read(constant p_addr : in natural;
						constant res_expected : in natural) is
		variable res : natural;
	begin
		wait until rising_edge(clk);
		
		-- Set address
		address <= std_logic_vector(to_unsigned(p_addr, address'length));
		wait until rising_edge(clk);
		
		-- Enable read
		read <= '1';

		wait until rising_edge(clk);
		wait until rising_edge(clk);
		

		-- Check output
		res := to_integer(unsigned(readdata));
		assert res = res_expected
		report  "Unexpected result: " &
				"address = " & integer'image(p_addr) & "; " & 
				"readdata = " & integer'image(res) & "; " &
				"readdata_expected = " & integer'image(res_expected)
		severity error;
		
	
		-- Disable read	
		read <='0';
		--wait until rising_edge(clk);
		
	end procedure IO_read;
	
-- Avalon Bus write test procedure
	procedure IO_write(constant p_addr : in natural;
						constant p_wrdata : in natural;
						constant res_expected : in natural) is
		variable res : natural;
	begin
		wait until rising_edge(clk);
		
		-- Set writedata
		writedata <= std_logic_vector(to_unsigned(p_wrdata, writedata'length));	
		-- Set address
		address <= std_logic_vector(to_unsigned(p_addr, address'length));
		
		wait until rising_edge(clk);
		
		-- Enable write
		write <= '1';
		
		wait until rising_edge(clk);	--wait for 2 clk cycles as in quartus specification
		wait until rising_edge(clk);
		
		-- Check output
		case p_addr is 
			when 0 	=> res := to_integer(unsigned(data));
			--when "01" => DO NOTHING
			when 2 	=> res := to_integer(unsigned'("" & frame_rst_rq));
			when others => null;
		end case;
		
		assert res = res_expected
		report  "Unexpected result: " &
				"address = " & integer'image(p_addr) & "; " & 
				"readdata = " & integer'image(res) & "; " &
				"readdata_expected = " & integer'image(res_expected)
		severity error;
		
		
		-- Disable read	
		write <='0';
		--wait until rising_edge(clk);
	
	end procedure IO_write;
	
	
	begin
	
	-- Attribute default values
		nReset 			<= '1';
		address 		<= (others =>'0');
		write 			<= '0';
		read 			<= '0';
		writedata 		<= (others =>'0');
		--readdata 		<= (others =>'0');
		tx_ready 		<= '0';
		--data 			<= (others =>'0');
		--frame_rst_rq 	<= '0';
		wait until rising_edge(clk);
		
	-- Reset the module
		async_reset;
		
		wait for TIME_DELTA;
		
		-- NZR encoder is ready 
		tx_ready <='1';		
		
		-- read flag 
		IO_read(1, 1);								-- expect 1 bc tx_ready = 1
		
		-- write data
		IO_write(0, 16#0FAAAAAA#, 16#AAAAAA#);		-- write data
		
		tx_ready <= '0';							-- NZR encoder drives tx_ready low				
		wait for TIME_DELTA;					-- new_frame signal triggers NZR encoder

		IO_read(1, 0);								-- MCU polls flag but line is occupied by NZR encoder
		
		wait for TIME_FRAME24;						-- NZR encoder sends the frame
		wait for TIME_FRAME24;
		
		
		tx_ready <= '1';							-- Frame Tx has ended, tx_ready =1
		
		-- NZR encoder sends NbLED frames
		-- ...
		
		-- try to send the same data
		
		-- read flag 
		IO_read(1, 1);								-- expect 1 bc tx_ready = 1
		
		-- write data
		IO_write(0, 16#0FAAAAAA#, 16#AAAAAA#);		-- write data
		tx_ready <= '0';							-- NZR encoder drives tx_ready low
		
		wait for TIME_DELTA;					-- new_frame signal triggers NZR encoder
		
		
		IO_read(1, 0);								-- MCU polls flag but line is occupied by NZR encoder
		
		wait for TIME_FRAME24;						-- NZR encoder sends the frame
		
		tx_ready <= '1';							-- Frame Tx has ended, tx_ready =1
		
		
		--...
		
		IO_read(1, 1);								-- MCU polls flag, line free

		IO_write(2, 16#0000000F#, 1);				-- WR requests
		tx_ready <= '0';							-- NZR encoder drives tx_ready low		
		
		wait for TIME_DELTA;-- until (new_frame = '1');					-- new_frame signal triggers NZR encoder
		
		IO_read(2, 16#0000000F#);					-- RD requests
		
		IO_write(2, 16#00000000#, 0);
		
		wait for TIME_RST_RQ;						-- NZR encoder sends the reset frame

		tx_ready <= '1'; 							-- NZR encoder has finished the tx	
		
		-- Indicate end of tb
		sim_finished <= true;
		
		wait;
	
	end process simulation;
	
	
end architecture test;
