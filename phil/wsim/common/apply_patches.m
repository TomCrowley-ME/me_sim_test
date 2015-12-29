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
% apply_patches.m                                                         %
%                                                                         %
% Applies "fixes" to known MATLAB bugs. Fairly dumb.                      %
% 10/31/13                                                                %
% mikestewart@moonexpress.com                                             %
%-------------------------------------------------------------------------%

function apply_patches()

nimbus_root = getenv('NIMBUS_ROOT');
if isempty(nimbus_root)
    warning('NIMBUS_ROOT not set -- skipping patching');
    return;
end

switch version('-release')
    case '2013b'
        patched_file = fullfile(nimbus_root,'common','patches','raccel_mat.c.r2013b');
    case '2014b'
        patched_file = fullfile(nimbus_root,'common','patches','raccel_mat.c.r2014b');
    case '2015b'
        patched_file = fullfile(nimbus_root,'common','patches','raccel_mat.c.r2014b');
    otherwise
        warning('Unrecognized MATLAB version, things probably won''t work!');
        return;
end

% Break rt_RAccelReplaceToFilename in raccel_mat.c to make rapid
% accelerator builds write to the correct location
target_file = fullfile(matlabroot,'rtw','c','raccel','raccel_mat.c');
backup_file = [patched_file '.bak'];

target_info = dir(target_file);
patched_info = dir(patched_file);


if target_info.bytes ~= patched_info.bytes
    fprintf(1,'Patching %s...\n', target_file);
    [result, message] = copyfile(target_file, backup_file, 'f');
    if result ~= 1
        error([message 10 'Failed to create backup file ' backup_file '!']);
    end

    [result, message] = copyfile(patched_file, target_file, 'f');
    if result ~= 1
        error([message 10 'Please copy ' patched_file ' to ' target_file ' manually!']);
    else
        fprintf(1,'Success! Backup located at %s\n', backup_file);
    end


end