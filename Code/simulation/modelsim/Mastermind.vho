-- Copyright (C) 2016  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel MegaCore Function License Agreement, or other 
-- applicable license agreement, including, without limitation, 
-- that your use is for the sole purpose of programming logic 
-- devices manufactured by Intel and sold by Intel or its 
-- authorized distributors.  Please refer to the applicable 
-- agreement for further details.

-- VENDOR "Altera"
-- PROGRAM "Quartus Prime"
-- VERSION "Version 16.1.0 Build 196 10/24/2016 SJ Lite Edition"

-- DATE "05/21/2017 13:04:06"

-- 
-- Device: Altera 5M160ZE64C5 Package EQFP64
-- 

-- 
-- This VHDL file should be used for ModelSim-Altera (VHDL) only
-- 

LIBRARY IEEE;
LIBRARY MAXV;
USE IEEE.STD_LOGIC_1164.ALL;
USE MAXV.MAXV_COMPONENTS.ALL;

ENTITY 	Mastermind IS
    PORT (
	clk_Rand : IN std_logic;
	clk_Button : IN std_logic;
	Button1 : IN std_logic;
	Button2 : IN std_logic;
	Button3 : IN std_logic;
	Button4 : IN std_logic;
	ButtonValidate : IN std_logic;
	ButtonRES : IN std_logic;
	RGB0_red : BUFFER std_logic;
	RGB0_green : BUFFER std_logic;
	RGB0_blue : BUFFER std_logic;
	RGB1_red : BUFFER std_logic;
	RGB1_green : BUFFER std_logic;
	RGB1_blue : BUFFER std_logic;
	RGB2_red : BUFFER std_logic;
	RGB2_green : BUFFER std_logic;
	RGB2_blue : BUFFER std_logic;
	RGB3_red : BUFFER std_logic;
	RGB3_green : BUFFER std_logic;
	RGB3_blue : BUFFER std_logic;
	Segment1a : BUFFER std_logic;
	Segment1b : BUFFER std_logic;
	Segment1c : BUFFER std_logic;
	Segment1d : BUFFER std_logic;
	Segment2a : BUFFER std_logic;
	Segment2b : BUFFER std_logic;
	Segment2c : BUFFER std_logic;
	Segment2d : BUFFER std_logic
	);
END Mastermind;

-- Design Ports Information


ARCHITECTURE structure OF Mastermind IS
SIGNAL gnd : std_logic := '0';
SIGNAL vcc : std_logic := '1';
SIGNAL unknown : std_logic := 'X';
SIGNAL devoe : std_logic := '1';
SIGNAL devclrn : std_logic := '1';
SIGNAL devpor : std_logic := '1';
SIGNAL ww_devoe : std_logic;
SIGNAL ww_devclrn : std_logic;
SIGNAL ww_devpor : std_logic;
SIGNAL ww_clk_Rand : std_logic;
SIGNAL ww_clk_Button : std_logic;
SIGNAL ww_Button1 : std_logic;
SIGNAL ww_Button2 : std_logic;
SIGNAL ww_Button3 : std_logic;
SIGNAL ww_Button4 : std_logic;
SIGNAL ww_ButtonValidate : std_logic;
SIGNAL ww_ButtonRES : std_logic;
SIGNAL ww_RGB0_red : std_logic;
SIGNAL ww_RGB0_green : std_logic;
SIGNAL ww_RGB0_blue : std_logic;
SIGNAL ww_RGB1_red : std_logic;
SIGNAL ww_RGB1_green : std_logic;
SIGNAL ww_RGB1_blue : std_logic;
SIGNAL ww_RGB2_red : std_logic;
SIGNAL ww_RGB2_green : std_logic;
SIGNAL ww_RGB2_blue : std_logic;
SIGNAL ww_RGB3_red : std_logic;
SIGNAL ww_RGB3_green : std_logic;
SIGNAL ww_RGB3_blue : std_logic;
SIGNAL ww_Segment1a : std_logic;
SIGNAL ww_Segment1b : std_logic;
SIGNAL ww_Segment1c : std_logic;
SIGNAL ww_Segment1d : std_logic;
SIGNAL ww_Segment2a : std_logic;
SIGNAL ww_Segment2b : std_logic;
SIGNAL ww_Segment2c : std_logic;
SIGNAL ww_Segment2d : std_logic;
SIGNAL \bPressed1~regout\ : std_logic;
SIGNAL \bPressed2~regout\ : std_logic;
SIGNAL \bPressed3~regout\ : std_logic;
SIGNAL \bPressed4~regout\ : std_logic;
SIGNAL \clk_Button~combout\ : std_logic;
SIGNAL \clk_Rand~combout\ : std_logic;
SIGNAL \Add0~25_combout\ : std_logic;
SIGNAL \Add0~27\ : std_logic;
SIGNAL \Add0~27COUT1_36\ : std_logic;
SIGNAL \Add0~32COUT1_37\ : std_logic;
SIGNAL \Add0~22\ : std_logic;
SIGNAL \Add0~22COUT1_38\ : std_logic;
SIGNAL \Add0~15_combout\ : std_logic;
SIGNAL \SecretCode~41_combout\ : std_logic;
SIGNAL \Add0~17\ : std_logic;
SIGNAL \Add0~10_combout\ : std_logic;
SIGNAL \Add0~12\ : std_logic;
SIGNAL \Add0~12COUT1_39\ : std_logic;
SIGNAL \Add0~2\ : std_logic;
SIGNAL \Add0~2COUT1_40\ : std_logic;
SIGNAL \Add0~5_combout\ : std_logic;
SIGNAL \Mux0~0_combout\ : std_logic;
SIGNAL \SecretCode~72\ : std_logic;
SIGNAL \Add0~30_combout\ : std_logic;
SIGNAL \Add0~0_combout\ : std_logic;
SIGNAL \SecretCode~71\ : std_logic;
SIGNAL \Add0~32\ : std_logic;
SIGNAL \Add0~20_combout\ : std_logic;
SIGNAL \SecretCode~34_combout\ : std_logic;
SIGNAL \ButtonRES~combout\ : std_logic;
SIGNAL \SecretCode[0].Red~regout\ : std_logic;
SIGNAL \ButtonValidate~combout\ : std_logic;
SIGNAL \Mux8~0_combout\ : std_logic;
SIGNAL \SecretCode[0].Green~regout\ : std_logic;
SIGNAL \Mux9~0_combout\ : std_logic;
SIGNAL \SecretCode[0].Blue~regout\ : std_logic;
SIGNAL \Button1~combout\ : std_logic;
SIGNAL \bPressedValidate~1_combout\ : std_logic;
SIGNAL \RGB0_state~8\ : std_logic;
SIGNAL \RGB0_state~11_combout\ : std_logic;
SIGNAL \RGB0_state.Green~regout\ : std_logic;
SIGNAL \RGB0_state~13_combout\ : std_logic;
SIGNAL \RGB0_state.Blue~regout\ : std_logic;
SIGNAL \WideNor0~0_combout\ : std_logic;
SIGNAL \WideNor0~combout\ : std_logic;
SIGNAL \SecretCode~75_combout\ : std_logic;
SIGNAL \SecretCode~83_combout\ : std_logic;
SIGNAL \SecretCode~84_combout\ : std_logic;
SIGNAL \SecretCode~79_combout\ : std_logic;
SIGNAL \SecretCode~85_combout\ : std_logic;
SIGNAL \SecretCode~86_combout\ : std_logic;
SIGNAL \SecretCode~73\ : std_logic;
SIGNAL \SecretCode~74_combout\ : std_logic;
SIGNAL \SecretCode[3].Green~regout\ : std_logic;
SIGNAL \Button4~combout\ : std_logic;
SIGNAL \bPressedValidate~0_combout\ : std_logic;
SIGNAL \RGB3_state~9\ : std_logic;
SIGNAL \RGB3_state.Green~regout\ : std_logic;
SIGNAL \SecretCode~80_combout\ : std_logic;
SIGNAL \SecretCode~87_combout\ : std_logic;
SIGNAL \SecretCode~76_combout\ : std_logic;
SIGNAL \SecretCode~77_combout\ : std_logic;
SIGNAL \SecretCode[3].Blue~regout\ : std_logic;
SIGNAL \RGB3_state.Blue~regout\ : std_logic;
SIGNAL \SecretCode~81_combout\ : std_logic;
SIGNAL \SecretCode~78_combout\ : std_logic;
SIGNAL \SecretCode[3].Red~regout\ : std_logic;
SIGNAL \RGB3_state.Red~regout\ : std_logic;
SIGNAL \WideNor3~0_combout\ : std_logic;
SIGNAL \WideNor3~combout\ : std_logic;
SIGNAL \SecretCode~42_combout\ : std_logic;
SIGNAL \SecretCode~39_combout\ : std_logic;
SIGNAL \SecretCode~37_combout\ : std_logic;
SIGNAL \SecretCode~38_combout\ : std_logic;
SIGNAL \SecretCode~36_combout\ : std_logic;
SIGNAL \SecretCode~40_combout\ : std_logic;
SIGNAL \SecretCode[1].Red~regout\ : std_logic;
SIGNAL \SecretCode~44_combout\ : std_logic;
SIGNAL \SecretCode~47_combout\ : std_logic;
SIGNAL \SecretCode~48_combout\ : std_logic;
SIGNAL \SecretCode~45_combout\ : std_logic;
SIGNAL \SecretCode~46_combout\ : std_logic;
SIGNAL \SecretCode[1].Green~regout\ : std_logic;
SIGNAL \Button2~combout\ : std_logic;
SIGNAL \RGB1_state~9\ : std_logic;
SIGNAL \RGB1_state.Green~regout\ : std_logic;
SIGNAL \SecretCode~53_combout\ : std_logic;
SIGNAL \SecretCode~49_combout\ : std_logic;
SIGNAL \SecretCode~50_combout\ : std_logic;
SIGNAL \SecretCode~51_combout\ : std_logic;
SIGNAL \SecretCode~52_combout\ : std_logic;
SIGNAL \SecretCode[1].Blue~regout\ : std_logic;
SIGNAL \RGB1_state.Blue~regout\ : std_logic;
SIGNAL \RGB1_state.Red~regout\ : std_logic;
SIGNAL \WideNor1~0_combout\ : std_logic;
SIGNAL \WideNor1~combout\ : std_logic;
SIGNAL \SecretCode~57_combout\ : std_logic;
SIGNAL \SecretCode~59_combout\ : std_logic;
SIGNAL \SecretCode~58_combout\ : std_logic;
SIGNAL \SecretCode~60_combout\ : std_logic;
SIGNAL \SecretCode~55_combout\ : std_logic;
SIGNAL \SecretCode~56_combout\ : std_logic;
SIGNAL \SecretCode[2].Red~regout\ : std_logic;
SIGNAL \SecretCode~66_combout\ : std_logic;
SIGNAL \SecretCode~67_combout\ : std_logic;
SIGNAL \SecretCode~69_combout\ : std_logic;
SIGNAL \SecretCode~68_combout\ : std_logic;
SIGNAL \SecretCode~70_combout\ : std_logic;
SIGNAL \SecretCode~64_combout\ : std_logic;
SIGNAL \SecretCode~65_combout\ : std_logic;
SIGNAL \SecretCode[2].Blue~regout\ : std_logic;
SIGNAL \SecretCode~61_combout\ : std_logic;
SIGNAL \SecretCode~62_combout\ : std_logic;
SIGNAL \SecretCode~63_combout\ : std_logic;
SIGNAL \SecretCode~88\ : std_logic;
SIGNAL \SecretCode~89_combout\ : std_logic;
SIGNAL \SecretCode[2].Green~regout\ : std_logic;
SIGNAL \Button3~combout\ : std_logic;
SIGNAL \RGB2_state~9\ : std_logic;
SIGNAL \RGB2_state.Green~regout\ : std_logic;
SIGNAL \RGB2_state.Blue~regout\ : std_logic;
SIGNAL \RGB2_state.Red~regout\ : std_logic;
SIGNAL \WideNor2~0_combout\ : std_logic;
SIGNAL \WideNor2~combout\ : std_logic;
SIGNAL \NbreCorrect~0_combout\ : std_logic;
SIGNAL \Stop~3_combout\ : std_logic;
SIGNAL \Stop~regout\ : std_logic;
SIGNAL \bPressedValidate~regout\ : std_logic;
SIGNAL \Stop~2_combout\ : std_logic;
SIGNAL \validation:tmpDisplay2[0]~regout\ : std_logic;
SIGNAL \validation:tmpDisplay2[1]~0_combout\ : std_logic;
SIGNAL \validation:tmpDisplay2[1]~regout\ : std_logic;
SIGNAL \Add1~0_combout\ : std_logic;
SIGNAL \validation:tmpDisplay2[2]~regout\ : std_logic;
SIGNAL \Equal0~1_combout\ : std_logic;
SIGNAL \validation:tmpDisplay2[3]~regout\ : std_logic;
SIGNAL \Equal0~0_combout\ : std_logic;
SIGNAL \RGB0_state~9_combout\ : std_logic;
SIGNAL \RGB0_state.Red~regout\ : std_logic;
SIGNAL \tmpDisplay~0_combout\ : std_logic;
SIGNAL \validation:tmpDisplay[0]~regout\ : std_logic;
SIGNAL \Segment1a~reg0_regout\ : std_logic;
SIGNAL \tmpDisplay~2_combout\ : std_logic;
SIGNAL \validation:tmpDisplay[1]~regout\ : std_logic;
SIGNAL \Segment1b~reg0_regout\ : std_logic;
SIGNAL \validation:tmpDisplay[2]~regout\ : std_logic;
SIGNAL \Segment1c~reg0_regout\ : std_logic;
SIGNAL \Segment2a~0_combout\ : std_logic;
SIGNAL \Segment2a~reg0_regout\ : std_logic;
SIGNAL \Segment2b~reg0_regout\ : std_logic;
SIGNAL \Segment2c~reg0_regout\ : std_logic;
SIGNAL \Segment2d~reg0_regout\ : std_logic;
SIGNAL count : std_logic_vector(6 DOWNTO 0);
SIGNAL \ALT_INV_ButtonRES~combout\ : std_logic;
SIGNAL \ALT_INV_RGB3_state.Red~regout\ : std_logic;
SIGNAL \ALT_INV_RGB2_state.Red~regout\ : std_logic;
SIGNAL \ALT_INV_RGB1_state.Red~regout\ : std_logic;
SIGNAL \ALT_INV_RGB0_state.Red~regout\ : std_logic;

