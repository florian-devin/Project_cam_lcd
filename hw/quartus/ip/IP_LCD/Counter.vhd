library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
    generic(
        cnt_width : integer := 4
    );

    Port ( 
        nReset     : in std_logic;
        trigger : in std_logic;
        o       : out std_logic_vector(cnt_width-1 downto 0));
end counter;

architecture count_arch of counter is
   signal i_o : std_logic_vector(cnt_width-1 downto 0);

begin
    process(nReset, trigger)
        begin
            if (rst = '0') then 
                count <= (others => '0');
            elsif (rising_edge(trigger)) then 
                i_o <= i_o + 1;
            end if;
        end process;
        
    o <= count;

end count_arch;