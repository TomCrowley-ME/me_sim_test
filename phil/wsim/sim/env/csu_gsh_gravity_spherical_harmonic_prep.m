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

%% Begin ini init file 
% Dependencies: 
% gsh_gravity_model_init
%
% Source: 
%
%%

gsh_f = central_body_flattening;   %flattening parameter
gsh_e = sqrt(1-(1-gsh_f)^2);       %square of first eccentricity
gsh_ef = (gsh_e^2*(1-gsh_f))/(1-gsh_e^2);
gsh_a = central_body_radius;
gsh_b = central_body_radius*(1-gsh_f);
gsh_ep = sqrt((gsh_a^2 - gsh_b^2)/gsh_b^2);


% only have harmonics for the moon right now....
gsh_sph_harm_order = gsh_sph_harm_order_desired*strcmp(central_body_name,'moon');   %n-th order model of gravity model. Pick 0 to 150.


    % % Load N-th order spherical harmonic coefficients
    gsh_n_degree = replace_empty_with_zero( find(gsh_sph_harm_coeffs(:,1)== gsh_sph_harm_order,1,'last') ); %finds last row to use
    gsh_deg      = replace_empty_with_zero( gsh_sph_harm_coeffs(2:gsh_n_degree,1) );
    gsh_ord      = replace_empty_with_zero( gsh_sph_harm_coeffs(2:gsh_n_degree,2) );
    gsh_c        = replace_empty_with_zero( gsh_sph_harm_coeffs(2:gsh_n_degree,3) );
    gsh_s        = replace_empty_with_zero( gsh_sph_harm_coeffs(2:gsh_n_degree,4) );

