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


%% Begin mas prep file 
% Dependencies: 
% csu_mpl_mass_properties_init
%
% Source: 

%%
% Lander CG Location
mpl_cg_wet_dry = [mpl_cgx_location_fillfrac_0, mpl_cgx_location_fillfrac_100;   ...
                  mpl_cgy_location_fillfrac_0, mpl_cgy_location_fillfrac_100; ...
                  mpl_cgz_location_fillfrac_0, mpl_cgz_location_fillfrac_100];

% Lander Mass
mpl_mass_wet_dry = [mpl_mass_fillfrac_0, mpl_mass_fillfrac_100];


% Lander Inertia Tensor
mpl_inertia_fillfrac_100 = [mpl_Ixx_fillfrac_100, mpl_Iyy_fillfrac_100, mpl_Izz_fillfrac_100, mpl_Ixy_fillfrac_100, mpl_Iyz_fillfrac_100, mpl_Ixz_fillfrac_100]';
mpl_inertia_fillfrac_0   = [mpl_Ixx_fillfrac_0,   mpl_Iyy_fillfrac_0,   mpl_Izz_fillfrac_0,   mpl_Ixy_fillfrac_0,   mpl_Iyz_fillfrac_0,   mpl_Ixz_fillfrac_0]';

mpl_inertia_wet_dry = [mpl_inertia_fillfrac_0, mpl_inertia_fillfrac_100];

%%%%%%%%%%%%%%% END SCRIPT %%%%%%%%%%%%%%%

%% initialize mass properties
mpl_mass_dry    = mpl_mass_fillfrac_0;
mpl_cg_dry      = [mpl_cgx_location_fillfrac_0 mpl_cgy_location_fillfrac_0 mpl_cgz_location_fillfrac_0];
mpl_inertia_dry = buildInertiaMatrix(mpl_inertia_fillfrac_0([1 2 3 4 6 5]));

% start with vehicle dry mass properties
mpl_mass_initial    = mpl_mass_dry;
mpl_cg_initial      = mpl_cg_dry;
mpl_inertia_initial = mpl_inertia_dry;

%% initialize HTP mass properties

% fluid inertias at center of tank, Ixx, Iyy, Izz, (Ixy, Ixz, Iyz optional)  
mpl_htp_inertia_fillfrac_0   = mpl_htp_mass_fillfrac_0  *[5/8*mpl_htp_tank_minor_radius^2+1/2*mpl_htp_tank_major_radius^2,...
                                                          5/8*mpl_htp_tank_minor_radius^2+1/2*mpl_htp_tank_major_radius^2,...
                                                          3/4*mpl_htp_tank_minor_radius^2+    mpl_htp_tank_major_radius^2];
mpl_htp_inertia_fillfrac_100 = mpl_htp_mass_fillfrac_100*[5/8*mpl_htp_tank_minor_radius^2+1/2*mpl_htp_tank_major_radius^2,...
                                                          5/8*mpl_htp_tank_minor_radius^2+1/2*mpl_htp_tank_major_radius^2,...
                                                          3/4*mpl_htp_tank_minor_radius^2+    mpl_htp_tank_major_radius^2];
% move inertias from tank center to origin
mpl_htp_inertia_fillfrac_0   = buildInertiaMatrix(mpl_htp_inertia_fillfrac_0)   + mpl_htp_mass_fillfrac_0*buildParallelAxisMatrix(mpl_htp_tank_center);
mpl_htp_inertia_fillfrac_100 = buildInertiaMatrix(mpl_htp_inertia_fillfrac_100) + mpl_htp_mass_fillfrac_100*buildParallelAxisMatrix(mpl_htp_tank_center);

% build tables
mpl_htp_mass_table    = [ mpl_htp_mass_fillfrac_0;   mpl_htp_mass_fillfrac_100 ];
mpl_htp_cg_table      = [ mpl_htp_cg_fillfrac_0;     mpl_htp_cg_fillfrac_100   ];
mpl_htp_inertia_table = [ buildInertiaVector(mpl_htp_inertia_fillfrac_0);  buildInertiaVector(mpl_htp_inertia_fillfrac_100) ];

