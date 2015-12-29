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

function inertia_vector = buildInertiaVector( input, option)
%% FUNCTION buildInertiaVector
%
%   inertia_vector = buildInertiaVector( input, options )
%
% INPUTS
%   inertia_matrix  [nxn]
%
% OUTPUTS
%   inertia_vector  [1x4]    [ Ixx Iyy Ixy Iyx ]
%       or
%   inertia_vector  [1x6]    [ Ixx Iyy Izz Ixy Ixz Iyz ]
%
% OPTIONS
%    'diag'        [string]  returns zero for all POIs
%

inertia_vector(1) = input(1,1);
inertia_vector(2) = input(2,2);

if (size(input,1)==2)&&(size(input,2)==2)
  if nargin==2
     if strcmpi(option,'diag')
       inertia_vector(3) = 0.0;
       inertia_vector(4) = 0.0;
     end
  else
    inertia_vector(3) = input(1,2);
    inertia_vector(4) = input(2,1);
  end
  
elseif (size(input,1)==3)&&(size(input,2)==3)
  inertia_vector(3) =  input(3,3);
  if nargin==2
     if strcmpi(option,'diag')
       inertia_vector(4) = 0.0;
       inertia_vector(5) = 0.0;
       inertia_vector(6) = 0.0;
     end
  else
    inertia_vector(4) = -input(1,2);
    inertia_vector(5) = -input(1,3);
    inertia_vector(6) = -input(2,3);
  end
end
