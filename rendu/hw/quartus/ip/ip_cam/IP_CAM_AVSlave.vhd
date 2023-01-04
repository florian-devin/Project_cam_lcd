library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ip_cam_avslave is
    port(
        clk             : in  std_logic;
        nReset          : in  std_logic;

        -- Internal interface (i.e. Avalon slave).
        address         : in  std_logic_vector(2 downto 0);
        write_n         : in  std_logic;
        read_n          : in  std_logic;
        writedata       : in  std_logic_vector(31 downto 0);
        readdata        : out std_logic_vector(31 downto 0);

        -- Internal interface (to master)
        start_addr      : out std_logic_vector(31 downto 0);
        length          : out std_logic_vector(31 downto 0);

        -- Internal interface (to frame)
        capture_done    : in  std_logic;
        acquisition     : out std_logic;

        LCD_addr        : out std_logic_vector(31 downto 0)
    );
end ip_cam_avslave;

architecture comp of ip_cam_avslave is

    signal CamAddr      : std_logic_vector(31 downto 0);
    signal CamLength    : std_logic_vector(31 downto 0);
    signal CamStatus    : std_logic;
    signal CamStart     : std_logic;
    signal CamStop      : std_logic;
    signal CamSnapshot  : std_logic;
    signal CamLCDAdrr   : std_logic_vector(31 downto 0);

begin

    process(clk, nReset, capture_done)
    begin
        if nReset = '0' then
            start_addr      <= (others => '0');
            length          <= (others => '0');
            acquisition     <= '0';
            CamAddr         <= (others => '0');
            CamLength       <= (others => '0');
            CamStatus       <= '0';
            CamStart        <= '0';
            CamSnapshot     <= '0';
            CamStop         <= '0';
            CamLCDAdrr      <= (others => '0');

        elsif rising_edge(clk) then
            readdata        <= (others => '0');
            acquisition     <= '0';

            if (capture_done = '1') then
                CamSnapshot <= '0';
                CamStatus   <= '0';
            end if;
            
            start_addr      <= CamAddr;
            length          <= CamLength;

            if write_n = '0' then
                case address is
                    when "000" => CamAddr       <= writedata;
                    when "001" => CamLength     <= writedata;
                    when "011" => 
                        CamStart      <= '1';
                        if (CamSnapshot = '1') then
                            acquisition <= '1';
                            CamStatus   <= '1';
                        end if;
                    when "100" => CamStart      <= '0';
                                  CamSnapshot   <= '0';     --CamStop
                    when "101" => 
                        CamSnapshot   <= '1';
                        if (CamStart = '1') then
                            acquisition <= '1';
                            CamStatus   <= '1';
                        end if;
                    when "110" => CamLCDAdrr <= writedata;
                    when others => null;
                end case;
            end if;

            
            if read_n = '0' then
                case address is
                    when "000" => readdata      <= CamAddr;
                    when "001" => readdata      <= CamLength;
                    when "010" => readdata(0)   <= CamStatus;
                                  readdata(31 downto 1) <= x"0000000" & "000";
                    when "110" => readdata      <= CamLCDAdrr;
                    when others => null;
                end case;
            end if;
        end if;

    end process;
    LCD_addr <= CamLCDAdrr;

end comp;