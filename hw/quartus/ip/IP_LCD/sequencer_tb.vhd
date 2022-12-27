library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sequencer_tb is
end sequencer_tb;

architecture test of sequencer_tb is

	signal clk : std_logic;
	signal nReset : std_logic;

    signal updateCmd : std_logic;
    signal regCmd : std_logic_vector(15 downto 0);
    signal updateParam : std_logic;
    signal regParam : std_logic_vector(15 downto 0);
    signal FifoEmpty : std_logic;
    signal frame_finished : std_logic;
    signal RdData : std_logic_vector(15 downto 0);

    signal framegenEnabled : std_logic;
    signal dataSeq : std_logic_vector(15 downto 0);
    signal D_CX_Seq : std_logic;
    signal RdFifo : std_logic;

	constant clk_periode : time := 20 ns;

begin

	dut : entity work.sequencer

	port map(clk => clk,
		nReset => nReset,
        updateCmd => updateCmd,
        regCmd => regCmd,
        updateParam => updateParam,
        regParam => regParam,
        FifoEmpty => FifoEmpty,
        frame_finished => frame_finished,
        RdData => RdData,
        framegenEnabled => framegenEnabled,
        dataSeq => dataSeq,
        D_CX_Seq => D_CX_Seq,
        RdFifo => RdFifo);

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
        updateCmd <= '0';
        regCmd <= (others => '0');
        updateParam <= '0';
        regParam <= (others => '0');
        FifoEmpty <= '0';
        frame_finished <= '0';
        RdData <= (others => '0');

        wait for 20 ns;
        nReset <= '1';

		wait;
	end process;
	
end architecture test;