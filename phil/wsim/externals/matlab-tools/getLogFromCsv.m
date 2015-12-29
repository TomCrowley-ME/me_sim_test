function [d,i,ch,t,fileName_s] = getLogFromCsv( fileName_s, varargin )
% GETLOGFROMCSV Turns a CSV telemetry file into a matrix, index and time
%  [d,i,ch] = GetLogFromBin( fileName_s ) Calls the readtelemetry.exe to 
% translate binary fileName_s into a .csv file, then reads the .csv file
% and creates an index file and list of column headers from it
%  d - data
%  i - index structure (i.t = index of t, i.n number of columns, i.Gaext6 
%      is guidance external analog)
%  ch - column header list
%  t - time in seconds
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

dt = optFill( varargin, 'dt', 1/1000);

data=importdata( fileName_s);
d=data.data;
ch=data.colheaders;

i = indexFromColheaders( data.colheaders );
i.n = length(ch);

if isfield( i, 'time' )
    i.t = i.time;
    t=unwrapt(d(:,i.t))*dt;
else
    t=[];
end    
