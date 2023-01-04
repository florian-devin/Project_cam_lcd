library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mFIFO_wrapper is

	port(
		clk     : in std_logic;
		nReset  : in std_logic;

        data    : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		rdreq	: IN STD_LOGIC ;
		wrreq	: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		rdempty	: OUT STD_LOGIC 

    );
end mFIFO_wrapper;

architecture arch of mFIFO_wrapper is

	component mFIFO
	
        port(
            aclr	: IN STD_LOGIC;
            data	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            rdclk	: IN STD_LOGIC;
            rdreq	: IN STD_LOGIC;
            wrclk	: IN STD_LOGIC;
            wrreq	: IN STD_LOGIC;
            q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
            rdempty	: OUT STD_LOGIC
        ); 
		
	end component mFIFO;
	
	component Inverter
	
		Port ( 
            i : in std_logic;
            o : out std_logic 
        );
		
	end component Inverter;
	
	
    signal sig_nclk : std_logic;
    signal sig_aclr : std_logic;


	
begin

	U0_mFIFO : mFIFO
        port map(
            aclr	=> sig_aclr,
            data	=> data,
            rdclk	=> sig_nclk,
            rdreq	=> rdreq,
            wrclk	=> sig_nclk,
            wrreq	=> wrreq,
            q	    => q,
            rdempty	=> rdempty
        );
			
	U1_clk_inv : Inverter
		port map(
			i => clk,
            o => sig_nclk
        );
			
	U2_nReset_inv : Inverter
		port map(
			i => nReset,
            o => sig_aclr
        );
	
end arch;
				