library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sequencer is
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
end sequencer;

architecture RTL of sequencer is

	type states is (idle, sendData, tempoData, waitFramegen);
	signal current_state: states;
	attribute enum_encoding: string;
	attribute enum_encoding of states: type is "gray";

	signal framegenEnabled_i : std_logic := '0';
    signal dataSeq_i : std_logic_vector(15 downto 0) := (others => '0');
    signal D_CX_Seq_i : std_logic := '0';
    signal RdFifo_i : std_logic := '0';
    signal seqDone_i : std_logic := '0';
begin


	process(clk, nReset, current_state)
	begin
    		if nReset = '0' then
                framegenEnabled_i <= '0';
                dataSeq_i <= (others => '0');
                D_CX_Seq_i <= '0';
                RdFifo_i <= '0';
                seqDone_i <= '0';
        		current_state <= idle;
				
    		elsif rising_edge(clk) then

				case current_state is
		
				when idle =>
                    framegenEnabled_i <= '0';
                    RdFifo_i <= '0';
                    seqDone_i <= '0';
                    if updateCmd = '1' then
                        dataSeq_i <= regData;
                        framegenEnabled_i <= '1';
                        D_CX_Seq_i <= '0';
                        current_state <= waitFramegen;
                    elsif updateParam = '1' then
                        dataSeq_i <= regData;
                        framegenEnabled_i <= '1';
                        D_CX_Seq_i <= '1';
                        current_state <= waitFramegen;
                    elsif FifoEmpty = '0' then
                        RdFifo_i <= '1';
                        current_state <= sendData;
                    end if;

                when sendData =>
                    RdFifo_i <= '0';
                    dataSeq_i <= RdData;
                    framegenEnabled_i <= '1';
                    D_CX_Seq_i <= '1';
                    current_state <= tempoData;

                when tempoData =>
                    current_state <= waitFramegen;

                when waitFramegen =>
                    framegenEnabled_i <= '0';
                    if frame_finished = '1' then
                        if updateCmd = '1' OR updateParam = '1' then
                            seqDone_i <= '1';
                        end if;
                        current_state <= idle;
                    end if;             
        
                when others =>
                    current_state <= idle;
                end case;

    		end if;
	end process;

    framegenEnabled <= framegenEnabled_i;
    dataSeq <= dataSeq_i;
    D_CX_Seq <= D_CX_Seq_i;
    RdFifo <= RdFifo_i;
    seqDone <= seqDone_i;

end RTL;

