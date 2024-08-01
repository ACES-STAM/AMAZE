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


// Test bench of galois_pow_7_sync_v2.v module
module tb_galois_pow_7_sync_v2 ();

localparam N_BITS = 254;

logic clk;
logic [N_BITS-1:0] a;
logic [N_BITS-1:0] c;

wire d;

`include "galois_pow_7_test_cases.sv"

// Module to be tested.
galois_pow_7_sync_v2 POW (
	.clk(clk),
	.base(a),
	.result(c),
	.ready(d)
);

// Module I/O timing information.
localparam MULT_LATENCY = 12+1; // Clock cylces

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
	#1;

	$display("Start (all):%d", $time);

	a = test_in;
	$display("Start (1):%d", $time);

	#2;

	a = 'b1;
	$display("Start (2):%d", $time);

	#2;

	a = 'b0;
	$display("Start (3):%d", $time);

	#(2*(4*MULT_LATENCY-2));

	$display("End (1):%d", $time);
	$display("Result (1)=%h", c);
	$display("Expected Result (1)=%h", test_out);
	if (c != test_out) begin
		$display("Test Failed");
		$stop;
	end

	#2;

	$display("End (2):%d", $time);
	$display("Result (2)=%h", c);
	$display("Expected Result (2)=%h", {{(N_BITS-1){1'b0}}, 1'b1});
	if (c != {{(N_BITS-1){1'b0}}, 1'b1}) begin
		$display("Test Failed");
		$stop;
	end

	#2;

	$display("End (3):%d", $time);
	$display("Result (3)=%h", c);
	$display("Expected Result (3)=%h", {N_BITS{1'b0}});
	if (c != {N_BITS{1'b0}}) begin
		$display("Test Failed");
		$stop;
	end

	$display("End (all):%d", $time);
	$display("Test Passed");
	$stop;
end

endmodule
