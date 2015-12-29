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

%% Begin mpl prep file 
% Dependencies: csu_mpl_mass_properties_init
%

%% initialize mass properties
% start with vehicle dry mass properties
mpl_mass_initial    = mpl_mass_dry;
mpl_cg_initial      = mpl_cg_dry;
mpl_inertia_initial = mpl_inertia_dry;

%% initialize HTP mass properties
% fluid masses
if ~isempty(mpl_htp_mass_initial)
  mpl_htp_mass_initial_tank1 = mpl_htp_mass_initial/4;
  mpl_htp_mass_initial_tank2 = mpl_htp_mass_initial/4;
  mpl_htp_mass_initial_tank3 = mpl_htp_mass_initial/4;
  mpl_htp_mass_initial_tank4 = mpl_htp_mass_initial/4;

  mpl_htp_mass_tank1 = mpl_htp_mass_initial_tank1;
  mpl_htp_mass_tank2 = mpl_htp_mass_initial_tank2;
  mpl_htp_mass_tank3 = mpl_htp_mass_initial_tank3;
  mpl_htp_mass_tank4 = mpl_htp_mass_initial_tank4;
else 
  mpl_htp_mass_tank1 = mpl_htp_mass_initial_tank1;
  mpl_htp_mass_tank2 = mpl_htp_mass_initial_tank2;
  mpl_htp_mass_tank3 = mpl_htp_mass_initial_tank3;
  mpl_htp_mass_tank4 = mpl_htp_mass_initial_tank4;
  mpl_htp_mass_initial = mpl_htp_mass_initial_tank1+...
                         mpl_htp_mass_initial_tank2+...
                         mpl_htp_mass_initial_tank3+...
                         mpl_htp_mass_initial_tank4;
end

% fluid inertias at center of tank, Ixx, Iyy, Izz, (Ixy, Ixz, Iyz optional)  
mpl_htp_inertia_fillfrac_0   = mpl_htp_mass_fillfrac_0  *[1.0 1.0 1.0]*2/5*mpl_htp_tank_radius^2;
mpl_htp_inertia_fillfrac_100 = mpl_htp_mass_fillfrac_100*[1.0 1.0 1.0]*2/5*mpl_htp_tank_radius^2;

% rotate inertias from tank frame to vehicle frame
mpl_htp_inertia_fillfrac_0_tank1   = euler2dcm(321,-atan2d(mpl_htp_center_tank1(2),mpl_htp_center_tank1(1)),0,0)*buildInertiaMatrix(mpl_htp_inertia_fillfrac_0);
mpl_htp_inertia_fillfrac_0_tank2   = euler2dcm(321,-atan2d(mpl_htp_center_tank2(2),mpl_htp_center_tank2(1)),0,0)*buildInertiaMatrix(mpl_htp_inertia_fillfrac_0);
mpl_htp_inertia_fillfrac_0_tank3   = euler2dcm(321,-atan2d(mpl_htp_center_tank3(2),mpl_htp_center_tank3(1)),0,0)*buildInertiaMatrix(mpl_htp_inertia_fillfrac_0);
mpl_htp_inertia_fillfrac_0_tank4   = euler2dcm(321,-atan2d(mpl_htp_center_tank4(2),mpl_htp_center_tank4(1)),0,0)*buildInertiaMatrix(mpl_htp_inertia_fillfrac_0);

mpl_htp_inertia_fillfrac_100_tank1 = euler2dcm(321,-atan2d(mpl_htp_center_tank1(2),mpl_htp_center_tank1(1)),0,0)*buildInertiaMatrix(mpl_htp_inertia_fillfrac_100);
mpl_htp_inertia_fillfrac_100_tank2 = euler2dcm(321,-atan2d(mpl_htp_center_tank2(2),mpl_htp_center_tank2(1)),0,0)*buildInertiaMatrix(mpl_htp_inertia_fillfrac_100);
mpl_htp_inertia_fillfrac_100_tank3 = euler2dcm(321,-atan2d(mpl_htp_center_tank3(2),mpl_htp_center_tank3(1)),0,0)*buildInertiaMatrix(mpl_htp_inertia_fillfrac_100);
mpl_htp_inertia_fillfrac_100_tank4 = euler2dcm(321,-atan2d(mpl_htp_center_tank4(2),mpl_htp_center_tank4(1)),0,0)*buildInertiaMatrix(mpl_htp_inertia_fillfrac_100);

