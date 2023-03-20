--------------------------------------------------------------------------------
-- Company: Spaceequation Inc
--
-- File: COM_MANAGER
--
--
-- Description: 
--
-- serial communication manager
--
-- Author: Vikram Reddy
--
--------------------------------------------------------------------------------             

library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;


entity COM_MANAGER is

	port (  CLK         : in std_logic;                      -- 40MHz osc clock
           
            RST         : in std_logic;                      -- used for reset
			
			TRIGGER     : in std_logic;
			
			TX_OUT      : out std_logic;                     -- used for reset
			
			ADC_0            : in std_logic_vector (11 downto 0);
	
            ADC_1            : in std_logic_vector (11 downto 0);
            
            ADC_2            : in std_logic_vector (11 downto 0);

            ADC_3            : in std_logic_vector (11 downto 0);

            ADC_4            : in std_logic_vector (11 downto 0);
			
            ADC_5            : in std_logic_vector (11 downto 0);

            ADC_6            : in std_logic_vector (11 downto 0);
			
            ADC_7            : in std_logic_vector (11 downto 0);
			
			ADC_TEST_B       : in std_logic_vector (11 downto 0);
			
			ADC_TEST_C       : in std_logic_vector (11 downto 0);
			
			ADC_TEST_D       : in std_logic_vector (11 downto 0)
            
);
end COM_MANAGER;


architecture rtl of COM_MANAGER is
attribute syn_preserve : boolean;
attribute syn_preserve of rtl: architecture is true;


component Shift_TX is 
           port (
           		CLK         	: in std_logic;                     	
	    
	        	RST     	    : in std_logic;	                 	   	 
			
          	  	load_IN       	: in std_logic;	
			
            	Trigger_IN      : in std_logic;
			
				Parity_EN       : in std_logic;   -- Set even parity
			
				Parallel_IN 	: in std_logic_vector(7 downto 0);	
			
		    	Ready           : out std_logic;
					
            	TX_OUT          : out std_logic  
			
			);
end component;


component Timer115200 is
generic (TIMER_COUNT: std_logic_vector (6 downto 0));
port (
            CLK               : in std_logic;                     	 -- 1MHz osc clock
	    
	        RST     	      : in std_logic;	                 	   	 -- to toggle leds
				
            ouptput_trigger	  : out std_logic

       );
end component;


--component Timer9600 is
--generic (TIMER_COUNT: std_logic_vector (9 downto 0));
--port (
--            CLK               : in std_logic;                     	 -- 1MHz osc clock
--	    
--	        RST     	      : in std_logic;	                 	   	 -- to toggle leds
--				
--            ouptput_trigger	  : out std_logic
--
--       );
--end component;



signal Load1: std_logic;
signal Load1_nxt: std_logic;
signal Parity1_EN:std_logic;
signal Parallel1_IN:std_logic_vector (7 downto 0);
signal Parallel1_IN_nxt:std_logic_vector (7 downto 0);
signal Ready1: std_logic;
type Data_Frame1 is array (0 to 25) of std_logic_vector (7 downto 0);
signal Bcount1, Bcount1_nxt:integer range 0 to 25;
signal TX_byte1:Data_Frame1;
signal Data_change1:std_logic;
signal FRAME_SET1:std_logic;
signal FRAME_SET1_NXT:std_logic;
signal FRAME_COMPLETE1:std_logic;
signal FRAME_COMPLETE1_NXT:std_logic;
signal Trigger_9600: std_logic;

constant CONSTANT_TIMER_14400:std_logic_vector (9 downto 0):= "1010011010"; -- 14400 baud rate

begin

Parity1_EN <= '0';

