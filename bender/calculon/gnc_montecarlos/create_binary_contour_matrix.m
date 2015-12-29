%-------------------------------------------------------------------------%
% create_binary_contour_matrix.m                                          %
%                                                                         %
% creates the a contourable matrix from two differnt data_struct_*s       %
% which returns percentage of runs which exceed some threshold            %
%                                                                         %
% inputs :                                                                %
% ifi_name_string = name from ifi structure, which indexes in mcall_final %
% axisname = '' for all, 'x' 'y' 'z' for 1 2 3, 'xy' takes norm of [1 2]  %
% data_struct_a = independent variable, x axis of countour                %
% threshold = numerical value, case fails if value(axis) > threshold      %
% data_struct_b = independent variable, y axis of countour                %
%                                                                         %
% 10/18/12                                                                %
%-------------------------------------------------------------------------%

function [ contour_z, n_runs ] = create_binary_contour_matrix(ifi_name_string, axis_name, threshold, data_struct_a, data_struct_b)

ifi = evalin('base','ifi');
mc_all_final = evalin('base','mc_all_final');

n_bins = length(data_struct_a.bin_centers);

contour_z = NaN(n_bins, n_bins);
n_runs = zeros(n_bins, n_bins);

switch axis_name
    case 'x'
        num_string = '1';
    case 'y'
        num_string = '2';
    case 'z'
        num_string = '3';
    case 'xy'
        num_string = '[1 2]';
    case ''
        num_string = ':';
    otherwise
        num_string = ':';
end

for ii = 1 : n_bins
    for jj = 1 : n_bins
        
        index_a = data_struct_a.bin(ii).indices;
        index_b = data_struct_b.bin(jj).indices;
        
        C = intersect(index_a,index_b);
      
        if ~isempty(C)
            eval(['contour_z(ii,jj) = mean( normrows(mc_all_final(C,ifi.' ifi_name_string '(' num_string '))) > ' num2str(threshold) ' ,1);'])
            n_runs(ii,jj) = length(C);
        end
        
        
        
    end
end

% this puts the matrix in the right orientation for the contouring
 contour_z = rot90(contour_z,3);
 contour_z = fliplr(contour_z);