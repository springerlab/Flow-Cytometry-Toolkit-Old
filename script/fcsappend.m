function [ data_append ] = fcsappend( data1, data2 )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

data_append = data1;

for field_name = fieldnames(data1)'
    data_append.(field_name{1}) = cat(1, data1.(field_name{1}), data2.(field_name{1}));
end

end