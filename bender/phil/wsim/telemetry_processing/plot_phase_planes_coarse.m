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

start_idx = 36700;
start_idx = 39500;
start_idx = 3300;
start_idx = 1;
start_idx = 40800;
start_idx = 41710;
end_idx = 185;
end_idx = size(telem.cnt.quat_err.Time);
end_idx = 40900;
end_idx = 41718;

if isempty(truth) == 0 && exist('cac_coarse_thruster_trq_x','var') > 0
    
    alpha1_x = evalin( 'base','cac_coarse_thruster_trq_x')/truth.sim.inertia.Data(1,1,end);
    % alpha2_x = evalin( 'base','cac_alpha_gain_biprop_fire')*alpha1_x;
    alpha2_x = evalin( 'base','cac_alpha_gain_coarse_only')*alpha1_x;

    alpha1_y = evalin( 'base','cac_coarse_thruster_trq_y')/truth.sim.inertia.Data(2,2,end);
    % alpha2_y = evalin( 'base','cac_alpha_gain_biprop_fire')*alpha1_y;
    alpha2_y = evalin( 'base','cac_alpha_gain_coarse_only')*alpha1_y;

    alpha1_z = evalin( 'base','cac_coarse_thruster_trq_z')/truth.sim.inertia.Data(3,3,end);
    % alpha2_z = evalin( 'base','cac_alpha_gain_biprop_fire')*alpha1_z;
    alpha2_z = evalin( 'base','cac_alpha_gain_coarse_only')*alpha1_z;
    
    theta_db = evalin( 'base','cac_rotx_deadband');
    edot = [-20*pi/180:.01*pi/180:20*pi/180];
    cac_rotx_deadband_minus = evalin( 'base','cac_rotx_deadband_minus');
    cac_rotx_deadband = evalin( 'base','cac_rotx_deadband');
    cac_roty_deadband_minus = evalin( 'base','cac_roty_deadband_minus');
    cac_roty_deadband = evalin( 'base','cac_roty_deadband');
    cac_rotz_deadband_minus = evalin( 'base','cac_rotz_deadband_minus');
    cac_rotz_deadband = evalin( 'base','cac_rotz_deadband');
    
else
    csu_mpl_mass_properties_lander_init
    csu_mpl_mass_properties_lander_prep
    csu_mpl_mass_properties_mtv_init
    csu_mpl_mass_properties_mtv_prep
    csu_psp_propulsion_system_parameters_init
    csu_psp_propulsion_system_parameters_mtv_init
    csc_emp_est_mass_props_init
    csc_emp_est_mass_props_mtv_init
    csc_emp_est_mass_props_prep
    csc_cac_coarse_acs_ctrl_init
    csc_cac_coarse_acs_ctrl_prep
    alpha1_x = cac_coarse_thruster_trq_x/mpl_inertia_initial(1,1);
    alpha2_x = cac_alpha_gain_coarse_only*alpha1_x;

    alpha1_y = cac_coarse_thruster_trq_y/mpl_inertia_initial(2,2);
    alpha2_y = cac_alpha_gain_coarse_only*alpha1_y;

    alpha1_z = cac_coarse_thruster_trq_z/mpl_inertia_initial(3,3);
    alpha2_z = cac_alpha_gain_coarse_only*alpha1_z;

    theta_db = cac_rotx_deadband;
    edot = [-20*pi/180:.01*pi/180:20*pi/180];

end

for i=1:size(edot,2)
    c1_x(i) = -cac_rotx_deadband_minus - edot(i)^2/(2*alpha2_x);
    c2_x(i) = -cac_rotx_deadband_minus + edot(i)^2/(2*alpha1_x);
    c3_x(i) =  cac_rotx_deadband - edot(i)^2/(2*alpha1_x);
    c4_x(i) =  cac_rotx_deadband + edot(i)^2/(2*alpha2_x);
    c1_y(i) = -cac_roty_deadband_minus - edot(i)^2/(2*alpha2_y);
    c2_y(i) = -cac_roty_deadband_minus + edot(i)^2/(2*alpha1_y);
    c3_y(i) =  cac_roty_deadband - edot(i)^2/(2*alpha1_y);
    c4_y(i) =  cac_roty_deadband + edot(i)^2/(2*alpha2_y);
    c1_z(i) = -cac_rotz_deadband_minus - edot(i)^2/(2*alpha2_z);
    c2_z(i) = -cac_rotz_deadband_minus + edot(i)^2/(2*alpha1_z);
    c3_z(i) =  cac_rotz_deadband - edot(i)^2/(2*alpha1_z);
    c4_z(i) =  cac_rotz_deadband + edot(i)^2/(2*alpha2_z);

end

c1_x = c1_x*180/pi;
c2_x = c2_x*180/pi;
c3_x = c3_x*180/pi;
c4_x = c4_x*180/pi;
c1_y = c1_y*180/pi;
c2_y = c2_y*180/pi;
c3_y = c3_y*180/pi;
c4_y = c4_y*180/pi;
c1_z = c1_z*180/pi;
c2_z = c2_z*180/pi;
c3_z = c3_z*180/pi;
c4_z = c4_z*180/pi;

