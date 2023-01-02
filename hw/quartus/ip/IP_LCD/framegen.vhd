library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity framegen is
	port(
		clk : in std_logic;
		nReset : in std_logic;

		dataSeq : in std_logic_vector(15 downto 0);
        framegenEnabled : in std_logic;
        D_CX_Seq : in std_logic;
		
        frame_finished : out std_logic;
        CSX : out std_logic;
        D_CX : out std_logic;
        WRX : out std_logic;
        RDX : out std_logic;
        D : out std_logic_vector(15 downto 0)
		);
end framegen;

architecture RTL of framegen is

	type states is (idle, send1, send2, send3, send4);
	signal current_state: states;
	attribute enum_encoding: string;
	attribute enum_encoding of states: type is "gray";

	signal frame_finished_i : std_logic := '0';
	signal CSX_i : std_logic := '0';
	signal D_CX_i : std_logic := '0';
    signal WRX_i : std_logic := '0';
    signal RDX_i : std_logic := '0';
    signal D_i : std_logic_vector(15 downto 0) := (others => '0');

begin

	process(clk, nReset, current_state)
	begin
    		if nReset = '0' then
                frame_finished_i <= '0';
                CSX_i <= '1'; -- Not sure about the initial value
                D_CX_i <= '0';
                WRX_i <= '0';
                RDX_i <= '0';
                D_i <= (others => '0');
        		current_state <= idle;
				
    		elsif rising_edge(clk) then

				case current_state is
		
				when idle =>
                    frame_finished_i <= '1';
                    CSX_i <= '1';
                    D_CX_i <= '0';
                    WRX_i <= '0';
                    RDX_i <= '1';
					if framegenEnabled = '1' then
                        current_state <= send1;
                        D_i <= dataSeq;
                        frame_finished_i <= '0';
					end if;
		
				when send1 =>
					CSX_i <= '0';
                    D_CX_i <= D_CX_Seq;
                    WRX_i <= '0';
                    current_state <= send2;

                when send2 =>
                    -- Second clock cycle of WRX at low
                    current_state <= send3;

                when send3 =>
                    WRX_i <= '1';
                    current_state <= send4;

                when send4 =>
                    -- Second clock cycle of WRX at high
                    current_state <= idle;
        
                when others =>
                    current_state <= idle;
                end case;

    		end if;
	end process;

    frame_finished <= frame_finished_i;
    CSX <= CSX_i;
    D_CX <= D_CX_i;
    WRX <= WRX_i;
    RDX <= RDX_i;
    D <= D_i;

end RTL;