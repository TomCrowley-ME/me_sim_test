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

%-------------------------------------------------------------------------%
% csu_rpn_ap_rpn_evaluation_callback.m                                    %
%                                                                         %
% Initialization callback for csc_eap_evaluate_ap mask initialization     %
% Parses RPN equation string into infix notation for a formula block      %
%                                                                         %
% Inputs:    1. Path for block to update (gcb from the mask)              %
%            2. RPN equation string                                       %
%                                                                         %
% 08/23/13                                                                %
% mikestewart@moonexpress.com                                             %
%-------------------------------------------------------------------------%

function csu_rpn_ap_rpn_evaluation_callback(blk, rpn_equation)

% Start by splitting the supplied RPN string into tokens
rpn_tokens = strsplit(strtrim(rpn_equation));

% Preallocate the biggest possible stack the RPN can use
rpn_stack = cell(1, length(rpn_tokens));
rpn_stack_ptr = 0;

for i=1:length(rpn_tokens)
    tok = rpn_tokens{i};
    
    if isnan(str2double(tok))
        % Token was not a number, so it must be an operator
        switch tok
            case 'AND'
                if rpn_stack_ptr < 2
                    error(['RPN error: cannot apply AND to single argument in ''' rpn_equation '''']);
                else
                    rpn_stack{rpn_stack_ptr - 1} = ['(' rpn_stack{rpn_stack_ptr - 1} ' && ' rpn_stack{rpn_stack_ptr} ')'];
                    rpn_stack_ptr = rpn_stack_ptr - 1;
                end
            case 'OR'
                if rpn_stack_ptr < 2
                    error(['RPN error: cannot apply OR to single argument in ''' rpn_equation '''']);
                else
                    rpn_stack{rpn_stack_ptr - 1} = ['(' rpn_stack{rpn_stack_ptr - 1} ' || ' rpn_stack{rpn_stack_ptr} ')'];
                    rpn_stack_ptr = rpn_stack_ptr - 1;
                end
            case 'NOT'
                if rpn_stack_ptr < 1
                    error(['RPN error: cannot apply NOT with no argument in ''' rpn_equation '''']);
                else
                    rpn_stack{rpn_stack_ptr} = ['(!' rpn_stack{rpn_stack_ptr} ')'];
                end
            otherwise
                % Unrecognized operator
                if isempty(tok)
                    % Fall through in case an empty string snuck in
                    break;
                else
                    % Got garbage, report
                    error(['RPN error: found unknown token ' tok ' in ''' rpn_equation '''']);
                end
        end
    else
        % Token was a number, so push it onto the stack
        rpn_stack_ptr = rpn_stack_ptr + 1;
        rpn_stack{rpn_stack_ptr} = ['u(' tok ')'];
    end
end

% After all of this, the number of elements on the stack should be exactly
% one. Otherwise we got an incomplete RPN and can't continue
if rpn_stack_ptr ~= 1
    error(['Incomplete RPN ''' rpn_equation ''' supplied -- resulting stack does not have a single element']);
end

set_param([blk '/infix_ap_equation'], 'Expr', rpn_stack{1});

end