library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity config_update is
	port(
		clk : in std_logic;
		nReset : in std_logic;

		seqDone : in std_logic;
        
        updateCmd : out std_logic;
        regCmd : out std_logic_vector(15 downto 0);
        updateParam : out std_logic;
        regParam : out std_logic_vector(15 downto 0)
		);
end config_update;

architecture RTL of config_update is

	type states is (idle, sendData, waitFramegen, tempoData);
	signal current_state: states;
	attribute enum_encoding: string;
	attribute enum_encoding of states: type is "gray";

	signal updateCmd_i : std_logic := '0';
    signal regCmd_i : std_logic_vector(15 downto 0) := (others => '0');
    signal updateParam_i : std_logic := '0';
    signal regParam_i : std_logic_vector(15 downto 0) := (others => '0');
begin


	process(clk, nReset, current_state)
	begin
    		if nReset = '0' then
                updateCmd_i <= '0';
                regCmd_i <= (others => '0');
                updateParam_i <= '0';
                regParam_i <= (others => '0');
        		current_state <= idle;
				
    		elsif rising_edge(clk) then

				case current_state is
		
				when idle =>    
        
                when others =>
                    current_state <= idle;
                end case;

    		end if;
	end process;

    updateCmd <= updateCmd_i;
    regCmd <= regCmd_i;
    updateParam <= updateParam_i;
    regParam <= regParam_i;

end RTL;

