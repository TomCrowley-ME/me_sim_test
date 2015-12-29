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

function Inertia = inertiaStruc2Matrix( MP )
%% FUNCTION struc2InertiaMatrix
%
%   Inertia = struc2InertiaMatrix( MP )
%
% INPUTS
%   MP     {struct}    Structure with individual inertia data
%    .Ixx   [1x1]
%    .Iyy   [1x1]
%    .Izz   [1x1]
%    .Ixy   [1x1]
%    .Ixz   [1x1]
%    .Iyz   [1x1]
%
% OUTPUTS
%   Inertia [3x3]       where
%       [   Ixx    -Ixy    -Ixz;
%          -Ixy     Iyy    -Iyz;
%          -Ixz    -Iyz     Izz ]

Inertia(1,1) = MP.Ixx;
Inertia(1,2) = -MP.Ixy;
Inertia(1,3) = -MP.Ixz;
Inertia(2,1) = -MP.Ixy;
Inertia(2,2) = MP.Iyy;
Inertia(2,3) = -MP.Iyz;
Inertia(3,1) = -MP.Ixz;
Inertia(3,2) = -MP.Iyz;
Inertia(3,3) = MP.Izz;
