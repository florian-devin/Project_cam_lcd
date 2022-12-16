library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ip_cam_avslave is
    port(
        clk             : in  std_logic;
        nReset          : in  std_logic;

        -- Internal interface (i.e. Avalon slave).
        address         : in  std_logic_vector(2 downto 0);
        write           : in  std_logic;
        read            : in  std_logic;
        writedata       : in  std_logic_vector(31 downto 0);
        readdata        : out std_logic_vector(31 downto 0);

        -- Internal interface (to master)
        start_addr      : out std_logic_vector(31 downto 0);
        lenght          : out std_logic_vector(31 downto 0);

        -- Internal interface (to frame)
        capture_done    : in  std_logic;
        acquisition     : out std_logic
    );
end ip_cam_avslave;

architecture comp of ip_cam_avslave is

    signal CamAddr      : std_logic_vector(31 downto 0);
    signal CamLength    : std_logic_vector(31 downto 0);
    signal CamStatus    : std_logic;
    signal CamStart     : std_logic;
    signal CamStop      : std_logic;
    signal CamSnapshot  : std_logic;

begin

    process(clk, nReset)
    begin
        if nReset = '0' then
            start_addr      <= (others => '0');
            lenght          <= (others => '0');
            acquisition     <= '0';
        elsif rising_edge(clk) then
            acquisition     <= CamStart and CamSnapshot;
            CamStatus       <= capture_done;

            if (capture_done = '1') then
                CamSnapshot <= '0';
            end if;
            
            start_addr      <= CamAddr;
            lenght          <= CamLength;
        end if;

    end process;

    -- Avalon slave write to registers.
    process(clk, nReset)
    begin
        if nReset = '0' then
            CamAddr      <= (others => '0');
            CamLength    <= (others => '0');
            CamStatus    <= '0';
            CamStart     <= '0';
            CamSnapshot  <= '0';

        elsif rising_edge(clk) then
            if write = '1' then
                case address is
                    when "000" => CamAddr       <= writedata;
                    when "001" => CamLength     <= writedata;
                    when "011" => CamStart      <= '1';
                    when "100" => CamStart      <= '0'; 
                                  CamSnapshot   <= '0';     --CamStop
                    when "101" => CamSnapshot   <= '1';
                    when others => null;
                end case;
            end if;
        end if;
    end process;

        -- Avalon slave read from registers.
    process(clk)
    begin
        if rising_edge(clk) then
            readdata <= (others => '0');
            if read = '1' then
                case address is
                    when "000" => readdata      <= CamAddr;
                    when "001" => readdata      <= CamLength;
                    when "010" => readdata(0)   <= CamStatus;
                    when others => null;
                end case;
            end if;
        end if;
    end process;
end comp;