BEGIN

ww_clk_Rand <= clk_Rand;
ww_clk_Button <= clk_Button;
ww_Button1 <= Button1;
ww_Button2 <= Button2;
ww_Button3 <= Button3;
ww_Button4 <= Button4;
ww_ButtonValidate <= ButtonValidate;
ww_ButtonRES <= ButtonRES;
RGB0_red <= ww_RGB0_red;
RGB0_green <= ww_RGB0_green;
RGB0_blue <= ww_RGB0_blue;
RGB1_red <= ww_RGB1_red;
RGB1_green <= ww_RGB1_green;
RGB1_blue <= ww_RGB1_blue;
RGB2_red <= ww_RGB2_red;
RGB2_green <= ww_RGB2_green;
RGB2_blue <= ww_RGB2_blue;
RGB3_red <= ww_RGB3_red;
RGB3_green <= ww_RGB3_green;
RGB3_blue <= ww_RGB3_blue;
Segment1a <= ww_Segment1a;
Segment1b <= ww_Segment1b;
Segment1c <= ww_Segment1c;
Segment1d <= ww_Segment1d;
Segment2a <= ww_Segment2a;
Segment2b <= ww_Segment2b;
Segment2c <= ww_Segment2c;
Segment2d <= ww_Segment2d;
ww_devoe <= devoe;
ww_devclrn <= devclrn;
ww_devpor <= devpor;
\ALT_INV_ButtonRES~combout\ <= NOT \ButtonRES~combout\;
\ALT_INV_RGB3_state.Red~regout\ <= NOT \RGB3_state.Red~regout\;
\ALT_INV_RGB2_state.Red~regout\ <= NOT \RGB2_state.Red~regout\;
\ALT_INV_RGB1_state.Red~regout\ <= NOT \RGB1_state.Red~regout\;
\ALT_INV_RGB0_state.Red~regout\ <= NOT \RGB0_state.Red~regout\;

-- Location: PIN_7,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: Default
\clk_Button~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "input")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_clk_Button,
	combout => \clk_Button~combout\);

-- Location: PIN_9,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: Default
\clk_Rand~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "input")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_clk_Rand,
	combout => \clk_Rand~combout\);

