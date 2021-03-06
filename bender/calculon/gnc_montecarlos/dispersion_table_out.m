% select DCM
if strcmp(est_err_frame_type,'VNC')
    DispersionParamName = {'Velocity Vector Position Error (m)';'Orbit Normal Position Error (m)';'Radial Position Error (m)';...
    'Velocity Vector Velocity Error (m/s)';'Orbit Normal Velocity Error (m/s)';'Radial Velocity Error (m/s)';...
    'Biprop Isp (sec)';'Biprop Thrust (N)';'Biprop Start Delay (sec)';'Biprop Stop Delay';'Biprop Misalignment (deg)';...
    'Lateral Dry CM X (m)';'Lateral Dry CM Y (m)';'Longitudinal Dry CM Z';'HTP Mass (kg)';'RP1 Mass (kg)';'Cold Gas (kg)';'Mass Estimate Error (kg)';...
    'LIDAR Maximum Acquisition Range (m)';'Long Range LIDAR Error (m)';'Short Range LIDAR Error (m)';'Star Tracker Noise (arc-sec)'};
%     'Camera Integration Time (sec)';'Image Processing Delay (sec)'};
    Three_Sigma_Pos = [pos_est_err_3sigma_vhat pos_est_err_3sigma_nhat pos_est_err_3sigma_rhat];
    Three_Sigma_Vel = [vel_est_err_3sigma_vhat vel_est_err_3sigma_nhat vel_est_err_3sigma_rhat];
    
elseif strcmp(est_err_frame_type,'LVLH')
    DispersionParamName = {'Velocity Vector Error (m)';'Orbit Normal Position Error (m)';'Radial Position Error (m)';...
    'Velocity Vector Velocity Error (m/s)';'Orbit Normal Velocity Error (m/s)';'Radial Velocity Error (m/s)';...
    'Biprop Isp (sec)';'Biprop Thrust (N)';'Biprop Start Delay (sec)';'Biprop Stop Delay';'Biprop Misalignment (deg)';...
    'Lateral Dry CM X (m)';'Lateral Dry CM Y (m)';'Longitudinal Dry CM Z';'HTP Mass (kg)';'RP1 Mass (kg)';'Cold Gas (kg)';'Mass Estimate Error (kg)';...
    'LIDAR Maximum Acquisition Range (m)';'Long Range LIDAR  Error (m)';'Short Range LIDAR Error (m)';'Star Tracker Noise (arc-sec)'};
%     'Camera Integration Time (sec)';'Image Processing Delay (sec)'};
    Three_Sigma_Pos = [pos_est_err_3sigma_vhat pos_est_err_3sigma_nhat pos_est_err_3sigma_rhat];
    Three_Sigma_Vel = [vel_est_err_3sigma_vhat vel_est_err_3sigma_nhat vel_est_err_3sigma_rhat];

else
    DispersionParamName = {'Radial Position Error (m)';'Velocity Vector Position Error (m)';'Orbit Normal Position Error (m)';...
    'Radial Velocity Error (m/s)';'Velocity Vector Velocity Error (m/s)';'Orbit Normal Velocity Error (m/s)';...
    'Biprop Isp (sec)';'Biprop Thrust (N)';'Biprop Start Delay (sec)';'Biprop Stop Delay';'Biprop Misalignment (deg)';...
    'Lateral Dry CM X (m)';'Lateral Dry CM Y (m)';'Longitudinal Dry CM Z';'HTP Mass (kg)';'RP1 Mass (kg)';'Cold Gas (kg)';'Mass Estimate Error (kg)'};
    'LIDAR Maximum Acquisition Range (m)';'Long Range LIDAR  Error (m)';'Short Range LIDAR Error (m)';'Star Tracker Noise (arc-sec)';...
%     'Camera Integration Time (millisec)';'Image Processing Delay (sec)'};
    Three_Sigma_Pos = [pos_est_err_3sigma_rhat pos_est_err_3sigma_vhat pos_est_err_3sigma_nhat ];
    Three_Sigma_Vel = [vel_est_err_3sigma_rhat vel_est_err_3sigma_vhat vel_est_err_3sigma_nhat ];

end

NominalValue = [ini_position_v(1); ini_position_v(2);ini_position_v(3);...
                ini_velocity_v(1);ini_velocity_v(2);ini_velocity_v(3);...
                tpl_main_biprop_isp;tdl_main_biprop_thrust;0;0;0;...
                0;0;0;htp_mass_nominal;rp1_mass_nominal;gn2_mass_nominal;0;...
                max_range_mean;0;0;0];
