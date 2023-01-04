library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gFIFO_wrapper is

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
end gFIFO_wrapper;

architecture arch of gFIFO_wrapper is

	component gFIFO
	
        port(
            aclr		: IN STD_LOGIC ;
            clock		: IN STD_LOGIC ;
            data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
            rdreq		: IN STD_LOGIC ;
            wrreq		: IN STD_LOGIC ;
            almost_empty		: OUT STD_LOGIC ;
            almost_full		: OUT STD_LOGIC ;
            empty		: OUT STD_LOGIC ;
            full		: OUT STD_LOGIC ;
            q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
        ); 
		
	end component gFIFO;
	
	component Inverter
	
		Port ( 
            i : in std_logic;
            o : out std_logic 
        );
		
	end component Inverter;
	
	
    signal sig_nclk : std_logic;
    signal sig_aclr : std_logic;


	
begin

	U0_gFIFO : gFIFO
        port map(
            aclr	        => sig_aclr,
            clock           => sig_nclk,
            data	        => data,
            rdreq	        => rdreq,
            wrreq	        => wrreq,
            almost_empty    => almost_empty,
            almost_full	    => almost_full,
            empty		    => empty,
            full		    => full,
            q	            => q
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
				