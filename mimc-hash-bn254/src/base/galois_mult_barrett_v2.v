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
// Performs a large multiplication first and then performs a Barrett reduction.

// Barrett Reduction Algorithm: https://doi.org/10.1007/3-540-47721-7_24
//     (Refer to Diagram Five)

module galois_mult_barrett_v2 #(
	parameter N_BITS = 254,
	parameter PRIME_MODULUS = 254'h30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000001, // Size: N_BITS
	parameter R = 255'h54a47462623a04a7ab074a58680730147144852009e880ae620703a6be1de925 // Size: N_BITS + 1
) (
	input clk,
	input rst,
	input en,
	input  [N_BITS-1:0] num1,
	input  [N_BITS-1:0] num2,
	output [N_BITS-1:0] product,
	output reg done
);

// States of the state machine
localparam INIT = 3'd1;
localparam COMPUTE_1 = 3'd2;
localparam COMPUTE_2 = 3'd3;
localparam COMPUTE_3 = 3'd4;
localparam FINISH = 3'd7;

// State machine registers
reg [3-1:0] state, next_state;

reg [(2*N_BITS)-1:0] w;

wire [(N_BITS+1)-1:0] x1;
wire [(N_BITS+1)-1:0] x2;
wire [(N_BITS+1)-1:0] x3;

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
			next_state <= FINISH;
		FINISH:
			next_state <= state;
		default:
			next_state <= INIT;
	endcase
end

wire [(N_BITS+1)-1:0] t1;
assign t1 = w[2*N_BITS-1:N_BITS-1];

wire [27-1:0] ym1 [0:10-1];
assign ym1[0] = t1[27*0 +: 27];
assign ym1[1] = t1[27*1 +: 27];
assign ym1[2] = t1[27*2 +: 27];
assign ym1[3] = t1[27*3 +: 27];
assign ym1[4] = t1[27*4 +: 27];
assign ym1[5] = t1[27*5 +: 27];
assign ym1[6] = t1[27*6 +: 27];
assign ym1[7] = t1[27*7 +: 27];
assign ym1[8] = t1[27*8 +: 27];
assign ym1[9] = t1[27*9 +: 12];

wire [27-1:0] ym2 [0:10-1];
assign ym2[0] = R[27*0 +: 27];
assign ym2[1] = R[27*1 +: 27];
assign ym2[2] = R[27*2 +: 27];
assign ym2[3] = R[27*3 +: 27];
assign ym2[4] = R[27*4 +: 27];
assign ym2[5] = R[27*5 +: 27];
assign ym2[6] = R[27*6 +: 27];
assign ym2[7] = R[27*7 +: 27];
assign ym2[8] = R[27*8 +: 27];
assign ym2[9] = R[27*9 +: 12];

reg [(2*27+9)-1:0] y_parts [0:20-1]; // TODO: reduce array size from 20 to 12=10+2

initial begin
	y_parts[0] <= 0;
	y_parts[1] <= 0;
	y_parts[2] <= 0;
	y_parts[3] <= 0;
	y_parts[4] <= 0;
	y_parts[5] <= 0;
	y_parts[6] <= 0;
	y_parts[7] <= 0;
	y_parts[19] <= 0;
end

wire [(2*(N_BITS+1))-1:0] y_short;
assign y_short = y_parts[0]
	+ (y_parts[1] << 27*1)
	+ (y_parts[2] << 27*2)
	+ (y_parts[3] << 27*3)
	+ (y_parts[4] << 27*4)
	+ (y_parts[5] << 27*5)
	+ (y_parts[6] << 27*6)
	+ (y_parts[7] << 27*7)
	+ (y_parts[8] << 27*8)
	+ (y_parts[9] << 27*9)
	+ (y_parts[10] << 27*10)
	+ (y_parts[11] << 27*11)
	+ (y_parts[12] << 27*12)
	+ (y_parts[13] << 27*13)
	+ (y_parts[14] << 27*14)
	+ (y_parts[15] << 27*15)
	+ (y_parts[16] << 27*16)
	+ (y_parts[17] << 27*17)
	+ (y_parts[18] << 27*18)
	+ (y_parts[19] << 27*19);

