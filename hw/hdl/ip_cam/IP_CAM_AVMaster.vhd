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
        ack             : out std_logic
    );
end ip_cam_avmaster;

architecture comp of ip_cam_avmaster is

    constant LDC_addr : std_logic_vector(31 downto 0) := (others => '1');  -- TODO : Change LDC addr
    -- State reg
    type fsm_states is (
        ST_IDLE, ST_WAIT_DATA, ST_WRITE, ST_ACK, ST_WAIT_LCD, ST_WRITE_LCD
    );
    signal state_reg, state_next    : fsm_states;

    -- Current address 
    signal addr_reg, addr_next      : std_logic_vector(31 downto 0);
    signal write_data               : std_logic_vector(31 downto 0);

begin


    process(clk, nReset, new_frame, waitRequest, state_reg, fifo_empty)
    begin
        if nReset = '0' then
            state_reg       <= ST_IDLE;
            addr_reg        <= start_addr;
            state_next      <= ST_IDLE;
            addr_next       <= start_addr;
            ack             <= '0';

            address         <= (others => '0');
            write_n         <= '1';
            byteEnable_n    <= (others => '1');
            burstCount      <= (others => '0');
            datawr          <= (others => '0');

        elsif rising_edge(clk) then
            state_reg   <= state_next;
            addr_reg    <= addr_next;
            case state_reg is 
                when ST_IDLE =>
                    addr_next        <= start_addr;

                    ack             <= '0';

                    address         <= (others => '0');
                    write_n         <= '1';
                    byteEnable_n    <= (others => '1');
                    burstCount      <= (others => '0');
                    datawr          <= (others => '0');

                    if new_frame = '1' then
                        state_next <= ST_WAIT_DATA;
                    end if;

                when ST_WAIT_DATA => 
                    ack <= '0';
                    if fifo_empty = '0' then
                        state_next      <= ST_WRITE;
                        address         <= addr_reg;
                        datawr          <= data;
                        write_n         <= '0';
                        byteEnable_n    <= "0000";

                    --elsif new_frame = '0' then
                    --    state_next  <= ST_WAIT_LCD;
                    end if;

                when ST_WRITE =>
                    if waitRequest = '0' then
                        state_next  <= ST_ACK;
                        addr_next   <= std_logic_vector(unsigned(addr_reg) + 1);
                        --state_next  <= ST_WAIT_DATA;
                        write_n         <= '1';
                    end if;
                
                when ST_ACK => 
                    ack         <= '1';
                    state_next  <= ST_WAIT_DATA;

                when ST_WAIT_LCD =>
                    state_next      <= ST_WRITE_LCD;
                    address         <= LDC_addr;
                    datawr(1)       <= '1';
                    write_n         <= '0';
                    byteEnable_n    <= "0000";

                when ST_WRITE_LCD => 
                    if waitRequest = '0' then
                        state_next  <= ST_IDLE;
                    end if;
            end case;

        end if;

    end process;


--    process(clk, nReset, new_frame, waitRequest, new_data, state_reg)
--    begin
--        if nReset = '0' then
--            state_reg       <= ST_IDLE;
--            addr_reg        <= start_addr;
--            state_next      <= ST_IDLE;
--            addr_next       <= start_addr;
--            ack             <= '0';
--
--            address         <= (others => '0');
--            write_n         <= '1';
--            byteEnable_n    <= (others => '1');
--            burstCount      <= (others => '0');
--            datawr          <= (others => '0');
--
--        elsif rising_edge(clk) then
--            state_reg   <= state_next;
--            addr_reg    <= addr_next;
--            case state_reg is 
--                when ST_IDLE =>
--                    addr_next        <= start_addr;
--
--                    ack             <= '0';
--
--                    address         <= (others => '0');
--                    write_n         <= '1';
--                    byteEnable_n    <= (others => '1');
--                    burstCount      <= (others => '0');
--                    datawr          <= (others => '0');
--
--                    if new_frame = '1' then
--                        state_next <= ST_WAIT_DATA;
--                    end if;
--
--                when ST_WAIT_DATA => 
--                    if new_data = '1' then
--                        state_next      <= ST_WRITE;
--                        address         <= addr_reg;
--                        datawr          <= data;
--                        write_n         <= '0';
--                        byteEnable_n    <= "0000";
--
--                    --elsif new_frame = '0' then
--                    --    state_next  <= ST_WAIT_LCD;
--                    end if;
--
--                when ST_WRITE =>
--                    if waitRequest = '0' then
--                        state_next  <= ST_ACK;
--                        write_n         <= '1';
--                    end if;
--                
--                when ST_ACK => 
--                    ack         <= '1';
--                    addr_next   <= std_logic_vector(unsigned(addr_reg) + 1);
--                    state_next  <= ST_WAIT_DATA;
--
--                when ST_WAIT_LCD =>
--                    state_next      <= ST_WRITE_LCD;
--                    address         <= LDC_addr;
--                    datawr(1)       <= '1';
--                    write_n         <= '0';
--                    byteEnable_n    <= "0000";
--
--                when ST_WRITE_LCD => 
--                    if waitRequest = '0' then
--                        state_next  <= ST_IDLE;
--                    end if;
--            end case;
--
--        end if;
--
--    end process;
end comp;