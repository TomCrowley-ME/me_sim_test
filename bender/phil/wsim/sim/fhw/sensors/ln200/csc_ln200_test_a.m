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
%
% Sources:
%   csc_ln200_req.html
%
%% Verify that all CSU's and CSC's are present

% verify presence of the csc
try
    load_system('csc_ln200_lib_a');
catch ME
    disp('component test failed ln200 - could not find csc');
    return
end

% verify presence of imk
try
    load_system('csc_ln200_lib_a/csc_ln200_a/csu_imk_imu_kinematics_a');
    unit_test_record('pass',1);
catch ME
    unit_test_record('fail',1,'Could not locate imk csu');
end

% verify presence of lnh
try
    load_system('csc_ln200_lib_a/csc_ln200_a/csu_lnh_ln200_hardware_a');
    unit_test_record('pass',2);
catch ME
    unit_test_record('fail',2,'Could not locate lnh csu');
end

% verify presence of lns
try
    load_system('csc_ln200_lib_a/csc_ln200_a/csu_lns_ln200_software_lib_a');
    unit_test_record('pass',3);
catch ME
    unit_test_record('fail',3,'Could not locate lns csu');
end

%% end test
disp('Completed csc_ln200_test_a.m');

