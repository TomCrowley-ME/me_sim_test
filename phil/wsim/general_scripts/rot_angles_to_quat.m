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

function quat  = rot_angles_to_quat(rot_angles_zyx)

rotz = rot_angles_zyx(1);
roty = rot_angles_zyx(2);
rotx = rot_angles_zyx(3);


cgamma = cos( rotx/2 );
cbeta  = cos( roty/2 );
calpha = cos( rotz/2 );
sgamma = sin( rotx/2 );
sbeta  = sin( roty/2 );
salpha = sin( rotz/2 );



quat = [ calpha*cbeta*sgamma-salpha*sbeta*cgamma,...
         calpha*sbeta*cgamma+salpha*cbeta*sgamma,...
         salpha*cbeta*cgamma-calpha*sbeta*sgamma,...
         calpha*cbeta*cgamma+salpha*sbeta*sgamma ];