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
% compute_inertial_ini_quat_from_topo.m                                   %
%                                                                         %
% 06/19/14                                                                %
%-------------------------------------------------------------------------%

function quat_inertial = compute_inertial_ini_quat_from_topo(quat_topo_to_body, time_seconds, moonrotationrate, ini_Tmat_MCMF_to_Topocentric, ini_hour, ini_minute, ini_seconds, earth_moon_rotation_matrix_select)


if earth_moon_rotation_matrix_select == 0
    % moon
    q_j2000_to_mcmf = quaternion_inertial_to_moonfixed(time_seconds, moonrotationrate);
else
    % earth
    q_j2000_to_mcmf = quaternion_inertial_to_earthfixed(time_seconds);
end


q_mcmf_to_topo = dcm_to_quat(ini_Tmat_MCMF_to_Topocentric);

q_j2000_to_topo = quat_mult(q_j2000_to_mcmf, q_mcmf_to_topo);

quat_inertial = quat_mult(q_j2000_to_topo, quat_topo_to_body);