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

%% Begin IMK test file
% Dependencies:
%   csu_imk_imu_kinematics_init_a
%   csu_imk_imu_kinematics_prep_a
%
% Sources:
%   csu_imk_imu_kinematics_req
%
%% Initialize 
csu_imk_imu_kinematics_init_a

%set up test vectors
cmd_t=[0:2]';

%override initialized parameters for imu and set up random
% imu angles relative to the body
imu_rotx=30*pi/180;imu_roty=60*pi/180; imu_rotz = 90*pi/180;
csu_imk_imu_kinematics_prep_a

%set up random set of euler angle inputs to be used in all tests
euler_x=0*pi/180;euler_y=0*pi/180;euler_z=0*pi/180;
eulers_in=[cmd_t ones(size(cmd_t,1),1)*[euler_x euler_y euler_z ]];
% calculate dcm for euler rotation matrix
cgamma=cos(euler_x);
cbeta=cos(euler_y);
calpha=cos(euler_z);
sgamma=sin(euler_x);
sbeta=sin(euler_y);
salpha=sin(euler_z);
euler_dcm=[ calpha*cbeta, calpha*sbeta*sgamma-salpha*cgamma, calpha*sbeta*cgamma+salpha*sgamma, 
          salpha*cbeta, salpha*sbeta*sgamma+calpha*cgamma, salpha*sbeta*cgamma-calpha*sgamma,
          -sbeta, cbeta*sgamma, cbeta*cgamma ];

%% test centripetal accelerations IMK_0001

failed=false;
alpha_in=[cmd_t zeros(size(cmd_t,1),3)]; 
omega_in=[cmd_t [1 0 0;0 1 0;0 0 1]];
gravity_in=[cmd_t ones(size(cmd_t,1),1)*[0 0 0 ]];
accel_in=[cmd_t ones(size(cmd_t,1),1)*[0 0 0 ]];

for i=1:3
    % initialize the imu position
    imu_position(1:3)=0;
    imu_position(i)= 1;
    
    %convert position to eci
    rotated_imu_position=imu_position*euler_dcm';
    
    %calculate expected acceleration in eci frame
    expected_accels=cross(omega_in(:,2:4),cross(omega_in(:,2:4),ones(3,1)*rotated_imu_position,2),2);
    
    %convert expected accels to body frame
    expected_accels=expected_accels*euler_dcm;
    
    %convert expected accels to imu frame
    expected_accels=expected_accels*imu_dcm;
    
    %sim and check if answer is correct
    sim('csu_imk_imu_kinematics_hrn_a');
    if(max(max(abs(expected_accels-accel_out)))>eps)
    failed=true;
    end
end

if(failed==true)
    unit_test_record('fail',1,'centripetal accelerations incorrect');
else
    unit_test_record('pass',1);
end

%% test tangential accelerations IMK_0002
failed=false;
omega_in=[cmd_t zeros(size(cmd_t,1),3)]; 
alpha_in=[cmd_t [1 0 0;0 1 0;0 0 1]];
gravity_in=[cmd_t ones(size(cmd_t,1),1)*[0 0 0 ]];
accel_in=[cmd_t ones(size(cmd_t,1),1)*[0 0 0 ]];



for i=1:3
    % initialize the position
    imu_position(1:3)=0;
    imu_position(i)= 1;
    
    %convert position to eci
    rotated_imu_position=imu_position*euler_dcm';
    
    %calculate expected acceleration in eci frame
    expected_accels=cross(alpha_in(:,2:4),(ones(3,1)*rotated_imu_position),2);
    
    %convert expected accels to body frame
    expected_accels=expected_accels*euler_dcm;
    
    %convert expected accels to imu frame
    expected_accels=expected_accels*imu_dcm;
    
    %sim and check if answer is correct
    sim('csu_imk_imu_kinematics_hrn_a');
    if(max(max(abs(expected_accels-accel_out)))>eps)
    failed=true;
    end
end

if(failed==true)
    unit_test_record('fail',2,'tangential accelerations incorrect');
else
    unit_test_record('pass',2);
end

%% test body accelerations IMK_0003

failed=false;
omega_in=[cmd_t zeros(size(cmd_t,1),3)]; 
alpha_in=[cmd_t zeros(size(cmd_t,1),3)];
gravity_in=[cmd_t ones(size(cmd_t,1),1)*[0 0 0 ]];
accel_in=[cmd_t [1 0 0;0 1 0;0 0 1]];

imu_position(1:3)=0;

%calculate expected acceleration in eci frame
expected_accels=accel_in(:,2:4);
    
%convert expected accels to body frame
expected_accels=expected_accels*euler_dcm;
    
%convert expected accels to imu frame
expected_accels=expected_accels*imu_dcm;
    
%sim and check if answer is correct
sim('csu_imk_imu_kinematics_hrn_a');
if(max(max(abs(expected_accels-accel_out)))>eps)
    failed=true;
end


if(failed==true)
    unit_test_record('fail',3,'body accelerations incorrect');
else
    unit_test_record('pass',3);
end


%% test gravitational accelerations IMK_0004

failed=false;
omega_in=[cmd_t zeros(size(cmd_t,1),3)]; 
alpha_in=[cmd_t zeros(size(cmd_t,1),3)];
accel_in=[cmd_t ones(size(cmd_t,1),1)*[0 0 0 ]];
gravity_in=[cmd_t [1 0 0;0 1 0;0 0 1]];

imu_position(1:3)=0;

%calculate expected acceleration in eci frame
expected_accels=-gravity_in(:,2:4);  %imu outputs opposite of gravity field
    
%convert expected accels to body frame
expected_accels=expected_accels*euler_dcm;
    
%convert expected accels to imu frame
expected_accels=expected_accels*imu_dcm;
    
%sim and check if answer is correct
sim('csu_imk_imu_kinematics_hrn_a');
if(max(max(abs(expected_accels-accel_out)))>eps)
    failed=true;
end


if(failed==true)
    unit_test_record('fail',4,'gravity accelerations incorrect');
else
    unit_test_record('pass',4);
end

%% test angular velocities IMK_0005
failed=false;
alpha_in=[cmd_t zeros(size(cmd_t,1),3)]; 
omega_in=[cmd_t [1 0 0;0 1 0;0 0 1]];
gravity_in=[cmd_t ones(size(cmd_t,1),1)*[0 0 0 ]];
accel_in=[cmd_t ones(size(cmd_t,1),1)*[0 0 0 ]];

for i=1:3
    % initialize the imu position
    imu_position(1:3)=0;
    imu_position(i)= 1;
    
    %convert position to eci
    rotated_imu_position=imu_position*euler_dcm';
    
    %calculate expected in body frame
    expected_rates=omega_in(:,2:4);
    
    %convert expected accels to imu frame
    expected_rates=expected_rates*imu_dcm;
    
    %sim and check if answer is correct
    sim('csu_imk_imu_kinematics_hrn_a');
    if(max(max(abs(expected_rates-rates_out)))>eps)
    failed=true;
    end
end

if(failed==true)
    unit_test_record('fail',5,'angular velocities incorrect');
else
    unit_test_record('pass',5);
end
    
%% end test
disp('Completed csu_imk_imu_kinematics_test_a');

    
    
    
    


