library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ReadMemCtrl is
	generic(
        DefaultBurstLength : integer := 4
    );
    port(
		clk : in std_logic;
		nReset : in std_logic;

		--Inputs
        waitrequest             : in std_logic;
        MasterFIFO_empty         : in std_logic;   
        GlobalFIFO_AlmostFull   : in std_logic;
        StartAddress            : in std_logic_vector(31 downto 0);
        BufferLength            : in std_logic_vector(31 downto 0);             -- Number of pixels to read in memory

        --Outputs
        read        : out std_logic;
        burstcount  : out std_logic_vector(3 downto 0);
        address     : out std_logic_vector(31 downto 0)            

	);
end ReadMemCtrl;

architecture RTL of ReadMemCtrl is

	type states is (Idle, SyncGlobalFIFO, GetPointer, SetRdSignals, WaitWaitRequest, RealeaseRdSignals, SyncMasterFIFO);
	signal current_state: states;
	attribute enum_encoding: string;
	attribute enum_encoding of states: type is "gray";

	
    --internal signals
    signal i_read       : std_logic                     := '0';
    signal i_burstcount : std_logic_vector(3 downto 0)  := (others => '0');
    signal i_address    : std_logic_vector(31 downto 0) := (others => '0');

    signal i_maxburstLength     : std_logic_vector(to_unsigned(DefaultBurstLength, burstcount'length)) -- Maximal nb of burst per burst read 
    signal i_curPixel           : std_logic_vector(31 down to 0);               -- current pixel observed 


begin


	process(clk, nReset, current_state)
	begin
    		if nReset = '0' then
                --reset values
                i_read       <= '0';
                i_burstcount <= (others => '0');
                i_address    <= (others => '0');

    		elsif rising_edge(clk) then

				case current_state is
		
                    when Idle =>
                        if MasterFIFO_empty = '1' then
                            current_state <= SyncGlobalFIFO;                    -- Master Fifo has been emptied, go to next state
                        else
                            current_state <= Idle;                              -- Master Fifo still contains data, keep waiting
                        end if;
            
                    when SyncGlobalFIFO =>
                        if GlobalFIFO_AlmostFull = '0' then
                            current_state <= GetPointer;                        -- Global FIFO still has space for more data, create a read        
                        else
                            current_state <= SyncGlobalFIFO;                    -- Global FIFO is full, wait for LCD controller to empty it
                        end if;

                    when GetPointer =>
                        
                        current_state <= SetRdSignals;
            
                    when SetRdSignals =>
            

                    when WaitWaitRequest =>
                        if waitrequest = '0' then
                            current_state <= RealeaseRdSignals;                 -- Avalon bus is available and has received read signals, move to deassert state
                        else
                            current_state <= WaitWaitRequest;                   -- Avalon bus is still not available
                        end if;

                    when RealeaseRdSignals =>

                        current_state <= SetRdSignals;
                    
                    when SyncMasterFIFO =>
                        if MasterFIFO_empty = '0' then
                            current_state <= Idle;                              -- Master FIFO is not empty, at least one data has been sent, go to idle
                        else
                            current_state <= SyncMasterFIFO;                    -- Master FIFO still hasn't received ant data from read, wait
                        end if;


                    when others =>
                        current_state <= Idle;

                end case;

    		end if;
	end process;

    --Apply internal to external
    -- d <= d_i
    read          <= i_read;      
    burstcount    <= i_burstcount;
    address       <= i_address;   

end ReadMemCtrl;

