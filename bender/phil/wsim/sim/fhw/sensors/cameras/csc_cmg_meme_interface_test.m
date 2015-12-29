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
% csc_cmg_meme_interface_test.m                                           %
%                                                                         %
% geometry and what have you                                              %
% 10/15/13                                                                %
%-------------------------------------------------------------------------%

model_name = 'csc_cmg_meme_interface_hrn';
load_system(model_name)

nimbus_sim_init;

%-------------------------------------------------------------------------%
% set the stop time of the simulation
sim_stop_time = 150;

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
% simulation init (sets initial conditions and calls FSW init files)
ini_j2000_or_topo = 0; % initialize sim topocentric phasse ( 1 for inertial )
est_j2000_or_topo = 1; % initialize to Approach Phase Estimation Error

%-----------------------------------------------------------------------%
% Load the scenario: only place for scenario-specific data
load_scenario('scenario_1');


nimbus_sim_prep;
%%

% % end state from scenario 1: should be on surface (ish) and pointing straight down
% time = telem.cma_cam_image_time.Data(end);
% body_pos_eci = truth.sim_rtk_pos_eci.Data(end,:) - 10000000*[-0.775838563978826  -0.598403192122559   0.199970353554735];
% body_quat_eci = truth.sim_rrk_q_body_from_eci.Data(end,:);

km_standoff = 10;

time = 1.430316544100000e+09;

if ~exist('opt_eci','var')
    opt_axis_eci = [0 0 0];
    fprintf(1,'camera should be on surface of moon\n')
else
    opt_axis_eci = opt_eci.Data(:,1)';
end

body_pos_eci = 1e6*[0.843851792584388   0.466879271382913  -1.444585231082321] - 1000*km_standoff*opt_axis_eci;
body_quat_eci = [-0.336134817449092   0.895247159369383   0.041065079908306   0.289585164246447];

 

sim('csc_cmg_meme_interface_hrn')



