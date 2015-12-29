
MC_ROOT = fileparts(mfilename('fullpath'));
setenv('MC_ROOT', MC_ROOT);

% add to path
addpath([ MC_ROOT '/' ]);

% % addition folders: set relative and uncomment when needed
% addpath([ MC_ROOT 'my_new_folder' ]);