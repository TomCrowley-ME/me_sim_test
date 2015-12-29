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

function matlab_type = get_matlab_param_type(parameter_type)
    if strcmp(parameter_type.base_type, 'float')
        switch parameter_type.size_in_bits
            case 32
                matlab_type = 'single';
            case 64
                matlab_type = 'double';
            otherwise
                matlab_type = [];
        end
    else
        matlab_type = sprintf('int%u', parameter_type.size_in_bits);
        if ~parameter_type.signed
            matlab_type = ['u' matlab_type];
        end
    end
end