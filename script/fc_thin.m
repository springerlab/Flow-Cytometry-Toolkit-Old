function thindata = fc_thin(data,num)
%THINDATA retrieves a subset of the data in a flow cytometry data struct.
%This is most useful when you want to avoid saturating a scatter plot with
%points.
%
%   THINDATA(DATA,NUM) returns a new data struct that contains either NUM
%   events, if NUM >= 1, or a fraction of the events in DATA, if NUM < 1.
%
%   Created 2012/7/13 by JW

if exist('num')~=1
    % default
    num = 50000;
end

fns = fieldnames(data)';
n = length(data.(fns{1}));

if num < 1
    % pull out a fraction of the data (approx)
    k = 10./num;
    idx = 1:k:n;
else
    % pull out a specific number of events
    idx = randperm(n,num);
end

% filter each channel
for c = 1:length(fns)
    thindata.(fns{c}) = data.(fns{c})(idx);
end