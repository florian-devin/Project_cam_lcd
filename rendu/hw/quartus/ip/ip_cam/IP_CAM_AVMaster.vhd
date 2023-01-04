library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ip_cam_avmaster is
    port(
        clk             : in  std_logic;
        nReset          : in  std_logic;

        -- Internal interface (i.e. Avalon slave).
        address         : out std_logic_vector(31 downto 0);
        write_n         : out std_logic;
        byteEnable_n    : out std_logic_vector(3 downto 0);
        burstCount      : out std_logic_vector(1 downto 0);
        datawr          : out std_logic_vector(31 downto 0);
        waitRequest     : in  std_logic;


        -- Internal interface (to slave)
        start_addr      : in  std_logic_vector(31 downto 0);
        length          : in  std_logic_vector(31 downto 0);

        -- Internal interface (to frame)
        data            : in  std_logic_vector(31 downto 0);
        fifo_empty      : in  std_logic;
        --new_data        : in  std_logic;
        new_frame       : in  std_logic;
        ack             : out std_logic;

        capture_done    : in  std_logic;
        LCD_addr        : in  std_logic_vector(31 downto 0)
    );
end ip_cam_avmaster;

architecture comp of ip_cam_avmaster is

    --constant LCD_addr : std_logic_vector(31 downto 0) := (others => '1');  -- TODO : Change LCD addr
    -- State reg
    type fsm_states is (
        ST_IDLE, ST_WAIT_DATA, ST_WRITE, ST_ACK, ST_WRITE_LCD
    );
    signal state_reg, state_next    : fsm_states;

    -- Current address 
    signal addr_reg, addr_next      : std_logic_vector(31 downto 0);
    signal write_data               : std_logic_vector(31 downto 0);

    signal capture_done_req         : std_logic;
    signal capture_done_rst_reg     : std_logic;
    signal capture_done_rst_next    : std_logic;  

    signal address_next             : std_logic_vector(31 downto 0);
    signal write_n_next             : std_logic;
    signal byteEnable_n_next        : std_logic_vector(3 downto 0);
    signal burstCount_next          : std_logic_vector(1 downto 0);
    signal datawr_next              : std_logic_vector(31 downto 0);
    signal ack_next                 : std_logic;

    signal address_reg              : std_logic_vector(31 downto 0);
    signal write_n_reg              : std_logic;
    signal byteEnable_n_reg         : std_logic_vector(3 downto 0);
    signal burstCount_reg           : std_logic_vector(1 downto 0);
    signal datawr_reg               : std_logic_vector(31 downto 0);
    signal ack_reg                  : std_logic;

begin


    STATE_LOGIC : process(clk, nReset, capture_done, start_addr, addr_reg)
    begin
        if nReset = '0' then
            state_reg               <= ST_IDLE;
            addr_reg                <= start_addr;
            capture_done_req        <= '0';
            address_reg             <= (others => '0');
            write_n_reg             <= '1';
            byteEnable_n_reg        <= (others => '1');
            burstCount_reg          <= (others => '0');
            datawr_reg              <= (others => '0');
            ack_reg                 <= '0';
            capture_done_rst_reg    <= '0';

        elsif rising_edge(clk) then
            state_reg               <= state_next;
            addr_reg                <= addr_next;
            address_reg             <= address_next;
            write_n_reg             <= write_n_next;
            byteEnable_n_reg        <= byteEnable_n_next;
            burstCount_reg          <= burstCount_next;
            datawr_reg              <= datawr_next;
            ack_reg                 <= ack_next;
            capture_done_rst_reg    <= capture_done_rst_next;
            if (capture_done = '1') then
                capture_done_req <= '1';
            elsif (capture_done_rst_reg = '1') then
                capture_done_req <= '0';
            end if;
        end if;
        end process;

        NEXT_STATE : process(clk,
                             nReset,
                             new_frame, 
                             waitRequest, 
                             state_reg, 
                             fifo_empty, 
                             length, 
                             start_addr, 
                             addr_reg, 
                             data,
                             address_reg,
                             write_n_reg,
                             byteEnable_n_reg,
                             datawr_reg,
                             ack_reg,
                             capture_done_req,
                             LCD_addr,
                             burstCount_reg,
                             capture_done_rst_reg)
        begin
            state_next              <= state_reg;
            addr_next               <= addr_reg;
            address_next            <= address_reg;
            write_n_next            <= write_n_reg;
            byteEnable_n_next       <= byteEnable_n_reg;
            burstCount_next         <= burstCount_reg;
            datawr_next             <= datawr_reg;
            ack_next                <= ack_reg;
            capture_done_rst_next   <= capture_done_rst_reg;
            case state_reg is 
                when ST_IDLE =>
                    addr_next               <= start_addr;
                    ack_next                <= '0';
                    --address_next            <= (others => '0');
                    write_n_next            <= '1';
                    byteEnable_n_next       <= (others => '1');
                    burstCount_next         <= (others => '0');
                    datawr_next             <= (others => '0');
                    capture_done_rst_next   <= '0';

                    if new_frame = '1' then
                        state_next      <= ST_WAIT_DATA;
                    end if;

                when ST_WAIT_DATA => 
                    ack_next <= '0';
                    if fifo_empty = '0' then
                        state_next          <= ST_WRITE;
                        address_next        <= addr_reg;
                        datawr_next         <= data;
                        write_n_next        <= '0';
                        byteEnable_n_next   <= "0000";
                    elsif capture_done_req = '1' then
                        state_next              <= ST_WRITE_LCD;
                        addr_next               <= start_addr;
                        capture_done_rst_next   <= '1';
                    end if;
                    
                when ST_WRITE =>
                    if waitRequest = '0' then
                        state_next      <= ST_ACK;
                        if (addr_reg = std_logic_vector(unsigned(start_addr) + unsigned(length))) then 
                            addr_next   <= start_addr;
                        else
                            addr_next   <= std_logic_vector(unsigned(addr_reg) + 1);
                        end if;
                        write_n_next    <= '1';
                        ack_next        <= '1';
                    end if;
                
                when ST_ACK => 
                    ack_next    <= '0';
                    state_next  <= ST_WAIT_DATA;

                when ST_WRITE_LCD => 
                    if waitRequest = '0' then
                        address_next        <= LCD_addr;
                        datawr_next(0)      <= '1';
                        write_n_next        <= '0';
                        byteEnable_n_next   <= "0000";
                        state_next          <= ST_IDLE;
                    end if;
            end case;

    end process;
    address         <= address_reg;
    write_n         <= write_n_reg;
    byteEnable_n    <= byteEnable_n_reg;
    burstCount      <= burstCount_reg;
    datawr          <= datawr_reg;
    ack             <= ack_reg;
end comp;