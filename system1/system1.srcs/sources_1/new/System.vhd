library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity System is
  Port(clk, en, up_dn, clr : in std_logic;
       y : out std_logic);
end System;

architecture Behavioral of System is
signal count : std_logic_vector(1 downto 0);
signal b : std_logic_vector(2 downto 0);
signal t : std_logic_vector(2 downto 0);
begin

process(clk)  -- Counter Process
variable cnt : integer range 0 to 3 := 0;
begin
  if rising_edge(clk) then
    if (clr = '1') then
      cnt := 0;
    elsif (en = '1') then
      if (up_dn = '1') then
        cnt := cnt + 1;
      else
        cnt := cnt - 1;
      end if;
    end if;
  end if;
  count <= std_logic_vector(to_unsigned(cnt, 2));
end process;

process(count)  -- Decoder Process
begin
  case count is
    when "00" => 
      b <= "001";
    when "01" => 
      b <= "010";
    when "10" => 
      b <= "100";
    when "11" =>
      b <= "000";
    when others =>
      b <= "XXX";
  end case;
end process;

process(clk, b)  -- D-FF1 Process
begin
  if rising_edge(clk) then
    t(0) <= b(2);
  end if;
end process;

t(1) <= t(0) AND b(0);

process(clk, t)  -- D-FF2 Process
begin
  if rising_edge(clk) then
    t(2) <= t(1);
  end if;
end process;

y <= t(2) XOR b(1);

end Behavioral;