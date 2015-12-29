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

figure
subplot(311),plot(UnitTests.Atmosphere.Density.Data,UnitTests.Atmosphere.Alt.Data),grid,xlabel('density, kg/m3')
title('Atmosphere versus Altitude'),set(gcf,'Name','Atmosphere')
subplot(312),plot(UnitTests.Atmosphere.Pressure.Data,UnitTests.Atmosphere.Alt.Data),grid,xlabel('pressure, Pa')
subplot(313),plot(UnitTests.Atmosphere.Sound.Data,UnitTests.Atmosphere.Alt.Data),grid,xlabel('speed of sound, m/s')

