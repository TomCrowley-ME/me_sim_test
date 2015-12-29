function [ned_wnrps, Ce2n, rgm]=ecefvelpos2nedrates( rem, rel_vemps )

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


% based on simulink block inside of 6DOF ECEF block, calculates ned rates
%  from lat,h and relative velocity

% WGS84 Earth
R=6378137; % equatorial radius, wgs84
F=1/298.257223563; % earth flattening, wgs84

units=initUnits;

% get LLA then NED wrt ECEF frame from LLA
rgm=ecef2lla( rem );
Ce2n=dcmecef2ned( rgm(1), rgm(2) );

rel_vnmps = Ce2n*rel_vemps(:);
vnorth=rel_vnmps(1);
veast=rel_vnmps(2);

lat_ar=rgm(1) * units.degrees;
h_sm=rgm(3);

e2=1-(1-F)^2;
den = 1-sin(lat_ar)^2*e2;

w1=veast / ( h_sm + R/sqrt(den));
w2=vnorth / ( h_sm + R*(1-e2) / sqrt( den^3 ) );
w3=tan( lat_ar ) * w1;

ned_wnrps=[ w1 -w2 -w3];
