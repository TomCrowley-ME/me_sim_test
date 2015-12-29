%% Link Figure X-Axes.
%
% Given a figure number, or a list of figure numbrers,
% links the specified axes (or X axis if none are supplied)
% of all axes in all subplots of that figure (or all those figures).

function link_fig_axes(varargin)
    % We can get 0, 1, or 2 arguments
    if nargin > 2
        error('link_fig_axes: to many arguments');
    else
        % If no arguments, then assume [] for fig
        if nargin > 0
            fig = varargin{1};
        else
            fig = [];
        end

        % If there's a second argument, it's the axes to link
        if nargin == 2
            axes_to_link = varargin{2};
        else
            axes_to_link = 'x';
        end
    end

    if isempty(fig)
        
        % Figure Selection.
        %
        % If the list of figures is empty, then link the X axis
        % of all subplots in the current figure.

        fig = get(0,'CurrentFigure');
    end

    % Find axis objects.
    %
    % This will 
    %
    ax = findobj(fig,'Type','Axes');

    % Remove 'NonDataObject' tagged objects
    % from the list. This is apparently the
    % recommended way to do it.
    %
    nondatachild = logical([]);
    for k=length(ax):-1:1
        nondatachild(k) = isappdata(ax(k),'NonDataObject');
    end
    ax(nondatachild) = [];

    % Now go do the real work.
    %
    linkaxes(ax, axes_to_link);
