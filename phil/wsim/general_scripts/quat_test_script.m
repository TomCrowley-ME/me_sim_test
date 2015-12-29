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


% initialize quat
q(1,:) = [0 0 0 1];

% set up constant rate w/ random rates
rates = (1 * pi/180)*ones(360,3) + randn(360,3)*0.01;

% initialize metrics
qdiff(1,:) = quat_mult( quat_inv(q(1,:)), q(1,:) );
delta_theta_degree(1,:) = 2 * acosd( qdiff(1,4) ); 

for ii = 2 : 360
    
     q(ii,:)  = quat_propagate( q(ii-1,:), rates(ii,:), 1 );
     
     qdiff(ii,:) = quat_mult( quat_inv(q(ii,:)), q(1,:) );
     delta_theta_degree(ii,:) = 2 * acosd( qdiff(ii,4) ); 

end

figure; plot(q); title('integrated quaternion')
figure; plot(delta_theta_degree); title('total angle (degrees) from initial quaternion')

[ euler_xyz ] = quat2euler(q);

figure; plot(euler_xyz * 180/pi); title('Euler angles, 321 Parameterization')
legend('phi','theta','phi')