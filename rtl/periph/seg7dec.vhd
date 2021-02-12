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
-- bin to 7seg decoder
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seg7dec is 
    port (
        number : in std_logic_vector(3 downto 0);
        digits : out std_logic_vector(6 downto 0)
    );
end seg7dec;

architecture struct of seg7dec is

begin
    process(number) is
    begin
        case to_integer(unsigned(number)) is
            when  0 => digits <= "1000000";
            when  1 => digits <= "1111001";
            when  2 => digits <= "0100100";
            when  3 => digits <= "0110000";
            when  4 => digits <= "0011001";
            when  5 => digits <= "0010010";
            when  6 => digits <= "0000010";
            when  7 => digits <= "1111000";
            when  8 => digits <= "0000000";
            when  9 => digits <= "0010000";
            when 10 => digits <= "0001000";
            when 11 => digits <= "0000011";
            when 12 => digits <= "1000110";
            when 13 => digits <= "0100001";
            when 14 => digits <= "0000110";
            when 15 => digits <= "0001110";
            when others => digits <= "1111111";
        end case;
    end process;
end;