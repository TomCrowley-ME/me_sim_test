function [t,y]=ode_rk4_input( derivfu, tspan, y0, u )
% for testing rk4_input

% (Source published under the MIT License, see readme.txt for rationale and license text at the end )

iu = 1:2:length(tspan);

t=tspan( iu );
y=zeros( length(y0),length(t) );

y(:,1)=y0;
for ii = 1:length(iu)-1
    % skip 2, so that mid is valid
    y( :,ii+1 ) = rk4_input( y(:,ii), derivfu, derivfu( t(ii),y(:,ii),u(:,iu(ii) ) ), u(:,iu(ii)+1),u(:,iu(ii)+2), t(ii), t(ii+1)-t(ii) );
end

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
