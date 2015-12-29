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
% set_central_body_gravity.m                                              %
%                                                                         %
% single output function called by top-level script                       %
% 07/02/14                                                                %
%-------------------------------------------------------------------------%

function central_body_gravity_mu = set_central_body_gravity(body)

global gbl_param

switch body
    
    case 'moon'
         central_body_gravity_mu = gbl_param.moon_gravity_mu;
 
    case 'earth'
         central_body_gravity_mu = gbl_param.earth_gravity_mu;

    otherwise
        error('Unrecognized central body requested: only ''earth'' or ''moon'' current accepted. Cannot continue simulation')
        
end
