% clear all

load_model mtv1;

%-------------------------------------------------------------------------%
% define nonvirtual buses
mtv_bus_all;
mtv_commands_all;

%-------------------------------------------------------------------------%
% initialize global parameters & set planet
gbl_global_parameters_init;
central_body_name = 'earth';
set_central_body;

%-------------------------------------------------------------------------%
% set the stop time of the simulation
sim_stop_time = 60;

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
% simulation init (sets initial conditions and calls FSW init files)
ini_j2000_or_topo = 0; % initialize to Topo  == 0
est_j2000_or_topo = 0; % initialize to Landed Phase Estimation Error

mc_prefix_s = 'mtv_winds_mc';
mc_prefix_s_pos = 'mtv_winds_pos_mc';
mc_prefix_workspace = 'mtv_winds_workspace_mc';

% set seed!
RandStream.setGlobalStream(RandStream.create('mt19937ar','seed',23))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mc_n = 1000;  % User set to total number of MC cases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% percent of range errors
percent_mean = 0/100; % Set mean to 0%
percent_variation = (0.1)/100; % Range above and below mean (FLIR MLR 2K 0.1% at 1 km == 1 meter at 1 km)
percent_errors = percent_mean + percent_variation*rand(mc_n,1);

% % hardcode
% percent_errors = 0.010*ones(mc_n,1);

% max acquisition range
max_range_mean = 1.0*5000; % Set mean to 2.5 km
max_range_variation = 5000; % Range above and below mean
max_ranges = abs(max_range_mean + max_range_variation*rand(mc_n,1));
% max_ranges = abs(2*max_range_mean)*randn(mc_n,1);

% % hardcode
max_ranges = 5000*ones(mc_n,1);

% star tracker transerve noise (in arcsecond)
min_st_noise = 0;
max_st_noise = 10;
st_noise_vec = abs(min_st_noise + (max_st_noise-min_st_noise)*rand(mc_n,1));

% % hardcode
st_noise_vec = 9*ones(mc_n,1);

% camera integration time (used in blur noise factor)
min_integ_time =  5/ 1000;
max_integ_time = 15 / 1000;
integ_time_vec = abs(min_integ_time + (max_integ_time-min_integ_time)*rand(mc_n,1));

% % hardcode
integ_time_vec = 0.010*ones(mc_n,1);

% camera angular field of view
min_aov = 30 * pi/180;
max_aov = 50 * pi/180;
aov_vec = abs(min_aov + (max_aov-min_aov)*rand(mc_n,1));

% % hardcode
aov_vec = (26.2254*pi/180)*ones(mc_n,1);

% time between camera updates
min_delta_t = 0;
max_delta_t = 2;
delta_t_vec = abs(min_delta_t + (max_delta_t-min_delta_t)*rand(mc_n,1));

% % hardcode
delta_t_vec = 0.1*ones(mc_n,1);

% image processing delay time
min_delay_t = 0.1;
max_delay_t = 0.2;
delay_t_vec = abs(min_delay_t + (max_delay_t-min_delay_t)*rand(mc_n,1));

% % hardcode
delay_t_vec = 0.25*ones(mc_n,1);

% total lateral center-of-mass offset wet sigma - normal distribution
% lateral_cm_wet_sigma = 0.000;
% lateral_cm_wet_sigma = 0.004;
% lateral_cm_x_wet = 1.0*sqrt(0.5*lateral_cm_wet_sigma^2)*randn(mc_n,1);
% lateral_cm_y_wet = 1.0*sqrt(0.5*lateral_cm_wet_sigma^2)*randn(mc_n,1);
% lateral_cm_z_wet = 1.0*(0.01/3)*randn(mc_n,1);

% total lateral cm wet max/min - uniform distribution
lateral_cm_x_wet_max = 0.000;
lateral_cm_y_wet_max = 0.000;
lateral_cm_z_wet_max = 0.000;
lateral_cm_x_wet_min = 0.000;
lateral_cm_y_wet_min = 0.000;
lateral_cm_z_wet_min = 0.000;
lateral_cm_x_wet = lateral_cm_x_wet_min + (lateral_cm_x_wet_max - lateral_cm_x_wet_min)*rand(mc_n,1);
lateral_cm_y_wet = lateral_cm_y_wet_min + (lateral_cm_y_wet_max - lateral_cm_y_wet_min)*rand(mc_n,1);
lateral_cm_z_wet = lateral_cm_z_wet_min + (lateral_cm_z_wet_max - lateral_cm_z_wet_min)*rand(mc_n,1);

