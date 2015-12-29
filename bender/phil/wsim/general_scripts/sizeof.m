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
% sizeof.m                                                                %
%                                                                         %
% Returns the size of a specified numeric type in bytes                   %
%                                                                         %
% Input:  type (string, eg 'uint16')                                      %
% Output: size in bytes                                                   %
%                                                                         %
% 08/16/13                                                               %
%-------------------------------------------------------------------------%

function byte_size = sizeof(type)

test_value = eval([type '(0)']);
test_info = whos('test_value');

byte_size = test_info.bytes;