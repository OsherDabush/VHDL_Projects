library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.math_real.all;

entity BackgroundSubtraction is
 generic(width : natural := 8);
    Port(aclk            : in std_logic;
         aresetn         : in std_logic;
         s_axis_tvalid   : in std_logic;
         s_axis_tdata    : in std_logic_vector(width - 1 downto 0);
         s_axis_tlast    : in std_logic;
         s_axis_tready   : out std_logic;
         m_axis_tvalid   : out std_logic;
         m_axis_tdata    : out std_logic_vector(width - 1 downto 0);
         m_axis_tlast    : out std_logic;
         m_axis_tready   : in std_logic;
         threshold       : in std_logic_vector(width - 1 downto 0));
end BackgroundSubtraction;

architecture Behavioral of BackgroundSubtraction is
component AveragePixels is
 generic(width    : natural := 8);
    Port(clk      : in std_logic;
         resetn   : in std_logic;
         s_tvalid : in std_logic;
         s_tdata  : in std_logic_vector(width - 1 downto 0);
         m_tdata  : out std_logic_vector(width - 1 downto 0));
end component;
component ForegroundDetector is
 generic(width     : natural := 8);
    Port(clk       : in std_logic;
         resetn    : in std_logic;
         s_tvalid  : in std_logic;
         s_tdata   : in std_logic_vector(width - 1 downto 0);
         bg_tdata  : in std_logic_vector(width - 1 downto 0);
         threshold : in std_logic_vector(width - 1 downto 0);
         m_tdata   : out std_logic_vector(width - 1 downto 0));
end component;
COMPONENT OutputBuffer
  PORT (
    wr_rst_busy : OUT STD_LOGIC;
    rd_rst_busy : OUT STD_LOGIC;
    s_aclk : IN STD_LOGIC;
    s_aresetn : IN STD_LOGIC;
    s_axis_tvalid : IN STD_LOGIC;
    s_axis_tready : OUT STD_LOGIC;
    s_axis_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    s_axis_tlast : IN STD_LOGIC;
    m_axis_tvalid : OUT STD_LOGIC;
    m_axis_tready : IN STD_LOGIC;
    m_axis_tdata : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axis_tlast : OUT STD_LOGIC
  );
END COMPONENT;

signal FIFO_tvalid : std_logic;
signal FIFO_tdata  : std_logic_vector(7 downto 0);
signal bg_tdata    : std_logic_vector(7 downto 0);
begin

-- Connecting the output of Foreground Detector to AXI Video Out
m_axis_tvalid <= FIFO_tvalid;

OutputBuffer_0: OutputBuffer port map(s_aclk=>aclk,
				  	                  s_aresetn=>aresetn,
                                      s_axis_tvalid=>s_axis_tvalid,
                                      s_axis_tready=>s_axis_tready,
                                      s_axis_tdata=>s_axis_tdata,
                                      s_axis_tlast=>s_axis_tlast,
                                      m_axis_tvalid=>FIFO_tvalid,
                                      m_axis_tready=>m_axis_tready, 
                                      m_axis_tdata=>FIFO_tdata,
                                      m_axis_tlast=>m_axis_tlast);
    
Average_Pixels: AveragePixels generic map(width=>8)
                                 port map(clk=>aclk,
									      resetn=>aresetn,
									      s_tvalid=>FIFO_tvalid,
									      s_tdata=>FIFO_tdata,
									      m_tdata=>bg_tdata);

Foreground_Detector: ForegroundDetector generic map(width=>8)
                                           port map(clk=>aclk,
												    resetn=>aresetn,
												    s_tvalid=>FIFO_tvalid,
												    s_tdata=>FIFO_tdata,
												    bg_tdata=>bg_tdata,
												    m_tdata=>m_axis_tdata,
												    threshold=>threshold);

end Behavioral;