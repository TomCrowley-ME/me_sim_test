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

function components_error_deg = components_error_from_quat(q1,q2)

if isa(q1,'timeseries') && isa(q2,'timeseries')
    
    qE = quat_mult(q1.Data, quat_inv(q2.Data));
    qE = qE .* repmat( sign(qE(:,4)),1,4);
    euler_err_deg = quat2euler(qE)*180/pi;
    
    components_error_deg = timeseries(euler_err_deg, q1.Time, 'name',['components_error_deg_' q1.Name '_' q2.Name]);
    
else
    
    qE = quat_mult(q1, quat_inv(q2));
    qE = qE .* repmat( sign(qE(:,4)),1,4);
    euler_err_deg = quat2euler(qE)*180/pi;
    components_error_deg = euler_err_deg;
    
end