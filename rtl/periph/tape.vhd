--
-- complete rewrite by Niels Lueddecke in 2021
--
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
-- tape frequency generator
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 

entity tape is 
	generic  (
		BIT_DIVIDE_MAX	: integer := 5208 -- 417us/4 at 50MHz
	);
	port (
		clk      		: in std_logic;
		reset_n			: in std_logic;
		
		LED_DISK			: out std_logic_vector(1 downto 0);
		
		tape_out			: out std_logic;
		
		hps_status		: in  std_logic_vector(31 downto 0);
		ioctl_download	: in  std_logic;
		ioctl_index		: in  std_logic_vector(7 downto 0);
		ioctl_wr			: in  std_logic;
		ioctl_addr		: in  std_logic_vector(24 downto 0);
		ioctl_data		: in  std_logic_vector(7 downto 0);
		ioctl_wait		: out  std_logic
	);
end tape;

	architecture rtl of tape is
		signal divide_bit		: unsigned(16 downto 0) := (others => '0');
		
		signal tx_cnt_block	: unsigned(11 downto 0) := (others => '1');
		signal tx_cnt_bs		: unsigned(11 downto 0) := (others => '0');
		signal tx_cnt_byte	: unsigned(3 downto 0) := (others => '0');
		signal tx_cnt_bit		: unsigned(3 downto 0) := (others => '0');
		signal tx_cnt_mid		: unsigned(3 downto 0) := (others => '0');
		signal tx_cnt_pulse	: unsigned(7 downto 0) := (others => '0');
		
		signal cnt_txadr		: unsigned(7 downto 0) := (others => '0');
		
		signal cnt_cut_head	: unsigned(7 downto 0) := (others => '0');
		
		signal dl_adr			: std_logic_vector(24 downto 0);
		signal dl_data			: std_logic_vector(7 downto 0);
		signal dl_readbyte	: std_logic := '0';
		signal dl_readblock	: std_logic := '0';
		
		signal tmp_color		: std_logic_vector(7 downto 0);
		signal tmp_adr			: std_logic_vector(6 downto 0);
		signal tmp_data		: std_logic_vector(7 downto 0);
		
		signal buff_adr		: std_logic_vector(6 downto 0) := (others => '1');
		signal buff_di			: std_logic_vector(7 downto 0);
		signal buff_do			: std_logic_vector(7 downto 0);
		signal buff_we_n		: std_logic := '0';
		
		signal block_nr		: unsigned(7 downto 0) := (others => '1');
		signal checksum		: unsigned(7 downto 0) := (others => '0');
	
