function out = fc_numel(data)
fn = fieldnames(data);
out = numel(data.(fn{1}));