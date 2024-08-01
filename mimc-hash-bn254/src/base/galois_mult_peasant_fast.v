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

module galois_mult_peasant_fast #(
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
reg [2-1:0] state, next_state;

// Regs that store operands, intermediate results and final result
reg [N_BITS-1:0] x1;
reg [N_BITS-1:0] x2;
reg [N_BITS-1:0] result;

// Wires used in calculations
wire [N_BITS-1:0] result_plus_x1_times_x2;
wire [N_BITS-1:0] out1;
wire [N_BITS-1:0] out2;
wire [(N_BITS+6)-1:0] x1_times_x2;
wire [(N_BITS+6)-1:0] x1_times_64;

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
			// result = result + x1*LowestSixBits(x2)
			result <= result_plus_x1_times_x2;

			// x1 = x1 * 2^6
			x1 <= out2;

			// x2 = x2 / 2^6
			x2 <= x2 >> 6;
		end
	endcase

	// $strobe("[galois_mult_peasant_fast.v] x1=%h", x1);
	// $strobe("[galois_mult_peasant_fast.v] x2=%h", x2);
	// $strobe("[galois_mult_peasant_fast.v]  r=%h", result);
end

// Output result assignment
assign product = result;
assign x1_times_x2 = x1 * x2[6-1:0];

assign x1_times_64 = x1 << 6;

galois_add #(
	.N_BITS(N_BITS)
) GALOIS_ADD (
	.num1(result),
	.num2(out1),
	.sum(result_plus_x1_times_x2)
);

galois_reduce #(
	.N_BITS(N_BITS),
	.PRIME_MODULUS(PRIME_MODULUS)
) REDUCE_1 (
	.x_times_64(x1_times_x2),
	.result(out1)
);

galois_reduce #(
	.N_BITS(N_BITS),
	.PRIME_MODULUS(PRIME_MODULUS)
) REDUCE_2 (
	.x_times_64(x1_times_64),
	.result(out2)
);

endmodule

module galois_reduce #(
	parameter N_BITS = 254,
	parameter PRIME_MODULUS = 254'h30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000001 // Size: N_BITS
) (
	input [(N_BITS+6)-1:0] x_times_64,
	output [N_BITS-1:0] result
);

localparam [(N_BITS+6)-1:0] M_1 = 1 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_2 = 2 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_3 = 3 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_4 = 4 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_5 = 5 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_6 = 6 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_7 = 7 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_8 = 8 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_9 = 9 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_10 = 10 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_11 = 11 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_12 = 12 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_13 = 13 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_14 = 14 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_15 = 15 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_16 = 16 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_17 = 17 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_18 = 18 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_19 = 19 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_20 = 20 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_21 = 21 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_22 = 22 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_23 = 23 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_24 = 24 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_25 = 25 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_26 = 26 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_27 = 27 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_28 = 28 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_29 = 29 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_30 = 30 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_31 = 31 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_32 = 32 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_33 = 33 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_34 = 34 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_35 = 35 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_36 = 36 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_37 = 37 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_38 = 38 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_39 = 39 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_40 = 40 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_41 = 41 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_42 = 42 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_43 = 43 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_44 = 44 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_45 = 45 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_46 = 46 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_47 = 47 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_48 = 48 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_49 = 49 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_50 = 50 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_51 = 51 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_52 = 52 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_53 = 53 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_54 = 54 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_55 = 55 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_56 = 56 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_57 = 57 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_58 = 58 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_59 = 59 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_60 = 60 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_61 = 61 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_62 = 62 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_63 = 63 * PRIME_MODULUS;

