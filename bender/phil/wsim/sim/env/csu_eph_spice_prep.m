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

%% Begin SPICE prep file
% Dependencies: 
% csu_eph_spice_init.m
%
%%

% Using loaded SPICE kernels, create lookup table of Earth-Moon distance,
% Sun-Moon distance (MCMF Frame). 


% API for MICE Functions:
% http://naif.jpl.nasa.gov/pub/naif/toolkit_docs/C/info/mostused.html

% ini_epoch_seconds is in UTC. Convert to Ephemeris Time (ET)
% (http://www.cv.nrao.edu/~rfisher/Ephemerides/times.html)
% (http://en.wikipedia.org/wiki/Ephemeris_time)

% Convert utc to et: (CURRENTLY HAVE TO MANUALLY CHANGE THIS IN SIM.PROC
% FILE
j2000_seconds_et = cspice_str2et('2013-SEP-23 00:00');

spice_time_lookup = j2000_seconds_et:eph_time_step_size:(sim_stop_time + j2000_seconds_et);
nelements = length(spice_time_lookup);
eph_pos_m2e_mcmf = zeros(nelements,3);
eph_pos_m2s_mcmf = zeros(nelements,3);
eph_pos_m2e_j2000 = zeros(nelements,3);
eph_pos_m2s_j2000 = zeros(nelements,3);

% Create lookup table vectors of Earth-Moon and Sun-Moon distances.
for i = 1:nelements
    % Create Moon-to-Earth, Moon-to-Sun vectors in J2000 frame.
    eph_pos_m2e_j2000(i,1:3) = 1000*cspice_spkpos('Earth', spice_time_lookup(i), 'J2000', 'LT+S', 'Moon');
    eph_pos_m2s_j2000(i,1:3) = 1000*cspice_spkpos('Sun', spice_time_lookup(i), 'J2000', 'LT+S', 'Moon');
    
    % Create Moon-to-Earth, Moon-to-Sun vectors in J2000 frame.
    %('MOON_PA' is more accurate representation of MCMF_PA frame than
    %'IAU_MOON')
    eph_pos_m2s_mcmf(i,1:3) = 1000*cspice_spkpos('Sun', spice_time_lookup(i), 'MOON_PA', 'LT+S', 'Moon');
    eph_pos_m2e_mcmf(i,1:3) = 1000*cspice_spkpos('Earth', spice_time_lookup(i), 'MOON_PA', 'LT+S', 'Moon');
end
    eph_pos_s2m_j2000 = eph_pos_m2s_j2000 .* -1;
    eph_pos_e2m_j2000 = eph_pos_m2e_j2000 .* -1;
    eph_pos_s2m_mcmf = eph_pos_m2s_mcmf .* -1;
    eph_pos_e2m_mcmf = eph_pos_m2e_mcmf .* -1;

clear spice_time_lookup nelements i j2000_seconds_et;
%%%%%%%%%%%%%%% END SCRIPT %%%%%%%%%%%%%%%