% move inertias from tank centers to origin
mpl_htp_inertia_fillfrac_0_tank1   = mpl_htp_inertia_fillfrac_0_tank1 + mpl_htp_mass_fillfrac_0*buildParallelAxisMatrix(mpl_htp_center_tank1);
mpl_htp_inertia_fillfrac_0_tank2   = mpl_htp_inertia_fillfrac_0_tank2 + mpl_htp_mass_fillfrac_0*buildParallelAxisMatrix(mpl_htp_center_tank2);
mpl_htp_inertia_fillfrac_0_tank3   = mpl_htp_inertia_fillfrac_0_tank3 + mpl_htp_mass_fillfrac_0*buildParallelAxisMatrix(mpl_htp_center_tank3);
mpl_htp_inertia_fillfrac_0_tank4   = mpl_htp_inertia_fillfrac_0_tank4 + mpl_htp_mass_fillfrac_0*buildParallelAxisMatrix(mpl_htp_center_tank4);

mpl_htp_inertia_fillfrac_100_tank1 = mpl_htp_inertia_fillfrac_100_tank1 + mpl_htp_mass_fillfrac_100*buildParallelAxisMatrix(mpl_htp_center_tank1);
mpl_htp_inertia_fillfrac_100_tank2 = mpl_htp_inertia_fillfrac_100_tank2 + mpl_htp_mass_fillfrac_100*buildParallelAxisMatrix(mpl_htp_center_tank2);
mpl_htp_inertia_fillfrac_100_tank3 = mpl_htp_inertia_fillfrac_100_tank3 + mpl_htp_mass_fillfrac_100*buildParallelAxisMatrix(mpl_htp_center_tank3);
mpl_htp_inertia_fillfrac_100_tank4 = mpl_htp_inertia_fillfrac_100_tank4 + mpl_htp_mass_fillfrac_100*buildParallelAxisMatrix(mpl_htp_center_tank4);

% build tables
mpl_htp_mass_table          = [ mpl_htp_mass_fillfrac_0;   mpl_htp_mass_fillfrac_100 ];
mpl_htp_cg_table            = [ mpl_htp_cg_fillfrac_0;     mpl_htp_cg_fillfrac_100   ];
mpl_htp_inertia_table_tank1 = [ buildInertiaVector(mpl_htp_inertia_fillfrac_0_tank1);  buildInertiaVector(mpl_htp_inertia_fillfrac_100_tank1) ];
mpl_htp_inertia_table_tank2 = [ buildInertiaVector(mpl_htp_inertia_fillfrac_0_tank2);  buildInertiaVector(mpl_htp_inertia_fillfrac_100_tank2) ];
mpl_htp_inertia_table_tank3 = [ buildInertiaVector(mpl_htp_inertia_fillfrac_0_tank3);  buildInertiaVector(mpl_htp_inertia_fillfrac_100_tank3) ];
mpl_htp_inertia_table_tank4 = [ buildInertiaVector(mpl_htp_inertia_fillfrac_0_tank4);  buildInertiaVector(mpl_htp_inertia_fillfrac_100_tank4) ];

% fluid CGs
mpl_htp_cg_initial_tank1 = mpl_htp_center_tank1 + interp1(mpl_htp_mass_table, mpl_htp_cg_table, mpl_htp_mass_tank1,'linear');
mpl_htp_cg_initial_tank2 = mpl_htp_center_tank2 + interp1(mpl_htp_mass_table, mpl_htp_cg_table, mpl_htp_mass_tank2,'linear');
mpl_htp_cg_initial_tank3 = mpl_htp_center_tank3 + interp1(mpl_htp_mass_table, mpl_htp_cg_table, mpl_htp_mass_tank3,'linear');
mpl_htp_cg_initial_tank4 = mpl_htp_center_tank4 + interp1(mpl_htp_mass_table, mpl_htp_cg_table, mpl_htp_mass_tank4,'linear');

