library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity system2 is
    Port(a   : in std_logic_vector(7 downto 0);
         sel : in std_logic_vector(1 downto 0);
         y   : out std_logic_vector(7 downto 0));
end system2;

architecture Behavioral of system2 is
signal s0 : std_logic_vector(7 downto 0);
signal s1 : std_logic_vector(7 downto 0);
signal s2 : std_logic_vector(7 downto 0);
signal s3 : std_logic_vector(7 downto 0);
begin

process(a)
variable count : integer range 0 to 8 := 0;
begin
    for i in 0 to 7 loop
        if (a(i) = '1') then
            count := count + 1;
        end if;
    end loop;
    s0 <= std_logic_vector(to_unsigned(count, 8));
end process;

process(a)
variable temp : unsigned(7 downto 0);
begin
    temp := (unsigned(a) xor x"ff") + 1;
    s1   <= std_logic_vector(temp);
end process;

process(a)
variable count : integer range 0 to 7;
begin
    count := 0;
    for i in 0 to 7 loop
        if (a(i) = a(i + 1)) then 
            count := count + 1;
        end if;
        s2 <= std_logic_vector(to_unsigned(count, 8));
    end loop;
end process;

process(a)
variable temp : std_logic_vector(7 downto 0);
begin
    temp := a;
    temp := temp(6 downto 0) & '0';
    if (a(7) = '1') then
        temp := x"00";
    end if;
    s3 <= temp;
end process;

process(a, sel)
begin
    case sel is
        when "00" =>
            y <= s0;
        when "01" =>
            y <= s1;
        when "10" =>
            y <= s2;
        when "11" =>
            y <= s3;
        when others => 
            y <= "XXXXXXXX";
    end case;
end process;
end Behavioral;