edot = edot*180/pi;

if isempty(truth) == 0

    figure(101);clf;grid on;box on;hold on;title('True Phase Plane - X Axis');xlabel('Angle - X Error (deg)');ylabel('Rate - X Error (deg/sec)')
    set(gcf,'Name','True Phase Plane - X Axis')
    plot(c1_x(ceil(size(edot,2)/2):end),edot(ceil(size(edot,2)/2):end),'black','linewidth',2)
    plot(c2_x(1:ceil(size(edot,2)/2)),edot(1:ceil(size(edot,2)/2)),'black','linewidth',2)
    plot(c3_x(ceil(size(edot,2)/2):end),edot(ceil(size(edot,2)/2):end),'black','linewidth',2)
    plot(c4_x(1:ceil(size(edot,2)/2)),edot(1:ceil(size(edot,2)/2)),'black','linewidth',2)

    plot(-error.pointing.components_error_deg.Data(start_idx:end_idx-1,1),-truth.sim.rrk_rate_body_eci_body.Data(start_idx*10:10:end_idx*10-9,1)*180/pi,'b','linewidth',2)
    %saveas(gcf,'TruePhaseX.png');
    
    figure(102);clf;grid on;box on;hold on;title('True Phase Plane - Y Axis');xlabel('Angle - Y Error (deg)');ylabel('Rate - Y Error (deg/sec)')
    set(gcf,'Name','True Phase Plane - Y Axis')
    plot(c1_y(ceil(size(edot,2)/2):end),edot(ceil(size(edot,2)/2):end),'black','linewidth',2)
    plot(c2_y(1:ceil(size(edot,2)/2)),edot(1:ceil(size(edot,2)/2)),'black','linewidth',2)
    plot(c3_y(ceil(size(edot,2)/2):end),edot(ceil(size(edot,2)/2):end),'black','linewidth',2)
    plot(c4_y(1:ceil(size(edot,2)/2)),edot(1:ceil(size(edot,2)/2)),'black','linewidth',2)

    plot(-error.pointing.components_error_deg.Data(start_idx:end_idx-1,2),-truth.sim.rrk_rate_body_eci_body.Data(start_idx*10:10:end_idx*10-9,2)*180/pi,'r','linewidth',2)
    %saveas(gcf,'TruePhaseY.png');

    figure(103);clf;grid on;box on;hold on;title('True Phase Plane - Z Axis');xlabel('Angle - Z Error (deg)');ylabel('Rate - Z Error (deg/sec)')
    set(gcf,'Name','True Phase Plane - Z Axis')
    plot(c1_z(ceil(size(edot,2)/2):end),edot(ceil(size(edot,2)/2):end),'black','linewidth',2)
    plot(c2_z(1:ceil(size(edot,2)/2)),edot(1:ceil(size(edot,2)/2)),'black','linewidth',2)
    plot(c3_z(ceil(size(edot,2)/2):end),edot(ceil(size(edot,2)/2):end),'black','linewidth',2)
    plot(c4_z(1:ceil(size(edot,2)/2)),edot(1:ceil(size(edot,2)/2)),'black','linewidth',2)

    plot(-error.pointing.components_error_deg.Data(start_idx:end_idx-1,3),-truth.sim.rrk_rate_body_eci_body.Data(start_idx*10:10:end_idx*10-9,3)*180/pi,'y','linewidth',2)
    %saveas(gcf,'TruePhaseZ.png');
    
    figure(104);clf;grid on;box on;hold on;title('Flight Phase Plane - X Axis');xlabel('Angle - X Error (deg)');ylabel('Rate - X Error (deg/sec)')
    set(gcf,'Name','Flight Phase Plane - X Axis')
    plot(c1_x(ceil(size(edot,2)/2):end),edot(ceil(size(edot,2)/2):end),'black','linewidth',2)
    plot(c2_x(1:ceil(size(edot,2)/2)),edot(1:ceil(size(edot,2)/2)),'black','linewidth',2)
    plot(c3_x(ceil(size(edot,2)/2):end),edot(ceil(size(edot,2)/2):end),'black','linewidth',2)
    plot(c4_x(1:ceil(size(edot,2)/2)),edot(1:ceil(size(edot,2)/2)),'black','linewidth',2)

    plot(-error.pointing.flight_components_error_deg.Data(start_idx:end_idx,1),-telem.est.rate.Data(start_idx:end_idx,1)*180/pi,'b','linewidth',2)
    %saveas(gcf,'FlightPhaseX.png');

    figure(105);clf;grid on;box on;hold on;title('Flight Phase Plane - Y Axis');xlabel('Angle - Y Error (deg)');ylabel('Rate - Y Error (deg/sec)')
    set(gcf,'Name','Flight Phase Plane - Y Axis')
    plot(c1_y(ceil(size(edot,2)/2):end),edot(ceil(size(edot,2)/2):end),'black','linewidth',2)
    plot(c2_y(1:ceil(size(edot,2)/2)),edot(1:ceil(size(edot,2)/2)),'black','linewidth',2)
    plot(c3_y(ceil(size(edot,2)/2):end),edot(ceil(size(edot,2)/2):end),'black','linewidth',2)
    plot(c4_y(1:ceil(size(edot,2)/2)),edot(1:ceil(size(edot,2)/2)),'black','linewidth',2)

    plot(-error.pointing.flight_components_error_deg.Data(start_idx:end_idx,2),-telem.est.rate.Data(start_idx:end_idx,2)*180/pi,'r','linewidth',2)
    %saveas(gcf,'FlightPhaseY.png');

    figure(106);clf;grid on;box on;hold on;title('Flight Phase Plane - Z Axis');xlabel('Angle - Z Error (deg)');ylabel('Rate - Z Error (deg/sec)')
    set(gcf,'Name','Flight Phase Plane - Z Axis')
    plot(c1_z(ceil(size(edot,2)/2):end),edot(ceil(size(edot,2)/2):end),'black','linewidth',2)
    plot(c2_z(1:ceil(size(edot,2)/2)),edot(1:ceil(size(edot,2)/2)),'black','linewidth',2)
    plot(c3_z(ceil(size(edot,2)/2):end),edot(ceil(size(edot,2)/2):end),'black','linewidth',2)
    plot(c4_z(1:ceil(size(edot,2)/2)),edot(1:ceil(size(edot,2)/2)),'black','linewidth',2)

    plot(-error.pointing.flight_components_error_deg.Data(start_idx:end_idx,3),-telem.est.rate.Data(start_idx:end_idx,3)*180/pi,'y','linewidth',2)
    %saveas(gcf,'FlightPhaseZ.png');

