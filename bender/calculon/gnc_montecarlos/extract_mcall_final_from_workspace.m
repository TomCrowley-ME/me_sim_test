function mcall = extract_mcall_final_from_workspace( file_index, truth, telem, error )

i = index_mcall_final;

%-------------------------------------------------------------------------%
% derive values

tFSW = telem.est.local_pos.Time;

mas_mass = resample(truth.sim.mass, tFSW);
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

% Find where pitch velocity crosses the 0 because s**t goes unstable after
% that, if doesnt exist get last point
% thrusting_b = act_f_n>max( act_f_n )*.05; % thrusting if > 5% max
% touchdown=extractPitchCrossOverPoint( rtk_vel_topo,orient_3dof_yz_r, thrusting_b, 'AfterIndex', istart2burn );

% touchdown = find( all( abs(truth.fsw_rate.topo.sim_vel.Data) < 1e-6, 2),1)-1;
% if isempty(touchdown)
%     touchdown = length(mas_mass);
% end


touchdown_sim = find( all( abs(truth.sim.vel_topo.Data) < 1e-6, 2),1)-1;


if touchdown_sim == 0 || touchdown_est == 0
    % started from a landed position
    takeoff =  find( all( abs(truth.sim.vel_topo.Data) > 1e-6, 2), 1) ;
    landed = find( all( abs(truth.sim.vel_topo.Data) < 1e-6, 2) );
    
    if  isempty(takeoff)
      touchdown = 1;
    else
      touchdown_sim = landed( find( landed > takeoff, 1) ) - 1;
    
      touchdown_sim_time = truth.sim.vel_topo.Time(touchdown_sim);
      touchdown = find(telem.est.vel.Time >= touchdown_sim_time,1);
    end
end

if  isempty(touchdown)
    fprintf('No touchdown detected. Exiting.\n')
    return
end


%-------------------------------------------------------------------------%
% mcall values

mcall=zeros(1,i.n);

mcall(i.file_index)             = file_index;
mcall(i.est_pos_err)            = error.knowledge.total.pos.Data(touchdown,:);   
mcall(i.est_vel_err)            = error.knowledge.total.vel.Data(touchdown,:); 
mcall(i.est_angles_xyz_err)     = error.knowledge.total.euler.Data(touchdown,:); 
mcall(i.est_rates_dps_err)      = error.knowledge.total.rate.Data(touchdown,:)* 180/pi;

mcall(i.gnc_pos_err)            = truth.fsw_rate.total.sim_pos.Data(touchdown,:);
mcall(i.gnc_vel_err)            = truth.fsw_rate.total.sim_vel.Data(touchdown,:);
mcall(i.gnc_angles_zyx_err)     = truth.fsw_rate.total.sim_euler.Data(touchdown,:);
mcall(i.gnc_rates_dps_err)      = truth.fsw_rate.total.sim_rate.Data(touchdown,:) * 180/pi;

mcall(i.mass)           = truth.sim.mass.Data(end);
mcall(i.mass_first)     = truth.sim.mass.Data(istop1burn);
mcall(i.burn1_time)     = tFSW(istop1burn)-tFSW(istart1burn);
mcall(i.coast_time)     = tFSW(istart2burn)-tFSW(istop1burn);
mcall(i.burn2_time)     = tFSW(end)-tFSW(istart2burn);
mcall(i.pos_coast )     = truth.fsw_rate.total.sim_pos.Data(istop1burn,:);
mcall(i.pos_burn2 )     = truth.fsw_rate.total.sim_pos.Data(istart2burn,:);

mcall(i.vcrossover_time ) = tFSW(end)-tFSW(touchdown(1));

mcall(i.cgx_final ) = truth.sim.cg.Data(end,1);
mcall(i.cgy_final ) = truth.sim.cg.Data(end,2);
mcall(i.cgz_final ) = truth.sim.cg.Data(end,3);

mcall(i.htp_used  ) = truth.sim.prop_used_main.Data(end);
mcall(i.gn2_used  ) = truth.sim.prop_used_acs.Data(end);

horz_vel            = norm(mcall(i.gnc_vel_err(1:2)));
horz_vel_est_err    = norm(mcall(i.est_vel_err(1:2)));
vert_vel            = norm(mcall(i.gnc_vel_err(3)));
vert_vel_est_err    = abs(mcall(i.est_vel_err(3)));
alt_knowledge       = norm(mcall(i.est_pos_err(3)));
horz_pos            = norm(mcall(i.gnc_pos_err(1:2)),2);
body_rates          = norm(mcall(i.gnc_rates_dps_err));
dry_mass            = evalin('base','mpl_mass_dry');
final_mass          = mcall(i.mass);
final_gnc_ang_err   = norm(mcall(i.gnc_angles_zyx_err(1:2)));
htp_mass_used       = mcall(i.htp_used);
htp_mass_initial    = evalin('base','mpl_htp_mass_initial');

% MX application
% mcall(i.fail ) = (horz_vel > 10) | (vert_vel > 10) | (alt_knowledge > 9);
% mcall(i.fail_strict ) = (horz_pos > 10000) |(horz_vel > 5) | (horz_vel_est_err > 5) | (alt_knowledge > 8) | (vert_vel > 4) | (vert_vel_est_err > 4) | (final_gnc_ang_err > 15) | (body_rates > 10) | (final_mass < dry_mass) ; 

% MTV applicatoin
mcall(i.fail ) = (horz_vel > 1.0) | (vert_vel > 2.0) | (alt_knowledge > 0.5);
mcall(i.fail_strict ) = (horz_pos > 3) |(horz_vel > 0.75) | (horz_vel_est_err > 1.0) | (alt_knowledge > 0.20) | (vert_vel > 2.0) | (vert_vel_est_err > 2.0) | (final_gnc_ang_err > 25) | (body_rates > 45) | (htp_mass_used >= htp_mass_initial);  
if mcall(i.fail_strict) == 1 | mcall(i.fail) == 1
    horz_pos
    horz_vel
    horz_vel_est_err
    alt_knowledge
    vert_vel
    vert_vel_est_err
    final_gnc_ang_err
    body_rates
    htp_mass_used
    htp_mass_initial
    
end
    
end

