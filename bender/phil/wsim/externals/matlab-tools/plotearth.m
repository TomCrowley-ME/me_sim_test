function plotearth( varargin )
% plotearth

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

bNoFill=0;
if nargin>0
    bNoFill = varargin{1};
end
r=6378e3;
%t=0:360;
%plot(r*cos(t*pi/180),r*sin(t*pi/180),'k-');
h=rectangle('Position',[-r -r 2*r 2*r],'Curvature',[1 1]);

if ~bNoFill
    set(h,'FaceColor','cyan','EdgeColor','cyan');
end