% initial fluid CG and inertia
mpl_htp_cg_initial      = mpl_htp_tank_center + interp1(mpl_htp_mass_table, mpl_htp_cg_table, mpl_htp_mass_initial,'linear');
mpl_htp_inertia_initial = buildInertiaMatrix(interp1(mpl_htp_mass_table, mpl_htp_inertia_table, mpl_htp_mass_initial,'linear'));

%% Add HTP fluids to vehicle mass properties
[mpl_mass_initial, mpl_cg_initial, mpl_inertia_initial] =...
      configureMassProps( 'Add',...
      mpl_htp_mass_initial, mpl_htp_cg_initial, mpl_htp_inertia_initial,...
      mpl_mass_initial, mpl_cg_initial, mpl_inertia_initial );

%% initialize RP1 mass properties

% fluid inertias at center of tank, Ixx, Iyy, Izz, (Ixy, Ixz, Iyz optional)  
mpl_rp1_inertia_fillfrac_0   = mpl_rp1_mass_fillfrac_0  *[5/8*mpl_rp1_tank_minor_radius^2+1/2*mpl_rp1_tank_major_radius^2,...
                                                          5/8*mpl_rp1_tank_minor_radius^2+1/2*mpl_rp1_tank_major_radius^2,...
                                                          3/4*mpl_rp1_tank_minor_radius^2+    mpl_rp1_tank_major_radius^2];
mpl_rp1_inertia_fillfrac_100 = mpl_rp1_mass_fillfrac_100*[5/8*mpl_rp1_tank_minor_radius^2+1/2*mpl_rp1_tank_major_radius^2,...
                                                          5/8*mpl_rp1_tank_minor_radius^2+1/2*mpl_rp1_tank_major_radius^2,...
                                                          3/4*mpl_rp1_tank_minor_radius^2+    mpl_rp1_tank_major_radius^2];
% move inertias from tank center to origin
mpl_rp1_inertia_fillfrac_0   = buildInertiaMatrix(mpl_rp1_inertia_fillfrac_0)   + mpl_rp1_mass_fillfrac_0*buildParallelAxisMatrix(mpl_rp1_tank_center);
mpl_rp1_inertia_fillfrac_100 = buildInertiaMatrix(mpl_rp1_inertia_fillfrac_100) + mpl_rp1_mass_fillfrac_100*buildParallelAxisMatrix(mpl_rp1_tank_center);

% build tables
mpl_rp1_mass_table    = [ mpl_rp1_mass_fillfrac_0;   mpl_rp1_mass_fillfrac_100 ];
mpl_rp1_cg_table      = [ mpl_rp1_cg_fillfrac_0;     mpl_rp1_cg_fillfrac_100   ];
mpl_rp1_inertia_table = [ buildInertiaVector(mpl_rp1_inertia_fillfrac_0);  buildInertiaVector(mpl_rp1_inertia_fillfrac_100) ];

% initial fluid CG and inertia
mpl_rp1_cg_initial      = mpl_rp1_tank_center + interp1(mpl_rp1_mass_table, mpl_rp1_cg_table, mpl_rp1_mass_initial,'linear');
mpl_rp1_inertia_initial = buildInertiaMatrix(interp1(mpl_rp1_mass_table, mpl_rp1_inertia_table, mpl_rp1_mass_initial,'linear'));

%% Add RP1 fluids to vehicle mass properties
[mpl_mass_initial, mpl_cg_initial, mpl_inertia_initial] =...
      configureMassProps( 'Add',...
      mpl_rp1_mass_initial, mpl_rp1_cg_initial, mpl_rp1_inertia_initial,...
      mpl_mass_initial, mpl_cg_initial, mpl_inertia_initial );

