function allplates = fcsreadplateseries(datadir, filenamestub, varargin)
%FCSREADPLATESERIES reads a folder of .fcs files that correspond to a time
%course experiment. Files should adhere to Jue's format.
%
%   Created 20120807
%   Updated 20120821
tic

p = inputParser;
addRequired(p,'datadir',@ischar);
addOptional(p,'filenamestub','',@ischar);
addParamValue(p,'keepparams','rename',@ischar);
addParamValue(p,'noplates',false,@islogical);

parse(p,datadir, filenamestub, varargin{:});
filenamestub = p.Results.filenamestub;
keepparams = p.Results.keepparams;
noplates = p.Results.noplates;

disp(['Loading data from ' datadir])
allplates = struct;

% Load data
fns = dir([datadir '*.fcs']);
[~, idx] = sort([fns.datenum]);
fns = {fns(idx).name};

for c=1:length(fns)
    fn = [datadir fns{c}];
    
    platename = '';
    if ~isempty(filenamestub)
        platename = regexp(fn, filenamestub,'tokens');
        if ~isempty(platename) && ~isempty(platename{1})
            platename = underscorify(platename{1}{1});
        end
    elseif noplates
        platename = underscorify(fns{c}(1:end-4));
    end    
    
    if ~isempty(platename)
        [dat met] = fcsparse(fn,keepparams);
%         disp(fn);
        
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
end

% disp('Reformatting data into struct array.')
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