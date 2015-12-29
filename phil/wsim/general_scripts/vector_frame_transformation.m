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
% Vectorized vector frame transformation                                  %
%                                                                         %
% Input: v (row vector) 
%        q (row vector)                 
% Output: w in frame q                      
%                                                                         %
% 03/19/14                                                                %
%-------------------------------------------------------------------------%


function [ vA ] = vector_frame_transformation( vB_in, q_A2B_in)

ts_out = 0;

if isa(vB_in,'timeseries')
    ts_out = 1;
    vB = vB_in.Data;
else
    vB = vB_in;
end
    
if isa(q_A2B_in,'timeseries')
    ts_out = 1;
    q_A2B = q_A2B_in.Data;
else
    q_A2B = q_A2B_in;
end
    
q = quat_inv( q_A2B );
    
% compute components of new vector 

    a1 = repmat( 2 * dot( vB, q(:,1:3), 2), 1, 3) .* q(:,1:3);
    
    a2 = repmat(2 * q(:,4), 1, 3) .* cross( q(:,1:3), vB, 2);
    
    a3 = repmat( (2 * q(:,4).*q(:,4) - 1), 1,  3 ) .* vB;
    
    vA = a1 + a2 + a3;
    
    
 if ts_out   
    vA = timeseries(vA, vB_in.Time, 'name',['transformed_' vB_in.Name]);
 end
    