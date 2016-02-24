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

figure;plot(t,rtk_pos_topo(:,1)-rtk_pos_topo(1,1),'linewidth',2);grid;hold on;plot(t,rtk_pos_topo(:,2)-rtk_pos_topo(1,2),'g','linewidth',2);plot(t,rtk_pos_topo(:,3)-kfl_topo_to_site_rel(3),'r','linewidth',2)
title('True Position in Topocentric Frame');xlabel('Time (sec)');ylabel('Position (meters)')
figure;plot(t,est_pos_topo(:,1)-rtk_pos_topo(1,1),'linewidth',2);grid;hold on;plot(t,est_pos_topo(:,2)-est_pos_topo(1,2),'g','linewidth',2);plot(t,est_pos_topo(:,3)-kfl_topo_to_site_rel(3),'r','linewidth',2)
title('Estimated Position in Topocentric Frame');xlabel('Time (sec)');ylabel('Position (meters)')
figure;plot(t,rtk_pos_topo(:,1)-rtk_pos_topo(1,1),'linewidth',2);grid;hold on;plot(t,rtk_pos_topo(:,2)-rtk_pos_topo(1,2),'g','linewidth',2);plot(t,rtk_pos_topo(:,3)-kfl_topo_to_site_rel(3),'r','linewidth',2)
M = {'X-Topocentric','Y-Topocentric','Altitude'};
if plot_est 
plot(t,est_pos_topo(:,1)-rtk_pos_topo(1,1));plot(t,est_pos_topo(:,2)-est_pos_topo(1,2),'g');plot(t,est_pos_topo(:,3)-kfl_topo_to_site_rel(3),'r')
    M = {'X-Topocentric','Y-Topocentric','Altitude','Estimated X-Topocentric','Estimated Y-Topocentric','Estimated Altitude'};
end
legend(M,'Location','SouthEast','fontsize',14);
title('True and Estimated Position in Topocentric Frame');xlabel('Time (sec)');ylabel('Position (meters)')