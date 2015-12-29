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
% csu_tup_time_update_prep.m                                              %
%                                                                         %
% 09/30/11                                                                %
%-------------------------------------------------------------------------%

% zero out process noise while landed
tup_process_noise_landed = csc_tup_landed_process_noise_var_set(kfl_use_tracker_meas, tup_landed_attitude_process_noise, kfl_n_state);

%------------------------------------------------------------------------%
%       Create equations of motion (linear)                              %
%------------------------------------------------------------------------%

tup_state_update_init = eye(kfl_n_state) + tup_state_dynamics_init * est_time_step;

clear Z I A

