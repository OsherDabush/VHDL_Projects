library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_Controller is
  Port(clk, rst  : in std_logic;
       tx_enable : in std_logic;
       data_in   : in std_logic_vector(7 downto 0);
       data_out  : out std_logic_vector(7 downto 0);
       rx        : in std_logic;
       tx        : out std_logic);
end UART_Controller;

architecture Behavioral of UART_Controller is

component Debouncer is 
  Port(clk, rst : in std_logic;
       btn_in   : in std_logic;
       btn_out  : out std_logic);
end component;

component UART is 
  Port(clk, rst : in std_logic;
       tx_start : in std_logic;
       data_in  : in std_logic_vector(7 downto 0);
       data_out : out std_logic_vector(7 downto 0);
       rx       : in std_logic;
       tx       : out std_logic);
end component;

signal btn_pressed : std_logic;

begin

TX_Debouncer: Debouncer port map(clk     => clk,
                                 rst     => rst,
                                 btn_in  => tx_enable,
                                 btn_out => btn_pressed);
                                 
UART_Transceiver: UART port map(clk      => clk,
                                rst      => rst,
                                tx_start => btn_pressed,
                                data_in  => data_in,
                                data_out => data_out,
                                rx       => rx,
                                tx       => tx);

end Behavioral;