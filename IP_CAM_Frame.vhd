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
        Mclk        :   in  std_logic;
        CAM_reset   :   out std_logic;

        -- IP_CAM_AVSlave interface
        capture_done:   out std_logic;
        acquisition :   in  std_logic;

        -- IP_CAM_AVMaster
        new_data    :   out std_logic;
        new_frame   :   out std_logic;
        data        :   out std_logic_vector(15 downto 0) := std_logic_vector(to_signed(0, 16));
        ack         :   in  std_logic
    );
end IP_CAM_Frame;

architecture  behav of IP_CAM_Frame is

    -- Buffer for GREEN2 and BLUE
    signal GREEN2   :   std_logic_vector(5 downto 0);
    signal BLUE   :   std_logic_vector(5 downto 0);
    

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
                        ST_END);
    signal state   : STATE_TYPE;
begin 
    process(clk, nReset)
    begin
        -- Reset send to ST_IDLE state
        if nReset='0' then
            state <= ST_IDLE;

        elsif rising_edge(clk) then
            case state is

                -- Wait for acquisition to start
                when ST_IDLE =>
                capture_done = '0';
                if acquisition = '1' then
                    state <= ST_WAIT_VSYNC;
                else null;
                end if;

                -- Wait for Vsync (FRAME_VALID)
                when ST_WAIT_VSYNC =>
                if Vsync = '1' then
                    -- Tell master unit a new frame is being read
                    new_frame <= '1';
                    state <= ST_WAIT_HSYNC;
                else null;
                end if;

                -- Wait for Hsync (LINE_VALID)
                when ST_WAIT_HSYNC =>
                if Hsync = '1' then
                    state <= ST_SAMPLE_RED;
                else null;
                end if;

                -- Data read is RED pixel
                when ST_SAMPLE_RED =>
                -- Checks if new line
                if Hsync = '0' then
                    state <= ST_WAIT_LINE_CHANGE_GB;
                else            
                    -- Put data in RED_FIFO (5 bits only, need to truncate)
                    -- code here
                    state <= ST_SAMPLE_GREEN1;
                end if;

                -- Data read is GREEN1 pixel
                when ST_SAMPLE_GREEN1 =>
                -- Checks if new line
                if Hsync = '0' then
                    state <= ST_WAIT_LINE_CHANGE_GB;
                else            
                    -- Put data in GREEN_FIFO (6 bits)
                    -- code here
                    state <= ST_SAMPLE_RED;
                end if;

                -- Wait for new line to start
                when ST_WAIT_LINE_CHANGE_GB =>
                if Hsync = '1' then
                    state <= ST_SAMPLE_GREEN2;
                else null;
                end if;

                -- Data read is GREEN2 pixel
                when ST_SAMPLE_GREEN2 =>
                -- Checks if new line
                if Hsync = '0' then
                    state <= ST_WAIT_LINE_CHANGE_RG;
                else            
                    -- Store data
                    GREEN2 <= CAM_data;
                    state <= ST_SAMPLE_BLUE;
                end if;

                -- Data is blue, need to convert the whole pixel into 16 bits
                when ST_SAMPLE_BLUE =>
                -- Store truncated data to 5 MSB and go to ST_CONVERT
                BLUE <= CAM_data(5 downto 1);
                state <= ST_CONVERT;

                -- Convert R G1 G2 & B data into 16-bits value
                when ST_CONVERT =>
                GREEN2 <= (GREEN2 + CAM_data) / 2;
                data(4 downto 0) <= -- FIFO_BLUE_POP;
                data(10 downto 5) <= GREEN2;
                data(15 downto 11) <= -- FIFO_RED_POP;
                state <= ST_SEND;

                when ST_SEND =>
                -- Tell master unit a data is sent
                new_data = '1';

                -- Wait for data to be received to go next data
                if ack = '1' then
                    new_data = '0';
                else null;
                end if;

                -- Line finished
                if Vsync = '1' and Hsync = '0' then
                    state <= ST_WAIT_LINE_CHANGE_RG;

                -- Line still going
                elsif Vsync = '1' and Hsync = '1' then
                    state <= ST_SAMPLE_GREEN2;

                -- Frame finished
                else state <= ST_END;
                end if;

                -- Wait for new line to start
                when ST_WAIT_LINE_CHANGE_RG =>
                if Hsync = '1' then
                    state <= ST_SAMPLE_RED;
                else null;
                end if;

                when ST_END =>
                capture_done = '1';
                state <= ST_IDLE;

                -- In case of unexpected state, send to ST_IDLE
                when others => state <= ST_IDLE;
            end case;
        end if;
    end process;

end behav;



ENTITY state_machine IS
   PORT(
      clk      : IN   STD_LOGIC;
      input    : IN   STD_LOGIC;
      reset    : IN   STD_LOGIC;
      output   : OUT  STD_LOGIC_VECTOR(1 downto 0));
END state_machine;
ARCHITECTURE a OF state_machine IS
   TYPE STATE_TYPE IS (s0, s1, s2);
   SIGNAL state   : STATE_TYPE;
BEGIN
   PROCESS (clk, reset)
   BEGIN
      IF reset = '1' THEN
         state <= s0;
      ELSIF (clk'EVENT AND clk = '1') THEN
         CASE state IS
            WHEN s0=>
               IF input = '1' THEN
                  state <= s1;
               ELSE
                  state <= s0;
               END IF;
            WHEN s1=>
               IF input = '1' THEN
                  state <= s2;
               ELSE
                  state <= s1;
               END IF;
            WHEN s2=>
               IF input = '1' THEN
                  state <= s0;
               ELSE
                  state <= s2;
               END IF;
         END CASE;
      END IF;
   END PROCESS;
   
   PROCESS (state)
   BEGIN
      CASE state IS
         WHEN s0 =>
            output <= "00";
         WHEN s1 =>
            output <= "01";
         WHEN s2 =>
            output <= "10";
      END CASE;
   END PROCESS;
   
END a;