function [gain,phase]=getgainphase(t,u,y)

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

dy=diff(y);
du=diff(u);
iu=find(du(1:end-1)<0&du((1:end-1)+1)>=0,2,'first');iu=iu(1):iu(2);
io=find(dy(1:end-1)<0&dy((1:end-1)+1)>=0,2,'first');io=io(1):io(2);

gain=(max(y(io))-min(y(io)))/(max(u(iu))-min(u(iu)));
w=2*pi/(t(iu(end))-t(iu(1)));

%phase=-( t(io)-t(iu(1)) )*w;
phase=-mod( ( t(io(1))-t(iu(1)) )*w, 2*pi);
