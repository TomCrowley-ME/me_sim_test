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
% touchdown_evaluation.m                                                  %
%                                                                         %
% evaluates touchdown conditions for first cut success/failure            %
% 05/30/13                                                                %
%-------------------------------------------------------------------------%

function touchdown_evaluation(telem, truth)

test_for_parameters_in_workspace = evalin( 'base', 'exist(''mpl_mass_dry'',''var'')');

if ~isempty(find( all( abs(truth.fsw_rate.topo.sim_vel.Data) < 1e-6, 2),1)) && ~isempty(find( all( abs(truth.sim.vel_topo.Data) < 1e-6, 2),1)-1)
    touchdown_est_initial = find( all( abs(truth.fsw_rate.topo.sim_vel.Data) < 1e-6, 2),1)-1;
    touchdown_initial = find( all( abs(truth.sim.vel_topo.Data) < 1e-6, 2),1)-1;
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

while norm(truth.sim.vel_topo.Data(touchdown,1:2),2) < 1e-6 || norm(telem.est.vel.Data(touchdown_est,1:2),2) < 1e-6,
    touchdown = touchdown - 10;
    touchdown_est = touchdown_est - 1;
end

horz_pos = norm(truth.sim.pos_topo.Data(touchdown,1:2),2);
horz_vel = norm(truth.sim.vel_topo.Data(touchdown,1:2));

horz_vel_est_err = norm(truth.sim.vel_topo.Data(touchdown,1:2) - telem.est.vel.Data(touchdown_est,1:2),2);

%alt_knowledge =  norm(truth.sim.pos_topo.Data(touchdown,3) - telem.est.local_pos.Data(touchdown_est,3));
alt_knowledge =  norm(truth.sim.altitude.Data(touchdown) - telem.est.altitude.Data(touchdown_est));
vert_vel =  norm(truth.sim.vel_topo.Data(touchdown,3));

vert_vel_est_err = abs(truth.sim.vel_topo.Data(touchdown,3) - telem.est.vel.Data(touchdown_est,3));

final_gnc_ang_err = norm(truth.sim.euler_zyx.Data(touchdown,1:2));
body_rates = norm(truth.sim.rate_body.Data(touchdown,:))*180/pi;

htp_mass_used = truth.sim.htp_used_main.Data(touchdown)+truth.sim.htp_used_acs.Data(touchdown);
rp1_mass_used = truth.sim.rp1_used_main.Data(touchdown);
gn2_mass_used = truth.sim.gn2_used_acs.Data(touchdown);

lateral_cg_truth = 1e3*truth.sim.cg.Data(touchdown,1:2);
lateral_cg_est = 1e3*telem.est.cg.Data(touchdown_est,1:2);

lateral_gnc_pos_scalar_limit  = 25000.0;
lateral_gnc_vel_scalar_limit  = 5.0;
lateral_est_vel_scalar_limit  = 5.0;
final_est_vert_pos_err_limit  = 10.0;
final_gnc_vert_vel_err_limit  = 4.0;
vertical_est_vel_scalar_limit = 1.5;
final_gnc_ang_err_limit       = 15.0;
final_gnc_rate_err_limit      = 25.0;
htp_mass_initial              = evalin('base','mpl_htp_mass_initial');
rp1_mass_initial              = evalin('base','mpl_rp1_mass_initial');
gn2_mass_initial              = evalin('base','mpl_gn2_mass_initial');

