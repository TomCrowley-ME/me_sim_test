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

%------------------------------------------------------------------------
%   ping.m
%
%   Uses a system() call to ping and returns the result. 
%   0 means a connection was made, 1 means the host didn't respond.
%   07/25/12
%------------------------------------------------------------------------

function result = ping(ip_addr_str)
    fprintf('Pinging %s\n', ip_addr_str)
    if ispc
        [~, log] = system(['ping ' ip_addr_str]);
        result = isempty(strfind(log, 'TTL='));
    elseif isunix
        [result, ~] = system(['ping -q -c 5 -i 1 ' ip_addr_str]);
    else
        fprintf('Unrecognized Operating System')
        result = 1;
    end
end
