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


// Module that performs one round of MiMC block cipher (exponent = 7).
// Equivalent to one round of MiMC permutation if key is always set to zero.

// Use `MIMC_CIPHER_ROUND_METHOD` parameter to select which MiMC round hardware method is used.
// Only the following values of MIMC_CIPHER_ROUND_METHOD are valid:
//     - "v1"
//     - "v2"

// Refer to file `galois_mult.v` for explanation of parameter `GALOIS_MULT_METHOD`.
// Refer to file `galois_pow_7.v` for explanation of parameter `GALOIS_POW_7_METHOD`.

module mimc_cipher_round #(
	parameter N_BITS = 254,
	parameter GALOIS_MULT_METHOD = "peasant",
	parameter GALOIS_POW_7_METHOD = "parallel",
	parameter MIMC_CIPHER_ROUND_METHOD = "v2"
) (
	input clk,
	input rst,
	input en,
	input  [N_BITS-1:0] in,
	input  [N_BITS-1:0] round_constant,
	input  [N_BITS-1:0] key,
	output [N_BITS-1:0] out,
	output done
);

generate
	case (MIMC_CIPHER_ROUND_METHOD)
		"v1": begin : DESIGN
			mimc_cipher_round_v1 #(
				.N_BITS(N_BITS),
				.GALOIS_MULT_METHOD(GALOIS_MULT_METHOD),
				.GALOIS_POW_7_METHOD(GALOIS_POW_7_METHOD)
			) MIMC_CIPHER_ROUND (
				.clk(clk),
				.rst(rst),
				.en(en),
				.in(in),
				.round_constant(round_constant),
				.key(key),
				.out(out),
				.done(done)
			);
		end

		"v2": begin : DESIGN
			mimc_cipher_round_v2 #(
				.N_BITS(N_BITS),
				.GALOIS_MULT_METHOD(GALOIS_MULT_METHOD),
				.GALOIS_POW_7_METHOD(GALOIS_POW_7_METHOD)
			) MIMC_CIPHER_ROUND (
				.clk(clk),
				.rst(rst),
				.en(en),
				.in(in),
				.round_constant(round_constant),
				.key(key),
				.out(out),
				.done(done)
			);
		end

		default: begin: DESIGN
			initial $display("[WARNING] using MIMC_CIPHER_ROUND_METHOD=\"v2\" by default");
			mimc_cipher_round_v2 #(
				.N_BITS(N_BITS),
				.GALOIS_MULT_METHOD(GALOIS_MULT_METHOD),
				.GALOIS_POW_7_METHOD(GALOIS_POW_7_METHOD)
			) MIMC_CIPHER_ROUND (
				.clk(clk),
				.rst(rst),
				.en(en),
				.in(in),
				.round_constant(round_constant),
				.key(key),
				.out(out),
				.done(done)
			);
		end
	endcase
endgenerate

endmodule
