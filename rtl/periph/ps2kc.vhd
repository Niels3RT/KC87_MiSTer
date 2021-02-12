-- Copyright (c) 2015, $ME
-- All rights reserved.
--
-- Redistribution and use in source and synthezised forms, with or without modification, are permitted 
-- provided that the following conditions are met:
--
-- 1. Redistributions of source code must retain the above copyright notice, this list of conditions 
--    and the following disclaimer.
--
-- 2. Redistributions in synthezised form must reproduce the above copyright notice, this list of conditions
--    and the following disclaimer in the documentation and/or other materials provided with the distribution.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED 
-- WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
-- PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR 
-- ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED 
-- TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
-- HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
-- NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
-- POSSIBILITY OF SUCH DAMAGE.
--
--
-- MiSTer PS/2 inputs -> KC87 Keymatrix
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ps2kc is
    port (
		clk			: in std_logic;
		res_n			: in std_logic;
		scancode		: in std_logic_vector(7 downto 0);
		scanstate	: in std_logic;
		rcvd			: in std_logic;
		matrixXin	: in  std_logic_vector(7 downto 0);
		matrixXout	: out std_logic_vector(7 downto 0);
		matrixYin	: in  std_logic_vector(7 downto 0);
		matrixYout	: out std_logic_vector(7 downto 0)
	);
end;

architecture rtl of ps2kc is
    type keyMatrixType is array(8 downto 1) of std_logic_vector(8 downto 1);
	 -- init mit 1 funktioniert in ise nicht, Quartus kanns :P
    signal keyMatrix : keyMatrixType := (others => (others => '1'));
    
