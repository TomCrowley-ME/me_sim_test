function s = matrixToCString( mat, varargin )

% (Source published under the MIT License, see readme.txt for rationale, license text at the end)
% Copyright (c) 2011 Ian M. Garcia

s=[];
format_s = optFill( varargin, 'Format', '%10.3f' );
typePrefix_s = optFill( varargin, 'Prefix', '' );
acrossColumns_b = optFill( varargin, 'AcrossColumns', 0 );
asVector_b = optFill( varargin, 'AsVector', 0 );

if size(mat,2)==1 || acrossColumns_b
    % print vectors as lines
    mat = mat';
end

for i=1:size(mat,1)
    if size(mat,1)>1
        if i==1
            s=[s,'{'];
        else
            s=[s,' '];
        end
    end
    if ~asVector_b
        s=[s ' {'];
    end
    for j=1:size(mat,2)
        s=[s, ' ', typePrefix_s, sprintf( format_s, mat(i,j) )];
        if j < size(mat,2)
            s=[s, ','];
        end
    end
    if ~asVector_b
        s=[s,' }'];
    end
    if i < size(mat,1)
        s=[s,','];
    else
        if size(mat,1)>1
            s=[s,sprintf(' }')];
        end
    end
    s=[s,sprintf('\n')];
end

% (Source published under the MIT License, see readme.txt for rationale, license text at the end)
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
