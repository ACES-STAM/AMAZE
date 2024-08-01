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


// Test bench of galois_pow_7.v module
module tb_galois_pow_7 ();

// REGS AND WIRES DECLARATIONS

localparam N_BITS = 254;

logic clk;
logic rst;
logic en;
logic [N_BITS-1:0] a;
logic [N_BITS-1:0] c;
logic done;

`include "galois_pow_7_test_cases.sv"

// Add module instantiation.
galois_pow_7 #(
	.N_BITS(N_BITS),
	.GALOIS_MULT_METHOD("peasant"),
	.GALOIS_POW_7_METHOD("parallel")
) GALOIS_POW (
	.clk(clk),
	.rst(rst),
	.en(en),
	.base(a),
	.result(c),
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
	#1 // Test of exponentiation to the power of 7
		a = test_in;
	#1
		$display("Start:%d", $time);
		rst = 1'b0;
		en =  1'b1;
	wait(done);
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
