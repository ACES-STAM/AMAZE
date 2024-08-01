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

module galois_mult_barrett #(
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
reg [2*(N_BITS+1)-1:0] y;
reg [(2*N_BITS)-1:0] z;

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
			// $strobe("[galois_mult_barrett.v] w=%h", w);
		end
		COMPUTE_2: begin
			y <= w[2*N_BITS-1:N_BITS-1] * R;
			// $strobe("[galois_mult_barrett.v] y=%h", y);
		end
		COMPUTE_3: begin
			z <= y[2*N_BITS:N_BITS+1] * PRIME_MODULUS;
			// $strobe("[galois_mult_barrett.v] z=%h", z);
			// $strobe("[galois_mult_barrett.v] x1=%h", x1);
			// $strobe("[galois_mult_barrett.v] x2=%h", x2);
			// $strobe("[galois_mult_barrett.v] x3=%h", x3);
			// $strobe("[galois_mult_barrett.v] result=%h", result);
		end
	endcase
end

assign x1 = w[N_BITS:0] - z[N_BITS:0];
assign x2 = (x1 >= {1'b0, PRIME_MODULUS}) ? x1 - {1'b0, PRIME_MODULUS} : x1;
assign x3 = (x2 >= {1'b0, PRIME_MODULUS}) ? x2 - {1'b0, PRIME_MODULUS} : x2;
assign product = x3[N_BITS-1:0];

endmodule
