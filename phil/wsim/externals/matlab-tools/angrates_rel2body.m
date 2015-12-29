function body_wbrps=angrates_rel2body( rel_wbrps, rem, rel_vemps,  Ci2b, Ce2i )
% get total angular rates in body frame from relative and ECEF position, velocity and orientation

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


earth_werps=[0 0 7.292115e-5];

rgm=ecef2lla( rem );
Ce2n=dcmecef2ned( rgm(1), rgm(2) );
Ce2b = Ci2b * Ce2i;

ned_wnrps=ecefvelpos2nedrates( rem, rel_vemps );
ned_wbrps= Ce2b * Ce2n' * ned_wnrps(:);

earth_wbrps = Ce2b * earth_werps(:);

body_wbrps = rel_wbrps + earth_wbrps' + ned_wbrps';

