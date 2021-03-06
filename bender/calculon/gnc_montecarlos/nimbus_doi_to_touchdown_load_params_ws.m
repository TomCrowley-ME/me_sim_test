% clear all
 
load_model nimbus;

%-------------------------------------------------------------------------%
% define mission type: "micro", "1", "2"
mission_type='micro';
if strcmp(mission_type,'1')
  htp_mass_nominal = 176.05;
  rp1_mass_nominal = 19.0;
  gn2_mass_nominal = 0.5;
else
  mpl_mass_dry          = 38.0;
  mpl_mass_dry          = 29.0; % 10-02-15 Bud Fraze
  mpl_mass_fillfrac_100 = 110.0;
  mpl_mass_fillfrac_100 = 117.04; % 10-02-15 Bud Fraze
  mpl_mass_fillfrac_0   = mpl_mass_dry;
  mpl_cgz_location_fillfrac_0   = 0.20;
  mpl_cgz_location_fillfrac_100 = 0.09;
  mpl_htp_mass_initial  = 39.7059+14.2133;
  mpl_rp1_mass_initial  = 5.2941+2.1867;  
  emp_mass_fillfrac_100 = mpl_mass_fillfrac_100;
  emp_mass_fillfrac_0   = mpl_mass_fillfrac_0;
  htp_mass_nominal =mpl_htp_mass_initial;
  rp1_mass_nominal =mpl_rp1_mass_initial ;
  gn2_mass_nominal = 0.2;
end

%-------------------------------------------------------------------------%
% define reference frame for estimation error dispersions: "VNC", "LVLH", "RVN"
est_err_frame_type='VNC';

%-------------------------------------------------------------------------%
% define nonvirtual buses
nimbus_bus_all;
nimbus_commands_all;
 
%-------------------------------------------------------------------------%
% initialize global parameters & set planet
gbl_global_parameters_init;
central_body_name = 'moon';
set_central_body;
 
%-------------------------------------------------------------------------%
% set the stop time of the simulation
sim_stop_time = 4300;
 
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
% simulation init (sets initial conditions and calls FSW init files)
ini_j2000_or_topo = 1; % initialize to J2000 == 1
est_j2000_or_topo = 3; % initialize to deorbit state position, velocity knowledge errors
est_j2000_or_topo = 0; % initialize to deorbit state position, velocity knowledge errors
 
mc_prefix_s         = 'doi_to_touchdown_mc';
mc_prefix_s_pos     = 'doi_to_touchdown_pos_mc';
mc_prefix_workspace = 'doi_to_touchdown_workspace_mc';
 
% set seed!
RandStream.setGlobalStream(RandStream.create('mt19937ar','seed',14))
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mc_n = 100;  % User set to total number of MC cases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% percent of range errors
percent_mean = 1/100; % Set mean to 0%
percent_variation = (0.1)/100; % Range above and below mean (FLIR MLR 2K 0.1% at 1 km == 1 meter at 1 km)
percent_errors = percent_mean + percent_variation*rand(mc_n,1);
 
% % hardcode
% percent_errors = 0.001*ones(mc_n,1);
 
% max acquisition range
max_range_mean = 1.0*15000; % Set mean to 15 km
max_range_variation = 500; % Range above and below mean
sigma = max_range_variation/3;
max_ranges = abs(max_range_mean + sigma*randn(mc_n,1));
% max_ranges = abs(2*max_range_mean)*randn(mc_n,1);
 
% hardcode
%max_ranges = 15000*ones(mc_n,1);
 
% star tracker transverse noise (in arcsecond)
min_st_noise = 0;
max_st_noise = 50;
st_noise_vec = abs(min_st_noise + (max_st_noise-min_st_noise)*rand(mc_n,1));
 
% % hardcode
% st_noise_vec = 9*ones(mc_n,1);
 
% camera integration time (used in blur noise factor)
min_integ_time =  5/ 1000;
max_integ_time = 15/ 1000;
integ_time_vec = abs(min_integ_time + (max_integ_time-min_integ_time)*rand(mc_n,1));
 
