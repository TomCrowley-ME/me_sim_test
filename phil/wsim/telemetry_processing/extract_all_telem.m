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
% extract_all_telem.m                                                     %
%                                                                         %
% loads data from directory, either phil or wsim                          %
% 05/30/13                                                                %
%-------------------------------------------------------------------------%

function [ telem error_flag ] = extract_all_telem( scenario_data, type_string )

telem = [];
error_flag = 0;

% ESC: this file is a mess given how unknown this whole thing is right now.....

switch type_string
    
    case 'fsw'
        
       bus_names = fieldnames(scenario_data);
       telem = [];
        
       for jj = 1 : length( bus_names )
           
           temp_tscollection = tscollection;
           
           if isempty( regexpi(bus_names{jj},'sim') ) && isempty( regexpi(bus_names{jj},'veh') )
               
               prefix = bus_names{jj};
              
               temp_tscollection = pull_out_signals(temp_tscollection, scenario_data.(bus_names{jj}), prefix);
               
               eval(['telem.' prefix ' = temp_tscollection;'])
               
           end
           
           
       end
        
        
    case 'sim'
        
       bus_names = fieldnames(scenario_data);
       telem = [];
        
       for jj = 1 : length( bus_names )
           
           temp_tscollection = tscollection;
           
           if ~isempty( regexpi(bus_names{jj},'sim') ) || ~isempty( regexpi(bus_names{jj},'veh') )
               
               prefix = bus_names{jj};
              
               temp_tscollection = pull_out_signals(temp_tscollection, scenario_data.(bus_names{jj}) ,prefix);
               
               eval(['telem.' prefix ' = temp_tscollection;'])

           end
           
          
       end
        
    otherwise
        error_flag = 1;
        error(sprinf('cannot extract telemetry for type_string = %s',type_string))
        
        
end

function telem = pull_out_signals(telem, data_struct, prefix)

signal_names = fieldnames(data_struct);

for kk = 1 : length(signal_names)
    
    if ~isstruct( data_struct.(signal_names{kk}) )
        
        %eval( sprintf('telem.%s_%s = data_struct.(signal_names{kk});',prefix,signal_names{kk}) )
        
        try
            eval( sprintf('telem = addts(telem, data_struct.(signal_names{kk}), ''%s'');', signal_names{kk}) )
            %eval( sprintf('telem.%s = setinterpmethod(telem.%s, ''zoh'');', signal_names{kk}, signal_names{kk} ) )
        catch
            fprintf(1,'telem = addts(telem, data_struct.(signal_names{kk}), ''%s'');', signal_names{kk})
        end
    
    else

        telem = pull_out_signals(telem, data_struct.(signal_names{kk}), prefix);
    
    end
  

end

    
    
    
    