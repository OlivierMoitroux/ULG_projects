



library ieee;
library std;
use ieee. std_logic_1164.all;
use ieee. std_logic_textio.all;
use ieee. std_logic_unsigned.all;
use std.textio.all;


 entity test_Mastermind is -- déclaration d'une entité vide pourla simulation
 end;
 
 architecture test_arch of test_Mastermind is 
													
	-- input
	signal clk_Button			:  std_logic;		-- déclaration des signaux internes que sont les I/O de Mastermind
	signal clk_Rand			:  std_logic;
	signal Button1 			:  std_logic;
	signal Button2 			:  std_logic;
	signal Button3 			:  std_logic;
	signal Button4 			:  std_logic;
	signal ButtonValidate 	:  std_logic;
	signal ButtonRES 			:  std_logic;
	
	-- output
	-- (3 pins de couleur par LED RGB)
	signal RGB0_red		:  std_logic; 
	signal RGB0_green		:  std_logic;
	signal RGB0_blue		:  std_logic;
	
	signal RGB1_red		:  std_logic;
	signal RGB1_green		:  std_logic;
	signal RGB1_blue		:  std_logic;
	
	signal RGB2_red		:  std_logic;
	signal RGB2_green		:  std_logic;
	signal RGB2_blue		:  std_logic;
	
	signal RGB3_red		:  std_logic;
	signal RGB3_green		:  std_logic;
	signal RGB3_blue		:  std_logic;
	
	signal Segment1a		:  std_logic; 
	signal Segment1b		:  std_logic;
	signal Segment1c		:  std_logic;
	signal Segment1d		:  std_logic;
	
	signal Segment2a		:  std_logic; 
	signal Segment2b		:  std_logic;
	signal Segment2c		:  std_logic;
	signal Segment2d		:  std_logic;
	
	-- les variables que j'utilise dans ce TestBench--
	
	constant fast_clk_cycle : integer := 10000; 
	constant slow_clk_cycle : integer := 1000; 
	
	
	-- description de Mastermind 
	component Mastermind 
	port (
	
	-- input
	clk_Button		: in std_logic;
	clk_Rand       : in std_logic;
	Button1 			: in std_logic;
	Button2 			: in std_logic;
	Button3 			: in std_logic;
	Button4 			: in std_logic;
	ButtonValidate : in std_logic;
	ButtonRES 		: in std_logic;
	
	-- output
	-- (3 pins de couleur par LED RGB)
	RGB0_red		: buffer std_logic; 
	RGB0_green	: buffer std_logic;
	RGB0_blue	: buffer std_logic;
	
	RGB1_red		: buffer std_logic;
	RGB1_green	: buffer std_logic;
	RGB1_blue	: buffer std_logic;
	
	RGB2_red		: buffer std_logic;
	RGB2_green	: buffer std_logic;
	RGB2_blue	: buffer std_logic;
	
	RGB3_red		: buffer std_logic;
	RGB3_green	: buffer std_logic;
	RGB3_blue	: buffer std_logic;
	
	Segment1a	: buffer std_logic; 
	Segment1b	: buffer std_logic; 
	Segment1c	: buffer std_logic;
	Segment1d	: buffer std_logic;
	
	Segment2a	: buffer std_logic;
	Segment2b	: buffer std_logic;
	Segment2c	: buffer std_logic;
	Segment2d	: buffer std_logic
	);
	
	end component;
	
	--Begining of the architecture 
	begin 
	DUT : Mastermind -- on indique quel composant est testé  (Device Under Test) 
		port map (
		
	clk_Button		=> clk_Button,
	clk_Rand       => clk_Rand,
	Button1 			=> Button1,
	Button2 			=> Button2,
	Button3 			=> Button3,
	Button4 			=> Button4,
	ButtonValidate => ButtonValidate,
	ButtonRES 		=> ButtonRES,
	
	
	RGB0_red		=> RGB0_red,
	RGB0_green	=> RGB0_green,
	RGB0_blue	=> RGB0_blue,
	
	RGB1_red		=> RGB1_red,
	RGB1_green	=> RGB1_green,
	RGB1_blue	=> RGB1_blue,
	
	RGB2_red		=> RGB2_red,
	RGB2_green	=> RGB2_green, 
	RGB2_blue	=> RGB2_blue,
	
	RGB3_red		=> RGB3_red,
	RGB3_green	=> RGB3_green,
	RGB3_blue	=> RGB3_blue,
	
	Segment1a	=> Segment1a,
	Segment1b	=> Segment1b,
	Segment1c	=> Segment1c,
	Segment1d	=> Segment1d,
	
	Segment2a   => Segment2a,
	Segment2b   => Segment2b,
	Segment2c   => Segment2c,
	Segment2d   => Segment2d
	);
	
	-- Déclaration des process
	
	-- Première clock
	
	clk_rapide : process 
	begin 
		for i in 1 to fast_clk_cycle loop 
			clk_Rand <= '0';
			wait for  8ms ;
			clk_Rand <= '1';
			wait for  8ms ;
		end loop;
		wait for 0.1sec; 
	end process clk_rapide ;
	
	--deuxième clock
	
	clk_lente : process 
	begin 
		for i in 1 to slow_clk_cycle loop 
			clk_Button <= '0';
			wait for  60ms ;
			clk_Button <= '1';
			wait for  60ms ;
		end loop;
		wait for 0.1sec; 
	end process clk_lente ;
	
	
	simulation_tour : process
	begin 
	
	wait for 0.5sec;
		Button1 <= '0';
		Button2 <= '0';
		Button3 <= '0';
		Button4 <= '0';
		ButtonValidate <= '0';
		ButtonRES <= '0';
	
	wait for 0.5sec ;
		ButtonRES <= '1';
	wait for 150ms ;
		ButtonRES <= '0';
		
	-- premier choix
	
	wait for 0.5sec;
		ButtonValidate <= '1';
	wait for 150ms;
		ButtonValidate <= '0';
		
	wait for 0.5sec ;
		Button1 <= '1';
	wait for 150ms ;
		Button1 <='0';
	
	wait for 0.5sec;
		ButtonValidate <= '1';
	wait for 150ms;
		ButtonValidate <= '0';
	
	wait for 0.5sec;
		ButtonValidate <= '1';
	wait for 150ms;
		ButtonValidate <= '0';
		
	wait for 0.5sec;
		ButtonValidate <= '1';
	wait for 150ms;
		ButtonValidate <= '0';
		
	wait for 0.5sec;
		ButtonValidate <= '1';
	wait for 150ms;
		ButtonValidate <= '0';

	wait for 0.5sec;
		ButtonValidate <= '1';
	wait for 150ms;
		ButtonValidate <= '0';

	wait for 0.5sec;
		ButtonValidate <= '1';
	wait for 150ms;
		ButtonValidate <= '0';
		
	wait for 0.5sec;
		ButtonValidate <= '1';
	wait for 150ms;
		ButtonValidate <= '0';
		
	wait for 0.5sec;
		ButtonValidate <= '1';
	wait for 150ms;
		ButtonValidate <= '0';
		
	wait for 0.5sec;
		ButtonValidate <= '1';
	wait for 150ms;
		ButtonValidate <= '0';
		
	wait for 0.5sec ;
		Button1 <= '1';
	wait for 150ms ;
		Button1 <='0';
		
	wait for 0.5sec ;
		Button2 <= '1';
	wait for 150ms ;
		Button1 <='0';
	
	wait for 0.5sec ;
		ButtonRES <= '1';
	wait for 300ms ;
		ButtonRES <='0';

	-----------------------
--	wait for 0.5sec;
--		ButtonValidate <='1';
--	wait for 150ms;
--		
--	-- deuxième choix 
--		
--	wait for 0.5sec ;
--		Button2 <= '1' ;
--	wait for 150ms ;
--		Button2 <='0';
--		
--	wait for 0.5sec ;
--		Button2 <= '1' ;
--	wait for 150ms ;
--		Button2 <='0';
--		
--	-- troisième choix
--		
--	wait for 0.5sec ;
--		Button3 <= '1' ;
--	wait for 200ms ;
--		Button3 <='0';
--	wait for 0.5sec ;
--		Button3 <= '1' ;
--	wait for 90ms ;
--		Button3 <='0';
--	wait for 0.5sec ;
--		Button3 <= '1' ;
--	wait for 170ms ;
--		Button3 <='0';
	
	-- Validation 
	
	wait for 0.5sec ;
		ButtonValidate <= '1' ;
	wait for 300ms ;
		ButtonValidate <= '0';
		
		
	-- NB : d'autres testBench ont été réalisés mais ne sont pas présentés ici (Victoire,...)
		
	end process simulation_tour;
	
end architecture test_arch ;
	
