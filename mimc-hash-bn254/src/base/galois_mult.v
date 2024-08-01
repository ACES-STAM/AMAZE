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


// Module that performs multiplication between two elements in Galois Field with Prime order.

// Use `GALOIS_MULT_METHOD` parameter to select which multiplication hardware method is used.
// Only the following values of GALOIS_MULT_METHOD are valid:
//     - "peasant"
//     - "barrett"
// Whichever method is selected, the following parameters must be supplied:
//     - N_BITS
//     - PRIME_MODULUS
// Additionally, if "barrett" method is selected, the following parameters must be supplied:
//     - GALOIS_MULT_BARRETT_R

module galois_mult #(
    parameter N_BITS = 254,
    parameter PRIME_MODULUS = 254'h30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000001, // Size: N_BITS
    parameter GALOIS_MULT_METHOD = "peasant",
    parameter GALOIS_MULT_BARRETT_R = 255'h54a47462623a04a7ab074a58680730147144852009e880ae620703a6be1de925 // Size: N_BITS + 1
) (
    input clk,
    input rst,
    input en,
    input  [N_BITS-1:0] num1,
    input  [N_BITS-1:0] num2,
    output [N_BITS-1:0] product,
    output done
);

generate
	case (GALOIS_MULT_METHOD)
		"peasant": begin : DESIGN
			galois_mult_peasant #(
				.N_BITS(N_BITS),
				.PRIME_MODULUS(PRIME_MODULUS)
			) GALOIS_MULT (
				.clk(clk),
				.rst(rst),
				.en(en),
				.num1(num1),
				.num2(num2),
				.product(product),
				.done(done)
			);
		end

		"barrett": begin : DESIGN
			galois_mult_barrett #(
				.N_BITS(N_BITS),
				.PRIME_MODULUS(PRIME_MODULUS),
				.R(GALOIS_MULT_BARRETT_R)
			) GALOIS_MULT (
				.clk(clk),
				.rst(rst),
				.en(en),
				.num1(num1),
				.num2(num2),
				.product(product),
				.done(done)
			);
		end

		"barrett+karatsuba": begin : DESIGN
			galois_mult_karatsuba #(
				.N_BITS(N_BITS),
				.PRIME_MODULUS(PRIME_MODULUS),
				.R(GALOIS_MULT_BARRETT_R)
			) GALOIS_MULT (
				.clk(clk),
				.rst(rst),
				.en(en),
				.num1(num1),
				.num2(num2),
				.product(product),
				.done(done)
			);
		end

		default: begin : DESIGN
			initial $display("[WARNING] using GALOIS_MULT_METHOD=\"peasant\" by default");
			galois_mult_peasant #(
				.N_BITS(N_BITS),
				.PRIME_MODULUS(PRIME_MODULUS)
			) GALOIS_MULT (
				.clk(clk),
				.rst(rst),
				.en(en),
				.num1(num1),
				.num2(num2),
				.product(product),
				.done(done)
			);
		end
	endcase
endgenerate

endmodule
