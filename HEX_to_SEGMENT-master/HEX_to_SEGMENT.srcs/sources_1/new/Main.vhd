library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.math_real.all;

entity Main is
    Port(HEX     : in std_logic_vector(3 downto 0);
         enableN : in std_logic_vector(3 downto 0);
         SEVEN_SEG     : out std_logic_vector(6 downto 0);
         ANODES   : out std_logic_vector(3 downto 0));
end Main;

architecture Behavioral of Main is

component SEG_Decoder is
    Port(X : in std_logic_vector(3 downto 0);
         Y : out std_logic_vector(6 downto 0));
end component;

component Anode_Encoder is
    Port(SEL   : in std_logic_vector(3 downto 0);
         ANODE : out std_logic_vector(3 downto 0));
end component;

begin

S_D: SEG_Decoder port map(X=>HEX,
                          Y=>SEVEN_SEG);
                          
A_E: Anode_Encoder port map(SEL=>enableN,
                            ANODE=>ANODES);       
                          
end Behavioral;