library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IP_CAM_Frame is
    port(
        clk     :   in  std_logic;
        nReset  :   in  std_logic;

        -- External interface from CAMERA

            -- Only 6 bits are routed from the camera DOUT
        CAM_data    :   in  std_logic_vector(5 downto 0) := std_logic_vector(to_signed(0, 6));
        Hsync       :   in  std_logic;
        Vsync       :   in  std_logic;
        Mclk        :   out  std_logic;
        CAM_reset   :   out std_logic := '1';
        pxl_clk     :   in  std_logic;

        -- IP_CAM_AVSlave interface
        capture_done:   out std_logic := '0';
        acquisition :   in  std_logic;

        -- IP_CAM_AVMaster interface
        new_data    :   out std_logic := '0';
        new_frame   :   out std_logic := '0';
        ack         :   in  std_logic;
        --Send to FIFO data        :   out std_logic_vector(15 downto 0) := std_logic_vector(to_signed(0, 16)); 

        -- Output FIFO
        output_interface    :   out   std_logic_vector (31 DOWNTO 0)

    );
end IP_CAM_Frame;

architecture  behav of IP_CAM_Frame is

    signal old_vsync  : std_logic := '0';
    signal old_hsync  : std_logic := '0';

    -- Buffer for GREEN2 and BLUE
    signal GREEN       :   std_logic_vector(5 downto 0);
    signal BLUE     :   std_logic_vector(4 downto 0);
    signal RED      :   std_logic_vector(4 downto 0);

    -- FIFO related internal signals
    signal data_red    :  std_logic_vector (4 DOWNTO 0);
    signal data_green  :  std_logic_vector (5 DOWNTO 0);
    signal data_interface  :  std_logic_vector (31 DOWNTO 0);

    signal read_red    :   std_logic;
    signal read_green  :   std_logic;
    signal read_interface  :   std_logic;

    signal write_red   :   std_logic;
    signal write_green :   std_logic;
    signal write_interface :   std_logic;

    --full_red    :   std_logic;
    --full_green  :   std_logic;
    --full_interface  :   std_logic;

    signal output_red  :   std_logic_vector (4 DOWNTO 0);
    signal output_green    :   std_logic_vector (5 DOWNTO 0);
    

    --empty_interface :   std_logic ;
    --usedw_interface :   std_logic_vector (7 DOWNTO 0)


    -- Declare state names and state variable
    type STATE_TYPE IS (ST_IDLE,
                        ST_WAIT_VSYNC,
                        ST_WAIT_HSYNC,
                        ST_SAMPLE_RED,
                        ST_SAMPLE_GREEN1,
                        ST_WAIT_LINE_CHANGE_GB,
                        ST_WAIT_LINE_CHANGE_RG,
                        ST_SAMPLE_GREEN2,
                        ST_SAMPLE_BLUE,
                        ST_CONVERT,
                        ST_SEND,
                        ST_DATA_CONTINUE,
                        ST_END);
    signal state   : STATE_TYPE;
begin

    -- FIFO mapping
    FIFO_red : entity work.FIFO_red
    port map(
        clock => clk,
        data => data_red,
        rdreq => read_red,
        wrreq => write_red,
        --full => full_red,
        q => output_red
    );

    FIFO_GREEN1 : entity work.FIFO_GREEN1
    port map(
        clock => clk,
        data => data_green,
        rdreq => read_green,
        wrreq => write_green,
        --full => full_green,
        q => output_green
    );

    FIFO_interface : entity work.FIFO_interface
    port map(
        clock => clk,
        data => data_interface,
        rdreq => ack,
        wrreq => write_interface,
        --full => full_interface,
        --empty => empty_interface,
        q => output_interface
        --usedw   => usedw_interface
    );

process(clk)
begin
    -- Send clock to camera, will return pxl_clk which uses PLL on Mclk
    Mclk <= clk;
end process;

