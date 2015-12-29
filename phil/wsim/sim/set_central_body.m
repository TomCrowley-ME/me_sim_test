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
% set_central_body.m                                                      %
%                                                                         %
% top-level script to set the central body for each scenario              %
% 03/28/14                                                                %
%-------------------------------------------------------------------------%


central_body_gravity_mu           = set_central_body_gravity(central_body_name);
central_body_radius               = set_central_body_radius(central_body_name);
central_body_rotation_rate        = set_central_body_rotation_rate(central_body_name);
central_body_omega_dot            = set_central_body_rotation_derivative(central_body_name);
central_body_flattening           = set_central_body_flattening(central_body_name);
earth_moon_rotation_matrix_select = set_central_body_rotation_matrix(central_body_name);