%% initialize N2 mass properties
% fluid masses
if ~isempty(mpl_gn2_mass_initial)
  mpl_gn2_mass_initial_tank1 = mpl_gn2_mass_initial/4;
  mpl_gn2_mass_initial_tank2 = mpl_gn2_mass_initial/4;
  mpl_gn2_mass_initial_tank3 = mpl_gn2_mass_initial/4;
  mpl_gn2_mass_initial_tank4 = mpl_gn2_mass_initial/4;
  
  mpl_gn2_mass_tank1 = mpl_gn2_mass_initial_tank1;
  mpl_gn2_mass_tank2 = mpl_gn2_mass_initial_tank2;
  mpl_gn2_mass_tank3 = mpl_gn2_mass_initial_tank3;
  mpl_gn2_mass_tank4 = mpl_gn2_mass_initial_tank4;
else
  mpl_gn2_mass_tank1 = mpl_gn2_mass_initial_tank1;
  mpl_gn2_mass_tank2 = mpl_gn2_mass_initial_tank2;
  mpl_gn2_mass_tank3 = mpl_gn2_mass_initial_tank3;
  mpl_gn2_mass_tank4 = mpl_gn2_mass_initial_tank4;
  mpl_gn2_mass_initial = mpl_gn2_mass_initial_tank1+...
                         mpl_gn2_mass_initial_tank2+...
                         mpl_gn2_mass_initial_tank3+...
                         mpl_gn2_mass_initial_tank4;
end

% fluid inertias at center of tank, Ixx, Iyy, Izz, (Ixy, Ixz, Iyz optional)  
mpl_gn2_inertia_fillfrac_0   = mpl_gn2_mass_fillfrac_0  *[1/4*mpl_gn2_tank_radius^2+1/3*mpl_gn2_tank_length^2,...
                                                          1/2*mpl_gn2_tank_radius^2,...
                                                          1/4*mpl_gn2_tank_radius^2+1/3*mpl_gn2_tank_length^2];
mpl_gn2_inertia_fillfrac_100 = mpl_gn2_mass_fillfrac_100*[1/4*mpl_gn2_tank_radius^2+1/3*mpl_gn2_tank_length^2,...
                                                          1/2*mpl_gn2_tank_radius^2,...
                                                          1/4*mpl_gn2_tank_radius^2+1/3*mpl_gn2_tank_length^2];

% rotate inertias from tank frame to vehicle frame
mpl_gn2_inertia_fillfrac_0_tank1   = euler2dcm(321,-atan2d(mpl_gn2_center_tank1(2),mpl_gn2_center_tank1(1)),0,0)*buildInertiaMatrix(mpl_gn2_inertia_fillfrac_0);
mpl_gn2_inertia_fillfrac_0_tank2   = euler2dcm(321,-atan2d(mpl_gn2_center_tank2(2),mpl_gn2_center_tank2(1)),0,0)*buildInertiaMatrix(mpl_gn2_inertia_fillfrac_0);
mpl_gn2_inertia_fillfrac_0_tank3   = euler2dcm(321,-atan2d(mpl_gn2_center_tank3(2),mpl_gn2_center_tank3(1)),0,0)*buildInertiaMatrix(mpl_gn2_inertia_fillfrac_0);
mpl_gn2_inertia_fillfrac_0_tank4   = euler2dcm(321,-atan2d(mpl_gn2_center_tank4(2),mpl_gn2_center_tank4(1)),0,0)*buildInertiaMatrix(mpl_gn2_inertia_fillfrac_0);