assign result = x_times_64 < M_1 ? x_times_64
	: x_times_64 < M_2 ? x_times_64 - M_1
    : x_times_64 < M_3 ? x_times_64 - M_2
    : x_times_64 < M_4 ? x_times_64 - M_3
    : x_times_64 < M_5 ? x_times_64 - M_4
    : x_times_64 < M_6 ? x_times_64 - M_5
    : x_times_64 < M_7 ? x_times_64 - M_6
    : x_times_64 < M_8 ? x_times_64 - M_7
    : x_times_64 < M_9 ? x_times_64 - M_8
    : x_times_64 < M_10 ? x_times_64 - M_9
    : x_times_64 < M_11 ? x_times_64 - M_10
    : x_times_64 < M_12 ? x_times_64 - M_11
    : x_times_64 < M_13 ? x_times_64 - M_12
    : x_times_64 < M_14 ? x_times_64 - M_13
    : x_times_64 < M_15 ? x_times_64 - M_14
    : x_times_64 < M_16 ? x_times_64 - M_15
    : x_times_64 < M_17 ? x_times_64 - M_16
    : x_times_64 < M_18 ? x_times_64 - M_17
    : x_times_64 < M_19 ? x_times_64 - M_18
    : x_times_64 < M_20 ? x_times_64 - M_19
    : x_times_64 < M_21 ? x_times_64 - M_20
    : x_times_64 < M_22 ? x_times_64 - M_21
    : x_times_64 < M_23 ? x_times_64 - M_22
    : x_times_64 < M_24 ? x_times_64 - M_23
    : x_times_64 < M_25 ? x_times_64 - M_24
    : x_times_64 < M_26 ? x_times_64 - M_25
    : x_times_64 < M_27 ? x_times_64 - M_26
    : x_times_64 < M_28 ? x_times_64 - M_27
    : x_times_64 < M_29 ? x_times_64 - M_28
    : x_times_64 < M_30 ? x_times_64 - M_29
    : x_times_64 < M_31 ? x_times_64 - M_30
    : x_times_64 < M_32 ? x_times_64 - M_31
    : x_times_64 < M_33 ? x_times_64 - M_32
    : x_times_64 < M_34 ? x_times_64 - M_33
    : x_times_64 < M_35 ? x_times_64 - M_34
    : x_times_64 < M_36 ? x_times_64 - M_35
    : x_times_64 < M_37 ? x_times_64 - M_36
    : x_times_64 < M_38 ? x_times_64 - M_37
    : x_times_64 < M_39 ? x_times_64 - M_38
    : x_times_64 < M_40 ? x_times_64 - M_39
    : x_times_64 < M_41 ? x_times_64 - M_40
    : x_times_64 < M_42 ? x_times_64 - M_41
    : x_times_64 < M_43 ? x_times_64 - M_42
    : x_times_64 < M_44 ? x_times_64 - M_43
    : x_times_64 < M_45 ? x_times_64 - M_44
    : x_times_64 < M_46 ? x_times_64 - M_45
    : x_times_64 < M_47 ? x_times_64 - M_46
    : x_times_64 < M_48 ? x_times_64 - M_47
    : x_times_64 < M_49 ? x_times_64 - M_48
    : x_times_64 < M_50 ? x_times_64 - M_49
    : x_times_64 < M_51 ? x_times_64 - M_50
    : x_times_64 < M_52 ? x_times_64 - M_51
    : x_times_64 < M_53 ? x_times_64 - M_52
    : x_times_64 < M_54 ? x_times_64 - M_53
    : x_times_64 < M_55 ? x_times_64 - M_54
    : x_times_64 < M_56 ? x_times_64 - M_55
    : x_times_64 < M_57 ? x_times_64 - M_56
    : x_times_64 < M_58 ? x_times_64 - M_57
    : x_times_64 < M_59 ? x_times_64 - M_58
    : x_times_64 < M_60 ? x_times_64 - M_59
    : x_times_64 < M_61 ? x_times_64 - M_60
    : x_times_64 < M_62 ? x_times_64 - M_61
    : x_times_64 < M_63 ? x_times_64 - M_62
    : x_times_64 - M_63;

endmodule

module galois_reduce_small #(
	parameter N_BITS = 254,
	parameter PRIME_MODULUS = 254'h30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000001 // Size: N_BITS
) (
	input [(N_BITS+6)-1:0] x_times_64,
	output [N_BITS-1:0] result
);

localparam [(N_BITS+6)-1:0] M_1 = 1 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_2 = 2 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_3 = 3 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_4 = 4 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_5 = 5 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_6 = 6 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_7 = 7 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_8 = 8 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_9 = 9 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_10 = 10 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_11 = 11 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_12 = 12 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_13 = 13 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_14 = 14 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_15 = 15 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_16 = 16 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_17 = 17 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_18 = 18 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_19 = 19 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_20 = 20 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_21 = 21 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_22 = 22 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_23 = 23 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_24 = 24 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_25 = 25 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_26 = 26 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_27 = 27 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_28 = 28 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_29 = 29 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_30 = 30 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_31 = 31 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_32 = 32 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_33 = 33 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_34 = 34 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_35 = 35 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_36 = 36 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_37 = 37 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_38 = 38 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_39 = 39 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_40 = 40 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_41 = 41 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_42 = 42 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_43 = 43 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_44 = 44 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_45 = 45 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_46 = 46 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_47 = 47 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_48 = 48 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_49 = 49 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_50 = 50 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_51 = 51 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_52 = 52 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_53 = 53 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_54 = 54 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_55 = 55 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_56 = 56 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_57 = 57 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_58 = 58 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_59 = 59 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_60 = 60 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_61 = 61 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_62 = 62 * PRIME_MODULUS;
localparam [(N_BITS+6)-1:0] M_63 = 63 * PRIME_MODULUS;

