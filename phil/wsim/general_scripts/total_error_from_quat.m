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

function total_error_deg = total_error_from_quat(q1,q2)

if isa(q1,'timeseries') && isa(q2,'timeseries')
    
    qE = quat_mult(q1.Data, quat_inv(q2.Data));
    qE = qE .* repmat( sign(qE(:,4)),1,4);
    cos_argument = qE(:,4);
    cos_argument( cos_argument > +1 ) = +1;
    cos_argument( cos_argument < -1 ) = -1;
    temp = 2*acosd(cos_argument);
    
    total_error_deg = timeseries(temp, q1.Time, 'name',['total_error_deg_' q1.Name '_' q2.Name]);
    
else
    
    qE = quat_mult(q1, quat_inv(q2));
    qE = qE .* repmat( sign(qE(:,4)),1,4);
    cos_argument = qE(:,4);
    cos_argument( cos_argument > +1 ) = +1;
    cos_argument( cos_argument < -1 ) = -1;
    total_error_deg = 2*acosd(cos_argument);
    
end