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


// Module that performs multiplication between two elements in Galois Field with Prime order.
// Performs a large multiplication first and then performs a Barrett reduction.

// Pipelined design: supports multiple in-flight computations.
//     - Latency: 12 clock cycles (including the cycle in which inputs are injected).
//     - Pipeline length: 12 clock cycles.
//     - Accepts new request in every clock cycle.

// WARNING: Currently, only a field with N_BITS = 254 bits is supported.

// Barrett Reduction Algorithm: https://doi.org/10.1007/3-540-47721-7_24
//     (Refer to Diagram Five)

module galois_mult_barrett_sync_v2 #(
    parameter N_BITS = 254,
    parameter PRIME_MODULUS = 254'h30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000001, // Size: N_BITS
    parameter BARRETT_R = 255'h54a47462623a04a7ab074a58680730147144852009e880ae620703a6be1de925 // Size: N_BITS + 1
) (
    input clk,
    input  [N_BITS-1:0] num1,
    input  [N_BITS-1:0] num2,
    output [N_BITS-1:0] product
);

localparam MULT_LATENCY = 3+1; // Clock cylces

reg [N_BITS-1:0] result;
reg [256-1:0] mult_1_num1;
reg [256-1:0] mult_1_num2;
reg [256-1:0] mult_2_num1;
reg [256-1:0] mult_2_num2;
reg [256-1:0] mult_3_num1;
reg [256-1:0] mult_3_num2;
reg [N_BITS:0] w_saved [0:(2*MULT_LATENCY)-1];
reg [(2*N_BITS)-1:0] w;
reg [2*(N_BITS+1)-1:0] y;
reg [(2*N_BITS)-1:0] z;

wire [(N_BITS+1)-1:0] x;
wire signed [(N_BITS+1+1)-1:0] x1;
wire signed [(N_BITS+1+1)-1:0] x2;
wire [2*256-1:0] mult_1_product;
wire [2*256-1:0] mult_2_product;
wire [2*256-1:0] mult_3_product;

integer i;

// Operation logic
always @(posedge clk) begin
    mult_1_num1 <= {2'b0, num1};
    mult_1_num2 <= {2'b0, num2};

    w <= mult_1_product[2*N_BITS-1:0];

    w_saved[0] <= w[N_BITS:0];
    for (i = 1; i < 2*MULT_LATENCY; i = i + 1) begin
        w_saved[i] <= w_saved[i-1];
    end

    mult_2_num1 <= {1'b0, w[2*N_BITS-1:N_BITS-1]};
    mult_2_num2 <= {1'b0, BARRETT_R};

    y <= mult_2_product[2*(N_BITS+1)-1:0];

    mult_3_num1 <= {2'b0, y[2*N_BITS:N_BITS+1]};
    mult_3_num2 <= {2'b0, PRIME_MODULUS};

    z <= mult_3_product[2*N_BITS-1:0];
end

assign x = w_saved[(2*MULT_LATENCY)-1][(N_BITS+1)-1:0] - z[(N_BITS+1)-1:0];
assign x1 = x - PRIME_MODULUS;
assign x2 = x - 2*PRIME_MODULUS;
assign product = x2 >= 0 ? x2[N_BITS-1:0] : x1 >= 0 ? x1[N_BITS-1:0] : x[N_BITS-1:0];

mult_256_sync MULT_1 (
    .clk(clk),
    .num1(mult_1_num1),
    .num2(mult_1_num2),
    .product(mult_1_product)
);

mult_256_sync MULT_2 (
    .clk(clk),
    .num1(mult_2_num1),
    .num2(mult_2_num2),
    .product(mult_2_product)
);

mult_256_sync MULT_3 (
    .clk(clk),
    .num1(mult_3_num1),
    .num2(mult_3_num2),
    .product(mult_3_product)
);

endmodule