% total lateral center-of-mass offset dry - normal distribution
% lateral_cm_dry_sigma = 0.000;
% lateral_cm_dry_sigma = 0.004;
% lateral_cm_x_dry = 1.0*sqrt(0.5*lateral_cm_dry_sigma^2)*randn(mc_n,1);
% lateral_cm_y_dry = 1.0*sqrt(0.5*lateral_cm_dry_sigma^2)*randn(mc_n,1);
% lateral_cm_z_dry = 1.0*(0.01/3)*randn(mc_n,1);

% total lateral cm dry max/min - uniform distribution
lateral_cm_x_dry_max = 0.000;
lateral_cm_y_dry_max = 0.000;
lateral_cm_z_dry_max = 0.000;
lateral_cm_x_dry_min = 0.000;
lateral_cm_y_dry_min = 0.000;
lateral_cm_z_dry_min = 0.000;
lateral_cm_x_dry = lateral_cm_x_dry_min + (lateral_cm_x_dry_max - lateral_cm_x_dry_min)*rand(mc_n,1);
lateral_cm_y_dry = lateral_cm_y_dry_min + (lateral_cm_y_dry_max - lateral_cm_y_dry_min)*rand(mc_n,1);
lateral_cm_z_dry = lateral_cm_z_dry_min + (lateral_cm_z_dry_max - lateral_cm_z_dry_min)*rand(mc_n,1);

% set initial HTP mass, nominally set to: Scenario 88 (43.44 kg) Scenario 81 (34.47 kg)
if exist('scenario')
    if (scenario==81)
        htp_mass_nominal = 34.47;
    elseif (scenario==88)
        htp_mass_nominal = 44.44;
    end
else
    scenario         = 81;
    htp_mass_nominal = 34.47;
end
htp_mass_min = htp_mass_nominal-1.0;
htp_mass_max = htp_mass_nominal+0.0;
htp_mass     = htp_mass_min + (htp_mass_max - htp_mass_min)*rand(mc_n,1);

% wind speed max/min - uniform distribution [m/s]
wind_speed_min   = 7.0;
wind_speed_max   = 13.0;
wind_speed       = wind_speed_min + (wind_speed_max - wind_speed_min)*rand(mc_n,1);
wind_azimuth_min = 0.0;
wind_azimuth_max = 360.0;
wind_azimuth     = wind_azimuth_min + (wind_azimuth_max - wind_azimuth_min)*rand(mc_n,1);

% set random misalignment angles and azimuth angles for 25 thrusters
misalignment_ang_deg_1sigma = 0.0;

for i=1:25
    azimuth_ang(1:mc_n,i) = 360*rand(mc_n,1);
    misalignment_ang(1:mc_n,i) = misalignment_ang_deg_1sigma*randn(mc_n,1);
end

% Normal distribution with 1 sigma position error 50/3 meters and 1.5/3 m/s  
% Spherical distribution
%                         1.00*((2000/3)*randn(mc_n,1)), ...
%                         1.00*((2000/3)*randn(mc_n,1)), ...
%                         1.00*((2000/3)*randn(mc_n,1)), ...
%                         1.00*((2/3)*randn(mc_n,1)), ...
%                         1.00*((2/3)*randn(mc_n,1)), ...
%                         1.00*((2/3)*randn(mc_n,1)), ...
% 1 sec Knowledge Errors at Takeoff
mc_6dof_variables=cat(2, 1.0*percent_errors,...
                         1.0*max_ranges, ...
                        0.0*((382/3)*randn(mc_n,1)), ...
                        0.0*((382/3)*randn(mc_n,1)), ...
                        0.0*((382/3)*randn(mc_n,1)), ...
                        0.0*((0.3/3)*randn(mc_n,1)), ...
                        0.0*((0.3/3)*randn(mc_n,1)), ...
                        0.0*((0.3/3)*randn(mc_n,1)), ...
                        1.0*st_noise_vec, ...
                        1.0*integ_time_vec, ...
                        1.0*aov_vec, ...
                        1.0*delta_t_vec, ...
                        1.0*delay_t_vec, ...
                        lateral_cm_x_dry, ...
                        lateral_cm_y_dry, ...
                        lateral_cm_z_dry, ...
                        lateral_cm_x_wet, ...
                        lateral_cm_y_wet, ...
                        lateral_cm_z_wet,...
                        azimuth_ang,...
                        misalignment_ang,...
                        htp_mass, ...
                        wind_speed, ...
                        wind_azimuth ...
                        );
% and velocity error 2/3 m/s
% for icase=1:mc_n
%     mc_6dof_variables(icase,3:5) = randn(3,1)*500/3 ;
%     mc_6dof_variables(icase,6:8) = randn(3,1)*2/3 ;
% end

