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

function hovercraft_quat  = eul2quat(hovercraft_eul_zyx)

rotz = hovercraft_eul_zyx(1);
roty = hovercraft_eul_zyx(2);
rotx = hovercraft_eul_zyx(3);

q0 = cos(rotz/2)*cos(roty/2)*cos(rotx/2) + sin(rotz/2)*sin(roty/2)*sin(rotx/2);
q1 = cos(rotz/2)*cos(roty/2)*sin(rotx/2) - sin(rotz/2)*sin(roty/2)*cos(rotx/2);
q2 = cos(rotz/2)*sin(roty/2)*cos(rotx/2) + sin(rotz/2)*cos(roty/2)*sin(rotx/2);
q3 = sin(rotz/2)*cos(roty/2)*cos(rotx/2) - cos(rotz/2)*sin(roty/2)*sin(rotx/2);

hovercraft_quat = [q1 q2 q3 q0]';
hovercraft_quat = hovercraft_quat/norm(hovercraft_quat);