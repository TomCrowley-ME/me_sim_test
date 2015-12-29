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
% quat_propagate.m                                                        %
%                                                                         %
% Scalar part last quaternion quaternion closed-form propagator           %
% Assume constant angular velocity during delta-T                         %
%                                                                         %
% Input: q0 (starting quaternion) 
%        rate (constant angular rate, body frame) 
%        deltaT (duration of propagation)
% Output: qT                      
%                                                                         %
% 08/22/13                                                                %
%-------------------------------------------------------------------------%


function [ qT ] = quat_propagate( q0, rate, deltaT )

% turn rate into row vector
if size(rate,1) == 3 && numel(rate) == 3
    rate = rate';
end

% turn quat into row vector
if size(q0,1) == 4 && numel(q0) == 4
    q0 = q0';
end

omega_mag = norm(rate);

if omega_mag > 0
    
    omega_matrix = [ -h_cross(rate)    rate' ;
                     -rate             0     ];
    
    update_mat = eye(4)*cos(0.5*omega_mag*deltaT) + (1/omega_mag)*omega_matrix*sin(0.5*omega_mag*deltaT);
    qT = (update_mat * q0')';
    
else
    qT = q0;
end


function out=h_cross(in)

out=[  0      -in(3)   in(2);
       in(3)   0      -in(1);
      -in(2)   in(1)   0    ];