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
% set_central_body_flattening.m                                           %
%                                                                         %
% single output function called by top-level script                       %
% 07/24/14                                                                %
%-------------------------------------------------------------------------%

function central_body_flattening = set_central_body_flattening(body)

global gbl_param

switch body
    
    case 'moon'
         central_body_flattening = gbl_param.moon_flattening;
 
    case 'earth'
         central_body_flattening = gbl_param.earth_flattening;

    otherwise
        error('Unrecognized central body requested: only ''earth'' or ''moon'' current accepted. Cannot continue simulation')
        
end