wire signed [(N_BITS+6+1)-1:0] sub_2 = x_times_64 - M_2;
wire signed [(N_BITS+6+1)-1:0] sub_3 = x_times_64 - M_3;
wire signed [(N_BITS+6+1)-1:0] sub_1 = x_times_64 - M_1;
wire signed [(N_BITS+6+1)-1:0] sub_4 = x_times_64 - M_4;
wire signed [(N_BITS+6+1)-1:0] sub_5 = x_times_64 - M_5;
wire signed [(N_BITS+6+1)-1:0] sub_6 = x_times_64 - M_6;
wire signed [(N_BITS+6+1)-1:0] sub_7 = x_times_64 - M_7;
wire signed [(N_BITS+6+1)-1:0] sub_8 = x_times_64 - M_8;
wire signed [(N_BITS+6+1)-1:0] sub_9 = x_times_64 - M_9;
wire signed [(N_BITS+6+1)-1:0] sub_10 = x_times_64 - M_10;
wire signed [(N_BITS+6+1)-1:0] sub_11 = x_times_64 - M_11;
wire signed [(N_BITS+6+1)-1:0] sub_12 = x_times_64 - M_12;
wire signed [(N_BITS+6+1)-1:0] sub_13 = x_times_64 - M_13;
wire signed [(N_BITS+6+1)-1:0] sub_14 = x_times_64 - M_14;
wire signed [(N_BITS+6+1)-1:0] sub_15 = x_times_64 - M_15;
wire signed [(N_BITS+6+1)-1:0] sub_16 = x_times_64 - M_16;
wire signed [(N_BITS+6+1)-1:0] sub_17 = x_times_64 - M_17;
wire signed [(N_BITS+6+1)-1:0] sub_18 = x_times_64 - M_18;
wire signed [(N_BITS+6+1)-1:0] sub_19 = x_times_64 - M_19;
wire signed [(N_BITS+6+1)-1:0] sub_20 = x_times_64 - M_20;
wire signed [(N_BITS+6+1)-1:0] sub_21 = x_times_64 - M_21;
wire signed [(N_BITS+6+1)-1:0] sub_22 = x_times_64 - M_22;
wire signed [(N_BITS+6+1)-1:0] sub_23 = x_times_64 - M_23;
wire signed [(N_BITS+6+1)-1:0] sub_24 = x_times_64 - M_24;
wire signed [(N_BITS+6+1)-1:0] sub_25 = x_times_64 - M_25;
wire signed [(N_BITS+6+1)-1:0] sub_26 = x_times_64 - M_26;
wire signed [(N_BITS+6+1)-1:0] sub_27 = x_times_64 - M_27;
wire signed [(N_BITS+6+1)-1:0] sub_28 = x_times_64 - M_28;
wire signed [(N_BITS+6+1)-1:0] sub_29 = x_times_64 - M_29;
wire signed [(N_BITS+6+1)-1:0] sub_30 = x_times_64 - M_30;
wire signed [(N_BITS+6+1)-1:0] sub_31 = x_times_64 - M_31;
wire signed [(N_BITS+6+1)-1:0] sub_32 = x_times_64 - M_32;
wire signed [(N_BITS+6+1)-1:0] sub_33 = x_times_64 - M_33;
wire signed [(N_BITS+6+1)-1:0] sub_34 = x_times_64 - M_34;
wire signed [(N_BITS+6+1)-1:0] sub_35 = x_times_64 - M_35;
wire signed [(N_BITS+6+1)-1:0] sub_36 = x_times_64 - M_36;
wire signed [(N_BITS+6+1)-1:0] sub_37 = x_times_64 - M_37;
wire signed [(N_BITS+6+1)-1:0] sub_38 = x_times_64 - M_38;
wire signed [(N_BITS+6+1)-1:0] sub_39 = x_times_64 - M_39;
wire signed [(N_BITS+6+1)-1:0] sub_40 = x_times_64 - M_40;
wire signed [(N_BITS+6+1)-1:0] sub_41 = x_times_64 - M_41;
wire signed [(N_BITS+6+1)-1:0] sub_42 = x_times_64 - M_42;
wire signed [(N_BITS+6+1)-1:0] sub_43 = x_times_64 - M_43;
wire signed [(N_BITS+6+1)-1:0] sub_44 = x_times_64 - M_44;
wire signed [(N_BITS+6+1)-1:0] sub_45 = x_times_64 - M_45;
wire signed [(N_BITS+6+1)-1:0] sub_46 = x_times_64 - M_46;
wire signed [(N_BITS+6+1)-1:0] sub_47 = x_times_64 - M_47;
wire signed [(N_BITS+6+1)-1:0] sub_48 = x_times_64 - M_48;
wire signed [(N_BITS+6+1)-1:0] sub_49 = x_times_64 - M_49;
wire signed [(N_BITS+6+1)-1:0] sub_50 = x_times_64 - M_50;
wire signed [(N_BITS+6+1)-1:0] sub_51 = x_times_64 - M_51;
wire signed [(N_BITS+6+1)-1:0] sub_52 = x_times_64 - M_52;
wire signed [(N_BITS+6+1)-1:0] sub_53 = x_times_64 - M_53;
wire signed [(N_BITS+6+1)-1:0] sub_54 = x_times_64 - M_54;
wire signed [(N_BITS+6+1)-1:0] sub_55 = x_times_64 - M_55;
wire signed [(N_BITS+6+1)-1:0] sub_56 = x_times_64 - M_56;
wire signed [(N_BITS+6+1)-1:0] sub_57 = x_times_64 - M_57;
wire signed [(N_BITS+6+1)-1:0] sub_58 = x_times_64 - M_58;
wire signed [(N_BITS+6+1)-1:0] sub_59 = x_times_64 - M_59;
wire signed [(N_BITS+6+1)-1:0] sub_60 = x_times_64 - M_60;
wire signed [(N_BITS+6+1)-1:0] sub_61 = x_times_64 - M_61;
wire signed [(N_BITS+6+1)-1:0] sub_62 = x_times_64 - M_62;
wire signed [(N_BITS+6+1)-1:0] sub_63 = x_times_64 - M_63;