ivars = struct( 'ldr_2k_percent_error',1,...
                'ldr_2k_range_max',2,...
                'est_posx',3,'est_posy',4,'est_posz',5,...
                'est_velx',6,'est_vely',7,'est_velz',8,...
                'kfl_star_tracker_transverse_noise',9,...
                'cam_integ_time',10,...
                'cam_aov',11,...
                'cam_image_delta_t',12,...
                'cam_processing_delay',13,...
                'cgx_dry',14,'cgy_dry',15,'cgz_dry',16,...
                'cgx_wet',17,'cgy_wet',18,'cgz_wet',19,...
                'azimuth',[20:44],...
                'misalignment',[45:69],...
                'htp_mass',70,...
                'wind_speed',71,'wind_azimuth',72,...
                'n',72);
            
mc_i = 1 : size(mc_6dof_variables,1);

save MC_WORKSPACE

for i2mc = 1 : length(mc_i)
    tic;
    imc = mc_i(i2mc);
    name_mc = [ mc_prefix_s num2str(imc) ];
    name_mc_pos = [ mc_prefix_s_pos num2str(imc) ];
    name_mc_ws = [ mc_prefix_workspace num2str(imc) ];
    
    % MTV-1 specific init
    mtv1_sim_init;

    % Load the scenario
    if (scenario==81)
      fprintf('Scenario 81 loaded\n')
      load_scenario('scenario_81','schooner');
      scn81_guidance_tables;

    elseif (scenario==88)
      fprintf('Scenario 88 loaded\n')
      load_scenario('scenario_88','schooner');
      scn88_guidance_tables;

    end

    sensor_parameters;
    
    %----------------------------------------------------------------------%
    % Redefine wind altitude range
     Winds.Altitude = 0:.1:20;

    % Set wind speeds to zero
    Winds.Speed.Lateral  = zeros(size(Winds.Altitude));
    Winds.Speed.Vertical = zeros(size(Winds.Altitude));

    %----------------------------------------------------------------------%
    % simulation prep (acts on scenario speecific initial conditions )
    mtv1_sim_prep;

    %- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - - -%
    % set error state on Kalman filter state wrt true position, in inertial frame
    sim_set_kfl_error_state_init
    %- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - - -%

