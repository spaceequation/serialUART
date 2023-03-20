--------------------------------------------------------------------------------
-- Company: Spaceequation Inc
--
-- File: Timer20ms.vhd
--
--
-- Description: 
--
-- Trigger module
--
-- Author: Vikram Reddy
--
--------------------------------------------------------------------------------   

library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity Timer20ms is
generic (TIMER_COUNT: std_logic_vector(14 downto 0));
port (
            CLK         	: in std_logic;                     	
	    
	        RST     	   : in std_logic;	                 	   
				
            ouptput_trigger	: out std_logic

       );
end Timer20ms;

architecture rtl of Timer20ms is

signal int_count:std_logic_vector (14 downto 0);
signal int_count_nxt:std_logic_vector (14 downto 0);
signal ouptput_trigger_nxt:std_logic;

begin

inst_clk_gen_Trigger: process (RST,CLK)
        begin 
		if RST = '0' then
                int_count <= (others => '0');
                ouptput_trigger <= '0';
                elsif CLK = '1' and CLK'event then
				int_count <= int_count_nxt;
				ouptput_trigger <= ouptput_trigger_nxt;
               
               end if;
end process;

--assign next state values (to avoid latching) 
inst_Trigger_reassign: process(int_count,RST)
			begin
                         if RST = '0' then
                       int_count_nxt <=  (others => '0');
                        ouptput_trigger_nxt <= '0';
                         elsif int_count = TIMER_COUNT then 
					                                                        
				int_count_nxt <= (others => '0');
				ouptput_trigger_nxt <='1';
		         else 
				int_count_nxt <= int_count +1;
				ouptput_trigger_nxt <= '0';
                         end if;
   			end process;
			
end rtl;
