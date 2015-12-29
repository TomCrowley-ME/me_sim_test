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
[pathstr, name, ext] = fileparts(which('gen_legacy_code_orb.m'));
cd (pathstr);

%---------------------------------------------------------------------
%       Initialize and set legacy_code options
%---------------------------------------------------------------------
specs = legacy_code('initialize');
specs.SFunctionName = 'sfun_orb';
specs.InitializeConditionsFcnSpec = 'void initialize_orb(uint16 p1, void** work1)';
specs.OutputFcnSpec = 'void outputs_orb(uint8 u1[307200], uint8 u2[307200], double u3[2], double y1[16][2], double y2[16][2], void** work1)';
specs.TerminateFcnSpec = 'void terminate_orb(void** work1)';
specs.IncPaths = {'#fullfile(getenv(''NIMBUS_ROOT''), ''externals'', ''minopencv'')#';
                  '#fullfile(getenv(''NIMBUS_ROOT''), ''externals'', ''minopencv'', ''include'')#';
                  '#fullfile(getenv(''NIMBUS_ROOT''), ''externals'', ''minopencv'', ''include'', ''opencv2'')#'};
specs.SrcPaths = {'#fullfile(getenv(''NIMBUS_ROOT''), ''externals'', ''minopencv'')#'};
specs.HeaderFiles = {'sfun_orb_wrapper.h'};
specs.SourceFiles = {'orb_obj.cpp';
                     'sfun_orb_wrapper.cpp';
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
%legacy_code('compile', specs, '-DSAVE_IMAGE')

legacy_code('rtwmakecfg_generate', specs)
fix_rtwmakecfg('rtwmakecfg.m');

legacy_code('sfcn_tlc_generate', specs)

cd(currentpwd);
