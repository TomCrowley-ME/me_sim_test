% sweep of thrust
% clear all

load_model stack;
stack_bus_all;

perfectNav = 0; % 0==Use noise model 1==perfect navigation

mc_prefix_s = 'lander_sensors_mc';
mc_prefix_s_pos = 'lander_sensors_pos_mc';
mc_prefix_workspace = 'lander_sensors_workspace_mc';

% set seed!
RandStream.setGlobalStream(RandStream.create('mt19937ar','seed',23))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mc_n = 1000;  % User set to total number of MC cases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% percent of range errors
percent_mean = 0/100; % Set mean to 0%
percent_variation = (0.5*0.333)/100; % Range above and below mean
percent_errors = percent_mean + percent_variation*randn(mc_n,1);

% % hardcode
percent_errors = 0.010*ones(mc_n,1);

% max acquisition range
max_range_mean = 1.0*1000; % Set mean to 1.0 km
max_range_variation = 0.333*0.1*1000; % Range above and below mean
max_ranges = abs(max_range_mean + max_range_variation*randn(mc_n,1));
%max_ranges = abs(2*max_range_mean)*randn(mc_n,1);

% hardcode
max_ranges = 2400*ones(mc_n,1);

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
delta_t_vec = 4.0*ones(mc_n,1);

% image processing delay time
min_delay_t = 0.1;
max_delay_t = 0.2;
delay_t_vec = abs(min_delay_t + (max_delay_t-min_delay_t)*rand(mc_n,1));

% % hardcode
delay_t_vec = 0.20*ones(mc_n,1);

% Normal distribution with 1 sigma position error 50/3 meters and 1.5/3 m/s                   
mc_6dof_variables=cat(2, percent_errors,...
                         max_ranges, ...
                        1.00*((28.8675/3)*randn(mc_n,1)), ...
                        1.00*((28.8675/3)*randn(mc_n,1)), ...
                        1.00*((28.8675/3)*randn(mc_n,1)), ...
                        1.00*((0.8660/3)*randn(mc_n,1)), ...
                        1.00*((0.8660/3)*randn(mc_n,1)), ...
                        1.00*((0.8660/3)*randn(mc_n,1)), ...
                        st_noise_vec, ...
                        integ_time_vec, ...
                        aov_vec, ...
                        delta_t_vec, ...
                        delay_t_vec, ...
                        1.00*sqrt(0.5*(0.01/3)^2)*randn(mc_n,1), ...
                        1.00*sqrt(0.5*(0.01/3)^2)*randn(mc_n,1), ...
                        1.00*(0.01/3)*randn(mc_n,1), ...
                        1.00*sqrt(0.5*(0.01/3)^2)*randn(mc_n,1), ...
                        1.00*sqrt(0.5*(0.01/3)^2)*randn(mc_n,1), ...
                        1.00*(0.01/3)*randn(mc_n,1)...
                        );
% and velocity error 2/3 m/s
% for icase=1:mc_n
%     mc_6dof_variables(icase,3:5) = randn(3,1)*500/3 ;
%     mc_6dof_variables(icase,6:8) = randn(3,1)*2/3 ;
% end

ivars = struct( 'rdr_percent_error',1,...
                'rdr_range_max',2,...
                'est_posx',3,'est_posy',4,'est_posz',5,...
                'est_velx',6,'est_vely',7,'est_velz',8,...
                'kfl_star_tracker_transverse_noise',9,...
                'cam_integ_time',10,...
                'cam_aov',11,...
                'cam_image_delta_t',12,...
                'cam_processing_delay',13,...
                'cgx_dry',14,'cgy_dry',15,'cgz_dry',16,...
                'cgx_wet',17,'cgy_wet',18,'cgz_wet',19,...
                'n',19);
            
