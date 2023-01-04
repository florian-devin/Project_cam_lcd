library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity inverter is
    Port ( 
        i : in std_logic;
        o : out std_logic 
    );
        
end inverter;

architecture inverter_arch of inverter is
begin
    
    o <= not(i);

end inverter_arch;