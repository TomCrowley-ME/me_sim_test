function dv=symdiffcols( v )

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

% midpoint differenciation across cols
dv=zeros( size(v) );
n=size(dv,1);
dv(2:n-1,:)=.5*(v(3:n,:)-v(1:n-2,:));
dv(1,:)=v(2,:)-v(1,:);
dvhalf=( v(end,:)-v(end-1,:) );
dv(end,:)=dvhalf;% -dv2half ;%+1/2*dv2half;
% 
% % find f=a+bt+ct^2, f'(t)=b+ct
% b=.5*( -v(end,:)+4*v(end-1,:)-3*v(end-2,:) );
% c=.5*( v(end,:)-2*v(end-1,:)+v(end-2,:) );
% dv(end,:)=b+2*c;

%dv2half=(dvhalf-dv(end-1,:))*.5
%dv(end-1)+ 1/2*(dv(end-1)-dv(end-2));
%( v(end,:)-v(end-1,:) );% *1/3 +dv(end-1,:) *2/3;

