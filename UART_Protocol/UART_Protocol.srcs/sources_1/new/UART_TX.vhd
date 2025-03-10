library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_TX is
  generic(Baud_Rate   : integer := 868);  -- (100M / 115200) = 868
     Port(clk, rst    : in std_logic;
          tx_start    : in std_logic;
          tx_data_in  : in std_logic_vector(7 downto 0);
          tx_data_out : out std_logic);
end UART_TX;

architecture Behavioral of UART_TX is

type tx_state_type is (IDLE, START, DATA, STOP);
signal tx_state         : tx_state_type := IDLE;

signal baud_rate_clk    : std_logic := '0';

signal data_index       : integer range 0 to 7 := 0;
signal data_index_reset : std_logic := '1';
signal data_stored      : std_logic_vector(7 downto 0) := (others=>'0');

signal start_detected   : std_logic := '0';
signal start_reset      : std_logic := '0';
begin

process(clk)  -- baud_rate_clk_generator_process
variable baud_count : integer range 0 to (Baud_Rate - 1) := (Baud_Rate - 1);
begin
  if rising_edge(clk) then
    if (rst = '1') then
      baud_rate_clk <= '0';
      baud_count := (Baud_Rate - 1);
    else
      if (baud_count = 0) then
        baud_rate_clk <= '1';
        baud_count := (Baud_Rate - 1);
      else
        baud_rate_clk <= '0';
        baud_count := baud_count - 1;
      end if;
    end if;
  end if;
end process;

process(clk)  -- tx_start_detector_process
begin
  if rising_edge(clk) then
    if ((rst = '1') OR (start_reset = '1')) then
      start_detected <= '0';
    else
      if ((tx_start = '1') AND (start_detected = '0')) then
        start_detected <= '1';
        data_stored <= tx_data_in;
      end if;
    end if;
  end if;
end process;

process(clk)  -- data_index_counter_process
begin
  if rising_edge(clk) then
    if ((rst = '1') OR (data_index_reset = '1')) then
      data_index <= 0;
    elsif (baud_rate_clk = '1') then
      data_index <= data_index + 1;
    end if;
  end if;
end process;

process(clk) -- UART_TX_FSM_Process
begin
  if rising_edge(clk) then
    if (rst = '1') then
      tx_state <= IDLE;
      data_index_reset <= '1';  -- keep data_index_counter on hold
      start_reset <= '1';       -- keep tx_start_detector on hold
      tx_data_out <= '1';       -- keep tx line set along the standard
    else
      if (baud_rate_clk = '1') then  -- the FSM works on the baud rate frequency
        case tx_state is
          when IDLE =>
            data_index_reset <= '1';  -- keep data_index_counter on hold
            start_reset <= '0';       -- enable tx_start_detector to wait for starting impulses
            tx_data_out <= '1';       -- keep tx line set along the standard
            
            if (start_detected = '1') then
              tx_state <= START;
            end if;
          
          when START =>
            data_index_reset <= '0';   -- enable data_index_counter for DATA state
            tx_data_out <= '0';        -- send '0' as a start bit
            tx_state <= DATA;
            
          when DATA =>
            tx_data_out <= data_stored(data_index);  -- send one bit per one baud clock cycle 8 times
            
            if (data_index = 7) then
              data_index_reset <= '1';  -- disable data_index_counter when it has reached 8
              tx_state <= STOP;
            end if;
            
          when STOP =>
            tx_data_out <= '1';  -- send '1' as a stop bit
            start_reset <= '1';  -- prepare tx_start_detector to be ready detecting the next impuls in IDLE
            tx_state <= IDLE;
            
          when others =>
            tx_state <= IDLE;
        end case;
      end if;
    end if;
  end if;
end process;
end Behavioral;