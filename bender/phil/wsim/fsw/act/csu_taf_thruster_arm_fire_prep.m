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
% csu_taf_thruster_arm_fire_prep.m                                        %
%                                                                         %
% 07/02/14                                                                %
%-------------------------------------------------------------------------%


taf_fine_armed        = uint32( act_full_on_duration*ones(12,1,'uint32') );
taf_coarse_armed      = uint32( act_full_on_duration*ones(12,1,'uint32') );
taf_main_mono_armed   = uint32( act_full_on_duration );
taf_main_biprop_armed = uint32( act_full_on_duration );

taf_fine_disarmed        = uint32( zeros(12,1) );
taf_coarse_disarmed      = uint32( zeros(12,1) );
taf_main_mono_disarmed   = uint32( 0 );
taf_main_biprop_disarmed = uint32( 0 );