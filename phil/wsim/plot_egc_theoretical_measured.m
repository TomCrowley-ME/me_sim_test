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

conversion_Pc_to_Thrust
figure;plot(telem.tcs.press_chamber.Time,Thrust_out,'linewidth',2);hold on;plot(telem.est.mass*9.81*.937,'r','linewidth',2);grid;title('Telem Thrust From Pc vs. Theoretical (93.7%)');xlabel('Time (sec)');ylabel('Thrust (N)')
figure;plot(telem.tcs.press_chamber.Time,Thrust_out,'linewidth',2);hold on;plot(telem.egc.desired_thrust,'r','linewidth',2);grid;title('Telem Thrust From Pc vs. Theoretical (whatever we told it)');xlabel('Time (sec)');ylabel('Thrust (N)')