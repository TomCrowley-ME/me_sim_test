% clear all

load_model mtv1_with_slosh;

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

mc_prefix_s = 'mtv_acceptance_mc';
mc_prefix_s_pos = 'mtv_acceptance_pos_mc';
mc_prefix_workspace = 'mtv_acceptance_workspace_mc';

% set seed!
RandStream.setGlobalStream(RandStream.create('mt19937ar','seed',23))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mc_n = 200;  % User set to total number of MC cases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% percent of range errors
percent_mean = 0/100; % Set mean to 0%
percent_variation = (0.1)/100; % Range above and below mean (FLIR MLR 2K 0.1% at 1 km == 1 meter at 1 km)
percent_errors = percent_mean + percent_variation*rand(mc_n,1);

% % hardcode
percent_errors = 0.010*ones(mc_n,1);

% max acquisition range
max_range_mean = 1.0*5000; % Set mean to 2.5 km
max_range_variation = 5000; % Range above and below mean
max_ranges = abs(max_range_mean + max_range_variation*rand(mc_n,1));
% max_ranges = abs(2*max_range_mean)*randn(mc_n,1);

% hardcode
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

% hardcode
aov_vec = (26.2254*pi/180)*ones(mc_n,1);

% time between camera updates
min_delta_t = 0;
max_delta_t = 2;
delta_t_vec = abs(min_delta_t + (max_delta_t-min_delta_t)*rand(mc_n,1));

%hardcode
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
lateral_cm_x_dry_min =-0.000;
lateral_cm_y_dry_min =-0.000;
lateral_cm_z_dry_min = 0.000;
lateral_cm_x_dry = lateral_cm_x_dry_min + (lateral_cm_x_dry_max - lateral_cm_x_dry_min)*rand(mc_n,1);
lateral_cm_y_dry = lateral_cm_y_dry_min + (lateral_cm_y_dry_max - lateral_cm_y_dry_min)*rand(mc_n,1);
lateral_cm_z_dry = lateral_cm_z_dry_min + (lateral_cm_z_dry_max - lateral_cm_z_dry_min)*rand(mc_n,1);

% set initial HTP mass, nominally set to 29.36 kg
if exist('scenario')
    if (scenario==81)
        htp_mass_nominal = 29.36;
    elseif (scenario==88)
        htp_mass_nominal = 29.36;
    end
else
    scenario         = 81;
    htp_mass_nominal = 29.36;
end
htp_mass_min = htp_mass_nominal+0.0;
htp_mass_max = htp_mass_nominal+0.0;
htp_mass     = htp_mass_min + (htp_mass_max - htp_mass_min)*rand(mc_n,1);

% wind speed max/min - uniform distribution [m/s]
wind_speed_min   = 0.0;
wind_speed_max   = 0.0;
wind_speed       = wind_speed_min + (wind_speed_max - wind_speed_min)*rand(mc_n,1);
wind_azimuth_min = 0.0;
wind_azimuth_max = 0.0;
wind_azimuth     = wind_azimuth_min + (wind_azimuth_max - wind_azimuth_min)*rand(mc_n,1);

% wind gust speed, start time and length - uniform distribution
gust_magnitude_min = 0.0;
gust_magnitude_max = 0.0;
gust_magnitude     = gust_magnitude_min + (gust_magnitude_max - gust_magnitude_min)*rand(mc_n,1);
gust_start_min     = 20.0;
gust_start_max     = 20.0;
gust_start         = gust_start_min + (gust_start_max - gust_start_min)*rand(mc_n,1);
gust_length_min    = 10.0;
gust_length_max    = 10.0;
gust_length        = gust_length_min + (gust_length_max - gust_length_min)*rand(mc_n,1);
gust_direction_min = 0.0;
gust_direction_max = 0.0;
gust_direction     = gust_direction_min + (gust_direction_max - gust_direction_min)*rand(mc_n,1);

% set minimum fluid damping, nominally set to 0.01
constant_damping  = 0;       % 1=constant damping, 0=fill level dependant damping
fluid_damping_min = 0.01;
fluid_damping_max = 0.01;
fluid_damping     = fluid_damping_min + (fluid_damping_max - fluid_damping_min)*rand(mc_n,1);

