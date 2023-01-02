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
    signal write 		: std_logic;
    signal readSlave 		: std_logic;
    signal writedata	: std_logic_vector(31 downto 0);
    signal readdataSlave 	: std_logic_vector(31 downto 0);

    signal memWritten : std_logic;
    signal memRed : std_logic;
    signal addressMaster : std_logic_vector(31 downto 0);
    signal burstcount : std_logic_vector(3 downto 0);
    signal readMaster : std_logic;
    signal waitrequest : std_logic;
    signal readdatavalid : std_logic;
    signal readdataMaster : std_logic_vector(31 downto 0);

    signal CSX : std_logic;
    signal D_CX : std_logic;
    signal RDX : std_logic;
    signal WRX : std_logic;
    signal D : std_logic_vector(15 downto 0);

begin


	-- Instantiate DUT
	dut : entity work.IP_LCD_wrapper
    port map(
		clk     => clk,
		nReset  => nReset,
        addressSlave => addressSlave,
        write => write,
        readSlave => readSlave,
        writedata => writedata,
        readdataSlave => readdataSlave,
        memWritten => memWritten,
        memRed => memRed,
        addressMaster => addressMaster,
        burstcount => burstcount,
        readMaster => readMaster,
        waitrequest => waitrequest,
        readdatavalid => readdatavalid,
        readdataMaster => readdataMaster,
        CSX => CSX,
        D_CX => D_CX,
        RDX => RDX,
        WRX => WRX,
        D => D         
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
        writedata <= std_logic_vector(to_unsigned(data, 32));
        write <= '1';
        wait for 20 ns;
        write <= '0';
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

        memWritten<= '1';
        wait for CLK_PERIOD;
		memWritten <= '0';
        wait until rising_edge(clk);
		
        wait for 2*TIME_DELTA;
        -- simulate read data valid fom Avalon Bus
        readdatavalid<= '1';
        wait for CLK_PERIOD;
		readdatavalid <= '0';
        wait until rising_edge(clk);

        wait for 500 ns;
        -- simulate read data valid fom Avalon Bus
        readdatavalid<= '1';
        wait for CLK_PERIOD;
		readdatavalid <= '0';
        wait until rising_edge(clk);


	end procedure buflen3;

    procedure buflen9 is
	begin 
        avalonWrite(2, 16#00000009#);
        wait for 40 ns;

        memWritten<= '1';
        wait for CLK_PERIOD;
		memWritten <= '0';
        wait until rising_edge(clk);
		
        wait for 2*TIME_DELTA;
        
        -- simulate read data valid fom Avalon Bus
        readdatavalid<= '1';
        wait for CLK_PERIOD;
		readdatavalid <= '0';
        wait until rising_edge(clk);

        wait for TIME_DELTA;
        -- simulate read data valid fom Avalon Bus
        readdatavalid<= '1';
        wait for CLK_PERIOD;
		readdatavalid <= '0';
        wait until rising_edge(clk);

        wait for TIME_DELTA;
        -- simulate read data valid fom Avalon Bus
        readdatavalid<= '1';
        wait for CLK_PERIOD;
		readdatavalid <= '0';
        wait until rising_edge(clk);

        wait for TIME_DELTA;
        -- simulate read data valid fom Avalon Bus
        readdatavalid<= '1';
        wait for CLK_PERIOD;
		readdatavalid <= '0';
        waitrequest <= '1';
        wait until rising_edge(clk);

        wait for 10*TIME_DELTA;
        waitrequest <= '0';
        wait until rising_edge (clk);
        -- simulate read data valid fom Avalon Bus
        readdatavalid<= '1';
        wait for CLK_PERIOD;
		readdatavalid <= '0';
        wait until rising_edge(clk);


	end procedure buflen9;
	
	begin
	
    addressSlave <= (others => '0');
    write <= '0';
    readSlave <= '0';
    writedata <= x"00000000";
    readdataSlave <= x"00000000";
    memWritten <= '0';
    waitrequest <= '0';
    readdatavalid <= '0';
    readdataMaster <= x"421ABD9F";

    async_reset;

    wait for 20 ns;
    avalonWrite(1, 16#00000B0A#);
    wait for 2*TIME_DELTA;

    buflen9;

    wait for 50*TIME_DELTA;

    sim_finished <= true;
    wait;

	end process simulation;
	
end architecture test;