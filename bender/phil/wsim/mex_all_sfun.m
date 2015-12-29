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
% mex_all_sfun.m                                                          %
%                                                                         %
% run from any directory: should pick up pathing and put mex files back   %
% in the appropriate location                                             %
% 11/12/09                                                                %
%-------------------------------------------------------------------------%

function mex_all_sfun(varargin)

    flag = '';

    if nargin > 0
        if ischar(varargin{1}) && strcmp(varargin{1}, '-f')
            flag = '-f';
        end
    end

%-------------------------------------------------------------------------%
% homography estimation using openCV

    mex_hmg(flag);

%-------------------------------------------------------------------------%
% ORB feature detection using OpenCV
    mex_orb(flag);

%-------------------------------------------------------------------------%
% Image request code with MEME
    mex_tcp(flag);

 %-------------------------------------------------------------------------%
 % JPL SPICE Matlab Toolbox
    mex_mice(flag);
    
end