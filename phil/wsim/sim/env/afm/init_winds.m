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

function Winds = init_winds( EpochStart );
% Wind Initialization
%
% Modify this file for use with your simulation by choosing the wind database to use.
%
% INPUT
%   EpochStart  [1x7]   [ year, month, day, hour, minute, second, longitude ]
% OUTPUTS
%   Winds       [1x1]   Struture that contains the wind speed (m/s) and azimuth
%

%% Load the ETR Wind Database:
load ETR_Winds.mat;
clear Winds

Winds.Altitude = ETR_Winds.altitude;

Winds.Enable = 0;       % 1 = ON ; 0 = OFF


%% User Defined Section:
% Choose the data to use to populate the Winds structure.
% Example Options include:
%   Choosing a specific set (iSetNum) within a specified month:
%       Winds.Speed   = ETR_Wind.jan.velocity(:, iSetNum);
%       Winds.Azimuth = ETR_Wind.jan.azimuth(:, iSetNum);
%   Choosing the worst case for a month:
%       Winds.Speed   = ETR_Wind.jan.worstcase.velocity;
%       Winds.Azimuth = ETR_Wind.jan.worstcase.azimuth;
%   Choosing the absoulte worst case for all months in the year:
%       Winds.Speed   = ETR_Wind.WorstCase.velocity;
%       Winds.Azimuth = ETR_Wind.WorstCase.azimuth;

switch EpochStart(2)
    case 1
        % January
        Winds.Dataset   = 'Janurary - Worst Case';
        Winds.Speed     = ETR_Winds.jan.worstcase.velocity;
        Winds.Azimuth   = ETR_Winds.jan.worstcase.azimuth;
        
    case 2
        % February
        Winds.Dataset   = 'February - Worst Case';
        Winds.Speed     = ETR_Winds.feb.worstcase.velocity;
        Winds.Azimuth   = ETR_Winds.feb.worstcase.azimuth;
        
    case 3
        % March
        Winds.Dataset   = 'March - Worst Case';
        Winds.Speed     = ETR_Winds.mar.worstcase.velocity;
        Winds.Azimuth   = ETR_Winds.mar.worstcase.azimuth;
        
    case 4
        % April
        Winds.Dataset   = 'April - Worst Case';
        Winds.Speed     = ETR_Winds.apr.worstcase.velocity;
        Winds.Azimuth   = ETR_Winds.apr.worstcase.azimuth;
                
    case 5
        % May
        Winds.Dataset   = 'May - Worst Case';
        Winds.Speed     = ETR_Winds.may.worstcase.velocity;
        Winds.Azimuth   = ETR_Winds.may.worstcase.azimuth;
               
    case 6
        % June
        Winds.Dataset   = 'June - Worst Case';
        Winds.Speed     = ETR_Winds.jun.worstcase.velocity;
        Winds.Azimuth   = ETR_Winds.jun.worstcase.azimuth;
                
    case 7
        % July
        Winds.Dataset   = 'July - Worst Case';
        Winds.Speed     = ETR_Winds.jul.worstcase.velocity;
        Winds.Azimuth   = ETR_Winds.jul.worstcase.azimuth;
                
    case 8
        % August
        Winds.Dataset   = 'August - Worst Case';
        Winds.Speed     = ETR_Winds.aug.worstcase.velocity;
        Winds.Azimuth   = ETR_Winds.aug.worstcase.azimuth;
                
    case 9
        % September
        Winds.Dataset   = 'September - Worst Case';
        Winds.Speed     = ETR_Winds.sep.worstcase.velocity;
        Winds.Azimuth   = ETR_Winds.sep.worstcase.azimuth;
                
    case 10
        % October
        Winds.Dataset   = 'October - Worst Case';
        Winds.Speed     = ETR_Winds.oct.worstcase.velocity;
        Winds.Azimuth   = ETR_Winds.oct.worstcase.azimuth;
                
    case 11
        % November
        Winds.Dataset   = 'November - Worst Case';
        Winds.Speed     = ETR_Winds.nov.worstcase.velocity;
        Winds.Azimuth   = ETR_Winds.nov.worstcase.azimuth;
                
    case 12
        % December
        Winds.Dataset   = 'December - Worst Case';
        Winds.Speed     = ETR_Winds.dec.worstcase.velocity;
        Winds.Azimuth   = ETR_Winds.dec.worstcase.azimuth;
                
    otherwise
        disp('ERROR Month Not Recognized!');
end

Winds.Speed   = ETR_Winds.WorstCase.velocity;
Winds.Azimuth = ETR_Winds.WorstCase.azimuth;
    
clear ETR_Winds
