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
model_name = 'vision_loop_meme_interface_hrn';
load_system(model_name)

load vision_loop_test_data.mat

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
dt = 0.0025;
t0 = 0;
tFinal = 1;
t = [t0 : dt : tFinal];
n = length(t);

time.time               = t;
time.signals.values     = playback.time.Data(1:n,:);
time.signals.dimensions = [ 1 ];

pos_eci.time               = t;
pos_eci.signals.values     = playback.pos_eci.Data(1:n,:);
pos_eci.signals.dimensions = [ 3 ];

quat_eci.time               = t;
quat_eci.signals.values     = playback.quat_eci.Data(1:n,:);
quat_eci.signals.dimensions = [ 4 ];

rate_body.time               = t;
rate_body.signals.values     = playback.rate_body.Data(1:n,:);
rate_body.signals.dimensions = [ 3 ];

sim('vision_loop_meme_interface_hrn')

%%
iNew = find(new_pix.Data);
m = length(iNew);

for jj = 1 : m
    
    homog = H.Data(:,:,iNew(jj));
    im1_pix = pix1.Data(:,:,iNew(jj));
    im2_pix = pix2.Data(:,:,iNew(jj));
    
    pixel_error = NaN( size(im1_pix) );
    
    if valid.Data(iNew(jj)) > 0
        
        for kk = 1 : length(im1_pix)
            temp = homog*[im1_pix(kk,:) 1]';
            pixel_error(kk,:) = im2_pix(kk,:) - temp(1:2)'/temp(3);
        end
        
    end
    
    
    reprojection_error(:,:,jj) = pixel_error;
    mean_reprojection_error(jj,1) = mean( normrows(pixel_error) );
    std_reprojection_error(jj,1) = std( normrows(pixel_error) );
    
end


