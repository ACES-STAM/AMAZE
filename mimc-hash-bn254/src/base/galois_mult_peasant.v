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
// Uses Russian peasant multiplication method (simultaneous multiplication and reduction).

// Russian Peasant Multiplication Algorithm: https://en.wikipedia.org/wiki/Ancient_Egyptian_multiplication#Russian_peasant_multiplication
//                                           https://en.wikipedia.org/wiki/Finite_field_arithmetic#C_programming_example

module galois_mult_peasant #(
	parameter N_BITS = 254,
	parameter PRIME_MODULUS = 254'h30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000001 // Size: N_BITS
) (
	input clk,
	input rst,
	input en,
	input  [N_BITS-1:0] num1,
	input  [N_BITS-1:0] num2,
	output [N_BITS-1:0] product,
	output reg done
);

// LOCAL PARAMETERS

// States of the state machine
localparam INIT = 3'd1;
localparam COMPUTE = 3'd2;
localparam FINISH = 3'd3;

// REGS AND WIRES DECLARATIONS

// State machine registers
reg [1:0] state, next_state;

// Regs that store operands, intermediate results and final result
reg [N_BITS-1:0] x1;
reg [N_BITS-1:0] x2;
reg [N_BITS-1:0] result;

// Wires used in calculations
wire [N_BITS-1:0] result_plus_x1;
wire [N_BITS-1:0] x1_times_two;

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
			next_state <= (en) ? COMPUTE : state;
		COMPUTE:
			next_state <= (x1 == 0 || x2 == 0) ? FINISH : state;
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
			x1 <= num1;
			x2 <= num2;
			done <= 1'b0;
			result <= 0;
		end
		FINISH: begin
			done <= 1'b1;
		end
		COMPUTE: begin
			if (x2[0]) begin // If LSB of x2 is 1
				// result = result + x1
				result <= result_plus_x1;
			end

			// x1 = x1 * 2
			x1 <= x1_times_two;

			// x2 = x2 / 2
			x2 <= x2 >> 1;
		end
	endcase
end

// Output result assignment
assign product = result;

galois_add #(
	.N_BITS(N_BITS)
) GALOIS_ADD_1 (
	.num1(result),
	.num2(x1),
	.sum(result_plus_x1)
);

galois_add #(
	.N_BITS(N_BITS)
) GALOIS_ADD_2 (
	.num1(x1),
	.num2(x1),
	.sum(x1_times_two)
);

endmodule
