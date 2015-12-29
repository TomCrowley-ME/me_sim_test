%FUNCTION:  unit_test_record
%Record and display the results of unit tests.
%
%unit_test_record(arg1)
% When a single argument is given, it must be either 'reset' or 'show'.
%    arg1= 'reset' zeros the pass and fail counters.
%    arg1= 'show' displays the results of all of the unit 
%    tests since the last reset
%
%unit_test_record(arg1,arg2,{arg3})
%When two or three arguments are given, arg1 must be either 'pass' or
%'fail'.  
%      arg1='pass' increments the pass counter, and prints pass string. 
%      arg1='fail' increments the fail counter, and prints fail string.
%      In either case, arg2 is required and corresponds to the 
%      requirement number (eg. 27)that was violated.
%      arg3 is an optional comment that can be displayed with the string.


function unit_test_record(str,varargin)

% initialize variables
global pass_count 
global fail_count

if(isempty(pass_count))
     pass_count=0; fail_count=0;
end

requirement=[];comment=[];

%get the file name of the calling function 
[st,i]=dbstack;
if(size(st,1)>1)
    callingFunction=st(2).file(1:end-2);
else
    callingFunction=st(1).file(1:end-2);
end

%check number of arguments
if(nargin<1 || nargin>3)
    disp(['FAILED:: ' callingFunction ' -Illegal number of arguments to unit_test_record']);
    return;
end

%handle the single arguments
if(nargin==1)
    switch lower(str)
        case {'show'}
            disp(['Unit Tests Passed: ' int2str(pass_count)]);
            disp(['Unit Tests Failed: ' int2str(fail_count)])
        case {'reset'}
            disp('unit_test_record reset complete');
            pass_count=0; fail_count=0;
        otherwise
            disp(['FAILED::' callingFunction ' -Illegal single argument in unit_test_record']);
    end
    return
else
    %create the requirement number string
    if(~isnumeric(varargin{1}))
        disp(['FAILED:: ' callingFunction ' -Illegal second argument in unit_test_record']);
        return
    else
        reqNum=int2str(varargin{1});
        subindex=max(findstr(callingFunction,'test'));
        requirement=[callingFunction(1:subindex-1) '0000'];
        requirement(length(requirement)-length(reqNum)+1:end)=reqNum;
    end
    
    %create the comment string if it exists.
    if(nargin==3)
        if(~ischar(varargin{2}))
            disp(['FAILED:: ' callingFunction ' -Illegal third argument in unit_test_record']);
            return
        else
            comment=[' - ' varargin{2}];
        end
    end

    % check first argument type and do operation specified
    switch lower(str)
    case {'pass'}
         pass_count=pass_count+1;
         disp(['passed:: ' requirement comment]);
    case {'fail'}
        fail_count=fail_count+1;
        disp(['FAILED:: ' requirement comment]);
    otherwise
        disp(['FAILED::' callingFunction ' -Illegal first argument in unit_test_record']);
        return
    end
end

       
        
