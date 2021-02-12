--
-- Port to MiSTer by Niels Lueddecke
--
-- Original Copyright notice:
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
-- KC87 Toplevel
--

library IEEE;
use IEEE.std_logic_1164.all;

entity kc87 is
	port(
		clk				: in  std_logic;		-- 50Mhz
		vgaclock			: in  std_logic;		-- 7,3728Mhz
		reset				: in  std_logic;
		
		ps2_key			: in std_logic_vector(10 downto 0);
		
		scandouble		: in  std_logic;

		ce_pix			: out  std_logic;

		HBlank			: out std_logic;
		HSync				: out std_logic;
		VBlank			: out std_logic;
		VSync				: out std_logic;
		
		VGA_R				: out std_logic_vector(7 downto 0);
		VGA_G				: out std_logic_vector(7 downto 0);
		VGA_B				: out std_logic_vector(7 downto 0);
		
		LED_USER			: out std_logic;
		LED_POWER		: out std_logic_vector(1 downto 0);
		LED_DISK			: out std_logic_vector(1 downto 0)
    );
end kc87;

architecture struct of kc87 is
	signal SW				: std_logic_vector(9 downto 0);

	signal int_n			: std_logic;
	signal busrq_n			: std_logic;

	signal m1_n				: std_logic;
	signal mreq_n			: std_logic;
	signal iorq_n			: std_logic;
	signal rd_n				: std_logic;
	signal wr_n				: std_logic;

	signal halt_n			: std_logic;
	signal wait_n			: std_logic;
	signal busak_n			: std_logic;
	
	signal cpu_addr		: std_logic_vector(15 downto 0);
	signal cpu_do			: std_logic_vector(7 downto 0);
	signal cpu_di			: std_logic_vector(7 downto 0);
	signal bootRom_d		: std_logic_vector(7 downto 0);
	signal monitorRom_d	: std_logic_vector(7 downto 0);
	signal osRom_d			: std_logic_vector(7 downto 0);
	signal ram_d			: std_logic_vector(7 downto 0);
	signal vram_d			: std_logic_vector(7 downto 0);
	signal cram_d			: std_logic_vector(7 downto 0);
	signal uart_d			: std_logic_vector(7 downto 0);
	
	signal vgaramaddr		: std_logic_vector(9 downto 0);
	signal vgacoldata		: std_logic_vector(7 downto 0);
	signal vgachardata	: std_logic_vector(7 downto 0);

	--signal reset_n			: std_logic := '1';
	signal resetInt		: std_logic := '0';
	signal nmi_n			: std_logic;
	
	signal pio1_cs_n		: std_logic;
	signal pio2_cs_n		: std_logic;

	signal pio1_aIn		: std_logic_vector(7 downto 0);
	signal pio1_aOut		: std_logic_vector(7 downto 0);
	signal pio1_aRdy		: std_logic;
	signal pio1_aStb		: std_logic;

	signal pio1_bIn		: std_logic_vector(7 downto 0);
	signal pio1_bOut		: std_logic_vector(7 downto 0);
	signal pio1_bRdy		: std_logic;
	signal pio1_bStb		:  std_logic;

	signal pio2_aIn		: std_logic_vector(7 downto 0);
	signal pio2_aOut		: std_logic_vector(7 downto 0);
	signal pio2_aRdy		: std_logic;
	signal pio2_aStb		: std_logic;

	signal pio2_bIn		: std_logic_vector(7 downto 0);
	signal pio2_bOut		: std_logic_vector(7 downto 0);
	signal pio2_bRdy		: std_logic;
	signal pio2_bStb		: std_logic;

	signal ctc_d			: std_logic_vector(7 downto 0); 
	signal pio1_d			: std_logic_vector(7 downto 0);
	signal pio2_d			: std_logic_vector(7 downto 0);
	
	signal intAckCTC		: std_logic;
	signal intAckPio1		: std_logic;
	signal intAckPio2		: std_logic;

	signal sysctl_d		: std_logic_vector(7 downto 0);
	
	signal ram_cs_n		: std_logic;
	signal vram_cs_n		: std_logic;
	signal cram_cs_n		: std_logic;
	signal ctc_cs_n		: std_logic;
	signal uart_cs_n		: std_logic;
	signal bootRom_cs_n	: std_logic;
	signal sysctl_cs_n	: std_logic;
	
	signal ctcTcTo			: std_logic_vector(3 downto 0);
	signal ctcClkTrg		: std_logic_vector(3 downto 0);
	
	signal ps2_rcvd		: std_logic;
	signal ps2_state		: std_logic;
	signal ps2_code		: std_logic_vector(7 downto 0);
	signal old_stb			: std_logic;
	signal kmatrixXout	: std_logic_vector(7 downto 0);
	signal kmatrixXin		: std_logic_vector(7 downto 0);
	signal kmatrixYout	: std_logic_vector(7 downto 0);
	signal kmatrixYin		: std_logic_vector(7 downto 0);
	
	signal ioSel			: boolean;
	signal memSel			: boolean;

	signal kcSysClk		: std_logic;
	
	signal intAckPeriph	: std_logic_vector(7 downto 0);
	signal intPeriph		: std_logic_vector(7 downto 0);

	signal RETI_n			: std_logic;
	signal IntE				: std_logic;
	
	signal SRAM_ADDR		: std_logic_vector(15 downto 0);
	signal SRAM_DO			: std_logic_vector(7 downto 0);
	signal SRAM_DI			: std_logic_vector(7 downto 0);
	signal SRAM_CE_N		: std_logic;
	signal SRAM_WE_N		: std_logic;
	
	-- TEMP fuer UART, maybe via MiSTer user-IO??
	signal UART_TXD		: std_logic;
	signal UART_RXD		: std_logic;

