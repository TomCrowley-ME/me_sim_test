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

function mtv_add_path()

% % assumes that you've already run nimbus_set_path sucessfully

NIMBUS_ROOT = getenv('NIMBUS_ROOT');

% MTV-specific library blocks
addpath([ NIMBUS_ROOT '/mtv' ]);
addpath([ NIMBUS_ROOT '/mtv/sim' ]);
addpath([ NIMBUS_ROOT '/mtv/fsw' ]);
addpath([ NIMBUS_ROOT '/mtv/fsw/enums' ]);
addpath([ NIMBUS_ROOT '/sim/env/afm' ]);
addpath([ NIMBUS_ROOT '/mtv/sim/gps' ]);


MTV_ROOT = [ NIMBUS_ROOT '/mtv' ];
setenv('MTV_ROOT',MTV_ROOT);
assignin('base', 'MTV_ROOT', MTV_ROOT);


% % Mex all needed s-functions -- anything specific to MTV?
% mex_all_sfun;
%
% % Make sure needed external repositories are up to date -- anything specific to MTV?
% check_versions;
%
% % Apply patches to MATLAB because it hates us -- anything specific to MTV?
% apply_patches;

end

