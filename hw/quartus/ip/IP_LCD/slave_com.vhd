library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity slave_com is
	port(
		clk 	: in std_logic;
		nReset	: in std_logic;
		
		-- MCU interface (i.e. Avalon slave).
		address 	: in std_logic_vector(2 downto 0);
		write 		: in std_logic;
		read 		: in std_logic;
		writedata	: in std_logic_vector(31 downto 0);
		readdata 	: out std_logic_vector(31 downto 0);
		
		--Module interface
        FIFO_full : in std_logic; 
        FIFO_almost_full : in std_logic;
        FIFO_empty : in std_logic;
        FIFO_almost_empty : in std_logic;

		dataFifo : out std_logic_vector(8 downto 0);
        wrreq : out std_logic;
        bufferLength : out std_logic_vector(31 downto 0);
        startAddress : out std_logic_vector(31 downto 0)
	);
end slave_com;


architecture RTL of slave_com is

	signal iregFIFOStatus    : std_logic_vector(31 downto 0) := (others => '0');
    signal iregMemStartAddress : std_logic_vector(31 downto 0) := (others => '0');
    signal iregMemBufferLength : std_logic_vector(31 downto 0) := (others => '0');
    signal iregCfgCmd : std_logic_vector(31 downto 0) := (others => '0');
    signal iregCfgParam : std_logic_vector(31 downto 0) := (others => '0');
	
    signal iDataFifo : std_logic_vector(8 downto 0) := (others => '0');
    signal iWrreq : std_logic := '0';
    signal iBufferLength : std_logic_vector(31 downto 0) := (others => '0');
    signal iStartAddress : std_logic_vector(31 downto 0) := (others => '0');

    signal iNewCmd : std_logic := '0';
    signal iNewParam : std_logic := '0';
begin

    process(nReset, iregCfgCmd, iregCfgParam)
    begin
        if nReset = '0' then
            iBufferLength <= (others => '0');
            iStartAddress <= (others => '0');
            iDataFifo <= (others => '0');
            iWrreq <= '0';

        elsif rising_edge(clk) then
            iBufferLength <= iregMemBufferLength(31 downto 0);
            iStartAddress <= iregMemStartAddress(31 downto 0);

            iDataFifo <= (others => '0');
            iWrreq <= '0';

            if iNewCmd = '1' then
                iDataFifo <= iregCfgCmd(8 downto 0);
                iDataFifo(8) <= '0'
                iWrreq <= '1';
            elsif iNewParam = '1' then
                iDataFifo <= iregCfgParam(8 downto 0);
                iDataFifo(8) <= '1';
                iWrreq <= '1';
            end if;

        end if;
    end process;

	-- Avalon slave write to registers.
	process(clk, nReset)
	begin	
        if nReset = '0' then
            iregFIFOStatus <= (others => '0');
            iregMemStartAddress <= (others => '0');
            iregMemBufferLength <= (others => '0');
            iregCfgCmd <= (others => '0');
            iregCfgParam <= (others => '0');
            iNewParam <= '0';
            iNewCmd <= '0';

        elsif rising_edge(clk) then
            iNewParam <= '0';
            iNewCmd <= '0';
            if write = '1' then
                case address is
                    -- when "000" => DO NOTHING, FIFO status can only be read
                    when "001" => iregMemStartAddress <= writedata;
                    when "010" => iregMemBufferLength <= writedata;
                    when "011" => 
                        iregCfgCmd <= writedata;
                        iNewCmd <= '1';
                    when "100" => 
                        iregCfgParam <= writedata;
                        iNewParam <= '1';
                    when others => null;
                end case;
            end if;
        end if;
	end process;

    -- Write to FIFO registers
    process(clk, nReset)
    begin
        if nReset = '0' then
            iregFIFOStatus <= (others => '0');
        elsif rising_edge(clk) then
            iregFIFOStatus <= (others => '0');
            iregFIFOStatus(0) <= FIFO_full;
            iregFIFOStatus(1) <= FIFO_almost_full;
            iregFIFOStatus(2) <= FIFO_empty;
            iregFIFOStatus(3) <= FIFO_almost_empty;
        end if;
    end process;
	
	-- Avalon slave read from registers.
	process(clk)
	begin
		if rising_edge(clk) then
			readdata <= (others => '0');
			if read = '1' then
				case address is
					when "000" => readdata <= iregFIFOStatus;
                    when "001" => readdata <= iregMemStartAddress;
                    when "010" => readdata <= iregMemBufferLength;
                    when "011" => readdata <= iregCfgCmd;
                    when "100" => readdata <= iregCfgParam;
					when others => null;
				end case;
			end if;
		end if;
	end process;

    dataFifo <= iDataFifo;
    wrreq <= iWrreq;
    bufferLength <= iBufferLength;
    startAddress <= iStartAddress;

end RTL;