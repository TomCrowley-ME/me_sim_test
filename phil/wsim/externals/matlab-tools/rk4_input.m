function yout = rk4_input( y, derivf, dydt_t, u_th, u_tt, t, h )
% rk4 runge-kutta 4 for integration, with input
%
% Limitations:
%  use as sample. due to dynamic input size, cannot be used for embedded matlab

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

hh = .5 * h;
th = t + hh;

% First step
yt = y + hh * dydt_t;
% Second step
dyt = derivf( th, yt, u_th );
yt = y + hh * dyt;
% Third step
dym = derivf( th, yt, u_th );

yt = y + h*dym;
dym = dym + dyt;
% Fourth step
dyt = derivf( t+h, yt, u_tt );

yout = y + h/6.0*(dydt_t + dyt + 2.0*dym );
