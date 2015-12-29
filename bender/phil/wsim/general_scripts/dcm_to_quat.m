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
% dcm_to_quat.m                                                           %
%                                                                         %
% direction cosine matrix to scalar part last quatnerion                  %
% 06/24/14                                                                %
%-------------------------------------------------------------------------%

function q = dcm_to_quat( dcm )

q = zeros(1,4);

dcm_trace = trace(dcm);

if (dcm_trace > 0)
    
    trace_factor = sqrt( dcm_trace + 1 );
 
    q(1) = (dcm(2, 3) - dcm(3, 2))/(2*trace_factor);
    q(2) = (dcm(3, 1) - dcm(1, 3))/(2*trace_factor);
    q(3) = (dcm(1, 2) - dcm(2, 1))/(2*trace_factor);
    q(4) = 0.5*trace_factor;
    
else
    d = diag(dcm);
    
    if d(2) > d(1) && d(2) > d(3)
        
        diag_factor = sqrt(d(2) - d(1) - d(3) + 1 );
                
        q(2) = 0.5*diag_factor;
                
        if ( diag_factor ~= 0 )
            diag_factor = 0.5/diag_factor;
        end

        q(1) = (dcm(1, 2) + dcm(2, 1))*diag_factor;
        q(3) = (dcm(2, 3) + dcm(3, 2))*diag_factor;
        q(4) = (dcm(3, 1) - dcm(1, 3))*diag_factor;
        
    elseif d(3) > d(1)
        
        diag_factor = sqrt(d(3) - d(1) - d(2) + 1 );
 
        q(3) = 0.5*diag_factor;

        if ( diag_factor ~= 0 )
            diag_factor = 0.5/diag_factor;
        end
        
        q(1) = (dcm(3, 1) + dcm(1, 3))*diag_factor;
        q(2) = (dcm(2, 3) + dcm(3, 2))*diag_factor;
        q(4) = (dcm(1, 2) - dcm(2, 1))*diag_factor; 

    else
        
        diag_factor = sqrt(d(1) - d(2) - d(3) + 1);
        
        q(1) = 0.5*diag_factor;
        
        if ( diag_factor ~= 0 )
            diag_factor = 0.5/diag_factor;
        end
    
        q(2) = (dcm(1, 2) + dcm(2, 1))*diag_factor;
        q(3) = (dcm(3, 1) + dcm(1, 3))*diag_factor;
        q(4) = (dcm(2, 3) - dcm(3, 2))*diag_factor; 

    end
end

