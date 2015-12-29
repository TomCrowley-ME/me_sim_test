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
% csc_tup_landed_process_noise_var_set.m                                  %
%                                                                         %
% 09/30/11                                                                %
%-------------------------------------------------------------------------%


function tup_process_noise_landed = csc_tup_landed_process_noise_var_set(kfl_use_tracker_meas, tup_landed_attitude_process_noise, kfl_n_state)


if kfl_use_tracker_meas
    % keep attitude estimation alive when on ground
    tup_process_noise_landed  =  diag([ 0 0 0  ,0 0 0 ,  0 0 0 , tup_landed_attitude_process_noise , 0 0 0]);
else
    % kill off all process noise when on the ground
    tup_process_noise_landed = zeros(kfl_n_state, kfl_n_state);
end