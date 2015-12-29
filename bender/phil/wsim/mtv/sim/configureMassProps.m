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

function [mass_f, cg_f, inertia_f] = configureMassProps( configtype, ...
    mass_item, cg_item, inertia_item, mass0, cg0, inertia0 );

%% FUNCTION configureMassProps
%   Given a Vehicle's Current Mass Properties (mass0, cg0, and inertia0)...
%
%   Computes the total combined mass properties (mass_f, cg_f, inertia_f)
%   should an item (cg_item, mass_item, inertia_item)
%   be attached or be removed from it
%
%   [mass_f, cg_f, inertia_f] = configureMassProps( configtype, ...
%       mass_item, cg_item, inertia_item, mass0, cg0, inertia0 );
%
% INPUTS
%   configtype      [string]    String to identify how to reconfigure mass
%                                properties.
%                                To ADD to the original MPs, configtype
%                                must be 'add', 'ADD', 'Add', or '+'.
%
%                                To SUBTRACT from the original MPs,
%                                configtype must be 'subtract', 'SUBTRACT',
%                                'Subtract', or '-'
%
%   mass_item       [1x1]   [mass]        Mass of Item
%   cg_item         [3x1]   [dist]        CG location of Item
%   inertia_item    [3x3]   [mass-dist^2] Inertia of Item
%
%   mass0           [1x1]   [mass]        Initial Vehicle Mass
%   cg0             [3x1]   [dist]        Initial Vehicle CG location
%   inertia0        [3x3]   [mass-dist^2] Initial Vehicle Inertia Matrix
%
% OUTPUTS
%   mass_f          [1x1]   [mass]        New Reconfigured Mass
%   cg_f            [3x1]   [dist]        New Reconfigured CG Location
%   inertia_f       [3x3]   [mass-dist^2] New Reconfigured Inertia Matrix
%
% NOTE
%   This calculation is not unit specific.  Input parameters only need to be
%   of a uniform unit.  Standard METRIC [kg, m, kg-m^2] or ENGLISH 
%   [slug, ft, slug-ft^2] should be used.
%

%% Compute Reconfiguration Type:
switch configtype
    case {'subtract', 'SUBTRACT', 'Subtract', '-'}
        mult = -1;
    case {'add', 'ADD', 'Add', '+'}
        mult = 1;
    otherwise
        disp('ERROR in configureMassProps.m.  Unknown configtype.');
end

%% Compute New Mass:
mass_f = mass0 + mult * mass_item;

%% Check to See if Mass Still Exists:
if mass_f <= 0
    %% All Mass Has been Removed
    %   Final Mass Does not Exist.  Return NULL Mass Properties.
    mass_f       = 0.0;
    cg_f         = zeros(1,3);
    inertia_f    = zeros(3,3);

