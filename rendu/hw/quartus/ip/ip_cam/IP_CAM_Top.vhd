library ieee;
use ieee.std_logic_1164.all;


entity IP_CAM_Top is 
    port (
        Clk             : in  std_logic;
        nReset          : in  std_logic;

        -- Camera interface
        Cam_Mclk        : out std_logic;
        Cam_Pixclk      : in  std_logic;
        Cam_Hsync       : in  std_logic;
        Cam_Vsync       : in  std_logic;
        Cam_data        : in  std_logic_vector(5 downto 0);
        CamReset_n      : out std_logic;

        -- Avalon Slave interface
        AS_Address      : in  std_logic_vector(2 downto 0);
        AS_Cs_n         : in  std_logic;
        AS_Write_n      : in  std_logic;
        AS_Datawr       : in  std_logic_vector(31 downto 0);
        AS_Read_n       : in  std_logic;
        AS_Datard       : out std_logic_vector(31 downto 0);

        -- Avalon Master interface
        AM_Address      : out std_logic_vector(31 downto 0);
        AM_byteEnable_n : out std_logic_vector(3 downto 0);
        AM_BurstCount   : out std_logic_vector(1 downto 0);
        AM_Write_n      : out std_logic;
        AM_Datawr       : out std_logic_vector(31 downto 0);
        AM_WaitRequest  : in  std_logic

    );
end entity IP_CAM_Top;

architecture rtl of IP_CAM_Top is

    -- internal signals 
    signal start_addr   : std_logic_vector(31 downto 0);
    signal length       : std_logic_vector(31 downto 0);

    signal capture_done : std_logic;
    signal acquisition  : std_logic;

    signal data         : std_logic_vector(31 downto 0);
    signal empty        : std_logic;
    --signal new_data     : std_logic;
    signal new_frame    : std_logic;
    signal ack          : std_logic;

-- COMPONENTS
-------------------------------------------------
component ip_cam_avslave is
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
        acquisition     : out std_logic
    );
end component;
-------------------------------------------------
component ip_cam_avmaster is
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
end component;
-------------------------------------------------
component IP_CAM_Frame is
    port(
        clk     :   in  std_logic;
        nReset  :   in  std_logic;

        -- External interface from CAMERA

        -- Only 6 bits are routed from the camera OUT
        CAM_data    :   in  std_logic_vector(5 downto 0);
        Hsync       :   in  std_logic;
        Vsync       :   in  std_logic;
        Mclk        :   out  std_logic;
        CAM_reset   :   out std_logic;
        pxl_clk     :   in  std_logic;

        -- IP_CAM_AVSlave interface
        capture_done:   out std_logic;
        acquisition :   in  std_logic;

        -- IP_CAM_AVMaster interface
        new_frame   :   out std_logic;
        ack         :   in  std_logic;
        empty_interface :   out   std_logic;

        -- Output FIFO
        output_interface    :   out   std_logic_vector (31 DOWNTO 0)

    );
end component;
-------------------------------------------------

begin
    mapping_IP_CAM_AVSlave : ip_cam_avslave
        port map(
            clk             => Clk,
            nReset          => nReset,
    
            -- Internal interface (i.e. Avalon slave).
            address         => AS_Address,
            write_n         => AS_Write_n,
            read_n          => AS_Read_n,
            writedata       => AS_Datawr,
            readdata        => AS_Datard,
    
            -- Internal interface (to master)
            start_addr      => start_addr,
            length          => length,
    
            -- Internal interface (to frame)
            capture_done    => capture_done,
            acquisition     => acquisition

        );

    mapping_IP_CAM_AVMaster : ip_cam_avmaster
        port map(
            clk             => Clk,
            nReset          => nReset,
    
            -- Internal interface (i.e. Avalon slave).
            address         => AM_Address,
            write_n         => AM_Write_n,
            byteEnable_n    => AM_byteEnable_n,
            burstCount      => AM_BurstCount,
            datawr          => AM_Datawr,
            waitRequest     => AM_WaitRequest,
    
    
            -- Internal interface (to slave)
            start_addr      => start_addr,
            length          => length,
    
            -- Internal interface (to frame)
            data            => data,
            fifo_empty      => empty,
            --new_data        => new_data,
            new_frame       => new_frame,
            ack             => ack
        );

    mapping_IP_CAM_Frame : IP_CAM_Frame
        port map(
            clk => Clk,
            nReset => nReset,

            -- Only 6 bits are routed from the camera DOUT
            CAM_data   => Cam_data,
            Hsync      => Cam_Hsync,
            Vsync      => Cam_Vsync,
            Mclk       => Cam_Mclk,
            CAM_reset  => CamReset_n,
            pxl_clk    => Cam_Pixclk,

            -- IP_CAM_AVSlave interface
            capture_done => capture_done,
            acquisition  => acquisition,

            -- IP_CAM_AVMaster interface
            --new_data    => new_data,
            new_frame   => new_frame,
            -- Send to FIFO data        :   out std_logic_vector(15 downto 0) := std_logic_vector(to_signed(0, 16)); 
            ack         => ack,
            output_interface => data,
            empty_interface => empty

        );

end architecture rtl;