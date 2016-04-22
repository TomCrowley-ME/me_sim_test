function mcall=extract_mcall_initial_from_workspace_nimbus( file_index, truth, telem, error )

i = nimbus_index_mcall_initial;

tFSW = telem.est.local_pos.Time;
ibeginning = (tFSW<1);

mcall = zeros(1,i.n);

%-------------------------------------------------------------------------%
% telemetry items

mcall(i.file_index)             = file_index;
mcall(i.est_pos_err)            = error.knowledge.total.pos.Data(1,:);
mcall(i.est_vel_err)            = error.knowledge.total.vel.Data(1,:);

mcall(i.est_angles_xyz_err)     = mean( error.knowledge.total.euler.Data(ibeginning,:) );
mcall(i.est_rates_dps_err)      = error.knowledge.total.rate.Data(49,:) * 180/pi;
mcall(i.mass)                   = truth.sim.mass.Data(1)';

%-------------------------------------------------------------------------%
% sim configuration items

mcall(i.flr_15k_percent_error)   = evalin('base','flr_15k_percent_error');
mcall(i.flr_15k_range_max)       = evalin('base','flr_15k_range_max');
mcall(i.st_noise)               = evalin('base','sta_angle_std');
mcall(i.cam_integ_time)         = evalin('base','cam_integ_time');
mcall(i.cam_focal_length_f)     = evalin('base','cam_focal_length_f');
mcall(i.cam_aov)                = evalin('base','cam_aov');
mcall(i.cam_image_delta_t)      = evalin('base','cam_image_delta_t');
mcall(i.cam_processing_delay)   = evalin('base','cam_processing_delay');

mcall(i.cgx_dry)                = evalin('base','mpl_cgx_location_fillfrac_0');
mcall(i.cgy_dry)                = evalin('base','mpl_cgy_location_fillfrac_0');
mcall(i.cgz_dry)                = evalin('base','mpl_cgz_location_fillfrac_0');
mcall(i.cgx_wet)                = evalin('base','truth.sim.cg.Data(2,1)');
mcall(i.cgy_wet)                = evalin('base','truth.sim.cg.Data(2,2)');
mcall(i.cgz_wet)                = evalin('base','truth.sim.cg.Data(2,3)');
mcall(i.azimuth)                = evalin('base','az_ang_per_case');
mcall(i.misalignment)           = evalin('base','misalignments_per_case');

mcall(i.monoprop_thrust)        = evalin('base','tdl_main_mono_thrust');
mcall(i.monoprop_isp)           = evalin('base','tpl_main_monoprop_isp');
mcall(i.biprop_thrust)          = evalin('base','tdl_main_biprop_thrust');
mcall(i.biprop_isp)             = evalin('base','tpl_main_biprop_isp');
mcall(i.biprop_start_delay)     = evalin('base','tdl_main_engine_start_delay');
mcall(i.biprop_stop_delay)      = evalin('base','tdl_main_engine_stop_delay');
mcall(i.mass_estimate_bias)     = evalin('base','mass_estimate_bias_per_case');

mcall(i.htp_mass)               = evalin('base','mpl_htp_mass_initial');
mcall(i.rp1_mass)               = evalin('base','mpl_rp1_mass_initial');
mcall(i.gn2_mass)               = evalin('base','mpl_gn2_mass_initial');





