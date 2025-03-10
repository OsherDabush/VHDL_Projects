library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Debouncer is
  generic(COUNTER_SIZE : integer := 10_000);
     Port(clk, rst     : in std_logic;
          btn_in       : in std_logic;
          btn_out      : out std_logic);
end Debouncer;

architecture Behavioral of Debouncer is

signal FF1  : std_logic := '0';   -- output of flip-flop 1
signal FF2  : std_logic := '0';   -- output of flip-flop 2
signal FF3  : std_logic := '0';   -- output of flip-flop 3
signal FF4  : std_logic := '0';   -- output of flip-flop 4
signal count_start : std_logic := '0';
begin

process(clk)
begin
  if rising_edge(clk) then
    if (rst = '1') then
      FF1 <= '0';
      FF2 <= '0';
    else
      FF1 <= btn_in;
      FF2 <= FF1;
    end if;
  end if;
end process;

count_start <= FF1 xor FF2;

process(clk)
variable count : integer range 0 to COUNTER_SIZE := 0;
begin
  if rising_edge(clk) then
    if (rst = '1') then
      count := 0;
      FF3 <= '0';
    else
      if (count_start = '1') then
        count := 0;
      elsif (count < COUNTER_SIZE) then
        count := count + 1;
      else
        FF3 <= FF2;
      end if;
    end if;
  end if;
end process;

process(clk)
begin
  if rising_edge(clk) then
    if (rst = '1') then
      FF4 <= '0';
    else
      FF4 <= FF3;
    end if;
  end if;
end process;

with FF3 select
  btn_out <= FF3 XOR FF4 when '1', 
  '0' when others;

end Behavioral;