library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity lcd_controller_tb is
end lcd_controller_tb;

architecture test of lcd_controller_tb is

	signal clk : std_logic;
	signal nReset : std_logic;

    signal updateCmd : std_logic;
    signal updateParam : std_logic;
    signal regData : std_logic_vector(15 downto 0);
    signal FifoEmpty : std_logic;
    signal RdData : std_logic_vector(15 downto 0);

    signal RdFifo : std_logic;
    signal CSX : std_logic;
    signal D_CX : std_logic;
    signal WRX : std_logic;
    signal RDX : std_logic;
    signal D : std_logic_vector(15 downto 0);
    signal seqDone : std_logic;

	constant clk_periode : time := 20 ns;

begin

	dut : entity work.lcd_controller
	port map(clk => clk,
		nReset => nReset,
        updateCmd => updateCmd,
        updateParam => updateParam,
        regData => regData,
        FifoEmpty => FifoEmpty,
        RdData => RdData,
        RdFifo => RdFifo,
        CSX => CSX,
        D_CX => D_CX,
        WRX => WRX,
        RDX => RDX,
        D => D,
        seqDone => seqDone
        );

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
        updateParam <= '0';
        regData <= (others => '0');
        FifoEmpty <= '1';
        RdData <= (others => '0');

        wait for 20 ns;
        nReset <= '1';

        wait for 20 ns;
        regData <= "0000110000010001";
        RdData <= "0101010101010101";
        updateCmd <= '1';
        updateParam <= '1';
        FifoEmpty <= '0';

        wait for 30 ns;
        updateCmd <= '0';

        wait for 200 ns;
        updateParam <= '0';

        wait for 10 ns;
        FifoEmpty <= '1';

        wait for 200 ns;
        FifoEmpty <= '0';

		wait;
	end process;
	
end architecture test;