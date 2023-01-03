    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;


entity data_rotation is
    port(
		clk : in std_logic;                                                     
		nReset : in std_logic;
        readdatavalid_in : in std_logic;
        readdatavalid_out : out std_logic;
		readdata_in : in std_logic_vector(31 downto 0);
        readdata_out : out std_logic_vector(31 downto 0)
	);
end data_rotation;

architecture RTL of data_rotation is

    signal readdata_out_i : std_logic_vector(31 downto 0);
    signal readdatavalid_out_i : std_logic;

begin

	process(clk, nReset)
	begin
    		if nReset = '0' then
                readdata_out_i <= (others => '0');
                readdatavalid_out_i <= '0';  

    		elsif rising_edge(clk) then
                readdata_out_i(15 downto 0) <= readdata_in(31 downto 16);
                readdata_out_i(31 downto 16) <= readdata_in(15 downto 0);
                readdatavalid_out_i <= readdatavalid_in;
    		end if;
	end process;

    process(clk, readdata_out_i, readdatavalid_out_i)
    begin
        readdata_out <= readdata_out_i;
        readdatavalid_out <= readdatavalid_out_i;
    end process;

end RTL;

