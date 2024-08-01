module top(

	// Switch Inputs
	input SWITCH1,
	input SWITCH2,
	input SWITCH3,
	input SWITCH4,
	input SWITCH5,

	//LED Outputs
	output LED1,
	output LED2,
	output LED3,
	output LED4,
	output LED5,

	//Clock from oscillator
	input Clock,

	//Analog input in Arduino connector
	input Arduino_A0,
	input Arduino_A1,
	input Arduino_A2,
	input Arduino_A3,
	input Arduino_A4,
	input Arduino_A5,
	input Arduino_A6,
	input Arduino_A7,

	//Arduino I/Os
	inout Arduino_IO0,
	inout Arduino_IO1,
	inout Arduino_IO2,
	inout Arduino_IO3,
	inout Arduino_IO4,
	inout Arduino_IO5,
	inout Arduino_IO6,
	inout Arduino_IO7,
	inout Arduino_IO8,
	inout Arduino_IO9,
	inout Arduino_IO10,
	inout Arduino_IO11,
	inout Arduino_IO12,
	inout Arduino_IO13,

	//Reset Pin
	input RESET_N,

	//JTAG enable
	input JTAGEN,

	//There are 40 GPIOs. In this example pins are not used as LVDS pins.
	//NOTE: Refer README.txt on how to use these GPIOs with LVDS option.

	inout DIFFIO_L20N_CLK1N,
	inout DIFFIO_L20P_CLK1P,
	inout DIFFIO_L27N_PLL_CLKOUTN,
	inout DIFFIO_L27P_PLL_CLKOUTP,
	inout DIFFIO_B1N,
	inout DIFFIO_B1P,
	inout DIFFIO_B3N,
	inout DIFFIO_B3P,
	inout DIFFIO_B5N,
	inout DIFFIO_B5P,
	inout DIFFIO_B7N,
	inout DIFFIO_B7P,
	inout DIFFIO_B9N,
	inout DIFFIO_B9P,
	inout DIFFIO_B12N,
	inout DIFFIO_B12P,
	inout DIFFIO_B14N,
	inout DIFFIO_B14P,
	inout DIFFIO_B16N,
	inout DIFFIO_B16P,
	inout DIFFIO_R14P_CLK2P,
	inout DIFFIO_R14N_CLK2N,
	inout DIFFIO_R16P_CLK3P,
	inout DIFFIO_R16N_CLK3N,
	inout DIFFIO_R18P,
	inout DIFFIO_R18N,
	inout DIFFIO_R26P_DPCLK3,
	inout DIFFIO_R26N_DPCLK2,
	inout DIFFIO_R27P,
	inout DIFFIO_R28P,
	inout DIFFIO_R27N,
	inout DIFFIO_R28N,
	inout DIFFIO_R33P,
	inout DIFFIO_R33N,
	inout DIFFIO_T1P,
	inout DIFFIO_T1N,
	inout DIFFIO_T4N,
	inout DIFFIO_T6P,
	inout DIFFIO_T10P,
	inout DIFFIO_T10N

);


wire [253:0] mimc_out;
wire [253:0] mimc_in;

assign mimc_in = {{100{SWITCH3}}, {100{SWITCH4}}, {54{SWITCH4}}};

assign LED2 = |(mimc_out);

// mimc_cipher #(
// 	.N_BITS(254),
// 	.GALOIS_MULT_METHOD("barrett"),
// 	.GALOIS_POW_7_METHOD("parallel"),
// 	.MIMC_CIPHER_ROUND_METHOD("v1")
// ) MIMC_CIPHER (
// 	.clk(Clock),
// 	.rst(RESET_N),
// 	.en(SWITCH2),
// 	.in(mimc_in),
// 	.out(mimc_out),
// 	.done(LED1)
// );

mimc_cipher_sync_v2 #(
	.N_BITS(254)
) MIMC_CIPHER (
	.clk(Clock),
	.in(mimc_in),
	.out(mimc_out)
);

// galois_mult #(
// 	.N_BITS(254),
// 	.GALOIS_MULT_METHOD("peasant")
// ) GALOIS_MULT (
// 	.clk(Clock),
// 	.rst(RESET_N),
// 	.en(SWITCH2),
// 	.num1(mimc_in),
// 	.num2(mimc_in),
// 	.product(mimc_out),
// 	.done(LED1)
// );

// mult_256_sync MULT (
// 	.clk(Clock),
// 	.num1(mimc_in),
// 	.num2(mimc_in),
// 	.product(mimc_out)
// );

// galois_mult_barrett_sync MULT (
// 	.clk(Clock),
// 	.num1(mimc_in),
// 	.num2(mimc_in),
// 	.product(mimc_out),
// 	.ready(LED1)
// );

// galois_mult_barrett_sync_v2 MULT (
// 	.clk(Clock),
// 	.num1(mimc_in),
// 	.num2(mimc_in),
// 	.product(mimc_out)
// );

endmodule
