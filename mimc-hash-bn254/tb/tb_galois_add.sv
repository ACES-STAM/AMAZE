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


// Test bench of galois_add.v module
module tb_galois_add ();

// REGS AND WIRES DECLARATIONS

localparam N_BITS = 254;

logic clk;
logic rst;
logic en;
logic [N_BITS-1:0] a;
logic [N_BITS-1:0] b;
logic [N_BITS-1:0] c;
logic done;

`include "galois_add_test_cases.sv"

// Add module instantiation.
galois_add #(
	.N_BITS(N_BITS)
) GALOIS_ADD (
	.num1(a),
	.num2(b),
	.sum(c)
);


//-----------------------------------------------------------//
//
// Simulation
//
//-----------------------------------------------------------//

initial begin
	// Test of addition
	#1
	$display("Start:%d", $time);
	a = test_in1;
	b = test_in2;
	#1
	$display("End:%d", $time);
	$display("Result=%h", c);
	$display("Expected Result=%h", test_out);
	if (c == test_out)
		$display("Test Passed");
	else
		$display("Test Failed");
	$stop;
end

endmodule