mc_i=1:size(mc_6dof_variables,1);
for i2mc=1 :length(mc_i)
    tic;
    imc=mc_i(i2mc);
    name_mc=[ mc_prefix_s num2str(imc) ];
    name_mc_pos = [ mc_prefix_s_pos num2str(imc) ];
    name_mc_ws = [ mc_prefix_workspace num2str(imc) ];
    
    stack_sim_init;
    sim_set_kfl_error_state_init
    
    csc_gdn_option_select = 4; % Lambert/Terminal For Mighty Eagle    
    csc_gdn_option_select = 2; % Quadratic/Terminal Guidance
    csc_gdn_option_select = 3; % Gravity Turn/Terminal Guidance
    csc_gdn_option_select = 1; % Lambert/Terminal Guidance
  
    switch csc_gdn_option_select
    case 1
        gdn_block_name = 'csc_gdn_landing_PWPF_Lambert_Accel_Cmd';
    case 2
        gdn_block_name = 'csc_gdn_landing_PWPF_Quadratic_Accel_Cmd';
    case 3
        gdn_block_name = 'csc_gdn_landing_PWPF_GravityTurn_Accel_Cmd';
    case 4
        gdn_block_name = 'Moon_Express_Trajectory_and_Pointing_Guidance_Mighty_Eagle_Testing_Configuration';
    otherwise
        gdn_block_name = 'csc_gdn_landing_PWPF_Quadratic_Accel_Cmd';       
    end

    fprintf(1,'Using -->%s<-- for guidance\n\n',gdn_block_name)
    set_block_choice('stack/csci_fsw/csc_gdn_guidance', gdn_block_name)

    sensor_parameters;
    % %%%%%%%%%%%%%
    % Adjust here
    % %%%%%%%%%%%%%
    
        if ~isnan( mc_6dof_variables(imc,ivars.rdr_percent_error) )
            rdr_percent_error = mc_6dof_variables(imc,ivars.rdr_percent_error);
        end
        if ~isnan( mc_6dof_variables(imc,ivars.rdr_range_max) )
            rdr_range_max = mc_6dof_variables(imc,ivars.rdr_range_max);
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
            mpl_cgx_location_dry = mpl_cgx_location_dry + mc_6dof_variables(imc,ivars.cgx_dry);
        end
        if ~isnan( mc_6dof_variables(imc,ivars.cgy_dry) )
            mpl_cgy_location_dry = mpl_cgy_location_dry + mc_6dof_variables(imc,ivars.cgy_dry);
        end
        if ~isnan( mc_6dof_variables(imc,ivars.cgz_dry) )
            mpl_cgz_location_dry = mpl_cgz_location_dry + mc_6dof_variables(imc,ivars.cgz_dry);
        end
        if ~isnan( mc_6dof_variables(imc,ivars.cgx_wet) )
            mpl_cgx_location_wet = mpl_cgx_location_wet + mc_6dof_variables(imc,ivars.cgx_wet);
        end
        if ~isnan( mc_6dof_variables(imc,ivars.cgy_wet) )
            mpl_cgy_location_wet = mpl_cgy_location_wet + mc_6dof_variables(imc,ivars.cgy_wet);
        end
        if ~isnan( mc_6dof_variables(imc,ivars.cgz_wet) )
            mpl_cgz_location_wet = mpl_cgz_location_wet + mc_6dof_variables(imc,ivars.cgz_wet);
        end        
        % Stack cg (combined lander and braking stage)
        if ~isnan( mc_6dof_variables(imc,ivars.cgx_dry) )
            mps_cgx_location_dry = mps_cgx_location_dry + mc_6dof_variables(imc,ivars.cgx_dry);
        end
        if ~isnan( mc_6dof_variables(imc,ivars.cgy_dry) )
            mps_cgy_location_dry = mps_cgy_location_dry + mc_6dof_variables(imc,ivars.cgy_dry);
        end
        if ~isnan( mc_6dof_variables(imc,ivars.cgz_dry) )
            mps_cgz_location_dry = mps_cgz_location_dry + mc_6dof_variables(imc,ivars.cgz_dry);
        end
        if ~isnan( mc_6dof_variables(imc,ivars.cgx_wet) )
            mps_cgx_location_wet = mps_cgx_location_wet + mc_6dof_variables(imc,ivars.cgx_wet);
        end
        if ~isnan( mc_6dof_variables(imc,ivars.cgy_wet) )
            mps_cgy_location_wet = mps_cgy_location_wet + mc_6dof_variables(imc,ivars.cgy_wet);
        end
        if ~isnan( mc_6dof_variables(imc,ivars.cgz_wet) )
            mps_cgz_location_wet = mps_cgz_location_wet + mc_6dof_variables(imc,ivars.cgz_wet);
        end        
        
    kfl_state_init = [ kfl_position_init ; kfl_velocity_init ; kfl_acc_bias_init ;  kfl_gibbs_init ;  kfl_gyro_bias_init; kfl_landmark_init];
          
    stack_sim_prep;
    sim_set_kfl_error_state_prep
    
    sim('stack');
 
    clear mc_all_initial mc_all_final
    if ~exist('t','var')| size(t) ~= size(rtk_pos_topo,1)
        t = lns_accel.time;
        lns_accel  = lns_accel.signals.values;
    end
    
    plot_stack;
    
    save( name_mc );
    t_subsampled = t(1:10:end);
    rtk_pos_topo_subsampled = rtk_pos_topo(1:10:end,:);
    rtk_vel_topo_subsampled = rtk_vel_topo(1:10:end,:);
    propellant_used_subsampled = propellant_used(1:10:end,:);
    gdn_t_subsampled = gdn_t(1:10:end);
    est_pos_topo_subsampled = est_pos_topo(1:10:end,:);
    est_vel_topo_subsampled = est_vel_topo(1:10:end,:);
    
    save(name_mc_pos, 't_subsampled','rtk_pos_topo_subsampled','rtk_vel_topo_subsampled','propellant_used_subsampled',...
        'gdn_t_subsampled','est_pos_topo_subsampled','est_vel_topo_subsampled') ;
    save(name_mc_ws);
    
    t_elapse = toc;
    
    fprintf('-- %d out of %d (%d). Elapsed time is %4.1f seconds\n',i2mc,length(mc_i),imc, t_elapse );

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

save MC_WORKSPACE


