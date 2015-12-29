function mask_checkbox_set_param_enabled(block, checkbox_name, param_name)

enabled = strcmp(get_param(block, checkbox_name), 'on');

mask_enables = get_param(block, 'MaskEnables');
mask_names = get_param(block, 'MaskNames');

param_idx = find(strcmp(mask_names, param_name));

if enabled
    mask_enables{param_idx} = 'on';
else
    mask_enables{param_idx} = 'off';
end
set_param(gcb, 'MaskEnables', mask_enables);

end