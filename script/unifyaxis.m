function unifyaxis(h_fig, property, property_value)
% 
% for example:
%     unifyaxis(gcf, 'xlim')
% 

if nargin < 3
    lim_array = cell2mat(get(get(h_fig, 'children'), property));
else
    lim_array = property_value;
end

set(get(h_fig, 'children'), property, [min(lim_array(:,1)), max(lim_array(:,2)),])