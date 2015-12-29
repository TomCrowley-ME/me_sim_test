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
% bgfill.m                                                                %
%                                                                         %
% fills horizonal background regions of plots                             %
% 10/31/13                                                                %
% mikestewart@moonexpress.com                                             %
%-------------------------------------------------------------------------%

function bgfill(region, color, alpha)

if ~(isnumeric(region) && length(region)==2)
    warning('Fill region needs to be a 2-element ascending numeric array');
    return;
end

if region(1) > region(2)
    return;
end

xl = xlim;
yl = ylim;
unhold = 0;

if ~ishold
    unhold = 1;
    hold all;
end

p = patch([region(1) region(2) region(2) region(1)], [yl(1) yl(1) yl(2) yl(2)], color, 'EdgeColor', 'none');
set(p, 'FaceAlpha', alpha);
uistack(p, 'bottom');

xlim(xl);
if unhold
    hold off;
end

end