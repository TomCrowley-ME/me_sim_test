function [t,y]=stepifyTimeSequence(tIn,yIn,varargin)

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


flip=0;
dt = optFill(varargin,'Dt',.001);
if length(tIn)==size(yIn,2)
    flip=1;
    yIn=yIn';
end
tIn=tIn(:);
t=zeros(length(tIn)*2-1,1);
y=zeros(length(tIn)*2-1,size(yIn,2));
% copy original to even places
t(1:2:end)=tIn;
y(1:2:end,:)=yIn;
% duplicate original to following odd places
y(2:2:end,:)=yIn(1:end-1,:);
% yin=[1 2 3]-> y=[1 2 2 3 3]
% duplicate time minus dt (say, .01)
% tin=[1 3 7] -> t =[1 2.99 3 6.99 7
t(2:2:end)=tIn(2:end)-dt;
if flip
    t=t';
    y=y';
end
