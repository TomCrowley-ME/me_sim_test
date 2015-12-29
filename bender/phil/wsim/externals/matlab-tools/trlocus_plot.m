function [r0,rz,rk]=trlocus_plot(num,den,varargin)

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

v=optFill(varargin,'Axis',[-10 10 -10 10]);
Kmark=optFill(varargin,'K',[]);
% st up k vector of gains
k=optFill(varargin,'k',[0 logspace(-1,10,1e3)]);

% check whether is tf type and extract if it is
if isa(num,'tf')
    t=get(num,'den');
    den=t{1};
    t=get(num,'num');
    num=t{1};
end

% compute roots at each gain
r=rlocus(num,den,k);
% set up axis limits, then
% ste up and plot real and imaginary axis
%v=[-9 1 -5 5];

plot(v(1:2)+[-5 5],[0 0],'c--',[0 0],v(3:4)+[-5 5],'c--');
axis(v);
hold on; grid on;
% plot points, no tlines
% program doesn't know how to associate poles as k changes
% plot program plots each point in the matrix a complex numbre
if size(r,2)<2
    plot(r,0,'b.');
else
    plot( r,'b.');
end
xlabel('real'); ylabel('imaginary');
%place hold on to add open loop zeros and ploes
hold on
% find open loop poles, then find real and imag part of ples, and plot
r0=roots( den );
x=real( r0 );
y=imag( r0 );
plot(x,y,'mx');
% now plot open loop zeros
rz = roots( num );
if ~isempty( rz )
    x=real(rz);
    y=imag(rz);
    plot(x,y,'mo');
end
rk=[];
if ~isempty( Kmark )
    % retrieve roots when k=48 from r and plot with starts
    ik=find(k>=Kmark,1,'first');
    rk=r(ik,:);
    x=real(rk);
    y=imag(rk);
    plot(x,y,'k*');
    a=axis;
    a(3)=min([a(3),y]); a(4)=max([a(4),y]);
    %axis equal
    ylim(a(3:4));
end
hold off


