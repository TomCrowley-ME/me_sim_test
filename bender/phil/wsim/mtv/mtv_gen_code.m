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
% mtv_gen_code.m                                                          %
%                                                                         %
% Generates code for the mtv1 model. Each argument is interpreted as a    %
% generation target. Three special targets exist:                         %
%       * ofsw    --  Generates code for all apps tagged OFSW             %
%       * gsse    --  Generates code for all apps tagged GSSE             %
%       * headers --  Generates all model interface headers               %
% Otherwise, input arguments should be the acronyms for each desired app  %
% (ie, <acronym> in csc_<acronym>_<full_name>).                           %
%                                                                         %
% This script should be invoked as follows:                               %
%   $ matlab -nosplash -nodesktop -logfile gen_csc_code.log \             %
%      -r "mtv_gen_code('ofsw', 'headers')"                               %
%                                                                         %
% 10/31/13                                                                %
% mikestewart@moonexpress.com                                             %
%-------------------------------------------------------------------------%

function mtv_gen_code(varargin)

    % Helper function to grab short app names
    function ac = block_acronym(block_name)
        ac = regexpi(block_name, 'csc_([A-Za-z]+)_', 'tokens', 'once');
        if ~isempty(ac)
            ac = ac{1};
        end
    end

%% Necessary setup...
cd('..')
evalin('base', 'nimbus_set_path')
evalin('base', 'mtv_add_path')
cd('mtv')
evalin('base', 'mtv_init_hack')

NIMBUS_ROOT = getenv('NIMBUS_ROOT');
MTV_ROOT = getenv('MTV_ROOT');

%% Create a temporary log file
log_dir = fullfile(NIMBUS_ROOT, 'common', 'codegen');
logname = fullfile(log_dir, 'codegen.log');
old_logname = [logname '.bak'];

if ~exist(old_logname, 'file')
    % No backup file found
    if exist(logname, 'file')
        % Current codegen log does exist, though, so back it up
        movefile(logname, old_logname);
    end
end

[~, revision] = system(['hg id -i --cwd ' NIMBUS_ROOT]);
if isempty(revision)
    revision = 'UNKNOWN';
end

logfile = fopen(logname, 'w+');
fprintf(logfile, '------------ MTV CODEGEN  %s  %s ------------\n', strtrim(revision), datestr(now));

%% Determine build jobs
job_list = {};
generate_headers = false;
generate_all_ofsw = false;
generate_all_gsse = false;

if nargin > 0
    job_list = varargin;

    % First extract bundle targets (headers, ofsw, gsse)
    header_index = find(strcmp(job_list, 'headers'));
    if ~isempty(header_index)
        job_list(header_index) = [];
        generate_headers = true;
    end

    ofsw_index = find(strcmp(job_list, 'ofsw'));
    if ~isempty(ofsw_index)
        job_list(ofsw_index) = [];
        generate_all_ofsw = true;
    end

    gsse_index = find(strcmp(job_list, 'gsse'));
    if ~isempty(gsse_index)
        job_list(gsse_index) = [];
        generate_all_gsse = true;
    end

    % Everything now remaining in job_list needs to be an application (that
    % has been tagged OFSW or GSSE)'s acronym
else
    % No arguments, so build everything
    generate_headers = true;
    generate_all_ofsw = true;
    generate_all_gsse = true;
end

% A list of applications to generate code for
build_targets = {};
successful_targets = {};
failed_targets = {};

%% Generate code for each OFSW subsystem
if generate_all_ofsw || generate_all_gsse || ~isempty(job_list)
    % We've got some codegen work to do, so start off by finding candidate
    % subsystems
    blks = find_system('mtv1','SearchDepth','2','FollowLinks','on','BlockType','SubSystem');

    for i=1:length(blks)
        tag = get_param(blks{i}, 'Tag');
        options = regexp(tag, '(?<key>\w+)\s*=\s*(?<value>\w+)|(?<key>\w+)(?<value>)','names');

        is_ofsw = any(ismember({options.key},'OFSW'));
        is_gsse = any(ismember({options.key},'GSSE'));

        if is_ofsw || is_gsse
            % We've got a tagged subsystem, so check to see if it's in our
            % job list
            short_name = block_acronym(get_param(blks{i}, 'Name'));
            job_index = find(strcmp(short_name, job_list));

            % Remove the job from the job list
            job_list(job_index) = [];

            if ~isempty(job_index) || (is_ofsw && generate_all_ofsw) || (is_gsse && generate_all_gsse)
                % Either we've found something in the job list, or it's
                % been included in a build group, so add it to the build
                % targets list
                build_targets = [build_targets blks{i}];
            end
        end
    end

    % Not all of the requested jobs were valid -- error out
    if ~isempty(job_list)
        error(['Couldn''t find app(s) ' strjoin(job_list, ',')]);
    end

    for i=1:length(build_targets)
        % Generate code for all of our targets!
        try
            rtwbuild(build_targets{i});
            successful_targets{end+1} = build_targets{i};
        catch err
            failed_targets{end+1} = build_targets{i};
            fprintf(logfile, 'Exception building %s: %s\n', build_targets{i}, err.message);
        end
    end
end

if ~isempty(successful_targets)
    fprintf(logfile, 'Generated code for:\n');
    for i=1:length(successful_targets)
        fprintf(logfile, '    %s\n', successful_targets{i});
    end
end

if ~isempty(failed_targets)
    fprintf(logfile, '\nFailed code generation for:\n');
    for i=1:length(failed_targets)
        fprintf(logfile, '  %s\n', failed_targets{i});
    end
end

%% Generate headers

if generate_headers
    model_built = false;
    if isempty(successful_targets)
        % Model probably hasn't been compiled yet -- we need to do that first
        try
            set_param('mtv1','SimulationCommand','update');
            model_built = true;
        catch err
            fprintf(logfile, '\nFailed generating headers (model won''t compile)\n');
        end
    else
        model_built = true;
    end

    if model_built
        fsw_get_model_rates('mtv1', 'inc/csc_model_hz.h');
        fprintf(logfile, '\nGenerated model headers\n');
    end
end

%% Append old log file contents
fprintf(logfile, '\n\n');

if exist(old_logname, 'file')
    old_logfile = fopen(old_logname, 'r');

    line = fgets(old_logfile);
    while ischar(line)
        fwrite(logfile, line);
        line = fgets(old_logfile);
    end

    fclose(old_logfile);
    delete(old_logname);
end

fclose(logfile);

% If we've been called from the command line (presumably from a Makefile),
% exit out of MATLAB
if ~usejava('desktop')
    quit;
end

end
