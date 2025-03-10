library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_RX is
  generic(Baud_Rate_X16 : integer := 54);  -- (clk / baud_rate) / 16 => (100 000 000 / 115 200) / 16 = 54.25
     Port(clk, rst      : in std_logic;
          rx_data_in    : in std_logic;
          rx_data_out   : out std_logic_vector(7 downto 0));
end UART_RX;

architecture Behavioral of UART_RX is

type rx_state_type is (IDLE, START, DATA, STOP);
signal rx_state : rx_state_type := IDLE;

signal baud_rate_clk_x16 : std_logic := '0';
signal rx_data_stored    : std_logic_vector(7 downto 0) := (others=>'0');
begin

process(clk)  -- baud_rate_clk_X16_generator_process
variable baud_x16_count : integer range 0 to (Baud_Rate_X16 - 1) := (Baud_Rate_X16 - 1);
begin
  if rising_edge(clk) then
    if (rst = '1') then
      baud_rate_clk_x16 <= '0';
      baud_x16_count := (Baud_Rate_X16 - 1);
    else
      if (baud_x16_count = 0) then
        baud_rate_clk_x16 <= '1';
        baud_x16_count := (Baud_Rate_X16 - 1);
      else
        baud_rate_clk_x16 <= '0';
        baud_x16_count := baud_x16_count - 1;
      end if;
    end if;
  end if;
end process;

process(clk)  -- UART_RX_FSM_Process
variable bit_duration_count : integer range 0 to 15 := 0;
variable bit_count          : integer range 0 to 7 := 0;
begin
  if rising_edge(clk) then
    if (rst = '1') then
      rx_state <= IDLE;
      rx_data_stored <= (others=>'0');
      rx_data_out <= (others=>'0');
      bit_duration_count := 0;
      bit_count := 0;
    else
      if (baud_rate_clk_x16 = '1') then       -- the FSM works 16 times faster the baud rate frequency
        case rx_state is 
          when IDLE =>                        
            rx_data_stored <= (others=>'0');  -- clean the received data register
            bit_duration_count := 0;          -- reset counters
            bit_count := 0;
            
            if (rx_data_in = '0') then        -- if the start bit received
              rx_state <= START;              -- transit to the START state
            end if;
          
          when START =>
            if (rx_data_in = '0') then            -- verify that the start bit is preset
              if (bit_duration_count = 7) then    -- wait a half of the baud rate cycle
                rx_state <= DATA;                 -- (it puts the capture point at the middle of duration of the receiving bit)
                bit_duration_count := 0;
              else
                bit_duration_count := bit_duration_count + 1;
              end if;
            else
              rx_state <= IDLE;  -- the start bit is not preset (false alarm)
            end if;
            
          when DATA =>
            if (bit_duration_count = 15) then            -- wait for "one" baud rate cycle (not strictly one, about one)
              rx_data_stored(bit_count) <= rx_data_in;   -- fill in the receiving register one received bit.
              bit_duration_count := 0;
              
              if (bit_count = 7) then     -- when all 8 bit received, go to the STOP state
                rx_state <= STOP; 
                bit_duration_count := 0;
              else
                bit_count := bit_count + 1;
              end if;
            else
              bit_duration_count := bit_duration_count + 1;
            end if;
          
          when STOP =>
            if (bit_duration_count = 15) then   -- wait for "one" baud rate cycle
              rx_data_out <= rx_data_stored;    -- transer the received data to the outside world
              rx_state <= IDLE;
            else
              bit_duration_count := bit_duration_count + 1;
            end if;
            
          when others =>
            rx_state <= IDLE;
            
        end case;
      end if;
    end if;
  end if;
end process;
end Behavioral;