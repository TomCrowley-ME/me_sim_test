%te_current_inertial_north.m                                      %
%                                                                         %
% inputs: [degrees degrees meters]                                        %
% inputs: geodetic latitdue, longitude, altitude wrt WGS84 ellipsoid      %
%                                                                         %
% outputs:                                                                %
% 10/17/14                                                                %
%-------------------------------------------------------------------------%

function  octave_inertial_north(utc_time_vec, latitude, longitude, filename)

addpath(pwd)
addpath([pwd filesep 'general_scripts'])

run('sim/gbl_global_parameters_init.m')

north_eci = calculate_current_inertial_north(utc_time_vec, latitude, longitude)

csvwrite(filename, north_eci)
