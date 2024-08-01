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


// Module that implements a MiMC-based hash function (Miyaguchi-Preneel hash construction).
// MiMC configuration: exponent = 7, rounds = 91.

// Refer to file `galois_mult.v` for explanation of parameter `GALOIS_MULT_METHOD`.
// Refer to file `galois_pow_7.v` for explanation of parameter `GALOIS_POW_7_METHOD`.
// Refer to file `mimc_cipher_round.v` for explanation of parameter `MIMC_CIPHER_ROUND_METHOD`.

module mimc_hash #(
	parameter N_BITS = 254,
	parameter GALOIS_MULT_METHOD = "peasant",
	parameter GALOIS_POW_7_METHOD = "parallel",
	parameter MIMC_CIPHER_ROUND_METHOD = "v2"
) (
	input clk,
	input rst,
	input en,
	input  [N_BITS-1:0] in,
	output [N_BITS-1:0] out,
	output reg done
);

// LOCAL PARAMETERS

// States of the state machine
localparam INIT = 3'd1;
localparam COMPUTE_1 = 3'd2;
localparam COMPUTE_2 = 3'd3;
localparam COMPUTE_3 = 3'd4;
localparam COMPUTE_4 = 3'd5;
localparam FINISH = 3'd7;

// REGS AND WIRES DECLARATIONS

// State machine registers
reg [2:0] state, next_state;

// Regs that store operands, intermediate results and final result
reg mimc_rst;
reg mimc_en;
reg [N_BITS-1:0] mimc_key;
reg [N_BITS-1:0] hash;

// Wires used in calculations
wire mimc_done;
wire [N_BITS-1:0] mimc_out;
wire [N_BITS-1:0] add_1_sum;
wire [N_BITS-1:0] add_2_sum;

// Synchronization of the state machine
always @ (posedge clk or posedge rst) begin
	if (rst == 1)
		state <= INIT;
	else
		state <= next_state;
end

// State transition logic of the state machine
always @ (*) begin
	case (state)
		INIT:
			next_state <= COMPUTE_1;
		COMPUTE_1:
			next_state <= en ? COMPUTE_2 : state;
		COMPUTE_2:
			next_state <= COMPUTE_3;
		COMPUTE_3:
			next_state <= mimc_done ? COMPUTE_4 : state;
		COMPUTE_4:
			next_state <= COMPUTE_1;
		FINISH:
			next_state <= state;
		default:
			next_state <= COMPUTE_1;
	endcase
end

// Operation logic in the various states
always @(posedge clk) begin
	case (state)
		INIT: begin
			done <= 1'b0;
			mimc_rst <= 1'b1;
			mimc_en <= 1'b1;
			mimc_key <= 0; // Compiler should automatically infer the integer size
			hash <= 0; // Compiler should automatically infer the integer size
		end
		COMPUTE_1: begin
			mimc_key <= hash;
			done <= 1'b0;
			mimc_rst <= 1'b1;
			// $strobe("[mimc_hash.v] mimc_key=%h", mimc_key);
		end
		COMPUTE_2: begin
			mimc_rst <= 1'b0;
		end
		COMPUTE_3: begin
		end
		COMPUTE_4: begin
			hash <= add_2_sum;
			done <= 1'b1;
			// $strobe("[mimc_hash.v] hash=%h", hash);
		end
	endcase
end

// Output result assignment
assign out = hash;

mimc_cipher #(
	.N_BITS(N_BITS),
	.GALOIS_MULT_METHOD(GALOIS_MULT_METHOD),
	.GALOIS_POW_7_METHOD(GALOIS_POW_7_METHOD),
	.MIMC_CIPHER_ROUND_METHOD(MIMC_CIPHER_ROUND_METHOD)
) MIMC_CIPHER (
	.clk(clk),
	.rst(mimc_rst),
	.en(mimc_en),
	.in(in),
	.key(mimc_key),
	.out(mimc_out),
	.done(mimc_done)
);

galois_add #(
	.N_BITS(N_BITS)
) GALOIS_ADD_1 (
	.num1(in),
	.num2(mimc_out),
	.sum(add_1_sum)
);

galois_add #(
	.N_BITS(N_BITS)
) GALOIS_ADD_2 (
	.num1(add_1_sum),
	.num2(mimc_key),
	.sum(add_2_sum)
);

endmodule