begin
 
	-- ps/2-codes in eine 8x8 matrix umkopieren die weitgehend der des kc entspricht 
	process(clk, scancode, rcvd, matrixXin, matrixYin, keyMatrix)
	begin
		if rising_edge(clk) then
			if (rcvd='1') then
				case scancode is
					--- Zeile 1
					when x"45" => keyMatrix(1)(1) <= not scanstate; -- 0 (_)  => (0 =)
					when x"16" => keyMatrix(1)(2) <= not scanstate; -- 1 !
					when x"1e" => keyMatrix(1)(3) <= not scanstate; -- 2 "
					when x"26" => keyMatrix(1)(4) <= not scanstate; -- 3 (#)  => (3 §)
					when x"25" => keyMatrix(1)(5) <= not scanstate; -- 4 $
					when x"2e" => keyMatrix(1)(6) <= not scanstate; -- 5 %
					when x"36" => keyMatrix(1)(7) <= not scanstate; -- 6 &
					when x"3d" => keyMatrix(1)(8) <= not scanstate; -- 7 (')  => (7 /)

					--- Zeile 2
					when x"3e" => keyMatrix(2)(1) <= not scanstate; -- 8 (
					when x"46" => keyMatrix(2)(2) <= not scanstate; -- 9 )
					when x"61" => keyMatrix(2)(3) <= not scanstate; -- : *  => (< >)
					when x"5b" => keyMatrix(2)(4) <= not scanstate; -- ; +  => (+ *)
					when x"41" => keyMatrix(2)(5) <= not scanstate; -- , <  => (, ;)
					when x"4a" => keyMatrix(2)(6) <= not scanstate; -- = -  => (- _)
					when x"49" => keyMatrix(2)(7) <= not scanstate; -- . >  => (. :)
					when x"4e" => keyMatrix(2)(8) <= not scanstate; -- ? /  => (ß ?)

					--- Zeile 3
					-- @
					when x"1c" => keyMatrix(3)(2) <= not scanstate; -- A
					when x"32" => keyMatrix(3)(3) <= not scanstate; -- B
					when x"21" => keyMatrix(3)(4) <= not scanstate; -- C
					when x"23" => keyMatrix(3)(5) <= not scanstate; -- D
					when x"24" => keyMatrix(3)(6) <= not scanstate; -- E
					when x"2b" => keyMatrix(3)(7) <= not scanstate; -- F
					when x"34" => keyMatrix(3)(8) <= not scanstate; -- G

					--- Zeile 4
					when x"33" => keyMatrix(4)(1) <= not scanstate; -- H
					when x"43" => keyMatrix(4)(2) <= not scanstate; -- I
					when x"3b" => keyMatrix(4)(3) <= not scanstate; -- J
					when x"42" => keyMatrix(4)(4) <= not scanstate; -- K
					when x"4b" => keyMatrix(4)(5) <= not scanstate; -- L
					when x"3a" => keyMatrix(4)(6) <= not scanstate; -- M
					when x"31" => keyMatrix(4)(7) <= not scanstate; -- N
					when x"44" => keyMatrix(4)(8) <= not scanstate; -- O

					--- Zeile 5
					when x"4d" => keyMatrix(5)(1) <= not scanstate; -- P
					when x"15" => keyMatrix(5)(2) <= not scanstate; -- Q
					when x"2d" => keyMatrix(5)(3) <= not scanstate; -- R
					when x"1b" => keyMatrix(5)(4) <= not scanstate; -- S
					when x"2c" => keyMatrix(5)(5) <= not scanstate; -- T
					when x"3c" => keyMatrix(5)(6) <= not scanstate; -- U
					when x"2a" => keyMatrix(5)(7) <= not scanstate; -- V
					when x"1d" => keyMatrix(5)(8) <= not scanstate; -- W

					--- Zeile 6
					when x"22" => keyMatrix(6)(1) <= not scanstate; -- X
					when x"1a" => keyMatrix(6)(2) <= not scanstate; -- Y
					when x"35" => keyMatrix(6)(3) <= not scanstate; -- Z
					when x"0d" => keyMatrix(6)(4) <= not scanstate; -- Tab
					when x"05" => keyMatrix(6)(5) <= not scanstate; -- Pause Cont => (F1)
					when x"70" => keyMatrix(6)(6) <= not scanstate; -- INS DEL    => (Einfg)
					when x"0e" => keyMatrix(6)(7) <= not scanstate; -- ^
					when x"71" => keyMatrix(6)(8) <= not scanstate; -- (Entf)       => DEL
					when x"66" => keyMatrix(6)(8) <= not scanstate; -- (Backspace)  => DEL

					--- Zeile 7
					when x"6b" => keyMatrix(7)(1) <= not scanstate; -- Cursor <-
					when x"74" => keyMatrix(7)(2) <= not scanstate; -- Cursor ->
					when x"72" => keyMatrix(7)(3) <= not scanstate; -- Cursor down
					when x"75" => keyMatrix(7)(4) <= not scanstate; -- Cursor up
					when x"76" => keyMatrix(7)(5) <= not scanstate; -- ESC
					when x"5a" => keyMatrix(7)(6) <= not scanstate; -- Enter
					when x"0c" => keyMatrix(7)(7) <= not scanstate; -- Stop => F4
					when x"29" => keyMatrix(7)(8) <= not scanstate; -- Space

					--- Zeile 8
					-- (8)(1) Shift 
					when x"59" => keyMatrix(8)(1) <= not scanstate; -- rshift
					when x"12" => keyMatrix(8)(1) <= not scanstate; -- lshift
					when x"03" => keyMatrix(8)(2) <= not scanstate; -- Color   => (F5)
					when x"14" => keyMatrix(8)(3) <= not scanstate; -- Contr
					when x"0b" => keyMatrix(8)(4) <= not scanstate; -- Graphic => (F6)
					when x"06" => keyMatrix(8)(5) <= not scanstate; -- List    => (F2)
					when x"04" => keyMatrix(8)(6) <= not scanstate; -- Run     => (F3)
					when x"58" => keyMatrix(8)(7) <= not scanstate; -- Shift Lock
					when x"5d" => keyMatrix(8)(8) <= not scanstate; --  => (# ')
					when others =>null;
				end case;
			end if;
		end if;
		-- matrix zeilen und spalten fuer pio kombinieren
		for i in 0 to 7 loop
			matrixXout(i) <= (keyMatrix(1)(i+1) or matrixYin(0)) 
			and (keyMatrix(2)(i+1) or matrixYin(1)) 
			and (keyMatrix(3)(i+1) or matrixYin(2)) 
			and (keyMatrix(4)(i+1) or matrixYin(3)) 
			and (keyMatrix(5)(i+1) or matrixYin(4)) 
			and (keyMatrix(6)(i+1) or matrixYin(5)) 
			and (keyMatrix(7)(i+1) or matrixYin(6)) 
			and (keyMatrix(8)(i+1) or matrixYin(7));

			if ((keyMatrix(i+1) or matrixXin)="11111111") then
				matrixYout(i) <= '1';
			else
				matrixYout(i) <= '0';
			end if;
		end loop;
	end process;
end;
