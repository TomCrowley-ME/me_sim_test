function [complete_msg] = port_color(library_name)
%Colors input and output ports for given block
set_param(char(library_name),'Lock','off')
inputs=find_system(library_name,'regexp','on','blocktype','In');
outputs=find_system(library_name,'regexp','on','blocktype','Out');
li=length(inputs);
lo=length(outputs);
for i=1:li
    set_param(char(inputs(i)),'BackgroundColor','green')
end
for i=1:lo
    set_param(char(outputs(i)),'BackgroundColor','red')
end
TF=0;
while TF~=1
    user_entry = input('Would you like to save this model now? y/n','s');
    TF = strcmp(user_entry,'y');
    if TF==1
        save_system(library_name);
        complete_msg = 'Model has been changed and saved.';
    else
        TF = strcmp(user_entry,'n');
        if TF == 1
            complete_msg = 'Model changes not saved.';
        end
    end
end