-- Location: LC_X6_Y3_N1
\Add0~25\ : maxv_lcell
-- Equation(s):
-- \Add0~25_combout\ = ((!count(0)))
-- \Add0~27\ = CARRY(((count(0))))
-- \Add0~27COUT1_36\ = CARRY(((count(0))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "33cc",
	operation_mode => "arithmetic",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datab => count(0),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Add0~25_combout\,
	cout0 => \Add0~27\,
	cout1 => \Add0~27COUT1_36\);

-- Location: LC_X6_Y3_N2
\Add0~30\ : maxv_lcell
-- Equation(s):
-- \Add0~30_combout\ = count(1) $ ((((\Add0~27\))))
-- \Add0~32\ = CARRY(((!\Add0~27\)) # (!count(1)))
-- \Add0~32COUT1_37\ = CARRY(((!\Add0~27COUT1_36\)) # (!count(1)))

-- pragma translate_off
GENERIC MAP (
	cin0_used => "true",
	cin1_used => "true",
	lut_mask => "5a5f",
	operation_mode => "arithmetic",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(1),
	cin0 => \Add0~27\,
	cin1 => \Add0~27COUT1_36\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Add0~30_combout\,
	cout0 => \Add0~32\,
	cout1 => \Add0~32COUT1_37\);

-- Location: LC_X6_Y3_N3
\Add0~20\ : maxv_lcell
-- Equation(s):
-- \Add0~20_combout\ = (count(2) $ ((!\Add0~32\)))
-- \Add0~22\ = CARRY(((count(2) & !\Add0~32\)))
-- \Add0~22COUT1_38\ = CARRY(((count(2) & !\Add0~32COUT1_37\)))

-- pragma translate_off
GENERIC MAP (
	cin0_used => "true",
	cin1_used => "true",
	lut_mask => "c30c",
	operation_mode => "arithmetic",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datab => count(2),
	cin0 => \Add0~32\,
	cin1 => \Add0~32COUT1_37\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Add0~20_combout\,
	cout0 => \Add0~22\,
	cout1 => \Add0~22COUT1_38\);

-- Location: LC_X6_Y3_N4
\Add0~15\ : maxv_lcell
-- Equation(s):
-- \Add0~15_combout\ = (count(3) $ ((\Add0~22\)))
-- \Add0~17\ = CARRY(((!\Add0~22COUT1_38\) # (!count(3))))

-- pragma translate_off
GENERIC MAP (
	cin0_used => "true",
	cin1_used => "true",
	lut_mask => "3c3f",
	operation_mode => "arithmetic",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datab => count(3),
	cin0 => \Add0~22\,
	cin1 => \Add0~22COUT1_38\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Add0~15_combout\,
	cout => \Add0~17\);

-- Location: LC_X6_Y3_N9
\count[3]\ : maxv_lcell
-- Equation(s):
-- \SecretCode~88\ = (count(2) & ((count(0) & (!count[3] & count(5))) # (!count(0) & (count[3] & !count(5))))) # (!count(2) & (count(5) $ (((count(0) & !count[3])))))
-- count(3) = DFFEAS(\SecretCode~88\, GLOBAL(\clk_Rand~combout\), VCC, , , \Add0~15_combout\, , , VCC)

-- pragma translate_off
GENERIC MAP (
	lut_mask => "3942",
	operation_mode => "normal",
	output_mode => "reg_and_comb",
	register_cascade_mode => "off",
	sum_lutc_input => "qfbk",
	synch_mode => "on")
-- pragma translate_on
PORT MAP (
	clk => \clk_Rand~combout\,
	dataa => count(0),
	datab => count(2),
	datac => \Add0~15_combout\,
	datad => count(5),
	aclr => GND,
	sload => VCC,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~88\,
	regout => count(3));

-- Location: LC_X6_Y1_N5
\SecretCode~41\ : maxv_lcell
-- Equation(s):
-- \SecretCode~41_combout\ = ((!count(2) & (!count(5) & !count(1))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0003",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datab => count(2),
	datac => count(5),
	datad => count(1),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~41_combout\);

-- Location: LC_X6_Y3_N5
\Add0~10\ : maxv_lcell
-- Equation(s):
-- \Add0~10_combout\ = (count(4) $ ((!\Add0~17\)))
-- \Add0~12\ = CARRY(((count(4) & !\Add0~17\)))
-- \Add0~12COUT1_39\ = CARRY(((count(4) & !\Add0~17\)))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "c30c",
	operation_mode => "arithmetic",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datab => count(4),
	cin => \Add0~17\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Add0~10_combout\,
	cout0 => \Add0~12\,
	cout1 => \Add0~12COUT1_39\);

-- Location: LC_X6_Y3_N0
\count[4]\ : maxv_lcell
-- Equation(s):
-- count(4) = DFFEAS((\Add0~10_combout\ & ((count(3)) # ((!\Mux0~0_combout\) # (!\SecretCode~41_combout\)))), GLOBAL(\clk_Rand~combout\), VCC, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "b0f0",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Rand~combout\,
	dataa => count(3),
	datab => \SecretCode~41_combout\,
	datac => \Add0~10_combout\,
	datad => \Mux0~0_combout\,
	aclr => GND,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => count(4));

-- Location: LC_X6_Y3_N6
\Add0~0\ : maxv_lcell
-- Equation(s):
-- \Add0~0_combout\ = (count(5) $ (((!\Add0~17\ & \Add0~12\) # (\Add0~17\ & \Add0~12COUT1_39\))))
-- \Add0~2\ = CARRY(((!\Add0~12\) # (!count(5))))
-- \Add0~2COUT1_40\ = CARRY(((!\Add0~12COUT1_39\) # (!count(5))))

-- pragma translate_off
GENERIC MAP (
	cin0_used => "true",
	cin1_used => "true",
	cin_used => "true",
	lut_mask => "3c3f",
	operation_mode => "arithmetic",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datab => count(5),
	cin => \Add0~17\,
	cin0 => \Add0~12\,
	cin1 => \Add0~12COUT1_39\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Add0~0_combout\,
	cout0 => \Add0~2\,
	cout1 => \Add0~2COUT1_40\);

-- Location: LC_X6_Y3_N7
\Add0~5\ : maxv_lcell
-- Equation(s):
-- \Add0~5_combout\ = (((!\Add0~17\ & \Add0~2\) # (\Add0~17\ & \Add0~2COUT1_40\) $ (!count(6))))

-- pragma translate_off
GENERIC MAP (
	cin0_used => "true",
	cin1_used => "true",
	cin_used => "true",
	lut_mask => "f00f",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datad => count(6),
	cin => \Add0~17\,
	cin0 => \Add0~2\,
	cin1 => \Add0~2COUT1_40\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Add0~5_combout\);

-- Location: LC_X6_Y3_N8
\count[6]\ : maxv_lcell
-- Equation(s):
-- count(6) = DFFEAS((\Add0~5_combout\ & ((count(3)) # ((!\Mux0~0_combout\) # (!\SecretCode~41_combout\)))), GLOBAL(\clk_Rand~combout\), VCC, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "bf00",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Rand~combout\,
	dataa => count(3),
	datab => \SecretCode~41_combout\,
	datac => \Mux0~0_combout\,
	datad => \Add0~5_combout\,
	aclr => GND,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => count(6));

-- Location: LC_X6_Y2_N8
\Mux0~0\ : maxv_lcell
-- Equation(s):
-- \Mux0~0_combout\ = (count(4) & (((!count(0) & count(6)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0a00",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(4),
	datac => count(0),
	datad => count(6),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Mux0~0_combout\);

-- Location: LC_X5_Y3_N6
\count[0]\ : maxv_lcell
-- Equation(s):
-- count(0) = DFFEAS((\Add0~25_combout\ & ((count(3)) # ((!\Mux0~0_combout\) # (!\SecretCode~41_combout\)))), GLOBAL(\clk_Rand~combout\), VCC, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8aaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Rand~combout\,
	dataa => \Add0~25_combout\,
	datab => count(3),
	datac => \SecretCode~41_combout\,
	datad => \Mux0~0_combout\,
	aclr => GND,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => count(0));

-- Location: LC_X5_Y3_N7
\count[2]\ : maxv_lcell
-- Equation(s):
-- \SecretCode~72\ = ((count(5) & (count[2] & count(0))) # (!count(5) & (count[2] $ (count(0)))))
-- count(2) = DFFEAS(\SecretCode~72\, GLOBAL(\clk_Rand~combout\), VCC, , , \Add0~20_combout\, , , VCC)

-- pragma translate_off
GENERIC MAP (
	lut_mask => "c330",
	operation_mode => "normal",
	output_mode => "reg_and_comb",
	register_cascade_mode => "off",
	sum_lutc_input => "qfbk",
	synch_mode => "on")
-- pragma translate_on
PORT MAP (
	clk => \clk_Rand~combout\,
	datab => count(5),
	datac => \Add0~20_combout\,
	datad => count(0),
	aclr => GND,
	sload => VCC,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~72\,
	regout => count(2));

-- Location: LC_X5_Y3_N8
\count[5]\ : maxv_lcell
-- Equation(s):
-- \SecretCode~71\ = ((count(2) & ((count[5]) # (!count(0)))) # (!count(2) & ((count(0)) # (!count[5]))))
-- count(5) = DFFEAS(\SecretCode~71\, GLOBAL(\clk_Rand~combout\), VCC, , , \Add0~0_combout\, , , VCC)

-- pragma translate_off
GENERIC MAP (
	lut_mask => "f3cf",
	operation_mode => "normal",
	output_mode => "reg_and_comb",
	register_cascade_mode => "off",
	sum_lutc_input => "qfbk",
	synch_mode => "on")
-- pragma translate_on
PORT MAP (
	clk => \clk_Rand~combout\,
	datab => count(2),
	datac => \Add0~0_combout\,
	datad => count(0),
	aclr => GND,
	sload => VCC,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~71\,
	regout => count(5));

-- Location: LC_X5_Y3_N0
\count[1]\ : maxv_lcell
-- Equation(s):
-- \SecretCode~73\ = (count(6) & (((count[1])))) # (!count(6) & ((count[1] & ((!\SecretCode~71\))) # (!count[1] & (\SecretCode~72\))))
-- count(1) = DFFEAS(\SecretCode~73\, GLOBAL(\clk_Rand~combout\), VCC, , , \Add0~30_combout\, , , VCC)

-- pragma translate_off
GENERIC MAP (
	lut_mask => "c2f2",
	operation_mode => "normal",
	output_mode => "reg_and_comb",
	register_cascade_mode => "off",
	sum_lutc_input => "qfbk",
	synch_mode => "on")
-- pragma translate_on
PORT MAP (
	clk => \clk_Rand~combout\,
	dataa => \SecretCode~72\,
	datab => count(6),
	datac => \Add0~30_combout\,
	datad => \SecretCode~71\,
	aclr => GND,
	sload => VCC,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~73\,
	regout => count(1));

-- Location: LC_X6_Y1_N7
\SecretCode~34\ : maxv_lcell
-- Equation(s):
-- \SecretCode~34_combout\ = (count(3) & ((count(2)) # ((count(0) & count(1)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "c888",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(2),
	datab => count(3),
	datac => count(0),
	datad => count(1),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~34_combout\);

-- Location: PIN_44,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: Default
\ButtonRES~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "input")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_ButtonRES,
	combout => \ButtonRES~combout\);

-- Location: LC_X5_Y1_N6
\SecretCode[0].Red\ : maxv_lcell
-- Equation(s):
-- \SecretCode[0].Red~regout\ = DFFEAS((count(5)) # ((count(6)) # ((count(4) & \SecretCode~34_combout\))), GLOBAL(\clk_Button~combout\), VCC, , \ButtonRES~combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "fefa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => count(5),
	datab => count(4),
	datac => count(6),
	datad => \SecretCode~34_combout\,
	aclr => GND,
	ena => \ButtonRES~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \SecretCode[0].Red~regout\);

-- Location: PIN_45,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: Default
\ButtonValidate~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "input")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_ButtonValidate,
	combout => \ButtonValidate~combout\);

-- Location: LC_X6_Y1_N6
\Mux8~0\ : maxv_lcell
-- Equation(s):
-- \Mux8~0_combout\ = (count(1) & ((count(2)) # ((!count(5) & count(0))))) # (!count(1) & (count(2) & (!count(5))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8e8c",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(1),
	datab => count(2),
	datac => count(5),
	datad => count(0),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Mux8~0_combout\);

-- Location: LC_X5_Y1_N5
\SecretCode[0].Green\ : maxv_lcell
-- Equation(s):
-- \SecretCode[0].Green~regout\ = DFFEAS((count(4) & ((count(5) & (!\Mux8~0_combout\ & !count(3))) # (!count(5) & (\Mux8~0_combout\ & count(3))))) # (!count(4) & (count(5))), GLOBAL(\clk_Button~combout\), VCC, , \ButtonRES~combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "644c",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => count(4),
	datab => count(5),
	datac => \Mux8~0_combout\,
	datad => count(3),
	aclr => GND,
	ena => \ButtonRES~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \SecretCode[0].Green~regout\);

-- Location: LC_X6_Y1_N3
\Mux9~0\ : maxv_lcell
-- Equation(s):
-- \Mux9~0_combout\ = (count(4) & ((count(3)) # ((count(1) & count(2)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "cc80",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(1),
	datab => count(4),
	datac => count(2),
	datad => count(3),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Mux9~0_combout\);

-- Location: LC_X5_Y1_N0
\SecretCode[0].Blue\ : maxv_lcell
-- Equation(s):
-- \SecretCode[0].Blue~regout\ = DFFEAS(((count(6)) # ((count(5) & \Mux9~0_combout\))), GLOBAL(\clk_Button~combout\), VCC, , \ButtonRES~combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "ffa0",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => count(5),
	datac => \Mux9~0_combout\,
	datad => count(6),
	aclr => GND,
	ena => \ButtonRES~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \SecretCode[0].Blue~regout\);

-- Location: PIN_46,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: Default
\Button1~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "input")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_Button1,
	combout => \Button1~combout\);

-- Location: LC_X3_Y2_N4
\bPressedValidate~1\ : maxv_lcell
-- Equation(s):
-- \bPressedValidate~1_combout\ = (!\ButtonRES~combout\ & (((!\Equal0~0_combout\ & !\Stop~regout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0005",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ButtonRES~combout\,
	datac => \Equal0~0_combout\,
	datad => \Stop~regout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \bPressedValidate~1_combout\);

-- Location: LC_X3_Y2_N5
bPressed1 : maxv_lcell
-- Equation(s):
-- \RGB0_state~8\ = (\Button1~combout\) # (((\Stop~regout\) # (!bPressed1)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "ffaf",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "qfbk",
	synch_mode => "on")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => \Button1~combout\,
	datac => \Button1~combout\,
	datad => \Stop~regout\,
	aclr => GND,
	sload => VCC,
	ena => \bPressedValidate~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \RGB0_state~8\,
	regout => \bPressed1~regout\);

-- Location: LC_X4_Y1_N7
\RGB0_state~11\ : maxv_lcell
-- Equation(s):
-- \RGB0_state~11_combout\ = ((\RGB0_state~8\ & ((\RGB0_state.Green~regout\))) # (!\RGB0_state~8\ & (!\RGB0_state.Red~regout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "f055",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \RGB0_state.Red~regout\,
	datac => \RGB0_state.Green~regout\,
	datad => \RGB0_state~8\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \RGB0_state~11_combout\);

-- Location: LC_X5_Y1_N2
\RGB0_state.Green\ : maxv_lcell
-- Equation(s):
-- \RGB0_state.Green~regout\ = DFFEAS((!\ButtonRES~combout\ & ((\Equal0~0_combout\ & (\SecretCode[0].Green~regout\)) # (!\Equal0~0_combout\ & ((\RGB0_state~11_combout\))))), GLOBAL(\clk_Button~combout\), VCC, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "2320",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => \SecretCode[0].Green~regout\,
	datab => \ButtonRES~combout\,
	datac => \Equal0~0_combout\,
	datad => \RGB0_state~11_combout\,
	aclr => GND,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \RGB0_state.Green~regout\);

-- Location: LC_X4_Y1_N0
\RGB0_state~13\ : maxv_lcell
-- Equation(s):
-- \RGB0_state~13_combout\ = ((\RGB0_state~8\ & ((\RGB0_state.Blue~regout\))) # (!\RGB0_state~8\ & (\RGB0_state.Green~regout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "f0aa",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \RGB0_state.Green~regout\,
	datac => \RGB0_state.Blue~regout\,
	datad => \RGB0_state~8\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \RGB0_state~13_combout\);

-- Location: LC_X5_Y1_N9
\RGB0_state.Blue\ : maxv_lcell
-- Equation(s):
-- \RGB0_state.Blue~regout\ = DFFEAS((!\ButtonRES~combout\ & ((\Equal0~0_combout\ & (\SecretCode[0].Blue~regout\)) # (!\Equal0~0_combout\ & ((\RGB0_state~13_combout\))))), GLOBAL(\clk_Button~combout\), VCC, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "2320",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => \SecretCode[0].Blue~regout\,
	datab => \ButtonRES~combout\,
	datac => \Equal0~0_combout\,
	datad => \RGB0_state~13_combout\,
	aclr => GND,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \RGB0_state.Blue~regout\);

-- Location: LC_X5_Y1_N3
\WideNor0~0\ : maxv_lcell
-- Equation(s):
-- \WideNor0~0_combout\ = (\SecretCode[0].Green~regout\ & (\RGB0_state.Green~regout\ & (\RGB0_state.Blue~regout\ $ (!\SecretCode[0].Blue~regout\)))) # (!\SecretCode[0].Green~regout\ & (!\RGB0_state.Green~regout\ & (\RGB0_state.Blue~regout\ $ 
-- (!\SecretCode[0].Blue~regout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8241",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \SecretCode[0].Green~regout\,
	datab => \RGB0_state.Blue~regout\,
	datac => \SecretCode[0].Blue~regout\,
	datad => \RGB0_state.Green~regout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \WideNor0~0_combout\);

-- Location: LC_X5_Y1_N1
WideNor0 : maxv_lcell
-- Equation(s):
-- \WideNor0~combout\ = ((\WideNor0~0_combout\ & (\RGB0_state.Red~regout\ $ (!\SecretCode[0].Red~regout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "c300",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datab => \RGB0_state.Red~regout\,
	datac => \SecretCode[0].Red~regout\,
	datad => \WideNor0~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \WideNor0~combout\);

-- Location: LC_X5_Y3_N5
\SecretCode~75\ : maxv_lcell
-- Equation(s):
-- \SecretCode~75_combout\ = ((count(2) & (!count(0) & count(5))) # (!count(2) & (count(0) $ (!count(5)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "3c03",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datab => count(2),
	datac => count(0),
	datad => count(5),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~75_combout\);

-- Location: LC_X5_Y3_N3
\SecretCode~83\ : maxv_lcell
-- Equation(s):
-- \SecretCode~83_combout\ = (count(1) & ((count(6)) # ((\SecretCode~75_combout\)))) # (!count(1) & (!count(6) & ((!\SecretCode~71\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "a8b9",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(1),
	datab => count(6),
	datac => \SecretCode~75_combout\,
	datad => \SecretCode~71\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~83_combout\);

-- Location: LC_X5_Y3_N4
\SecretCode~84\ : maxv_lcell
-- Equation(s):
-- \SecretCode~84_combout\ = (count(6) & ((count(0) & (count(2) $ (!\SecretCode~83_combout\))) # (!count(0) & (count(2) & !\SecretCode~83_combout\)))) # (!count(6) & (((\SecretCode~83_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8f60",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(0),
	datab => count(2),
	datac => count(6),
	datad => \SecretCode~83_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~84_combout\);

-- Location: LC_X4_Y3_N7
\SecretCode~79\ : maxv_lcell
-- Equation(s):
-- \SecretCode~79_combout\ = (count(0) & ((count(5) & (count(1) $ (!count(2)))) # (!count(5) & (count(1) & !count(2))))) # (!count(0) & ((count(5) & (!count(1) & count(2))) # (!count(5) & (count(1) $ (!count(2))))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "9429",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(0),
	datab => count(5),
	datac => count(1),
	datad => count(2),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~79_combout\);

-- Location: LC_X4_Y3_N4
\SecretCode~85\ : maxv_lcell
-- Equation(s):
-- \SecretCode~85_combout\ = (count(0) & ((count(5) & (!count(1) & count(2))) # (!count(5) & (count(1) $ (!count(2)))))) # (!count(0) & ((count(5) & (count(1) & !count(2))) # (!count(5) & (!count(1) & count(2)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "2942",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(0),
	datab => count(5),
	datac => count(1),
	datad => count(2),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~85_combout\);

-- Location: LC_X4_Y3_N6
\SecretCode~86\ : maxv_lcell
-- Equation(s):
-- \SecretCode~86_combout\ = (!count(6) & ((count(3) & ((\SecretCode~85_combout\))) # (!count(3) & (\SecretCode~79_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "5044",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(6),
	datab => \SecretCode~79_combout\,
	datac => \SecretCode~85_combout\,
	datad => count(3),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~86_combout\);

-- Location: LC_X5_Y3_N1
\SecretCode~74\ : maxv_lcell
-- Equation(s):
-- \SecretCode~74_combout\ = (count(0) & (\SecretCode~73\ & ((!count(2)) # (!count(6))))) # (!count(0) & (\SecretCode~73\ $ (((count(6) & !count(2))))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "7b04",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(0),
	datab => count(6),
	datac => count(2),
	datad => \SecretCode~73\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~74_combout\);

-- Location: LC_X4_Y3_N3
\SecretCode[3].Green\ : maxv_lcell
-- Equation(s):
-- \SecretCode[3].Green~regout\ = DFFEAS((count(3) & (\SecretCode~84_combout\)) # (!count(3) & (((\SecretCode~74_combout\)))), GLOBAL(\clk_Button~combout\), VCC, , \ButtonRES~combout\, \SecretCode~86_combout\, , , count(4))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "dd88",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "on")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => count(3),
	datab => \SecretCode~84_combout\,
	datac => \SecretCode~86_combout\,
	datad => \SecretCode~74_combout\,
	aclr => GND,
	sload => count(4),
	ena => \ButtonRES~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \SecretCode[3].Green~regout\);

-- Location: PIN_54,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: Default
\Button4~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "input")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_Button4,
	combout => \Button4~combout\);

-- Location: LC_X3_Y2_N0
\bPressedValidate~0\ : maxv_lcell
-- Equation(s):
-- \bPressedValidate~0_combout\ = (!\ButtonRES~combout\ & (((!\Equal0~0_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0505",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ButtonRES~combout\,
	datac => \Equal0~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \bPressedValidate~0_combout\);

-- Location: LC_X3_Y2_N6
bPressed4 : maxv_lcell
-- Equation(s):
-- \RGB3_state~9\ = ((!\Button4~combout\ & (!\Stop~regout\ & bPressed4))) # (!\bPressedValidate~0_combout\)

-- pragma translate_off
GENERIC MAP (
	lut_mask => "10ff",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "qfbk",
	synch_mode => "on")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => \Button4~combout\,
	datab => \Stop~regout\,
	datac => \Button4~combout\,
	datad => \bPressedValidate~0_combout\,
	aclr => GND,
	sload => VCC,
	ena => \bPressedValidate~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \RGB3_state~9\,
	regout => \bPressed4~regout\);

-- Location: LC_X4_Y2_N8
\RGB3_state.Green\ : maxv_lcell
-- Equation(s):
-- \RGB3_state.Green~regout\ = DFFEAS((!\ButtonRES~combout\ & ((\Equal0~0_combout\ & ((\SecretCode[3].Green~regout\))) # (!\Equal0~0_combout\ & (!\RGB3_state.Red~regout\)))), GLOBAL(\clk_Button~combout\), VCC, , \RGB3_state~9\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "5011",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => \ButtonRES~combout\,
	datab => \RGB3_state.Red~regout\,
	datac => \SecretCode[3].Green~regout\,
	datad => \Equal0~0_combout\,
	aclr => GND,
	ena => \RGB3_state~9\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \RGB3_state.Green~regout\);

-- Location: LC_X4_Y3_N0
\SecretCode~80\ : maxv_lcell
-- Equation(s):
-- \SecretCode~80_combout\ = (count(0) & ((count(5) & (count(1) & !count(2))) # (!count(5) & (!count(1) & count(2))))) # (!count(0) & ((count(5) & (count(1) $ (!count(2)))) # (!count(5) & (count(1) & !count(2)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "4294",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(0),
	datab => count(5),
	datac => count(1),
	datad => count(2),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~80_combout\);

-- Location: LC_X4_Y3_N5
\SecretCode~87\ : maxv_lcell
-- Equation(s):
-- \SecretCode~87_combout\ = (count(6)) # ((count(3) & (\SecretCode~80_combout\)) # (!count(3) & ((\SecretCode~85_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "fdec",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(3),
	datab => count(6),
	datac => \SecretCode~80_combout\,
	datad => \SecretCode~85_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~87_combout\);

-- Location: LC_X4_Y3_N8
\SecretCode~76\ : maxv_lcell
-- Equation(s):
-- \SecretCode~76_combout\ = (count(1) & ((count(6)) # ((\SecretCode~72\)))) # (!count(1) & (!count(6) & (\SecretCode~75_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "ba98",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(1),
	datab => count(6),
	datac => \SecretCode~75_combout\,
	datad => \SecretCode~72\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~76_combout\);

-- Location: LC_X4_Y3_N9
\SecretCode~77\ : maxv_lcell
-- Equation(s):
-- \SecretCode~77_combout\ = (count(6) & ((count(0) & (count(2) & !\SecretCode~76_combout\)) # (!count(0) & (!count(2) & \SecretCode~76_combout\)))) # (!count(6) & (((\SecretCode~76_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1f80",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(0),
	datab => count(2),
	datac => count(6),
	datad => \SecretCode~76_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~77_combout\);

-- Location: LC_X4_Y3_N2
\SecretCode[3].Blue\ : maxv_lcell
-- Equation(s):
-- \SecretCode[3].Blue~regout\ = DFFEAS((count(3) & (((\SecretCode~77_combout\)))) # (!count(3) & (\SecretCode~84_combout\)), GLOBAL(\clk_Button~combout\), VCC, , \ButtonRES~combout\, \SecretCode~87_combout\, , , count(4))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "ee44",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "on")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => count(3),
	datab => \SecretCode~84_combout\,
	datac => \SecretCode~87_combout\,
	datad => \SecretCode~77_combout\,
	aclr => GND,
	sload => count(4),
	ena => \ButtonRES~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \SecretCode[3].Blue~regout\);

-- Location: LC_X4_Y2_N6
\RGB3_state.Blue\ : maxv_lcell
-- Equation(s):
-- \RGB3_state.Blue~regout\ = DFFEAS((!\ButtonRES~combout\ & ((\Equal0~0_combout\ & ((\SecretCode[3].Blue~regout\))) # (!\Equal0~0_combout\ & (\RGB3_state.Green~regout\)))), GLOBAL(\clk_Button~combout\), VCC, , \RGB3_state~9\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "5410",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => \ButtonRES~combout\,
	datab => \Equal0~0_combout\,
	datac => \RGB3_state.Green~regout\,
	datad => \SecretCode[3].Blue~regout\,
	aclr => GND,
	ena => \RGB3_state~9\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \RGB3_state.Blue~regout\);

-- Location: LC_X4_Y3_N1
\SecretCode~81\ : maxv_lcell
-- Equation(s):
-- \SecretCode~81_combout\ = ((count(3) & (\SecretCode~79_combout\)) # (!count(3) & ((\SecretCode~80_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "f3c0",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datab => count(3),
	datac => \SecretCode~79_combout\,
	datad => \SecretCode~80_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~81_combout\);

-- Location: LC_X5_Y3_N2
\SecretCode~78\ : maxv_lcell
-- Equation(s):
-- \SecretCode~78_combout\ = (!count(4) & ((count(3) & ((\SecretCode~74_combout\))) # (!count(3) & (\SecretCode~77_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "5410",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(4),
	datab => count(3),
	datac => \SecretCode~77_combout\,
	datad => \SecretCode~74_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~78_combout\);

-- Location: LC_X5_Y3_N9
\SecretCode[3].Red\ : maxv_lcell
-- Equation(s):
-- \SecretCode[3].Red~regout\ = DFFEAS((!\SecretCode~78_combout\ & ((count(6)) # ((!\SecretCode~81_combout\) # (!count(4))))), GLOBAL(\clk_Button~combout\), VCC, , \ButtonRES~combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "00bf",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => count(6),
	datab => count(4),
	datac => \SecretCode~81_combout\,
	datad => \SecretCode~78_combout\,
	aclr => GND,
	ena => \ButtonRES~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \SecretCode[3].Red~regout\);

-- Location: LC_X4_Y2_N0
\RGB3_state.Red\ : maxv_lcell
-- Equation(s):
-- \RGB3_state.Red~regout\ = DFFEAS((!\ButtonRES~combout\ & ((\Equal0~0_combout\ & ((\SecretCode[3].Red~regout\))) # (!\Equal0~0_combout\ & (!\RGB3_state.Blue~regout\)))), GLOBAL(\clk_Button~combout\), VCC, , \RGB3_state~9\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "5011",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => \ButtonRES~combout\,
	datab => \RGB3_state.Blue~regout\,
	datac => \SecretCode[3].Red~regout\,
	datad => \Equal0~0_combout\,
	aclr => GND,
	ena => \RGB3_state~9\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \RGB3_state.Red~regout\);

-- Location: LC_X4_Y2_N9
\WideNor3~0\ : maxv_lcell
-- Equation(s):
-- \WideNor3~0_combout\ = (\RGB3_state.Blue~regout\ & ((\RGB3_state.Green~regout\ $ (\SecretCode[3].Green~regout\)) # (!\SecretCode[3].Blue~regout\))) # (!\RGB3_state.Blue~regout\ & ((\SecretCode[3].Blue~regout\) # (\RGB3_state.Green~regout\ $ 
-- (\SecretCode[3].Green~regout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "7dbe",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \RGB3_state.Blue~regout\,
	datab => \RGB3_state.Green~regout\,
	datac => \SecretCode[3].Green~regout\,
	datad => \SecretCode[3].Blue~regout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \WideNor3~0_combout\);

-- Location: LC_X4_Y2_N2
WideNor3 : maxv_lcell
-- Equation(s):
-- \WideNor3~combout\ = ((\WideNor3~0_combout\) # (\RGB3_state.Red~regout\ $ (\SecretCode[3].Red~regout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "ff3c",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datab => \RGB3_state.Red~regout\,
	datac => \SecretCode[3].Red~regout\,
	datad => \WideNor3~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \WideNor3~combout\);

-- Location: LC_X6_Y1_N4
\SecretCode~42\ : maxv_lcell
-- Equation(s):
-- \SecretCode~42_combout\ = (((count(3) & !count(4))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "00f0",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datac => count(3),
	datad => count(4),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~42_combout\);

-- Location: LC_X6_Y1_N2
\SecretCode~39\ : maxv_lcell
-- Equation(s):
-- \SecretCode~39_combout\ = (count(2) & (((!count(1)) # (!count(5))) # (!count(0)))) # (!count(2) & ((count(5)) # ((count(0) & count(1)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "7efa",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(2),
	datab => count(0),
	datac => count(5),
	datad => count(1),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~39_combout\);

-- Location: LC_X6_Y1_N8
\SecretCode~37\ : maxv_lcell
-- Equation(s):
-- \SecretCode~37_combout\ = (((count(5) & count(2))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "f000",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datac => count(5),
	datad => count(2),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~37_combout\);

-- Location: LC_X6_Y1_N0
\SecretCode~38\ : maxv_lcell
-- Equation(s):
-- \SecretCode~38_combout\ = (count(4) & (((count(3))))) # (!count(4) & ((count(3) & (!count(0))) # (!count(3) & ((!\SecretCode~37_combout\)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "b0b5",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(4),
	datab => count(0),
	datac => count(3),
	datad => \SecretCode~37_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~38_combout\);

-- Location: LC_X6_Y1_N9
\SecretCode~36\ : maxv_lcell
-- Equation(s):
-- \SecretCode~36_combout\ = ((count(2) & (count(5) & count(1))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "c000",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datab => count(2),
	datac => count(5),
	datad => count(1),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~36_combout\);

-- Location: LC_X6_Y1_N1
\SecretCode~40\ : maxv_lcell
-- Equation(s):
-- \SecretCode~40_combout\ = (count(4) & ((\SecretCode~38_combout\ & (\SecretCode~39_combout\)) # (!\SecretCode~38_combout\ & ((\SecretCode~36_combout\))))) # (!count(4) & (((\SecretCode~38_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "dad0",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(4),
	datab => \SecretCode~39_combout\,
	datac => \SecretCode~38_combout\,
	datad => \SecretCode~36_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~40_combout\);

-- Location: LC_X5_Y1_N4
\SecretCode[1].Red\ : maxv_lcell
-- Equation(s):
-- \SecretCode[1].Red~regout\ = DFFEAS((count(6)) # (((\SecretCode~42_combout\ & !\SecretCode~41_combout\)) # (!\SecretCode~40_combout\)), GLOBAL(\clk_Button~combout\), VCC, , \ButtonRES~combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aeff",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => count(6),
	datab => \SecretCode~42_combout\,
	datac => \SecretCode~41_combout\,
	datad => \SecretCode~40_combout\,
	aclr => GND,
	ena => \ButtonRES~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \SecretCode[1].Red~regout\);

-- Location: LC_X3_Y1_N0
\SecretCode~44\ : maxv_lcell
-- Equation(s):
-- \SecretCode~44_combout\ = ((count(6)) # ((count(5) & count(2))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "fcf0",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datab => count(5),
	datac => count(6),
	datad => count(2),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~44_combout\);

-- Location: LC_X3_Y1_N3
\SecretCode~47\ : maxv_lcell
-- Equation(s):
-- \SecretCode~47_combout\ = (count(1) & (count(5) & (count(2) & count(0))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8000",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(1),
	datab => count(5),
	datac => count(2),
	datad => count(0),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~47_combout\);

-- Location: LC_X3_Y1_N4
\SecretCode~48\ : maxv_lcell
-- Equation(s):
-- \SecretCode~48_combout\ = (!count(6) & ((count(3) & ((\SecretCode~47_combout\))) # (!count(3) & (\SecretCode~41_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "5410",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(6),
	datab => count(3),
	datac => \SecretCode~41_combout\,
	datad => \SecretCode~47_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~48_combout\);

-- Location: LC_X3_Y1_N8
\SecretCode~45\ : maxv_lcell
-- Equation(s):
-- \SecretCode~45_combout\ = (count(5) & (((!count(1) & !count(0))) # (!count(2)))) # (!count(5) & ((count(2)) # ((count(1)) # (count(0)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "777e",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(5),
	datab => count(2),
	datac => count(1),
	datad => count(0),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~45_combout\);

-- Location: LC_X3_Y1_N1
\SecretCode~46\ : maxv_lcell
-- Equation(s):
-- \SecretCode~46_combout\ = (((!count(6) & \SecretCode~45_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0f00",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datac => count(6),
	datad => \SecretCode~45_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~46_combout\);

-- Location: LC_X3_Y1_N2
\SecretCode[1].Green\ : maxv_lcell
-- Equation(s):
-- \SecretCode[1].Green~regout\ = DFFEAS((count(3) & (((\SecretCode~46_combout\)))) # (!count(3) & (\SecretCode~44_combout\)), GLOBAL(\clk_Button~combout\), VCC, , \ButtonRES~combout\, \SecretCode~48_combout\, , , count(4))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "ee44",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "on")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => count(3),
	datab => \SecretCode~44_combout\,
	datac => \SecretCode~48_combout\,
	datad => \SecretCode~46_combout\,
	aclr => GND,
	sload => count(4),
	ena => \ButtonRES~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \SecretCode[1].Green~regout\);

-- Location: PIN_47,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: Default
\Button2~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "input")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_Button2,
	combout => \Button2~combout\);

-- Location: LC_X3_Y2_N2
bPressed2 : maxv_lcell
-- Equation(s):
-- \RGB1_state~9\ = ((!\Button2~combout\ & (!\Stop~regout\ & bPressed2))) # (!\bPressedValidate~0_combout\)

-- pragma translate_off
GENERIC MAP (
	lut_mask => "10ff",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "qfbk",
	synch_mode => "on")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => \Button2~combout\,
	datab => \Stop~regout\,
	datac => \Button2~combout\,
	datad => \bPressedValidate~0_combout\,
	aclr => GND,
	sload => VCC,
	ena => \bPressedValidate~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \RGB1_state~9\,
	regout => \bPressed2~regout\);

-- Location: LC_X4_Y1_N6
\RGB1_state.Green\ : maxv_lcell
-- Equation(s):
-- \RGB1_state.Green~regout\ = DFFEAS((!\ButtonRES~combout\ & ((\Equal0~0_combout\ & ((\SecretCode[1].Green~regout\))) # (!\Equal0~0_combout\ & (!\RGB1_state.Red~regout\)))), GLOBAL(\clk_Button~combout\), VCC, , \RGB1_state~9\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "2301",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => \Equal0~0_combout\,
	datab => \ButtonRES~combout\,
	datac => \RGB1_state.Red~regout\,
	datad => \SecretCode[1].Green~regout\,
	aclr => GND,
	ena => \RGB1_state~9\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \RGB1_state.Green~regout\);

-- Location: LC_X3_Y1_N6
\SecretCode~53\ : maxv_lcell
-- Equation(s):
-- \SecretCode~53_combout\ = (!count(3) & ((count(2) & ((!count(1)) # (!count(5)))) # (!count(2) & ((count(5)) # (count(1))))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "007e",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(2),
	datab => count(5),
	datac => count(1),
	datad => count(3),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~53_combout\);

-- Location: LC_X5_Y4_N8
\SecretCode~49\ : maxv_lcell
-- Equation(s):
-- \SecretCode~49_combout\ = (((count(0) & count(1))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "f000",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datac => count(0),
	datad => count(1),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~49_combout\);

-- Location: LC_X5_Y4_N9
\SecretCode~50\ : maxv_lcell
-- Equation(s):
-- \SecretCode~50_combout\ = (count(4) & (!count(5) & (!count(2) & !\SecretCode~49_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0002",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(4),
	datab => count(5),
	datac => count(2),
	datad => \SecretCode~49_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~50_combout\);

-- Location: LC_X5_Y1_N8
\SecretCode~51\ : maxv_lcell
-- Equation(s):
-- \SecretCode~51_combout\ = (!count(4) & (\SecretCode~37_combout\ & ((count(1)) # (count(0)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0e00",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(1),
	datab => count(0),
	datac => count(4),
	datad => \SecretCode~37_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~51_combout\);

-- Location: LC_X4_Y1_N8
\SecretCode~52\ : maxv_lcell
-- Equation(s):
-- \SecretCode~52_combout\ = (count(3) & ((count(6)) # ((\SecretCode~50_combout\) # (\SecretCode~51_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "ccc8",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(6),
	datab => count(3),
	datac => \SecretCode~50_combout\,
	datad => \SecretCode~51_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~52_combout\);

-- Location: LC_X4_Y1_N5
\SecretCode[1].Blue\ : maxv_lcell
-- Equation(s):
-- \SecretCode[1].Blue~regout\ = DFFEAS((\SecretCode~52_combout\) # ((count(4) & ((count(6)) # (\SecretCode~53_combout\)))), GLOBAL(\clk_Button~combout\), VCC, , \ButtonRES~combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "ffc8",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => count(6),
	datab => count(4),
	datac => \SecretCode~53_combout\,
	datad => \SecretCode~52_combout\,
	aclr => GND,
	ena => \ButtonRES~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \SecretCode[1].Blue~regout\);

-- Location: LC_X4_Y1_N9
\RGB1_state.Blue\ : maxv_lcell
-- Equation(s):
-- \RGB1_state.Blue~regout\ = DFFEAS((!\ButtonRES~combout\ & ((\Equal0~0_combout\ & ((\SecretCode[1].Blue~regout\))) # (!\Equal0~0_combout\ & (\RGB1_state.Green~regout\)))), GLOBAL(\clk_Button~combout\), VCC, , \RGB1_state~9\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "3202",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => \RGB1_state.Green~regout\,
	datab => \ButtonRES~combout\,
	datac => \Equal0~0_combout\,
	datad => \SecretCode[1].Blue~regout\,
	aclr => GND,
	ena => \RGB1_state~9\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \RGB1_state.Blue~regout\);

-- Location: LC_X4_Y1_N4
\RGB1_state.Red\ : maxv_lcell
-- Equation(s):
-- \RGB1_state.Red~regout\ = DFFEAS((!\ButtonRES~combout\ & ((\Equal0~0_combout\ & (\SecretCode[1].Red~regout\)) # (!\Equal0~0_combout\ & ((!\RGB1_state.Blue~regout\))))), GLOBAL(\clk_Button~combout\), VCC, , \RGB1_state~9\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "2023",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => \SecretCode[1].Red~regout\,
	datab => \ButtonRES~combout\,
	datac => \Equal0~0_combout\,
	datad => \RGB1_state.Blue~regout\,
	aclr => GND,
	ena => \RGB1_state~9\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \RGB1_state.Red~regout\);

-- Location: LC_X4_Y1_N1
\WideNor1~0\ : maxv_lcell
-- Equation(s):
-- \WideNor1~0_combout\ = (\SecretCode[1].Blue~regout\ & ((\RGB1_state.Green~regout\ $ (\SecretCode[1].Green~regout\)) # (!\RGB1_state.Blue~regout\))) # (!\SecretCode[1].Blue~regout\ & ((\RGB1_state.Blue~regout\) # (\RGB1_state.Green~regout\ $ 
-- (\SecretCode[1].Green~regout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "6ff6",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \SecretCode[1].Blue~regout\,
	datab => \RGB1_state.Blue~regout\,
	datac => \RGB1_state.Green~regout\,
	datad => \SecretCode[1].Green~regout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \WideNor1~0_combout\);

-- Location: LC_X4_Y1_N2
WideNor1 : maxv_lcell
-- Equation(s):
-- \WideNor1~combout\ = ((\WideNor1~0_combout\) # (\RGB1_state.Red~regout\ $ (\SecretCode[1].Red~regout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "ff5a",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \RGB1_state.Red~regout\,
	datac => \SecretCode[1].Red~regout\,
	datad => \WideNor1~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \WideNor1~combout\);

-- Location: LC_X4_Y4_N9
\SecretCode~57\ : maxv_lcell
-- Equation(s):
-- \SecretCode~57_combout\ = (count(2)) # ((count(1) & ((count(0)) # (!count(3)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "ecee",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(1),
	datab => count(2),
	datac => count(0),
	datad => count(3),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~57_combout\);

-- Location: LC_X4_Y4_N7
\SecretCode~59\ : maxv_lcell
-- Equation(s):
-- \SecretCode~59_combout\ = (count(2) & (!count(5) & ((count(3)) # (!count(0))))) # (!count(2) & (count(3) & (count(5) & !count(0))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "082c",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(3),
	datab => count(2),
	datac => count(5),
	datad => count(0),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~59_combout\);

-- Location: LC_X4_Y4_N5
\SecretCode~58\ : maxv_lcell
-- Equation(s):
-- \SecretCode~58_combout\ = (count(0) & (count(2) $ ((!count(5))))) # (!count(0) & (!count(3) & (count(2) $ (!count(5)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "84a5",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(2),
	datab => count(0),
	datac => count(5),
	datad => count(3),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~58_combout\);

-- Location: LC_X4_Y4_N6
\SecretCode~60\ : maxv_lcell
-- Equation(s):
-- \SecretCode~60_combout\ = (count(6)) # ((count(1) & ((!\SecretCode~58_combout\))) # (!count(1) & (!\SecretCode~59_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "cdef",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(1),
	datab => count(6),
	datac => \SecretCode~59_combout\,
	datad => \SecretCode~58_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~60_combout\);

-- Location: LC_X4_Y4_N0
\SecretCode~55\ : maxv_lcell
-- Equation(s):
-- \SecretCode~55_combout\ = ((count(2) $ (count(5))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0ff0",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datac => count(2),
	datad => count(5),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~55_combout\);

-- Location: LC_X4_Y4_N1
\SecretCode~56\ : maxv_lcell
-- Equation(s):
-- \SecretCode~56_combout\ = (\SecretCode~55_combout\) # ((count(0) & (!count(3) & count(1))) # (!count(0) & (count(3) & !count(1))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "ff24",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(0),
	datab => count(3),
	datac => count(1),
	datad => \SecretCode~55_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~56_combout\);

-- Location: LC_X4_Y4_N2
\SecretCode[2].Red\ : maxv_lcell
-- Equation(s):
-- \SecretCode[2].Red~regout\ = DFFEAS((count(6) & (\SecretCode~57_combout\)) # (!count(6) & (((\SecretCode~56_combout\)))), GLOBAL(\clk_Button~combout\), VCC, , \ButtonRES~combout\, \SecretCode~60_combout\, , , count(4))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "dd88",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "on")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => count(6),
	datab => \SecretCode~57_combout\,
	datac => \SecretCode~60_combout\,
	datad => \SecretCode~56_combout\,
	aclr => GND,
	sload => count(4),
	ena => \ButtonRES~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \SecretCode[2].Red~regout\);

-- Location: LC_X5_Y4_N0
\SecretCode~66\ : maxv_lcell
-- Equation(s):
-- \SecretCode~66_combout\ = (((!count(0) & count(3))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0f00",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datac => count(0),
	datad => count(3),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~66_combout\);

-- Location: LC_X5_Y4_N1
\SecretCode~67\ : maxv_lcell
-- Equation(s):
-- \SecretCode~67_combout\ = (count(5) & (count(6) $ ((!count(2))))) # (!count(5) & (count(2) & ((count(6)) # (!\SecretCode~66_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "c2d2",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(5),
	datab => count(6),
	datac => count(2),
	datad => \SecretCode~66_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~67_combout\);

-- Location: LC_X5_Y4_N4
\SecretCode~69\ : maxv_lcell
-- Equation(s):
-- \SecretCode~69_combout\ = ((count(1) & ((count(0)) # (!count(3)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "c0cc",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datab => count(1),
	datac => count(0),
	datad => count(3),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~69_combout\);

-- Location: LC_X5_Y4_N5
\SecretCode~68\ : maxv_lcell
-- Equation(s):
-- \SecretCode~68_combout\ = (!count(2) & (count(5) & (!count(3) & \SecretCode~49_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0400",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(2),
	datab => count(5),
	datac => count(3),
	datad => \SecretCode~49_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~68_combout\);

-- Location: LC_X5_Y4_N6
\SecretCode~70\ : maxv_lcell
-- Equation(s):
-- \SecretCode~70_combout\ = (count(6)) # ((\SecretCode~68_combout\) # ((!\SecretCode~55_combout\ & !\SecretCode~69_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "ffcd",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \SecretCode~55_combout\,
	datab => count(6),
	datac => \SecretCode~69_combout\,
	datad => \SecretCode~68_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~70_combout\);

-- Location: LC_X5_Y4_N3
\SecretCode~64\ : maxv_lcell
-- Equation(s):
-- \SecretCode~64_combout\ = (count(2) & ((count(6)) # ((!count(0) & !count(5))))) # (!count(2) & ((count(6) & (!count(0))) # (!count(6) & ((count(5))))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "f51c",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(0),
	datab => count(5),
	datac => count(2),
	datad => count(6),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~64_combout\);

-- Location: LC_X5_Y4_N2
\SecretCode~65\ : maxv_lcell
-- Equation(s):
-- \SecretCode~65_combout\ = ((count(0) & (!count(3) & \SecretCode~64_combout\)) # (!count(0) & (count(3) & !\SecretCode~64_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0c30",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datab => count(0),
	datac => count(3),
	datad => \SecretCode~64_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~65_combout\);

-- Location: LC_X5_Y4_N7
\SecretCode[2].Blue\ : maxv_lcell
-- Equation(s):
-- \SecretCode[2].Blue~regout\ = DFFEAS((count(1) & (\SecretCode~67_combout\)) # (!count(1) & (((\SecretCode~65_combout\)))), GLOBAL(\clk_Button~combout\), VCC, , \ButtonRES~combout\, \SecretCode~70_combout\, , , count(4))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "dd88",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "on")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => count(1),
	datab => \SecretCode~67_combout\,
	datac => \SecretCode~70_combout\,
	datad => \SecretCode~65_combout\,
	aclr => GND,
	sload => count(4),
	ena => \ButtonRES~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \SecretCode[2].Blue~regout\);

-- Location: LC_X6_Y2_N9
\SecretCode~61\ : maxv_lcell
-- Equation(s):
-- \SecretCode~61_combout\ = (count(2) & (!count(1) & ((count(3)) # (!count(0))))) # (!count(2) & (count(1) & ((count(0)) # (!count(3)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "45a2",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(2),
	datab => count(0),
	datac => count(3),
	datad => count(1),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~61_combout\);

-- Location: LC_X6_Y2_N4
\SecretCode~62\ : maxv_lcell
-- Equation(s):
-- \SecretCode~62_combout\ = (count(5) & ((count(3) & (!count(0) & !count(1))) # (!count(3) & (count(0) & count(1))))) # (!count(5) & ((count(1)) # ((!count(3) & count(0)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "7318",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(3),
	datab => count(5),
	datac => count(0),
	datad => count(1),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~62_combout\);

-- Location: LC_X6_Y2_N6
\SecretCode~63\ : maxv_lcell
-- Equation(s):
-- \SecretCode~63_combout\ = (!count(6) & ((count(5) & (!count(2) & !\SecretCode~62_combout\)) # (!count(5) & (count(2) & \SecretCode~62_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0042",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(5),
	datab => count(2),
	datac => \SecretCode~62_combout\,
	datad => count(6),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~63_combout\);

-- Location: LC_X6_Y2_N3
\SecretCode~89\ : maxv_lcell
-- Equation(s):
-- \SecretCode~89_combout\ = (count(5) & (\SecretCode~88\ & (count(1) $ (!count(2))))) # (!count(5) & ((count(1) & (\SecretCode~88\)) # (!count(1) & ((count(2))))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "d160",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => count(5),
	datab => count(1),
	datac => \SecretCode~88\,
	datad => count(2),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SecretCode~89_combout\);

-- Location: LC_X6_Y2_N2
\SecretCode[2].Green\ : maxv_lcell
-- Equation(s):
-- \SecretCode[2].Green~regout\ = DFFEAS((count(6) & (\SecretCode~61_combout\)) # (!count(6) & (((\SecretCode~89_combout\)))), GLOBAL(\clk_Button~combout\), VCC, , \ButtonRES~combout\, \SecretCode~63_combout\, , , count(4))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "dd88",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "on")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => count(6),
	datab => \SecretCode~61_combout\,
	datac => \SecretCode~63_combout\,
	datad => \SecretCode~89_combout\,
	aclr => GND,
	sload => count(4),
	ena => \ButtonRES~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \SecretCode[2].Green~regout\);

-- Location: PIN_53,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: Default
\Button3~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "input")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_Button3,
	combout => \Button3~combout\);

-- Location: LC_X3_Y2_N3
bPressed3 : maxv_lcell
-- Equation(s):
-- \RGB2_state~9\ = ((!\Button3~combout\ & (!\Stop~regout\ & bPressed3))) # (!\bPressedValidate~0_combout\)

-- pragma translate_off
GENERIC MAP (
	lut_mask => "10ff",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "qfbk",
	synch_mode => "on")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => \Button3~combout\,
	datab => \Stop~regout\,
	datac => \Button3~combout\,
	datad => \bPressedValidate~0_combout\,
	aclr => GND,
	sload => VCC,
	ena => \bPressedValidate~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \RGB2_state~9\,
	regout => \bPressed3~regout\);

-- Location: LC_X3_Y2_N8
\RGB2_state.Green\ : maxv_lcell
-- Equation(s):
-- \RGB2_state.Green~regout\ = DFFEAS((!\ButtonRES~combout\ & ((\Equal0~0_combout\ & ((\SecretCode[2].Green~regout\))) # (!\Equal0~0_combout\ & (!\RGB2_state.Red~regout\)))), GLOBAL(\clk_Button~combout\), VCC, , \RGB2_state~9\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "5101",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => \ButtonRES~combout\,
	datab => \RGB2_state.Red~regout\,
	datac => \Equal0~0_combout\,
	datad => \SecretCode[2].Green~regout\,
	aclr => GND,
	ena => \RGB2_state~9\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \RGB2_state.Green~regout\);

-- Location: LC_X5_Y2_N6
\RGB2_state.Blue\ : maxv_lcell
-- Equation(s):
-- \RGB2_state.Blue~regout\ = DFFEAS((!\ButtonRES~combout\ & ((\Equal0~0_combout\ & (\SecretCode[2].Blue~regout\)) # (!\Equal0~0_combout\ & ((\RGB2_state.Green~regout\))))), GLOBAL(\clk_Button~combout\), VCC, , \RGB2_state~9\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "4450",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => \ButtonRES~combout\,
	datab => \SecretCode[2].Blue~regout\,
	datac => \RGB2_state.Green~regout\,
	datad => \Equal0~0_combout\,
	aclr => GND,
	ena => \RGB2_state~9\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \RGB2_state.Blue~regout\);

-- Location: LC_X3_Y2_N1
\RGB2_state.Red\ : maxv_lcell
-- Equation(s):
-- \RGB2_state.Red~regout\ = DFFEAS((!\ButtonRES~combout\ & ((\Equal0~0_combout\ & (\SecretCode[2].Red~regout\)) # (!\Equal0~0_combout\ & ((!\RGB2_state.Blue~regout\))))), GLOBAL(\clk_Button~combout\), VCC, , \RGB2_state~9\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "4045",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => \ButtonRES~combout\,
	datab => \SecretCode[2].Red~regout\,
	datac => \Equal0~0_combout\,
	datad => \RGB2_state.Blue~regout\,
	aclr => GND,
	ena => \RGB2_state~9\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \RGB2_state.Red~regout\);

-- Location: LC_X5_Y2_N4
\WideNor2~0\ : maxv_lcell
-- Equation(s):
-- \WideNor2~0_combout\ = (\RGB2_state.Blue~regout\ & ((\SecretCode[2].Green~regout\ $ (\RGB2_state.Green~regout\)) # (!\SecretCode[2].Blue~regout\))) # (!\RGB2_state.Blue~regout\ & ((\SecretCode[2].Blue~regout\) # (\SecretCode[2].Green~regout\ $ 
-- (\RGB2_state.Green~regout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "7dbe",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \RGB2_state.Blue~regout\,
	datab => \SecretCode[2].Green~regout\,
	datac => \RGB2_state.Green~regout\,
	datad => \SecretCode[2].Blue~regout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \WideNor2~0_combout\);

-- Location: LC_X5_Y2_N5
WideNor2 : maxv_lcell
-- Equation(s):
-- \WideNor2~combout\ = ((\WideNor2~0_combout\) # (\RGB2_state.Red~regout\ $ (\SecretCode[2].Red~regout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "ff3c",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datab => \RGB2_state.Red~regout\,
	datac => \SecretCode[2].Red~regout\,
	datad => \WideNor2~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \WideNor2~combout\);

-- Location: LC_X4_Y2_N3
\NbreCorrect~0\ : maxv_lcell
-- Equation(s):
-- \NbreCorrect~0_combout\ = ((\WideNor3~combout\) # ((\WideNor1~combout\) # (\WideNor2~combout\))) # (!\WideNor0~combout\)

-- pragma translate_off
GENERIC MAP (
	lut_mask => "fffd",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \WideNor0~combout\,
	datab => \WideNor3~combout\,
	datac => \WideNor1~combout\,
	datad => \WideNor2~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \NbreCorrect~0_combout\);

-- Location: LC_X4_Y2_N4
\Stop~3\ : maxv_lcell
-- Equation(s):
-- \Stop~3_combout\ = ((\bPressedValidate~regout\ & (!\ButtonValidate~combout\ & !\NbreCorrect~0_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "000c",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datab => \bPressedValidate~regout\,
	datac => \ButtonValidate~combout\,
	datad => \NbreCorrect~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Stop~3_combout\);

-- Location: LC_X4_Y2_N5
Stop : maxv_lcell
-- Equation(s):
-- \Stop~regout\ = DFFEAS(((\Equal0~0_combout\) # ((\Stop~regout\) # (\Stop~3_combout\))), GLOBAL(\clk_Button~combout\), VCC, , , , , \ButtonRES~combout\, )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "fffc",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "on")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	datab => \Equal0~0_combout\,
	datac => \Stop~regout\,
	datad => \Stop~3_combout\,
	aclr => GND,
	sclr => \ButtonRES~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \Stop~regout\);

-- Location: LC_X4_Y2_N1
bPressedValidate : maxv_lcell
-- Equation(s):
-- \bPressedValidate~regout\ = DFFEAS((\bPressedValidate~0_combout\ & (\ButtonValidate~combout\ & ((\bPressedValidate~regout\) # (!\Stop~regout\)))) # (!\bPressedValidate~0_combout\ & (((\bPressedValidate~regout\)))), GLOBAL(\clk_Button~combout\), VCC, , , , 
-- , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "d0cc",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => \Stop~regout\,
	datab => \bPressedValidate~regout\,
	datac => \ButtonValidate~combout\,
	datad => \bPressedValidate~0_combout\,
	aclr => GND,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \bPressedValidate~regout\);

-- Location: LC_X5_Y2_N3
\Stop~2\ : maxv_lcell
-- Equation(s):
-- \Stop~2_combout\ = (((\bPressedValidate~regout\ & !\ButtonValidate~combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "00f0",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datac => \bPressedValidate~regout\,
	datad => \ButtonValidate~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Stop~2_combout\);

-- Location: LC_X4_Y2_N7
\validation:tmpDisplay2[0]\ : maxv_lcell
-- Equation(s):
-- \validation:tmpDisplay2[0]~regout\ = DFFEAS((\ButtonRES~combout\) # (\validation:tmpDisplay2[0]~regout\ $ (((!\Equal0~0_combout\ & \Stop~2_combout\)))), GLOBAL(\clk_Button~combout\), VCC, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "efba",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => \ButtonRES~combout\,
	datab => \Equal0~0_combout\,
	datac => \Stop~2_combout\,
	datad => \validation:tmpDisplay2[0]~regout\,
	aclr => GND,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \validation:tmpDisplay2[0]~regout\);

-- Location: LC_X5_Y2_N9
\validation:tmpDisplay2[1]~0\ : maxv_lcell
-- Equation(s):
-- \validation:tmpDisplay2[1]~0_combout\ = (\ButtonRES~combout\) # ((!\ButtonValidate~combout\ & (\bPressedValidate~regout\ & !\Equal0~0_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "ccdc",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ButtonValidate~combout\,
	datab => \ButtonRES~combout\,
	datac => \bPressedValidate~regout\,
	datad => \Equal0~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \validation:tmpDisplay2[1]~0_combout\);

-- Location: LC_X2_Y2_N2
\validation:tmpDisplay2[1]\ : maxv_lcell
-- Equation(s):
-- \validation:tmpDisplay2[1]~regout\ = DFFEAS((\validation:tmpDisplay2[1]~0_combout\ & (!\ButtonRES~combout\ & (\validation:tmpDisplay2[0]~regout\ $ (!\validation:tmpDisplay2[1]~regout\)))) # (!\validation:tmpDisplay2[1]~0_combout\ & 
-- (((\validation:tmpDisplay2[1]~regout\)))), GLOBAL(\clk_Button~combout\), VCC, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "21f0",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => \validation:tmpDisplay2[0]~regout\,
	datab => \ButtonRES~combout\,
	datac => \validation:tmpDisplay2[1]~regout\,
	datad => \validation:tmpDisplay2[1]~0_combout\,
	aclr => GND,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \validation:tmpDisplay2[1]~regout\);

-- Location: LC_X2_Y2_N7
\Add1~0\ : maxv_lcell
-- Equation(s):
-- \Add1~0_combout\ = (((!\validation:tmpDisplay2[1]~regout\ & !\validation:tmpDisplay2[0]~regout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "000f",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datac => \validation:tmpDisplay2[1]~regout\,
	datad => \validation:tmpDisplay2[0]~regout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Add1~0_combout\);

-- Location: LC_X2_Y2_N0
\validation:tmpDisplay2[2]\ : maxv_lcell
-- Equation(s):
-- \validation:tmpDisplay2[2]~regout\ = DFFEAS((\validation:tmpDisplay2[1]~0_combout\ & (!\ButtonRES~combout\ & (\validation:tmpDisplay2[2]~regout\ $ (\Add1~0_combout\)))) # (!\validation:tmpDisplay2[1]~0_combout\ & (\validation:tmpDisplay2[2]~regout\)), 
-- GLOBAL(\clk_Button~combout\), VCC, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "12aa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => \validation:tmpDisplay2[2]~regout\,
	datab => \ButtonRES~combout\,
	datac => \Add1~0_combout\,
	datad => \validation:tmpDisplay2[1]~0_combout\,
	aclr => GND,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \validation:tmpDisplay2[2]~regout\);

-- Location: LC_X2_Y2_N4
\Equal0~1\ : maxv_lcell
-- Equation(s):
-- \Equal0~1_combout\ = (!\validation:tmpDisplay2[2]~regout\ & (((!\validation:tmpDisplay2[1]~regout\ & !\validation:tmpDisplay2[0]~regout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0005",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \validation:tmpDisplay2[2]~regout\,
	datac => \validation:tmpDisplay2[1]~regout\,
	datad => \validation:tmpDisplay2[0]~regout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Equal0~1_combout\);

-- Location: LC_X2_Y2_N9
\validation:tmpDisplay2[3]\ : maxv_lcell
-- Equation(s):
-- \validation:tmpDisplay2[3]~regout\ = DFFEAS((\ButtonRES~combout\) # ((\validation:tmpDisplay2[3]~regout\ & ((!\Stop~2_combout\) # (!\Equal0~1_combout\)))), GLOBAL(\clk_Button~combout\), VCC, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "dcfc",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => \Equal0~1_combout\,
	datab => \ButtonRES~combout\,
	datac => \validation:tmpDisplay2[3]~regout\,
	datad => \Stop~2_combout\,
	aclr => GND,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \validation:tmpDisplay2[3]~regout\);

-- Location: LC_X3_Y2_N7
\Equal0~0\ : maxv_lcell
-- Equation(s):
-- \Equal0~0_combout\ = (!\validation:tmpDisplay2[0]~regout\ & (!\validation:tmpDisplay2[1]~regout\ & (!\validation:tmpDisplay2[3]~regout\ & !\validation:tmpDisplay2[2]~regout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0001",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \validation:tmpDisplay2[0]~regout\,
	datab => \validation:tmpDisplay2[1]~regout\,
	datac => \validation:tmpDisplay2[3]~regout\,
	datad => \validation:tmpDisplay2[2]~regout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Equal0~0_combout\);

-- Location: LC_X4_Y1_N3
\RGB0_state~9\ : maxv_lcell
-- Equation(s):
-- \RGB0_state~9_combout\ = ((\RGB0_state~8\ & (!\RGB0_state.Red~regout\)) # (!\RGB0_state~8\ & ((\RGB0_state.Blue~regout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "55f0",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \RGB0_state.Red~regout\,
	datac => \RGB0_state.Blue~regout\,
	datad => \RGB0_state~8\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \RGB0_state~9_combout\);

-- Location: LC_X5_Y1_N7
\RGB0_state.Red\ : maxv_lcell
-- Equation(s):
-- \RGB0_state.Red~regout\ = DFFEAS((!\ButtonRES~combout\ & ((\Equal0~0_combout\ & (\SecretCode[0].Red~regout\)) # (!\Equal0~0_combout\ & ((!\RGB0_state~9_combout\))))), GLOBAL(\clk_Button~combout\), VCC, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "2023",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	dataa => \SecretCode[0].Red~regout\,
	datab => \ButtonRES~combout\,
	datac => \Equal0~0_combout\,
	datad => \RGB0_state~9_combout\,
	aclr => GND,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \RGB0_state.Red~regout\);

-- Location: LC_X5_Y2_N7
\tmpDisplay~0\ : maxv_lcell
-- Equation(s):
-- \tmpDisplay~0_combout\ = \WideNor2~combout\ $ (\WideNor0~combout\ $ (\WideNor1~combout\ $ (\WideNor3~combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "6996",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \WideNor2~combout\,
	datab => \WideNor0~combout\,
	datac => \WideNor1~combout\,
	datad => \WideNor3~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \tmpDisplay~0_combout\);

-- Location: LC_X5_Y2_N8
\validation:tmpDisplay[0]\ : maxv_lcell
-- Equation(s):
-- \validation:tmpDisplay[0]~regout\ = DFFEAS((((!\ButtonRES~combout\ & !\tmpDisplay~0_combout\))), GLOBAL(\clk_Button~combout\), VCC, , \validation:tmpDisplay2[1]~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "000f",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	datac => \ButtonRES~combout\,
	datad => \tmpDisplay~0_combout\,
	aclr => GND,
	ena => \validation:tmpDisplay2[1]~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \validation:tmpDisplay[0]~regout\);

-- Location: LC_X2_Y3_N5
\Segment1a~reg0\ : maxv_lcell
-- Equation(s):
-- \Segment1a~reg0_regout\ = DFFEAS(GND, GLOBAL(\clk_Button~combout\), VCC, , !\ButtonRES~combout\, \validation:tmpDisplay[0]~regout\, , , VCC)

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "on")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	datac => \validation:tmpDisplay[0]~regout\,
	aclr => GND,
	sload => VCC,
	ena => \ALT_INV_ButtonRES~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \Segment1a~reg0_regout\);

-- Location: LC_X5_Y2_N1
\tmpDisplay~2\ : maxv_lcell
-- Equation(s):
-- \tmpDisplay~2_combout\ = (\WideNor2~combout\ & ((\WideNor0~combout\ & ((!\WideNor3~combout\) # (!\WideNor1~combout\))) # (!\WideNor0~combout\ & (!\WideNor1~combout\ & !\WideNor3~combout\)))) # (!\WideNor2~combout\ & ((\WideNor0~combout\) # 
-- ((!\WideNor3~combout\) # (!\WideNor1~combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "4ddf",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \WideNor2~combout\,
	datab => \WideNor0~combout\,
	datac => \WideNor1~combout\,
	datad => \WideNor3~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \tmpDisplay~2_combout\);

-- Location: LC_X5_Y2_N2
\validation:tmpDisplay[1]\ : maxv_lcell
-- Equation(s):
-- \validation:tmpDisplay[1]~regout\ = DFFEAS(((!\ButtonRES~combout\ & ((\tmpDisplay~2_combout\)))), GLOBAL(\clk_Button~combout\), VCC, , \validation:tmpDisplay2[1]~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "3300",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	datab => \ButtonRES~combout\,
	datad => \tmpDisplay~2_combout\,
	aclr => GND,
	ena => \validation:tmpDisplay2[1]~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \validation:tmpDisplay[1]~regout\);

-- Location: LC_X2_Y3_N4
\Segment1b~reg0\ : maxv_lcell
-- Equation(s):
-- \Segment1b~reg0_regout\ = DFFEAS(GND, GLOBAL(\clk_Button~combout\), VCC, , !\ButtonRES~combout\, \validation:tmpDisplay[1]~regout\, , , VCC)

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "on")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	datac => \validation:tmpDisplay[1]~regout\,
	aclr => GND,
	sload => VCC,
	ena => \ALT_INV_ButtonRES~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \Segment1b~reg0_regout\);

-- Location: LC_X5_Y2_N0
\validation:tmpDisplay[2]\ : maxv_lcell
-- Equation(s):
-- \validation:tmpDisplay[2]~regout\ = DFFEAS(((!\ButtonRES~combout\ & ((!\NbreCorrect~0_combout\)))), GLOBAL(\clk_Button~combout\), VCC, , \validation:tmpDisplay2[1]~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0033",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	datab => \ButtonRES~combout\,
	datad => \NbreCorrect~0_combout\,
	aclr => GND,
	ena => \validation:tmpDisplay2[1]~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \validation:tmpDisplay[2]~regout\);

-- Location: LC_X2_Y3_N2
\Segment1c~reg0\ : maxv_lcell
-- Equation(s):
-- \Segment1c~reg0_regout\ = DFFEAS((((\validation:tmpDisplay[2]~regout\))), GLOBAL(\clk_Button~combout\), VCC, , !\ButtonRES~combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "ff00",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	datad => \validation:tmpDisplay[2]~regout\,
	aclr => GND,
	ena => \ALT_INV_ButtonRES~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \Segment1c~reg0_regout\);

-- Location: LC_X3_Y2_N9
\Segment2a~0\ : maxv_lcell
-- Equation(s):
-- \Segment2a~0_combout\ = (!\ButtonRES~combout\ & (((\Equal0~0_combout\) # (!\Stop~regout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "5055",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ButtonRES~combout\,
	datac => \Equal0~0_combout\,
	datad => \Stop~regout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Segment2a~0_combout\);

-- Location: LC_X2_Y2_N3
\Segment2a~reg0\ : maxv_lcell
-- Equation(s):
-- \Segment2a~reg0_regout\ = DFFEAS((((\validation:tmpDisplay2[0]~regout\))), GLOBAL(\clk_Button~combout\), VCC, , \Segment2a~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "ff00",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	datad => \validation:tmpDisplay2[0]~regout\,
	aclr => GND,
	ena => \Segment2a~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \Segment2a~reg0_regout\);

-- Location: LC_X2_Y2_N5
\Segment2b~reg0\ : maxv_lcell
-- Equation(s):
-- \Segment2b~reg0_regout\ = DFFEAS((((\validation:tmpDisplay2[1]~regout\))), GLOBAL(\clk_Button~combout\), VCC, , \Segment2a~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "ff00",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	datad => \validation:tmpDisplay2[1]~regout\,
	aclr => GND,
	ena => \Segment2a~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \Segment2b~reg0_regout\);

-- Location: LC_X2_Y2_N8
\Segment2c~reg0\ : maxv_lcell
-- Equation(s):
-- \Segment2c~reg0_regout\ = DFFEAS(GND, GLOBAL(\clk_Button~combout\), VCC, , \Segment2a~0_combout\, \validation:tmpDisplay2[2]~regout\, , , VCC)

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "on")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	datac => \validation:tmpDisplay2[2]~regout\,
	aclr => GND,
	sload => VCC,
	ena => \Segment2a~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \Segment2c~reg0_regout\);

-- Location: LC_X2_Y2_N6
\Segment2d~reg0\ : maxv_lcell
-- Equation(s):
-- \Segment2d~reg0_regout\ = DFFEAS((((\validation:tmpDisplay2[3]~regout\))), GLOBAL(\clk_Button~combout\), VCC, , \Segment2a~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "ff00",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk_Button~combout\,
	datad => \validation:tmpDisplay2[3]~regout\,
	aclr => GND,
	ena => \Segment2a~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \Segment2d~reg0_regout\);

-- Location: PIN_24,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: 16mA
\RGB0_red~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \ALT_INV_RGB0_state.Red~regout\,
	oe => VCC,
	padio => ww_RGB0_red);

-- Location: PIN_26,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: 16mA
\RGB0_green~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \RGB0_state.Green~regout\,
	oe => VCC,
	padio => ww_RGB0_green);

-- Location: PIN_25,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: 16mA
\RGB0_blue~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \RGB0_state.Blue~regout\,
	oe => VCC,
	padio => ww_RGB0_blue);

-- Location: PIN_20,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: 16mA
\RGB1_red~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \ALT_INV_RGB1_state.Red~regout\,
	oe => VCC,
	padio => ww_RGB1_red);

-- Location: PIN_22,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: 16mA
\RGB1_green~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \RGB1_state.Green~regout\,
	oe => VCC,
	padio => ww_RGB1_green);

-- Location: PIN_21,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: 16mA
\RGB1_blue~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \RGB1_state.Blue~regout\,
	oe => VCC,
	padio => ww_RGB1_blue);

-- Location: PIN_13,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: 16mA
\RGB2_red~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \ALT_INV_RGB2_state.Red~regout\,
	oe => VCC,
	padio => ww_RGB2_red);

-- Location: PIN_19,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: 16mA
\RGB2_green~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \RGB2_state.Green~regout\,
	oe => VCC,
	padio => ww_RGB2_green);

-- Location: PIN_18,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: 16mA
\RGB2_blue~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \RGB2_state.Blue~regout\,
	oe => VCC,
	padio => ww_RGB2_blue);

-- Location: PIN_5,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: 16mA
\RGB3_red~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \ALT_INV_RGB3_state.Red~regout\,
	oe => VCC,
	padio => ww_RGB3_red);

-- Location: PIN_12,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: 16mA
\RGB3_green~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \RGB3_state.Green~regout\,
	oe => VCC,
	padio => ww_RGB3_green);

-- Location: PIN_11,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: 16mA
\RGB3_blue~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \RGB3_state.Blue~regout\,
	oe => VCC,
	padio => ww_RGB3_blue);

-- Location: PIN_1,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: 16mA
\Segment1a~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \Segment1a~reg0_regout\,
	oe => VCC,
	padio => ww_Segment1a);

-- Location: PIN_2,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: 16mA
\Segment1b~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \Segment1b~reg0_regout\,
	oe => VCC,
	padio => ww_Segment1b);

-- Location: PIN_3,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: 16mA
\Segment1c~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \Segment1c~reg0_regout\,
	oe => VCC,
	padio => ww_Segment1c);

-- Location: PIN_4,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: 16mA
\Segment1d~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => GND,
	oe => VCC,
	padio => ww_Segment1d);

-- Location: PIN_63,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: 16mA
\Segment2a~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \Segment2a~reg0_regout\,
	oe => VCC,
	padio => ww_Segment2a);

-- Location: PIN_62,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: 16mA
\Segment2b~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \Segment2b~reg0_regout\,
	oe => VCC,
	padio => ww_Segment2b);

-- Location: PIN_61,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: 16mA
\Segment2c~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \Segment2c~reg0_regout\,
	oe => VCC,
	padio => ww_Segment2c);

-- Location: PIN_60,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: 16mA
\Segment2d~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \Segment2d~reg0_regout\,
	oe => VCC,
	padio => ww_Segment2d);
END structure;


