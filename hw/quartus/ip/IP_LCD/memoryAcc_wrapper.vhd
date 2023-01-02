library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memoryAcc_wrapper is

	port(
		clk     : in std_logic;
		nReset  : in std_logic;

        -- Avalon Bus signals
        readdatavalid           : in std_logic;
        waitrequest             : in std_logic;
        readdata                : in std_logic_vector(31 downto 0);
        -- Slave signals
        globalFIFO_AlmostFull   : in std_logic;                                 -- global FIFO fill info
        startAddress            : in std_logic_vector(31 downto 0);             -- First address of the frame in memory
        bufferLength            : in std_logic_vector(31 downto 0);             -- Number of pixels to read in memory
        -- IP_CAM signal
        memWritten              : in std_logic;                                 -- Sync signal from IP_CAM
        -- LCD controller signal
        gFIFO_rdreq		        : IN STD_LOGIC ;

        -- To Avalon Bus
        read                : out std_logic;                                            -- Avalon Bus read 
        burstcount          : out std_logic_vector(3 downto 0);                         -- Avalon Bus burst count (nb of consecutive reads)
        address             : out std_logic_vector(31 downto 0);                        -- Avalon Bus address
        -- To IP_CAM
        memRed              : out std_logic;                                            -- Synchronization with IP_CAM, memory has been read completely by IP_LCD
        -- To LCD controller
        gFIFO_empty_LCD     : OUT STD_LOGIC ;
        gFIFO_q		        : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        -- To Slave
        gFIFO_almost_empty	: OUT STD_LOGIC ;
		gFIFO_almost_full	: OUT STD_LOGIC ;
		gFIFO_empty		    : OUT STD_LOGIC ;
		gFIFO_full		    : OUT STD_LOGIC
        
    );
end memoryAcc_wrapper;

architecture arch of memoryAcc_wrapper is

	component master_wrapper
        port(
            clk     : in std_logic;
            nReset  : in std_logic;

            -- Avalon Bus signals
            readdatavalid           : in std_logic;
            waitrequest             : in std_logic;
            readdata                : in std_logic_vector(31 downto 0);
            -- Slave signals
            globalFIFO_AlmostFull   : in std_logic;                                 -- global FIFO fill info
            startAddress            : in std_logic_vector(31 downto 0);             -- First address of the frame in memory
            bufferLength            : in std_logic_vector(31 downto 0);             -- Number of pixels to read in memory
            -- IP_CAM signal
            memWritten              : in std_logic;                                 -- Sync signal from IP_CAM
            -- gFIFO signals
            gFIFO_wrfull            : in std_logic;

            -- To Avalon Bus
            read        : out std_logic;                                            -- Avalon Bus read 
            burstcount  : out std_logic_vector(3 downto 0);                         -- Avalon Bus burst count (nb of consecutive reads)
            address     : out std_logic_vector(31 downto 0);                        -- Avalon Bus address
            -- To IP_CAM
            memRed      : out std_logic;                                            -- Synchronization with IP_CAM, memory has been read completely by IP_LCD
            -- To global FIFO
            gFIFO_wrreq : out std_logic;                                            -- Write request to global FIFO
            gFIFO_data  : out std_logic_vector(15 downto 0)                        -- Data to push in global FIFO
    );
		
	end component master_wrapper;
	

    component gFIFO_wrapper
        port(
            nReset		    : IN STD_LOGIC ;
            clk		        : IN STD_LOGIC ;
            data		    : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
            rdreq		    : IN STD_LOGIC ;
            wrreq		    : IN STD_LOGIC ;
            almost_empty	: OUT STD_LOGIC ;
            almost_full		: OUT STD_LOGIC ;
            empty		    : OUT STD_LOGIC ;
            full		    : OUT STD_LOGIC ;
            q		        : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)

    );

    end component gFIFO_wrapper;
	
    -- Internal signals
    signal i_gFIFO_full         : STD_LOGIC := '0';
    signal i_gFIFO_almost_full  : STD_LOGIC := '0';
    signal i_gFIFO_wrreq        : STD_LOGIC := '0';
    signal i_gFIFO_data         : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal i_gFIFO_empty        : STD_LOGIC := '0';

begin

	U0_master_wrapper : master_wrapper
        generic map(
            DefaultBurstLength  => x"4"
        )

        port map(
            clk 	=> clk,
            nReset 	=> nReset,

            readdatavalid           => readdatavalid,           
            waitrequest             => waitrequest,             
            readdata                => readdata,                
            globalFIFO_AlmostFull   => i_gFIFO_almost_full,   
            startAddress            => startAddress,            
            bufferLength            => bufferLength,            
            memWritten              => memWritten,              
            gFIFO_wrfull            => i_gFIFO_full,            
            read                    => read,                    
            burstcount              => burstcount,              
            address                 => address,                 
            memRed                  => memRed,                  
            gFIFO_wrreq             => i_gFIFO_wrreq,             
            gFIFO_data              => i_gFIFO_data      
        );

    U1_gFIFO_wrapper : gFIFO_wrapper
        port map(
            nReset		    => nReset,		    
            clk		        => clk,		        
            data		    => i_gFIFO_data,		    
            rdreq		    => gFIFO_rdreq,		    
            wrreq		    => i_gFIFO_wrreq,		    
            almost_empty	=> gFIFO_almost_empty,	
            almost_full		=> i_gFIFO_almost_full,		
            empty		    => i_gFIFO_empty,		    
            full		    => i_gFIFO_full,		    
            q		        => gFIFO_q		        
        );

        gFIFO_almost_full	<= i_gFIFO_almost_full;		
        gFIFO_empty		    <= i_gFIFO_empty;
        gFIFO_empty_LCD		<= i_gFIFO_empty;    
        gFIFO_full		    <= i_gFIFO_full;





end arch;
				