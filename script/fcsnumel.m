function out = fcsnumel(data)
fn = fieldnames(data);
out = numel(data.(fn{1}));