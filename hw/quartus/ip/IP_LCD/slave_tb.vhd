library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity slave_tb is
end slave_tb;

architecture test of slave_tb is

	signal clk : std_logic;
	signal nReset : std_logic;

    signal address : std_logic_vector(2 downto 0);
    signal write : std_logic;
    signal read : std_logic;
    signal writedata : std_logic_vector(31 downto 0);
    signal readdata : std_logic_vector(31 downto 0);

    signal FIFO_full : std_logic;
    signal FIFO_almost_full : std_logic;
    signal FIFO_empty : std_logic;
    signal FIFO_almost_empty : std_logic;
    signal seqDone : std_logic;

    signal bufferLength : std_logic_vector(31 downto 0);
    signal startAddress : std_logic_vector(31 downto 0);
    signal updateCmd : std_logic;
    signal updateParam : std_logic;
    signal regData : std_logic_vector(15 downto 0);

	constant clk_periode : time := 20 ns;

begin

	dut : entity work.slave
	port map(clk => clk,
		nReset => nReset,
        address => address,
        write => write,
        read => read,
        writedata => writedata,
        readdata => readdata,
        FIFO_full => FIFO_full,
        FIFO_almost_full => FIFO_almost_full,
        FIFO_empty => FIFO_empty,
        FIFO_almost_empty => FIFO_almost_empty,
        seqDone => seqDone,
        bufferLength => bufferLength,
        startAddress => startAddress,
        updateCmd => updateCmd,
        updateParam => updateParam,
        regData => regData);

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

        wait for 20 ns;
        nReset <= '1';

		wait;
	end process;
	
end architecture test;