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

% Unit Test for Gravity Gradient
close all
clear all
grv_mu_moon = 4.902800076e12; %m/(kg*s^2);
central_body_radius = 1737e3; %(m)
% S/C inertia matrix
Ixx = 10;
Iyy = 10;
Izz = 10;
Ixy = 10; 
Ixz = 10;
Iyz = 10;

I_sc = [Ixx Ixy Ixz; ...
        Ixy Iyy Iyz; ...
        Ixz Iyz Izz];

% S/C to moon position vector (S/C Body vector)
% Altitude above Moon surface (m)
alt = 200e3;

pos_sc2moon_body = (central_body_radius + alt) * [1; 0.5; 0];

% Moon to S/C position vector (MCI J2000 Frame), unused
pos_m2sc_I = [1; 0; 0];

% Quaternion transforming body vector to MCI J2000 Frame, unused
q_body_from_mci = [1; 1; 0; 0];

sim('util_gravity_gradient_hrn');
figure
subplot(4,1,1)
plot(cross_x.Time, cross_x.Data);
grid on
legend('x','y','z');
title('cross x');

subplot(4,1,2)
plot(torque_x.Time, torque_x.Data);
grid on
title('torque x');

subplot(4,1,3)
plot(cross_z.Time, cross_z.Data);
grid on
legend('x','y','z');
title('cross z');

subplot(4,1,4)
plot(torque_z.Time, torque_z.Data);
grid on
title('torque z');


figure
plot(gg_torque.Time,gg_torque.Data);
grid on
xlabel('Time (s)');
ylabel('Gravity Gradient Torque (N*m)');
legend('s/c x','s/c y','s/c z');
title('Gravity Gradient Torques Exerted on S/C');
gg_torque_body.Data(end,:)

