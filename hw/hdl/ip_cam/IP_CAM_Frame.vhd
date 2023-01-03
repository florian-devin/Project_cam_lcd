library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IP_CAM_Frame is
    port(
        clk     :   in  std_logic;
        nReset  :   in  std_logic;

        -- External interface from CAMERA

        -- Only 6 bits are routed from the camera OUT
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
        new_frame   :   out std_logic := '0';
        ack         :   in  std_logic;
        empty_interface :   out   std_logic;

        -- Output FIFO
        output_interface    :   out   std_logic_vector (31 DOWNTO 0)

    );
end IP_CAM_Frame;

architecture  behav of IP_CAM_Frame is
    
    -- Flags and buffers
    signal PXL_CLK_old: std_logic := '0';
    signal old_vsync  : std_logic := '0';
    signal old_hsync  : std_logic := '0';
    signal first_red: std_logic := '0';
    signal first_green2: std_logic := '0';

    -- Buffer for GREEN2 and BLUE
    signal GREEN       :   std_logic_vector(5 downto 0);
    signal BLUE     :   std_logic_vector(4 downto 0);
    signal RED      :   std_logic_vector(4 downto 0);

    -- FIFO related internal signals
    signal data_red    :  std_logic_vector (4 DOWNTO 0);
    signal data_green  :  std_logic_vector (5 DOWNTO 0);
    signal data_interface  :  std_logic_vector (31 DOWNTO 0) := std_logic_vector(to_signed(0, 32));

    signal read_red    :   std_logic;
    signal read_green  :   std_logic;
    signal read_interface  :   std_logic;

    signal write_red   :   std_logic;
    signal write_green :   std_logic;
    signal write_interface :   std_logic;

    signal output_red  :   std_logic_vector (4 DOWNTO 0);
    signal output_green    :   std_logic_vector (5 DOWNTO 0);

    -- Declare state names
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
        q => output_red
    );

    FIFO_GREEN1 : entity work.FIFO_GREEN1
    port map(
        clock => clk,
        data => data_green,
        rdreq => read_green,
        wrreq => write_green,
        q => output_green
    );

    FIFO_interface : entity work.FIFO_interface
    port map(
        clock => clk,
        data => data_interface,
        rdreq => ack,
        wrreq => write_interface,
        empty => empty_interface,
        q => output_interface
    );

process(clk)
begin
    -- Send clock to camera, will return pxl_clk which uses PLL on Mclk
    Mclk <= clk;
end process;

process(clk, nReset)
variable GREEN2   :   integer := 0;
variable GREEN1   :   integer := 0;
variable pixel_count    :   integer :=0;
begin
    -- Reset all signals
    if nReset = '0' then

        -- FIFO red
        data_red <= std_logic_vector(to_signed(0, 5));
        read_red <= '0';
        write_red <= '0';

        -- FIFO green
        data_green <= std_logic_vector(to_signed(0, 6));
        read_green <= '0';
        write_green <= '0';

        -- FIFO interface
        data_interface <= std_logic_vector(to_signed(0, 32));
        write_interface <= '0';

        -- CAMERA
        CAM_reset <= '0';

        -- SLAVE signals
        capture_done <= '0';

        -- MASTER signals
        new_frame <= '0';
        
        state <= ST_IDLE;
        GREEN2 := 0;
        GREEN1 := 0;
        pixel_count := 0;
    
-- STATE MACHINE
    elsif rising_edge(clk) then
        case state is
--------------------------------------------------------------
-- Wait for acquisition start signal
            when ST_IDLE =>

            -- Deactivate signals from previous cycle
            CAM_reset <= '1';
            capture_done <= '0';

            -- Check if acquisition has started
            if acquisition = '1' then
                old_vsync <= Vsync;
                state <= ST_WAIT_VSYNC;
            else null;
            end if;
--------------------------------------------------------------
-- Wait for Vsync
            when ST_WAIT_VSYNC =>
            old_hsync <= Hsync;
            if Vsync = '1' and old_vsync = '0' then
                new_frame <= '1';
                state <= ST_WAIT_HSYNC;
            else null;
            end if;
            old_vsync <= Vsync;

--------------------------------------------------------------
-- Wait for Hsync
            when ST_WAIT_HSYNC =>

            -- Deactivate signals from previous cycle
            new_frame <= '0';

            -- Check if data is pixel data
            if Hsync = '1' and old_hsync = '0' then
                PXL_CLK_old <= pxl_clk;
                state <= ST_SAMPLE_RED;
            else null;
            end if;
            old_hsync <= Hsync;

            -- Flag for first red pixel read
            first_red <= '1';


