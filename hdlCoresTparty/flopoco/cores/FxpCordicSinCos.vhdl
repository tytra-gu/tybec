--------------------------------------------------------------------------------
--                        CordicSinCos_23_23_F300_uid2
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Matei Istoan, Florent de Dinechin (2012-...)
--------------------------------------------------------------------------------
-- Pipeline depth: 9 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity CordicSinCos_23_23_F300_uid2 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(23 downto 0);
          C : out  std_logic_vector(23 downto 0);
          S : out  std_logic_vector(23 downto 0)   );
end entity;

architecture arch of CordicSinCos_23_23_F300_uid2 is
signal sgn :  std_logic;
signal q :  std_logic;
signal o :  std_logic;
signal sqo :  std_logic_vector(2 downto 0);
signal qrot0 :  std_logic_vector(2 downto 0);
signal qrot, qrot_d1, qrot_d2, qrot_d3, qrot_d4, qrot_d5, qrot_d6, qrot_d7, qrot_d8 :  std_logic_vector(1 downto 0);
signal Yp :  std_logic_vector(27 downto 0);
signal Cos1 :  std_logic_vector(28 downto 0);
signal Sin1 :  std_logic_vector(28 downto 0);
signal Z1 :  std_logic_vector(27 downto 0);
signal D1 :  std_logic;
signal CosShift1 :  std_logic_vector(28 downto 0);
signal sgnSin1 :  std_logic;
signal SinShift1 :  std_logic_vector(28 downto 0);
signal CosShiftRoundBit1 :  std_logic;
signal SinShiftRoundBit1 :  std_logic;
signal CosShiftNeg1 :  std_logic_vector(28 downto 0);
signal SinShiftNeg1 :  std_logic_vector(28 downto 0);
signal Cos2, Cos2_d1 :  std_logic_vector(28 downto 0);
signal Sin2, Sin2_d1 :  std_logic_vector(28 downto 0);
signal atan2PowStage1 :  std_logic_vector(27 downto 0);
signal fullZ2 :  std_logic_vector(27 downto 0);
signal Z2, Z2_d1 :  std_logic_vector(26 downto 0);
signal D2, D2_d1 :  std_logic;
signal CosShift2, CosShift2_d1 :  std_logic_vector(28 downto 0);
signal sgnSin2 :  std_logic;
signal SinShift2, SinShift2_d1 :  std_logic_vector(28 downto 0);
signal CosShiftRoundBit2 :  std_logic;
signal SinShiftRoundBit2 :  std_logic;
signal CosShiftNeg2 :  std_logic_vector(28 downto 0);
signal SinShiftNeg2 :  std_logic_vector(28 downto 0);
signal Cos3 :  std_logic_vector(28 downto 0);
signal Sin3 :  std_logic_vector(28 downto 0);
signal atan2PowStage2 :  std_logic_vector(26 downto 0);
signal fullZ3 :  std_logic_vector(26 downto 0);
signal Z3 :  std_logic_vector(25 downto 0);
signal D3 :  std_logic;
signal CosShift3 :  std_logic_vector(28 downto 0);
signal sgnSin3 :  std_logic;
signal SinShift3 :  std_logic_vector(28 downto 0);
signal CosShiftRoundBit3 :  std_logic;
signal SinShiftRoundBit3 :  std_logic;
signal CosShiftNeg3 :  std_logic_vector(28 downto 0);
signal SinShiftNeg3 :  std_logic_vector(28 downto 0);
signal Cos4 :  std_logic_vector(28 downto 0);
signal Sin4 :  std_logic_vector(28 downto 0);
signal atan2PowStage3 :  std_logic_vector(25 downto 0);
signal fullZ4 :  std_logic_vector(25 downto 0);
signal Z4 :  std_logic_vector(24 downto 0);
signal D4 :  std_logic;
signal CosShift4 :  std_logic_vector(28 downto 0);
signal sgnSin4 :  std_logic;
signal SinShift4 :  std_logic_vector(28 downto 0);
signal CosShiftRoundBit4 :  std_logic;
signal SinShiftRoundBit4 :  std_logic;
signal CosShiftNeg4 :  std_logic_vector(28 downto 0);
signal SinShiftNeg4 :  std_logic_vector(28 downto 0);
signal Cos5, Cos5_d1 :  std_logic_vector(28 downto 0);
signal Sin5, Sin5_d1 :  std_logic_vector(28 downto 0);
signal atan2PowStage4 :  std_logic_vector(24 downto 0);
signal fullZ5 :  std_logic_vector(24 downto 0);
signal Z5, Z5_d1 :  std_logic_vector(23 downto 0);
signal D5, D5_d1 :  std_logic;
signal CosShift5, CosShift5_d1 :  std_logic_vector(28 downto 0);
signal sgnSin5 :  std_logic;
signal SinShift5, SinShift5_d1 :  std_logic_vector(28 downto 0);
signal CosShiftRoundBit5 :  std_logic;
signal SinShiftRoundBit5 :  std_logic;
signal CosShiftNeg5 :  std_logic_vector(28 downto 0);
signal SinShiftNeg5 :  std_logic_vector(28 downto 0);
signal Cos6 :  std_logic_vector(28 downto 0);
signal Sin6 :  std_logic_vector(28 downto 0);
signal atan2PowStage5 :  std_logic_vector(23 downto 0);
signal fullZ6 :  std_logic_vector(23 downto 0);
signal Z6 :  std_logic_vector(22 downto 0);
signal D6 :  std_logic;
signal CosShift6 :  std_logic_vector(28 downto 0);
signal sgnSin6 :  std_logic;
signal SinShift6 :  std_logic_vector(28 downto 0);
signal CosShiftRoundBit6 :  std_logic;
signal SinShiftRoundBit6 :  std_logic;
signal CosShiftNeg6 :  std_logic_vector(28 downto 0);
signal SinShiftNeg6 :  std_logic_vector(28 downto 0);
signal Cos7 :  std_logic_vector(28 downto 0);
signal Sin7 :  std_logic_vector(28 downto 0);
signal atan2PowStage6 :  std_logic_vector(22 downto 0);
signal fullZ7 :  std_logic_vector(22 downto 0);
signal Z7 :  std_logic_vector(21 downto 0);
signal D7 :  std_logic;
signal CosShift7 :  std_logic_vector(28 downto 0);
signal sgnSin7 :  std_logic;
signal SinShift7 :  std_logic_vector(28 downto 0);
signal CosShiftRoundBit7 :  std_logic;
signal SinShiftRoundBit7 :  std_logic;
signal CosShiftNeg7 :  std_logic_vector(28 downto 0);
signal SinShiftNeg7 :  std_logic_vector(28 downto 0);
signal Cos8, Cos8_d1 :  std_logic_vector(28 downto 0);
signal Sin8, Sin8_d1 :  std_logic_vector(28 downto 0);
signal atan2PowStage7 :  std_logic_vector(21 downto 0);
signal fullZ8 :  std_logic_vector(21 downto 0);
signal Z8, Z8_d1 :  std_logic_vector(20 downto 0);
signal D8, D8_d1 :  std_logic;
signal CosShift8, CosShift8_d1 :  std_logic_vector(28 downto 0);
signal sgnSin8 :  std_logic;
signal SinShift8, SinShift8_d1 :  std_logic_vector(28 downto 0);
signal CosShiftRoundBit8 :  std_logic;
signal SinShiftRoundBit8 :  std_logic;
signal CosShiftNeg8 :  std_logic_vector(28 downto 0);
signal SinShiftNeg8 :  std_logic_vector(28 downto 0);
signal Cos9 :  std_logic_vector(28 downto 0);
signal Sin9 :  std_logic_vector(28 downto 0);
signal atan2PowStage8 :  std_logic_vector(20 downto 0);
signal fullZ9 :  std_logic_vector(20 downto 0);
signal Z9 :  std_logic_vector(19 downto 0);
signal D9 :  std_logic;
signal CosShift9 :  std_logic_vector(28 downto 0);
signal sgnSin9 :  std_logic;
signal SinShift9 :  std_logic_vector(28 downto 0);
signal CosShiftRoundBit9 :  std_logic;
signal SinShiftRoundBit9 :  std_logic;
signal CosShiftNeg9 :  std_logic_vector(28 downto 0);
signal SinShiftNeg9 :  std_logic_vector(28 downto 0);
signal Cos10 :  std_logic_vector(28 downto 0);
signal Sin10 :  std_logic_vector(28 downto 0);
signal atan2PowStage9 :  std_logic_vector(19 downto 0);
signal fullZ10 :  std_logic_vector(19 downto 0);
signal Z10 :  std_logic_vector(18 downto 0);
signal D10 :  std_logic;
signal CosShift10 :  std_logic_vector(28 downto 0);
signal sgnSin10 :  std_logic;
signal SinShift10 :  std_logic_vector(28 downto 0);
signal CosShiftRoundBit10 :  std_logic;
signal SinShiftRoundBit10 :  std_logic;
signal CosShiftNeg10 :  std_logic_vector(28 downto 0);
signal SinShiftNeg10 :  std_logic_vector(28 downto 0);
signal Cos11, Cos11_d1 :  std_logic_vector(28 downto 0);
signal Sin11, Sin11_d1 :  std_logic_vector(28 downto 0);
signal atan2PowStage10 :  std_logic_vector(18 downto 0);
signal fullZ11 :  std_logic_vector(18 downto 0);
signal Z11, Z11_d1 :  std_logic_vector(17 downto 0);
signal D11, D11_d1 :  std_logic;
signal CosShift11, CosShift11_d1 :  std_logic_vector(28 downto 0);
signal sgnSin11 :  std_logic;
signal SinShift11, SinShift11_d1 :  std_logic_vector(28 downto 0);
signal CosShiftRoundBit11 :  std_logic;
signal SinShiftRoundBit11 :  std_logic;
signal CosShiftNeg11 :  std_logic_vector(28 downto 0);
signal SinShiftNeg11 :  std_logic_vector(28 downto 0);
signal Cos12 :  std_logic_vector(28 downto 0);
signal Sin12 :  std_logic_vector(28 downto 0);
signal atan2PowStage11 :  std_logic_vector(17 downto 0);
signal fullZ12 :  std_logic_vector(17 downto 0);
signal Z12 :  std_logic_vector(16 downto 0);
signal D12 :  std_logic;
signal CosShift12 :  std_logic_vector(28 downto 0);
signal sgnSin12 :  std_logic;
signal SinShift12 :  std_logic_vector(28 downto 0);
signal CosShiftRoundBit12 :  std_logic;
signal SinShiftRoundBit12 :  std_logic;
signal CosShiftNeg12 :  std_logic_vector(28 downto 0);
signal SinShiftNeg12 :  std_logic_vector(28 downto 0);
signal Cos13 :  std_logic_vector(28 downto 0);
signal Sin13 :  std_logic_vector(28 downto 0);
signal atan2PowStage12 :  std_logic_vector(16 downto 0);
signal fullZ13 :  std_logic_vector(16 downto 0);
signal Z13 :  std_logic_vector(15 downto 0);
signal D13 :  std_logic;
signal CosShift13 :  std_logic_vector(28 downto 0);
signal sgnSin13 :  std_logic;
signal SinShift13 :  std_logic_vector(28 downto 0);
signal CosShiftRoundBit13 :  std_logic;
signal SinShiftRoundBit13 :  std_logic;
signal CosShiftNeg13 :  std_logic_vector(28 downto 0);
signal SinShiftNeg13 :  std_logic_vector(28 downto 0);
signal Cos14, Cos14_d1 :  std_logic_vector(28 downto 0);
signal Sin14, Sin14_d1 :  std_logic_vector(28 downto 0);
signal atan2PowStage13 :  std_logic_vector(15 downto 0);
signal fullZ14 :  std_logic_vector(15 downto 0);
signal Z14, Z14_d1 :  std_logic_vector(14 downto 0);
signal D14, D14_d1 :  std_logic;
signal CosShift14, CosShift14_d1 :  std_logic_vector(28 downto 0);
signal sgnSin14 :  std_logic;
signal SinShift14, SinShift14_d1 :  std_logic_vector(28 downto 0);
signal CosShiftRoundBit14 :  std_logic;
signal SinShiftRoundBit14 :  std_logic;
signal CosShiftNeg14 :  std_logic_vector(28 downto 0);
signal SinShiftNeg14 :  std_logic_vector(28 downto 0);
signal Cos15 :  std_logic_vector(28 downto 0);
signal Sin15 :  std_logic_vector(28 downto 0);
signal atan2PowStage14 :  std_logic_vector(14 downto 0);
signal fullZ15 :  std_logic_vector(14 downto 0);
signal Z15 :  std_logic_vector(13 downto 0);
signal D15 :  std_logic;
signal CosShift15 :  std_logic_vector(28 downto 0);
signal sgnSin15 :  std_logic;
signal SinShift15 :  std_logic_vector(28 downto 0);
signal CosShiftRoundBit15 :  std_logic;
signal SinShiftRoundBit15 :  std_logic;
signal CosShiftNeg15 :  std_logic_vector(28 downto 0);
signal SinShiftNeg15 :  std_logic_vector(28 downto 0);
signal Cos16 :  std_logic_vector(28 downto 0);
signal Sin16 :  std_logic_vector(28 downto 0);
signal atan2PowStage15 :  std_logic_vector(13 downto 0);
signal fullZ16 :  std_logic_vector(13 downto 0);
signal Z16 :  std_logic_vector(12 downto 0);
signal D16 :  std_logic;
signal CosShift16 :  std_logic_vector(28 downto 0);
signal sgnSin16 :  std_logic;
signal SinShift16 :  std_logic_vector(28 downto 0);
signal CosShiftRoundBit16 :  std_logic;
signal SinShiftRoundBit16 :  std_logic;
signal CosShiftNeg16 :  std_logic_vector(28 downto 0);
signal SinShiftNeg16 :  std_logic_vector(28 downto 0);
signal Cos17, Cos17_d1 :  std_logic_vector(28 downto 0);
signal Sin17, Sin17_d1 :  std_logic_vector(28 downto 0);
signal atan2PowStage16 :  std_logic_vector(12 downto 0);
signal fullZ17 :  std_logic_vector(12 downto 0);
signal Z17, Z17_d1 :  std_logic_vector(11 downto 0);
signal D17, D17_d1 :  std_logic;
signal CosShift17, CosShift17_d1 :  std_logic_vector(28 downto 0);
signal sgnSin17 :  std_logic;
signal SinShift17, SinShift17_d1 :  std_logic_vector(28 downto 0);
signal CosShiftRoundBit17 :  std_logic;
signal SinShiftRoundBit17 :  std_logic;
signal CosShiftNeg17 :  std_logic_vector(28 downto 0);
signal SinShiftNeg17 :  std_logic_vector(28 downto 0);
signal Cos18 :  std_logic_vector(28 downto 0);
signal Sin18 :  std_logic_vector(28 downto 0);
signal atan2PowStage17 :  std_logic_vector(11 downto 0);
signal fullZ18 :  std_logic_vector(11 downto 0);
signal Z18 :  std_logic_vector(10 downto 0);
signal D18 :  std_logic;
signal CosShift18 :  std_logic_vector(28 downto 0);
signal sgnSin18 :  std_logic;
signal SinShift18 :  std_logic_vector(28 downto 0);
signal CosShiftRoundBit18 :  std_logic;
signal SinShiftRoundBit18 :  std_logic;
signal CosShiftNeg18 :  std_logic_vector(28 downto 0);
signal SinShiftNeg18 :  std_logic_vector(28 downto 0);
signal Cos19 :  std_logic_vector(28 downto 0);
signal Sin19 :  std_logic_vector(28 downto 0);
signal atan2PowStage18 :  std_logic_vector(10 downto 0);
signal fullZ19 :  std_logic_vector(10 downto 0);
signal Z19 :  std_logic_vector(9 downto 0);
signal D19 :  std_logic;
signal CosShift19 :  std_logic_vector(28 downto 0);
signal sgnSin19 :  std_logic;
signal SinShift19 :  std_logic_vector(28 downto 0);
signal CosShiftRoundBit19 :  std_logic;
signal SinShiftRoundBit19 :  std_logic;
signal CosShiftNeg19 :  std_logic_vector(28 downto 0);
signal SinShiftNeg19 :  std_logic_vector(28 downto 0);
signal Cos20, Cos20_d1 :  std_logic_vector(28 downto 0);
signal Sin20, Sin20_d1 :  std_logic_vector(28 downto 0);
signal atan2PowStage19 :  std_logic_vector(9 downto 0);
signal fullZ20 :  std_logic_vector(9 downto 0);
signal Z20, Z20_d1 :  std_logic_vector(8 downto 0);
signal D20, D20_d1 :  std_logic;
signal CosShift20, CosShift20_d1 :  std_logic_vector(28 downto 0);
signal sgnSin20 :  std_logic;
signal SinShift20, SinShift20_d1 :  std_logic_vector(28 downto 0);
signal CosShiftRoundBit20 :  std_logic;
signal SinShiftRoundBit20 :  std_logic;
signal CosShiftNeg20 :  std_logic_vector(28 downto 0);
signal SinShiftNeg20 :  std_logic_vector(28 downto 0);
signal Cos21 :  std_logic_vector(28 downto 0);
signal Sin21 :  std_logic_vector(28 downto 0);
signal atan2PowStage20 :  std_logic_vector(8 downto 0);
signal fullZ21 :  std_logic_vector(8 downto 0);
signal Z21 :  std_logic_vector(7 downto 0);
signal D21 :  std_logic;
signal CosShift21 :  std_logic_vector(28 downto 0);
signal sgnSin21 :  std_logic;
signal SinShift21 :  std_logic_vector(28 downto 0);
signal CosShiftRoundBit21 :  std_logic;
signal SinShiftRoundBit21 :  std_logic;
signal CosShiftNeg21 :  std_logic_vector(28 downto 0);
signal SinShiftNeg21 :  std_logic_vector(28 downto 0);
signal Cos22 :  std_logic_vector(28 downto 0);
signal Sin22 :  std_logic_vector(28 downto 0);
signal atan2PowStage21 :  std_logic_vector(7 downto 0);
signal fullZ22 :  std_logic_vector(7 downto 0);
signal Z22 :  std_logic_vector(6 downto 0);
signal D22 :  std_logic;
signal CosShift22 :  std_logic_vector(28 downto 0);
signal sgnSin22 :  std_logic;
signal SinShift22 :  std_logic_vector(28 downto 0);
signal CosShiftRoundBit22 :  std_logic;
signal SinShiftRoundBit22 :  std_logic;
signal CosShiftNeg22 :  std_logic_vector(28 downto 0);
signal SinShiftNeg22 :  std_logic_vector(28 downto 0);
signal Cos23 :  std_logic_vector(28 downto 0);
signal Sin23 :  std_logic_vector(28 downto 0);
signal atan2PowStage22 :  std_logic_vector(6 downto 0);
signal fullZ23 :  std_logic_vector(6 downto 0);
signal Z23 :  std_logic_vector(5 downto 0);
signal D23 :  std_logic;
signal CosShift23 :  std_logic_vector(28 downto 0);
signal sgnSin23 :  std_logic;
signal SinShift23 :  std_logic_vector(28 downto 0);
signal CosShiftRoundBit23 :  std_logic;
signal SinShiftRoundBit23 :  std_logic;
signal CosShiftNeg23 :  std_logic_vector(28 downto 0);
signal SinShiftNeg23 :  std_logic_vector(28 downto 0);
signal Cos24, Cos24_d1 :  std_logic_vector(28 downto 0);
signal Sin24, Sin24_d1 :  std_logic_vector(28 downto 0);
signal atan2PowStage23 :  std_logic_vector(5 downto 0);
signal fullZ24 :  std_logic_vector(5 downto 0);
signal Z24, Z24_d1 :  std_logic_vector(4 downto 0);
signal D24, D24_d1 :  std_logic;
signal CosShift24, CosShift24_d1 :  std_logic_vector(28 downto 0);
signal sgnSin24 :  std_logic;
signal SinShift24, SinShift24_d1 :  std_logic_vector(28 downto 0);
signal CosShiftRoundBit24 :  std_logic;
signal SinShiftRoundBit24 :  std_logic;
signal CosShiftNeg24 :  std_logic_vector(28 downto 0);
signal SinShiftNeg24 :  std_logic_vector(28 downto 0);
signal Cos25 :  std_logic_vector(28 downto 0);
signal Sin25 :  std_logic_vector(28 downto 0);
signal atan2PowStage24 :  std_logic_vector(4 downto 0);
signal fullZ25 :  std_logic_vector(4 downto 0);
signal Z25 :  std_logic_vector(3 downto 0);
signal D25 :  std_logic;
signal CosShift25 :  std_logic_vector(28 downto 0);
signal sgnSin25 :  std_logic;
signal SinShift25 :  std_logic_vector(28 downto 0);
signal CosShiftRoundBit25 :  std_logic;
signal SinShiftRoundBit25 :  std_logic;
signal CosShiftNeg25 :  std_logic_vector(28 downto 0);
signal SinShiftNeg25 :  std_logic_vector(28 downto 0);
signal Cos26 :  std_logic_vector(28 downto 0);
signal Sin26 :  std_logic_vector(28 downto 0);
signal redCos :  std_logic_vector(28 downto 0);
signal redSin :  std_logic_vector(28 downto 0);
signal redCosNeg :  std_logic_vector(28 downto 0);
signal redSinNeg :  std_logic_vector(28 downto 0);
signal CosX0, CosX0_d1 :  std_logic_vector(28 downto 0);
signal SinX0, SinX0_d1 :  std_logic_vector(28 downto 0);
signal roundedCosX :  std_logic_vector(24 downto 0);
signal roundedSinX :  std_logic_vector(24 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            qrot_d1 <=  qrot;
            qrot_d2 <=  qrot_d1;
            qrot_d3 <=  qrot_d2;
            qrot_d4 <=  qrot_d3;
            qrot_d5 <=  qrot_d4;
            qrot_d6 <=  qrot_d5;
            qrot_d7 <=  qrot_d6;
            qrot_d8 <=  qrot_d7;
            Cos2_d1 <=  Cos2;
            Sin2_d1 <=  Sin2;
            Z2_d1 <=  Z2;
            D2_d1 <=  D2;
            CosShift2_d1 <=  CosShift2;
            SinShift2_d1 <=  SinShift2;
            Cos5_d1 <=  Cos5;
            Sin5_d1 <=  Sin5;
            Z5_d1 <=  Z5;
            D5_d1 <=  D5;
            CosShift5_d1 <=  CosShift5;
            SinShift5_d1 <=  SinShift5;
            Cos8_d1 <=  Cos8;
            Sin8_d1 <=  Sin8;
            Z8_d1 <=  Z8;
            D8_d1 <=  D8;
            CosShift8_d1 <=  CosShift8;
            SinShift8_d1 <=  SinShift8;
            Cos11_d1 <=  Cos11;
            Sin11_d1 <=  Sin11;
            Z11_d1 <=  Z11;
            D11_d1 <=  D11;
            CosShift11_d1 <=  CosShift11;
            SinShift11_d1 <=  SinShift11;
            Cos14_d1 <=  Cos14;
            Sin14_d1 <=  Sin14;
            Z14_d1 <=  Z14;
            D14_d1 <=  D14;
            CosShift14_d1 <=  CosShift14;
            SinShift14_d1 <=  SinShift14;
            Cos17_d1 <=  Cos17;
            Sin17_d1 <=  Sin17;
            Z17_d1 <=  Z17;
            D17_d1 <=  D17;
            CosShift17_d1 <=  CosShift17;
            SinShift17_d1 <=  SinShift17;
            Cos20_d1 <=  Cos20;
            Sin20_d1 <=  Sin20;
            Z20_d1 <=  Z20;
            D20_d1 <=  D20;
            CosShift20_d1 <=  CosShift20;
            SinShift20_d1 <=  SinShift20;
            Cos24_d1 <=  Cos24;
            Sin24_d1 <=  Sin24;
            Z24_d1 <=  Z24;
            D24_d1 <=  D24;
            CosShift24_d1 <=  CosShift24;
            SinShift24_d1 <=  SinShift24;
            CosX0_d1 <=  CosX0;
            SinX0_d1 <=  SinX0;
         end if;
      end process;
   sgn <= X(23);  -- sign
   q <= X(22);  -- quadrant
   o <= X(21);  -- octant
   sqo <= sgn & q & o;  -- sign, quadrant, octant
   qrot0 <= sqo +  "001"; -- rotate by an octant
   qrot <= qrot0(2 downto 1); -- new quadrant: 00 is the two octants around the origin
   Yp<= X(21 downto 0) & "000000";
   --  This Yp is in -pi/4, pi/4. Now start CORDIC with angle atan(1/2)
   Cos1 <= "01101101111011001010110010110";-- scale factor, about 1668335359399035750495707645325093723600924024491159887514859730869878231234178489585b-280
   Sin1 <= "00000000000000000000000000000";
   Z1<= Yp;
   D1<= Yp(27);
   CosShift1 <= "0" & Cos1(28 downto 1);
   sgnSin1 <= Sin1(28);
   SinShift1 <= (28 downto 28 => sgnSin1) & Sin1(28 downto 1);
   CosShiftRoundBit1 <= Cos1(0);
   SinShiftRoundBit1 <= Sin1(0);
   CosShiftNeg1 <= (28 downto 0 => D1) xor CosShift1 ;
   SinShiftNeg1 <= (not (28 downto 0 => D1)) xor SinShift1 ;
   Cos2 <= Cos1 + SinShiftNeg1 +  not (D1 xor SinShiftRoundBit1) ;
   Sin2 <= Sin1 + CosShiftNeg1 + (D1 xor CosShiftRoundBit1) ;
   atan2PowStage1 <= "0100101110010000000101000111";
   fullZ2 <= Z1 + atan2PowStage1 when D1='1' else Z1 - atan2PowStage1 ;
   Z2 <= fullZ2(26 downto 0);
   D2 <= fullZ2(27);
   CosShift2 <= "00" & Cos2(28 downto 2);
   sgnSin2 <= Sin2(28);
   SinShift2 <= (28 downto 27 => sgnSin2) & Sin2(28 downto 2);
   ----------------Synchro barrier, entering cycle 1----------------
   CosShiftRoundBit2 <= Cos2_d1(1);
   SinShiftRoundBit2 <= Sin2_d1(1);
   CosShiftNeg2 <= (28 downto 0 => D2_d1) xor CosShift2_d1 ;
   SinShiftNeg2 <= (not (28 downto 0 => D2_d1)) xor SinShift2_d1 ;
   Cos3 <= Cos2_d1 + SinShiftNeg2 +  not (D2_d1 xor SinShiftRoundBit2) ;
   Sin3 <= Sin2_d1 + CosShiftNeg2 + (D2_d1 xor CosShiftRoundBit2) ;
   atan2PowStage2 <= "010011111101100111000010111";
   fullZ3 <= Z2_d1 + atan2PowStage2 when D2_d1='1' else Z2_d1 - atan2PowStage2 ;
   Z3 <= fullZ3(25 downto 0);
   D3 <= fullZ3(26);
   CosShift3 <= "000" & Cos3(28 downto 3);
   sgnSin3 <= Sin3(28);
   SinShift3 <= (28 downto 26 => sgnSin3) & Sin3(28 downto 3);
   CosShiftRoundBit3 <= Cos3(2);
   SinShiftRoundBit3 <= Sin3(2);
   CosShiftNeg3 <= (28 downto 0 => D3) xor CosShift3 ;
   SinShiftNeg3 <= (not (28 downto 0 => D3)) xor SinShift3 ;
   Cos4 <= Cos3 + SinShiftNeg3 +  not (D3 xor SinShiftRoundBit3) ;
   Sin4 <= Sin3 + CosShiftNeg3 + (D3 xor CosShiftRoundBit3) ;
   atan2PowStage3 <= "01010001000100010001110101";
   fullZ4 <= Z3 + atan2PowStage3 when D3='1' else Z3 - atan2PowStage3 ;
   Z4 <= fullZ4(24 downto 0);
   D4 <= fullZ4(25);
   CosShift4 <= "0000" & Cos4(28 downto 4);
   sgnSin4 <= Sin4(28);
   SinShift4 <= (28 downto 25 => sgnSin4) & Sin4(28 downto 4);
   CosShiftRoundBit4 <= Cos4(3);
   SinShiftRoundBit4 <= Sin4(3);
   CosShiftNeg4 <= (28 downto 0 => D4) xor CosShift4 ;
   SinShiftNeg4 <= (not (28 downto 0 => D4)) xor SinShift4 ;
   Cos5 <= Cos4 + SinShiftNeg4 +  not (D4 xor SinShiftRoundBit4) ;
   Sin5 <= Sin4 + CosShiftNeg4 + (D4 xor CosShiftRoundBit4) ;
   atan2PowStage4 <= "0101000101100001101010001";
   fullZ5 <= Z4 + atan2PowStage4 when D4='1' else Z4 - atan2PowStage4 ;
   Z5 <= fullZ5(23 downto 0);
   D5 <= fullZ5(24);
   CosShift5 <= "00000" & Cos5(28 downto 5);
   sgnSin5 <= Sin5(28);
   SinShift5 <= (28 downto 24 => sgnSin5) & Sin5(28 downto 5);
   ----------------Synchro barrier, entering cycle 2----------------
   CosShiftRoundBit5 <= Cos5_d1(4);
   SinShiftRoundBit5 <= Sin5_d1(4);
   CosShiftNeg5 <= (28 downto 0 => D5_d1) xor CosShift5_d1 ;
   SinShiftNeg5 <= (not (28 downto 0 => D5_d1)) xor SinShift5_d1 ;
   Cos6 <= Cos5_d1 + SinShiftNeg5 +  not (D5_d1 xor SinShiftRoundBit5) ;
   Sin6 <= Sin5_d1 + CosShiftNeg5 + (D5_d1 xor CosShiftRoundBit5) ;
   atan2PowStage5 <= "010100010111010111111000";
   fullZ6 <= Z5_d1 + atan2PowStage5 when D5_d1='1' else Z5_d1 - atan2PowStage5 ;
   Z6 <= fullZ6(22 downto 0);
   D6 <= fullZ6(23);
   CosShift6 <= "000000" & Cos6(28 downto 6);
   sgnSin6 <= Sin6(28);
   SinShift6 <= (28 downto 23 => sgnSin6) & Sin6(28 downto 6);
   CosShiftRoundBit6 <= Cos6(5);
   SinShiftRoundBit6 <= Sin6(5);
   CosShiftNeg6 <= (28 downto 0 => D6) xor CosShift6 ;
   SinShiftNeg6 <= (not (28 downto 0 => D6)) xor SinShift6 ;
   Cos7 <= Cos6 + SinShiftNeg6 +  not (D6 xor SinShiftRoundBit6) ;
   Sin7 <= Sin6 + CosShiftNeg6 + (D6 xor CosShiftRoundBit6) ;
   atan2PowStage6 <= "01010001011110110001000";
   fullZ7 <= Z6 + atan2PowStage6 when D6='1' else Z6 - atan2PowStage6 ;
   Z7 <= fullZ7(21 downto 0);
   D7 <= fullZ7(22);
   CosShift7 <= "0000000" & Cos7(28 downto 7);
   sgnSin7 <= Sin7(28);
   SinShift7 <= (28 downto 22 => sgnSin7) & Sin7(28 downto 7);
   CosShiftRoundBit7 <= Cos7(6);
   SinShiftRoundBit7 <= Sin7(6);
   CosShiftNeg7 <= (28 downto 0 => D7) xor CosShift7 ;
   SinShiftNeg7 <= (not (28 downto 0 => D7)) xor SinShift7 ;
   Cos8 <= Cos7 + SinShiftNeg7 +  not (D7 xor SinShiftRoundBit7) ;
   Sin8 <= Sin7 + CosShiftNeg7 + (D7 xor CosShiftRoundBit7) ;
   atan2PowStage7 <= "0101000101111100010101";
   fullZ8 <= Z7 + atan2PowStage7 when D7='1' else Z7 - atan2PowStage7 ;
   Z8 <= fullZ8(20 downto 0);
   D8 <= fullZ8(21);
   CosShift8 <= "00000000" & Cos8(28 downto 8);
   sgnSin8 <= Sin8(28);
   SinShift8 <= (28 downto 21 => sgnSin8) & Sin8(28 downto 8);
   ----------------Synchro barrier, entering cycle 3----------------
   CosShiftRoundBit8 <= Cos8_d1(7);
   SinShiftRoundBit8 <= Sin8_d1(7);
   CosShiftNeg8 <= (28 downto 0 => D8_d1) xor CosShift8_d1 ;
   SinShiftNeg8 <= (not (28 downto 0 => D8_d1)) xor SinShift8_d1 ;
   Cos9 <= Cos8_d1 + SinShiftNeg8 +  not (D8_d1 xor SinShiftRoundBit8) ;
   Sin9 <= Sin8_d1 + CosShiftNeg8 + (D8_d1 xor CosShiftRoundBit8) ;
   atan2PowStage8 <= "010100010111110010101";
   fullZ9 <= Z8_d1 + atan2PowStage8 when D8_d1='1' else Z8_d1 - atan2PowStage8 ;
   Z9 <= fullZ9(19 downto 0);
   D9 <= fullZ9(20);
   CosShift9 <= "000000000" & Cos9(28 downto 9);
   sgnSin9 <= Sin9(28);
   SinShift9 <= (28 downto 20 => sgnSin9) & Sin9(28 downto 9);
   CosShiftRoundBit9 <= Cos9(8);
   SinShiftRoundBit9 <= Sin9(8);
   CosShiftNeg9 <= (28 downto 0 => D9) xor CosShift9 ;
   SinShiftNeg9 <= (not (28 downto 0 => D9)) xor SinShift9 ;
   Cos10 <= Cos9 + SinShiftNeg9 +  not (D9 xor SinShiftRoundBit9) ;
   Sin10 <= Sin9 + CosShiftNeg9 + (D9 xor CosShiftRoundBit9) ;
   atan2PowStage9 <= "01010001011111001100";
   fullZ10 <= Z9 + atan2PowStage9 when D9='1' else Z9 - atan2PowStage9 ;
   Z10 <= fullZ10(18 downto 0);
   D10 <= fullZ10(19);
   CosShift10 <= "0000000000" & Cos10(28 downto 10);
   sgnSin10 <= Sin10(28);
   SinShift10 <= (28 downto 19 => sgnSin10) & Sin10(28 downto 10);
   CosShiftRoundBit10 <= Cos10(9);
   SinShiftRoundBit10 <= Sin10(9);
   CosShiftNeg10 <= (28 downto 0 => D10) xor CosShift10 ;
   SinShiftNeg10 <= (not (28 downto 0 => D10)) xor SinShift10 ;
   Cos11 <= Cos10 + SinShiftNeg10 +  not (D10 xor SinShiftRoundBit10) ;
   Sin11 <= Sin10 + CosShiftNeg10 + (D10 xor CosShiftRoundBit10) ;
   atan2PowStage10 <= "0101000101111100110";
   fullZ11 <= Z10 + atan2PowStage10 when D10='1' else Z10 - atan2PowStage10 ;
   Z11 <= fullZ11(17 downto 0);
   D11 <= fullZ11(18);
   CosShift11 <= "00000000000" & Cos11(28 downto 11);
   sgnSin11 <= Sin11(28);
   SinShift11 <= (28 downto 18 => sgnSin11) & Sin11(28 downto 11);
   ----------------Synchro barrier, entering cycle 4----------------
   CosShiftRoundBit11 <= Cos11_d1(10);
   SinShiftRoundBit11 <= Sin11_d1(10);
   CosShiftNeg11 <= (28 downto 0 => D11_d1) xor CosShift11_d1 ;
   SinShiftNeg11 <= (not (28 downto 0 => D11_d1)) xor SinShift11_d1 ;
   Cos12 <= Cos11_d1 + SinShiftNeg11 +  not (D11_d1 xor SinShiftRoundBit11) ;
   Sin12 <= Sin11_d1 + CosShiftNeg11 + (D11_d1 xor CosShiftRoundBit11) ;
   atan2PowStage11 <= "010100010111110011";
   fullZ12 <= Z11_d1 + atan2PowStage11 when D11_d1='1' else Z11_d1 - atan2PowStage11 ;
   Z12 <= fullZ12(16 downto 0);
   D12 <= fullZ12(17);
   CosShift12 <= "000000000000" & Cos12(28 downto 12);
   sgnSin12 <= Sin12(28);
   SinShift12 <= (28 downto 17 => sgnSin12) & Sin12(28 downto 12);
   CosShiftRoundBit12 <= Cos12(11);
   SinShiftRoundBit12 <= Sin12(11);
   CosShiftNeg12 <= (28 downto 0 => D12) xor CosShift12 ;
   SinShiftNeg12 <= (not (28 downto 0 => D12)) xor SinShift12 ;
   Cos13 <= Cos12 + SinShiftNeg12 +  not (D12 xor SinShiftRoundBit12) ;
   Sin13 <= Sin12 + CosShiftNeg12 + (D12 xor CosShiftRoundBit12) ;
   atan2PowStage12 <= "01010001011111010";
   fullZ13 <= Z12 + atan2PowStage12 when D12='1' else Z12 - atan2PowStage12 ;
   Z13 <= fullZ13(15 downto 0);
   D13 <= fullZ13(16);
   CosShift13 <= "0000000000000" & Cos13(28 downto 13);
   sgnSin13 <= Sin13(28);
   SinShift13 <= (28 downto 16 => sgnSin13) & Sin13(28 downto 13);
   CosShiftRoundBit13 <= Cos13(12);
   SinShiftRoundBit13 <= Sin13(12);
   CosShiftNeg13 <= (28 downto 0 => D13) xor CosShift13 ;
   SinShiftNeg13 <= (not (28 downto 0 => D13)) xor SinShift13 ;
   Cos14 <= Cos13 + SinShiftNeg13 +  not (D13 xor SinShiftRoundBit13) ;
   Sin14 <= Sin13 + CosShiftNeg13 + (D13 xor CosShiftRoundBit13) ;
   atan2PowStage13 <= "0101000101111101";
   fullZ14 <= Z13 + atan2PowStage13 when D13='1' else Z13 - atan2PowStage13 ;
   Z14 <= fullZ14(14 downto 0);
   D14 <= fullZ14(15);
   CosShift14 <= "00000000000000" & Cos14(28 downto 14);
   sgnSin14 <= Sin14(28);
   SinShift14 <= (28 downto 15 => sgnSin14) & Sin14(28 downto 14);
   ----------------Synchro barrier, entering cycle 5----------------
   CosShiftRoundBit14 <= Cos14_d1(13);
   SinShiftRoundBit14 <= Sin14_d1(13);
   CosShiftNeg14 <= (28 downto 0 => D14_d1) xor CosShift14_d1 ;
   SinShiftNeg14 <= (not (28 downto 0 => D14_d1)) xor SinShift14_d1 ;
   Cos15 <= Cos14_d1 + SinShiftNeg14 +  not (D14_d1 xor SinShiftRoundBit14) ;
   Sin15 <= Sin14_d1 + CosShiftNeg14 + (D14_d1 xor CosShiftRoundBit14) ;
   atan2PowStage14 <= "010100010111110";
   fullZ15 <= Z14_d1 + atan2PowStage14 when D14_d1='1' else Z14_d1 - atan2PowStage14 ;
   Z15 <= fullZ15(13 downto 0);
   D15 <= fullZ15(14);
   CosShift15 <= "000000000000000" & Cos15(28 downto 15);
   sgnSin15 <= Sin15(28);
   SinShift15 <= (28 downto 14 => sgnSin15) & Sin15(28 downto 15);
   CosShiftRoundBit15 <= Cos15(14);
   SinShiftRoundBit15 <= Sin15(14);
   CosShiftNeg15 <= (28 downto 0 => D15) xor CosShift15 ;
   SinShiftNeg15 <= (not (28 downto 0 => D15)) xor SinShift15 ;
   Cos16 <= Cos15 + SinShiftNeg15 +  not (D15 xor SinShiftRoundBit15) ;
   Sin16 <= Sin15 + CosShiftNeg15 + (D15 xor CosShiftRoundBit15) ;
   atan2PowStage15 <= "01010001011111";
   fullZ16 <= Z15 + atan2PowStage15 when D15='1' else Z15 - atan2PowStage15 ;
   Z16 <= fullZ16(12 downto 0);
   D16 <= fullZ16(13);
   CosShift16 <= "0000000000000000" & Cos16(28 downto 16);
   sgnSin16 <= Sin16(28);
   SinShift16 <= (28 downto 13 => sgnSin16) & Sin16(28 downto 16);
   CosShiftRoundBit16 <= Cos16(15);
   SinShiftRoundBit16 <= Sin16(15);
   CosShiftNeg16 <= (28 downto 0 => D16) xor CosShift16 ;
   SinShiftNeg16 <= (not (28 downto 0 => D16)) xor SinShift16 ;
   Cos17 <= Cos16 + SinShiftNeg16 +  not (D16 xor SinShiftRoundBit16) ;
   Sin17 <= Sin16 + CosShiftNeg16 + (D16 xor CosShiftRoundBit16) ;
   atan2PowStage16 <= "0101000110000";
   fullZ17 <= Z16 + atan2PowStage16 when D16='1' else Z16 - atan2PowStage16 ;
   Z17 <= fullZ17(11 downto 0);
   D17 <= fullZ17(12);
   CosShift17 <= "00000000000000000" & Cos17(28 downto 17);
   sgnSin17 <= Sin17(28);
   SinShift17 <= (28 downto 12 => sgnSin17) & Sin17(28 downto 17);
   ----------------Synchro barrier, entering cycle 6----------------
   CosShiftRoundBit17 <= Cos17_d1(16);
   SinShiftRoundBit17 <= Sin17_d1(16);
   CosShiftNeg17 <= (28 downto 0 => D17_d1) xor CosShift17_d1 ;
   SinShiftNeg17 <= (not (28 downto 0 => D17_d1)) xor SinShift17_d1 ;
   Cos18 <= Cos17_d1 + SinShiftNeg17 +  not (D17_d1 xor SinShiftRoundBit17) ;
   Sin18 <= Sin17_d1 + CosShiftNeg17 + (D17_d1 xor CosShiftRoundBit17) ;
   atan2PowStage17 <= "010100011000";
   fullZ18 <= Z17_d1 + atan2PowStage17 when D17_d1='1' else Z17_d1 - atan2PowStage17 ;
   Z18 <= fullZ18(10 downto 0);
   D18 <= fullZ18(11);
   CosShift18 <= "000000000000000000" & Cos18(28 downto 18);
   sgnSin18 <= Sin18(28);
   SinShift18 <= (28 downto 11 => sgnSin18) & Sin18(28 downto 18);
   CosShiftRoundBit18 <= Cos18(17);
   SinShiftRoundBit18 <= Sin18(17);
   CosShiftNeg18 <= (28 downto 0 => D18) xor CosShift18 ;
   SinShiftNeg18 <= (not (28 downto 0 => D18)) xor SinShift18 ;
   Cos19 <= Cos18 + SinShiftNeg18 +  not (D18 xor SinShiftRoundBit18) ;
   Sin19 <= Sin18 + CosShiftNeg18 + (D18 xor CosShiftRoundBit18) ;
   atan2PowStage18 <= "01010001100";
   fullZ19 <= Z18 + atan2PowStage18 when D18='1' else Z18 - atan2PowStage18 ;
   Z19 <= fullZ19(9 downto 0);
   D19 <= fullZ19(10);
   CosShift19 <= "0000000000000000000" & Cos19(28 downto 19);
   sgnSin19 <= Sin19(28);
   SinShift19 <= (28 downto 10 => sgnSin19) & Sin19(28 downto 19);
   CosShiftRoundBit19 <= Cos19(18);
   SinShiftRoundBit19 <= Sin19(18);
   CosShiftNeg19 <= (28 downto 0 => D19) xor CosShift19 ;
   SinShiftNeg19 <= (not (28 downto 0 => D19)) xor SinShift19 ;
   Cos20 <= Cos19 + SinShiftNeg19 +  not (D19 xor SinShiftRoundBit19) ;
   Sin20 <= Sin19 + CosShiftNeg19 + (D19 xor CosShiftRoundBit19) ;
   atan2PowStage19 <= "0101000110";
   fullZ20 <= Z19 + atan2PowStage19 when D19='1' else Z19 - atan2PowStage19 ;
   Z20 <= fullZ20(8 downto 0);
   D20 <= fullZ20(9);
   CosShift20 <= "00000000000000000000" & Cos20(28 downto 20);
   sgnSin20 <= Sin20(28);
   SinShift20 <= (28 downto 9 => sgnSin20) & Sin20(28 downto 20);
   ----------------Synchro barrier, entering cycle 7----------------
   CosShiftRoundBit20 <= Cos20_d1(19);
   SinShiftRoundBit20 <= Sin20_d1(19);
   CosShiftNeg20 <= (28 downto 0 => D20_d1) xor CosShift20_d1 ;
   SinShiftNeg20 <= (not (28 downto 0 => D20_d1)) xor SinShift20_d1 ;
   Cos21 <= Cos20_d1 + SinShiftNeg20 +  not (D20_d1 xor SinShiftRoundBit20) ;
   Sin21 <= Sin20_d1 + CosShiftNeg20 + (D20_d1 xor CosShiftRoundBit20) ;
   atan2PowStage20 <= "010100011";
   fullZ21 <= Z20_d1 + atan2PowStage20 when D20_d1='1' else Z20_d1 - atan2PowStage20 ;
   Z21 <= fullZ21(7 downto 0);
   D21 <= fullZ21(8);
   CosShift21 <= "000000000000000000000" & Cos21(28 downto 21);
   sgnSin21 <= Sin21(28);
   SinShift21 <= (28 downto 8 => sgnSin21) & Sin21(28 downto 21);
   CosShiftRoundBit21 <= Cos21(20);
   SinShiftRoundBit21 <= Sin21(20);
   CosShiftNeg21 <= (28 downto 0 => D21) xor CosShift21 ;
   SinShiftNeg21 <= (not (28 downto 0 => D21)) xor SinShift21 ;
   Cos22 <= Cos21 + SinShiftNeg21 +  not (D21 xor SinShiftRoundBit21) ;
   Sin22 <= Sin21 + CosShiftNeg21 + (D21 xor CosShiftRoundBit21) ;
   atan2PowStage21 <= "01010001";
   fullZ22 <= Z21 + atan2PowStage21 when D21='1' else Z21 - atan2PowStage21 ;
   Z22 <= fullZ22(6 downto 0);
   D22 <= fullZ22(7);
   CosShift22 <= "0000000000000000000000" & Cos22(28 downto 22);
   sgnSin22 <= Sin22(28);
   SinShift22 <= (28 downto 7 => sgnSin22) & Sin22(28 downto 22);
   CosShiftRoundBit22 <= Cos22(21);
   SinShiftRoundBit22 <= Sin22(21);
   CosShiftNeg22 <= (28 downto 0 => D22) xor CosShift22 ;
   SinShiftNeg22 <= (not (28 downto 0 => D22)) xor SinShift22 ;
   Cos23 <= Cos22 + SinShiftNeg22 +  not (D22 xor SinShiftRoundBit22) ;
   Sin23 <= Sin22 + CosShiftNeg22 + (D22 xor CosShiftRoundBit22) ;
   atan2PowStage22 <= "0101001";
   fullZ23 <= Z22 + atan2PowStage22 when D22='1' else Z22 - atan2PowStage22 ;
   Z23 <= fullZ23(5 downto 0);
   D23 <= fullZ23(6);
   CosShift23 <= "00000000000000000000000" & Cos23(28 downto 23);
   sgnSin23 <= Sin23(28);
   SinShift23 <= (28 downto 6 => sgnSin23) & Sin23(28 downto 23);
   CosShiftRoundBit23 <= Cos23(22);
   SinShiftRoundBit23 <= Sin23(22);
   CosShiftNeg23 <= (28 downto 0 => D23) xor CosShift23 ;
   SinShiftNeg23 <= (not (28 downto 0 => D23)) xor SinShift23 ;
   Cos24 <= Cos23 + SinShiftNeg23 +  not (D23 xor SinShiftRoundBit23) ;
   Sin24 <= Sin23 + CosShiftNeg23 + (D23 xor CosShiftRoundBit23) ;
   atan2PowStage23 <= "010100";
   fullZ24 <= Z23 + atan2PowStage23 when D23='1' else Z23 - atan2PowStage23 ;
   Z24 <= fullZ24(4 downto 0);
   D24 <= fullZ24(5);
   CosShift24 <= "000000000000000000000000" & Cos24(28 downto 24);
   sgnSin24 <= Sin24(28);
   SinShift24 <= (28 downto 5 => sgnSin24) & Sin24(28 downto 24);
   ----------------Synchro barrier, entering cycle 8----------------
   CosShiftRoundBit24 <= Cos24_d1(23);
   SinShiftRoundBit24 <= Sin24_d1(23);
   CosShiftNeg24 <= (28 downto 0 => D24_d1) xor CosShift24_d1 ;
   SinShiftNeg24 <= (not (28 downto 0 => D24_d1)) xor SinShift24_d1 ;
   Cos25 <= Cos24_d1 + SinShiftNeg24 +  not (D24_d1 xor SinShiftRoundBit24) ;
   Sin25 <= Sin24_d1 + CosShiftNeg24 + (D24_d1 xor CosShiftRoundBit24) ;
   atan2PowStage24 <= "01010";
   fullZ25 <= Z24_d1 + atan2PowStage24 when D24_d1='1' else Z24_d1 - atan2PowStage24 ;
   Z25 <= fullZ25(3 downto 0);
   D25 <= fullZ25(4);
   CosShift25 <= "0000000000000000000000000" & Cos25(28 downto 25);
   sgnSin25 <= Sin25(28);
   SinShift25 <= (28 downto 4 => sgnSin25) & Sin25(28 downto 25);
   CosShiftRoundBit25 <= Cos25(24);
   SinShiftRoundBit25 <= Sin25(24);
   CosShiftNeg25 <= (28 downto 0 => D25) xor CosShift25 ;
   SinShiftNeg25 <= (not (28 downto 0 => D25)) xor SinShift25 ;
   Cos26 <= Cos25 + SinShiftNeg25 +  not (D25 xor SinShiftRoundBit25) ;
   Sin26 <= Sin25 + CosShiftNeg25 + (D25 xor CosShiftRoundBit25) ;
   redCos<= Cos26;
   redSin<= Sin26;
   ---- final reconstruction 
   redCosNeg <= (not redCos); -- negate by NOT, 1 ulp error
   redSinNeg <= (not redSin); -- negate by NOT, 1 ulp error
   with qrot_d8 select
      CosX0 <= 
          redCos    when "00",
          redSinNeg when "01",
          redCosNeg when "10",
          redSin    when others;
   with qrot_d8 select
      SinX0 <= 
          redSin    when "00",
          redCos    when "01",
          redSinNeg when "10",
          redCosNeg when others;
   ----------------Synchro barrier, entering cycle 9----------------
   roundedCosX <= CosX0_d1(28 downto 4) +  ("000000000000000000000000" & '1');
   roundedSinX <= SinX0_d1(28 downto 4) +  ("000000000000000000000000" & '1');
   C <= roundedCosX(24 downto 1);
   S <= roundedSinX(24 downto 1);
end architecture;