process(clk, nReset) -- Sample data based on camera clock
variable GREEN2   :   integer := 0;
variable GREEN1   :   integer := 0;
begin

    -- Reset send to ST_IDLE state
    if nReset = '0' then
        capture_done <= '0';
        new_data <= '0';
        CAM_reset <= '0';
        new_frame <= '0';
        state <= ST_IDLE;

    elsif rising_edge(clk) then
        case state is

            -- Wait for acquisition to start
            when ST_IDLE =>
            CAM_reset <= '1';
            capture_done <= '0';
            if acquisition = '1' then
                old_vsync <= Vsync;
                state <= ST_WAIT_VSYNC;
            else null;
            end if;

            -- Wait for Vsync
            when ST_WAIT_VSYNC =>
            old_hsync <= Hsync;
            if Vsync = '1' and old_vsync = '0' then
                new_frame <= '1';
                state <= ST_WAIT_HSYNC;
            else null;
            end if;
            old_vsync <= Vsync;

            -- Wait for Hsync
            when ST_WAIT_HSYNC =>
            new_frame <= '0';
            if Hsync = '1' and old_hsync = '0' then
                state <= ST_SAMPLE_RED;
            else null;
            end if;
            old_hsync <= Hsync;

            -- Data read is RED pixel
            when ST_SAMPLE_RED =>
            write_green <= '0';        
            -- Put data in RED_FIFO (5 bits only, need to truncate)
            data_red <= CAM_data(4 downto 0); -- Data available on port
            write_red <= '1'; -- Data sent to FIFO
            state <= ST_SAMPLE_GREEN1;

            -- Data read is GREEN1 pixel
            when ST_SAMPLE_GREEN1 =>
            write_red <= '0';
            -- Checks if new line
            if Hsync = '0' then
                old_hsync <= Hsync;
                state <= ST_WAIT_LINE_CHANGE_GB;
            else            
                -- Put data in GREEN_FIFO (6 bits)
                data_green <= CAM_data;
                write_green <= '1';
                state <= ST_SAMPLE_RED;
            end if;

            -- Wait for new line to start
            when ST_WAIT_LINE_CHANGE_GB =>
            if Hsync = '1' and old_hsync ='0' then
                state <= ST_SAMPLE_GREEN2;
            else null;
            end if;
            old_hsync <= Hsync;

            -- Data read is GREEN2 pixel
            when ST_SAMPLE_GREEN2 =>
        
                -- Store data
                GREEN2 := to_integer(signed(CAM_data));
                state <= ST_SAMPLE_BLUE;

            -- Data is blue, need to convert the whole pixel into 16 bits
            when ST_SAMPLE_BLUE =>
            -- Store truncated data to 5 MSB and go to ST_CONVERT
            BLUE <= CAM_data(5 downto 1);
            state <= ST_CONVERT;

            -- Convert R G1 G2 & B data into 16-bits value
            -- Get Green and Red values from FIFOs
            when ST_CONVERT =>
            read_green <= '1';
            read_red <= '1';
            
            GREEN1  :=  to_integer(signed(output_green));
            RED     <=  output_red;
            GREEN1 := (GREEN1 + GREEN2) / 2;
            GREEN <= std_logic_vector(to_signed(GREEN1, 6));
            
            data_interface(4 downto 0) <= BLUE;
            data_interface(10 downto 5) <= GREEN;
            data_interface(15 downto 11) <= RED;
            
            write_interface <= '1';
            state <= ST_SEND;

            when ST_SEND =>
            write_interface <= '0';
            read_green <= '0';
            read_red <= '0';
            -- Tell master unit a data is available
            new_data <= '1';
            state <= ST_DATA_CONTINUE;

            when ST_DATA_CONTINUE =>
            new_data <= '0';

            -- Line finished
            if Vsync = '1' and Hsync = '0' then
                old_hsync <= Hsync;
                state <= ST_WAIT_LINE_CHANGE_RG;

            -- Line still going
            elsif Vsync = '1' and Hsync = '1' then
                state <= ST_SAMPLE_GREEN2;

            -- Frame finished
            else state <= ST_END;
            end if;

            -- Wait for new line to start
            when ST_WAIT_LINE_CHANGE_RG =>
            if Hsync = '1' and old_hsync ='0' then
                state <= ST_SAMPLE_RED;
            else null;
            end if;
            old_hsync <= Hsync;

            when ST_END =>
            capture_done <= '1';
            state <= ST_IDLE;

            -- In case of unexpected state, send to ST_IDLE
            when others => state <= ST_IDLE;
        end case;
    end if;
end process;


end behav;