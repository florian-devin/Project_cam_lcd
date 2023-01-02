library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lcd_controller is

	port(
		clk : in std_logic;
		nReset : in std_logic;
		
		updateCmd : in std_logic;
        updateParam : in std_logic;
        regData : in std_logic_vector(15 downto 0);
        FifoEmpty : in std_logic;
        RdData : in std_logic_vector(15 downto 0);

		RdFifo : out std_logic;
        CSX : out std_logic;
        D_CX : out std_logic;
        WRX : out std_logic;
        RDX : out std_logic;
        D : out std_logic_vector(15 downto 0);
        seqDone : out std_logic
        );
		
end lcd_controller;

architecture RTL of lcd_controller is

	component framegen
		
        port(
            clk : in std_logic;
            nReset : in std_logic;
            dataSeq : in std_logic_vector(15 downto 0);
            framegenEnabled : in std_logic;
            D_CX_Seq : in std_logic;
            frame_finished : out std_logic;
            CSX : out std_logic;
            D_CX : out std_logic;
            WRX : out std_logic;
            RDX : out std_logic;
            D : out std_logic_vector(15 downto 0)
        );
		
	end component framegen;
	
	component sequencer
	
		port(
			clk : in std_logic;
			nReset : in std_logic;
			
			updateCmd : in std_logic;
            updateParam : in std_logic;
            regData : in std_logic_vector(15 downto 0);
            FifoEmpty : in std_logic;
            frame_finished : in std_logic;
            RdData : in std_logic_vector(15 downto 0);

            framegenEnabled : out std_logic;
            dataSeq : out std_logic_vector(15 downto 0);
            D_CX_Seq : out std_logic;
            RdFifo : out std_logic;
            seqDone : out std_logic
            );
		
	end component sequencer;
	
	signal framegenEnabled_i : std_logic;
    signal frame_finished_i : std_logic;
    signal dataSeq_i : std_logic_vector(15 downto 0);
    signal D_CX_Seq_i : std_logic;
	
begin

	U0 : framegen
		port map(
			clk => clk,
			nReset => nReset,
            dataSeq => dataSeq_i,
            framegenEnabled => framegenEnabled_i,
            D_CX_Seq => D_CX_Seq_i,
            frame_finished => frame_finished_i,
            CSX => CSX,
            D_CX => D_CX,
            WRX => WRX,
            RDX => RDX,
            D => D			
        );
			
	U1 : sequencer
		port map(
			clk => clk,
			nReset => nReset,
			framegenEnabled => framegenEnabled_i,
            dataSeq => dataSeq_i,
            D_CX_Seq => D_CX_Seq_i,
            frame_finished => frame_finished_i,
            updateCmd => updateCmd,
            updateParam => updateParam,
            regData => regData,
            FifoEmpty => FifoEmpty,
            RdData => RdData,
            RdFifo => RdFifo,
            seqDone => seqDone
        );
	
end RTL;
				