begin
	process
	begin
		wait until rising_edge(clk);
		
		-- reset buffer we_n
		buff_we_n	<= '1';
		
		-- send pulse
		if tx_cnt_pulse > 0 then
			tx_cnt_pulse <= tx_cnt_pulse - 1;
			tape_out <= '1';
		else
			tape_out <= '0';
		end if;

		-- send bit to kc
		if tx_cnt_bit > 0 then
			if divide_bit > 0 then
				divide_bit <= divide_bit - 1;
			else
				divide_bit <= to_unsigned(BIT_DIVIDE_MAX,17);
				tx_cnt_bit <= tx_cnt_bit - 1;
				if tx_cnt_bit = 1 or tx_cnt_bit = tx_cnt_mid then
					-- send pulse
					tx_cnt_pulse <= x"64";	--100, ca. 2us
				end if;
			end if;
		end if;

		-- send byte to kc
		if tx_cnt_bit = 0 then
			if tx_cnt_byte > 0 then
				divide_bit <= to_unsigned(BIT_DIVIDE_MAX,17);
				tx_cnt_byte <= tx_cnt_byte - 1;
				if tx_cnt_byte = 9 then
					-- Vorton
					tx_cnt_bit <= x"f";
					tx_cnt_mid <= x"8";
				else
					tmp_data <= b"0" & tmp_data(7 downto 1);
					-- normales bit
					if tmp_data(0) = '1' then
						tx_cnt_bit <= x"8";
						tx_cnt_mid <= x"5";
					else
						tx_cnt_bit <= x"4";
						tx_cnt_mid <= x"3";
					end if;
				end if;
			end if;
		end if;
		
		-- send silence/start ones
		if tx_cnt_bs > 0 then
			if divide_bit > 0 then
				divide_bit <= divide_bit - 1;
			else
				divide_bit <= to_unsigned(BIT_DIVIDE_MAX,17);
				tx_cnt_bs <= tx_cnt_bs - 1;
				if tx_cnt_bs < 1396 and tx_cnt_bs(1 downto 0) = b"01" then
					-- send pulse
					tx_cnt_pulse <= x"64";	--100, ca. 2us
					-- dont divide last pulse
					if tx_cnt_bs = b"0000000000000001" then
						tx_cnt_bs <= (others => '0');
					end if;
				end if;
			end if;
		end if;
		
		-- send data block to kc
		if tx_cnt_byte = 0 and tx_cnt_bit = 0 and tx_cnt_bs = 0 then
			if tx_cnt_block < 528 then
				tx_cnt_block <= tx_cnt_block + 1;
				if 	tx_cnt_block(1 downto 0) = b"00" then
					buff_adr <= std_logic_vector(cnt_txadr(6 downto 0));
				elsif tx_cnt_block(1 downto 0) = b"11" then
					if 	tx_cnt_block(11 downto 2) = 0 then
						-- send silence/start ones
						tx_cnt_bs <= x"708";
					elsif tx_cnt_block(11 downto 2) = 1 then
						-- send blocknr
						tmp_data  <= std_logic_vector(block_nr);
						checksum  <= x"00";
						tx_cnt_byte  <= x"9";
					elsif tx_cnt_block(11 downto 2) = 130 then
						-- send checksum
						tmp_data <= std_logic_vector(checksum);
						tx_cnt_byte  <= x"9";
					elsif tx_cnt_block(11 downto 2) = 131 then
						-- send one last vorton
						cnt_txadr <= x"00";
						tx_cnt_bit <= x"f";
						tx_cnt_mid <= x"8";
					else
						-- send standard byte
						tmp_data   <= buff_do;
						cnt_txadr <= cnt_txadr + 1;
						LED_DISK <= b"1" & buff_do(0);
						checksum	  <= checksum + unsigned(buff_do);
						tx_cnt_byte  <= x"9";
					end if;
				end if;
			else
				dl_readbyte  <= '1';
				dl_readblock <= '1';
			end if;
		end if;
		
		-- fill block buffer
		if ioctl_download = '1' and dl_readbyte = '0' and dl_readblock = '1' then
			dl_readbyte <= '1';
			if cnt_cut_head > 0 then
				cnt_cut_head <= cnt_cut_head - 1;
				if cnt_cut_head = 1 then
					block_nr <= unsigned(dl_data);
				end if;
			else
				cnt_txadr <= cnt_txadr + 1;
				-- save byte to block buffer
				buff_adr    <= std_logic_vector(cnt_txadr(6 downto 0));
				buff_we_n   <= '0';
				buff_di     <= dl_data;
				-- block complete
				if cnt_txadr(6 downto 0) = b"1111111" then
					dl_readbyte  <= '0';
					dl_readblock <= '0';
					cnt_txadr    <= x"00";
					tx_cnt_block <= x"000";
					cnt_cut_head <= x"01";
				end if;
			end if;
		end if;
		
		-- get next byte from hps
		if ioctl_download = '0' then
			ioctl_wait   <= '0';
			dl_readbyte  <= '1';
			dl_readblock <= '1';
			cnt_cut_head <= x"11";
			cnt_txadr    <= x"00";
			LED_DISK     <= b"10";
		elsif dl_readbyte = '0' then
			ioctl_wait  <= '1';
		elsif ioctl_wr = '0' then
			ioctl_wait  <= '0';
		elsif ioctl_wr = '1' then
			ioctl_wait  <= '1';
			dl_readbyte <= '0';
			dl_adr      <= ioctl_addr;
			dl_data     <= ioctl_data;
		end if;
	end process;
	
	-- 128 byte block buffer
	blockbuffer : entity work.sram
		generic map (
			AddrWidth => 7,
			DataWidth => 8
		)
		port map (
			clk  => clk,
			addr => buff_adr,
			din  => buff_di,
			dout => buff_do,
			ce_n => '0', 
			we_n => buff_we_n
		);
end;
