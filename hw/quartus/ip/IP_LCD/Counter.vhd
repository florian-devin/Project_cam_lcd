library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
    generic(
        cnt_width : integer := 4
    );

    Port ( 
        nReset  : in std_logic;
        trigger : in std_logic;
        clr     : in std_logic;
        cnt     : out std_logic_vector(cnt_width-1 downto 0)
    );
        
end counter;

architecture count_arch of counter is
   signal i_cnt : std_logic_vector(cnt_width-1 downto 0);

begin
    process(nReset, clr, trigger)
        begin
            if (nReset = '0') then 
                i_cnt <= (others => '0');
            
            elsif (clr = '1') then
                i_cnt <= (others => '0');

            elsif (rising_edge(trigger)) then 
                i_cnt <= std_logic_vector(unsigned(i_cnt) + 1);

            end if;
        end process;
        
    cnt <= i_cnt;

end count_arch;