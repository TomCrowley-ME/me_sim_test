function mcall = extract_mcall_final_from_workspace_nimbus( file_index, truth, telem, error )

i = nimbus_index_mcall_final;

%-------------------------------------------------------------------------%
% derive values

tFSW = telem.est.local_pos.Time;

mass = resample(truth.sim.mass, tFSW);
thr_thruster_forces_body = resample(truth.sim.thruster_forces, tFSW);

% act_fIn = zeros( size(thr_thruster_forces_body.Data) );
% for jj = 1 : length(act_fIn)
%     cI2B = angle2dcm(   truth.fsw_rate.sim_euler.Data(jj,3)*pi/180,...
%                         truth.fsw_rate.sim_euler.Data(jj,2)*pi/180,...
%                         truth.fsw_rate.sim_euler.Data(jj,1)*pi/180,...
%                         'zyx');
%     act_fIn(jj,:) = (cI2B'*thr_thruster_forces_body.Data(jj,:)')';
% end

act_f_n = normrows(thr_thruster_forces_body.Data);

[istart1burn, istop1burn, istart2burn] = extractBurnPoints( act_f_n );

if ~isempty(find( all( abs(truth.fsw_rate.topo.sim_vel.Data) < 1e-6, 2),1)) && ~isempty(find( all( abs(truth.sim.vel_topo.Data) < 1e-6, 2),1)-1)
    touchdown_est_initial = find( all( abs(truth.fsw_rate.topo.sim_vel.Data) < 1e-6, 2),1)-1;
    touchdown_initial = find( all( abs(truth.sim.vel_topo.Data) < 1e-6, 2),1)-1;
else
    touchdown_est_initial = 0;
    touchdown_initial = 0;
end

if touchdown_est_initial == 0 || touchdown_initial == 0
    touchdown_est = size(truth.fsw_rate.topo.sim_vel.Time,1);
    touchdown = size(truth.sim.vel_topo.Time,1);
else
    touchdown_est = find( all( abs(truth.fsw_rate.topo.sim_vel.Data) < 1e-6, 2),1)-1;
    touchdown = find( all( abs(truth.sim.vel_topo.Data) < 1e-6, 2),1)-1;

end

if isempty(touchdown_est) && isempty(touchdown)
    fprintf('No touchdown detected. Exiting.\n')
    return
end

if touchdown <= 0 || touchdown_est <= 0
    % started from a landed position
    takeoff =  find( all( abs(truth.sim.vel_topo.Data) > 1e-6, 2), 1) ;
    landed = find( all( abs(truth.sim.vel_topo.Data) < 1e-6, 2) );
    
    touchdown = landed( find( landed > takeoff, 1) ) - 1;
    
    takeoff_est =  find( all( abs(truth.fsw_rate.topo.sim_vel.Data) > 1e-6, 2), 1) ;
    landed_est = find( all( abs(truth.fsw_rate.topo.sim_vel.Data) < 1e-6, 2) );
    
    touchdown_est = landed_est( find( landed_est > takeoff_est, 1) ) - 1;
end

while abs(truth.fsw_rate.topo.sim_vel.Data(touchdown_est,3)) < 1e-6 || abs(telem.est.vel.Data(touchdown_est,3) )< 1e-6,
    touchdown = touchdown - 10;
    touchdown_est = touchdown_est - 1;
end

if  isempty(touchdown_est)
    fprintf('No touchdown detected. Exiting.\n')
    return
end


%-------------------------------------------------------------------------%
% mcall values

mcall=zeros(1,i.n);

mcall(i.file_index)             = file_index;
mcall(i.est_pos_err)            = error.knowledge.total.pos.Data(touchdown_est,:);   
mcall(i.est_vel_err)            = error.knowledge.total.vel.Data(touchdown_est,:); 
mcall(i.est_angles_xyz_err)     = error.knowledge.total.euler.Data(touchdown_est,:); 
mcall(i.est_rates_dps_err)      = error.knowledge.total.rate.Data(touchdown_est,:)* 180/pi;
mcall(i.est_alt_err)            = truth.sim.altitude.Data(touchdown) - telem.est.altitude.Data(touchdown_est);

