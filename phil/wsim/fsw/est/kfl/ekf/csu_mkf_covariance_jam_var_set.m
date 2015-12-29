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
% csu_mkf_covariance_jam_var_set.m                                        %
%                                                                         %
% 05/06/14                                                                %
%-------------------------------------------------------------------------%

function [ mkf_cov_jam_index ] = csu_mkf_covariance_jam_var_set(kfl_use_tracker_meas, kfl_pos_index, kfl_vel_index, kfl_acc_bias_index, kfl_gibbs_index, kfl_gyro_bias_index)

if kfl_use_tracker_meas
    % keep attitude estimation alive when on ground
    mkf_cov_jam_index = [ kfl_pos_index kfl_vel_index kfl_acc_bias_index];
else
    % kill off all cov growth when on the ground
    mkf_cov_jam_index = [ kfl_pos_index kfl_vel_index kfl_acc_bias_index kfl_gibbs_index kfl_gyro_bias_index];
end


