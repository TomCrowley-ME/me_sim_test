%-------------------------------------------------------------------------%
% FRESH_CHECKOUT_README.TXT                                               %
%                                                                         %
%-------------------------------------------------------------------------%

If you've just done a fresh checkout of the code, you need to do the following steps to get up and running:

1) If you haven't already done so, call mex -setup from the matlab command line and choose a compiler. If you don't have a C/C++ compiler, get one.

2) Navigate to bender/phil/wsim.

3) Run nimbus_set_path.m. This script is intelligent, and will guide you through setting up the repository for use if it is unable to find its needed paths (only working on linux/mac -- windows still needs manual cloning of subrepos for now).

4) Now you are ready to run the model by calling the run script of the desired scenario. These scripts have names in the form of run_scn#_....m.

