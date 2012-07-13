function data_filter = fcsselect(data, idx)
%
% select events in data according to idx
% idx should have the same number of row 

data_filter = struct;

for field_name = fieldnames(data)'
    channel = data.(field_name{1});
    data_filter.(field_name{1}) = channel(idx);    
end