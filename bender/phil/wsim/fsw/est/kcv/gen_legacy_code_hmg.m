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

%---------------------------------------------------------------------
%       Store location to allow calling from anywhere
%---------------------------------------------------------------------
currentpwd = pwd;
[pathstr, name, ext] = fileparts(which('gen_legacy_code_hmg.m'));
cd (pathstr);

%---------------------------------------------------------------------
%       Initialize and set legacy_code options
%---------------------------------------------------------------------
specs = legacy_code('initialize');
specs.SFunctionName = 'sfun_hmg';
specs.InitializeConditionsFcnSpec = 'void initialize_hmg(double p1, void** work1)';
specs.OutputFcnSpec = 'void outputs_hmg(double u1[16][2], double u2[16][2], double y1[3][3], uint8 y2[16], void** work1)';
specs.TerminateFcnSpec = 'void terminate_hmg(void** work1)';
% Since we're using external paths here that we don't want hardcoded, we wrap desired MATLAB commands in #'s
% which tells fix_rtwmakecfg.m to replace the contained strings with something to eval
specs.IncPaths = {'#fullfile(getenv(''NIMBUS_ROOT''), ''externals'', ''minopencv'')#';
                  '#fullfile(getenv(''NIMBUS_ROOT''), ''externals'', ''minopencv'', ''include'')#';
                  '#fullfile(getenv(''NIMBUS_ROOT''), ''externals'', ''minopencv'', ''include'', ''opencv2'')#'};
specs.SrcPaths = {'#fullfile(getenv(''NIMBUS_ROOT''), ''externals'', ''minopencv'')#'};
specs.HeaderFiles = {'sfun_hmg_wrapper.h'};
specs.SourceFiles = {'hmg_obj.cpp';
                     'sfun_hmg_wrapper.cpp';
                     'algorithm.cpp';
                     'alloc.cpp';
                     'arithm.cpp';
                     'array.cpp';
                     'calibration.cpp';
                     'color.cpp';
                     'convert.cpp';
                     'copy.cpp';
                     'datastructs.cpp';
                     'descriptors.cpp';
                     'detectors.cpp';
                     'drawing.cpp';
                     'fast.cpp';
                     'fast_score.cpp';
                     'filter.cpp';
                     'fundam.cpp';
                     'histogram.cpp';
                     'imgwarp.cpp';
                     'keypoint.cpp';
                     'lapack.cpp';
                     'matchers.cpp';
                     'mathfuncs.cpp';
                     'matmul.cpp';
                     'matop.cpp';
                     'matrix.cpp';
                     'modelest.cpp';
                     'orb.cpp';
                     'parallel.cpp';
                     'pyramids.cpp';
                     'smooth.cpp';
                     'stat.cpp';
                     'system.cpp';
                     'thresh.cpp';
                     'undistort.cpp';
                     'utils.cpp';
                     };
specs.Options.language = 'C';

%---------------------------------------------------------------------
%       Generate Code
%---------------------------------------------------------------------
legacy_code('sfcn_cmex_generate', specs)
%legacy_code('compile', specs)

legacy_code('rtwmakecfg_generate', specs)
fix_rtwmakecfg('rtwmakecfg.m');

legacy_code('sfcn_tlc_generate', specs)

cd(currentpwd);
