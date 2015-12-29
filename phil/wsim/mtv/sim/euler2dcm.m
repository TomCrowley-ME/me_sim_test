%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2010 - 2015 Moon Express, Inc.
% All Rights Reserved.
%
% PROPRIETARY DATA NOTICE:
% The data herein include Proprietary Data and are restricted under the
% Data Rights provisions of Lunar CATALYST Space Act Agreement
% No. SAAM ID# 18251 and Reimbursable Space Act Agreement No.SAA2-402930.
% All information contained herein is and remains proprietary to and the
% property of Moon Express, Inc. Dissemination of this information or
% reproduction of this material is strictly forbidden unless prior
% written permission is obtained from Moon Express, Inc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function T=euler2dcm(order,p1,p2,p3)
% EA2DC	calculates the direction cosine matrix using specified Euler Angles
%		1=phi 2=theta 3=psi (deg)
%
%  INPUTS:
%	order	- rotation order
%	p1	- x-axis rotation angle (deg)
%	p2	- y-axis rotation angle (deg)
%	p3	- z-axis rotation angle (deg)
%
%  OUTPUTS:	
%	T	- direction cosine matrix from body to inertial frame

if nargin==2,p3=p1(3);p2=p1(2);p1=p1(1);end

c1=cosd(p1); s1=sind(p1);
c2=cosd(p2); s2=sind(p2);
c3=cosd(p3); s3=sind(p3);

if order==312
  T=[ c3*c1-s1*s2*s3   c3*s1+s3*s2*c1  -s3*c2;
              -c2*s1            c2*c1      s2;
      s3*c1+c3*s2*s1   s3*s1-c3*s2*c1   c3*c2];
elseif order==321
  T=[           c2*c1            c2*s1    -s2;
      -c3*s1+s3*s2*c1   c3*c1+s3*s2*s1  s3*c2;
       s3*s1+c3*s2*c1  -s3*c1+c3*s2*s1  c3*c2];
elseif order==123
  T=[ c3*c2   c3*s2*s1+s3*c1  -c3*s2*c1+s3*s1;
     -s3*c2  -s3*s2*s1+c3*c1   s3*s2*c1+c3*s1;
         s2           -c2*s1            c2*c1];
elseif order==132
  T=[ c3*c2   c3*s2*c1+s3*s1   c3*s2*s1-s3*c1;
        -s2            c2*c1            c2*s1;
      s3*c2   s3*s2*c1-c3*s1   s3*s2*s1+c3*c1];
elseif order==313
  T=[  c3*c1-s3*c2*s1   c3*s1+s3*c2*c1  s3*s2;
      -s3*s1-c3*c2*s1  -s3*s1+c3*c2*c1  c3*s2;
                s2*s1           -s2*c1     c2];
else
  fprintf('%s rotation not supported',order)
end
