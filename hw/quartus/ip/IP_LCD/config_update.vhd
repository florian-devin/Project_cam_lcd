library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity config_update is
	port(
		clk : in std_logic;
		nReset : in std_logic;

		seqDone : in std_logic;
		SlaveFifoEmpty : in std_logic;
		q : in std_logic_vector(8 downto 0);
        
        updateCmd : out std_logic;
        updateParam : out std_logic;
        regData : out std_logic_vector(15 downto 0);
		rdreq : out std_logic
		);
end config_update;

architecture RTL of config_update is

	type states is (idle, askData, receiveData);
	signal current_state: states;
	attribute enum_encoding: string;
	attribute enum_encoding of states: type is "gray";

	signal updateCmd_i : std_logic := '0';
    signal updateParam_i : std_logic := '0';
    signal regData_i : std_logic_vector(15 downto 0) := (others => '0');
	signal rdreq_i : std_logic := '0';
begin


	process(clk, nReset, current_state)
	begin
    		if nReset = '0' then
                updateCmd_i <= '0';
                updateParam_i <= '0';
                regData_i <= (others => '0');
				rdreq_i <= '0';
        		current_state <= idle;
				
    		elsif rising_edge(clk) then

				case current_state is
		
				when idle =>
					regData_i <= (others => '0');
					updateCmd_i <= '0';
					updateParam_i <= '0';
					rdreq_i <= '0'; 
					if SlaveFifoEmpty = '0' AND seqDone = '1' then
						rdreq_i <= '1';
						current_state <= askData;
					end if;

				when askData =>
					rdreq_i <= '0';
					current_state <= receiveData;

				when receiveData =>
					regData_i(7 downto 0) <= q(7 downto 0);
					if q(8) = '0' then
						updateCmd_i <= '1';
					else
						updateParam_i <= '1';
					end if;
					current_state <= idle;

                when others =>
                    current_state <= idle;
                end case;

    		end if;
	end process;

    updateCmd <= updateCmd_i;
    updateParam <= updateParam_i;
    regData <= regData_i;
	rdreq <= rdreq_i;

end RTL;

