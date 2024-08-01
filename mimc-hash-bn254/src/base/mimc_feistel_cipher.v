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


// Module that performs all rounds of Feistel variant of MiMC block cipher (exponent = 5, rounds = 220).
// Equivalent to all rounds of Feistel variant of MiMC permutation if key is always set to zero.

// Refer to file `galois_mult.v` for explanation of parameter `GALOIS_MULT_METHOD`.

module mimc_feistel_cipher #(
	parameter N_BITS = 254,
	parameter ROUNDS = 220,
	parameter GALOIS_MULT_METHOD = "peasant"
) (
	input clk,
	input rst,
	input en,
	input  [N_BITS-1:0] in_left,
	input  [N_BITS-1:0] in_right,
	input  [N_BITS-1:0] key,
	output [N_BITS-1:0] out_left,
	output [N_BITS-1:0] out_right,
	output reg done
);

// LOCAL PARAMETERS

localparam ROUNDS_N_BITS = $clog2(ROUNDS);

// States of the state machine
localparam INIT = 3'd1;
localparam COMPUTE_1 = 3'd2;
localparam COMPUTE_2 = 3'd3;
localparam COMPUTE_3 = 3'd4;
localparam FINISH = 3'd7;

// REGS AND WIRES DECLARATIONS

// State machine registers
reg [2:0] state, next_state;

// Regs that store operands, intermediate results and final result
reg mimc_round_rst;
reg mimc_round_en;
reg [N_BITS-1:0] mimc_round_in_left;
reg [N_BITS-1:0] mimc_round_in_right;
reg [N_BITS-1:0] mimc_round_constant;
reg mimc_round_is_last;
reg [ROUNDS_N_BITS-1:0] round_count;

// Memory region for storing MiMC round constants
reg [N_BITS-1:0] memory_all_round_constants [0:ROUNDS-1];

// Wires used in calculations
wire mimc_round_done;
wire [N_BITS-1:0] mimc_round_out_left;
wire [N_BITS-1:0] mimc_round_out_right;

// Loading of all MiMC round constants
initial begin
	$readmemh("../data/mimc_5_220_bn254_round_constants.txt", memory_all_round_constants);
end

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
			next_state <= (en) ? COMPUTE_1 : state;
		COMPUTE_1:
			next_state <= (round_count == ROUNDS) ? FINISH : COMPUTE_2;
		COMPUTE_2:
			next_state <= mimc_round_done ? COMPUTE_3 : state;
		COMPUTE_3:
			next_state <= COMPUTE_1;
		FINISH:
			next_state <= state;
		default:
			next_state <= INIT;
	endcase
end

// Operation logic in the various states
always @(posedge clk) begin
	case (state)
		INIT: begin
			done <= 1'b0;
			round_count <= 0;
			mimc_round_in_left <= in_left;
			mimc_round_in_right <= in_right;
			mimc_round_is_last <= 1'b0;
			mimc_round_rst <= 1'b1;
			mimc_round_en <= 1'b1;
		end
		FINISH: begin
			done <= 1'b1;
		end
		COMPUTE_1: begin
			mimc_round_constant <= memory_all_round_constants[round_count];
			mimc_round_is_last <= (round_count + 1 == ROUNDS);
			// $strobe("[mimc_feistel_cipher.v] mimc_round_constant=%h", mimc_round_constant);
			// $strobe("[mimc_feistel_cipher.v] mimc_round_is_last=%h", mimc_round_is_last);
		end
		COMPUTE_2: begin
			mimc_round_rst <= 1'b0;
		end
		COMPUTE_3: begin
			mimc_round_in_left <= mimc_round_out_left;
			mimc_round_in_right <= mimc_round_out_right;
			mimc_round_rst <= 1'b1;
			round_count <= round_count + 1;
			// $strobe("[mimc_feistel_cipher.v] mimc_round_out=(%h, %h)", mimc_round_out_left, mimc_round_out_right);
			// $strobe("[mimc_feistel_cipher.v] round_count=%d", round_count);
		end
	endcase
end

assign out_left = mimc_round_in_left;
assign out_right = mimc_round_in_right;

mimc_feistel_cipher_round #(
	.N_BITS(N_BITS),
	.GALOIS_MULT_METHOD(GALOIS_MULT_METHOD)
) MIMC_FEISTEL_CIPHER_ROUND (
	.clk(clk),
	.rst(mimc_round_rst),
	.en(mimc_round_en),
	.in_left(mimc_round_in_left),
	.in_right(mimc_round_in_right),
	.round_constant(mimc_round_constant),
	.key(key),
	.is_last_round(mimc_round_is_last),
	.out_left(mimc_round_out_left),
	.out_right(mimc_round_out_right),
	.done(mimc_round_done)
);

endmodule