% % hardcode
% integ_time_vec = 0.010*ones(mc_n,1);
 
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
% delta_t_vec = 0.1*ones(mc_n,1);
 
% image processing delay time
min_delay_t = 0.1;
max_delay_t = 0.2;
delay_t_vec = abs(min_delay_t + (max_delay_t-min_delay_t)*rand(mc_n,1));
 
% % hardcode
%delay_t_vec = 0.25*ones(mc_n,1);
 
% total lateral cm dry - normal distribution
% lateral_cm_dry_sigma = 0.000;
% lateral_cm_dry_sigma = 0.004;
% lateral_cm_x_dry = 1.0*sqrt(0.5*lateral_cm_dry_sigma^2)*randn(mc_n,1);
% lateral_cm_y_dry = 1.0*sqrt(0.5*lateral_cm_dry_sigma^2)*randn(mc_n,1);
% lateral_cm_z_dry = 1.0*(0.01/3)*randn(mc_n,1);
 
% total lateral cm dry - uniform distribution
lateral_cm_x_dry_max =  0.005;
lateral_cm_y_dry_max =  0.005;
longitudinal_cm_z_dry_max =  0.005;
lateral_cm_x_dry_min = -0.005;
lateral_cm_y_dry_min = -0.005;
longitudinal_cm_z_dry_min = -0.005;
lateral_cm_x_dry = (lateral_cm_x_dry_max - lateral_cm_x_dry_min)/3*randn(mc_n,1);
lateral_cm_y_dry = (lateral_cm_y_dry_max - lateral_cm_y_dry_min)/3*randn(mc_n,1);
longitudinal_cm_z_dry = (longitudinal_cm_z_dry_max - longitudinal_cm_z_dry_min)/3*randn(mc_n,1);
 
% set initial HTP mass
htp_mass_min = htp_mass_nominal-0.1;
htp_mass_max = htp_mass_nominal+0.1;
mid=(htp_mass_max+htp_mass_min)/2;sigma=(htp_mass_max-htp_mass_min)/3;
htp_mass     =  mid+sigma*randn(mc_n,1);                                     % normal  distribution
% htp_mass     = htp_mass_min + (htp_mass_max - htp_mass_min)*rand(mc_n,1);  % uniform distribution
 
% set initial RP1 mass
rp1_mass_min = rp1_mass_nominal-0.1;
rp1_mass_max = rp1_mass_nominal+0.1;
mid=(rp1_mass_max+rp1_mass_min)/2;sigma=(rp1_mass_max-rp1_mass_min)/3;
rp1_mass     =  mid+sigma*randn(mc_n,1);                                     % normal  distribution
% rp1_mass     = rp1_mass_min + (rp1_mass_max - rp1_mass_min)*rand(mc_n,1);  % uniform distribution
 
% set initial GN2 mass
gn2_mass_min = gn2_mass_nominal-0.01;
gn2_mass_max = gn2_mass_nominal+0.01;
mid=(gn2_mass_max+gn2_mass_min)/2;sigma=(gn2_mass_max-gn2_mass_min)/3;
gn2_mass     =  mid+sigma*randn(mc_n,1);                                     % normal  distribution
% gn2_mass     = gn2_mass_min + (gn2_mass_max - gn2_mass_min)*rand(mc_n,1);  % uniform distribution
 
% set random misalignment angles and azimuth angles for 25 thrusters
misalignment_ang_deg_3sigma = 0.1;
 
for i=1:27
    azimuth_ang(1:mc_n,i) = 360*rand(mc_n,1);
    misalignment_ang(1:mc_n,i) = misalignment_ang_deg_3sigma/3*randn(mc_n,1);
end
 
% set monoprop thrust scale factor, nominally set to 1
monoprop_thrust_min = 0.997;
monoprop_thrust_max = 1.003;
% monoprop_thrust     = monoprop_thrust_min + (monoprop_thrust_max - monoprop_thrust_min)*rand(mc_n,1);
mid=(monoprop_thrust_max+monoprop_thrust_min)/2;sigma=(monoprop_thrust_max-monoprop_thrust_min)/3;
monoprop_thrust     =  mid+sigma*randn(mc_n,1);
 
