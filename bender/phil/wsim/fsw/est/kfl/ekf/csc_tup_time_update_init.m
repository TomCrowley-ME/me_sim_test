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
% csu_tup_time_update_init.m                                              %
%                                                                         %
% 09/30/11                                                                %
%-------------------------------------------------------------------------%

% high altitude process noise
tup_process_noise_high     =  diag([  1.1    1.1   10.1 ,  0.000505    0.000505     0.000505 ,  0.00001  0.00001  0.00001 , 0.001 0.001 0.001 , 0.001 0.001 0.001 ]);

% low altitude process noise
tup_process_noise_low      =  diag([ 10.1   10.1    1e6 , 1e3  1e3  1e6 ,   1000.1   1000.1  10000.1 , 0.001 0.001 0.001 , 0.001 0.001 0.001 ]);

% terminal descent process noise
tup_process_noise_terminal =  diag([ 10.1   10.1    1e6 , 1e5  1e5  1e6 ,   1000.1   1000.1  10000.1 , 0.001 0.001 0.001 , 0.001 0.001 0.001 ]);

% zero out process noise when landed, except on attitude (if using tracker)
tup_landed_attitude_process_noise = [0.001 0.001 0.001]; % should be commented

tup_noise_switch_alt   = 4000;
tup_noise_terminal_alt =  200;

%------------------------------------------------------------------------%
%       Create equations of motion (linear)                              %
%------------------------------------------------------------------------%
Z = zeros(3,3);
I = eye(3);

tup_state_dynamics_init = [ Z I Z Z Z ;
                            Z Z Z Z Z;
                            Z Z Z Z Z ;
                            Z Z Z Z -I ;
                            Z Z Z Z Z ];


clear Z I 

