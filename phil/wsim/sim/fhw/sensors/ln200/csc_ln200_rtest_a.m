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

%% Begin ln200 test file
%
% Dependencies:
% csc_ln200_lib_a.mdl
% csc_ln200_test_a.m
% csu_imk_imu_kinematics_test_a.m
% csu_lnh_ln200_hardware_test_a.m
% csu_lns_ln200_software_test_a.m
%
% Sources:
%   csc_ln200_req.html
%
%% Verify that all CSU's and CSC's are present

% verify presence of the csc
csc_ln200_test_a

%% Unit Tests
csu_imk_imu_kinematics_test_a
csu_lnh_ln200_hardware_test_a
csu_lns_ln200_software_test_a

%% end test
disp('Completed csc_ln200_rtest_a.m');

