    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;


entity RdWrSeq is
    port(
		clk : in std_logic;                                                     
		nReset : in std_logic;

		--Inputs

        cur_burstcount  : in std_logic_vector(3 downto 0);                      -- Avalon Bus burst count for this burst read(nb of consecutive reads)
        BurstCounter    : in std_logic_vector(3 downto 0);                      -- Avalon Bus bursts counted in the current burstread 
        nPixToCount     : in std_logic_vector(1 downto 0);                      -- Nb of pixel to read in the current burstread
        lFIFO_q         : in std_logic_vector(15 downto 0);                     -- Output of the local FIFO
        lFIFO_rdempty   : in std_logic;                                         -- read empty status from local FIFO

        --Outputs
        
        gFIFO_wrreq : out std_logic;                                            -- Write request to global FIFO
        gFIFO_data  : out std_logic_vector(15 downto 0);                        -- Data to push in global FIFO
        lFIFO_rdreq : out std_logic                                             -- Read request to local FIFO
	);
end RdWrSeq;

architecture RTL of RdWrSeq is

	type states is (Idle, CheckEOL, SyncGlobalFIFO, GetPointer, 
                    SetRdSignals, WaitWaitRequest, RealeaseRdSignals,
                    SyncMasterFIFO1, SyncMasterFIFO2, ResetPointer, 
                    UpdateAddress, ClrMemRed);

	signal current_state: states;
	attribute enum_encoding: string;
	attribute enum_encoding of states: type is "gray";

    --internal signals
    signal i_read               : std_logic                     := '0';
    signal i_burstcount         : std_logic_vector(3 downto 0)  := (others => '0');
    signal i_address            : std_logic_vector(31 downto 0) := (others => '0');
    signal i_memRed             : std_logic                     := '0';
    signal i_nPixToCount        : std_logic_vector(1 downto 0)  := (others => '0');            
    signal i_clrPixCounter      : std_logic                     := '0';
    signal i_clrBurstCounter    : std_logic                     := '0';


begin


	process(clk, nReset, current_state)
	begin
    		if nReset = '0' then
                --reset values
                i_read              <= '0';
                i_burstcount        <= (others => '0');
                i_address           <= (others => '0');
                i_memRed            <= '0';
                i_nPixToCount       <= (others => '0');            
                i_clrPixCounter     <= '0';
                i_clrBurstCounter   <= '0';

    		elsif rising_edge(clk) then

				case current_state is
		
                    when Idle =>
                        if memWritten = '1' then
                            current_state <= CheckEOL;                           -- New frame available in memory, start reading
                        else
                            current_state <= Idle;                              -- No frame available
                        end if;
                    
                    when CheckEOL =>
                        if pixCounter >= BufferLength  then
                            current_state <= ResetPointer;                      -- Total nb of pixel read, reset pointer
                        else
                            current_state <= SyncGlobalFIFO;                    -- Total nb of pixels not reached, continue
                        end if;

                    when SyncGlobalFIFO =>
                        if GlobalFIFO_AlmostFull = '0' then
                            current_state <= GetPointer;                        -- Global FIFO still has space for more data, create a read        
                        else
                            current_state <= SyncGlobalFIFO;                    -- Global FIFO is full, wait for LCD controller to empty it
                        end if;

                    when GetPointer =>
                        i_clrBurstCounter <= '1';                               -- burst Counter is cleared
                        if unsigned(pixCounter) - unsigned(BufferLength) >= to_unsigned(2*DefaultBurstLength, i_burstcount'length) then   -- if pixels left to read > number of pixels in full burst  
                            i_burstcount <= std_logic_vector(to_unsigned(DefaultBurstLength, i_burstcount'length)); -- burst count is full length
                            i_nPixToCount <= std_logic_vector(to_unsigned(2*DefaultBurstLength, i_burstcount'length)); -- count full length pixels
                        else 
                            i_burstcount <= (0 => '1', others => '0');
                            if unsigned(pixCounter) - unsigned(BufferLength) > 1 then
                                i_nPixToCount <= "10";     -- Pix to count takes value 2
                            else
                                i_nPixToCount <= "01";     -- Pix to count takes value 2
                            end if;
                        end if;
                        current_state <= SetRdSignals;
            
                    when SetRdSignals =>
                        i_clrBurstCounter <= '0';                               -- Stop clr of Burst counter
                        i_read <= '1';                                          -- Assert read signal for new read
                        current_state <= WaitWaitRequest;
            
                    when WaitWaitRequest =>
                        if waitrequest = '0' then
                            current_state <= RealeaseRdSignals;                 -- Avalon bus is available and has received read signals, move to deassert state
                        else
                            current_state <= WaitWaitRequest;                   -- Avalon bus is still not available
                        end if;

                    when RealeaseRdSignals =>
                        i_read <= '0';                                          -- Release read signal
                        current_state <= SyncMasterFIFO1;   
                    
                    when SyncMasterFIFO1 =>
                        if MasterFIFO_empty = '0' then
                            current_state <= UpdateAddress;                     -- Master FIFO is not empty, at least one data has been sent, go to idle
                        else
                            current_state <= SyncMasterFIFO1;                   -- Master FIFO still hasn't received any data from read, wait
                        end if;

                    when UpdateAddress =>
                        i_address <= std_logic_vector(unsigned(i_address) + unsigned(i_burstcount));                  -- Append address pointer
                        current_state <= SyncMasterFIFO2;

                    when SyncMasterFIFO2 =>
                        if MasterFIFO_empty = '1' then
                            current_state <= CheckEOL;                          -- Master FIFO has been read and emptied, go to next read                     
                        else
                            current_state <= SyncMasterFIFO2;                   -- Master FIFO operation not finished 
                        end if;
                    
                    when ResetPointer =>
                        i_address <= StartAddress;                              -- Reset address pointer to StartAddress
                        i_clrPixCounter <= '1';                                 -- Clear pixel counter for new frame
                        i_memRed <= '1';                                        -- Synchronize with IP_CAM                
                        current_state <= ClrMemRed;
                    
                    when ClrMemRed =>
                        i_clrPixCounter <= '0';                                 -- realase clear of pixel counter
                        i_memRed <= '0';                                        -- release sync with IP_CAM signal
                        current_state <= ClrMemRed;   

                    when others =>
                        current_state <= Idle;

                end case;

    		end if;
	end process;
    
    -- Apply internal to external
    read            <= i_read;      
    burstcount      <= i_burstcount;
    address         <= i_address;
    memRed          <= i_memRed;             
    nPixToCount     <= i_nPixToCount;                    
    clrPixCounter   <= i_clrPixCounter;      
    clrBurstCounter <= i_clrBurstCounter;       

end RTL;

