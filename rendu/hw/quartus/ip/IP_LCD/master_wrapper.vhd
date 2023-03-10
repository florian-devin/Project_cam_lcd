library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity master_wrapper is

	port(
		clk     : in std_logic;
		nReset  : in std_logic;

        -- Avalon Bus signals
        readdatavalid           : in std_logic;
        waitrequest             : in std_logic;
        readdata                : in std_logic_vector(31 downto 0);
        -- Slave signals
        globalFIFO_AlmostFull   : in std_logic;                                 -- global FIFO fill info
        CAMaddress            : in std_logic_vector(31 downto 0);             -- First address of the frame in memory
        startAddress            : in std_logic_vector(31 downto 0);             -- First address of the frame in memory
        bufferLength            : in std_logic_vector(31 downto 0);             -- Number of pixels to read in memory
        -- IP_CAM signal
        memWritten              : in std_logic;                                 -- Sync signal from IP_CAM
        -- gFIFO signals
        gFIFO_wrfull            : in std_logic;

        -- To Avalon Bus
        read        : out std_logic;                                            -- Avalon Bus read 
        write       : out std_logic;
        burstcount  : out std_logic_vector(3 downto 0);                         -- Avalon Bus burst count (nb of consecutive reads)
        address     : out std_logic_vector(31 downto 0);                        -- Avalon Bus address
        writedata   : out std_logic_vector(31 downto 0);
        -- To global FIFO
        gFIFO_wrreq : out std_logic;                                            -- Write request to global FIFO
        gFIFO_data  : out std_logic_vector(15 downto 0)                        -- Data to push in global FIFO
    );
end master_wrapper;

architecture arch of master_wrapper is

	component ReadMemCtrl
        generic(
            DefaultBurstLength : unsigned(3 downto 0) := x"4"           -- max 15 or else change burstcount width                             -- Constant: default length of burst read
        );
        port(
            clk : in std_logic;                                                     
            nReset : in std_logic;

            --Inputs
            waitrequest             : in std_logic;                                 -- Avalon Bus waitrequest
            masterFIFO_empty        : in std_logic;                                 -- master FIFO fill info   
            globalFIFO_AlmostFull   : in std_logic;                                 -- global FIFO fill info
            CAMaddress              : in std_logic_vector(31 downto 0);
            startAddress            : in std_logic_vector(31 downto 0);             -- First address of the frame in memory
            bufferLength            : in std_logic_vector(31 downto 0);             -- Number of pixels to read in memory
            memWritten              : in std_logic;                                 -- Sync signal from IP_CAM
            pixCounter              : in std_logic_vector(31 downto 0);              -- Nb of pixel read since last start of frame
            BurstCounter            : in std_logic_vector(3 downto 0);

            --Outputs
            read            : out std_logic;                                        -- Avalon Bus read 
            write           : out std_logic;
            im_read         : out std_logic;   
            burstcount      : out std_logic_vector(3 downto 0);                     -- Avalon Bus burst count (nb of consecutive reads)
            im_burstcount   : out std_logic_vector(3 downto 0);                                        
            address         : out std_logic_vector(31 downto 0);                    -- Avalon Bus address                                     -- Synchronization with IP_CAM, memory has been read completely by IP_LCD
            writedata       : out std_logic_vector(31 downto 0);
            nPixToCount     : out std_logic_vector(7 downto 0);                     -- Nb of pixel to read in the current burstread           
            clrPixCounter   : out std_logic;                                        -- Pixel counter reset signal
            clrBurstCounter : out std_logic                                         -- Burst counter reset signal
        );
		
	end component ReadMemCtrl;
	
	component RdWrSeq
	
        port(
            clk : in std_logic;                                                     
            nReset : in std_logic;

            --Inputs
            AM_read         : in std_logic;                                         -- Avalon Master read request
            burstcount      : in std_logic_vector(3 downto 0);                      -- Avalon Bus burst count for this burst read(nb of consecutive reads)
            BurstCounter    : in std_logic_vector(3 downto 0);                      -- Avalon Bus bursts counted in the current burstread 
            nPixToCount     : in std_logic_vector(7 downto 0);                      -- Nb of pixel to read in the current burstread
            mFIFO_q         : in std_logic_vector(15 downto 0);                     -- Output of the master FIFO
            mFIFO_rdempty   : in std_logic;                                         -- read empty status from master FIFO
            gFIFO_wrfull    : in std_logic;                                         -- write full status from global FIFO

            --Outputs
            gFIFO_wrreq : out std_logic;                                            -- Write request to global FIFO
            gFIFO_data  : out std_logic_vector(15 downto 0);                        -- Data to push in global FIFO
            mFIFO_rdreq : out std_logic                                             -- Read request to master FIFO
        );
		
	end component RdWrSeq;
	
	component Counter
	
        generic(
            cnt_width : integer := 4
        );

        Port ( 
            nReset  : in std_logic;
            trigger1 : in std_logic;
            trigger2 : in std_logic;
            clr     : in std_logic;
            cnt     : out std_logic_vector(cnt_width-1 downto 0)
        );
		
	end component Counter;

    component mFIFO_wrapper
        port(
            clk     : in std_logic;
            nReset  : in std_logic;

            data    : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            rdreq	: IN STD_LOGIC ;
            wrreq	: IN STD_LOGIC ;
            q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
            rdempty	: OUT STD_LOGIC 

        );

    end component mFIFO_wrapper;

    component data_rotation
        port(
            clk     : in std_logic;
            nReset  : in std_logic;
            readdatavalid_in : IN STD_LOGIC;
            readdatavalid_out: OUT STD_LOGIC;
            readdata_in : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            readdata_out: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
        );
    end component data_rotation;

    component Inverter
	
		Port ( 
            i : in std_logic;
            o : out std_logic 
        );
		
	end component Inverter;
	
    -- Internal signals
            
    signal isig_pixCounter          : std_logic_vector(31 downto 0);              -- Nb of pixel read since last start of frame                
    signal isig_nPixToCount         : std_logic_vector(7 downto 0);                     -- Nb of pixel to read in the current burstread           
    signal isig_clrPixCounter       : std_logic;
    signal isig_BurstCounter        : std_logic_vector(3 downto 0);
    signal isig_clrBurstCounter     : std_logic;
    signal isig_mFIFO_q             : std_logic_vector(15 downto 0);                     -- Output of the master FIFO
    signal isig_mFIFO_rdempty       : std_logic;
    signal isig_mFIFO_rdreq         : std_logic;

    signal isig_read                : std_logic;
    signal isig_burstcount          : std_logic_vector(3 downto 0);
    signal isig_readdata           : std_logic_vector(31 downto 0);
    signal isig_readdatavalid      : std_logic;

    signal sig_nclk : std_logic;


