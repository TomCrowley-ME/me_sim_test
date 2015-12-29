function [str, cell_str, s] = struct2str(s, disp_str, index_of_fields_to_use, x_ratio, y_ratio)
% STRUCT2STR - Converts a struct into a char string and optionally display
% its pairs of field names and field values in a list box.
% The rows of the list box visualizing the fields can be individually
% selected, and the corresponding fields can be copied to the clipboard.
% Selecting a substruct results in invoking struct2str on the substruct.
% This way a struct hierarchy can be easily traversed.
% In this way, this function can be used to paste significant fields
% of a struct to a plain text file, for documentation purposes.
% By displaying the obtained char string we get a similar output as
% the one generated by the Matlab built-in function DISP, when called on the original struct.
%
% INPUTS:
% s: the struct to be converted and optionally visualized
% disp_str: When disp_str = 1 a listbox is shown containing the string provided after the conversion of the input struct
% index_of_fields_to_use: this is vector containing the indices of the fields to convert to string
% xratio: is the normalized width of the listbox with respect to the width of the screen
% yratio: is the normalized height of the listbox with respect to the height of the screen
%
% OUTPUTS:
% str: the char string obtained after the conversion of the input struct s
% cell_str: this is a cell of string. Each cell contains a pair
% (field_name, field_value)
% s: the input struct is also returned as an output.
%
% % Example 1
%     disp('-------------------------------------------------------');
%     s.field1 = 'This is the first field of an example struct';
%     s.field2 = 35;
%     s.field3 = [ 1 2 3 4 5];
%     s.field4 = cell(4,2);
%     s.field5 = {'first_char_item','second_char_item','third_char_item'};
%     s.field6 = {[1 2 3], [4 5 6], [7 8]};
%     s.field7 = ones(10,4);
%     s.field8 = 'First unused field';
%     s.field9 = 'Second unused field';
%     s.field10 = struct('Question','The Answer to Life, the Universe, and Everything?','Answer',42);
%
%     disp_str = 1;
%     index_of_fields_to_use = [1:7,10];
%     s_title = 'The s struct';
%     s_name = 's';
%     [str, cell_str, s] = struct2str(s, disp_str, index_of_fields_to_use);
%     % In case you pressed 'Copy selected fields to clipboard ...', you can now paste
%     % the struct description on a plain text file.
%     disp('-------------------------------------------------------');
%     disp(s);
%     disp(str);
%     disp('The last two instructions should provide similarly formatted outputs on the first seven fields of s.');
%     disp('-------------------------------------------------------');

% See also STRUCT2CELL, STRUCT2ARRAY, CELL2STRUCT, FIELDNAMES.

% STRUCT2STR, $Version: 2.0, February 2008
% Author of the original version:
%      Marco Cococcioni (m.cococcioni <at> gmail.com)
% Author of this version (added recursive substruct traversal):
%      Felix Zoergiebel (felix_z <at> web.de)

if nargin < 5,
    y_ratio = 0.5;
end

if nargin < 4,
    x_ratio = 0.5;
end

if nargin < 2,
    disp_str = 0;
end

if nargin < 1,
    s.field1 = 'This is the first field of an example struct';
    s.field2 = 35;
    s.field3 = [ 1 2 3 4 5];
    s.field4 = cell(4,2);
    s.field5 = {'first_char_item','second_char_item','third_char_item'};
    s.field6 = {[1 2 3], [4 5 6], [7 8]};
    s.field7 = ones(10,4);
    s.field8 = 'First unused field';
    s.field9 = 'Second unused field';
    s.field10 = struct('Question','The Answer to Life, the Universe, and Everything?','Answer',42);

    disp_str = 1;
    index_of_fields_to_use = [1:7,10];
    s_title = 'The s struct';
    s_name = 's';
    [str, cell_str, s] = struct2str(s, disp_str, index_of_fields_to_use);
    return
else
    s_name  = inputname(1);
    if isempty(s_name), s_name='unnamed'; end
    s_title = sprintf('The %s struct',s_name);
end

s=s(:);

len = length(s);
fnames = fieldnames(s(1));

if nargin < 3,
    index_of_fields_to_use = 1:length(fnames);
elseif isempty(index_of_fields_to_use),
    index_of_fields_to_use = 1:length(fnames);
end


str = '';

k = 1;

max_len = 0;
for l = 1:len
    for f = 1:length(fnames)
        l = length(fnames{f});
        if l > max_len,
            max_len = l;
        end
    end
end

max_len = max_len + length(s_name) + 3;

