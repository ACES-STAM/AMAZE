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


// Test bench of mimc_cipher_sync_v2.v module
module tb_mimc_cipher_sync_v2 ();

localparam N_BITS = 254;

logic clk;
logic [N_BITS-1:0] a;
logic [N_BITS-1:0] b;
logic [N_BITS-1:0] c;

`include "mimc_cipher_test_cases.sv"

// Module to be tested.
mimc_cipher_sync_v2 MIMC_CIPHER (
	.clk(clk),
	.in(a),
	.key(b),
	.out(c)
);

// Module I/O timing information.
localparam MIMC_CIPHER_ROUND_LATENCY = 52 + 1; // Clock cylces

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
end

initial begin
	$display("Start (all):%d", $time);

	a = test1_in;
    b = test1_key;
	$display("Start (1):%d", $time);

	#2;

	a = test2_in;
    b = test2_key;
	$display("Start (2):%d", $time);

	#2;

	a = test3_in;
    b = test3_key;
	$display("Start (3):%d", $time);

	#(2*(91*MIMC_CIPHER_ROUND_LATENCY - 2));

	$display("End (1):%d", $time);
	$display("Result (1)=%h", c);
	$display("Expected Result (1)=%h", test1_out);
	if (c != test1_out) begin
		$display("Test Failed");
		$stop;
	end

    #2;

	$display("End (2):%d", $time);
	$display("Result (2)=%h", c);
	$display("Expected Result (2)=%h", test2_out);
	if (c != test2_out) begin
		$display("Test Failed");
		$stop;
	end

	#2;

	$display("End (3):%d", $time);
	$display("Result (3)=%h", c);
	$display("Expected Result (3)=%h", test3_out);
	if (c != test3_out) begin
		$display("Test Failed");
		$stop;
	end

	$display("End (all):%d", $time);
	$display("Test Passed");
	$stop;
end

endmodule
