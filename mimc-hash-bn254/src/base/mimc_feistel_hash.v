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


// Module that implements a hash function based on Feistel variant of MiMC (sponge construction).
// MiMC configuration: exponent = 5, rounds = 220.

// Refer to file `galois_mult.v` for explanation of parameter `GALOIS_MULT_METHOD`.

module mimc_feistel_hash #(
	parameter N_BITS = 254,
	parameter GALOIS_MULT_METHOD = "peasant"
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
reg [N_BITS-1:0] state_r;
reg [N_BITS-1:0] state_c;

// Wires used in calculations
wire mimc_done;
wire [N_BITS-1:0] mimc_out_left;
wire [N_BITS-1:0] mimc_out_right;
wire [N_BITS-1:0] state_r_plus_in;

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
			state_r <= 0;
			state_c <= 0;
		end
		COMPUTE_1: begin
			done <= 1'b0;
			mimc_rst <= 1'b1;
		end
		COMPUTE_2: begin
			mimc_rst <= 1'b0;
		end
		COMPUTE_3: begin
		end
		COMPUTE_4: begin
			state_r <= mimc_out_left;
			state_c <= mimc_out_right;
			done <= 1'b1;
			// $strobe("[mimc_feistel_hash.v] mimc_out=(%h, %h)", mimc_out_left, mimc_out_right);
		end
	endcase
end

// Output result assignment
assign out = state_r;

galois_add #(
	.N_BITS(N_BITS)
) GALOIS_ADD (
	.num1(in),
	.num2(state_r),
	.sum(state_r_plus_in)
);

mimc_feistel_cipher #(
	.N_BITS(N_BITS),
	.GALOIS_MULT_METHOD(GALOIS_MULT_METHOD)
) MIMC_FEISTEL_CIPHER (
	.clk(clk),
	.rst(mimc_rst),
	.en(mimc_en),
	.in_left(state_r_plus_in),
	.in_right(state_c),
	.key({N_BITS{1'b0}}), // Key is always zero.
	.out_left(mimc_out_left),
	.out_right(mimc_out_right),
	.done(mimc_done)
);

endmodule