% set monoprop Isp scale factor, nominally set to 1
monoprop_isp_min = 0.997;
monoprop_isp_max = 1.003;
% monoprop_isp     = monoprop_isp_min + (monoprop_isp_max - monoprop_isp_min)*rand(mc_n,1);
mid=(monoprop_isp_max+monoprop_isp_min)/2;sigma=(monoprop_isp_max-monoprop_isp_min)/3;
monoprop_isp     =  mid+sigma*randn(mc_n,1);
 
% set biprop thrust scale factor, nominally set to 1
biprop_thrust_min = 0.997;
biprop_thrust_max = 1.003;
% biprop_thrust     = biprop_thrust_min + (biprop_thrust_max - biprop_thrust_min)*rand(mc_n,1);
mid=(biprop_thrust_max+biprop_thrust_min)/2;sigma=(biprop_thrust_max-biprop_thrust_min)/3;
biprop_thrust     =  mid+sigma*randn(mc_n,1);
 
% set biprop Isp scale factor, nominally set to 1
biprop_isp_min = 0.950;
biprop_isp_max = 1.000;
% biprop_isp     = biprop_isp_min + (biprop_isp_max - biprop_isp_min)*rand(mc_n,1);
mid=(biprop_isp_max+biprop_isp_min)/2;sigma=(biprop_isp_max-biprop_isp_min)/3;
biprop_isp     =  mid+sigma*randn(mc_n,1);
 
% set mass estimate bias, nominally set to 0
mass_estimate_bias_min = -0.001;
mass_estimate_bias_max =  0.001;
% mass_estimate_bias     = mass_estimate_bias_min + (mass_estimate_bias_max - mass_estimate_bias_min)*rand(mc_n,1);
mid=(mass_estimate_bias_max+mass_estimate_bias_min)/2;sigma=(mass_estimate_bias_max-mass_estimate_bias_min)/3;
mass_estimate_bias     =  mid+sigma*randn(mc_n,1);
 
% set biprop burn start delay, scale factor, nominally set to 0
biprop_start_delay_min = 0.950;
biprop_start_delay_max = 1.050;
sigma=(biprop_start_delay_max-biprop_start_delay_min)/3;
biprop_start_delay     = abs(sigma*randn(mc_n,1));
 
% set biprop stop delay, msec, nominally set to 0
biprop_stop_delay_min = 0.950;
biprop_stop_delay_max = 1.050;
sigma=(biprop_stop_delay_max-biprop_stop_delay_min)/3;
biprop_stop_delay     = abs(sigma*randn(mc_n,1));

% set position estimation errors in radial, velocity and orbit normal directions, meters
pos_est_err_3sigma_rhat = 10.0;
pos_est_err_3sigma_vhat = 1000.0;
pos_est_err_3sigma_nhat = 10.0;
% select DCM
if strcmp(est_err_frame_type,'VNC')
    pos_est_err = randn(mc_n,3).*(ones(mc_n,1)*[pos_est_err_3sigma_vhat pos_est_err_3sigma_nhat pos_est_err_3sigma_rhat]/3);
elseif strcmp(est_err_frame_type,'LVLH')
    pos_est_err = randn(mc_n,3).*(ones(mc_n,1)*[pos_est_err_3sigma_vhat pos_est_err_3sigma_nhat pos_est_err_3sigma_rhat]/3);
else
    pos_est_err = randn(mc_n,3).*(ones(mc_n,1)*[pos_est_err_3sigma_rhat pos_est_err_3sigma_vhat pos_est_err_3sigma_nhat]/3);
end

% set velocity estimation errors in radial, velocity and orbit normal directions, meters/sec
vel_est_err_3sigma_rhat = 0.5;
vel_est_err_3sigma_vhat = 0.5;
vel_est_err_3sigma_nhat = 0.5;
if strcmp(est_err_frame_type,'VNC')
    vel_est_err = randn(mc_n,3).*(ones(mc_n,1)*[vel_est_err_3sigma_vhat vel_est_err_3sigma_nhat vel_est_err_3sigma_rhat]/3);
