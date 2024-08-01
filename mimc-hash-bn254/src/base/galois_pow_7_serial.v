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


// Module that performs exponentiation to the power of 7, on an element in Galois Field with Prime order.

// Refer to file `galois_mult.v` for explanation of parameter `GALOIS_MULT_METHOD`.

module galois_pow_7_serial #(
	parameter N_BITS = 254,
	parameter GALOIS_MULT_METHOD = "peasant"
) (
	input clk,
	input rst,
	input en,
	input  [N_BITS-1:0] base,
	output [N_BITS-1:0] result,
	output reg done
);

// LOCAL PARAMETERS

// States of the state machine
localparam INIT = 4'd0;
localparam COMPUTE_1A = 4'd1;
localparam COMPUTE_1B = 4'd2;
localparam COMPUTE_1C = 4'd3;
localparam COMPUTE_2A = 4'd4;
localparam COMPUTE_2B = 4'd5;
localparam COMPUTE_2C = 4'd6;
localparam COMPUTE_3A = 4'd7;
localparam COMPUTE_3B = 4'd8;
localparam COMPUTE_3C = 4'd9;
localparam COMPUTE_4A = 4'd10;
localparam COMPUTE_4B = 4'd11;
localparam COMPUTE_4C = 4'd12;
localparam FINISH = 4'd15;

// REGS AND WIRES DECLARATIONS

// State machine registers
reg [3:0] state, next_state;

// Regs that store operands, intermediate results and final result
reg [N_BITS-1:0] base_pow_2;
reg [N_BITS-1:0] base_pow_3;
reg [N_BITS-1:0] base_pow_5;
reg [N_BITS-1:0] base_pow_7;
reg mult_rst;
reg mult_en;
reg [N_BITS-1:0] mult_num1;
reg [N_BITS-1:0] mult_num2;

// Wires used in calculations
wire mult_done;
wire [N_BITS-1:0] mult_product;

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
			next_state <= (en) ? COMPUTE_1A : state;
		COMPUTE_1A:
			next_state <= COMPUTE_1B;
		COMPUTE_1B:
			next_state <= (mult_done) ? COMPUTE_1C : state;
		COMPUTE_1C:
			next_state <= COMPUTE_2A;
		COMPUTE_2A:
			next_state <= COMPUTE_2B;
		COMPUTE_2B:
			next_state <= (mult_done) ? COMPUTE_2C : state;
		COMPUTE_2C:
			next_state <= COMPUTE_3A;
		COMPUTE_3A:
			next_state <= COMPUTE_3B;
		COMPUTE_3B:
			next_state <= (mult_done) ? COMPUTE_3C : state;
		COMPUTE_3C:
			next_state <= COMPUTE_4A;
		COMPUTE_4A:
			next_state <= COMPUTE_4B;
		COMPUTE_4B:
			next_state <= (mult_done) ? COMPUTE_4C : state;
		COMPUTE_4C:
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
			mult_en <=  1'b1;
			mult_rst <= 1'b1;
		end
		FINISH: begin
			done <= 1'b1;
		end
		COMPUTE_1A: begin
			mult_num1 <= base;
			mult_num2 <= base;
		end
		COMPUTE_1B: begin
			mult_rst <= 1'b0;
		end
		COMPUTE_1C: begin
			base_pow_2 <= mult_product;
			mult_rst <= 1'b1;
			// $strobe("[galois_pow_7_serial.v] base_pow_2=%h", base_pow_2);
		end
		COMPUTE_2A: begin
			mult_num1 <= base_pow_2;
			mult_num2 <= base;
		end
		COMPUTE_2B: begin
			mult_rst <= 1'b0;
		end
		COMPUTE_2C: begin
			base_pow_3 <= mult_product;
			mult_rst <= 1'b1;
			// $strobe("[galois_pow_7_serial.v] base_pow_3=%h", base_pow_3);
		end
		COMPUTE_3A: begin
			mult_num1 <= base_pow_3;
			mult_num2 <= base_pow_2;
		end
		COMPUTE_3B: begin
			mult_rst <= 1'b0;
		end
		COMPUTE_3C: begin
			base_pow_5 <= mult_product;
			mult_rst <= 1'b1;
			// $strobe("[galois_pow_7_serial.v] base_pow_5=%h", base_pow_5);
		end
		COMPUTE_4A: begin
			mult_num1 <= base_pow_5;
			mult_num2 <= base_pow_2;
		end
		COMPUTE_4B: begin
			mult_rst <= 1'b0;
		end
		COMPUTE_4C: begin
			base_pow_7 <= mult_product;
			mult_rst <= 1'b1;
			// $strobe("[galois_pow_7_serial.v] base_pow_7=%h", base_pow_7);
		end
	endcase
end

// Output result assignment
assign result = base_pow_7;

galois_mult #(
	.N_BITS(N_BITS),
	.GALOIS_MULT_METHOD(GALOIS_MULT_METHOD)
) GALOIS_MULT (
	.clk(clk),
	.rst(mult_rst),
	.en(mult_en),
	.num1(mult_num1),
	.num2(mult_num2),
	.product(mult_product),
	.done(mult_done)
);

endmodule
