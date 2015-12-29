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
% create_telem_name_struct.m                                              %
%                                                                         %
% create names for signals for plotting                                   %
% 02/14/15                                                                %
%-------------------------------------------------------------------------%

function name_struct = create_telem_name_struct(telem)

% extract struct names
message_names = fieldnames(telem);
n_messages = length(message_names);

for ii = 1 : n_messages
        
    % determine message member names
    member_names  =  telem.(message_names{ii}).fieldnames;
    n_members = length(member_names);
    
    for jj = 1 : n_members
        
        eval( sprintf('message_name_struct.%s = ''%s.%s'';', member_names{jj}, message_names{ii}, member_names{jj} ) ) ;
        
    end
    
    % reassign the new ts to the current message name
    name_struct.(message_names{ii}) = message_name_struct;
    
    clear message_name_struct
    
end
