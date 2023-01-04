library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
    generic(
        cnt_width : integer := 4
    );

    Port ( 
        nReset  : in std_logic;
        trigger1 : in std_logic;
        trigger2 : in std_logic;
        clr     : in std_logic;
        cnt     : out std_logic_vector(cnt_width-1 downto 0)
    );
        
end counter;

architecture count_arch of counter is
    signal i_cnt : std_logic_vector(cnt_width-1 downto 0);
    signal i_trigger : std_logic;
begin
    process(nReset, clr, i_trigger)
        begin
            if (nReset = '0') then 
                i_cnt <= (others => '0');
            
            elsif (clr = '1') then
                i_cnt <= (others => '0');

            elsif (rising_edge(i_trigger)) then 
                i_cnt <= std_logic_vector(unsigned(i_cnt) + 1);

            end if;
        end process;
        
    cnt <= i_cnt;
    i_trigger <= trigger1 AND trigger2;

end count_arch;