function C=rotvec2dcm_approx( v )

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

vmag = norm3( v );


EPS=1e-36; % eps(1e-20)

if vmag < EPS
    C=eye(3);
else
    v_x=Xross( v );
    %C=eye(3) - sin(vmag)/vmag*v_x + (1-cos(vmag))/vmag^2 *v_x*v_x;
    if vmag < 1e-3
        % approximation SA 7.1.1.2-3 pg 7-16
        sin_factor = 1-vmag^2/6 + vmag^4/120;
        cos_factor = 1/2-vmag^2/24 + vmag^4/720;
    else
        sin_factor = sin(vmag)/vmag;
        cos_factor = (1-cos(vmag))/vmag^2;
    end
    C=eye(3) - sin_factor * v_x + cos_factor * v_x*v_x;
end
