library ieee;
use ieee.std_logic_1164.all;

entity uart is

generic

(
	 number_of_baud   	 : integer:=10;
    system_clock       	 : integer:=50000000;
    baud_rate            : integer:=115200
);
port

(
	clk 		: in std_logic;
	rst 		: in std_logic;
	
	tx_data  : in std_logic_vector(number_of_baud-3 downto 0); --gpio27
	tx_start : in std_logic;
	tx_pin 	: out std_logic;
	
	rx_pin 	: in std_logic; --gpio5
	rx_data 	: out std_logic_vector(number_of_baud-3 downto 0);
	rx_ready : out std_logic
);

end entity;

architecture rtl of uart is

component receiver is

generic
(
	 number_of_baud   	 : integer:=10;
    system_clock       	 : integer:=50000000;
    baud_rate            : integer:=115200
);
port
(
	Clk : in std_logic;
	Rst : in std_logic;
	Din : in std_logic;
	Dout: out std_logic_vector(number_of_baud-3 downto 0);
	Ready : out std_logic
);
end component;

component transmitter is
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
end component;

signal ready_to_transmit 	: std_logic;
signal rst_not : std_logic;

begin

rst_not<=(not rst); 

receive:receiver generic map(	number_of_baud	=>number_of_baud,
										system_clock	=>system_clock,
										baud_rate		=>baud_rate)
					  
					  port map(Clk		=>Clk,
								  Rst		=>rst_not,
								  Din		=>rx_pin,
								  Dout	=>rx_data,
								  Ready	=>rx_ready);

transmit:transmitter generic map( number_of_baud =>number_of_baud,
											 system_clock	 =>system_clock,
											 baud_rate		 =>baud_rate)
							
							port map(Clk			=>Clk,
										Rst			=>rst_not,
										TxStart		=>tx_start,
										TxData		=>tx_data,
										TxReady		=>ready_to_transmit,
										UART_tx_pin	=>tx_pin);

end rtl;