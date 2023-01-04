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
    signal memWritten : std_logic;
    signal CAMaddress : std_logic_vector(31 downto 0);
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
        memWritten => memWritten,
        CAMaddress => CAMaddress,
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

    procedure avalonWrite(constant addr : in natural;
                          constant data : in natural) is
    begin

        address <= std_logic_vector(to_unsigned(addr, 3));
        writedata <= std_logic_vector(to_unsigned(data, 32));
        write <= '1';
        wait for 20 ns;
        write <= '0';
        wait for 20 ns;

    end procedure avalonWrite;

    procedure avalonRead(constant addr : in natural) is
    begin

        address <= std_logic_vector(to_unsigned(addr, 3));
        read <= '1';
        wait for 20 ns;
        read <= '0';
        wait for 20 ns;

    end procedure avalonRead;

	begin
		nReset <= '0';
        address <= "000";
        write <= '0';
        read <= '0';
        writedata <= (others => '0');
        FIFO_full <= '0';
        FIFO_almost_full <= '0';
        FIFO_empty <= '1';
        FIFO_almost_empty <= '0';
        seqDone <= '0';

        wait for 20 ns;
        nReset <= '1';

        wait for 20 ns;
        avalonWrite(1, 16#00DAAAAA#);
        seqDone <= '1';

        wait for 40 ns;
        avalonWrite(2, 16#00ABBBBB#);

        wait for 40 ns;
        avalonWrite(3, 16#000000AA#);
        seqDone <= '0';

        wait for 40 ns;
        avalonWrite(3, 16#000000AB#);

        wait for 40 ns;
        avalonWrite(3, 16#000000BA#);
        seqDone <= '1';

        wait for 40 ns;
        avalonWrite(4, 16#000000BB#);

        wait for 20 ns;
        FIFO_full <= '1';
        FIFO_almost_full <= '1';
        FIFO_empty <= '0';
        FIFO_almost_empty <= '0';

        wait for 20 ns;
        avalonRead(0);

        wait for 40 ns;
        avalonRead(1);

        wait for 40 ns;
        avalonRead(2);

        wait for 40 ns;
        avalonRead(3);

        wait for 40 ns;
        avalonRead(4);



		wait;
	end process;
	
end architecture test;