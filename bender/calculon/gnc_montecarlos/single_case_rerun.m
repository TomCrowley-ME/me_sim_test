% Single case rerun
load('doi_to_touchdown_mc73.mat')
sim('nimbus');
cd /home/jkaidy/me_sim/bender/phil/wsim/scenarios/scenario_3_deorbit_to_landing/scn3_wsim_data/;
process_test_data
cd ../../..