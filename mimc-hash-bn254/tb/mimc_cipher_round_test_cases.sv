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


logic [253:0] test1_in             = 'h0b0ed2a88bbc21ff8df7d33b19b35cee28393c5602b7728bf2b1e12b3201112f;
logic [253:0] test1_round_constant = 'h1e1289b8eff2d431b178bc957cc0c41a1d7237057b9256fd090eb3c6366b9ef5;
logic [253:0] test1_key            = 'h265484d5f60a98a1cfd2204308bbcace7939ca61b161a7c3ab5f6495d908c558;
logic [253:0] test1_out            = 'h2b160e5e137b9db94a5a0659f32da4d1d626ac1b1884d99d612e887945c5d342;

logic [253:0] test2_in             = 'h30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000000;
logic [253:0] test2_round_constant = 'h2e2ebbb178296b63d88ec198f0976ad98bc1d4eb0d921ddd2eb86cb7e70a98e5;
logic [253:0] test2_key            = 'h1673ba20119a2723e5ecec15c2c6c50e57e536e2876765120959f47e2183795b;
logic [253:0] test2_out            = 'h0b97638fe5782ee534f5a90a6fcb0d5fcc53cba3a18e2f56b4ba5da3283ba28d;

logic [253:0] test3_in             = 'h2733f33ee65784ef44e48ccad6a2d83154c79ec8eda733dd22f89e0d9db0277e;
logic [253:0] test3_round_constant = 'h2ee5427bd20c47f8d2f0aa9e6419f7926abcd5965084292ae54dd780077e6902;
logic [253:0] test3_key            = 'h2646854c6b1a5bd1d06acd6b7907acb8adfc0d12e8bc114fb1a7de8ed4f2e326;
logic [253:0] test3_out            = 'h1e75b7005a1a8235999c0376eb0dbd67d6e93305436fbf72d7888b10d786d955;
