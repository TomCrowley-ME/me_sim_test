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

function Inertia = buildInertiaMatrix( input)
%% FUNCTION buildInertiaMatrix
%
%   Inertia = buildInertiaMatrix( inertia_vector )
%
% INPUTS
%   input_vector  [1x6]   Array with individual inertia data
%
% OUTPUTS
%   Inertia       [3x3]   where
%       [  input(1) -input(4) -input(5);
%         -input(4)  input(2) -input(6);
%         -input(5  -input(6)  input(3) ]

Inertia(1,1) = input(1);
Inertia(2,2) = input(2);
Inertia(3,3) = input(3);

if length(input)>3
  Inertia(1,2) = -input(4);
  Inertia(1,3) = -input(5);
  Inertia(2,1) = -input(4);
  Inertia(2,3) = -input(6);
  Inertia(3,1) = -input(5);
  Inertia(3,2) = -input(6);
else
  Inertia(1,2) = 0.0;
  Inertia(1,3) = 0.0;
  Inertia(2,1) = 0.0;
  Inertia(2,3) = 0.0;
  Inertia(3,1) = 0.0;
  Inertia(3,2) = 0.0;    
end