TX_byte1(0)  <= x"02";-- Frame Byte 0  
TX_byte1(1)  <= x"AD";-- Frame Byte 0
TX_byte1(2)  <= x"C0";-- Frame Byte 0
TX_byte1(3)  <= "0000" & ADC_0 (11 downto 8);
TX_byte1(4)  <= ADC_0 (7 downto 0); 
TX_byte1(5)  <= "0000" & ADC_1 (11 downto 8);
TX_byte1(6)  <= ADC_1 (7 downto 0); 
TX_byte1(7)  <= "0000" & ADC_2 (11 downto 8);
TX_byte1(8)  <= ADC_2 (7 downto 0);
TX_byte1(9)  <= "0000" & ADC_3 (11 downto 8);
TX_byte1(10) <= ADC_3 (7 downto 0); 
TX_byte1(11) <= "0000" & ADC_4 (11 downto 8);
TX_byte1(12) <= ADC_4 (7 downto 0); 
TX_byte1(13) <= "0000" & ADC_5 (11 downto 8);
TX_byte1(14) <= ADC_5 (7 downto 0);
TX_byte1(15) <= "0000" & ADC_6 (11 downto 8);
TX_byte1(16) <= ADC_6 (7 downto 0);
TX_byte1(17) <= "0000" & ADC_7 (11 downto 8);
TX_byte1(18) <= ADC_7 (7 downto 0);
TX_byte1(19) <= "0000" & ADC_TEST_B (11 downto 8);
TX_byte1(20) <= ADC_TEST_B (7 downto 0);
TX_byte1(21) <= "0000" & ADC_TEST_C (11 downto 8);
TX_byte1(22) <= ADC_TEST_C (7 downto 0);
TX_byte1(23) <= "0000" & ADC_TEST_D (11 downto 8);
TX_byte1(24) <= ADC_TEST_D (7 downto 0);
TX_byte1(25) <= x"03";


							
inst_422TX: Shift_TX port map (CLK   		    => CLK,
								RST             => RST,
								load_IN		    => Load1,
								Trigger_IN	    => Trigger_9600,
								Parity_EN	    => Parity1_EN,
								Parallel_IN	    => Parallel1_IN,
								Ready		    => Ready1,
								TX_OUT		    => TX_OUT);

--inst_Trigger: Timer9600 generic map (TIMER_COUNT => CONSTANT_TIMER_14400)  -- 8.695 us equal to 115000 baud rate
--                            port map (
--							    CLK        		  =>    CLK,                	
--	    
--		     					RST     		  =>    RST,                  	  -- RST
--				
--								ouptput_trigger	  =>    Trigger_9600);

inst_Trigger: Timer115200 generic map (TIMER_COUNT => "1000101")  -- 8.695 us equal to 115000 baud rate
                            port map (
							    CLK        		  =>    CLK,                	
	    
		     					RST     		  =>    RST,                  	  -- RST
				
								ouptput_trigger	  =>    Trigger_9600);
								

inst_CLK_COM_CCD : process (RST,CLK)
BEGIN 
				if RST = '0' then
                Data_change1 <= '0';
                Bcount1 <= 0;
                Parallel1_IN <= (others => '0');
                Load1  <= '0';
			    FRAME_SET1 <= '0';
				FRAME_COMPLETE1 <= '0';
				elsif CLK = '1' and CLK'event then
               
                Parallel1_IN <= Parallel1_IN_nxt;
                Load1 <= Load1_nxt;
                Data_change1 <= Load1;  --one cycle Delay 
                Bcount1 <= Bcount1_nxt;
				FRAME_SET1 <= FRAME_SET1_NXT;
			    FRAME_COMPLETE1 <= FRAME_COMPLETE1_NXT;


                end if;
end process;


inst_Frame1: process(TRIGGER,FRAME_SET1,FRAME_COMPLETE1)
BEGIN
        if TRIGGER = '1' then 
		      FRAME_SET1_NXT <= '1';
			elsif FRAME_COMPLETE1 = '1'  then 
			 FRAME_SET1_NXT <= '0';
			else 
		  FRAME_SET1_NXT <= FRAME_SET1; 	
         end if;

end process;

inst_Toggle1: process(Ready1,Parallel1_IN,Bcount1,Data_change1,FRAME_SET1,TX_byte1,FRAME_COMPLETE1)
	BEGIN
                         
                            if Ready1 = '0' and FRAME_SET1 = '1'   then 
                                    if Bcount1 = 25 and Data_change1 = '1' then 
                                    Bcount1_nxt <= 0;
									FRAME_COMPLETE1_NXT <= '1';
                                    elsif Data_change1 = '1' then 
                                    Bcount1_nxt <= Bcount1 + 1;
									FRAME_COMPLETE1_NXT <= FRAME_COMPLETE1;
                                    else
                                    Bcount1_nxt <= Bcount1;
									FRAME_COMPLETE1_NXT <= FRAME_COMPLETE1;
                                    end if;
                                    Parallel1_IN_nxt <= TX_byte1(Bcount1);
                                    Load1_nxt <= '1';            
                            else

                                Parallel1_IN_nxt <= Parallel1_IN;
                                FRAME_COMPLETE1_NXT <= '0';
                                Load1_nxt <= '0';
                                Bcount1_nxt <=  Bcount1;
                            end if;
	end process;


	
end rtl;