mpl_htp_cg_tank1 = mpl_htp_cg_initial_tank1;
mpl_htp_cg_tank2 = mpl_htp_cg_initial_tank2;
mpl_htp_cg_tank3 = mpl_htp_cg_initial_tank3;
mpl_htp_cg_tank4 = mpl_htp_cg_initial_tank4;

% fluid inertias
mpl_htp_inertia_initial_tank1 = buildInertiaMatrix(interp1(mpl_htp_mass_table, mpl_htp_inertia_table_tank1, mpl_htp_mass_tank1,'linear'));
mpl_htp_inertia_initial_tank2 = buildInertiaMatrix(interp1(mpl_htp_mass_table, mpl_htp_inertia_table_tank2, mpl_htp_mass_tank2,'linear'));
mpl_htp_inertia_initial_tank3 = buildInertiaMatrix(interp1(mpl_htp_mass_table, mpl_htp_inertia_table_tank3, mpl_htp_mass_tank3,'linear'));
mpl_htp_inertia_initial_tank4 = buildInertiaMatrix(interp1(mpl_htp_mass_table, mpl_htp_inertia_table_tank4, mpl_htp_mass_tank4,'linear'));

mpl_htp_inertia_tank1 = mpl_htp_inertia_initial_tank1;
mpl_htp_inertia_tank2 = mpl_htp_inertia_initial_tank2;
mpl_htp_inertia_tank3 = mpl_htp_inertia_initial_tank3;
mpl_htp_inertia_tank4 = mpl_htp_inertia_initial_tank4;

%% Add HTP fluids to vehicle mass properties
% tank 1
[mpl_mass_initial, mpl_cg_initial, mpl_inertia_initial] =...
      configureMassProps( 'Add',...
      mpl_htp_mass_tank1, mpl_htp_cg_tank1, mpl_htp_inertia_tank1,...
      mpl_mass_initial, mpl_cg_initial, mpl_inertia_initial );
% tank 2
[mpl_mass_initial, mpl_cg_initial, mpl_inertia_initial] =...
      configureMassProps( 'Add',...
      mpl_htp_mass_tank2, mpl_htp_cg_tank2, mpl_htp_inertia_tank2,...
      mpl_mass_initial, mpl_cg_initial, mpl_inertia_initial );
% tank 3
[mpl_mass_initial, mpl_cg_initial, mpl_inertia_initial] =...
      configureMassProps( 'Add',...
      mpl_htp_mass_tank3, mpl_htp_cg_tank3, mpl_htp_inertia_tank3,...
      mpl_mass_initial, mpl_cg_initial, mpl_inertia_initial );
% tank 4
[mpl_mass_initial, mpl_cg_initial, mpl_inertia_initial] =...
      configureMassProps( 'Add',...
      mpl_htp_mass_tank4, mpl_htp_cg_tank4, mpl_htp_inertia_tank4,...
      mpl_mass_initial, mpl_cg_initial, mpl_inertia_initial );

%% initialize N2 mass properties
% fluid masses
if ~isempty(mpl_gn2_mass_initial)
  mpl_gn2_mass_initial_tank1 = mpl_gn2_mass_initial/4;
  mpl_gn2_mass_initial_tank2 = mpl_gn2_mass_initial/4;
  mpl_gn2_mass_initial_tank3 = mpl_gn2_mass_initial/4;
  mpl_gn2_mass_initial_tank4 = mpl_gn2_mass_initial/4;
  mpl_gn2_mass_initial_tank5 = 0.0;
  mpl_gn2_mass_initial_tank6 = 0.0;

  mpl_gn2_mass_tank1 = mpl_gn2_mass_initial_tank1;
  mpl_gn2_mass_tank2 = mpl_gn2_mass_initial_tank2;
  mpl_gn2_mass_tank3 = mpl_gn2_mass_initial_tank3;
  mpl_gn2_mass_tank4 = mpl_gn2_mass_initial_tank4;
  mpl_gn2_mass_tank5 = mpl_gn2_mass_initial_tank5;
  mpl_gn2_mass_tank6 = mpl_gn2_mass_initial_tank6;