elseif strcmp(est_err_frame_type,'LVLH')
    vel_est_err = randn(mc_n,3).*(ones(mc_n,1)*[vel_est_err_3sigma_vhat vel_est_err_3sigma_nhat vel_est_err_3sigma_rhat]/3);
else
    vel_est_err = randn(mc_n,3).*(ones(mc_n,1)*[vel_est_err_3sigma_rhat vel_est_err_3sigma_vhat vel_est_err_3sigma_nhat]/3);
end

% define Monte Carlo initialization structure
mc_6dof_variables=cat(2,percent_errors,...
                                        max_ranges, ...
                                        pos_est_err, ...
                                        vel_est_err, ...
                                        st_noise_vec, ...
                                        integ_time_vec, ...
                                        aov_vec, ...
                                        delta_t_vec, ...
                                        delay_t_vec, ...
                                        lateral_cm_x_dry, ...
                                        lateral_cm_y_dry, ...
                                        longitudinal_cm_z_dry, ...
                                        azimuth_ang,...
                                        misalignment_ang,...
                                        htp_mass, ...
                                        rp1_mass, ...
                                        gn2_mass, ...
                                        monoprop_isp, ...
                                        monoprop_thrust, ...
                                        biprop_thrust, ...
                                        biprop_isp, ...
                                        biprop_start_delay, ...
                                        biprop_stop_delay, ...
                                        mass_estimate_bias ...
                                        );

% define indexes to Monte Carlo initialization variables
ivars = struct( 'percent_error',1,...
                        'range_max',2,...
                        'pos_est_err',[3:5],...
                        'vel_est_err',[6:8],...
                        'st_noise',9,...
                        'cam_integ_time',10,...
                        'cam_aov',11,...
                        'cam_image_delta_t',12,...
                        'cam_processing_delay',13,...
                        'cgx_dry',14,'cgy_dry',15,'cgz_dry',16,...
                        'azimuth',[17:43],...
                        'misalignment',[44:70],...
                        'htp_mass',71,'rp1_mass',72,'gn2_mass',73,...
                        'monoprop_thrust',74,'monoprop_isp',75,...
                        'biprop_thrust',76,'biprop_isp',77,...
                        'biprop_start_delay',78,'biprop_stop_delay',79,...
                        'mass_estimate_bias',80,...
                        'n',80);
            
mc_i = 1 : size(mc_6dof_variables,1);
 
save MC_WORKSPACE
 
for i2mc = 1 : 1
    tic;
    imc = mc_i(i2mc);
    name_mc = [ mc_prefix_s num2str(imc) ];
    name_mc_pos = [ mc_prefix_s_pos num2str(imc) ];
    name_mc_ws = [ mc_prefix_workspace num2str(imc) ];
    
    nimbus_sim_init;
 
    % Load the scenario
    fprintf('Scenario 3 loaded, for MX-%s\n',mission_type)
    load_scenario('scenario_3','nimbus');
    scn3_guidance_tables;
 
    sensor_parameters;
 
    %----------------------------------------------------------------------%
    % simulation prep (acts on scenario speecific initial conditions )
    nimbus_sim_prep;
    
    %- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - - -%
    % set error state on Kalman filter state wrt true position, in inertial frame
    sim_set_kfl_error_state_init
    %- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - - -%
 