assign result = sub_63 >= 0 ? sub_63
    : sub_62 >= 0 ? sub_62
    : sub_61 >= 0 ? sub_61
    : sub_60 >= 0 ? sub_60
    : sub_59 >= 0 ? sub_59
    : sub_58 >= 0 ? sub_58
    : sub_57 >= 0 ? sub_57
    : sub_56 >= 0 ? sub_56
    : sub_55 >= 0 ? sub_55
    : sub_54 >= 0 ? sub_54
    : sub_53 >= 0 ? sub_53
    : sub_52 >= 0 ? sub_52
    : sub_51 >= 0 ? sub_51
    : sub_50 >= 0 ? sub_50
    : sub_49 >= 0 ? sub_49
    : sub_48 >= 0 ? sub_48
    : sub_47 >= 0 ? sub_47
    : sub_46 >= 0 ? sub_46
    : sub_45 >= 0 ? sub_45
    : sub_44 >= 0 ? sub_44
    : sub_43 >= 0 ? sub_43
    : sub_42 >= 0 ? sub_42
    : sub_41 >= 0 ? sub_41
    : sub_40 >= 0 ? sub_40
    : sub_39 >= 0 ? sub_39
    : sub_38 >= 0 ? sub_38
    : sub_37 >= 0 ? sub_37
    : sub_36 >= 0 ? sub_36
    : sub_35 >= 0 ? sub_35
    : sub_34 >= 0 ? sub_34
    : sub_33 >= 0 ? sub_33
    : sub_32 >= 0 ? sub_32
    : sub_31 >= 0 ? sub_31
    : sub_30 >= 0 ? sub_30
    : sub_29 >= 0 ? sub_29
    : sub_28 >= 0 ? sub_28
    : sub_27 >= 0 ? sub_27
    : sub_26 >= 0 ? sub_26
    : sub_25 >= 0 ? sub_25
    : sub_24 >= 0 ? sub_24
    : sub_23 >= 0 ? sub_23
    : sub_22 >= 0 ? sub_22
    : sub_21 >= 0 ? sub_21
    : sub_20 >= 0 ? sub_20
    : sub_19 >= 0 ? sub_19
    : sub_18 >= 0 ? sub_18
    : sub_17 >= 0 ? sub_17
    : sub_16 >= 0 ? sub_16
    : sub_15 >= 0 ? sub_15
    : sub_14 >= 0 ? sub_14
    : sub_13 >= 0 ? sub_13
    : sub_12 >= 0 ? sub_12
    : sub_11 >= 0 ? sub_11
    : sub_10 >= 0 ? sub_10
    : sub_9 >= 0 ? sub_9
    : sub_8 >= 0 ? sub_8
    : sub_7 >= 0 ? sub_7
    : sub_6 >= 0 ? sub_6
    : sub_5 >= 0 ? sub_5
    : sub_4 >= 0 ? sub_4
    : sub_3 >= 0 ? sub_3
    : sub_2 >= 0 ? sub_2
    : sub_1 >= 0 ? sub_1
    : x_times_64;

endmodule
