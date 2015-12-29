function adot=angvel2eulerrate_zyx(azyx,w)

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

if size(azyx,1)~=3 || size(w,1)~=3
    error('series must be across last index')
end

adot=zeros(3,size(azyx,2));
for i=1:size(azyx,2)
    % wie pg 325. beware that a comes in z,y,x so must be flipped (theta1=x=a(3))
    c1=cos(azyx(3,i));c2=cos(azyx(2,i));
    s1=sin(azyx(3,i));s2=sin(azyx(2,i));

    adot([3 2 1],i)=1/c2*[c2 s1*s2 c1*s2; 0 c1*c2 -s1*c2; 0 s1 c1]*w(:,i);
end
