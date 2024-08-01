//  @author : Secure, Trusted, and Assured Microelectronics (STAM) Center
//
//  Copyright (c) 2024 STAM Center (SCAI/ASU)
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


// Test bench of mimc_feistel_cipher_round.v module
module tb_mimc_feistel_cipher_round ();

// REGS AND WIRES DECLARATIONS

localparam N_BITS = 254;

logic clk;
logic rst;
logic en;
logic [N_BITS-1:0] a1, a2;
logic [N_BITS-1:0] b;
logic [N_BITS-1:0] c;
logic d;
logic [N_BITS-1:0] e1, e2;
logic done;

`include "mimc_feistel_cipher_round_test_cases.sv"

// Add module instantiation.
mimc_feistel_cipher_round #(
	.N_BITS(N_BITS),
	.GALOIS_MULT_METHOD("peasant")
) MIMC_FEISTEL_CIPHER_ROUND (
	.clk(clk),
	.rst(rst),
	.en(en),
	.in_left(a1),
	.in_right(a2),
	.round_constant(b),
	.key(c),
	.is_last_round(d),
	.out_left(e1),
	.out_right(e2),
	.done(done)
);


//-----------------------------------------------------------//
//
// Simulation
//
//-----------------------------------------------------------//

// CLK
always begin
	#1 clk = ~clk;
end

initial begin
	clk = 1'b0;
	#1
		en = 1'b0;
		rst = 1'b1;
	#1 // Test of one round of MiMC cipher
		a1 = test_in_left;
		a2 = test_in_right;
		b = test_round_constant;
		c = test_key;
		d = test_is_last_round;
	#1
		$display("Start:%d", $time);
		rst = 1'b0;
		en =  1'b1;
	wait(done);
	$display("End:%d", $time);
	$display("Result=(%h, %h)", e1, e2);
	$display("Expected Result=(%h, %h)", test_out_left, test_out_right);
	if (e1 == test_out_left && e2 == test_out_right)
		$display("Test Passed");
	else
		$display("Test Failed");
	$stop;
end

endmodule
