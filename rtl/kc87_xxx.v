
module kc87
(
	input         clk,
	input         reset,
	
	input         ntsc,
	input         scandouble,

	output reg    ce_pix,

	output reg    HBlank,
	output reg    HSync,
	output reg    VBlank,
	output reg    VSync,

	output  [7:0] video
);

assign ce_pix	= 1;

assign HBlank	= 0;
assign HSync	= 0;
assign VBlank	= 0;
assign VSync	= 0;

assign video	= 0;

// ********** T80 CPU **********
wire cen;
wire wait_n;
wire int_n;
wire nmi_n;
wire busrq_n;
wire m1_n;
wire iorq;
wire noread;
wire write;
wire rfsh_n;
wire halt_n;
wire busak_n;
wire [15:0] a;
wire [7:0] dinst;
wire [7:0] t80_di;
wire [7:0] t80_do;
wire [2:0] mc;
wire [2:0] ts;

wire intcycle_n;
wire inte;
wire stop;
wire reti_n;

T80 T80
(
	.RESET_n(reset),
	.CLK_n(clk),
	.CEN(cen),
	.WAIT_n(wait_n),
	.INT_n(int_n),
	.NMI_n(nmi_n),
	.BUSRQ_n(busrq_n),
	.M1_n(m1_n),
	.IORQ(iorq),
	.NoRead(noread),
	.Write(write),
	.RFSH_n(rfsh_n),
	.HALT_n(halt_n),
	.BUSAK_n(busak_n),
	.A(a),
	.DInst(dinst),
	.DI(t80_di),
	.DO(t80_do),
	.MC(mc),
	.TS(ts),
	.IntCycle_n(intcycle_n),
	.IntE(inte),
	.Stop(stop),
	.RETI_n(reti_n)
);

// ********** interupt controller **********

//-- interupt controller
//	intController : entity work.intController
//	port map (
//	  clk         => clk,
//	  res_n       => resetInt,
//	  int_n       => int_n,
//	  intPeriph   => intPeriph,
//	  intAck      => intAckPeriph,
//	  cpuDIn      => cpu_di,
//	  m1_n        => m1_n,
//	  iorq_n      => iorq_n,
//	  rd_n        => rd_n,
//	  RETI_n      => RETI_n
//	);

endmodule
