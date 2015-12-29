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
% csc_sta_star_tracker_prep.m                                             %
%                                                                         %
% 03/28/13                                                                %
%-------------------------------------------------------------------------%


sta_body_to_head1_dcm = rot_angles_to_dcm([ sta_body_to_head1_rotz sta_body_to_head1_roty sta_body_to_head1_rotx] );
sta_body_to_head1 = rot_angles_to_quat([ sta_body_to_head1_rotz sta_body_to_head1_roty sta_body_to_head1_rotx] );

% counter initializes at 0
sta_att_counter = sta_att_update_time / sim_time_step_size ;