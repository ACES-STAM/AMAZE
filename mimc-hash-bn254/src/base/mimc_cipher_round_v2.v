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

// Refer to file `galois_mult.v` for explanation of parameter `GALOIS_MULT_METHOD`.
// Refer to file `galois_pow_7.v` for explanation of parameter `GALOIS_POW_7_METHOD`.

module mimc_cipher_round_v2 #(
	parameter N_BITS = 254,
	parameter GALOIS_MULT_METHOD = "peasant",
	parameter GALOIS_POW_7_METHOD = "parallel"
) (
	input clk,
	input rst,
	input en,
	input  [N_BITS-1:0] in,
	input  [N_BITS-1:0] round_constant,
	input  [N_BITS-1:0] key,
	output [N_BITS-1:0] out,
	output reg done
);

// LOCAL PARAMETERS

// States of the state machine
localparam INIT = 3'd0;
localparam COMPUTE_1 = 3'd1;
localparam COMPUTE_2 = 3'd2;
localparam COMPUTE_3 = 3'd3;
localparam FINISH = 3'd7;

// REGS AND WIRES DECLARATIONS

// State machine registers
reg [3-1:0] state, next_state;

// Regs that store operands, intermediate results and final result
reg pow_rst;
reg pow_en;
reg [N_BITS-1:0] in_plus_key_plus_round_constant;
reg [N_BITS-1:0] add_num1;
reg [N_BITS-1:0] add_num2;

// Wires used in calculations
wire pow_done;
wire [N_BITS-1:0] add_sum;

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
			next_state <= COMPUTE_2;
		COMPUTE_2:
			next_state <= COMPUTE_3;
		COMPUTE_3:
			next_state <= (pow_done) ? FINISH : state;
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
			pow_rst <= 1'b1;
			pow_en <= 1'b1;
			add_num1 <= in;
			add_num2 <= round_constant;
		end
		FINISH: begin
			done <= 1'b1;
			pow_rst <= 1'b1;
		end
		COMPUTE_1: begin
			in_plus_key_plus_round_constant <= add_sum;
			add_num1 <= add_sum;
			add_num2 <= key;
		end
		COMPUTE_2: begin
			in_plus_key_plus_round_constant <= add_sum;
		end
		COMPUTE_3: begin
			pow_rst <= 1'b0;
		end
	endcase
end

galois_add #(
	.N_BITS(N_BITS)
) GALOIS_ADD (
	.num1(add_num1),
	.num2(add_num2),
	.sum(add_sum)
);

galois_pow_7 #(
	.N_BITS(N_BITS),
	.GALOIS_MULT_METHOD(GALOIS_MULT_METHOD),
	.GALOIS_POW_7_METHOD(GALOIS_POW_7_METHOD)
) GALOIS_POW (
	.clk(clk),
	.rst(pow_rst),
	.en(pow_en),
	.base(in_plus_key_plus_round_constant),
	.result(out),
	.done(pow_done)
);

endmodule