mpl_gn2_inertia_fillfrac_100_tank1 = euler2dcm(321,-atan2d(mpl_gn2_center_tank1(2),mpl_gn2_center_tank1(1)),0,0)*buildInertiaMatrix(mpl_gn2_inertia_fillfrac_100);
mpl_gn2_inertia_fillfrac_100_tank2 = euler2dcm(321,-atan2d(mpl_gn2_center_tank2(2),mpl_gn2_center_tank2(1)),0,0)*buildInertiaMatrix(mpl_gn2_inertia_fillfrac_100);
mpl_gn2_inertia_fillfrac_100_tank3 = euler2dcm(321,-atan2d(mpl_gn2_center_tank3(2),mpl_gn2_center_tank3(1)),0,0)*buildInertiaMatrix(mpl_gn2_inertia_fillfrac_100);
mpl_gn2_inertia_fillfrac_100_tank4 = euler2dcm(321,-atan2d(mpl_gn2_center_tank4(2),mpl_gn2_center_tank4(1)),0,0)*buildInertiaMatrix(mpl_gn2_inertia_fillfrac_100);

% move inertias from tank centers to origin
mpl_gn2_inertia_fillfrac_0_tank1   = mpl_gn2_inertia_fillfrac_0_tank1 + mpl_gn2_mass_fillfrac_0*buildParallelAxisMatrix(mpl_gn2_center_tank1);
mpl_gn2_inertia_fillfrac_0_tank2   = mpl_gn2_inertia_fillfrac_0_tank2 + mpl_gn2_mass_fillfrac_0*buildParallelAxisMatrix(mpl_gn2_center_tank2);
mpl_gn2_inertia_fillfrac_0_tank3   = mpl_gn2_inertia_fillfrac_0_tank3 + mpl_gn2_mass_fillfrac_0*buildParallelAxisMatrix(mpl_gn2_center_tank3);
mpl_gn2_inertia_fillfrac_0_tank4   = mpl_gn2_inertia_fillfrac_0_tank4 + mpl_gn2_mass_fillfrac_0*buildParallelAxisMatrix(mpl_gn2_center_tank4);

mpl_gn2_inertia_fillfrac_100_tank1 = mpl_gn2_inertia_fillfrac_100_tank1 + mpl_gn2_mass_fillfrac_100*buildParallelAxisMatrix(mpl_gn2_center_tank1);
mpl_gn2_inertia_fillfrac_100_tank2 = mpl_gn2_inertia_fillfrac_100_tank2 + mpl_gn2_mass_fillfrac_100*buildParallelAxisMatrix(mpl_gn2_center_tank2);
mpl_gn2_inertia_fillfrac_100_tank3 = mpl_gn2_inertia_fillfrac_100_tank3 + mpl_gn2_mass_fillfrac_100*buildParallelAxisMatrix(mpl_gn2_center_tank3);
mpl_gn2_inertia_fillfrac_100_tank4 = mpl_gn2_inertia_fillfrac_100_tank4 + mpl_gn2_mass_fillfrac_100*buildParallelAxisMatrix(mpl_gn2_center_tank4);

% build mass and CG tables
mpl_gn2_mass_table          = [ mpl_gn2_mass_fillfrac_0;     mpl_gn2_mass_fillfrac_100 ];
mpl_gn2_cg_table            = [ mpl_gn2_cg_fillfrac_0;       mpl_gn2_cg_fillfrac_100   ];
mpl_gn2_inertia_table_tank1 = [ buildInertiaVector(mpl_gn2_inertia_fillfrac_0_tank1);  buildInertiaVector(mpl_gn2_inertia_fillfrac_100_tank1) ];
mpl_gn2_inertia_table_tank2 = [ buildInertiaVector(mpl_gn2_inertia_fillfrac_0_tank2);  buildInertiaVector(mpl_gn2_inertia_fillfrac_100_tank2) ];
mpl_gn2_inertia_table_tank3 = [ buildInertiaVector(mpl_gn2_inertia_fillfrac_0_tank3);  buildInertiaVector(mpl_gn2_inertia_fillfrac_100_tank3) ];
mpl_gn2_inertia_table_tank4 = [ buildInertiaVector(mpl_gn2_inertia_fillfrac_0_tank4);  buildInertiaVector(mpl_gn2_inertia_fillfrac_100_tank4) ];

