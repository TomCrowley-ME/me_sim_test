function [o2p_r, a2p_v, a2p_a] = transport( q2p_r, b2p_v, b2p_a,   a2b_w, a2b_dw,   o2q_r, a2q_v, a2q_a )

% (Source published under the MIT License, see readme.txt for rationale)
% 
% Copyright (c) 2011 Ian M. Garcia
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.
% 
% (http://www.opensource.org/licenses/mit-license.php)

%#eml

% everything in A frame
% r_P/O = r_Q/O + r_P/Q
% v_P/a = v_Q/a + v_P/b + w_b/a x r_P/Q
% a_P/a = a_P/b + a_Q/a + alpha_b/a x r_P/Q + w_b/ax(w_b/axr_P/Q) + 2 w_b/a x v_p/b
o2p_r = o2q_r + q2p_r;
a2p_v = a2q_v + b2p_v + cross( a2b_w, q2p_r );
a2p_a = b2p_a + a2q_a + cross( a2b_dw, q2p_r ) + cross( a2b_w, cross( a2b_w, q2p_r ) ) + 2 * cross( a2b_w, b2p_v );


