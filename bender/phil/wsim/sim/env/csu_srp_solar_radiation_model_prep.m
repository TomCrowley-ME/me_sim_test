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
% csu_srp_solar_radiation_model_prep.m                                    %
% Dependencies: csu_srp_solar_radiation_model_init.m                      %
% 08/14/13                                                                %
%-------------------------------------------------------------------------%


csu_srp_ang_penumbra_moon = zeros(sim_stop_time,1);
csu_srp_ang_umbra_moon = zeros(sim_stop_time,1);

for i = 1:sim_stop_time
    csu_srp_ang_penumbra_moon(i) = atan((gbl_param.sun_radius+central_body_radius)/(norm(pos_s2m_j2000(i,:)))) *180/pi;      %(deg)
    csu_srp_ang_umbra_moon(i) = atan(gbl_param.sun_radius/(norm(pos_s2m_j2000(i,:))))*180/pi;      %(deg)
end

clear i