% set peak pendulum length/tank radius ratio, nominally set to 100%
pendulum_length_min = 0.8;
pendulum_length_max = 1.2;
pendulum_length     = pendulum_length_min + (pendulum_length_max - pendulum_length_min)*rand(mc_n,1);

% set peak pendulum mass fraction, nominally set to 100%
pendulum_mass_min   = 1.0;
pendulum_mass_max   = 1.0;
pendulum_mass       = pendulum_mass_min + (pendulum_mass_max - pendulum_mass_min)*rand(mc_n,1);

% set peak hinge height/tank radius ratio, nominally set to 100%
hinge_height_min = 1.0;
hinge_height_max = 1.0;
hinge_height     = hinge_height_min + (hinge_height_max - hinge_height_min)*rand(mc_n,1);

% set tank drain efficiencies, nominally set to 100%
drain_efficiency_min = 1.0;
drain_efficiency_max = 1.0;
drain_efficiency     = drain_efficiency_min + (drain_efficiency_max - drain_efficiency_min)*rand(mc_n,4);

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
                        fluid_damping, ...
                        pendulum_length, ...
                        pendulum_mass, ...
                        hinge_height, ...
                        drain_efficiency, ...
                        wind_speed, ...
                        wind_azimuth, ...
                        gust_magnitude, ...
                        gust_start, ...
                        gust_length, ...
                        gust_direction ...
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
                'fluid_damping',71,...
                'pendulum_length',72,'pendulum_mass',73,...
                'hinge_height',74,...
                'drain_efficiency',[75:78],...
                'wind_speed',79,'wind_azimuth',80,...
                'gust_magnitude',81,'gust_start',82,...
                'gust_length',83,'gust_direction',84,...
                'n',84);
            
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

    imh_accel_noise_on      = 0;  % 1 - ON, 0 - OFF
    imh_gyro_noise_on       = 0;  % 1 - ON, 0 - OFF
    imh_accel_bias_noise_on = 0;  % 1 - ON, 0 - OFF
    imh_gyro_bias_noise_on  = 0;  % 1 - ON, 0 - OFF

% set MEMS IMU seeds
% MEM 1
    mum1_accel_noise_seed = [ fix(rand*1000) fix(rand*1000) fix(rand*1000)];
    mum1_accel_bias_seed  = [ fix(rand*1000) fix(rand*1000) fix(rand*1000)];
    mum1_gyro_noise_seed  = [ fix(rand*1000) fix(rand*1000) fix(rand*1000)];
    mum1_gyro_bias_seed   = [ fix(rand*1000) fix(rand*1000) fix(rand*1000)];
    
%-------------------------------------------------------------------------%
% MEM 2
    mum2_accel_noise_seed = [ fix(rand*1000) fix(rand*1000) fix(rand*1000)];
    mum2_accel_bias_seed  = [ fix(rand*1000) fix(rand*1000) fix(rand*1000)];
    mum2_gyro_noise_seed  = [ fix(rand*1000) fix(rand*1000) fix(rand*1000)];
    mum2_gyro_bias_seed   = [ fix(rand*1000) fix(rand*1000) fix(rand*1000)];
    
%-------------------------------------------------------------------------%
% MEM 3
    mum3_accel_noise_seed = [ fix(rand*1000) fix(rand*1000) fix(rand*1000)];
    mum3_accel_bias_seed  = [ fix(rand*1000) fix(rand*1000) fix(rand*1000)];
    mum3_gyro_noise_seed  = [ fix(rand*1000) fix(rand*1000) fix(rand*1000)];
    mum3_gyro_bias_seed   = [ fix(rand*1000) fix(rand*1000) fix(rand*1000)];

