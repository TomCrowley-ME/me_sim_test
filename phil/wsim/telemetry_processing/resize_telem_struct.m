%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -%
% telem = resize_telem_strcut(telem, i_start_telem)                       %
%                                                                         %
% resizes structure of tscollection to all have consistent times/lengths  %
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -%


function telem = resize_telem_struct(telem, i_start_telem)

% extract struct names
message_names = fieldnames(telem);
n_messages = length(message_names);

for ii = 1 : n_messages
    
    fprintf(1, 'Resizing %s to start at index %d\n', message_names{ii}, i_start_telem)
    
    % determine message member names
    member_names  =  telem.(message_names{ii}).fieldnames;
    n_members = length(member_names);
    
    start_time = telem.(message_names{ii}).Time(i_start_telem);
    
    i_end_telem = length(telem.(message_names{ii}).Time);
    
    % create new time vector of appropriate length using cfe header
    
    time_vec = telem.(message_names{ii}).Time(i_start_telem:i_end_telem) - start_time;
    
    % create a temporary tscollection using this time
    temp_ts = tscollection(time_vec);
    
    for jj = 1 : n_members
        
        try
            % shorten each member down to the new length
            eval( sprintf('temp_ts.%s =  timeseries( getdatasamples(telem.%s.%s, [i_start_telem : i_end_telem]), temp_ts.Time,''Name'', ''%s'' );', member_names{jj}, message_names{ii}, member_names{jj}, member_names{jj}) ) ;
            
        catch err
            % some members like 'length' and 'name' are not actually ts objecs
            switch member_names{jj}
                case {'Name','Length','Time','TimeInfo'}
                    % no action needed, as these are standard
                otherwise
                    % if its something else, we might have a problem
                    rethrow(err)
            end
        end   

    end
    
    % reassign the new ts to the current message name
    telem.(message_names{ii}) = temp_ts;
    clear temp_ts
    
end


