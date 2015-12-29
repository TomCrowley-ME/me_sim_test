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
% csc_ekf_nonlinear_filter_init.m                                         %
%                                                                         %
% 09/29/11                                                                %
%-------------------------------------------------------------------------%

ekf_covariance_init = diag([10 10 10 .5 .5 .5 0.1 0.1 0.1 1 1 1 1 1 1]);

ekf_meas_matrix = zeros(kfl_n_meas, kfl_n_state);
% ekf_meas_matrix(1:3,1:3) = eye(3);