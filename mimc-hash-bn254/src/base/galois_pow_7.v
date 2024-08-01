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


// Module that performs exponentiation to the power of 7, on an element in Galois Field with Prime order.

// Use `GALOIS_POW_7_METHOD` parameter to select which exponentiation hardware method is used.
// Only the following values of GALOIS_POW_7_METHOD are valid:
//     - "serial" (uses 1 galois_mult instance and takes time equivalent to 4 multiplications)
//     - "parallel" (uses 2 galois_mult instances and takes time equivalent to 3 multiplications)

// Refer to file `galois_mult.v` for explanation of parameter `GALOIS_MULT_METHOD`.

module galois_pow_7 #(
	parameter N_BITS = 254,
	parameter GALOIS_MULT_METHOD = "peasant",
	parameter GALOIS_POW_7_METHOD = "parallel"
) (
	input clk,
	input rst,
	input en,
	input  [N_BITS-1:0] base,
	output [N_BITS-1:0] result,
	output done
);

generate
	case (GALOIS_POW_7_METHOD)
		"serial": begin : DESIGN
			galois_pow_7_serial #(
				.N_BITS(N_BITS),
				.GALOIS_MULT_METHOD(GALOIS_MULT_METHOD)
			) GALOIS_POW (
				.clk(clk),
				.rst(rst),
				.en(en),
				.base(base),
				.result(result),
				.done(done)
			);
		end

		"parallel": begin : DESIGN
			galois_pow_7_parallel #(
				.N_BITS(N_BITS),
				.GALOIS_MULT_METHOD(GALOIS_MULT_METHOD)
			) GALOIS_POW (
				.clk(clk),
				.rst(rst),
				.en(en),
				.base(base),
				.result(result),
				.done(done)
			);
		end

		default: begin : DESIGN
			initial $display("[WARNING] using GALOIS_POW_7_METHOD=\"serial\" by default");
			galois_pow_7_serial #(
				.N_BITS(N_BITS),
				.GALOIS_MULT_METHOD(GALOIS_MULT_METHOD)
			) GALOIS_POW (
				.clk(clk),
				.rst(rst),
				.en(en),
				.base(base),
				.result(result),
				.done(done)
			);
		end
	endcase
endgenerate

endmodule
