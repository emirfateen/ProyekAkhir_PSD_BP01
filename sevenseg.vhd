library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sevenseg is
Port ( bcdin : in STD_LOGIC_VECTOR (3 downto 0);
sevensegment : out STD_LOGIC_VECTOR (6 downto 0));
end sevenseg;

architecture sevenseg of sevenseg is
begin

    process(bcdin)
    begin
        case bcdin is
            when "0000" => sevensegment <= "1000000"; ---0
            when "0001" => sevensegment <= "1111001"; ---1
            when "0010" => sevensegment <= "0100100"; ---2
            when "0011" => sevensegment <= "0110000"; ---3
            when "0100" => sevensegment <= "1100011"; ---4
            when others => sevensegment <= "1111111"; 
        end case;
    end process;

end sevenseg;