%     mhn_accel_noise_on      = 1;  % 1 - ON, 0 - OFF
%     mhn_gyro_noise_on       = 1;  % 1 - ON, 0 - OFF
%     mhn_accel_bias_noise_on = 1;  % 1 - ON, 0 - OFF
%     mhn_gyro_bias_noise_on  = 1;  % 1 - ON, 0 - OFF
 
    % %%%%%%%%%%%%%
    % Adjust here
    % %%%%%%%%%%%%%
 
        if ~isnan( mc_6dof_variables(imc,ivars.percent_error) )
            flr_15k_percent_error = mc_6dof_variables(imc,ivars.percent_error);
        end
        if ~isnan( mc_6dof_variables(imc,ivars.range_max) )
            flr_15k_range_max = mc_6dof_variables(imc,ivars.range_max);
        end
        
        % radial, velocity, orbit normal, co-normal and local horizontal frame basis vectors
        rhat=ini_position_v/norm(ini_position_v);
        vhat=ini_velocity_v/norm(ini_velocity_v);
        nhat=cross(rhat,vhat)/norm(cross(rhat,vhat));
        chat=cross(vhat,nhat)/norm(cross(vhat,nhat));
        hhat=cross(nhat,rhat)/norm(cross(nhat,rhat));

        % radial, velocity, orbit normal to inertial frame DCM
        rvn2eci=[rhat; vhat; nhat]';
        % VNC to inertial frame DCM
        vnc2eci=[vhat; nhat; chat]';
        % LVLH to inertial frame DCM
        % lvlh2eci=[rhat; hhat; nhat]';
        lvlh2eci=[hhat; nhat; rhat]';

        % select DCM
        if strcmp(est_err_frame_type,'VNC')
          DCM = vnc2eci;
        elseif strcmp(est_err_frame_type,'LVLH')
          DCM = lvlh2eci;
        else
          DCM = rvn2eci;
        end

        % initial position and velocity estimates in ECI frame
        if ~isnan( mc_6dof_variables(imc,ivars.pos_est_err) )
            kfl_position_init = ini_position_v' + DCM*mc_6dof_variables(imc,ivars.pos_est_err)';
        end
        if ~isnan( mc_6dof_variables(imc,ivars.vel_est_err) )
            kfl_velocity_init = ini_velocity_v' + DCM*mc_6dof_variables(imc,ivars.vel_est_err)';
        end

        if ~isnan( mc_6dof_variables(imc,ivars.st_noise) )
            sta_angle_std = mc_6dof_variables(imc,ivars.st_noise)*(pi/180)/3600;
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
 
        % Lander CG
        if ~isnan( mc_6dof_variables(imc,ivars.cgx_dry) )
            mpl_cgx_location_fillfrac_0 = mpl_cgx_location_fillfrac_0 + mc_6dof_variables(imc,ivars.cgx_dry);
        end
        if ~isnan( mc_6dof_variables(imc,ivars.cgy_dry) )
            mpl_cgy_location_fillfrac_0 = mpl_cgy_location_fillfrac_0 + mc_6dof_variables(imc,ivars.cgy_dry);
        end
        if ~isnan( mc_6dof_variables(imc,ivars.cgz_dry) )
            mpl_cgz_location_fillfrac_0 = mpl_cgz_location_fillfrac_0 + mc_6dof_variables(imc,ivars.cgz_dry);
        end
 
        % initial htp,rp1,gn2 masses
        if ~isnan( mc_6dof_variables(imc,ivars.htp_mass) )
            mpl_htp_mass_initial  = mc_6dof_variables(imc,ivars.htp_mass);
        end
        if ~isnan( mc_6dof_variables(imc,ivars.rp1_mass) )
            mpl_rp1_mass_initial  = mc_6dof_variables(imc,ivars.rp1_mass);
        end
        if ~isnan( mc_6dof_variables(imc,ivars.gn2_mass) )
            mpl_gn2_mass_initial  = mc_6dof_variables(imc,ivars.gn2_mass);
        end

        % set dry/wet mass nominal values based on mission type
        if strcmp(mission_type,'1')
          htp_mass_nominal = 176.05;
          rp1_mass_nominal = 19.0;
          gn2_mass_nominal = 0.5;
          mpl_mass_fillfrac_0   = mpl_mass_dry;
          emp_mass_fillfrac_100 = mpl_mass_fillfrac_100;
          emp_mass_fillfrac_0   = mpl_mass_fillfrac_0;
        else
          mpl_mass_dry          = 38.0;
          mpl_mass_dry          = 29.0; % 10-02-15 Bud Fraze
          mpl_mass_fillfrac_100 = 110.0;
          mpl_mass_fillfrac_100 = 117.04; % 10-02-15 Bud Fraze
          mpl_mass_fillfrac_0   = mpl_mass_dry;
          mpl_cgz_location_fillfrac_0   = 0.20;
          mpl_cgz_location_fillfrac_100 = 0.09;
          mpl_htp_mass_initial  = 39.7059+14.2133;
          mpl_rp1_mass_initial  = 5.2941+2.1867;  
          emp_mass_fillfrac_100 = mpl_mass_fillfrac_100;
          emp_mass_fillfrac_0   = mpl_mass_fillfrac_0;
          htp_mass_nominal =mpl_htp_mass_initial;
          rp1_mass_nominal =mpl_rp1_mass_initial ;
          gn2_mass_nominal = 0.2;
        end

        csu_mpl_mass_properties_lander_prep

        % mass estimate bias
        mass_estimate_bias_per_case = mc_6dof_variables(imc,ivars.mass_estimate_bias);
        if ~isnan( mc_6dof_variables(imc,ivars.mass_estimate_bias) )
            emp_mass_fillfrac_100 = emp_mass_fillfrac_100 + mc_6dof_variables(imc,ivars.mass_estimate_bias);
            emp_mass_fillfrac_0   = emp_mass_fillfrac_0   + mc_6dof_variables(imc,ivars.mass_estimate_bias);
        end
        emp_initial_fuel_used = emp_mass_fillfrac_100 - emp_mass_fillfrac_0 - mpl_htp_mass_initial - mpl_rp1_mass_initial - mpl_gn2_mass_initial;

        csc_emp_est_mass_props_prep
 
        % thruster misalignment
        if ~isnan( mc_6dof_variables(imc,ivars.azimuth))
         if ~isnan( mc_6dof_variables(imc,ivars.misalignment))
           
                az_ang_per_case = mc_6dof_variables(imc,ivars.azimuth);
                misalignments_per_case = mc_6dof_variables(imc,ivars.misalignment);
                if abs(misalignments_per_case) > 1e-6
                   thr_misalignment_populator
                end
         end
        end

        % set main engine nominal values based on mission type
        if strcmp(mission_type,'1')
          tdl_main_biprop_thrust = 2224.11081;
          tpl_main_biprop_isp    = 310.0;
          tpl_rp1_to_htp_ratio   = 1/9;
        elseif strcmp(mission_type,'micro')
          tdl_main_biprop_thrust = 1112.0;
          tdl_main_biprop_thrust = 445.0;
          tpl_main_biprop_isp    = 310.0;
          tpl_rp1_to_htp_ratio   = 1/7.5;
        end
        % main engine thrust and Isp performance
        % monoprop
        if ~isnan( mc_6dof_variables(imc,ivars.monoprop_thrust) )
            tdl_main_mono_thrust = mc_6dof_variables(imc,ivars.monoprop_thrust)*tdl_main_mono_thrust;
        end
        if ~isnan( mc_6dof_variables(imc,ivars.monoprop_isp) )
            tpl_main_monoprop_isp = mc_6dof_variables(imc,ivars.monoprop_isp)*tpl_main_monoprop_isp;
        end
        % biprop
        if ~isnan( mc_6dof_variables(imc,ivars.biprop_thrust) )
            tdl_main_biprop_thrust = mc_6dof_variables(imc,ivars.biprop_thrust)*tdl_main_biprop_thrust;
        end
        if ~isnan( mc_6dof_variables(imc,ivars.biprop_isp) )
            tpl_main_biprop_isp   = mc_6dof_variables(imc,ivars.biprop_isp)*tpl_main_biprop_isp;
        end
        csu_tdl_thruster_dynamics_lander_prep
        csu_tpl_thruster_propellant_lander_prep
 
        % biprop start delay
        if ~isnan( mc_6dof_variables(imc,ivars.biprop_start_delay) )
            tdl_main_engine_start_delay = mc_6dof_variables(imc,ivars.biprop_start_delay)*tdl_main_engine_start_delay;
        end
 
        % biprop stop delay
        if ~isnan( mc_6dof_variables(imc,ivars.biprop_stop_delay) )
            tdl_main_engine_stop_delay = mc_6dof_variables(imc,ivars.biprop_stop_delay)*tdl_main_engine_stop_delay;
        end
         
        kfl_state_init = [ kfl_position_init ; kfl_velocity_init ; kfl_acc_bias_init ;  kfl_gibbs_init ;  kfl_gyro_bias_init];
                              
    sim_set_kfl_error_state_prep
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

 
 

