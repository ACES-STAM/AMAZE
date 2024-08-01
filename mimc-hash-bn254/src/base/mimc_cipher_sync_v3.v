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


// Module that performs all rounds of MiMC block cipher (exponent = 7, rounds = 91).
// Equivalent to all rounds of MiMC permutation if key is always set to zero.

// Pipelined design: supports multiple in-flight computations.
//     - Latency: 3640 clock cycles (including the cycle in which inputs are injected).
//     - Pipeline length: 3640 clock cycles.
//     - Accepts new request in each of the first 13 clock cycles in every 3640-clock-cycle period.

module mimc_cipher_sync_v3 #(
    parameter N_BITS = 254,
    parameter ROUNDS = 91,
    parameter PRIME_MODULUS = 254'h30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000001, // Size: N_BITS
    parameter BARRETT_R = 255'h54a47462623a04a7ab074a58680730147144852009e880ae620703a6be1de925 // Size: N_BITS + 1
) (
    input clk,
    input  [N_BITS-1:0] in,
	input  [N_BITS-1:0] key,
	output [N_BITS-1:0] out
);

localparam MIMC_CIPHER_ROUND_LATENCY = 39 + 1; // Clock cylces
localparam COMPUTE_PHASES = MIMC_CIPHER_ROUND_LATENCY;
localparam LAST_READY_PHASE = 13; // Equal to MULT_LATENCY in galois_pow_7_sync_v3.v

reg [$clog2(COMPUTE_PHASES)-1:0] compute_phase = 0;

reg [$clog2(ROUNDS)-1:0] round_count = 0;

reg [N_BITS-1:0] mimc_round_in;
reg [N_BITS-1:0] mimc_round_constant;
reg [N_BITS-1:0] mimc_round_key;

reg [N_BITS-1:0] key_saved [0:LAST_READY_PHASE-1];

wire [N_BITS-1:0] mimc_round_out;

// Memory region for storing MiMC round constants
reg [N_BITS-1:0] memory_all_round_constants [0:ROUNDS-1];

// Loading of all MiMC round constants
initial begin
	$readmemh("../data/mimc_7_91_bn254_round_constants.txt", memory_all_round_constants);
end

// Operation logic
always @(posedge clk) begin
    compute_phase <= (compute_phase + 1'b1) % COMPUTE_PHASES;

    if (compute_phase == LAST_READY_PHASE) begin
        round_count <= (round_count + 1'b1) % ROUNDS;
        // $strobe("[mimc_cipher_sync_v3.v] (round_count + 1)=%d", round_count);
    end

    if (0 <= compute_phase && compute_phase <= LAST_READY_PHASE) begin
        mimc_round_constant <= memory_all_round_constants[round_count];
        // $strobe("[mimc_cipher_sync_v3.v] mimc_round_constant=%h", mimc_round_constant);


        if (round_count == 0) begin
            mimc_round_key <= key;
            key_saved[compute_phase] <= key;
        end else begin
            mimc_round_key <= key_saved[compute_phase];
        end
        // $strobe("[mimc_cipher_sync_v3.v] mimc_round_key=%h", mimc_round_key);

        if (round_count == 0) begin
            mimc_round_in <= in;
        end else begin
            mimc_round_in <= mimc_round_out;
        end
        // $strobe("[mimc_cipher_sync_v3.v] mimc_round_in=%h", mimc_round_in);
    end
end

mimc_cipher_round_sync_v3 #(
    .N_BITS(N_BITS),
    .PRIME_MODULUS(PRIME_MODULUS),
    .BARRETT_R(BARRETT_R)
) MIMC_CIPHER_ROUND (
	.clk(clk),
	.in(mimc_round_in),
	.round_constant(mimc_round_constant),
	.key(mimc_round_key),
	.out(mimc_round_out)
);

galois_add #(
	.N_BITS(N_BITS)
) ADD (
	.num1(mimc_round_out),
	.num2(key_saved[compute_phase]),
	.sum(out)
);

endmodule
