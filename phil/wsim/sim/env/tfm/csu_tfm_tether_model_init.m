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

%% Tether model
tfm_cg_enable      = 1;      % 0=use CG at origin, 1=use computed CG
tfm_forces_enable  = 1;      % Turn ON Tether Forces
tfm_moments_enable = 1;      % Turn ON Tether Moments

tfm_tether_unstretched_length = 9.21;          % m
tfm_tether_spring_constant    = 10.0;          % N/m
tfm_tether_mass_per_length    = 1.0;           % kg/m

tfm_hanging_location_topo     = [0.0 0.0 10.0]; % m
tfm_attachment_location_body  = [0.0 0.0 0.2];  % m

tfm_sleeve_length             = 1.5;           % m
tfm_sleeve_mass               = 0.5;           % kg

tfm_horseshoe_bolt_mass       = 0.5;           % kg

