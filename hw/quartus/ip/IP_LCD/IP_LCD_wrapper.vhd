library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IP_LCD_wrapper is

	port(
		clk : in std_logic;
		nReset : in std_logic;

        -- Avalon Slave
   		addressSlave 	: in std_logic_vector(2 downto 0);
		write 		: in std_logic;
		readSlave 		: in std_logic;
		writedata	: in std_logic_vector(31 downto 0);
		readdataSlave 	: out std_logic_vector(31 downto 0);

        -- Avalon Master
        memWritten : in std_logic;
        memRed : out std_logic;
        addressMaster : out std_logic_vector(31 downto 0);
        burstcount : out std_logic_vector(3 downto 0);
        readMaster : out std_logic;
        waitrequest : in std_logic;
        readdatavalid : in std_logic;
        readdataMaster : in std_logic_vector(31 downto 0);

        -- LCD PINS
        CSX : out std_logic;
        D_CX : out std_logic;
        RDX : out std_logic;
        WRX : out std_logic;
        D : out std_logic_vector(15 downto 0)
        );
		
end IP_LCD_wrapper;

architecture RTL of IP_LCD_wrapper is

	component memoryAcc_wrapper
        port(
            clk 	: in std_logic;
            nReset	: in std_logic;
            -- Avalon Bus signals
            readdatavalid           : in std_logic;
            waitrequest             : in std_logic;
            readdata                : in std_logic_vector(31 downto 0);
            -- Slave signals
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
	end component memoryAcc_wrapper;
	
	component lcd_controller
		port(
            clk : in std_logic;
            nReset : in std_logic;
            updateCmd : in std_logic;
            updateParam : in std_logic;
            regData : in std_logic_vector(15 downto 0);
            FifoEmpty : in std_logic;
            RdData : in std_logic_vector(15 downto 0);
            seqDone : out std_logic;

            RdFifo : out std_logic;
            CSX : out std_logic;
            D_CX : out std_logic;
            WRX : out std_logic;
            RDX : out std_logic;
            D : out std_logic_vector(15 downto 0)
        );
	end component lcd_controller;

    component slave
        port(
            clk : in std_logic;
            nReset : in std_logic;

            -- Avalon
            address 	: in std_logic_vector(2 downto 0);
            write 		: in std_logic;
            read 		: in std_logic;
            writedata	: in std_logic_vector(31 downto 0);
            readdata 	: out std_logic_vector(31 downto 0);

            -- Module
            FIFO_full : in std_logic; 
            FIFO_almost_full : in std_logic;
            FIFO_empty : in std_logic;
            FIFO_almost_empty : in std_logic;
            seqDone : in std_logic;

            bufferLength : out std_logic_vector(31 downto 0);
            startAddress : out std_logic_vector(31 downto 0);
            updateCmd : out std_logic;
            updateParam : out std_logic;
            regData : out std_logic_vector(15 downto 0)
        );
    end component slave;

    -- Internal signals
    signal RdData_i : std_logic_vector(15 downto 0);
    signal RdFifo_i : std_logic;
    signal gFIFO_almost_empty_i : STD_LOGIC ;
	signal gFIFO_almost_full_i : STD_LOGIC ;
	signal gFIFO_empty_i : STD_LOGIC ;
    signal gFIFO_empty_LCD_i : STD_LOGIC ;
	signal gFIFO_full_i : std_logic;
    signal updateCmd_i : std_logic;
    signal updateParam_i : std_logic;
    signal regData_i : std_logic_vector(15 downto 0);
    signal seqDone_i : std_logic;
    signal startAddress_i : std_logic_vector(31 downto 0);
    signal bufferLength_i : std_logic_vector(31 downto 0);
	
begin

	memoryAcc_inst : memoryAcc_wrapper
		port map(
            clk     => clk,
            nReset  => nReset,

            readdatavalid           => readdatavalid,           
            waitrequest             => waitrequest,             
            readdata                => readdataMaster,                
            startAddress            => startAddress_i,            
            bufferLength            => bufferLength_i,            
            memWritten              => memWritten,              
            gFIFO_rdreq		        => RdFifo_i,		        
            read                    => readMaster,                    
            burstcount              => burstcount,              
            address                 => addressMaster,                 
            memRed                  => memRed,                  
            gFIFO_empty_LCD         => gFIFO_empty_LCD_i,         
            gFIFO_q		            => RdData_i ,		            
            gFIFO_almost_empty	    => gFIFO_almost_empty_i,	    
            gFIFO_almost_full	    => gFIFO_almost_full_i,	    
            gFIFO_empty		        => gFIFO_empty_i,		        
            gFIFO_full		        => gFIFO_full_i		        
        );
			
	lcd_ctrl_inst : lcd_controller
		port map(
            clk => clk,
            nReset => nReset,
            updateCmd => updateCmd_i,
            updateParam => updateParam_i,
            regData => regData_i,
            FifoEmpty => gFIFO_empty_LCD_i,
            RdData => RdData_i,
            RdFifo => RdFifo_i,
            CSX => CSX,
            D_CX => D_CX,
            WRX => WRX,
            RDX => RDX,
            D => D,
            seqDone => seqDone_i
        );


    slave_inst : slave 
        port map (
            clk => clk,
            nReset => nReset,
            address => addressSlave,
            write => write,
            read => readSlave,
            writedata => writedata,
            readdata => readdataSlave,
            FIFO_full => gFIFO_full_i,
            FIFO_almost_full => gFIFO_almost_full_i,
            FIFO_empty => gFIFO_empty_i,
            FIFO_almost_empty => gFIFO_almost_empty_i,
            seqDone => seqDone_i,
            bufferLength => bufferLength_i,
            startAddress => startAddress_i,
            updateCmd => updateCmd_i,
            updateParam => updateParam_i,
            regData => regData_i
	    );
	
end RTL;
				