begin
	-- MiSTer video?
	ce_pix <= '1';
	
	-- LEDs
	LED_POWER <= '1' & '1';
	LED_DISK  <= '1' & '0';
	
	-- some static signals
	wait_n	<= '1';
	busrq_n	<= '1';
	nmi_n		<= '1';
	
	-- reset-logik
	process (reset, clk)
	begin
		--if reset_n = '0' or KEY(0)='0' then
		if reset = '1' then
			resetInt <= '0';
		elsif rising_edge(clk) then
			resetInt <= '1';
		end if;
	end process;
	
	-- diverse cs signale
	ram_cs_n		<= mreq_n;
	cram_cs_n	<= '0' when (cpu_addr(15 downto 10) = "111010") and memSel else '1';
	vram_cs_n	<= '0' when (cpu_addr(15 downto 10) = "111011") and memSel else '1';
	bootRom_cs_n <= '0' when (sysctl_d(0)='0' and cpu_addr(15 downto 14)="00" and memSel) else '1';

	ioSel			<= iorq_n = '0' and m1_n='1';
	memSel		<= mreq_n = '0';

	intAckCTC	<= '0' when intAckPeriph(3 downto 0)="0000" else '1';
	intAckPio1	<= '0' when intAckPeriph(5 downto 4)="00" else '1';
	intAckPio2	<= '0' when intAckPeriph(7 downto 6)="00" else '1';

	uart_cs_n	<= '0' when cpu_addr(7 downto 1) = "0000000" and ioSel else '1';
	sysctl_cs_n	<= '0' when cpu_addr(7 downto 0) = "00000010" and ioSel else '1';
	ctc_cs_n		<= '0' when cpu_addr(7 downto 3) = "10000"  and ioSel else '1';
	pio1_cs_n	<= '0' when cpu_addr(7 downto 3) = "10001"  and ioSel else '1';
	pio2_cs_n	<= '0' when cpu_addr(7 downto 3) = "10010"  and ioSel else '1';
	
	-- cpu data-in multiplexer
	cpu_di <=
		ctc_d       when (ctc_cs_n		= '0' or intAckCTC  ='1') else
		pio1_d      when (pio1_cs_n	= '0' or intAckPio1 ='1') else
		pio2_d      when (pio2_cs_n	= '0' or intAckPio2 ='1') else
		uart_d      when uart_cs_n		= '0' else
		bootRom_d   when bootRom_cs_n	= '0' else
		sysctl_d    when sysctl_cs_n	= '0' else
		cram_d      when cram_cs_n		= '0' else
		vram_d      when vram_cs_n		= '0' else
		ram_d;

	-- teh cpu
	cpu : entity work.T80se
		generic map(Mode => 1, T2Write => 1, IOWait => 0)
		port map(
			RESET_n => resetInt,
			CLK_n   => clk,
			CLKEN   => kcSysClk or sysctl_d(1) or SW(0),
			WAIT_n  => wait_n,
			INT_n   => int_n,
			NMI_n   => nmi_n,
			BUSRQ_n => busrq_n,
			M1_n    => m1_n,
			MREQ_n  => mreq_n,
			IORQ_n  => iorq_n,
			RD_n    => rd_n,
			WR_n    => wr_n,
			RFSH_n  => open,
			HALT_n  => halt_n,
			BUSAK_n => busak_n,
			A       => cpu_addr,
			DI      => cpu_di,
			DO      => cpu_do,
			RETI_n  => RETI_n,
			IntE    => IntE
		);
	
	-- interupt controller
	intController : entity work.intController
		port map (
			clk         => clk,
			res_n       => resetInt,
			int_n       => int_n,
			intPeriph   => intPeriph,
			intAck      => intAckPeriph,
			cpuDIn      => cpu_di,
			m1_n        => m1_n,
			iorq_n      => iorq_n,
			rd_n        => rd_n,
			RETI_n      => RETI_n
		);
	
	-- ctc
	ctc : entity work.ctc
		port map (
			clk     => clk,
			res_n   => resetInt,
			en      => ctc_cs_n,
			dIn     => cpu_do,
			dOut    => ctc_d,
			cs      => cpu_addr(1 downto 0),
			m1_n    => m1_n,
			iorq_n  => iorq_n,
			rd_n    => rd_n,
			int     => intPeriph(3 downto 0),
			intAck  => intAckPeriph(3 downto 0),
			clk_trg => ctcClkTrg,
			zc_to   => ctcTcTo,
			kcSysClk => kcSysClk
		);
		
	-- ctc-aus und eingaenge verdrahten
	ctcClkTrg(2 downto 0) <= (others => '0');
	ctcClkTrg(3) <= ctcTcTo(2);
	
	-- System PIO
	pio1 : entity work.pio
		port map (
			clk   => clk,
			res_n => resetInt,
			en    => '1',
			dIn   => cpu_do,
			dOut  => pio1_d,
			baSel => cpu_addr(0),
			cdSel => cpu_addr(1),
			cs_n  => pio1_cs_n,
			m1_n  => m1_n,
			iorq_n => iorq_n,
			rd_n  => rd_n,
			intAck => intAckPeriph(5 downto 4),
			int   => intPeriph(5 downto 4),
			aIn   => pio1_aIn,
			aOut  => pio1_aOut,
			aRdy  => pio1_aRdy,
			aStb  => pio1_aStb,
			bIn   => pio1_bIn,
			bOut  => pio1_bOut,
			bRdy  => pio1_bRdy,
			bStb  => '1'
		);
	pio1_aStb <= '1';
	pio1_aIn <= (others => '1');
	pio1_bIn <= (others => '1');

	-- Keyboard PIO
	pio2 : entity work.pio
		port map (
			clk   => clk,
			res_n => resetInt,
			en    => '1',
			dIn   => cpu_do,
			dOut  => pio2_d,
			baSel => cpu_addr(0),
			cdSel => cpu_addr(1),
			cs_n  => pio2_cs_n,
			m1_n  => m1_n,
			iorq_n => iorq_n,
			rd_n  => rd_n,
			intAck => intAckPeriph(7 downto 6),
			int   => intPeriph(7 downto 6),
			aIn   => kmatrixXout,
			aOut  => kmatrixXin,
			aRdy  => pio2_aRdy,
			aStb  => '1',
			bIn   => kmatrixYout,
			bOut  => kmatrixYin,
			bRdy  => pio2_bRdy,
			bStb  => '1'
		);
	
	-- Syscontrol port:
	-- 0: 0 Bootrom einblenden
	-- 0: 1 Bootrom aus
	-- 1: 0 Turbo aus
	-- 1: 1 Turbo an
	-- 2: 0 Schreibschutz Ram ab 8000 aus
	-- 2: 1 Schreibschutz Ram ab 8000 an
	syscontrol : entity work.pport
		port map (
			clk   => clk,
			ce_n  => sysctl_cs_n, 
			wr_n  => wr_n,
			res_n => resetInt,
			dIn   => cpu_do,
			pOut  => sysctl_d
		);
	
	-- sram signale
	ram_d		 <= SRAM_DO;
	SRAM_ADDR <= cpu_addr;
	SRAM_CE_N <= '0';
	SRAM_WE_N <= wr_n or ram_cs_n or (sysctl_d(2) and cpu_addr(15)) or (sysctl_d(2) and cpu_addr(15)); -- wp fuer oberen ram wenn sysctl_d(2)
	SRAM_DI	 <= cpu_do when wr_n = '0' and ram_cs_n = '0';
	
	-- system blockram
	sysram : entity work.sram
		generic map (
			AddrWidth => 16,
			DataWidth => 8
		)
		port map (
			clk  => clk,
			addr => SRAM_ADDR,
			din  => SRAM_DI,
			dout => SRAM_DO,
			ce_n => SRAM_CE_N, 
			we_n => SRAM_WE_N
		);
	
	-- video blockram
	vram : entity work.dualsram
		generic map (
			AddrWidth => 10
		)
		port map (
			clk1  => clk,
			addr1 => cpu_addr(9 downto 0),
			din1  => cpu_do,
			dout1 => vram_d,
			ce1_n => vram_cs_n, 
			we1_n => wr_n,

			clk2  => vgaclock,
			addr2 => vgaramaddr,
			din2  => "00000000",
			dout2 => vgachardata,
			ce2_n => '0',
			we2_n => '1'
		);
		
	-- color-video blockram
	cram : entity work.dualsram
		generic map (
			AddrWidth => 10
		)
		port map (
			clk1  => clk,
			addr1 => cpu_addr(9 downto 0),
			din1  => cpu_do,
			dout1 => cram_d,
			ce1_n => cram_cs_n, 
			we1_n => wr_n,

			clk2  => vgaclock,
			addr2 => vgaramaddr,
			din2  => "00000000",
			dout2 => vgacoldata,
			ce2_n => '0',
			we2_n => '1'
		);
		
	-- startrom
	monitor : entity work.monitor
		port map (
			clk => clk,
			addr => cpu_addr(13 downto 0),
			data => bootRom_d
		);
		
	-- vga-controller
	video : entity work.video
		port map (
			clk    => vgaclock,
			red    => VGA_R,
			green  => VGA_G,
			blue   => VGA_B,
			hsync  => HSync,
			vsync  => VSync,
			hblank => HBlank,
			vblank => VBlank,

			ramAddr => vgaramaddr,
			colData => vgacoldata,
			charData => vgachardata,
			scanLine => SW(1)
		);
		
	-- ps/2 interface
	ps2kc : entity work.ps2kc
		port map (
			clk			=> clk,
			res_n			=> resetInt,
			scancode		=> ps2_code,
			scanstate	=> ps2_state,
			rcvd			=> ps2_rcvd,
			matrixXout	=> kmatrixXout,
			matrixXin 	=> kmatrixXin,
			matrixYout	=> kmatrixYout,
			matrixYin	=> kmatrixYin
		);
	-- detect pressed key from MiSTer
	process (ps2_key, clk)
	begin
		if rising_edge(clk) then
			old_stb <= ps2_key(10);
			if old_stb /= ps2_key(10) then
				LED_USER  <= ps2_key(9);
				ps2_state <= ps2_key(9);
				ps2_code  <= ps2_key(7 downto 0);
				ps2_rcvd  <= '1';
			else
				ps2_rcvd  <= '0';
			end if;
		end if;
	end process;
	
	-- uart
	uart : entity work.uart
		port map (
			clk  => clk,
			cs_n => uart_cs_n,
			rd_n => rd_n,
			wr_n => wr_n,
			addr => cpu_addr(0 downto 0),
			dIn  => cpu_do,
			dOut => UART_D,
			txd  => UART_TXD,
			rxd  => UART_RXD
		);

end;