--------------------------------------------------------------
-- Data sent is RED pixel
            when ST_SAMPLE_RED =>
            first_red <= '0';
            write_green <= '0';
            -- Check if the line has changed
            if Hsync = '0' then
                old_hsync <= Hsync;
                state <= ST_WAIT_LINE_CHANGE_GB;

            -- Else register the data on PXL_CLK rising edge (or first pixel)
            else
                if (PXL_CLK_old = '0' and pxl_clk = '1') or (first_red = '1') then
                    -- Put data in RED_FIFO (5 bits only, need to truncate)
                    data_red <= CAM_data(5 downto 1); -- Data available on port
                    write_red <= '1'; -- Data sent to FIFO
                    state <= ST_SAMPLE_GREEN1;
                else null;
                end if;
            end if;
            -- Wait for PXL_CLK to be rising edge

            PXL_CLK_old <= pxl_clk;
--------------------------------------------------------------
-- Data sent is GREEN1 pixel
            when ST_SAMPLE_GREEN1 =>
            write_red <= '0';
            if PXL_CLK_old = '0' and pxl_clk = '1' then
                data_green <= CAM_data;
                write_green <= '1';
                state <= ST_SAMPLE_RED;

            else null;
            end if;
            PXL_CLK_old <= pxl_clk;
--------------------------------------------------------------
-- Wait for new line to start with GREEN2 and BLUE pixels
            when ST_WAIT_LINE_CHANGE_GB =>

            -- Reset FIFO input just in case
            data_red <= std_logic_vector(to_signed(0, 5));
            data_green <= std_logic_vector(to_signed(0, 6));

            if Hsync = '1' and old_hsync ='0' then
                state <= ST_SAMPLE_GREEN2;
                first_green2 <= '1';
            else null;
            end if;
            old_hsync <= Hsync;
            PXL_CLK_old <= pxl_clk;
--------------------------------------------------------------
-- Data sent is GREEN2 pixel
            when ST_SAMPLE_GREEN2 =>
            read_green <= '0';
            read_red <= '0';
            write_interface <= '0';

            -- Check if the line has changed
            if Hsync = '0' and Vsync = '1' then
                old_hsync <= Hsync;
                state <= ST_WAIT_LINE_CHANGE_RG;

            -- or if the frame has ended
            elsif Vsync = '0' then
                state <= ST_END;
            
            -- Else acquire the GREEN2 pixel sent
            else 
                if (PXL_CLK_old = '0' and pxl_clk = '1') or first_green2 = '1' then
                    first_green2 <= '0';

                    -- Save data in buffer
                    GREEN2 := to_integer(signed(CAM_data));
                    state <= ST_SAMPLE_BLUE;
                else null;
                end if;
            end if;

            PXL_CLK_old <= pxl_clk;
--------------------------------------------------------------
-- Data sent is BLUE pixel
            when ST_SAMPLE_BLUE =>

            -- Rising edge of PXL_CLK
            if PXL_CLK_old = '0' and pxl_clk = '1' then
                -- Store BLUE pixel value in buffer for conversion
                BLUE <= CAM_data(5 downto 1);
                GREEN1  :=  to_integer(signed(output_green));
                -- RED     <=  output_red;
                GREEN1 := (GREEN1 + GREEN2) / 2;
                GREEN <= std_logic_vector(to_signed(GREEN1, 6));
                state <= ST_SEND;
            else null;
            end if;
            PXL_CLK_old <= pxl_clk;
--------------------------------------------------------------
-- Conversion into proper 16-bit format
            when ST_SEND =>
            if pixel_count = 0 then
                data_interface(4 downto 0) <= BLUE;
                data_interface(10 downto 5) <= GREEN;
                data_interface(15 downto 11) <= output_red;
                pixel_count := 1;
            else
                data_interface(20 downto 16) <= BLUE;
                data_interface(26 downto 21) <= GREEN;
                data_interface(31 downto 27) <= output_red;
                pixel_count := 0;
                write_interface <= '1';
            end if;
            read_green <= '1';
            read_red <= '1';
            PXL_CLK_old <= pxl_clk;
            state <= ST_SAMPLE_GREEN2;
--------------------------------------------------------------
-- Wait for new line to start with RED and GREEN1 pixels
            when ST_WAIT_LINE_CHANGE_RG =>
            if Hsync = '1' and old_hsync ='0' then
                state <= ST_SAMPLE_RED;
                first_red <= '1';
            else null;
            end if;
            old_hsync <= Hsync;
--------------------------------------------------------------
-- end of the frame
            when ST_END =>
            capture_done <= '1';
            state <= ST_IDLE;
--------------------------------------------------------------
-- In case of unexpected state, send to ST_IDLE
            when others => state <= ST_IDLE;
        end case;
--------------------------------------------------------------
    end if;
end process;


end behav;