%     imh_accel_noise_on      = 1;  % 1 - ON, 0 - OFF
%     imh_gyro_noise_on       = 1;  % 1 - ON, 0 - OFF
%     imh_accel_bias_noise_on = 1;  % 1 - ON, 0 - OFF
%     imh_gyro_bias_noise_on  = 1;  % 1 - ON, 0 - OFF

    % %%%%%%%%%%%%%
    % Adjust here
    % %%%%%%%%%%%%%

        if ~isnan( mc_6dof_variables(imc,ivars.ldr_2k_percent_error) )
            ldr_2k_percent_error = mc_6dof_variables(imc,ivars.ldr_2k_percent_error);
        end
        if ~isnan( mc_6dof_variables(imc,ivars.ldr_2k_range_max) )
            ldr_2k_range_max = mc_6dof_variables(imc,ivars.ldr_2k_range_max);
        end
        if ~isnan( mc_6dof_variables(imc,ivars.est_posx) )
            kfl_position_init(1) = ini_position_v(1) + mc_6dof_variables(imc,ivars.est_posx);
        end
        if ~isnan( mc_6dof_variables(imc,ivars.est_posy) )
            kfl_position_init(2) =  ini_position_v(2) + mc_6dof_variables(imc,ivars.est_posy);
        end
        if ~isnan( mc_6dof_variables(imc,ivars.est_posz) )
            kfl_position_init(3) =  ini_position_v(3) + mc_6dof_variables(imc,ivars.est_posz);
        end
        if ~isnan( mc_6dof_variables(imc,ivars.est_velx) )
            kfl_velocity_init(1) = ini_velocity_v(1) + mc_6dof_variables(imc,ivars.est_velx);
        end
        if ~isnan( mc_6dof_variables(imc,ivars.est_vely) )
            kfl_velocity_init(2) =  ini_velocity_v(2) + mc_6dof_variables(imc,ivars.est_vely);
        end
        if ~isnan( mc_6dof_variables(imc,ivars.est_velz) )
            kfl_velocity_init(3) =  ini_velocity_v(3) + mc_6dof_variables(imc,ivars.est_velz);
        end

        if ~isnan( mc_6dof_variables(imc,ivars.kfl_star_tracker_transverse_noise) )
            kfl_star_tracker_transverse_noise = mc_6dof_variables(imc,ivars.kfl_star_tracker_transverse_noise);
        end
        
        if ~isnan( mc_6dof_variables(imc,ivars.cam_integ_time) )
            cam_integ_time = mc_6dof_variables(imc,ivars.cam_integ_time);
        end
        if ~isnan( mc_6dof_variables(imc,ivars.cam_aov) )
            cam_aov = mc_6dof_variables(imc,ivars.cam_aov);
        end
        if ~isnan( mc_6dof_variables(imc,ivars.cam_image_delta_t) )
            cam_image_delta_t = mc_6dof_variables(imc,ivars.cam_image_delta_t);
        end
        if ~isnan( mc_6dof_variables(imc,ivars.cam_processing_delay) )
            cam_processing_delay = mc_6dof_variables(imc,ivars.cam_processing_delay);
        end

        csc_cam_camera_system_prep

        % Lander cg only
        if ~isnan( mc_6dof_variables(imc,ivars.cgx_dry) )
            mpl_cgx_dry = mpl_cgx_dry + mc_6dof_variables(imc,ivars.cgx_dry);
        end
        if ~isnan( mc_6dof_variables(imc,ivars.cgy_dry) )
            mpl_cgy_dry = mpl_cgy_dry + mc_6dof_variables(imc,ivars.cgy_dry);
        end
        if ~isnan( mc_6dof_variables(imc,ivars.cgz_dry) )
            mpl_cgz_dry = mpl_cgz_dry + mc_6dof_variables(imc,ivars.cgz_dry);
        end
        
        mpl_cg_dry = [ mpl_cgx_dry  mpl_cgy_dry  mpl_cgz_dry]+mpl_origin_trans;

        if ~isnan( mc_6dof_variables(imc,ivars.htp_mass) )
            mpl_htp_mass_initial  = mc_6dof_variables(imc,ivars.htp_mass);
        end

        csu_mpl_mass_properties_mtv_prep

        if ~isnan( mc_6dof_variables(imc,ivars.azimuth))
         if ~isnan( mc_6dof_variables(imc,ivars.misalignment))
           
                az_ang_per_case = mc_6dof_variables(imc,ivars.azimuth);
                misalignments_per_case = mc_6dof_variables(imc,ivars.misalignment);
                if abs(misalignments_per_case) > 1e-6
                   thr_misalignment_populator
                end
         end
        end  

        if ~isnan( mc_6dof_variables(imc,ivars.wind_speed) )
            Winds.Speed.Lateral = mc_6dof_variables(imc,ivars.wind_speed)*ones(length(Winds.Altitude),1);
        end        

        if ~isnan( mc_6dof_variables(imc,ivars.wind_azimuth) )
            Winds.Azimuth = mc_6dof_variables(imc,ivars.wind_azimuth)*ones(length(Winds.Altitude),1);
        end        

        kfl_state_init = [ kfl_position_init ; kfl_velocity_init ; kfl_acc_bias_init ;  kfl_gibbs_init ;  kfl_gyro_bias_init];
                              
    sim_set_kfl_error_state_prep

    sim('mtv1');
 %%
    clear mc_all_initial mc_all_final
    process_test_data(scenario_data_dir);
    if ~exist('t','var') | size(t) ~= size(truth.sim.rtk_pos_eci.Time,1)
        t = truth.sim.rtk_pos_eci.Time;
    end
    
    save( name_mc );

%     t_subsampled = t(1:10:end);
%     rtk_pos_topo_subsampled = truth.sim.pos_topo(1:10:end,:);
%     rtk_vel_topo_subsampled = truth.sim.vel_topo(1:10:end,:);
%     propellant_used_subsampled = propellant_used(1:10:end,:);
%     gdn_t_subsampled = telem.gdn.seq_t.Time(1:10:end);
%     est_pos_topo_subsampled = telem.est.pos.Data(1:10:end,:);
%     est_vel_topo_subsampled = telem.est.vel.Data(1:10:end,:);
%     
    mc_traj_data.sim_pos    = truth.fsw_rate.topo.sim_pos;
    mc_traj_data.sim_vel    = truth.fsw_rate.topo.sim_vel;
    mc_traj_data.sim_mass   = truth.sim.mass.Data(1) - resample(truth.sim.mass, truth.fsw_rate.total.sim_acc.Time);
%    mc_traj_data.gdn_t      = telem.gdn.seq_t;
    mc_traj_data.est_pos    = telem.est.pos;
    mc_traj_data.est_vel    = telem.est.vel;
    mc_traj_data.est_alt    = telem.est.altitude;
    mc_traj_data.est_frame  = telem.cmp.est_ref_frame;
    
    save(name_mc_pos, 'mc_traj_data') ;
%     save(name_mc_ws);

    t_elapse = toc;
    
    fprintf('-- %d out of %d (%d). Elapsed time is %4.1f seconds\n',i2mc,length(mc_i),imc, t_elapse );

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

save MC_WORKSPACE


