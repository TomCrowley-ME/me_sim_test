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
% export_visualization_data.m                                             %
%                                                                         %
% 06/19/14                                                                %
%-------------------------------------------------------------------------%

% process_test_data(pwd)

% create csv file of true spacecraft position/attitude in mcmf

% process_test data loads in tne scnenario, but need prep to grab TMat
ini_Tmat_MCMF_to_Topocentric = [ -sind(ini_topocentric_longitude)                                 cosd(ini_topocentric_longitude)                                0                             ;...
                                 -sind(ini_topocentric_latitude)*cosd(ini_topocentric_longitude) -sind(ini_topocentric_latitude)*sind(ini_topocentric_longitude) cosd(ini_topocentric_latitude);...
                                  cosd(ini_topocentric_latitude)*cosd(ini_topocentric_longitude)  cosd(ini_topocentric_latitude)*sind(ini_topocentric_longitude) sind(ini_topocentric_latitude)];

                              
% convert to quaternion
mcmf_to_topo_quat_scalar_first = dcm2quat(ini_Tmat_MCMF_to_Topocentric);
mcmf_to_topo_quat = [mcmf_to_topo_quat_scalar_first(2:4) mcmf_to_topo_quat_scalar_first(1)];
clear mcmf_to_topo_quat_scalar_first

i_hover = find( truth.sim.spacecraft_landed_flag.Data == 0, 1 );
if i_hover == 1
    i_real_start = find( truth.sim.spacecraft_landed_flag.Data == 1, 1);
    
    i_hover = find( truth.sim.spacecraft_landed_flag.Data(i_real_start:end) == 0, 1 ) + i_real_start;
    
end

i_land = find( truth.sim.spacecraft_landed_flag.Data(i_hover:end) == 1, 1 ) + i_hover;

i_hover = i_hover - 200;
i_land = i_land + 200;

true_quat = truth.sim.q_topo_to_body.Data(i_hover:i_land,:);
true_pos = truth.sim.pos_topo.Data(i_hover:i_land,:);
true_time = truth.sim.Time(i_hover:i_land,:);

% create body_to_mcmf attitude
body_to_mcmf_quat = ( quat_mult( repmat(mcmf_to_topo_quat,length(true_quat),1), true_quat ) );

% create body position in mcmf
true_pos(:,3) = true_pos(:,3)+central_body_radius + ini_alt_wrt_meanrad;
pos_mcmf = vector_frame_transformation( true_pos,  repmat(quat_inv(mcmf_to_topo_quat), length(true_pos),1)  );

% construct timeseries for easy resampling
ts_body_to_mcmf_quat = timeseries(body_to_mcmf_quat,true_time, 'Name','body_to_mcmf_quat');
ts_body_pos_mcmf = timeseries(pos_mcmf, true_time, 'Name','body_pos_mcmf');

% sample position/attitude down to desired framerate
frame_dt = 1/24;
tFinal = ts_body_pos_mcmf.Time(end);
t0 = ts_body_pos_mcmf.Time(1);
frame_time_vec = [t0 : frame_dt : tFinal]';

vis_body_to_mcmf_quat = resample(ts_body_to_mcmf_quat, frame_time_vec);
vis_body_pos_mcmf = resample(ts_body_pos_mcmf, frame_time_vec);

% downsample true thrust values (binned into either on or off) to capture
% higher rate dynmaics (badly...)
yesno_thrust = squeeze((truth.sim.thrusts.Data(i_hover:i_land) > 0))';
ts_yesno_thrust = timeseries(yesno_thrust,true_time,'Name','thrust_on');
vis_thrusters_on = resample(ts_yesno_thrust, frame_time_vec);


%TIME	MCMF_X	MCMF_Y	MCMF_Z	BODY2MCMF_1	BODY2MCMF_2	BODY2MCMF_3	BODY2MCMF_4

dlmwrite('scn81_improved_acs_lander_mcmf_pose.csv', [vis_body_pos_mcmf.Time vis_body_pos_mcmf.Data vis_body_to_mcmf_quat.Data],'precision',12)
dlmwrite('scn81_improved_acs_thuster_firings.csv', [vis_thrusters_on.Time vis_thrusters_on.Data]);