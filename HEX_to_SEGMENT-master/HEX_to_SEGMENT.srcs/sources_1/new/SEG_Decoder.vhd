library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.math_real.all;

entity SEG_Decoder is
    Port(X : in std_logic_vector(3 downto 0);
         Y : out std_logic_vector(6 downto 0));
end SEG_Decoder;

architecture Behavioral of SEG_Decoder is
begin

process(X)
begin
  case X is 
    when x"0" => Y <= "0000001";
    when x"1" => Y <= "1001111";
    when x"2" => Y <= "0010010";
    when x"3" => Y <= "0000110";
    when x"4" => Y <= "1001100";
    when x"5" => Y <= "0100100";
    when x"6" => Y <= "0100000";
    when x"7" => Y <= "0001111";
    when x"8" => Y <= "0000000";
    when x"9" => Y <= "0000100";
    when x"A" => Y <= "0001000";
    when x"B" => Y <= "1100000";
    when x"C" => Y <= "0110001";
    when x"D" => Y <= "1000010";
    when x"E" => Y <= "0110000";
    when x"F" => Y <= "0111000";
  end case;
end process;
end Behavioral;