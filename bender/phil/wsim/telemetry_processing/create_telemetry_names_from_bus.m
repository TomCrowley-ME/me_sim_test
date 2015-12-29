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
% create_telemetry_names_from_bus.m                                       %
%                                                                         %
% creates cell array of telemetry names for given bus                     %
%                                                                         %
% Inputs:  1. bus name, as given in clamps                                %
%                                                                         %
% Outputs: 1. cell array of telemetry names, formatted to match PHIL      %
%                                                                         %
% 05/30/13                                                                %
% eleanorcrane@moonexpress.com  (from hover: htv_setup)                   %
%-------------------------------------------------------------------------%

function telem_fname = create_telemetry_names_from_bus(telem_bus_names)

% create array of field names from telemetry_data matrix from
% csc_ttc_telem_msg bus, env_metrics bus, and fhw_spacecraft_forces bus
% telem_bus_names={'sim_tlm_msg'; ...
%                  };
telem_bus_cnt = length(telem_bus_names);    % calc number of bus names in array

k=1;  % intialize telem_fname index
for h=1:telem_bus_cnt
    localBus = evalin('base',telem_bus_names{h,1});
    n_fields = length(localBus.Elements);    % calc number of fields in the bus object
    for i=1:n_fields
        dims = localBus.Elements(i).Dimensions;       % calc number of dimensions in case the field is a vector
        for j=1:dims
            if dims > 1
                telem_fname{k,1} = sprintf('%s[%d]',localBus.Elements(i).Name,j); % set the name of the field with index
            else
                telem_fname{k,1} = localBus.Elements(i).Name;       % set the name of the field
            end
            k=k+1;
        end
    end
end 