else
    %% Mass Still Exists

    %% Compute New CG Location:
    cg_f = ((mass0*cg0) + mult * (mass_item*cg_item))/ mass_f;  % [dist]

    if mult == 1
        %% Item is to be added to Vehicle
        %   Reconfiguration Process:
        %   1 - Compute Distance from Vehicle's old CG to new CG
        %   2 - Use Parallel Axis Theorem with computed distance from 1
        %       to Relocate Vehicle's inertia (inertia0) to new combined CG
        %   3 - Compute Distance from Item's CG to new combined CG
        %   4 - Use Parallel Axis Theorem with computed distance from 3
        %       to Relocate Added Item's inertia to new combined CG
        %   5 - Add both Inertias at new combined CG.  Result is inertia_f

        %  (1) Compute Distance from Vehicle's old CG to new CG:
        d0f = cg0 - cg_f;

        %  (2) Use Parallel Axis Theorem with computed distance from 1 to
        %      relocate Vehicle's inertia to new combined CG
        I_0cg.Ixx = inertia0(1,1) + mass0*( d0f(2)^2 + d0f(3)^2 );
        I_0cg.Iyy = inertia0(2,2) + mass0*( d0f(1)^2 + d0f(3)^2 );
        I_0cg.Izz = inertia0(3,3) + mass0*( d0f(1)^2 + d0f(2)^2 );
        I_0cg.Ixy = -inertia0(1,2) + mass0 * d0f(1) * d0f(2);
        I_0cg.Ixz = -inertia0(1,3) + mass0 * d0f(1) * d0f(3);
        I_0cg.Iyz = -inertia0(2,3) + mass0 * d0f(2) * d0f(3);
        I_0cg.Inertia = struc2InertiaMatrix( I_0cg );

        %  (3) Compute Distance from Item's CG to new combined CG:
        dif = cg_item - cg_f;

        %  (4) Use Parallel Axis Theorem with computed distance from 3
        %      to relocate Added Item's inertia to new combined CG:
        I_icg.Ixx = inertia_item(1,1) + mass_item*( dif(2)^2 + dif(3)^2 );
        I_icg.Iyy = inertia_item(2,2) + mass_item*( dif(1)^2 + dif(3)^2 );
        I_icg.Izz = inertia_item(3,3) + mass_item*( dif(1)^2 + dif(2)^2 );
        I_icg.Ixy = -inertia_item(1,2) + mass_item * dif(1) * dif(2);
        I_icg.Ixz = -inertia_item(1,3) + mass_item * dif(1) * dif(3);
        I_icg.Iyz = -inertia_item(2,3) + mass_item * dif(2) * dif(3);
        I_icg.Inertia = struc2InertiaMatrix( I_icg );

        %  (5) Add both Inertias at new combined CG.  Result is inertia_f
        inertia_f = I_0cg.Inertia + I_icg.Inertia;

    else
        %% Item is to be removed from Vehicle
        %   Reconfiguration Process:
        %   1 - Compute Distance from Item's CG to Vehicle's original CG
        %   2 - Use Parallel Axis Theorem with computed distance from 1
        %       to Relocate Item's inertia to old Vehicle's CG
        %   3 - Subtract the Item's inertia from the original inertia.  The
        %       result is the Vehicle's inertia at the old CG.
        %   4 - Compute Distance from Vehicle's Old CG to the Vehicle's new
        %       CG.
        %   5 - Use Parallel Axis Theorem with computed distance from 4
        %       to Relocate Vehicle's inertia to new CG.  Result is
        %       inertia_f.

        %  (1) Compute Distance from Item's CG to Vehicle's original CG:
        di0 = cg_item - cg0;

        %  (2) Use Parallel Axis Theorem with computed distance from 1
        %      to relocate Item's inertia to old Vehicle's CG:
        I_icg.Ixx = inertia_item(1,1) + mass_item*( di0(2)^2 + di0(3)^2 );
        I_icg.Iyy = inertia_item(2,2) + mass_item*( di0(1)^2 + di0(3)^2 );
        I_icg.Izz = inertia_item(3,3) + mass_item*( di0(1)^2 + di0(2)^2 );
        I_icg.Ixy = -inertia_item(1,2) + mass_item * di0(1) * di0(2);
        I_icg.Ixz = -inertia_item(1,3) + mass_item * di0(1) * di0(3);
        I_icg.Iyz = -inertia_item(2,3) + mass_item * di0(2) * di0(3);
        I_icg.Inertia = struc2InertiaMatrix( I_icg );

        %  (3) Subtract the Item's inertia from the original inertia.
        %       The result is the Vehicle's inertia at the old CG.:
        I_foldcg = inertia0 - I_icg.Inertia;

        %  (4) Compute Distance from Vehicle's Old CG to the new CG
        d0f = cg0 - cg_f;

        %  (5) Use Parallel Axis Theorem with computed distance from 4
        %      to relocate Vehicle's inertia to new CG.  Result is
        %      inertia_f:
        I_f.Ixx = I_foldcg(1,1) - mass_f*( d0f(2)^2 + d0f(3)^2 );
        I_f.Iyy = I_foldcg(2,2) - mass_f*( d0f(1)^2 + d0f(3)^2 );
        I_f.Izz = I_foldcg(3,3) - mass_f*( d0f(1)^2 + d0f(2)^2 );
        I_f.Ixy = -I_foldcg(1,2) - mass_f * d0f(1) * d0f(2);
        I_f.Ixz = -I_foldcg(1,3) - mass_f * d0f(1) * d0f(3);
        I_f.Iyz = -I_foldcg(2,3) - mass_f * d0f(2) * d0f(3);
        I_f.Inertia = struc2InertiaMatrix( I_f );

        inertia_f = I_f.Inertia;
    end
end
