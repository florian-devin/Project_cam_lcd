library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IP_LCD_wrapper_tb is
end IP_LCD_wrapper_tb;

architecture test of IP_LCD_wrapper_tb is
	--clock period
	constant CLK_PERIOD : time := 20 ns;
	
	-- delta time between two different inputs
	constant TIME_DELTA : time := 10*CLK_PERIOD;

    signal clk      : std_logic;
	signal nReset   : std_logic;

    signal sim_finished : boolean := false;

    signal addressSlave 	: std_logic_vector(2 downto 0);
    signal writeSlave 		: std_logic;
    signal readSlave 		: std_logic;
    signal writedataSlave	: std_logic_vector(31 downto 0);
    signal readdataSlave 	: std_logic_vector(31 downto 0);

    signal addressMaster : std_logic_vector(31 downto 0);
    signal burstcount : std_logic_vector(3 downto 0);
    signal readMaster : std_logic;
    signal waitrequestMaster : std_logic;
    signal readdatavalidMaster : std_logic;
    signal readdataMaster : std_logic_vector(31 downto 0);
    signal writedataMaster : std_logic_vector(31 downto 0);
    signal writeMaster : std_logic;

    signal CSX : std_logic;
    signal D_CX : std_logic;
    signal RDX : std_logic;
    signal WRX : std_logic;
    signal D : std_logic_vector(15 downto 0);
    signal LCD_ON : std_logic;
    signal LCD_RESET : std_logic;

begin


	-- Instantiate DUT
	dut : entity work.IP_LCD_wrapper
    port map(
		clk     => clk,
		nReset  => nReset,
        addressSlave => addressSlave,
        writeSlave => writeSlave,
        readSlave => readSlave,
        writedataSlave => writedataSlave,
        readdataSlave => readdataSlave,
        addressMaster => addressMaster,
        burstcount => burstcount,
        readMaster => readMaster,
        writeMaster => writeMaster,
        waitrequestMaster => waitrequestMaster,
        readdatavalidMaster => readdatavalidMaster,
        readdataMaster => readdataMaster,
        writedataMaster => writedataMaster,
        CSX => CSX,
        D_CX => D_CX,
        RDX => RDX,
        WRX => WRX,
        D => D,
        LCD_ON => LCD_ON,
        LCD_RESET => LCD_RESET 
    );
	
	-- Generate CLK signal
	clk_generation : process
	begin
		if not sim_finished then
			clk <= '1';
			wait for CLK_PERIOD / 2;
			clk <= '0';
			wait for CLK_PERIOD / 2;
		else 
			wait;
		end if;
	end process clk_generation;

			
-- Simulation
	simulation : process
	
-- Reset procedure	
	procedure async_reset is
	begin 
		wait until rising_edge(clk);
		wait for CLK_PERIOD/4;
		nReset <= '0';
		
		wait for CLK_PERIOD/2;
		nReset <= '1';
	end procedure async_reset;

    procedure avalonWrite(constant addr : in natural;
                          constant data : in natural) is
    begin

        addressSlave <= std_logic_vector(to_unsigned(addr, 3));
        writedataSlave <= std_logic_vector(to_unsigned(data, 32));
        writeSlave <= '1';
        wait for 20 ns;
        writeSlave <= '0';
        wait for 20 ns;

    end procedure avalonWrite;

    procedure avalonRead(constant addr : in natural) is
    begin

        addressSlave <= std_logic_vector(to_unsigned(addr, 3));
        readSlave <= '1';
        wait for 20 ns;
        readSlave <= '0';
        wait for 20 ns;

    end procedure avalonRead;

    procedure buflen3 is
	begin 
        avalonWrite(2, 16#00000003#);
        wait for 40 ns;

        wait until rising_edge(clk);
		
        wait for 2*TIME_DELTA;
        -- simulate read data valid fom Avalon Bus
        readdatavalidMaster<= '1';
        wait for CLK_PERIOD;
		readdatavalidMaster <= '0';
        wait until rising_edge(clk);

        wait for 500 ns;
        -- simulate read data valid fom Avalon Bus
        readdatavalidMaster<= '1';
        wait for CLK_PERIOD;
		readdatavalidMaster <= '0';
        wait until rising_edge(clk);


	end procedure buflen3;

    procedure buflen9 is
	begin 
        avalonWrite(2, 16#00000009#);
        wait for 40 ns;

        avalonWrite(5, 16#00000000#);
        wait until rising_edge(clk);
		
        wait for 2*TIME_DELTA;
        
        -- simulate read data valid fom Avalon Bus
        readdataMaster <= X"00DBC53A";
        readdatavalidMaster<= '1';
        wait for CLK_PERIOD;
		readdatavalidMaster <= '0';
        wait until rising_edge(clk);

        wait for TIME_DELTA;
        -- simulate read data valid fom Avalon Bus
        readdatavalidMaster<= '1';
        wait for CLK_PERIOD;
		readdatavalidMaster <= '0';
        wait until rising_edge(clk);

        wait for TIME_DELTA;
        -- simulate read data valid fom Avalon Bus
        readdataMaster <= X"00060A0E";
        readdatavalidMaster<= '1';
        wait for CLK_PERIOD;
		readdatavalidMaster <= '0';
        wait until rising_edge(clk);

        wait for TIME_DELTA;
        -- simulate read data valid fom Avalon Bus
        readdatavalidMaster<= '1';
        wait for CLK_PERIOD;
		readdatavalidMaster <= '0';
        waitrequestMaster <= '1';
        wait until rising_edge(clk);

        wait for 10*TIME_DELTA;
        waitrequestMaster <= '0';
        wait for CLK_PERIOD;
        -- simulate read data valid fom Avalon Bus
        readdatavalidMaster<= '1';
        wait for CLK_PERIOD;
		readdatavalidMaster <= '0';
        wait until rising_edge(clk);


	end procedure buflen9;
	
	begin
	
    addressSlave <= (others => '0');
    writeSlave <= '0';
    readSlave <= '0';
    readdataSlave <= x"00000000";
    waitrequestMaster <= '0';
    readdatavalidMaster <= '0';
    readdataMaster <= x"421ABD9F";

    async_reset;
    wait for 20 ns;
    avalonWrite(6, 16#000EAEEAA#);

    wait for 20 ns;
    avalonWrite(1, 16#00000B0A#);
    wait for 2*TIME_DELTA;

    buflen9;

    wait for 20*TIME_DELTA;
    buflen9;
    wait for 30*TIME_DELTA;

    sim_finished <= true;
    wait;

	end process simulation;
	
end architecture test;