reg [(2*27+9)-1:0] z_parts [0:10-1];

wire [(2*N_BITS)-1:0] z_short;
assign z_short = z_parts[0]
	+ (z_parts[1] << 27*1)
	+ (z_parts[2] << 27*2)
	+ (z_parts[3] << 27*3)
	+ (z_parts[4] << 27*4)
	+ (z_parts[5] << 27*5)
	+ (z_parts[6] << 27*6)
	+ (z_parts[7] << 27*7)
	+ (z_parts[8] << 27*8)
	+ (z_parts[9] << 27*9);

wire [N_BITS-1:0] t0;
assign t0 = y_short[2*N_BITS:N_BITS+1];

wire [27-1:0] zm1 [0:10-1];
assign zm1[0] = t0[27*0 +: 27];
assign zm1[1] = t0[27*1 +: 27];
assign zm1[2] = t0[27*2 +: 27];
assign zm1[3] = t0[27*3 +: 27];
assign zm1[4] = t0[27*4 +: 27];
assign zm1[5] = t0[27*5 +: 27];
assign zm1[6] = t0[27*6 +: 27];
assign zm1[7] = t0[27*7 +: 27];
assign zm1[8] = t0[27*8 +: 27];
assign zm1[9] = t0[27*9 +: 11];

wire [27-1:0] zm2 [0:10-1];
assign zm2[0] = PRIME_MODULUS[27*0 +: 27];
assign zm2[1] = PRIME_MODULUS[27*1 +: 27];
assign zm2[2] = PRIME_MODULUS[27*2 +: 27];
assign zm2[3] = PRIME_MODULUS[27*3 +: 27];
assign zm2[4] = PRIME_MODULUS[27*4 +: 27];
assign zm2[5] = PRIME_MODULUS[27*5 +: 27];
assign zm2[6] = PRIME_MODULUS[27*6 +: 27];
assign zm2[7] = PRIME_MODULUS[27*7 +: 27];
assign zm2[8] = PRIME_MODULUS[27*8 +: 27];
assign zm2[9] = PRIME_MODULUS[27*9 +: 11];

