    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;


entity RdWrSeq is
    port(
		clk : in std_logic;                                                     
		nReset : in std_logic;

		--Inputs
        AM_read         : in std_logic;                                         -- Avalon Master read request
        burstcount      : in std_logic_vector(3 downto 0);                      -- Avalon Bus burst count for this burst read(nb of consecutive reads)
        BurstCounter    : in std_logic_vector(3 downto 0);                      -- Avalon Bus bursts counted in the current burstread 
        nPixToCount     : in std_logic_vector(1 downto 0);                      -- Nb of pixel to read in the current burstread
        lFIFO_q         : in std_logic_vector(15 downto 0);                     -- Output of the local FIFO
        lFIFO_rdempty   : in std_logic;                                         -- read empty status from local FIFO
        gFIFO_wrfull    : in std_logic;                                         -- write full status from global FIFO

        --Outputs
        gFIFO_wrreq : out std_logic;                                            -- Write request to global FIFO
        gFIFO_data  : out std_logic_vector(15 downto 0);                        -- Data to push in global FIFO
        lFIFO_rdreq : out std_logic                                             -- Read request to local FIFO
	);
end RdWrSeq;

architecture RTL of RdWrSeq is

	type states is (Idle, Init, waitBurstCompletion, rise_lFIFO_rdreq, fall_lFIFO_rdreq, 
                    check_gFIFO_wrfull, rise_gFIFO_wrreq, fall_gFIFO_wrreq,
                    check_curpix, check_lFIFO_rdempty, rise_lFIFO_rdreq_del, 
                    fall_lFIFO_rdreq_del);

	signal current_state: states;
	attribute enum_encoding: string;
	attribute enum_encoding of states: type is "gray";

    -- internal variables
    signal curPix           : unsigned := '0';                                  -- Pixels left to transfer
    signal curBurstcount    : unsigned := '0';                                  -- Bursts left to transfer

    -- internal signals
    signal i_gFIFO_wrreq : std_logic                        := '0';             -- internal Write request to global FIFO
    signal i_gFIFO_data  : std_logic_vector(15 downto 0)    := (others => '0'); -- internal Data to push in global FIFO
    signal i_lFIFO_rdreq : std_logic                        := '0';             -- internal Read request to local FIFO


begin


	process(clk, nReset, current_state)
	begin
    		if nReset = '0' then
                --reset values
                i_gFIFO_wrreq <= '0';             
                i_gFIFO_data  <= (others => '0'); 
                i_lFIFO_rdreq <= '0';
                curpix <= '0';             


    		elsif rising_edge(clk) then

				case current_state is
		
                    when Idle =>
                        if AM_read = '1' then
                            current_state <= Init;                              -- Read has been requested, start init
                        else
                            current_state <= Idle;                              -- No memory read requested available
                        end if;
                    
                    when Init =>
                        curPix          <= unsigned(nPixToCount);               -- Store number of pix to count for this cycle
                        curBurstcount   <= unsigned(burstcount);                -- Store number of bursts to count for this cycle
                        i_gFIFO_data <= (other => '0');                         -- clear buffer
                        current_state   <= waitBurstComplete;                   -- go to Wait end of burst read

                    when waitBurstCompletion =>
                        if curBurstcount = unsigned(BurstCounter) then
                            current_state <= rise_lFIFO_rdreq;                  -- local FIFO has received all data, begin transfer        
                        else
                            current_state <= waitBurstCompletion;               -- Wait for burstread completion
                        end if;

                    when rise_lFIFO_rdreq =>
                        i_lFIFO_rdreq <= '1';                                   -- Rising edge on lFIFO rdreq        
                        current_state <= fall_lFIFO_rdreq;                      -- Move to deassertion of lFIFO rdreq
            
                    when fall_lFIFO_rdreq =>
                        i_lFIFO_rdreq   <= '0';                                 -- Falling edge on lFIFO rdreq
                        i_gFIFO_data    <= lFIFO_q;                             -- Store output of lFIFO for transfer to gFIFO 
                        current_state   <= check_gFIFO_wrfull;                  -- Move to check if gFIFO full
            
                    when check_gFIFO_wrfull =>
                        if gFIFO_wrfull = '0' then
                            current_state <= rise_gFIFO_wrreq;                  -- gFIFO still has space left, write is possible, move to write
                        else
                            current_state <= check_gFIFO_wrfull;                -- No space left in gFIFO, loop to wait for space
                        end if;

                    when rise_gFIFO_wrreq =>
                        i_gFIFO_wrreq <= '1';                                   -- Rising edge on gFIFO wrreq        
                        current_state <= fall_gFIFO_wrreq;                      -- Move to deassertion of gFIFO wrreq
            
                    when fall_gFIFO_wrreq =>
                        i_gFIFO_wrreq   <= '0';                                 -- Falling edge on gFIFO wrreq
                        curPix          <= curPix - 1;                          -- One pixel has been pushed, decrease internal variable
                        current_state   <= check_curpix;                        -- Move to check if internal pix variable reached 0
                    
                    when check_curpix =>
                        if curPix = 0 then
                            current_state <= check_lFIFO_rdempty;               -- No more useful pixels left to read, go to check if lFIFO is empty
                        else
                            current_state <= rise_lFIFO_rdreq;                  -- Pixels left to read, loop to beginning of cycle
                        end if;

                    when check_lFIFO_rdempty =>
                        if lFIFO_rdempty = '1' then
                            current_state <= Idle;                              -- lFIFO is empty, wait for next AM_read
                        else
                            current_state <= rise_lFIFO_rdreq_del;              -- No useful pixels are left in the FIFO but it is not empty, move to delete cycle
                        end if;

                    when rise_lFIFO_rdreq_del =>
                        i_lFIFO_rdreq <= '1';                                   -- Rising edge on lFIFO rdreq    
                        current_state <= fall_lFIFO_rdreq_del;                  -- Move to deassertion of lFIFO rdreq
                    
                    when fall_lFIFO_rdreq_del =>
                        i_lFIFO_rdreq <= '0';                                   -- Falling edge on lFIFO rdreq    
                        current_state <= check_lFIFO_rdempty;                   -- Move to check if lFIFO is now empty
                    
                    when others =>
                        current_state <= Idle;

                end case;

    		end if;
	end process;
    
    -- Apply internal to external
    gFIFO_wrreq <= i_gFIFO_wrreq; 
    gFIFO_data  <= i_gFIFO_data;
    lFIFO_rdreq <= i_lFIFO_rdreq;

end RTL;