%                 min_delta_t; min_delay_t];
MeanBiasSF = [0;0;0;0;0;0;...
             (biprop_isp_max+biprop_isp_min)/2;(biprop_thrust_max+biprop_thrust_min)/2;0;0;0;...
              0;0;0;0;0;0;(mass_estimate_bias_max+mass_estimate_bias_min)/2;...
              1;0;0;0];
%               0;0;];
MinSF = [0;0;0;...
         0;0;0;...
         biprop_isp_min;biprop_thrust_min;0;0;0;...
         1+lateral_cm_x_dry_min/mpl_cgx_location_fillfrac_0;1-lateral_cm_y_dry_min/mpl_cgy_location_fillfrac_0;1+longitudinal_cm_z_dry_min/mpl_cgz_location_fillfrac_0;...
         1-(htp_mass_min/htp_mass_nominal);1-(rp1_mass_min/rp1_mass_nominal);1-(gn2_mass_min/gn2_mass_nominal);0;...
         1-(max_range_variation/max_range_mean);0;0;0];
%          0;0];
MaxSF = [0;0;0;0;0;0;...
         biprop_isp_max;biprop_thrust_max;0;0;0;...
         1+lateral_cm_x_dry_max/mpl_cgx_location_fillfrac_0;1-lateral_cm_y_dry_max/mpl_cgy_location_fillfrac_0;1+longitudinal_cm_z_dry_max/mpl_cgz_location_fillfrac_0;...
         1+(htp_mass_max/htp_mass_nominal);1+(rp1_mass_max/rp1_mass_nominal);1+(gn2_mass_max/gn2_mass_nominal);0;...
         1+(max_range_variation/max_range_mean);0;0;0];
%          0;0];
Uniform_Gaussian = { 'Gaussian';'Gaussian';'Gaussian';...
                                   'Gaussian';'Gaussian';'Gaussian';...
                                   'Uniform'; 'Uniform'; 'Uniform'; 'Uniform';  'Gaussian';...
                                   'Uniform'; 'Uniform'; 'Uniform'; 'Gaussian';'Gaussian';'Gaussian';'Gaussian';...
                                   'Gaussian';'Gaussian';'Gaussian';'Uniform'};
%                                    'Uniform'; 'Uniform'};
ThreeSigma = [Three_Sigma_Pos(1); Three_Sigma_Pos(2); Three_Sigma_Pos(3); Three_Sigma_Vel(1); Three_Sigma_Vel(2); Three_Sigma_Vel(3);...
             (biprop_isp_max+biprop_isp_min)/2+(biprop_isp_max-biprop_isp_min)*tpl_main_biprop_isp;...
             (biprop_thrust_max+biprop_thrust_min)/2+(biprop_thrust_max-biprop_thrust_min)*tdl_main_biprop_thrust;...
             (biprop_start_delay_max-biprop_start_delay_min);(biprop_stop_delay_max-biprop_stop_delay_min);misalignment_ang_deg_3sigma;...
             (lateral_cm_x_dry_max - lateral_cm_x_dry_min)/2;(lateral_cm_y_dry_max - lateral_cm_y_dry_min)/2;(longitudinal_cm_z_dry_max - longitudinal_cm_z_dry_min)/2;...
             (htp_mass_max-htp_mass_min);(rp1_mass_max-rp1_mass_min);(gn2_mass_max-gn2_mass_min);(mass_estimate_bias_max-mass_estimate_bias_min);...
             max_range_variation;3*flr_15k_1sig_noise;3*flr_100m_1sig_noise;(max_st_noise-min_st_noise)];
%              max_integ_time-min_integ_time;max_delay_t-min_delay_t];
LowValue = -ThreeSigma + NominalValue;
    LowValue(1:3) = ini_position_v' - DCM*Three_Sigma_Pos'; 
    LowValue(4:6) = ini_velocity_v' - DCM*Three_Sigma_Vel'; 
HighValue = ThreeSigma + NominalValue;
    HighValue(1:3) = ini_position_v' + DCM*Three_Sigma_Pos'; 
    HighValue(4:6) = ini_velocity_v' + DCM*Three_Sigma_Vel'; 

T_Table_Test = table(DispersionParamName,NominalValue,MeanBiasSF,MinSF,MaxSF,Uniform_Gaussian,ThreeSigma,LowValue,HighValue);
writetable(T_Table_Test,'DispersionInputs.csv');
