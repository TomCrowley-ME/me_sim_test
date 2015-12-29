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
% csc_est_nontunable_variable_init.m                                      %
%                                                                         %
% 04/11/14                                                                %
%-------------------------------------------------------------------------%


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
% SNP

    snp_zero_index = zeros(1,kfl_n_meas);
    snp_zero_meas  = zeros(kfl_n_meas,1);

    snp_rdr_index       = [1];
    snp_rdr_zero_index  = [0];

    snp_stg_index       = [4 5 6];
    snp_stg_zero_index  = [0 0 0];

    snp_fsp_index       = [ 2 3 ];
    snp_fsp_zero_index  = [ 0 0 ]; 

    
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
% TUP    
    
    % Create equations of motion (linear)
    Z = zeros(3,3);
    I = eye(3);

    tup_state_dynamics_init = [ Z I Z Z  Z ; Z Z Z Z  Z ; Z Z Z Z  Z ; Z Z Z Z -I ; Z Z Z Z  Z ];


    clear Z I 
    
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
% MUP 

    mup_columns  = [1 : kfl_n_state];
    mup_identity = eye(kfl_n_state);


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
% FCV 

    fcv_diverged = 0;
    fcv_numerical_fault = 1;
    fcv_initializing = 2;
    fcv_acquiring = 3;
    fcv_converged = 4;
    
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
% MKF  
    
    % select filter biases and gibbs terms to create final values
    mkf_selection_index = [ kfl_acc_bias_index kfl_gyro_bias_index kfl_gibbs_index];

    mkf_zero_gibbs = [ 0 0 0];
    mkf_null_quat = [ 0 0 0 1];
    
    