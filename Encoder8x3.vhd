library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY Encoder8x3 IS
    PORT (
        input : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        output : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
    );
END ENTITY Encoder8x3;

ARCHITECTURE Behavioral OF Encoder8x3 IS
BEGIN
    PROCESS (input)
    BEGIN
        CASE input IS
            WHEN "00000001" =>
                output <= "000";
            WHEN "00000010" =>
                output <= "001";
            WHEN "00000100" =>
                output <= "010";
            WHEN "00001000" =>
                output <= "011";
            WHEN "00010000" =>
                output <= "100";
            WHEN "00100000" =>
                output <= "101";
            WHEN "01000000" =>
                output <= "110";
            WHEN "10000000" =>
                output <= "111";
            WHEN OTHERS =>
                output <= "000";
        END CASE;
    END PROCESS;
END ARCHITECTURE Behavioral;