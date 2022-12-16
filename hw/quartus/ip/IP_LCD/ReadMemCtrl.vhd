library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ReadMemCtrl is
	port(
		clk : in std_logic;
		nReset : in std_logic;

		--Inputs
        waitrequest             : in std_logic;
        MasterFIFOempty         : in std_logic;   
        GlobalFIFO_AlmostFull   : in std_logic;
        StartAddress            : in std_logic_vector(31 downto 0);
        BufferLength            : in std_logic_vector(31 downto 0);

        --Outputs
        read        : out std_logic;
        burstcount  : out std_logic_vector(3 downto 0);
        address     : out std_logic_vector(31 downto 0);            

		);
end ReadMemCtrl;

architecture RTL of ReadMemCtrl is

	type states is (idle, SyncGlobalFIFO, GetPointer, SetRdSignals, WaitWaitRequest, RealeaseRdSignals, SyncMasterFIFO);
	signal current_state: states;
	attribute enum_encoding: string;
	attribute enum_encoding of states: type is "gray";

	
    --internal signals
    signal i_read       : std_logic                     := '0';
    signal i_burstcount : std_logic_vector(3 downto 0)  := (others => '0');
    signal i_address    : std_logic_vector(31 downto 0) := (others => '0');

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
		
                    when idle =>
                    
            
                    when send_config1 =>


                    when send_config2 =>
    
            
                    when send_data1 =>
            

                    when send_data2 =>
                    
            
                    when others =>
                    
                end case;

    		end if;
	end process;

    --Apply internal to external
    -- d <= d_i

end ReadMemCtrl;

