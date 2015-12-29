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


vac_vernier_thruster_force = psp_vernier_acs_thrust;

vac_thruster13_trq = cross((psp_thruster13_position - emp_cgx_location_fillfrac_100), psp_thruster13_orientation);
vac_thruster14_trq = cross((psp_thruster14_position - emp_cgx_location_fillfrac_100), psp_thruster14_orientation);
vac_thruster15_trq = cross((psp_thruster15_position - emp_cgx_location_fillfrac_100), psp_thruster15_orientation);
vac_thruster16_trq = cross((psp_thruster16_position - emp_cgx_location_fillfrac_100), psp_thruster16_orientation);
vac_thruster17_trq = cross((psp_thruster17_position - emp_cgx_location_fillfrac_100), psp_thruster17_orientation);
vac_thruster18_trq = cross((psp_thruster18_position - emp_cgx_location_fillfrac_100), psp_thruster18_orientation);
vac_thruster19_trq = cross((psp_thruster19_position - emp_cgx_location_fillfrac_100), psp_thruster19_orientation);
vac_thruster20_trq = cross((psp_thruster20_position - emp_cgx_location_fillfrac_100), psp_thruster20_orientation);
vac_thruster21_trq = cross((psp_thruster21_position - emp_cgx_location_fillfrac_100), psp_thruster21_orientation);
vac_thruster22_trq = cross((psp_thruster22_position - emp_cgx_location_fillfrac_100), psp_thruster22_orientation);
vac_thruster23_trq = cross((psp_thruster23_position - emp_cgx_location_fillfrac_100), psp_thruster23_orientation);
vac_thruster24_trq = cross((psp_thruster24_position - emp_cgx_location_fillfrac_100), psp_thruster24_orientation);


vac_vernier_trq_matx = [ vac_thruster13_trq; vac_thruster14_trq; vac_thruster15_trq; vac_thruster16_trq; vac_thruster17_trq; vac_thruster18_trq;...
                         vac_thruster19_trq; vac_thruster20_trq; vac_thruster21_trq; vac_thruster22_trq; vac_thruster23_trq; vac_thruster24_trq ];
                     

vac_vernier_thruster_trq_x = 0;
for i = 1:size(vac_thruster_alloc_vernier_x_plus,2)
    
    vac_vernier_thruster_trq_x = vac_vernier_thruster_trq_x + vac_vernier_thruster_force*vac_vernier_trq_matx(vac_thruster_alloc_vernier_x_plus(i)-vac_thruster_id_offset,1);
    
end
   
vac_vernier_thruster_trq_y = 0;
for i = 1:size(vac_thruster_alloc_vernier_y_plus,2)
    
    vac_vernier_thruster_trq_y = vac_vernier_thruster_trq_y + vac_vernier_thruster_force*vac_vernier_trq_matx(vac_thruster_alloc_vernier_y_plus(i)-vac_thruster_id_offset,2);
    
end

vac_vernier_thruster_trq_z = 0;
for i = 1:size(vac_thruster_alloc_vernier_z_plus,2)
    
    vac_vernier_thruster_trq_z = vac_vernier_thruster_trq_z + vac_vernier_thruster_force*vac_vernier_trq_matx(vac_thruster_alloc_vernier_z_plus(i)-vac_thruster_id_offset,3);
    
end

