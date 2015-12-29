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

function [ q_j2000_to_mcmf ] = quaternion_inertial_to_earthfixed(seconds)


xjdate = (seconds/86400)+2451545;
d = xjdate - 2451545;
t = d/36525;

ut_hours = mod(seconds - 43200, 86400)/3600;
hours_term = (seconds/86400-ut_hours/24)/36525;
X = 6.697374558 + (2400.051336*hours_term)+(hours_term*hours_term*0.000025862)+(1.0027379093*(ut_hours+(d*86400-seconds)/3600));

GMST = mod(X,24);

d_no_hours = t*36525-(ut_hours/24);

delta_psi = -0.000319 * sin((125.04-(0.052954*d_no_hours))*pi/180) + ...
            -0.000024 * sin((280.47+(0.98565*d_no_hours))*2*pi/180);


eqeq = cos((23.4393-(0.0000004*d_no_hours))*pi/180)*delta_psi;
        
GAST = (GMST+eqeq)*(360/24*pi/180);

tmatrix(1,1) =  cos(GAST);
tmatrix(2,1) = -sin(GAST);
tmatrix(3,1) =  0;

tmatrix(1,2) =  sin(GAST);
tmatrix(2,2) =  cos(GAST);
tmatrix(3,2) =  0;

tmatrix(1,3) =  0;
tmatrix(2,3) =  0;
tmatrix(3,3) =  1;

q_j2000_to_mcmf = dcm_to_quat(tmatrix);

end
