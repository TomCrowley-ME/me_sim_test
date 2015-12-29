% Nimbus Estimation Review Monte Carlo

load MC_WORKSPACE
clear mc_all_initial mc_all_final

mc_prefix_s = 'lander_sensors_mc';
mc_i = 1:mc_n;
iin = index_mcall_initial;
ifi = index_mcall_final;
mc_all_initial = zeros(length(mc_i),iin.n);
mc_all_final = zeros(length(mc_i),ifi.n);

for i_count = 1 : length(mc_i)
    
    imc = mc_i( i_count );
    name_mc = [ mc_prefix_s num2str(imc) ];
    if exist(strcat(name_mc,'.mat'),'file')
        load( name_mc );
    else
        continue
    end
    
    mc_all_initial(i_count,:) = extract_mcall_initial_from_workspace( imc, truth, telem, error );
    mc_all_final(i_count,:)   = extract_mcall_final_from_workspace( imc, truth, telem, error ); 

    fprintf('-- %d out of %d\n',imc,length(mc_i) );
end

save([mc_prefix_s 'all'],'mc_all_initial','mc_all_final','iin','ifi','ivars','mc_6dof_variables','mc_prefix_s');


%% pull out runs in each of several bins in each parameter

n_bins = 10;
variable_names = fieldnames(ivars);

for pp = 1 : size(mc_6dof_variables,2)
    
    var_name = char(variable_names{pp});
    
    eval(['dispersions = mc_6dof_variables(:,ivars.' var_name ');'])
    
    dispersion_range = max(dispersions) - min(dispersions) ;
    if dispersion_range == 0
        continue
    end
    bins = [min(dispersions) : dispersion_range/n_bins : max(dispersions)];
    
    clear indices
    indices = cell(n_bins);
    
    for kk = 2 : length(bins)
        
        percent_bin = [bins(kk-1) bins(kk)];
        
%         eval(['indices{kk-1} = find(mc_all_initial(:,iin.' var_name ') >= percent_bin(1) & mc_all_initial(:,iin.' var_name ') < percent_bin(2))']);
        eval(['indices{kk-1} = find(mc_6dof_variables(:,ivars.' var_name ') >= percent_bin(1) & mc_6dof_variables(:,ivars.' var_name ') < percent_bin(2));']);
        
        
        % construct structure for this variable
        temp_struct.name = var_name;
        temp_struct.bins = bins;
        temp_struct.bin_centers = bins(1:n_bins) + (dispersion_range/n_bins)/2;
        temp_struct.bin(kk-1).n_runs = length( indices{kk-1} );
        temp_struct.bin(kk-1).indices =  indices{kk-1} ;
        
        temp_struct.bin(kk-1).mean_gnc_pos =  mean(mc_all_final(indices{kk-1},ifi.gnc_pos_err),1);
        temp_struct.bin(kk-1).std_gnc_pos = std(mc_all_final(indices{kk-1},ifi.gnc_pos_err),1);
        
        temp_struct.bin(kk-1).mean_gnc_vel =  mean(mc_all_final(indices{kk-1},ifi.gnc_vel_err),1);
        temp_struct.bin(kk-1).std_gnc_vel = std(mc_all_final(indices{kk-1},ifi.gnc_vel_err),1);
        
        temp_struct.bin(kk-1).mean_est_pos =  mean(mc_all_final(indices{kk-1},ifi.est_pos_err),1);
        temp_struct.bin(kk-1).std_est_pos = std(mc_all_final(indices{kk-1},ifi.est_pos_err),1);
        
        temp_struct.bin(kk-1).mean_est_vel =  mean(mc_all_final(indices{kk-1},ifi.est_vel_err),1);
        temp_struct.bin(kk-1).std_est_vel = std(mc_all_final(indices{kk-1},ifi.est_vel_err),1);
        
        temp_struct.bin(kk-1).mean_fuel_used =  mean(mc_all_final(indices{kk-1},iin.mass),1) - mean(mc_all_final(indices{kk-1},ifi.mass),1);
        temp_struct.bin(kk-1).std_fuel_used = std(mc_all_final(indices{kk-1},ifi.mass),1);
        
    end
    
    % rename structure
    
    eval(['data_struct_' var_name ' = temp_struct;'])
    var_name_string = ['data_struct_' var_name ];
    eval(['save([mc_prefix_s ''all''], var_name_string, ''-append'')']);
    clear temp_struct
    
end


