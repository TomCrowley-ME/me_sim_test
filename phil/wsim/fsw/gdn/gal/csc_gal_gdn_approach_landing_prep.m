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



% currently pulls in sim values
gal_grav_surface_topo = central_body_gravity_mu/(central_body_radius^2);
gal_grav_surface_topo = 1.6242; % Hardcode for moon because Terminal 
                                % uses this and it needs accel after EGC
                                % thrust taken into account, not gravity of
                                % earth when MTV is operating


csc_lac_landing_acceleration_command_prep;
csc_ltg_landing_terminal_guidance_prep;
csc_tlt_takeoff_landing_table_guidance_prep;