fmt1  = sprintf('%%s%%%ds: %%s\n', max_len);
fmt2 =  sprintf('%%s%%%ds: [%%dx%%d double]\n', max_len);
fmt3 =  sprintf('%%s%%%ds: {%%dx%%d cell}\n', max_len);
fmt4 =  sprintf('%%s%%%ds: [%%dx%%d %%s]\n', max_len);

fmt11  = sprintf('%%%ds: %%s\n', max_len);
fmt22 =  sprintf('%%%ds: [%%dx%%d double]\n', max_len);
fmt33 =  sprintf('%%%ds: {%%dx%%d cell}\n', max_len);
fmt44 =  sprintf('%%%ds: [%%dx%%d %%s]\n', max_len);

for l = 1:len
    for f = 1:length(fnames)

        if not(isempty(find(f == index_of_fields_to_use, 1))),

            [nr,nc] = size(getfield(s,{l},fnames{f}));

            if ischar(getfield(s,{l},fnames{f}))
                str = sprintf(fmt1,str,fnames{f}, [ '''' getfield(s,{l},fnames{f}) ''''] );
                cell_str{k} = sprintf(fmt11,fnames{f},[ '''' getfield(s,{l},fnames{f}) ''''] );
                k = k + 1;
            elseif isnumeric(getfield(s,{l},fnames{f}))
                if (max(nr,nc) < 9 && min(nr,nc)==1)
                    if nr==1 && nc == 1,
                        str = sprintf(fmt1,str,fnames{f}, num2str(getfield(s,{l},fnames{f})));
                        cell_str{k} = sprintf(fmt11,fnames{f}, num2str(getfield(s,{l},fnames{f})));
                        k = k + 1;
                    else
                        str = sprintf(fmt1,str,fnames{f}, [ '[' num2str(getfield(s,{l},fnames{f})) ']' ]);
                        cell_str{k} = sprintf(fmt11,fnames{f}, [ '[' num2str(getfield(s,{l},fnames{f})) ']' ] );
                        k = k + 1;
                    end
                else
                    str = sprintf(fmt2,str,fnames{f},nr,nc);
                    cell_str{k} = sprintf(fmt22,fnames{f},nr,nc);
                    k = k + 1;
                end
            elseif iscell(getfield(s,{l},fnames{f})),
                if (max(nr,nc) < 9 && min(nr,nc)==1),
                    d = getfield(s,{l},fnames{f});
                    d = d(:)';
                    if ischar(d{1}),
                        m = 2;
                        while m <= length(d) && (ischar(d{m})),
                            m = m + 1;
                        end
                        if m - 1 == length(d),
                            d_str = '{';
                            for n=1:m-2,
                                d_str = sprintf('%s''%s''  ',d_str,d{n});
                            end
                            d_str = sprintf('%s''%s''}',d_str,d{m-1});
                            str = sprintf(fmt1,str,fnames{f},d_str);
                            cell_str{k} = sprintf(fmt11,fnames{f},d_str);
                            k = k + 1;
                        end
                    elseif isnumeric(d(1)),
                        error('DA_TERMINARE!')
                        keyboard
                    else
                        str = sprintf(fmt3,str,fnames{f},nr,nc);
                        cell_str{k} = sprintf(fmt33,fnames{f},nr,nc);
                        k = k + 1;
                    end
                else
                    str = sprintf(fmt3,str,fnames{f},nr,nc);
                    cell_str{k} = sprintf(fmt33,fnames{f},nr,nc);
                    k = k + 1;
                end
            else
                str = sprintf(fmt4,str,fnames{f},nr,nc,class(getfield(s,{l},fnames{f})));
                cell_str{k} = sprintf(fmt44,fnames{f},nr,nc,class(getfield(s,{l},fnames{f})));
                k = k + 1;
            end
        end
    end
end

if disp_str,
    clipboard('copy',str);
    screen_size = get(0,'ScreenSize');
    [ind, ok] = listdlg('ListString',cell_str,'OKString','Copy selected fields to clipboard and quit','ListSize',[x_ratio*screen_size(3), y_ratio*screen_size(4)],'name',s_title, 'InitialValue', 1:length(cell_str));
    if ok,
        clipboard('copy', sprintf('%s = \n%s', s_name, cat(2,cell_str{ind})));
        name=fnames{index_of_fields_to_use(rem(ind-1,length(fnames))+1)};
        el=s(1).(name);
        if isstruct(el)
            newel=[s_name,'_1_dot_',name];
            eval([newel,'=el;']);
            eval(['[str, cell_str, s]=struct2str(',newel,', disp_str, [], x_ratio, y_ratio);']);
        end
    end
end