mcall(i.gnc_pos_err)            = truth.fsw_rate.total.sim_pos.Data(touchdown_est,:);
mcall(i.gnc_vel_err)            = truth.fsw_rate.total.sim_vel.Data(touchdown_est,:);
mcall(i.gnc_angles_zyx_err)     = truth.fsw_rate.total.sim_euler.Data(touchdown_est,:);
mcall(i.gnc_rates_dps_err)      = truth.fsw_rate.total.sim_rate.Data(touchdown_est,:) * 180/pi;

mcall(i.mass)           = truth.sim.mass.Data(end);
mcall(i.mass_first)     = truth.sim.mass.Data(istop1burn);
mcall(i.burn1_time)     = tFSW(istop1burn)-tFSW(istart1burn);
mcall(i.coast_time)     = tFSW(istart2burn)-tFSW(istop1burn);
mcall(i.burn2_time)     = tFSW(end)-tFSW(istart2burn);
mcall(i.pos_coast )     = truth.fsw_rate.total.sim_pos.Data(istop1burn,:);
mcall(i.pos_burn2 )     = truth.fsw_rate.total.sim_pos.Data(istart2burn,:);

mcall(i.vcrossover_time ) = tFSW(end)-tFSW(touchdown_est(1));

mcall(i.cgx_final ) = truth.sim.cg.Data(end,1);
mcall(i.cgy_final ) = truth.sim.cg.Data(end,2);
mcall(i.cgz_final ) = truth.sim.cg.Data(end,3);

mcall(i.htp_used  ) = truth.sim.htp_used_main.Data(touchdown) + truth.sim.htp_used_acs.Data(touchdown);
mcall(i.rp1_used  ) = truth.sim.rp1_used_main.Data(touchdown);
mcall(i.gn2_used  ) = truth.sim.gn2_used_acs.Data(touchdown);

horz_vel            = norm(mcall(i.gnc_vel_err(1:2)));
horz_vel_est_err    = norm(mcall(i.est_vel_err(1:2)));
vert_vel            = norm(mcall(i.gnc_vel_err(3)));
vert_vel_est_err    = abs(mcall(i.est_vel_err(3)));
alt_knowledge       = norm(mcall(i.est_alt_err));
horz_pos            = norm(mcall(i.gnc_pos_err(1:2)),2);
body_rates          = norm(mcall(i.gnc_rates_dps_err));
final_gnc_ang_err   = norm(mcall(i.gnc_angles_zyx_err(1:2)));
htp_mass_used       = mcall(i.htp_used);
rp1_mass_used       = mcall(i.rp1_used);
gn2_mass_used       = mcall(i.gn2_used);
htp_mass_initial    = evalin('base','mpl_htp_mass_initial');
rp1_mass_initial    = evalin('base','mpl_rp1_mass_initial');
gn2_mass_initial    = evalin('base','mpl_gn2_mass_initial');

lateral_gnc_pos_scalar_limit  = 15000.0;
lateral_gnc_vel_scalar_limit  = 5.0;
lateral_est_vel_scalar_limit  = 5.0;
final_est_vert_pos_err_limit  = 10.0;
final_gnc_vert_vel_err_limit  = 4.0;
vertical_est_vel_scalar_limit = 1.5;
final_gnc_ang_err_limit       = 15.0;
final_gnc_rate_err_limit      = 25.0;

% MX application
mcall(i.fail ) = (horz_vel > 10) | (vert_vel > 10) | (alt_knowledge > 9);
mcall(i.fail_strict ) = (horz_pos > lateral_gnc_pos_scalar_limit) || (horz_vel > lateral_gnc_vel_scalar_limit) || (horz_vel_est_err > lateral_est_vel_scalar_limit)...
     || (alt_knowledge > final_est_vert_pos_err_limit) || (vert_vel > final_gnc_vert_vel_err_limit) || (vert_vel_est_err > vertical_est_vel_scalar_limit) ...
     || (final_gnc_ang_err > final_gnc_ang_err_limit) || (body_rates > final_gnc_rate_err_limit) ...
     || (htp_mass_used >= htp_mass_initial) || (rp1_mass_used >= rp1_mass_initial) || (gn2_mass_used >= gn2_mass_initial); 

if mcall(i.fail_strict) == 1 || mcall(i.fail) == 1
    horz_pos
    horz_vel
    horz_vel_est_err
    alt_knowledge
    vert_vel
    vert_vel_est_err
    final_gnc_ang_err
    body_rates
    htp_mass_used
    rp1_mass_used
    gn2_mass_used
end
    
end

