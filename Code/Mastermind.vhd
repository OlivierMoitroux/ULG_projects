
library ieee;
use ieee.std_logic_1164.all; -- définition du type bit, bit vector, ...
use ieee.std_logic_arith.all; -- opération signées et non signées sur les vecteurs

entity Mastermind is port(

	-- input
	clk_Rand			: in std_logic;
	clk_Button		: in std_logic;
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
	
	Segment1a	: buffer std_logic; -- stuck at GND logique car tout commence par 0 dans la table de vérité
	Segment1b	: buffer std_logic;
	Segment1c	: buffer std_logic;
	Segment1d	: buffer std_logic;
	
	Segment2a	: buffer std_logic;
	Segment2b	: buffer std_logic;
	Segment2c	: buffer std_logic;
	Segment2d	: buffer std_logic
	
	);
end entity  Mastermind;

architecture Mastermind_arch of Mastermind is

	type LED_state is (Red, Green, Blue);
	
	signal RGB0_state : LED_state := Red;
	signal RGB1_state : LED_state := Red;
	signal RGB2_state : LED_state := Red;
	signal RGB3_state : LED_state := Red;
	
	-- Variable pour l'aléatoire
	signal count : integer range 0 to 80 := 0;
	
	-- Variable pour la vie
	signal Vie : integer range 0 to 9 := 9;
	
	-- La combinaison gagnante
	type SecretCodeType is array(0 to 3) of LED_state;
	signal SecretCode : SecretCodeType;
	
	-- Marque la fin de la partie
	signal Stop : std_logic := '0'; 
	
	-- Contient la séquence binaire du nbre de bonne(s) couleur(s) à afficher sur 7seg
	signal display : std_logic_vector (3 downto 0); -- := "0000";

	-- Contient la séquence binaire du nbre de vie à afficher sur 7seg
	signal display2 : std_logic_vector (3 downto 0);	
	
	-- Table de vérité pour le driver 7seg L7SN447 (ou 4511)
	type table10x4 is array(0 to 9, 0 to 3) of std_logic;
	constant segmentDisp: table10x4 := (
		"0000", -- 0
		"1000", -- 1
		"0100", -- 2
		"1100", -- 3
		"0010", -- 4
		"1010", -- 5
		"0110", -- 6 / bravo (b)
		"1110", -- 7
		"0001", -- 8
		"1001" -- 9
		);
		
	-- Sélection d'un seul signal par clk_Button
	signal bPressed1 			: std_logic := '0';
	signal bPressed2 			: std_logic := '0';
	signal bPressed3 			: std_logic := '0';
	signal bPressed4 			: std_logic := '0';
	signal bPressedValidate : std_logic := '0';
	-- Pas nécessaire pour RES

	begin -- arch
	
	
	-- First process : remet count à 0 quand arrive à 80
	countRand : process(clk_Rand, count)
	
	begin
		if rising_edge(clk_Rand) then
			case count is
				when 80 => count <= 0;
				when others => count <= count + 1;
			end case;
		end if;
	end process countRand;
		
	
	-- Second process : Génère le choix du joueur
	choice : process(clk_Button, Button1, Button2, Button3, Button4,
							RGB0_state, RGB1_state, RGB2_state, RGB3_state,
							ButtonRES, count, display, bPressed1, bPressed2,
							bPressed3, bPressed4)
	
	begin
		
		if (rising_edge(clk_Button)) then 
	
			if (ButtonRES = '1') then
				case count is
					when 0 	=> SecretCode <= (Red, Red, Red, Red);
					when 1 	=> SecretCode <= (Red, Red, Red, Green);
					when 2 	=> SecretCode <= (Red, Red, Red, Blue);
					when 3	=> SecretCode <= (Red, Red, Green, Red);
					when 4 	=> SecretCode <= (Red, Red, Green, Green);
					when 5 	=> SecretCode <= (Red, Red, Green, Blue);
					when 6 	=> SecretCode <= (Red, Red, Blue, Red);
					when 7 	=> SecretCode <= (Red, Red, Blue, Green);
					when 8 	=> SecretCode <= (Red, Red, Blue, Blue);
					when 9	=> SecretCode <= (Red, Green, Red, Red);
					when 10 	=> SecretCode <= (Red, Green, Red, Green);
					when 11 	=> SecretCode <= (Red, Green, Red, Blue);
					when 12 	=> SecretCode <= (Red, Green, Green, Red);
					when 13 	=> SecretCode <= (Red, Green, Green, Green);
					when 14 	=> SecretCode <= (Red, Green, Green, Blue);
					when 15 	=> SecretCode <= (Red, Green, Blue, Red);
					when 16 	=> SecretCode <= (Red, Green, Blue, Green);
					when 17 	=> SecretCode <= (Red, Green, Blue, Blue);
					when 18	=> SecretCode <= (Red, Blue, Red, Red);
					when 19	=> SecretCode <= (Red, Blue, Red, Green);
					when 20 	=> SecretCode <= (Red, Blue, Red, Blue);
					when 21 	=> SecretCode <= (Red, Blue, Green, Red);
					when 22 	=> SecretCode <= (Red, Blue, Green, Green);
					when 23 	=> SecretCode <= (Red, Blue, Green, Blue);
					when 24 	=> SecretCode <= (Red, Blue, Blue, Red);
					when 25	=> SecretCode <= (Red, Blue, Blue, Green);
					when 26 	=> SecretCode <= (Red, Blue, Blue, Blue);
					when 27 	=> SecretCode <= (Green, Red, Red, Red);
					when 28 	=> SecretCode <= (Green, Red, Red, Green);
					when 29 	=> SecretCode <= (Green, Red, Red, Blue);
					when 30 	=> SecretCode <= (Green, Red, Green, Red);
					when 31 	=> SecretCode <= (Green, Red, Green, Green);
					when 32	=> SecretCode <= (Green, Red, Green, Blue);
					when 33 	=> SecretCode <= (Green, Red, Blue, Red);
					when 34 	=> SecretCode <= (Green, Red, Blue, Green);
					when 35	=> SecretCode <= (Green, Red, Blue, Blue);
					when 36 	=> SecretCode <= (Green, Green, Red, Red);
					when 37 	=> SecretCode <= (Green, Green, Red, Green);
					when 38 	=> SecretCode <= (Green, Green, Red, Blue);
					when 39 	=> SecretCode <= (Green, Green, Green, Red);
					when 40 	=> SecretCode <= (Green, Green, Green, Green);
					when 41	=> SecretCode <= (Green, Green, Green, Blue);
					when 42 	=> SecretCode <= (Green, Green, Blue, Red);
					when 43 	=> SecretCode <= (Green, Green, Blue, Green);
					when 44 	=> SecretCode <= (Green, Green, Blue, Blue);
					when 45 	=> SecretCode <= (Green, Blue, Red, Red);
					when 46 	=> SecretCode <= (Green, Blue, Red, Green);
					when 47 	=> SecretCode <= (Green, Blue, Red, Blue);
					when 48 	=> SecretCode <= (Green, Blue, Green, Red);
					when 49 	=> SecretCode <= (Green, Blue, Green, Green);
					when 50 	=> SecretCode <= (Green, Blue, Green, Blue);
					when 51	=> SecretCode <= (Green, Blue, Blue, Red);
					when 52 	=> SecretCode <= (Green, Blue, Blue, Green);
					when 53 	=> SecretCode <= (Green, Blue, Blue, Blue);
					when 54 	=> SecretCode <= (Blue, Red, Red, Red);
					when 55 	=> SecretCode <= (Blue, Red, Red, Green);
					when 56 	=> SecretCode <= (Blue, Red, Red, Blue);
					when 57	=> SecretCode <= (Blue, Red, Green, Red);
					when 58 	=> SecretCode <= (Blue, Red, Green, Green);
					when 59 	=> SecretCode <= (Blue, Red, Green, Blue);
					when 60 	=> SecretCode <= (Blue, Red, Blue, Red);
					when 61 	=> SecretCode <= (Blue, Red, Blue, Green);
					when 62 	=> SecretCode <= (Blue, Red, Blue, Blue);
					when 63 	=> SecretCode <= (Blue, Green, Red, Red);
					when 64 	=> SecretCode <= (Blue, Green, Red, Green);
					when 65 	=> SecretCode <= (Blue, Green, Red, Blue);
					when 66 	=> SecretCode <= (Blue, Green, Green, Red);
					when 67	=> SecretCode <= (Blue, Green, Green, Green);
					when 68 	=> SecretCode <= (Blue, Green, Green, Blue);
					when 69 	=> SecretCode <= (Blue, Green, Blue, Red);
					when 70 	=> SecretCode <= (Blue, Green, Blue, Green);
					when 71 	=> SecretCode <= (Blue, Green, Blue, Blue);
					when 72 	=> SecretCode <= (Blue, Blue, Red, Red);
					when 73	=> SecretCode <= (Blue, Blue, Red, Green);
					when 74 	=> SecretCode <= (Blue, Blue, Red, Blue);
					when 75 	=> SecretCode <= (Blue, Blue, Green, Red);
					when 76 	=> SecretCode <= (Blue, Blue, Green, Green);
					when 77 	=> SecretCode <= (Blue, Blue, Green, Blue);
					when 78 	=> SecretCode <= (Blue, Blue, Blue, Red);
					when 79 	=> SecretCode <= (Blue, Blue, Blue, Green);
					when 80	=> SecretCode <= (Blue, Blue, Blue, Blue);

				end case;
			
				-- Par défaut tout sur rouge
				RGB0_state <= Red;
				RGB1_state <= Red;
				RGB2_state <= Red;
				RGB3_state <= Red;
			
			elsif Vie = 0 then
			
				RGB0_state <= SecretCode(0);
				RGB1_state <= SecretCode(1);
				RGB2_state <= SecretCode(2);
				RGB3_state <= SecretCode(3);
				
				-- Gestion de l'affichage
				Segment1a	<= display(0);
				Segment1b	<= display(1);
				Segment1c	<= display(2);
				Segment1d	<= display(3);
				
				-- Gestion de l'affichage
				Segment2a	<= '0';--display2(0);
				Segment2b	<= '0';--display2(1);
				Segment2c	<= '0';--display2(2);
				Segment2d	<= '0';--display2(3);
			
			elsif Stop = '1' and vie /= 0 then
				-- Rajouter display 6 ici si gagné !
				Segment1a	<= display(0);
				Segment1b	<= display(1);
				Segment1c	<= display(2);
				Segment1d	<= display(3);
			
			elsif Stop = '0' then -- Empêcher l'utilisateur de jouer quand il a gagné
				
				-- Colonne 1
				if Button1 = '1' then
					bPressed1 <= '1';
				end if;
				if (Button1 = '0' and bPressed1 = '1') then

					case RGB0_state is
						when Red 	=> RGB0_state <= Green;
						when Green => RGB0_state <= Blue;
						when Blue  => RGB0_state <= Red;
					end case;
					bPressed1 <= '0';
				end if;
				
				-- Colonne 2
				if Button2 = '1' then
					bPressed2 <= '1';
				end if;
				if (Button2 = '0' and bPressed2 = '1') then
				
					case RGB1_state is
						when Red 	=> RGB1_state <= Green;
						when Green	=> RGB1_state <= Blue;
						when Blue 	=> RGB1_state <= Red;
					end case;
					bPressed2 <= '0';
				end if;
				
				-- Colonne 3
				if Button3 = '1' then
					bPressed3 <= '1';
				end if;
				if (Button3 = '0' and bPressed3 = '1') then
				
					case RGB2_state is
						when Red	 	=> RGB2_state <= Green;
						when Green	=> RGB2_state <= Blue;
						when Blue 	=> RGB2_state <= Red;
					end case;
					bPressed3 <= '0';
				end if;
				
				-- Colonne 4
				if Button4 = '1' then
					bPressed4 <= '1';
				end if;
				if (Button4 = '0' and bPressed4 = '1') then
				
					case RGB3_state is
						when Red 	=> RGB3_state <= Green;
						when Green 	=> RGB3_state <= Blue;
						when Blue 	=> RGB3_state <= Red;
					end case;
					bPressed4 <= '0';
				end if;
		
				-- Gestion de l'affichage
				Segment1a	<= display(0);
				Segment1b	<= display(1);
				Segment1c	<= display(2);
				Segment1d	<= display(3);
				
				-- Gestion de l'affichage
				Segment2a	<= display2(0);
				Segment2b	<= display2(1);
				Segment2c	<= display2(2);
				Segment2d	<= display2(3);
			
			end if; -- end button RES not activated
			
			
		end if; -- rising_edge(clock)
		
		
		
	end process choice;

	
	
	-- Third process : Compte le nbre d'éléments justes, donne l'info sur le nombre à afficher sur 7seg 
	validation : process(clk_Button,ButtonValidate, SecretCode,
								RGB0_state, RGB1_state, RGB2_state, RGB3_state,
								ButtonRES, bPressedValidate)
	
	variable NbreCorrect : integer range 0 to 4;
	variable tmpVie : integer range 0 to 9;
	variable tmpDisplay : std_logic_vector (3 downto 0);
	variable tmpDisplay2 : std_logic_vector (3 downto 0);
	
	begin
	
		-- Analyse de la séquence entrée par l'utilisateur
		if (rising_edge(clk_Button)) then
			if (ButtonRES = '1') then
				Stop <= '0';
				tmpVie := 9;
				
				-- Remet le 7seg à "0000"
				for i in 0 to 3 loop
					tmpDisplay(i) := '0';
				end loop;
				
				-- Reset le 7seg à "1010"
				for i in 0 to 3 loop
					tmpDisplay2(i) := SegmentDisp(TmpVie, i);
				end loop;
		
				
			elsif Vie = 0 then -- empêche directement d'accéder aux conditions suivantes
				Stop <= '1';
				
		
			elsif(ButtonValidate = '1' and Stop = '0') then
				bPressedValidate <= '1';
			elsif(ButtonValidate = '0' and bPressedValidate = '1') then			
				bPressedValidate <= '0';
				
					tmpVie := Vie - 1;
					NbreCorrect := 0;
									
					-- Bouton validate verouillé une fois que l'on a terminé le jeu mais peux toujours changer couleur du mastermind
					if RGB0_state = SecretCode(0) then
						NbreCorrect := NbreCorrect + 1;
					end if;
		
					if RGB1_state = SecretCode(1) then
						NbreCorrect := NbreCorrect + 1;
					end if;
			
					if RGB2_state = SecretCode(2) then
						NbreCorrect := NbreCorrect + 1;
					end if;
		
					if RGB3_state = SecretCode(3) then
						NbreCorrect := NbreCorrect + 1;
					end if;
		
		
					for i in 0 to 3 loop
						tmpDisplay(i) := SegmentDisp(NbreCorrect, i);
					end loop;
				
					for i in 0 to 3 loop
						tmpDisplay2(i) := SegmentDisp(TmpVie, i);
					end loop;
					
					if NbreCorrect = 4 then -- Victoire et bloqué tant que appuie pas sur Reset
						Stop <= '1';
					
						--Display b pour "bravo"
						for i in 0 to 3 loop
							tmpDisplay(i) := SegmentDisp(6, i);
						end loop;
					
					end if;					
					
					
			end if; -- stop & ButtonValidate
		end if; -- clk_Button
		
		Vie <= TmpVie;
		display <= tmpDisplay;
		display2 <= tmpDisplay2;
	end process validation;
	
	
	-- last process (implicit) : compute RGB pins output
	
	RGB0_red 	<= '1' when RGB0_state = Red 		else '0';
	RGB0_green 	<= '1' when RGB0_state = Green 	else '0';
	RGB0_blue 	<= '1' when RGB0_state = Blue 	else '0';
	
	RGB1_red 	<= '1' when RGB1_state = Red 		else '0';
	RGB1_green 	<= '1' when RGB1_state = Green 	else '0';
	RGB1_blue 	<= '1' when RGB1_state = Blue 	else '0';
	
	RGB2_red 	<= '1' when RGB2_state = Red 		else '0';
	RGB2_green 	<= '1' when RGB2_state = Green 	else '0';
	RGB2_blue 	<= '1' when RGB2_state = Blue 	else '0';
	
	RGB3_red 	<= '1' when RGB3_state = Red 		else '0';
	RGB3_green 	<= '1' when RGB3_state = Green 	else '0';
	RGB3_blue 	<= '1' when RGB3_state = Blue 	else '0';
	
	
end architecture Mastermind_arch;

