%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2010 - 2015 Moon Express, Inc.
% All Rights Reserved.
%
% * NOTICE:  All information contained herein is, and remains
% * the proprietary property of Moon Express Inc.
% * Dissemination of this information or reproduction of this material
% * is strictly forbidden unless prior written permission is obtained
% * from Moon Express Inc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-------------------------------------------------------------------------%
% overlay_events.m                                                        %
%                                                                         %
% Overlays event information over plots                                   %
% 12/11/14                                                                %
%-------------------------------------------------------------------------%

function overplot_key_times(time_window, color_string)

% x_lim = [12.6 26.9];
% x_lim = [19.1 35.4];

for ii = 1 : length(time_window)
    
   
    x_patch = time_window{ii}([1 2 2 1]) ;
    
    figs=get(0,'Children');
    
    for jj = 1 : length(figs)
        
        % figure out if there are subfigures
        
        axes_objs = findobj(figs(jj),'Type','axes');
        
        for kk = 1 : length(axes_objs)
            
            axes(axes_objs(kk))
            y_lim = axes_objs(kk).YLim;
            y_patch = y_lim([1 1 2 2]);
            p = patch(x_patch,y_patch,1,'FaceColor', color_string{ii},'EdgeColor','none');
            set(p, 'FaceAlpha', 0.075);
            uistack(p, 'bottom');
            
        end
        
        
        print('-dpng','-r300', axes_objs(kk).Title.String)
        
    end
    
end