begin

	U0_ReadMemCtrl : ReadMemCtrl
        generic map(
            DefaultBurstLength  => x"4"
        )

        port map(
            clk 	=> clk,
            nReset 	=> nReset,

            waitrequest           => waitrequest,          
            MasterFIFO_empty      => isig_mFIFO_rdempty ,     
            globalFIFO_AlmostFull => globalFIFO_AlmostFull,
            CAMaddress            => CAMaddress,
            startAddress          => startAddress,         
            bufferLength          => bufferLength,         
            memWritten            => memWritten,           
            pixCounter            => isig_pixCounter, 
            BurstCounter          => isig_BurstCounter,             
            read                  => read,                 
            im_read               => isig_read,
            write                 => write,
            burstcount            => burstcount,
            im_burstcount         => isig_burstcount,           
            address               => address,                            
            writedata			  => writedata,
            nPixToCount           => isig_nPixToCount,          
            clrPixCounter         => isig_clrPixCounter,        
            clrBurstCounter       => isig_clrBurstCounter      
        );

    U1_RdWrSeq : RdWrSeq
        port map(
            clk 	=> clk,
            nReset 	=> nReset,

            AM_read       => isig_read,        
            burstcount    => isig_burstcount,     
            BurstCounter  => isig_BurstCounter,   
            nPixToCount   => isig_nPixToCount,    
            mFIFO_q       => isig_mFIFO_q,        
            mFIFO_rdempty => isig_mFIFO_rdempty,  
            gFIFO_wrfull  => gFIFO_wrfull,   

            gFIFO_wrreq => gFIFO_wrreq, 
            gFIFO_data  => gFIFO_data, 
            mFIFO_rdreq => isig_mFIFO_rdreq 
           
        );
    
    U2_mFIFO_wrapper : mFIFO_wrapper
        port map(
            clk     => clk,
            nReset  => nReset,
            data    => isig_readdata,
            rdreq   => isig_mFIFO_rdreq,
            wrreq   => isig_readdatavalid,
            q		=> isig_mFIFO_q,
            rdempty	=> isig_mFIFO_rdempty
            
        );
    
    U3_cntPix : Counter
        generic map(
            cnt_width => 32
        )
        port map(
            nReset      => nReset,
            trigger1    => isig_mFIFO_rdreq,
            trigger2    => '1',
            clr         => isig_clrPixCounter,
            cnt         => isig_pixCounter    
        );

    U4_cntBurst : Counter
        generic map(
            cnt_width => 4
        )
        port map(
            nReset      => nReset,
            trigger1    => isig_readdatavalid,
            trigger2    => sig_nclk,
            clr         => isig_clrBurstCounter,
            cnt         => isig_BurstCounter    
        );

    U5_data_rotation : data_rotation
        port map(
            clk     => clk,
            nReset  => nReset,
            readdatavalid_in => readdatavalid,
            readdatavalid_out => isig_readdatavalid,
            readdata_in => readdata,
            readdata_out => isig_readdata
        );

    U6_clk_inv : Inverter
    port map(
        i => clk,
        o => sig_nclk
    );

end arch;
				