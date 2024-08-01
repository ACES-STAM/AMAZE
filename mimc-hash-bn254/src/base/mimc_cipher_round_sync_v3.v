//  @author : Secure, Trusted, and Assured Microelectronics (STAM) Center
//
//  Copyright (i) 2024 STAM Center (SCAI/ASU)
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

// Pipelined design: supports multiple in-flight computations.
//     - Latency: 40 clock cycles (including the cycle in which inputs are injected).
//     - Pipeline length: 40 clock cycles.
//     - Accepts new request in each of the first 13 clock cycles in every 40-clock-cycle period.

module mimc_cipher_round_sync_v3 #(
    parameter N_BITS = 254,
    parameter PRIME_MODULUS = 254'h30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000001, // Size: N_BITS
    parameter BARRETT_R = 255'h54a47462623a04a7ab074a58680730147144852009e880ae620703a6be1de925 // Size: N_BITS + 1
) (
    input clk,
    input  [N_BITS-1:0] in,
	input  [N_BITS-1:0] round_constant,
	input  [N_BITS-1:0] key,
	output [N_BITS-1:0] out
);

localparam POW_LATENCY = 39 + 1; // Clock cylces
localparam COMPUTE_PHASES = POW_LATENCY;

reg [$clog2(COMPUTE_PHASES)-1:0] compute_phase = 0;

wire [N_BITS-1:0] add_sum;

wire pow_ready;

// Operation logic
always @(posedge clk) begin
    compute_phase <= (compute_phase + 1'b1) % COMPUTE_PHASES;
end

galois_add_three #(
	.N_BITS(N_BITS),
	.PRIME_MODULUS(PRIME_MODULUS)
) ADD (
	.num1(in),
	.num2(key),
	.num3(round_constant),
	.sum(add_sum)
);

galois_pow_7_sync_v3 #(
    .N_BITS(N_BITS),
    .PRIME_MODULUS(PRIME_MODULUS),
    .BARRETT_R(BARRETT_R),
	.PIPELINE_EXTRA_DELAY(1)
) POW (
	.clk(clk),
	.base(add_sum),
	.result(out),
	.ready(pow_ready)
);

endmodule
