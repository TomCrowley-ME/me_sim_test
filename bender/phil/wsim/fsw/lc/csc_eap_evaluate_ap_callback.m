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
% csc_eap_evaluate_ap_callback.m                                          %
%                                                                         %
% Initialization callback for csc_eap_evaluate_ap mask initialization     %
%                                                                         %
% Inputs:    1. Path for block to update (gcb from the mask)              %
%            2. RPN equation for the actionpoint                          %
%            3. Type of event to be generated when RTS is triggered       %
%                                                                         %
% 08/23/13                                                                %
% mikestewart@moonexpress.com                                             %
%-------------------------------------------------------------------------%

function csc_eap_evaluate_ap_callback(blk, rpn_equation, event_type)

% The event level can't be set through a mask variable directly, so we need
% to set it manually here
event_params = get_param([blk '/action_triggered_event'], 'MaskValues');
event_params{3} = event_type;
set_param([blk '/action_triggered_event'], 'MaskValues', event_params);

% Pass along the RPN equation in its native numeric form for the RPN block
% to interpret how it pleases
set_param([blk '/csu_rpn_ap_rpn_evaluation'], 'MaskValues', {rpn_equation});

end