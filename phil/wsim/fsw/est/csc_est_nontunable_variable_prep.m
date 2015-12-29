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
% csc_est_nontunable_variable_prep.m                                      %
%                                                                         %
% 07/22/14                                                                %
%-------------------------------------------------------------------------%

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
% SNP
    

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
% TUP    
    
    % Create equations of motion (linear)
    tup_state_update_init = eye(kfl_n_state) + tup_state_dynamics_init * est_time_step;

    
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
% MUP 


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
% FCV 

    % elements in covariance matrix
    fcv_n_elements = kfl_n_state*kfl_n_state;

    fcv_diag_elements = [1 : kfl_n_state+1 : fcv_n_elements];
 
    
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
% MKF  