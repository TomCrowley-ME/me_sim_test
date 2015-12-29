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
% compute_scenario_initial_quatnerion.m                                   %
%                                                                         %
% 06/19/14                                                                %
%-------------------------------------------------------------------------%

function ini_quaternion_v = compute_scenario_initial_quatnerion(ini_j2000_or_topo, ini_rotx, ini_roty, ini_rotz, time_seconds, moonrotationrate, ini_Tmat_MCMF_to_Topocentric, ini_hour, ini_minute, ini_seconds, earth_moon_rotation_matrix_select)

if ini_j2000_or_topo==1
    
    ini_quaternion_v=[cos(ini_rotz/2)*cos(ini_roty/2)*sin(ini_rotx/2)-sin(ini_rotz/2)*sin(ini_roty/2)*cos(ini_rotx/2),...
                      cos(ini_rotz/2)*sin(ini_roty/2)*cos(ini_rotx/2)+sin(ini_rotz/2)*cos(ini_roty/2)*sin(ini_rotx/2),...
                      sin(ini_rotz/2)*cos(ini_roty/2)*cos(ini_rotx/2)-cos(ini_rotz/2)*sin(ini_roty/2)*sin(ini_rotx/2),...
                      cos(ini_rotz/2)*cos(ini_roty/2)*cos(ini_rotx/2)+sin(ini_rotz/2)*sin(ini_roty/2)*sin(ini_rotx/2)];
else
    ini_quaternion_topo_to_body =[cos(ini_rotz/2)*cos(ini_roty/2)*sin(ini_rotx/2)-sin(ini_rotz/2)*sin(ini_roty/2)*cos(ini_rotx/2),...
                                  cos(ini_rotz/2)*sin(ini_roty/2)*cos(ini_rotx/2)+sin(ini_rotz/2)*cos(ini_roty/2)*sin(ini_rotx/2),...
                                  sin(ini_rotz/2)*cos(ini_roty/2)*cos(ini_rotx/2)-cos(ini_rotz/2)*sin(ini_roty/2)*sin(ini_rotx/2),...
                                  cos(ini_rotz/2)*cos(ini_roty/2)*cos(ini_rotx/2)+sin(ini_rotz/2)*sin(ini_roty/2)*sin(ini_rotx/2)];
                                    
    ini_quaternion_v = compute_inertial_ini_quat_from_topo(ini_quaternion_topo_to_body, time_seconds, moonrotationrate, ini_Tmat_MCMF_to_Topocentric, ini_hour, ini_minute, ini_seconds, earth_moon_rotation_matrix_select);

end