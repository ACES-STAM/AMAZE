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


logic [253:0] test_in_left        = 'h0b0ed2a88bbc21ff8df7d33b19b35cee28393c5602b7728bf2b1e12b3201112f;
logic [253:0] test_in_right       = 'h11644e720131a029085045b60181585d07816a910871ca8d0c208c16087cfd46;
logic [253:0] test_round_constant = 'h1e1289b8eff2d431b178bc957cc0c41a1d7237057b9256fd090eb3c6366b9ef5;
logic [253:0] test_key            = 'h265484d5f60a98a1cfd2204308bbcace7939ca61b161a7c3ab5f6495d908c558;
logic         test_is_last_round  = 'b0;
logic [253:0] test_out_left       = 'h1262ca491a251fd4e35f734ec765209d50b66c3fb292c8942e18434e9a6d8204;
logic [253:0] test_out_right      = 'h0b0ed2a88bbc21ff8df7d33b19b35cee28393c5602b7728bf2b1e12b3201112f;
