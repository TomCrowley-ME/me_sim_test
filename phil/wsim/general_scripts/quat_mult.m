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

%-------------------------------------------------------------------------%
% quat_mult.m                                                             %
%                                                                         %
% Vectorized scalar part last quaternion quaternion multiplication        %
% Euler rotation sequence used in 'zyx'                                   %
%                                                                         %
% Input: p (row vector) 
%        q (row vector)                 
% Output: r = p x q                      
%                                                                         %
% 08/22/13                                                                %
%-------------------------------------------------------------------------%


function [ r ] = quat_mult( p_in , q_in)

ts = 0;

if isa(p_in,'timeseries')
    p = p_in.Data;
    
    ts = 1;
else
    p = p_in;
end

if isa(q_in,'timeseries')
    q = q_in.Data;
    
    ts = 1;
else
    q = q_in;
end



r(:,1) = p(:,1).*q(:,4) + p(:,4).*q(:,1) - p(:,3).*q(:,2) + p(:,2).*q(:,3);

r(:,2) = p(:,2).*q(:,4) + p(:,3).*q(:,1) + p(:,4).*q(:,2) - p(:,1).*q(:,3);

r(:,3) = p(:,3).*q(:,4) - p(:,2).*q(:,1) + p(:,1).*q(:,2) + p(:,4).*q(:,3);

r(:,4) = p(:,4).*q(:,4) - p(:,1).*q(:,1) - p(:,2).*q(:,2) - p(:,3).*q(:,3);

if ts
    r = timeseries(r, p_in.Time, 'name',[p_in.name '_mult_' q_in.Name]);
end
