%#eml
function Ca2b=eigenaxis2dcm( e, theta_a2b )
% Eigenaxis rotation to direction cosine matrix
% Rotates frame a by THETA around E such that CA2B will transform a vector
%  in frame A to its representation in frame B
%
% Eq. 5.22 Wie pg 315

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


e=vec2unit_emb(e);
ca=cos( theta_a2b );
sa=sin( theta_a2b );
Ca2b = [ca + e(1)^2*(1-ca),        e(1)*e(2)*(1-ca)+e(3)*sa,   e(1)*e(3)*(1-ca)-e(2)*sa;
    e(2)*e(1)*(1-ca)-e(3)*sa,   ca+e(2)^2*(1-ca),           e(2)*e(3)*(1-ca)+e(1)*sa;
    e(3)*e(1)*(1-ca)+e(2)*sa,   e(3)*e(2)*(1-ca)-e(1)*sa,   ca+e(3)^2*(1-ca)];