% fluid CGs
mpl_gn2_cg_initial_tank1 = mpl_gn2_center_tank1 + interp1(mpl_gn2_mass_table, mpl_gn2_cg_table, mpl_gn2_mass_tank1,'linear');
mpl_gn2_cg_initial_tank2 = mpl_gn2_center_tank2 + interp1(mpl_gn2_mass_table, mpl_gn2_cg_table, mpl_gn2_mass_tank2,'linear');
mpl_gn2_cg_initial_tank3 = mpl_gn2_center_tank3 + interp1(mpl_gn2_mass_table, mpl_gn2_cg_table, mpl_gn2_mass_tank3,'linear');
mpl_gn2_cg_initial_tank4 = mpl_gn2_center_tank4 + interp1(mpl_gn2_mass_table, mpl_gn2_cg_table, mpl_gn2_mass_tank4,'linear');

mpl_gn2_cg_tank1 = mpl_gn2_cg_initial_tank1;
mpl_gn2_cg_tank2 = mpl_gn2_cg_initial_tank2;
mpl_gn2_cg_tank3 = mpl_gn2_cg_initial_tank3;
mpl_gn2_cg_tank4 = mpl_gn2_cg_initial_tank4;

% fluid inertias
mpl_gn2_inertia_initial_tank1 = buildInertiaMatrix(interp1(mpl_gn2_mass_table, mpl_gn2_inertia_table_tank1, mpl_gn2_mass_tank1,'linear'));
mpl_gn2_inertia_initial_tank2 = buildInertiaMatrix(interp1(mpl_gn2_mass_table, mpl_gn2_inertia_table_tank2, mpl_gn2_mass_tank2,'linear'));
mpl_gn2_inertia_initial_tank3 = buildInertiaMatrix(interp1(mpl_gn2_mass_table, mpl_gn2_inertia_table_tank3, mpl_gn2_mass_tank3,'linear'));
mpl_gn2_inertia_initial_tank4 = buildInertiaMatrix(interp1(mpl_gn2_mass_table, mpl_gn2_inertia_table_tank4, mpl_gn2_mass_tank4,'linear'));

mpl_gn2_inertia_tank1 = mpl_gn2_inertia_initial_tank1;
mpl_gn2_inertia_tank2 = mpl_gn2_inertia_initial_tank2;
mpl_gn2_inertia_tank3 = mpl_gn2_inertia_initial_tank3;
mpl_gn2_inertia_tank4 = mpl_gn2_inertia_initial_tank4;

%% Add N2 fluids to vehicle mass properties
% tank 1
[mpl_mass_initial, mpl_cg_initial, mpl_inertia_initial] =...
      configureMassProps( 'Add',...
      mpl_gn2_mass_tank1, mpl_gn2_cg_tank1, mpl_gn2_inertia_tank1,...
      mpl_mass_initial, mpl_cg_initial, mpl_inertia_initial );
% tank 2
[mpl_mass_initial, mpl_cg_initial, mpl_inertia_initial] =...
      configureMassProps( 'Add',...
      mpl_gn2_mass_tank2, mpl_gn2_cg_tank2, mpl_gn2_inertia_tank2,...
      mpl_mass_initial, mpl_cg_initial, mpl_inertia_initial );
% tank 3
[mpl_mass_initial, mpl_cg_initial, mpl_inertia_initial] =...
      configureMassProps( 'Add',...
      mpl_gn2_mass_tank3, mpl_gn2_cg_tank3, mpl_gn2_inertia_tank3,...
      mpl_mass_initial, mpl_cg_initial, mpl_inertia_initial );
% tank 4
[mpl_mass_initial, mpl_cg_initial, mpl_inertia_initial] =...
      configureMassProps( 'Add',...
      mpl_gn2_mass_tank4, mpl_gn2_cg_tank4, mpl_gn2_inertia_tank4,...
      mpl_mass_initial, mpl_cg_initial, mpl_inertia_initial );

