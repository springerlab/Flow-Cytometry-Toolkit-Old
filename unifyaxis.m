function unifyaxis(h_fig, property)
% 
% for example:
%     unifyaxis(gcf, 'xlim')
% 

lim_array = cell2mat(get(get(h_fig, 'children'), property));
set(get(h_fig, 'children'), property, [min(lim_array(:,1)), max(lim_array(:,2)),])