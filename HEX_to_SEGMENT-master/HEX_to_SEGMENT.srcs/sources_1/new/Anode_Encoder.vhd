library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.math_real.all;

entity Anode_Encoder is
    Port(SEL   : in std_logic_vector(3 downto 0);
         ANODE : out std_logic_vector(3 downto 0));
end Anode_Encoder;

architecture Behavioral of Anode_Encoder is
begin

process(SEL)
begin
  case SEL is 
    when "1110" => ANODE <= "1110";
    when "1101" => ANODE <= "1101";
    when "1011" => ANODE <= "1011";
    when "0111" => ANODE <= "0111";
    when others => ANODE <= "1111";
  end case;
end process;
end Behavioral;