else
  mpl_gn2_mass_tank1 = mpl_gn2_mass_initial_tank1;
  mpl_gn2_mass_tank2 = mpl_gn2_mass_initial_tank2;
  mpl_gn2_mass_tank3 = mpl_gn2_mass_initial_tank3;
  mpl_gn2_mass_tank4 = mpl_gn2_mass_initial_tank4;
  mpl_gn2_mass_tank5 = mpl_gn2_mass_initial_tank5;
  mpl_gn2_mass_tank6 = mpl_gn2_mass_initial_tank6;
  mpl_gn2_mass_initial = mpl_gn2_mass_initial_tank1+...
                         mpl_gn2_mass_initial_tank2+...
                         mpl_gn2_mass_initial_tank3+...
                         mpl_gn2_mass_initial_tank4+...
                         mpl_gn2_mass_initial_tank5+...
                         mpl_gn2_mass_initial_tank6;
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
mpl_gn2_inertia_fillfrac_0_tank5   = euler2dcm(321,-atan2d(mpl_gn2_center_tank4(2),mpl_gn2_center_tank5(1)),0,0)*buildInertiaMatrix(mpl_gn2_inertia_fillfrac_0);
mpl_gn2_inertia_fillfrac_0_tank6   = euler2dcm(321,-atan2d(mpl_gn2_center_tank4(2),mpl_gn2_center_tank6(1)),0,0)*buildInertiaMatrix(mpl_gn2_inertia_fillfrac_0);

mpl_gn2_inertia_fillfrac_100_tank1 = euler2dcm(321,-atan2d(mpl_gn2_center_tank1(2),mpl_gn2_center_tank1(1)),0,0)*buildInertiaMatrix(mpl_gn2_inertia_fillfrac_100);
mpl_gn2_inertia_fillfrac_100_tank2 = euler2dcm(321,-atan2d(mpl_gn2_center_tank2(2),mpl_gn2_center_tank2(1)),0,0)*buildInertiaMatrix(mpl_gn2_inertia_fillfrac_100);
mpl_gn2_inertia_fillfrac_100_tank3 = euler2dcm(321,-atan2d(mpl_gn2_center_tank3(2),mpl_gn2_center_tank3(1)),0,0)*buildInertiaMatrix(mpl_gn2_inertia_fillfrac_100);
mpl_gn2_inertia_fillfrac_100_tank4 = euler2dcm(321,-atan2d(mpl_gn2_center_tank4(2),mpl_gn2_center_tank4(1)),0,0)*buildInertiaMatrix(mpl_gn2_inertia_fillfrac_100);
mpl_gn2_inertia_fillfrac_100_tank5 = euler2dcm(321,-atan2d(mpl_gn2_center_tank5(2),mpl_gn2_center_tank5(1)),0,0)*buildInertiaMatrix(mpl_gn2_inertia_fillfrac_100);
mpl_gn2_inertia_fillfrac_100_tank6 = euler2dcm(321,-atan2d(mpl_gn2_center_tank6(2),mpl_gn2_center_tank6(1)),0,0)*buildInertiaMatrix(mpl_gn2_inertia_fillfrac_100);

% move inertias from tank centers to origin
mpl_gn2_inertia_fillfrac_0_tank1   = mpl_gn2_inertia_fillfrac_0_tank1 + mpl_gn2_mass_fillfrac_0*buildParallelAxisMatrix(mpl_gn2_center_tank1);
mpl_gn2_inertia_fillfrac_0_tank2   = mpl_gn2_inertia_fillfrac_0_tank2 + mpl_gn2_mass_fillfrac_0*buildParallelAxisMatrix(mpl_gn2_center_tank2);
mpl_gn2_inertia_fillfrac_0_tank3   = mpl_gn2_inertia_fillfrac_0_tank3 + mpl_gn2_mass_fillfrac_0*buildParallelAxisMatrix(mpl_gn2_center_tank3);
mpl_gn2_inertia_fillfrac_0_tank4   = mpl_gn2_inertia_fillfrac_0_tank4 + mpl_gn2_mass_fillfrac_0*buildParallelAxisMatrix(mpl_gn2_center_tank4);
mpl_gn2_inertia_fillfrac_0_tank5   = mpl_gn2_inertia_fillfrac_0_tank5 + mpl_gn2_mass_fillfrac_0*buildParallelAxisMatrix(mpl_gn2_center_tank5);
mpl_gn2_inertia_fillfrac_0_tank6   = mpl_gn2_inertia_fillfrac_0_tank6 + mpl_gn2_mass_fillfrac_0*buildParallelAxisMatrix(mpl_gn2_center_tank6);

