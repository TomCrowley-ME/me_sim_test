function diginto(thestruct, level,varargin)

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

values_b=optFill(varargin,'Values',1);
fid=optFill(varargin,'UseFid',1);

if nargin < 2
    level = 0;
end

fn = fieldnames(thestruct);
for n = 1:length(fn)
    tabs = '';
    for m = 1:level
        tabs = [tabs '    '];
    end
    fn2 = getfield(thestruct,fn{n});
    if isstruct(fn2)
        fprintf(fid,[tabs fn{n}]);
        fprintf(fid,'\n');
        diginto(fn2, level+1,varargin{:});
    else
        if values_b
            if length(size(fn2))>2
                for sub=1:size(fn2,3)
                    fprintf(fid,'%s (%d) = %s\n',[tabs fn{n}],sub,mat2str(fn2(:,:,sub)) );
                end
            else
                fprintf(fid,'%s = %s\n',[tabs fn{n}],mat2str(fn2));
            end
            %fn2 %#ok<NOPRT>
        else
            fprintf(fid,'%s',[tabs fn{n}]);
            fprintf(fid,'\n');
        end
    end
end

end