// Operation logic in the various states
always @(posedge clk) begin
	case (state)
		INIT: begin
			done <= 1'b0;
		end
		FINISH: begin
			done <= 1'b1;
		end
		COMPUTE_1: begin
			w <= num1 * num2;
			// $strobe("[galois_mult_barrett_v2.v] w=%h", w);
		end
		COMPUTE_2: begin
			y_parts[8] <= ym1[0]*ym2[8] + ym1[1]*ym2[7] + ym1[2]*ym2[6] + ym1[3]*ym2[5] + ym1[4]*ym2[4] + ym1[5]*ym2[3] + ym1[6]*ym2[2] + ym1[7]*ym2[1] + ym1[8]*ym2[0];
			y_parts[9] <= ym1[0]*ym2[9] + ym1[1]*ym2[8] + ym1[2]*ym2[7] + ym1[3]*ym2[6] + ym1[4]*ym2[5] + ym1[5]*ym2[4] + ym1[6]*ym2[3] + ym1[7]*ym2[2] + ym1[8]*ym2[1] + ym1[9]*ym2[0];
			y_parts[10] <= ym1[1]*ym2[9] + ym1[2]*ym2[8] + ym1[3]*ym2[7] + ym1[4]*ym2[6] + ym1[5]*ym2[5] + ym1[6]*ym2[4] + ym1[7]*ym2[3] + ym1[8]*ym2[2] + ym1[9]*ym2[1];
			y_parts[11] <= ym1[2]*ym2[9] + ym1[3]*ym2[8] + ym1[4]*ym2[7] + ym1[5]*ym2[6] + ym1[6]*ym2[5] + ym1[7]*ym2[4] + ym1[8]*ym2[3] + ym1[9]*ym2[2];
			y_parts[12] <= ym1[3]*ym2[9] + ym1[4]*ym2[8] + ym1[5]*ym2[7] + ym1[6]*ym2[6] + ym1[7]*ym2[5] + ym1[8]*ym2[4] + ym1[9]*ym2[3];
			y_parts[13] <= ym1[4]*ym2[9] + ym1[5]*ym2[8] + ym1[6]*ym2[7] + ym1[7]*ym2[6] + ym1[8]*ym2[5] + ym1[9]*ym2[4];
			y_parts[14] <= ym1[5]*ym2[9] + ym1[6]*ym2[8] + ym1[7]*ym2[7] + ym1[8]*ym2[6] + ym1[9]*ym2[5];
			y_parts[15] <= ym1[6]*ym2[9] + ym1[7]*ym2[8] + ym1[8]*ym2[7] + ym1[9]*ym2[6];
			y_parts[16] <= ym1[7]*ym2[9] + ym1[8]*ym2[8] + ym1[9]*ym2[7];
			y_parts[17] <= ym1[8]*ym2[9] + ym1[9]*ym2[8];
			y_parts[18] <= ym1[9]*ym2[9];
			// $strobe("[galois_mult_barrett_v2.v] y<partial>=%h", y_short[2*N_BITS:N_BITS+1]);
		end
		COMPUTE_3: begin
			z_parts[0] <= zm1[0]*zm2[0];
			z_parts[1] <= zm1[0]*zm2[1] + zm1[1]*zm2[0];
			z_parts[2] <= zm1[0]*zm2[2] + zm1[1]*zm2[1] + zm1[2]*zm2[0];
			z_parts[3] <= zm1[0]*zm2[3] + zm1[1]*zm2[2] + zm1[2]*zm2[1] + zm1[3]*zm2[0];
			z_parts[4] <= zm1[0]*zm2[4] + zm1[1]*zm2[3] + zm1[2]*zm2[2] + zm1[3]*zm2[1] + zm1[4]*zm2[0];
			z_parts[5] <= zm1[0]*zm2[5] + zm1[1]*zm2[4] + zm1[2]*zm2[3] + zm1[3]*zm2[2] + zm1[4]*zm2[1] + zm1[5]*zm2[0];
			z_parts[6] <= zm1[0]*zm2[6] + zm1[1]*zm2[5] + zm1[2]*zm2[4] + zm1[3]*zm2[3] + zm1[4]*zm2[2] + zm1[5]*zm2[1] + zm1[6]*zm2[0];
			z_parts[7] <= zm1[0]*zm2[7] + zm1[1]*zm2[6] + zm1[2]*zm2[5] + zm1[3]*zm2[4] + zm1[4]*zm2[3] + zm1[5]*zm2[2] + zm1[6]*zm2[1] + zm1[7]*zm2[0];
			z_parts[8] <= zm1[0]*zm2[8] + zm1[1]*zm2[7] + zm1[2]*zm2[6] + zm1[3]*zm2[5] + zm1[4]*zm2[4] + zm1[5]*zm2[3] + zm1[6]*zm2[2] + zm1[7]*zm2[1] + zm1[8]*zm2[0];
			z_parts[9] <= zm1[0]*zm2[9] + zm1[1]*zm2[8] + zm1[2]*zm2[7] + zm1[3]*zm2[6] + zm1[4]*zm2[5] + zm1[5]*zm2[4] + zm1[6]*zm2[3] + zm1[7]*zm2[2] + zm1[8]*zm2[1] + zm1[9]*zm2[0];
			// $strobe("[galois_mult_barrett_v2.v] z<partial>=%h", z_short[N_BITS:0]);
			// $strobe("[galois_mult_barrett_v2.v] x1=%h", x1);
			// $strobe("[galois_mult_barrett_v2.v] x2=%h", x2);
			// $strobe("[galois_mult_barrett_v2.v] x3=%h", x3);
		end
	endcase
end

assign x1 = w[N_BITS:0] - z_short[N_BITS:0];
assign x2 = (x1 >= {1'b0, PRIME_MODULUS}) ? x1 - {1'b0, PRIME_MODULUS} : x1;
assign x3 = (x2 >= {1'b0, PRIME_MODULUS}) ? x2 - {1'b0, PRIME_MODULUS} : x2;
assign product = x3[N_BITS-1:0];

endmodule
