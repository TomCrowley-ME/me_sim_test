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

function output = buildParallelAxisMatrix( input )
%% FUNCTION buildParallelAxisMatrix
%
%   parallelAxisMatrix = buildParallelAxisMatrix( d )
%
% INPUTS
%   d                    [1x3]   vector from old location to new
%
% OUTPUTS
%   parallelAxisMatrix   [3x3]   matrix used to transfer inertia matrix
%                                with respect from old location to new
%                                in parallel axis theorem calculations
%
%                                I_new + I_old + mass * parallelAxisMatrix 
%
%    = [ d(2)*d(2)+d(3)*d(3)  -d(1)*d(2)            -d(1)*d(3);
%       -d(2)*d(1)             d(1)*d(1)+d(3)*d(3)  -d(2)*d(3);
%       -d(3)*d(1)            -d(3)*d(2)             d(1)*d(1)+d(2)*d(2)]
%
output(1,1) =  input(2)*input(2)+input(3)*input(3);
output(1,2) = -input(1)*input(2);
output(1,3) = -input(1)*input(3);
output(2,1) = -input(2)*input(1);
output(2,2) =  input(1)*input(1)+input(3)*input(3);
output(2,3) = -input(2)*input(3);
output(3,1) = -input(3)*input(1);
output(3,2) = -input(3)*input(2);
output(3,3) =  input(1)*input(1)+input(2)*input(2);
