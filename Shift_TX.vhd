--------------------------------------------------------------------------------
-- Company: Spaceequation Inc
--
-- File: Shift_TX.vhd
--
--
-- Description: 
--
-- Serial shift module
--
-- Author: Vikram Reddy
--
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;


entity Shift_TX is
port (
			CLK         	: in std_logic;                     	
	    
	        	RST     	  : in std_logic;	                 	   	 
			
          	  	load_IN       	: in std_logic;	
			
            	Trigger_IN         : in std_logic;
			
				Parity_EN      : in std_logic;   -- Set even parity
			
				Parallel_IN 	: in std_logic_vector(7 downto 0);	
			
		    	Ready           : out std_logic;
					
            	TX_OUT	: out std_logic  

           
       );
end Shift_TX;

architecture rtl of Shift_TX is
attribute syn_preserve : boolean;
attribute syn_preserve of rtl: architecture is true;

type state_type is (idle,start,data,parity,stop);
signal state_reg,state_next: state_type;
signal TX_Serial_OUT_nxt:std_logic;
signal TX_Serial_OUT:std_logic;
signal load_flag:std_logic;
signal load_flag_nxt:std_logic;
signal load:std_logic;
signal Bit_counter: integer range 0 to 7;
signal Bit_counter_nxt: integer range 0 to 7;
signal Parity_cur,Parity_nxt: std_logic;
signal Trigger: std_logic;
signal Parallel_INP: std_logic_vector(7 downto 0);
signal Parity_ENP: std_logic;
constant C : integer := 7;  -- max bit count 



begin

Ready <= load_flag;
inst_clk_gen_Shift_TX: process (RST,CLK)
                begin 
				if RST = '0' then
               			state_reg <= idle;
				load_flag <= '0';
				TX_Serial_OUT <= '1';
				Bit_counter <= 0;
				Parity_cur <= '0';
                               
                elsif CLK = '1' and CLK'event then										
                load_flag <= load_flag_nxt;
				TX_Serial_OUT <= TX_Serial_OUT_nxt;
				TX_OUT <= TX_Serial_OUT_nxt;
				Bit_counter <= Bit_counter_nxt;
				state_reg <= state_next;
				Parity_cur <= Parity_nxt;
				Trigger <= Trigger_IN;
				Parallel_INP <= Parallel_IN;
				load <= load_IN;
				Parity_ENP <= Parity_EN;
                end if;
                
end process;

--assign next state values (to avoid latching) 
inst_Shift_TX_FSMD: process(Trigger,state_reg, load_flag,Parity_cur,load,Bit_counter,Parallel_INP,Parity_ENP,TX_Serial_OUT)
			begin
                       case state_reg is 
					   
							
							when idle =>
			                    			if  load = '1' and load_flag ='0' then
								state_next <= start;
								load_flag_nxt <= '1';

								else
								state_next <= state_reg;
								load_flag_nxt <= '0';
                                				end if;
							        
								TX_Serial_OUT_nxt <= '1';
								Bit_counter_nxt <= 0;
								Parity_nxt <= '0';
                                                                

							when start => 
								if Trigger = '1' and load_flag = '1'  then 
								state_next <= data;
								TX_Serial_OUT_nxt <= '0';
								else
								state_next <= state_reg;
								TX_Serial_OUT_nxt <= TX_Serial_OUT;
								
								end if;
								load_flag_nxt <= load_flag;
								Parity_nxt <= Parity_cur;
							        Bit_counter_nxt <= Bit_counter;
														
							when data => 
								if Trigger = '1' and load_flag = '1'then
									if  (Bit_counter = C) and (Parity_ENP = '1') then 
									state_next <= parity;
									Bit_counter_nxt <= Bit_counter;
									Parity_nxt <= Parity_cur;
                                   
                                                              
								    elsif  (Bit_counter = C) and (Parity_ENP = '0') then  
									state_next <= stop;
									Bit_counter_nxt <= Bit_counter;
									Parity_nxt <= Parity_cur;
									
									else
									state_next <= state_reg;
									Bit_counter_nxt <= Bit_counter + 1;
									Parity_nxt <= Parity_cur XOR Parallel_INP(Bit_counter);
									
									end if;
								TX_Serial_OUT_nxt <= Parallel_INP(Bit_counter);
								else
							   		
								TX_Serial_OUT_nxt <= TX_Serial_OUT; 
								Bit_counter_nxt <= Bit_counter;
								Parity_nxt <= Parity_cur;
								state_next <= state_reg;
								
								end if;
								load_flag_nxt <= load_flag;
								
						
						when parity => 						
							
								if Trigger = '1' and load_flag = '1'then
								TX_Serial_OUT_nxt <= Parity_cur; 
								state_next <= stop;
								else
								TX_Serial_OUT_nxt <= TX_Serial_OUT; 
								state_next <= state_reg;
								end if;
								Bit_counter_nxt <= 0;	 
								Parity_nxt <= Parity_cur;
								load_flag_nxt <= load_flag;
								

						when stop => 
								if Trigger = '1' and load_flag = '1'then
								TX_Serial_OUT_nxt <= '1'; 
								state_next <= idle;
								load_flag_nxt <= '0';
								else
								TX_Serial_OUT_nxt <= TX_Serial_OUT; 
								state_next <= state_reg;
								load_flag_nxt <= load_flag;
								end if;
								Bit_counter_nxt <= 0;	 
								Parity_nxt <= '0';

						    when others =>
						    TX_Serial_OUT_nxt <= '1'; 
						    load_flag_nxt <= '0';
						    Parity_nxt <= '0';
						    state_next <=  idle;
						    Bit_counter_nxt <= 0;
          
                        end case;
			
						 
end process;


end rtl;
