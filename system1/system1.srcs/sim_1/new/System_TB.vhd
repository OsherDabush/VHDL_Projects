library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity System_TB is
--  Port ( );
end System_TB;

architecture Behavioral of System_TB is

component System is
  Port(clk, en, up_dn, clr : in std_logic;
       y : out std_logic);
end component;

signal clk, en, up_dn, clr: std_logic := '0';
signal y : std_logic;
begin

U1: System port map(clk=>clk, en=>en, up_dn=>up_dn, clr=>clr, y=>y); 

process
begin
  clk <= '0';
  wait for 5ns;
  clk <= '1';
  wait for 5ns;
end process;

process
begin
  en <= '1';
  up_dn <= '1';
  wait for 100ns;
  up_dn <= '0';
  wait for 50ns;
  en <= '0';
  wait for 30ns;
  clr <= '1';
  wait;
end process;
end Behavioral;
