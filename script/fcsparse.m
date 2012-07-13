function [datastruct metadata]= fcsparse(filename, paramstokeep)
% FCSPARSE parses an FCS 3.0 file. It works on tube-mode and plate-mode
% (single-well) data files.
%
%   Created 2012/07/12 JW
%

% Stratedigm file
[data,paramVals,textHeader] = fcsread(filename);

% process data for each parameter (i.e. fluorescence channel)
datastruct = struct;
pnamelist = {paramVals.Name};

if exist('paramstokeep') ~= 1
    paramstokeep = 'all';
end

if ischar(paramstokeep)
    % keyword mode
    if strcmp(paramstokeep,'all')
        % grab all parameters (DEFAULT)
        for c=1:length(pnamelist)
            parname = underscorify(pnamelist{c});
            datastruct.(parname) = data(:,c);
        end
    elseif strcmp(paramstokeep,'common')    
        % grab only common channels and rename them
        datastruct = grab_specific_params(data, pnamelist, pstrat([],0));
        
    elseif strcmp(paramstokeep,'rename')
        % grab all channels but rename common ones
        nameconversions = pstrat([],1); % param names -> nicknames
        for c=1:length(pnamelist)
            parname = underscorify(pnamelist{c});

            % use any default nicknames that are available
            if isfield(nameconversions, parname) && ~isempty(nameconversions.(parname))
                parname = nameconversions.(parname);
            end

            datastruct.(parname) = data(:,c);
        end
    end
    
elseif isstruct(paramstokeep)
    % grab only wanted parameters and rename them
    datastruct = grab_specific_params(data, pnamelist, paramstokeep);
else
    error('PARAMSTOKEEP must be ''all'', ''common'', or a struct with flow cytometry parameter name conversions');
end

% process metadata
metadata = struct;

plate_id_idx = find(strcmp('PLATE_ID',{textHeader{:,1}}));
if ~isempty(plate_id_idx)
    metadata.plate_id = textHeader{plate_id_idx,2};
end

Date = textHeader{find(strcmp('$DATE',{textHeader{:,1}})),2};
BTim = textHeader{find(strcmp('$BTIM',{textHeader{:,1}})),2};
BTim_tmp = regexp(BTim, '^(\d{2}:\d{2}:\d{2})', 'tokens');
metadata.begin_time = datenum([Date, ' ', BTim_tmp{1}{1}]);


% well position
well_id_idx = find(strcmp('WELL_ID',{textHeader{:,1}}));
if ~isempty(well_id_idx)
    well_id = textHeader{well_id_idx,2};
    metadata.row = well_id(1)-'A'+1;
    metadata.col = str2num(well_id(2:end));
    metadata.well_id = well_id;
end

% helper functions
function datastruct = grab_specific_params(data, pnamelist, paramstokeep)
for par = fieldnames(paramstokeep)'
    par = par{1};
    k = find(strcmp(paramstokeep.(par),pnamelist));
    if ~isempty(k)
        datastruct.(par) = data(:,k);
    end
end