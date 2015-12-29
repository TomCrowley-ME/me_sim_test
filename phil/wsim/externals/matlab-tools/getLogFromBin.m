function [d,i,ch,t, fileName_s] = getLogFromBin( fileName_s, varargin )
% GETLOGFROMBIN Turns a binary Ventions telemetry file into a csv and index
%  [d,i,ch] = GetLogFromBin( fileName_s ) Calls the readtelemetry.exe to 
% translate binary fileName_s into a .csv file, then reads the .csv file
% and creates an index file and list of column headers from it
%  d - data
%  i - index structure (i.t = index of t, i.n number of columns, i.Gaext6 
%      is guidance external analog)
%  ch - column header list
%
% Typical use:
%  0-(change execPath_s inside the function to point to your ReadTelemetry.exe file)
%  1- type [d,i,ch]=GetLogFromBin(uigetfile('*.dat',''));t=(unwrap(d(:,i.t))-d(1,i.t))/1000;
%       to prompt for a file and get data
%  2- figure;plot(t,d(:,[i.Gaext6Raw i.Gaext7Raw i.diagA0 i.diagB0]),'.-');ylim([-1000 5000]);grid on
%       for example, to plot raw actuators x and y positions and "modified" positions 
%

% (Source published under the MIT License, see readme.txt for rationale)
% 
% Copyright (c) 2011 Ian M. Garcia
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.
% 
% (http://www.opensource.org/licenses/mit-license.php)

execPath_s = optFill( varargin, 'Parser', 'C:\Ventions\Code\Flight\Mains\LogParser-build-desktop\debug\ReadTelemetry.exe' );

command_s = [execPath_s ' ' fileName_s ' --ignore-last-zero 1 > ' fileName_s '.csv'];
fprintf( '%s\n', command_s );

[status,result] = system( command_s );
if status ~= 0
    error(result);
end

[d,i,ch,t]=getLogFromCsv( [ fileName_s '.csv'], varargin{:} );

