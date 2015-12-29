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
% rot_angles_to_dcm.m                                                     %
%                                                                         %
% Create direction cosine matrix from rotation angles                     %
% Euler rotation sequence used in 'zyx'                                   %
%                                                                         %
% Input: [euler_z euler_y euler_x]                                        %
% Output: [ dcm ]                                                         %
%                                                                         %
% 07/22/14                                                                %
%-------------------------------------------------------------------------%

function dcm = rot_angles_to_dcm( eulers )


    dcm = zeros(3,3);
    
    cang = cos( eulers );
    sang = sin( eulers );

            %     [          cy*cz,          cy*sz,            -sy]
            %     [ sy*sx*cz-sz*cx, sy*sx*sz+cz*cx,          cy*sx]
            %     [ sy*cx*cz+sz*sx, sy*cx*sz-cz*sx,          cy*cx]

            dcm(1,1) = cang(:,2).*cang(:,1);
            dcm(1,2) = cang(:,2).*sang(:,1);
            dcm(1,3) = -sang(:,2);
            dcm(2,1) = sang(:,3).*sang(:,2).*cang(:,1) - cang(:,3).*sang(:,1);
            dcm(2,2) = sang(:,3).*sang(:,2).*sang(:,1) + cang(:,3).*cang(:,1);
            dcm(2,3) = sang(:,3).*cang(:,2);
            dcm(3,1) = cang(:,3).*sang(:,2).*cang(:,1) + sang(:,3).*sang(:,1);
            dcm(3,2) = cang(:,3).*sang(:,2).*sang(:,1) - sang(:,3).*cang(:,1);
            dcm(3,3) = cang(:,3).*cang(:,2);
