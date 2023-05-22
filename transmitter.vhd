library ieee;
use ieee.std_logic_1164.all;

entity transmitter is
generic 
(
    number_of_baud   	 : integer:=10;
    system_clock       	 : integer:=50000000;
    baud_rate            : integer:=115200
	 
);
port
(
	Clk          : in std_logic; -- 50MHz
   Rst          : in std_logic;
   
   TxStart      : in std_logic; --active low
   TxData       : in std_logic_vector(number_of_baud-3 downto 0);
   TxReady      : out std_logic;
   UART_tx_pin  : out std_logic
);
end entity;

architecture rtl of transmitter is 

component serializer is 
generic
(
	number_of_baud : integer:=10
);
port
(
	 Clk     	  : in std_logic;
    Rst 		     : in std_logic;
    
    Shift_Enable : in std_logic;
    Load_Data    : in std_logic;
    Din    		  : in std_logic_vector(number_of_baud-1 downto 0);
    
	 Dout   		  : out std_logic
);
end component;
component baudclk_generator is

generic
(
	number_of_baud : integer:=10;
	baud_rate      : integer:=115200;
	system_clock	: integer:=50000000
);

port
(
	clk 	: in std_logic;
	rst 	: in std_logic;
	start : in std_logic;
	Ready : out std_logic;
	Baud  : out std_logic
);

end component;
component risingedge_detector is

port 
(
	clk		: in std_logic;
	rst		: in std_logic;
	input 	: in std_logic;
	output 	: out std_logic
);
end component;
signal Transmitted_data : std_logic_vector(number_of_baud-1 downto 0); 
signal Baud : std_logic;
signal Txstart_synced : std_logic;

begin
	
Transmitted_data<='1'&Txdata&'0';

rising:risingedge_detector port map(clk=>clk,
												rst=>rst,
												input=>TxStart,
												output=>Txstart_synced);

baudclock:baudclk_generator generic map(number_of_baud		=>number_of_baud,
													system_clock			=>system_clock,
													baud_rate				=>baud_rate)
									port map(clk 		=>Clk,
												rst 		=>Rst,
												
												start 	=>Txstart_synced,	
												Ready 	=>Txready,
												Baud 		=>Baud);

data_transmitting:serializer generic map(number_of_baud=>number_of_baud)
									  port map ( Clk 				=>Clk,   	  
													 Rst 		     	=>Rst,
													 Shift_Enable 	=>Baud,
													 Load_Data    	=>Txstart_synced,
													 Din    		 	=>Transmitted_data,
													 Dout				=>UART_tx_pin);

end rtl;
