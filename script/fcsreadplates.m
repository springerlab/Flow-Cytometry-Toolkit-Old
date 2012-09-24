function allplates = fcsreadplates(datadir, varargin)
%FCSREADPLATES reads a folder of .fcs files that correspond to a time
%course experiment. Files should adhere to Jue's format.
%
%   Created 20120807
%   Updated 20120821
%
%   Updated 20120909: renamed from fcsreadplateseries to fcsreadplates. Now
%   reads plate data in subfolders (LSRII) as well as all fcs files in a
%   single folder (Stratedigm)
%   Updated 20120914: platename info is updated to be extracted from met
%   data, instead of file name
%   Updated 20120920: update platename to be foldername + plate_id(from met)
tic

p = inputParser;
addRequired(p,'datadir',@ischar);
addOptional(p,'platenameregexp','',@ischar);
addParamValue(p,'keepunmatched',false,@islogical);
addParamValue(p,'keepparams','rename',@ischar);
addParamValue(p,'loadsubfolders',false,@islogical);
addParamValue(p,'output','array',@ischar);

parse(p,datadir, varargin{:});
platenameregexp = p.Results.platenameregexp;
keepunmatched= p.Results.keepunmatched;
keepparams = p.Results.keepparams;
loadsubfolders = p.Results.loadsubfolders;
output = p.Results.output;

disp(['Loading data from ' datadir])
allplates = struct;

% look for fcs files
% sorting by date helps load plates one at a time
fns = dir([datadir '*.fcs']);
[~, idx] = sort([fns.datenum]);
fns = {fns(idx).name};

if ~isempty(fns)
    disp('Found fcs files. Loading...');
    for c=1:length(fns)
        fn = [datadir fns{c}];
        
        % give current plate a name
        platename = '';
        %         if ~isempty(platenameregexp)
        %             % give plate name by regular expression match on filename
        %             [match,tokens] = regexp(fn, platenameregexp,'match','tokens');
        %             if ~isempty(tokens) && ~isempty(tokens{1})
        %                 platename = underscorify(tokens{1}{1});
        %             elseif ~isempty(match)
        %                 platename = underscorify(match{1});
        %             end
        %         end
        
        % read data
        %         if ~isempty(platename) || keepunmatched
        [dat met] = fcsparse(fn,keepparams);
        %         disp(fn);
        
        % if necessary, use filename as plate name
        if isempty(platename)
            % platename = underscorify(fns{c}(1:end-4));
            platename = met.plate_name;
        end
        
        if ~isfield(allplates,platename)
            disp(['Loading ' platename])
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
        %         end
    end
end

% no fcs files: load fcs files in subfolders instead
% force this by setting loadsubfolders=true
if isempty(fns) || loadsubfolders
    folders = dir(datadir);
    folders = folders(3:end);
    folders = folders([folders.isdir]);
    folders = {folders.name};
    
    for c=1:length(folders)
        folder = [datadir folders{c} '/'];
        
        fns = dir([folder '*.fcs']);
        fns = {fns.name};
        
        % read data
        for j=1:length(fns)
            fn = [datadir folder fns{j}];
            
            %             disp(fn);
            [dat met] = fcsparse(fn,keepparams);
            
            % use foldername as plate name
            platename = folders{c};
            platename = [platename, met.plate_name];
            
            if ~isfield(allplates,platename)
                disp(['Loading ' platename])
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
                % use filename as plate name
                platename = underscorify(fns{c}(1:end-4));
                allplates.(platename).data = dat;
                allplates.(platename).meta = met;
            end
        end
    end
end

if strcmpi(output,'array')
    disp('Formatting data into struct array.');
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
end

toc