else
    
    figure(104);clf;grid on;box on;hold on;title('Flight Phase Plane - X Axis');xlabel('Angle - X Error (deg)');ylabel('Rate - X Error (deg/sec)')
    set(gcf,'Name','Flight Phase Plane - X Axis')
    plot(c1_x(ceil(size(edot,2)/2):end),edot(ceil(size(edot,2)/2):end),'black','linewidth',2)
    plot(c2_x(1:ceil(size(edot,2)/2)),edot(1:ceil(size(edot,2)/2)),'black','linewidth',2)
    plot(c3_x(ceil(size(edot,2)/2):end),edot(ceil(size(edot,2)/2):end),'black','linewidth',2)
    plot(c4_x(1:ceil(size(edot,2)/2)),edot(1:ceil(size(edot,2)/2)),'black','linewidth',2)

    plot(-telem.est.euler_xyz.Data(start_idx:end_idx,1),-telem.est.rate.Data(start_idx:end_idx,1)*180/pi,'b','linewidth',2)
    %saveas(gcf,'FlightPhaseX.png');

    figure(105);clf;grid on;box on;hold on;title('Flight Phase Plane - Y Axis');xlabel('Angle - Y Error (deg)');ylabel('Rate - Y Error (deg/sec)')
    set(gcf,'Name','Flight Phase Plane - Y Axis')
    plot(c1_y(ceil(size(edot,2)/2):end),edot(ceil(size(edot,2)/2):end),'black','linewidth',2)
    plot(c2_y(1:ceil(size(edot,2)/2)),edot(1:ceil(size(edot,2)/2)),'black','linewidth',2)
    plot(c3_y(ceil(size(edot,2)/2):end),edot(ceil(size(edot,2)/2):end),'black','linewidth',2)
    plot(c4_y(1:ceil(size(edot,2)/2)),edot(1:ceil(size(edot,2)/2)),'black','linewidth',2)

    plot(-telem.est.euler_xyz.Data(start_idx:end_idx,2),-telem.est.rate.Data(start_idx:end_idx,2)*180/pi,'r','linewidth',2)
    %saveas(gcf,'FlightPhaseY.png');

    figure(106);clf;grid on;box on;hold on;title('Flight Phase Plane - Z Axis');xlabel('Angle - Z Error (deg)');ylabel('Rate - Z Error (deg/sec)')
    set(gcf,'Name','Flight Phase Plane - Z Axis')
    plot(c1_z(ceil(size(edot,2)/2):end),edot(ceil(size(edot,2)/2):end),'black','linewidth',2)
    plot(c2_z(1:ceil(size(edot,2)/2)),edot(1:ceil(size(edot,2)/2)),'black','linewidth',2)
    plot(c3_z(ceil(size(edot,2)/2):end),edot(ceil(size(edot,2)/2):end),'black','linewidth',2)
    plot(c4_z(1:ceil(size(edot,2)/2)),edot(1:ceil(size(edot,2)/2)),'black','linewidth',2)

    plot(-telem.est.euler_xyz.Data(start_idx:end_idx,3),-telem.est.rate.Data(start_idx:end_idx,3)*180/pi,'y','linewidth',2)
    %saveas(gcf,'FlightPhaseZ.png');

end