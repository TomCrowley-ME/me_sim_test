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

%------------------------------------------------------------------
%       This script is now used to only generate a template file
%   for code generation and the tlc file. 
%------------------------------------------------------------------

%------------------------------------------------------------------
%       Store location to allow calling from anywhere
%------------------------------------------------------------------
currentpwd = pwd;
[pathstr, name, ext] = fileparts(which('gen_legacy_code_tcp.m'));
cd(pathstr);

%------------------------------------------------------------------
%       Initialize and set legacy_code options
%------------------------------------------------------------------
specs = legacy_code('initialize');
specs.SFunctionName = 'sfun_tcp';
specs.InitializeConditionsFcnSpec = 'void initialize_tcp(int16 p1, int16 p2, int16 p3, int16 p4, int16 p5, void** work1)';
specs.OutputFcnSpec = 'void outputs_tcp(double u1[3], double u2[4], double u3[2], double u4[2], int32 u5, double u6[3], double u7[4], double y1[1], uint8 y2[307200], uint8 y3[1], void** work1)';
specs.TerminateFcnSpec = 'void terminate_tcp(void** work1)';
specs.HeaderFiles = {'sfun_tcp_wrapper.h'};
specs.SourceFiles = {'tcp_obj.cpp'; 'sfun_tcp_wrapper.cpp'};
specs.Options.language = 'C';

%------------------------------------------------------------------
%       Generate code
%------------------------------------------------------------------
legacy_code('sfcn_cmex_generate', specs)    % Generate sfunction source
%legacy_code('compile', specs);              % Compile sfunction
%legacy_code('rtwmakecfg_generate', specs)   % Generate rtwmakecfg.m
legacy_code('sfcn_tlc_generate', specs)     % Generate tlc file

cd(currentpwd);
