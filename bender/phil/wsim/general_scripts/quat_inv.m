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


function [ qinv ] = quat_inv( q )

if isa(q,'timeseries')

    if ~isempty(q.Data)
        temp = [ -q.Data(:,1:3) q.Data(:,4) ];
        qinv = timeseries(temp, q.Time, 'name',['inv_' q.Name]);
    else
        qinv = q;
    end
    
else

    if ~isempty(q)
        qinv = [ -q(:,1:3) q(:,4) ];
    else
        qinv = q;
    end
    
end