mpl_gn2_inertia_fillfrac_100_tank1 = mpl_gn2_inertia_fillfrac_100_tank1 + mpl_gn2_mass_fillfrac_100*buildParallelAxisMatrix(mpl_gn2_center_tank1);
mpl_gn2_inertia_fillfrac_100_tank2 = mpl_gn2_inertia_fillfrac_100_tank2 + mpl_gn2_mass_fillfrac_100*buildParallelAxisMatrix(mpl_gn2_center_tank2);
mpl_gn2_inertia_fillfrac_100_tank3 = mpl_gn2_inertia_fillfrac_100_tank3 + mpl_gn2_mass_fillfrac_100*buildParallelAxisMatrix(mpl_gn2_center_tank3);
mpl_gn2_inertia_fillfrac_100_tank4 = mpl_gn2_inertia_fillfrac_100_tank4 + mpl_gn2_mass_fillfrac_100*buildParallelAxisMatrix(mpl_gn2_center_tank4);
mpl_gn2_inertia_fillfrac_100_tank5 = mpl_gn2_inertia_fillfrac_100_tank5 + mpl_gn2_mass_fillfrac_100*buildParallelAxisMatrix(mpl_gn2_center_tank5);
mpl_gn2_inertia_fillfrac_100_tank6 = mpl_gn2_inertia_fillfrac_100_tank6 + mpl_gn2_mass_fillfrac_100*buildParallelAxisMatrix(mpl_gn2_center_tank6);

% build mass and CG tables
mpl_gn2_mass_table          = [ mpl_gn2_mass_fillfrac_0;     mpl_gn2_mass_fillfrac_100 ];
mpl_gn2_cg_table            = [ mpl_gn2_cg_fillfrac_0;       mpl_gn2_cg_fillfrac_100   ];
mpl_gn2_inertia_table_tank1 = [ buildInertiaVector(mpl_gn2_inertia_fillfrac_0_tank1);  buildInertiaVector(mpl_gn2_inertia_fillfrac_100_tank1) ];
mpl_gn2_inertia_table_tank2 = [ buildInertiaVector(mpl_gn2_inertia_fillfrac_0_tank2);  buildInertiaVector(mpl_gn2_inertia_fillfrac_100_tank2) ];
mpl_gn2_inertia_table_tank3 = [ buildInertiaVector(mpl_gn2_inertia_fillfrac_0_tank3);  buildInertiaVector(mpl_gn2_inertia_fillfrac_100_tank3) ];
mpl_gn2_inertia_table_tank4 = [ buildInertiaVector(mpl_gn2_inertia_fillfrac_0_tank4);  buildInertiaVector(mpl_gn2_inertia_fillfrac_100_tank4) ];
mpl_gn2_inertia_table_tank5 = [ buildInertiaVector(mpl_gn2_inertia_fillfrac_0_tank5);  buildInertiaVector(mpl_gn2_inertia_fillfrac_100_tank5) ];
mpl_gn2_inertia_table_tank6 = [ buildInertiaVector(mpl_gn2_inertia_fillfrac_0_tank6);  buildInertiaVector(mpl_gn2_inertia_fillfrac_100_tank6) ];

