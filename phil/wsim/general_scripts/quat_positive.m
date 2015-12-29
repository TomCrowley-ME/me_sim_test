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
% quat_inv.m                                                              %
%                                                                         %
% Vectorized scalar part last quaternion quaternion ineverse / conjugate  %
% Euler rotation sequence used in 'zyx'                                   %
%                                                                         %
% Input: q (row vector) 
% Output: qinv = q ^ -1                      
%                                                                         %
% 08/22/13                                                                %
%-------------------------------------------------------------------------%


function [ q_pos ] = quat_positive( q )

if isa(q,'timeseries')

    temp = repmat( sign(q.Data(:,4)), 1, 4) .* q.Data ;
    q_pos = timeseries(temp, q.Time, 'name',['[pos_' q.Name]);
    
else

    q_pos = repmat( sign(q(:,4)), 1, 4) .* q ;
    
end

