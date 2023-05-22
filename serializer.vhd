library ieee;
use ieee.std_logic_1164.all;

entity serializer is 
generic
(
	number_of_baud : integer:=10
);
port
(
	 Clk     	  : in std_logic;
    Rst 		     : in std_logic;
    
    Shift_Enable : in std_logic; --active high
    Load_Data    : in std_logic; --active high
    Din    		  : in std_logic_vector(number_of_baud-1 downto 0);
    
	 Dout   		  : out std_logic
);
end entity;

architecture rtl of serializer is 
signal Data     : std_logic_vector(number_of_baud-1 downto 0):=(others=>'1');
begin
	Serialize:process(Clk,Rst)
	begin
		if Rst='1' then
			Dout<='1';
			Data<=(others=>'1');
		elsif rising_edge(Clk) then
			if Load_Data='1' then
				Data<=Din;
			elsif Shift_Enable='1' then
				Data<='1'&Data(number_of_baud-1 downto 1);
				Dout<=Data(0);
			end if;
		end if;
	end process;
end rtl;