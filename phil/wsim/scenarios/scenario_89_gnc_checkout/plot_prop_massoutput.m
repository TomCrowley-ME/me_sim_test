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

% figure
% dry_mass=[175.8 175.8 175.8 175.8 175.8 ];
% prop_mass_used=[18.2452 18.5758 18.9064 19.2268 19.4893 19.796];
% plot(wet_mass,prop_mass_used)
% grid,xlabel('total mass, kg'),ylabel('prop mass used, kg')
% title('Propellant Usage for MTV 10 sec hop')
% 

%dry_mass=[150 155 160 165 170 175.8 180 185 190 195 200];
%prop_mass_used=[14.0144 13.9478 14.100 14.147 14.197 14.327 14.6435 15.326 15.4027 15.5168 16.0253];
%mass.dry=[120 125 130 135 140 145 150 155 160 165 170 175 180 185 190 195 200];
%mass.prop_used=[8.3 9.5 10.5 10.931 11.3413 11.8233 12.4439 12.996 13.1158 13.7305 14.1181 14.5437 14.6435 15.326 15.4027 15.5168 16.0253];


figure
mass.dry=[135 140 145 150 155 160 165 170 175 180 185 190 195 200];
mass.prop_used=[10.8 11.3413 11.8233 12.4439 12.996 13.1158 13.7305 14.1181 14.5437 14.6435 15.326 15.4027 15.5168 16.0253];
plot(mass.dry,mass.prop_used,'b-','Linewidth',4)
grid,xlabel('dry mass, kg'),ylabel('prop mass used, kg')
title('Propellant Usage for MTV 10 sec hop')

xx=100:.1:200;
yy=interp1(mass.dry,mass.prop_used,xx,'linear','extrap');
hold
plot(xx,yy,'r--','Linewidth',2)
