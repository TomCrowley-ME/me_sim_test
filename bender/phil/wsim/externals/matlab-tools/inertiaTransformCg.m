function I = inertiaTransformCg( cm_iSkgm2, mkg,  cm_rSm, cS2B,  varargin )
% transform inertia matrix around center of mass in frame S to B
%  use option ..., 'Flip',1,... to do flip transform from B frame INTO cm-centered

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

flip_b = optFill( varargin, 'Flip', 0 );

kflip = 1;
if flip_b
    kflip = -1;
end

% alias s_rBm,iS and iB for ease
x = cm_rSm(1);y= cm_rSm(2);z= cm_rSm(3);
I = zeros(3,3);

% Iprime = rotate from S to B
% then translate
Ip = cS2B * cm_iSkgm2 * cS2B';

I(1,1) = Ip(1,1) + kflip* mkg * (y^2+z^2);
I(2,2) = Ip(2,2) + kflip* mkg * (x^2+z^2);
I(3,3) = Ip(3,3) + kflip* mkg * (x^2+y^2);
I(1,2) = Ip(1,2) - kflip* mkg * x*y;
I(1,3) = Ip(1,3) - kflip* mkg * x*z;
I(2,3) = Ip(2,3) - kflip* mkg * y*z;
I(2,1) = I(1,2);
I(3,1) = I(1,3);
I(3,2) = I(2,3);

