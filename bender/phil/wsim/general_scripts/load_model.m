
%% load_model.m
%
% Loads a model if needed, else just exits. This
% is for routines that need to walk the whole model

function load_model(varargin) % optional args model_name

% Default arg(s)
if nargin > 0
    model_name = varargin{1};
else
    model_name = 'nimbus';
end

try
    tmodel_loaded = evalin('base', 'model_loaded');
catch
    tmodel_loaded = 'xXxXx';
end

if ( strcmp(tmodel_loaded, model_name) < 1)

    load_system (model_name);
    assignin('base', 'model_loaded', model_name);
    fprintf(1, 'Model %s loaded\n', model_name);
end

end
