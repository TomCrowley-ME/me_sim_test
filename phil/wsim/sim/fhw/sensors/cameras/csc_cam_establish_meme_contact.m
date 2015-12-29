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
% csc_cam_establish_meme_contact.m                                        %
%                                                                         %
% figure out if server is available if desired                            %
% 07/26/12                                                                %
%-------------------------------------------------------------------------%


function cam_use_meme_flag = csc_cam_establish_meme_contact(cam_attempt_to_use_meme_flag, meme_ip, meme_port)

if cam_attempt_to_use_meme_flag
    meme_str = strrep(meme_ip, ' ', '.');
    % attempt to contact server
    % if successful:
    meme_status = ping(meme_str);
    if meme_status == 0 
        % Ping was successful
        if ~exist('model_name','var')
            model_name = 'nimbus';
        end
        args = find_system(model_name, ...
            'FollowLinks', 'on', ...
            'LookUnderMasks', 'all', ...
            'FunctionName', 'sfun_tcp');
        for i = 1:length(args)
            set_param(char(args(i)), 'Parameters', [meme_ip ' ' meme_port]);
        end
        fprintf('Contact made with %s, using meme.\n', meme_str)
        cam_use_meme_flag = 1;
    else
        fprintf('No contact made with %s, using old model.\n', meme_str)
        cam_use_meme_flag = 0;
    end
else
    cam_use_meme_flag = 0;
end