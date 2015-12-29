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

function nimbus_set_path()

NIMBUS_ROOT = fileparts(mfilename('fullpath'));
setenv('NIMBUS_ROOT',NIMBUS_ROOT);
assignin('base', 'NIMBUS_ROOT', NIMBUS_ROOT);

% Find Mercurial. Start by looking for the HG environment variable.
hg_env = getenv('HG');

if isempty(hg_env)
    % No environment variable found... check the path
    if ispc
        [status, hg_path] = dos('where hg.exe');
    else
        [status, hg_path] = unix('which hg');
    end
    if status ~= 0
        error('MATLAB can''t find Mercurial! Make sure it''s in your PATH. If you need help getting this set up, contact mikestewart@moonexpress.com.');
    else
        setenv('HG', strtrim(hg_path));
    end
end

has_minopencv = false;

% general scripts
addpath([ NIMBUS_ROOT '/general_scripts']);

% external utils
%remove from path
%since we don't appear to be using
%addpath([ NIMBUS_ROOT '/externals/matlab-tools' ]); 
addpath([ NIMBUS_ROOT '/externals/jsonlab' ]);

minopencv_dir = [ NIMBUS_ROOT '/externals/minopencv' ];
if ~isdir(minopencv_dir)
   if yn_prompt('Warning: externals/minopencv doesn''t exist. Would you like me to try to clone it for you?', 'y', 'red');
       cd('externals');
        if ispc
            while ~isdir(minopencv_dir);
                status = system('hg clone https://platinum.moonexpress.com/hg/experimental/minopencv & type NUL>.hg_complete & exit &');
                while ~exist(fullfile(pwd, '.hg_complete'), 'file')
                    pause(1);
                end
                delete('.hg_complete');
            end
       else
           status = system('hg clone https://platinum.moonexpress.com/hg/experimental/minopencv');
        end
        if status ~= 0
           fprintf(2, 'Error trnimying to clone minopencv. Things may not run properly.\n\n');
        else
           has_minopencv = true;
        end
        cd(NIMBUS_ROOT);
    end
else
   has_minopencv = true;
end

% Sim library blocks
addpath([ NIMBUS_ROOT '/ground' ]);
addpath([ NIMBUS_ROOT '/externals' ]);
addpath([ NIMBUS_ROOT '/common' ]);
addpath([ NIMBUS_ROOT '/common/codegen' ]);
addpath([ NIMBUS_ROOT '/common/bus_initialization' ]);
addpath([ NIMBUS_ROOT '/sim' ]);
addpath([ NIMBUS_ROOT '/sim/hil_sim' ]);
addpath([ NIMBUS_ROOT '/sim/env' ]);
addpath([ NIMBUS_ROOT '/sim/env/afm' ]);
addpath([ NIMBUS_ROOT '/sim/env/enf' ]);
addpath([ NIMBUS_ROOT '/sim/env/rbd' ]);
addpath([ NIMBUS_ROOT '/sim/env/slh' ]);
addpath([ NIMBUS_ROOT '/sim/env/tfm' ]);
addpath([ NIMBUS_ROOT '/sim/fhw' ]);
addpath([ NIMBUS_ROOT '/sim/fhw/mass_properties' ]);
addpath([ NIMBUS_ROOT '/sim/fhw/thrusters' ]);
addpath([ NIMBUS_ROOT '/sim/fhw/sensors' ]);
addpath([ NIMBUS_ROOT '/sim/fhw/power' ]);
addpath([ NIMBUS_ROOT '/sim/fhw/thermal' ]);
addpath([ NIMBUS_ROOT '/sim/fhw/pressure' ]);
addpath([ NIMBUS_ROOT '/sim/fhw/sensors/mems' ]);
addpath([ NIMBUS_ROOT '/sim/fhw/sensors/lidar' ]);
addpath([ NIMBUS_ROOT '/sim/fhw/sensors/dsmac' ]);
addpath([ NIMBUS_ROOT '/sim/fhw/sensors/cameras' ]);
addpath([ NIMBUS_ROOT '/sim/fhw/sensors/cameras/kir' ]);
addpath([ NIMBUS_ROOT '/sim/fhw/sensors/star_tracker' ]);
addpath([ NIMBUS_ROOT '/externals/mice/src/mice' ]);
addpath([ NIMBUS_ROOT '/externals/mice/lib' ]);
addpath([ NIMBUS_ROOT '/externals/mice/kernels' ]);

% Flight software blocks
addpath([ NIMBUS_ROOT '/fsw' ]);

addpath([ NIMBUS_ROOT '/fsw/sc' ]);
addpath([ NIMBUS_ROOT '/fsw/lc' ]);

addpath([ NIMBUS_ROOT '/fsw/cmp' ]);
if isdir([ NIMBUS_ROOT '/fsw/cmp/enums'])
    addpath([ NIMBUS_ROOT '/fsw/cmp/enums'])
end

addpath([ NIMBUS_ROOT '/fsw/est' ]);
addpath([ NIMBUS_ROOT '/fsw/est/kcv' ]);
addpath([ NIMBUS_ROOT '/fsw/est/kfd' ]);
addpath([ NIMBUS_ROOT '/fsw/est/kfl' ]);
addpath([ NIMBUS_ROOT '/fsw/est/spc' ]);
addpath([ NIMBUS_ROOT '/fsw/est/emp' ]);
addpath([ NIMBUS_ROOT '/fsw/est/kfl/snp' ]);
addpath([ NIMBUS_ROOT '/fsw/est/kfl/ekf' ]);

addpath([ NIMBUS_ROOT '/fsw/gdn' ]);
addpath([ NIMBUS_ROOT '/fsw/gdn/gal' ]);
addpath([ NIMBUS_ROOT '/fsw/act' ]);

% vehicle control loop
addpath([ NIMBUS_ROOT '/fsw/pcs' ]);
addpath([ NIMBUS_ROOT '/fsw/tcs' ]);

% control
addpath([ NIMBUS_ROOT '/fsw/cnt' ]);
addpath([ NIMBUS_ROOT '/fsw/cnt/csc_ppc_phase_plane_ctrl' ]);

% Scenarios
scenario_dirs = dir([ NIMBUS_ROOT '/scenarios']);
for i=3:length(scenario_dirs)
    if scenario_dirs(i).isdir
        addpath([ NIMBUS_ROOT '/scenarios/' scenario_dirs(i).name]);
    end
end

% Telemetry processing
addpath([ NIMBUS_ROOT '/telemetry_processing' ]);

addpath([ NIMBUS_ROOT '/' ]);

% C&T Dictionary
CLAMPS_ROOT = [ NIMBUS_ROOT '/../../clamps' ];
assignin('base','CLAMPS_ROOT',CLAMPS_ROOT);
setenv('CLAMPS_ROOT',CLAMPS_ROOT);
addpath(CLAMPS_ROOT);

% Mex all needed s-functions
mex_all_sfun;

% Apply patches to MATLAB because it hates us
apply_patches;

end

