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


%
% Thruster geometry based torque specification for baseline nimbus lander
% Author: Nilesh V Kulkarni 8/24/13
% 

cac_thruster1_trq = cross((psp_thruster1_position - [emp_cgx_location_fillfrac_100 emp_cgy_location_fillfrac_100 emp_cgz_location_fillfrac_100]), psp_thruster1_orientation);
cac_thruster2_trq = cross((psp_thruster2_position - [emp_cgx_location_fillfrac_100 emp_cgy_location_fillfrac_100 emp_cgz_location_fillfrac_100]), psp_thruster2_orientation);
cac_thruster3_trq = cross((psp_thruster3_position - [emp_cgx_location_fillfrac_100 emp_cgy_location_fillfrac_100 emp_cgz_location_fillfrac_100]), psp_thruster3_orientation);
cac_thruster4_trq = cross((psp_thruster4_position - [emp_cgx_location_fillfrac_100 emp_cgy_location_fillfrac_100 emp_cgz_location_fillfrac_100]), psp_thruster4_orientation);
cac_thruster5_trq = cross((psp_thruster5_position - [emp_cgx_location_fillfrac_100 emp_cgy_location_fillfrac_100 emp_cgz_location_fillfrac_100]), psp_thruster5_orientation);
cac_thruster6_trq = cross((psp_thruster6_position - [emp_cgx_location_fillfrac_100 emp_cgy_location_fillfrac_100 emp_cgz_location_fillfrac_100]), psp_thruster6_orientation);
cac_thruster7_trq = cross((psp_thruster7_position - [emp_cgx_location_fillfrac_100 emp_cgy_location_fillfrac_100 emp_cgz_location_fillfrac_100]), psp_thruster7_orientation);
cac_thruster8_trq = cross((psp_thruster8_position - [emp_cgx_location_fillfrac_100 emp_cgy_location_fillfrac_100 emp_cgz_location_fillfrac_100]), psp_thruster8_orientation);
cac_thruster9_trq = cross((psp_thruster9_position - [emp_cgx_location_fillfrac_100 emp_cgy_location_fillfrac_100 emp_cgz_location_fillfrac_100]), psp_thruster9_orientation);
cac_thruster10_trq = cross((psp_thruster10_position - [emp_cgx_location_fillfrac_100 emp_cgy_location_fillfrac_100 emp_cgz_location_fillfrac_100]), psp_thruster10_orientation);
cac_thruster11_trq = cross((psp_thruster11_position - [emp_cgx_location_fillfrac_100 emp_cgy_location_fillfrac_100 emp_cgz_location_fillfrac_100]), psp_thruster11_orientation);
cac_thruster12_trq = cross((psp_thruster12_position - [emp_cgx_location_fillfrac_100 emp_cgy_location_fillfrac_100 emp_cgz_location_fillfrac_100]), psp_thruster12_orientation);

% psp_thruster25_trq = cross((psp_thruster25_position - [emp_cgx_location_fillfrac_100 emp_cgy_location_fillfrac_100 emp_cgz_location_fillfrac_100]), psp_thruster25_orientation);

                     
cac_coarse_trq_matx = [cac_thruster1_trq; cac_thruster2_trq; cac_thruster3_trq; cac_thruster4_trq; cac_thruster5_trq; cac_thruster6_trq;...
                       cac_thruster7_trq; cac_thruster8_trq; cac_thruster9_trq; cac_thruster10_trq; cac_thruster11_trq; cac_thruster12_trq ];
                     


% cac_coarse_thruster_force = psp_coarse_acs_thrust/6;
cac_coarse_thruster_force = psp_coarse_acs_thrust;

cac_coarse_thruster_force_axial = cac_coarse_thruster_force*[cosd(15) 1 cosd(15) cosd(15) 1 cosd(15) cosd(15) 1 cosd(15) cosd(15) 1 cosd(15) ];

cac_coarse_thruster_trq_x = 0;
for i = 1:size(cac_thruster_alloc_coarse_x_plus,2)
    
    cac_coarse_thruster_trq_x = cac_coarse_thruster_trq_x + cac_coarse_thruster_force*cac_coarse_trq_matx(cac_thruster_alloc_coarse_x_plus(i),1);
    
end
   
cac_coarse_thruster_trq_y = 0;
for i = 1:size(cac_thruster_alloc_coarse_y_plus,2)
    
    cac_coarse_thruster_trq_y = cac_coarse_thruster_trq_y + cac_coarse_thruster_force*cac_coarse_trq_matx(cac_thruster_alloc_coarse_y_plus(i),2);
    
end

cac_coarse_thruster_trq_z = 0;
for i = 1:size(cac_thruster_alloc_coarse_z_plus,2)
   
    cac_coarse_thruster_trq_z = cac_coarse_thruster_trq_z + cac_coarse_thruster_force*cac_coarse_trq_matx(cac_thruster_alloc_coarse_z_plus(i),3);
    
end

cac_total_trq_axial_force_matx = [cac_coarse_thruster_force*cac_coarse_trq_matx';cac_coarse_thruster_force_axial];
cac_trq_axial_force_pinv_matx = pinv(cac_total_trq_axial_force_matx);
cac_saturation_axial_force = 8*cac_coarse_thruster_force*cosd(15)+4*cac_coarse_thruster_force;



%%%%%%%%%%%%%%% END SCRIPT %%%%%%%%%%%%%%%

% 
% cac_coarse_thruster_trq_x = 0;
% for i = 1:size(cac_thruster_alloc_coarse_x_plus,2)
%     
%     cac_coarse_thruster_trq_x = cac_coarse_thruster_trq_x + psp_coarse_thruster_force*psp_thruster_trq_matx(cac_thruster_alloc_coarse_x_plus(i),1);
%     
% end
%    
% cac_coarse_thruster_trq_y = 0;
% for i = 1:size(cac_thruster_alloc_coarse_y_plus,2)
%     
%     cac_coarse_thruster_trq_y = cac_coarse_thruster_trq_y + psp_coarse_thruster_force*psp_thruster_trq_matx(cac_thruster_alloc_coarse_y_plus(i),2);
%     
% end
% 
% cac_coarse_thruster_trq_z = 0;
% for i = 1:size(cac_thruster_alloc_coarse_z_plus,2)
%     
%     cac_coarse_thruster_trq_z = cac_coarse_thruster_trq_z + psp_coarse_thruster_force*psp_thruster_trq_matx(cac_thruster_alloc_coarse_z_plus(i),3);
%     
% end

