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

function [pass,tests]=check_results(TestPoint,options);
%   TestPoint       input structure
%     .Type         cell array of strings controlling verification of each testpoint 
%                   'withinTolerance' = .Result within +/- .Tolerance of .Expected
%                   'insideLimits'    = .Result > .LowerLimit AND .Result < .UpperLimit 
%                   'outsideLimits'   = .Result < .LowerLimit OR  .Result > .UpperLimit
%                   'lessThanMax'     = .Result < .UpperLimit
%                   'greaterThanMin'  = .Result > .LowerLimit
%     .Result
%     .Expected
%     .Tolerance
%     .UpperLimit
%     .LowerLimit
%
%   options         string controlling display output
%                   []        = no output 
%                   'verbose' = display pass/fail for every testpoint
%                   'concise' = display summary: '# out of # PASSED'

global CASE_NUM;

if isempty(CASE_NUM),CASE_NUM=0;end
CASE_NUM = CASE_NUM+1;
pass    = 0;
rows    = size(TestPoint.Result,1);
cols    = size(TestPoint.Result,2);
tests   = rows*cols;
verbose = 0;

if nargin==2
    if strcmp(options,'concise'),verbose=0;end
    if strcmp(options,'verbose'),verbose=1;end
end
if verbose,fprintf('CASE #%d\n',CASE_NUM);end

%% cycle through testpoints, verify results depending on type
for i=1:rows
  for j=1:cols
    switch char(TestPoint.Type(i,j))
      case {'withinTolerance'}
        if (abs(TestPoint.Result(i,j) - TestPoint.Expected(i,j)) < TestPoint.Tolerance(i,j))
          pass=pass+1;
          if verbose,fprintf('testpoint %d PASSED\n',cols*(i-1)+j);end
        else
          if verbose,fprintf('testpoint %d FAILED\n',cols*(i-1)+j);end
        end
      case {'insideLimits'}
        if ((TestPoint.Result(i,j) > TestPoint.LowerLimit(i,j))&&(TestPoint.Result(i,j) < TestPoint.UpperLimit(i,j)))
          pass=pass+1;
          if verbose,fprintf('testpoint %d PASSED\n',cols*(i-1)+j);end
        else
          if verbose,fprintf('testpoint %d FAILED\n',cols*(i-1)+j);end
        end
      case {'outsideLimits'}
        if ((TestPoint.Result(i,j) < TestPoint.LowerLimit(i,j))||(TestPoint.Result(i,j) > TestPoint.UpperLimit(i,j)))
          pass=pass+1;
          if verbose,fprintf('testpoint %d PASSED\n',cols*(i-1)+j);end
        else
          if verbose,fprintf('testpoint %d FAILED\n',cols*(i-1)+j);end
        end
      case {'lessThanMax'}
        if (TestPoint.Result(i,j) < TestPoint.UpperLimit(i,j))
          pass=pass+1;
          if verbose,fprintf('testpoint %d PASSED\n',cols*(i-1)+j);end
        else
          if verbose,fprintf('testpoint %d FAILED\n',cols*(i-1)+j);end
        end
      case {'greaterThanMin'}
        if (TestPoint.Result(i,j) > TestPoint.LowerLimit(i,j))
          pass=pass+1;
          if verbose,fprintf('testpoint %d PASSED\n',cols*(i-1)+j);end
        else
          if verbose,fprintf('testpoint %d FAILED\n',cols*(i-1)+j);end
        end
      case {'skip'}
        tests=test-1;
        fprintf('testpoint %d INTENTIONALLY NOT CHECKED\n',cols*(i-1)+j);
      otherwise
        fprintf('testpoint %d TESTPOINT STRUCTURE NOT CORRECTLY CONFIGURED\n',cols*(i-1)+j);
      end
  end
end
%% display summary
if nargin==2
    if strcmp(options,'concise')
        fprintf('CASE #%d: %d out of %d PASSED\n',CASE_NUM,pass,tests);
    end
end