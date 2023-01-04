library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity slave is

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
        memWritten : out std_logic;
        CAMaddress : out std_logic_vector(31 downto 0);
		updateCmd : out std_logic;
        updateParam : out std_logic;
        regData : out std_logic_vector(15 downto 0)
        );
		
end slave;

architecture RTL of slave is

	component slave_com
        port(
            clk 	: in std_logic;
            nReset	: in std_logic;
            address 	: in std_logic_vector(2 downto 0);
            write 		: in std_logic;
            read 		: in std_logic;
            writedata	: in std_logic_vector(31 downto 0);
            readdata 	: out std_logic_vector(31 downto 0);
            FIFO_full : in std_logic; 
            FIFO_almost_full : in std_logic;
            FIFO_empty : in std_logic;
            FIFO_almost_empty : in std_logic;
            dataFifo : out std_logic_vector(8 downto 0);
            wrreq : out std_logic;
            bufferLength : out std_logic_vector(31 downto 0);
            startAddress : out std_logic_vector(31 downto 0);
            memWritten : out std_logic;
            CAMaddress : out std_logic_vector(31 downto 0)
        );	
	end component slave_com;
	
	component config_update
		port(
            clk : in std_logic;
            nReset : in std_logic;
            seqDone : in std_logic;
            SlaveFifoEmpty : in std_logic;
            q : in std_logic_vector(8 downto 0);
            updateCmd : out std_logic;
            updateParam : out std_logic;
            regData : out std_logic_vector(15 downto 0);
            rdreq : out std_logic
            );
	end component config_update;

    component slave_fifo
        port(
            aclr		: IN STD_LOGIC ;
            clock		: IN STD_LOGIC ;
            data		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
            rdreq		: IN STD_LOGIC ;
            wrreq		: IN STD_LOGIC ;
            empty		: OUT STD_LOGIC ;
            q		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
        );
    end component slave_fifo;

	signal n_aclr : std_logic;
    signal dataFifo_i : std_logic_vector(8 downto 0);
    signal wrreq_i : std_logic;
    signal rdreq_i : std_logic;
    signal q_i : std_logic_vector(8 downto 0);
    signal slaveFifoEmpty_i : std_logic;
	
begin

	slave_com_inst : slave_com
		port map(
			clk => clk,
			nReset => nReset,
            address => address,
            write => write,
            read => read,
            writedata => writedata,
            readdata => readdata,
            FIFO_full => FIFO_full,
            FIFO_almost_full => FIFO_almost_full,
            FIFO_empty => FIFO_empty,
            FIFO_almost_empty => FIFO_almost_empty,
            dataFifo => dataFifo_i,
            wrreq => wrreq_i,
            bufferLength => bufferLength,
            startAddress => startAddress,
            memWritten => memWritten,
            CAMaddress => CAMaddress
        );
			
	config_update_inst : config_update
		port map(
			clk => clk,
			nReset => nReset,
            seqDone => seqDone,
            SlaveFifoEmpty => slaveFifoEmpty_i,
            q => q_i,
            updateCmd => updateCmd,
            updateParam => updateParam,
            regData => regData,
            rdreq => rdreq_i
        );


    slave_fifo_inst : slave_fifo 
        port map (
		aclr	 => n_aclr,
		clock	 => clk,
		data	 => dataFifo_i,
		rdreq	 => rdreq_i,
		wrreq	 => wrreq_i,
		empty	 => slaveFifoEmpty_i,
		q	 => q_i
	);

    process(nReset, clk)
    begin
        n_aclr <= NOT nReset;
    end process;
	
end RTL;
				