library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity framegen_tb is
end framegen_tb;

architecture test of framegen_tb is

	signal clk : std_logic;
	signal nReset : std_logic;

    signal dataSeq : std_logic_vector(15 downto 0);
    signal framegenEnabled : std_logic;
    signal D_CX_Seq : std_logic;

    signal frame_finished : std_logic;
    signal CSX : std_logic;
    signal D_CX : std_logic;
    signal WRX : std_logic;
    signal RDX : std_logic;
    signal D : std_logic_vector(15 downto 0);

	constant clk_periode : time := 20 ns;

begin

	dut : entity work.framegen
	port map(clk => clk,
		nReset => nReset,
        dataSeq => dataSeq,
        framegenEnabled => framegenEnabled,
        D_CX_Seq => D_CX_Seq,
        frame_finished => frame_finished,
        CSX => CSX,
        D_CX => D_CX,
        WRX => WRX,
        RDX => RDX,
        D => D);

	CLOCK :process
	begin
		clk <= '1';
		wait for clk_periode/2;
		clk <= '0';
		wait for clk_periode/2;
	end process;

	simulation : process
	begin
		nReset <= '0';
        dataSeq <= "0000000000000000";
        framegenEnabled <= '0';
        D_CX_Seq <= '0';

        wait for 20 ns;
        nReset <= '1';

		wait;
	end process;
	
end architecture test;