if (horz_pos > lateral_gnc_pos_scalar_limit) || (horz_vel > lateral_gnc_vel_scalar_limit) || (horz_vel_est_err > lateral_est_vel_scalar_limit) || (alt_knowledge > final_est_vert_pos_err_limit) ...
|| (vert_vel > final_gnc_vert_vel_err_limit) || (vert_vel_est_err > vertical_est_vel_scalar_limit) || (final_gnc_ang_err > final_gnc_ang_err_limit) || (body_rates > final_gnc_rate_err_limit) ...
|| (htp_mass_used >= htp_mass_initial) || (rp1_mass_used >= rp1_mass_initial) || (gn2_mass_used >= gn2_mass_initial) ; 
    fprintf(1,'Degenerative Case.  One or more of the following conditions violated:\n')
    fprintf(1,'horz_pos > %g) || (horz_vel > %g) || (horz_vel_est_err > %g) || (alt_knowledge > %g) || (vert_vel > %g) || \n(vert_vel_est_err > %g) || (final_gnc_ang_err > %g) || (body_rates > %g) || \n(htp_mass_used >= %g) || (gn2_mass_used >= %g) || (rp1_mass_used >= %g)\n',...
            lateral_gnc_pos_scalar_limit,lateral_gnc_vel_scalar_limit,lateral_est_vel_scalar_limit,final_est_vert_pos_err_limit,final_gnc_vert_vel_err_limit,vertical_est_vel_scalar_limit,final_gnc_ang_err_limit,final_gnc_rate_err_limit,...
            htp_mass_initial,gn2_mass_initial,rp1_mass_initial)
else
    fprintf(1,'All Landing Conditions Within Limits\n')
    fprintf(1,'(horz_pos < %g) && (horz_vel < %g) && (horz_vel_est_err < %g) && (alt_knowledge < %g) && (vert_vel < %g) && \n(vert_vel_est_err < %g) && (final_gnc_ang_err < %g) && (body_rates < %g) && \n(htp_mass_used < %g) && (gn2_mass_used < %g) && (rp1_mass_used < %g)\n',...
            lateral_gnc_pos_scalar_limit,lateral_gnc_vel_scalar_limit,lateral_est_vel_scalar_limit,final_est_vert_pos_err_limit,final_gnc_vert_vel_err_limit,vertical_est_vel_scalar_limit,final_gnc_ang_err_limit,final_gnc_rate_err_limit,...
            htp_mass_initial,gn2_mass_initial,rp1_mass_initial)
end

fprintf(1,'horz_pos = %g\n', (horz_pos));
fprintf(1,'horz_vel = %g\n', (horz_vel));
fprintf(1,'horz_vel_est_err = %g\n', (horz_vel_est_err));
fprintf(1,'alt_knowledge = %g\n', (alt_knowledge));
fprintf(1,'vert_vel = %g\n', (vert_vel));
fprintf(1,'vert_vel_est_err = %g\n', (vert_vel_est_err));
fprintf(1,'final_gnc_ang_err = %g\n', (final_gnc_ang_err));
fprintf(1,'body_rates = %g\n', (body_rates));
fprintf(1,'htp_mass_used = %g\n', (htp_mass_used));
fprintf(1,'gn2_mass_used = %g\n', (gn2_mass_used));
fprintf(1,'rp1_mass_used = %g\n', (rp1_mass_used));

if test_for_parameters_in_workspace
    fprintf(1,'Altimeter Noise (percent) = %g\n', (evalin('base','ldr_2k_percent_error')*100));
    fprintf(1,'Altimeter Maximum Range (m) = %g\n', (evalin('base','ldr_2k_range_max')));
    fprintf(1,'Camera Focal Length (m) = %g\n', (evalin('base','cam_focal_length_f')));
    fprintf(1,'Camera Angular Field of View (deg) = %g\n', (evalin('base','cam_aov')*180/pi));
    fprintf(1,'Camera Image Delta-T (sec) = %g\n', (evalin('base','cam_image_delta_t')));
    fprintf(1,'Camera Processing Delay (sec) = %g\n', (evalin('base','cam_processing_delay')));
    fprintf(1,'Camera Integration Time(sec) = %g\n', (evalin('base','cam_integ_time')));
    fprintf(1,'Lateral CG Truth Xbody (mm) = %g\n', (lateral_cg_truth(1)));
    fprintf(1,'Lateral CG Truth Ybody (mm) = %g\n', (lateral_cg_truth(2)));
    fprintf(1,'Lateral CG Estimate Xbody (mm) = %g\n', (lateral_cg_est(1)));
    fprintf(1,'Lateral CG Estimate Ybody (mm) = %g\n', (lateral_cg_est(2)));
else
    fprintf(1,'No information on configuration available\n')
end
