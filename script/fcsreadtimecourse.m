function allplates = fcsreadtimecourse(datadir, stubexp, paramstokeep)
%FCSREADTIMECOURSE reads a folder of .fcs files that correspond to a time
%course experiment. Files should adhere to Jue's format.
%
%   Created 20120807
tic
disp(['Loading data from ' datadir])
allplates = struct;

% Load data
fns = dir([datadir '*.fcs']);
[~, idx] = sort([fns.datenum]);
fns = {fns(idx).name};

if exist('paramstokeep')~=1
    paramstokeep = 'rename';
end

for c=1:length(fns)
    fn = [datadir fns{c}];
    [dat met] = fcsparse(fn,paramstokeep);
    if exist('stubexp')==1
        platename = regexp(fn, stubexp,'match');
        platename = underscorify(platename{:});
    else
        platename = underscorify(fns{c}(1:end-4));
    end
    
    
    if ~isfield(allplates,platename)
        disp(['Processing ' platename])
        allplates.(platename) = struct;
    end
    
    if isfield(met,'row')
        % plate mode data
        if ~isfield(allplates.(platename), 'data')
            allplates.(platename).data = cell(8,12);
            allplates.(platename).meta = cell(8,12);
        end
        allplates.(platename).data{met.row,met.col} = dat;
        allplates.(platename).meta{met.row,met.col} = met;
    else
        % tube mode data
        allplates.(platename).data = dat;
        allplates.(platename).meta = met;
    end 
end

disp('Reformatting data into struct array.')
names = fieldnames(allplates);
newplates = struct;

for c=1:length(names)
    allplates.(names{c}).platename = names{c};
    
    if c==1
        newplates = allplates.(names{c});
    else
        newplates(c) = allplates.(names{c});
    end
end

allplates = newplates;

toc