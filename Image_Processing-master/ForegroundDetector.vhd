library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.math_real.all;

entity ForegroundDetector is
 generic(width     : natural := 8);
    Port(clk       : in std_logic;
         resetn    : in std_logic;
         s_tvalid  : in std_logic;
         s_tdata   : in std_logic_vector(width - 1 downto 0);
         bg_tdata  : in std_logic_vector(width - 1 downto 0);
         threshold : in std_logic_vector(width - 1 downto 0);
         m_tdata   : out std_logic_vector(width - 1 downto 0));
end ForegroundDetector;

architecture Behavioral of ForegroundDetector is
constant white_pixel : std_logic_vector(width - 1 downto 0) := x"ff";
constant black_pixel : std_logic_vector(width - 1 downto 0) := x"00";
signal threshold_signed : signed(width downto 0) := (others=>'0');
signal diff : signed(width downto 0) := (others=>'0');
begin

process(clk)
begin
  if rising_edge(clk) then
    if(resetn = '0') then
	  diff <= (others => '0');
	  threshold_signed <= (others => '0');
    elsif(s_tvalid = '1') then
	  -- Convert input data to signed vectors with 9 bits
      diff <= resize(abs(signed('0' & s_tdata) - signed('0' & bg_tdata)), 9);
	  -- Resize the threshold to 9 bits
      threshold_signed <= resize(signed(threshold), 9);
	else
	  diff <= (others => '0');
	  threshold_signed <= (others => '0');
	end if;
  end if;
end process;

process(clk) 
begin
  if rising_edge(clk) then
    if(resetn = '0') then
	  m_tdata <= (others=>'0');
	elsif(s_tvalid = '1') then
	  -- Check if any channel exceeds the threshold
      if(diff > threshold_signed) then
        m_tdata <= white_pixel; -- White pixel (foreground)
      else
        m_tdata <= black_pixel; -- Black pixel (background)
      end if;
    end if;
  end if;
end process;
end Behavioral;