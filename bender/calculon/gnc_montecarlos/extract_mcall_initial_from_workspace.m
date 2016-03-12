function mcall=extract_mcall_initial_from_workspace( file_index, truth, telem, error )

i = index_mcall_initial;

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

mcall(i.ldr_2k_percent_error)   = evalin('base','ldr_2k_percent_error');
mcall(i.ldr_2k_max_range)       = evalin('base','ldr_2k_range_max');
mcall(i.st_noise)   = evalin('base','sta_angle_std');
mcall(i.cam_integ_time)         = evalin('base','cam_integ_time');
mcall(i.cam_focal_length_f)     = evalin('base','cam_focal_length_f');
mcall(i.cam_aov)                = evalin('base','cam_aov');
mcall(i.cam_image_delta_t)      = evalin('base','cam_image_delta_t');
mcall(i.cam_processing_delay)   = evalin('base','cam_processing_delay');


mcall(i.cgx_dry)                = evalin('base','mpl_cgx_dry');
mcall(i.cgy_dry)                = evalin('base','mpl_cgy_dry');
mcall(i.cgz_dry)                = evalin('base','mpl_cgz_dry');
mcall(i.cgx_wet)                = evalin('base','truth.sim.cg.Data(1,1)');
mcall(i.cgy_wet)                = evalin('base','truth.sim.cg.Data(1,2)');
mcall(i.cgz_wet)                = evalin('base','truth.sim.cg.Data(1,3)'); 
mcall(i.azimuth)                = evalin('base','az_ang_per_case');
mcall(i.misalignment)           = evalin('base','misalignments_per_case');

mcall(i.htp_mass)               = evalin('base','mpl_htp_mass_initial');
