function cN2E=latlonaz2dcmn2e( latlon_ad, azimuth_ar)
% cN2E=latlonaz2dcmn2e( latlon_ad, azimuth_ar)
% SA eq 4.4.2.1-2 pg 4-29 (modified)
%  NOTE: original eq. is for Savage's ECEF convention. see dcmecef_savage2std for explanation

%#eml


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


l=deg2rad( latlon_ad(1) );
L=deg2rad( latlon_ad(2) );
a=azimuth_ar;

cN2E = [ 
    -sin(L)*cos(a)-cos(L)*sin(l)*sin(a),    sin(L)*sin(a)-cos(L)*sin(l)*cos(a),     cos(L)*cos(l)
    cos(L)*cos(a)-sin(L)*sin(l)*sin(a),     -cos(L)*sin(a)-sin(L)*sin(l)*cos(a),    sin(L)*cos(l)
    cos(l)*sin(a),                          cos(l)*cos(a),                          sin(l)
    ];