% fluid CGs
mpl_gn2_cg_initial_tank1 = mpl_gn2_center_tank1 + interp1(mpl_gn2_mass_table, mpl_gn2_cg_table, mpl_gn2_mass_tank1,'linear');
mpl_gn2_cg_initial_tank2 = mpl_gn2_center_tank2 + interp1(mpl_gn2_mass_table, mpl_gn2_cg_table, mpl_gn2_mass_tank2,'linear');
mpl_gn2_cg_initial_tank3 = mpl_gn2_center_tank3 + interp1(mpl_gn2_mass_table, mpl_gn2_cg_table, mpl_gn2_mass_tank3,'linear');
mpl_gn2_cg_initial_tank4 = mpl_gn2_center_tank4 + interp1(mpl_gn2_mass_table, mpl_gn2_cg_table, mpl_gn2_mass_tank4,'linear');
mpl_gn2_cg_initial_tank5 = mpl_gn2_center_tank5 + interp1(mpl_gn2_mass_table, mpl_gn2_cg_table, mpl_gn2_mass_tank5,'linear');
mpl_gn2_cg_initial_tank6 = mpl_gn2_center_tank6 + interp1(mpl_gn2_mass_table, mpl_gn2_cg_table, mpl_gn2_mass_tank6,'linear');

mpl_gn2_cg_tank1 = mpl_gn2_cg_initial_tank1;
mpl_gn2_cg_tank2 = mpl_gn2_cg_initial_tank2;
mpl_gn2_cg_tank3 = mpl_gn2_cg_initial_tank3;
mpl_gn2_cg_tank4 = mpl_gn2_cg_initial_tank4;
mpl_gn2_cg_tank5 = mpl_gn2_cg_initial_tank5;
mpl_gn2_cg_tank6 = mpl_gn2_cg_initial_tank6;

% fluid inertias
mpl_gn2_inertia_initial_tank1 = buildInertiaMatrix(interp1(mpl_gn2_mass_table, mpl_gn2_inertia_table_tank1, mpl_gn2_mass_tank1,'linear'));
mpl_gn2_inertia_initial_tank2 = buildInertiaMatrix(interp1(mpl_gn2_mass_table, mpl_gn2_inertia_table_tank2, mpl_gn2_mass_tank2,'linear'));
mpl_gn2_inertia_initial_tank3 = buildInertiaMatrix(interp1(mpl_gn2_mass_table, mpl_gn2_inertia_table_tank3, mpl_gn2_mass_tank3,'linear'));
mpl_gn2_inertia_initial_tank4 = buildInertiaMatrix(interp1(mpl_gn2_mass_table, mpl_gn2_inertia_table_tank4, mpl_gn2_mass_tank4,'linear'));
mpl_gn2_inertia_initial_tank5 = buildInertiaMatrix(interp1(mpl_gn2_mass_table, mpl_gn2_inertia_table_tank5, mpl_gn2_mass_tank5,'linear'));
mpl_gn2_inertia_initial_tank6 = buildInertiaMatrix(interp1(mpl_gn2_mass_table, mpl_gn2_inertia_table_tank6, mpl_gn2_mass_tank6,'linear'));

mpl_gn2_inertia_tank1 = mpl_gn2_inertia_initial_tank1;
mpl_gn2_inertia_tank2 = mpl_gn2_inertia_initial_tank2;
mpl_gn2_inertia_tank3 = mpl_gn2_inertia_initial_tank3;
mpl_gn2_inertia_tank4 = mpl_gn2_inertia_initial_tank4;
mpl_gn2_inertia_tank5 = mpl_gn2_inertia_initial_tank5;
mpl_gn2_inertia_tank6 = mpl_gn2_inertia_initial_tank6;

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
% tank 5
[mpl_mass_initial, mpl_cg_initial, mpl_inertia_initial] =...
      configureMassProps( 'Add',...
      mpl_gn2_mass_tank5, mpl_gn2_cg_tank5, mpl_gn2_inertia_tank5,...
      mpl_mass_initial, mpl_cg_initial, mpl_inertia_initial );
% tank 6
[mpl_mass_initial, mpl_cg_initial, mpl_inertia_initial] =...
      configureMassProps( 'Add',...
      mpl_gn2_mass_tank6, mpl_gn2_cg_tank6, mpl_gn2_inertia_tank6,...
      mpl_mass_initial, mpl_cg_initial, mpl_inertia_initial );