% set mIRU IMU seeds
    mhn_gyro_seed_v       = [fix(rand*1000), fix(rand*1000), fix(rand*1000)];
    mhn_gyro_bias_seed_v  = [fix(rand*1000), fix(rand*1000), fix(rand*1000)];
    mhn_accel_seed_v      = [fix(rand*1000), fix(rand*1000), fix(rand*1000),...
                             fix(rand*1000), fix(rand*1000), fix(rand*1000),...
                             fix(rand*1000), fix(rand*1000)];
    mhn_accel_bias_seed_v = [fix(rand*1000), fix(rand*1000), fix(rand*1000),...
                             fix(rand*1000), fix(rand*1000), fix(rand*1000),...
                             fix(rand*1000), fix(rand*1000)];

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

        % set drain efficiencies
        mpl_htp_drain_efficiency_tank1 = mc_6dof_variables(imc,ivars.drain_efficiency(1));
        mpl_htp_drain_efficiency_tank2 = mc_6dof_variables(imc,ivars.drain_efficiency(2));
        mpl_htp_drain_efficiency_tank3 = 1.0;
        mpl_htp_drain_efficiency_tank4 = 1.0;

        % uncomment this section to set fluid damping,
        % uses flag constant_damping to use either 1=constant or 0=fill level dependant damping 
        if ~isnan( mc_6dof_variables(imc,ivars.fluid_damping) )
            if constant_damping
                SloshData.fluid_damping  = mc_6dof_variables(imc,ivars.fluid_damping) * ones(size(SloshData.fill_fraction));
            else
                SloshData.fluid_damping  = mc_6dof_variables(imc,ivars.fluid_damping) * SloshData.fluid_damping / min(SloshData.fluid_damping);              
            end
        end

        % uncomment this section to set pendulum length at 0% fill level, 
        % lengths linearly interpolated to zero at 100% fill
        if ~isnan( mc_6dof_variables(imc,ivars.pendulum_length) )
            SloshData.pendulum_length      = mc_6dof_variables(imc,ivars.pendulum_length) * mpl_htp_tank_radius * (ones(size(SloshData.fill_fraction))-SloshData.fill_fraction);
            SloshData.pendulum_length(end) = 1e-6;
            SloshData.pendulum_length      = mc_6dof_variables(imc,ivars.pendulum_length) * SloshData.pendulum_length;
        end

        % uncomment this section to set maximum pendulum mass fraction
        % masses interpolated to zero at 0% and 100% fill levels
        if ~isnan( mc_6dof_variables(imc,ivars.pendulum_mass) )
            SloshData.pendulum_mass     = mc_6dof_variables(imc,ivars.pendulum_mass) * SloshData.pendulum_mass / max(SloshData.pendulum_mass);
        end

        % uncomment this section to set hinge height at 0% fill level,
        if ~isnan( mc_6dof_variables(imc,ivars.hinge_height) )
            SloshData.hinge_height  = mc_6dof_variables(imc,ivars.hinge_height) * SloshData.hinge_height;
        end

        if ~isnan( mc_6dof_variables(imc,ivars.wind_speed) )
            Winds.Speed.Lateral = mc_6dof_variables(imc,ivars.wind_speed)*ones(length(Winds.Altitude),1);
        end
        if ~isnan( mc_6dof_variables(imc,ivars.wind_azimuth) )
            Winds.Azimuth = mc_6dof_variables(imc,ivars.wind_azimuth)*ones(length(Winds.Altitude),1);
        end
        if ~isnan( mc_6dof_variables(imc,ivars.gust_magnitude) )
            afm_gust_magnitude = mc_6dof_variables(imc,ivars.gust_magnitude);
        end
        if ~isnan( mc_6dof_variables(imc,ivars.gust_start) )
            afm_gust_start  = mc_6dof_variables(imc,ivars.gust_start);
         end
        if ~isnan( mc_6dof_variables(imc,ivars.gust_length) )
            afm_gust_length = mc_6dof_variables(imc,ivars.gust_length);
        end
        if ~isnan( mc_6dof_variables(imc,ivars.gust_direction) )
            afm_gust_direction = mc_6dof_variables(imc,ivars.gust_direction);
        end
                      
        kfl_state_init = [ kfl_position_init ; kfl_velocity_init ; kfl_acc_bias_init ;  kfl_gibbs_init ;  kfl_gyro_bias_init];
                              
    sim_set_kfl_error_state_prep

    sim('mtv1_with_slosh');
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
    mc_traj_data.cg         = truth.sim.cg;

    save(name_mc_pos, 'mc_traj_data') ;
%     save(name_mc_ws);
    
    t_elapse = toc;
    
    fprintf('-- %d out of %d (%d). Elapsed time is %4.1f seconds\n',i2mc,length(mc_i),imc, t_elapse );

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

save MC_WORKSPACE


