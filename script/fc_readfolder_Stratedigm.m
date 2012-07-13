function [all_data, Plates_info, para_name] = fc_readfolder_Stratedigm(folder_name, channel)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic

fprintf('loading data from:\n%s\n\n', folder_name)

folder_list = dir(folder_name);
index = find(strcmp('..', {folder_list(:).name})|strcmp('.', {folder_list(:).name}));
folder_list(index) = [];
[ ~, order_tmp ] = sort( [ folder_list(:).datenum ] );
sorted_folder_list = folder_list( order_tmp ); % the files sorted by date

% clear data
all_plates_data = {};
all_plates_time = {};

para_name = {};
% Plates_name = {sorted_folder_list(:).name};  % for stratedigm single
% folder might contain multiple plates

all_plates_data = {};
all_plates_time = {};

Plates_name = {};   % record plate names

Plate_n = 0;    % record the amount of plates

fieldheader = fieldnames(channel)';
fieldindex = [];
for field_name = fieldnames(channel)'
    fieldindex(end+1) = channel.(field_name{1});
end

for sub_folder_name = {sorted_folder_list(:).name}
    
    % check fcs files in each subfolders
    fprintf('Reading: %s...\t', sub_folder_name{1})
    %     Plate_i = Plate_i + 1;
    file_name_list = dir(strcat(folder_name,'/',sub_folder_name{1}));
    
    %     Plate_data = cell(8,12);
    %     Plate_time = cell(8,12);
    
    for file_name = {file_name_list(:).name}
        
        if isempty(regexp(file_name{1}, '.fcs$'))
            continue
        end
        
        file_address = [folder_name,'/', sub_folder_name{1}, '/', file_name{1}];
        [data,paramVals,textHeader] = fcsread(file_address);
        
        % read parameter name
        if isempty(para_name)
            para_name = {paramVals.Name};
        end
        
        % well position
        well_id = textHeader{find(strcmp('WELL_ID',{textHeader{:,1}})),2};
        row = well_id(1)-'A'+1;
        col = str2num(well_id(2:end));
        
        Plate_name = [sub_folder_name{1}, '_', textHeader{find(strcmp('PLATE_ID',{textHeader{:,1}})),2}];
        Date = textHeader{find(strcmp('$DATE',{textHeader{:,1}})),2};
        BTim = textHeader{find(strcmp('$BTIM',{textHeader{:,1}})),2};
        
        BTim_tmp = regexp(BTim, '^(\d{2}:\d{2}:\d{2})', 'tokens');
        well_time = datenum([Date, ' ', BTim_tmp{1}{1}]);
        
        % search plate in
        Plate_index = find(strcmp(Plate_name, Plates_name));
        
        % extract data
        data_tmp = [];
        
        % another formating method
        % data_tmp = cell2struct(num2cell(data(:,fieldindex)), fieldheader, 2);
        
        for field_name = fieldnames(channel)'
            data_tmp.(field_name{1}) = data(:,channel.(field_name{1}));
        end
        
        if isempty(Plate_index)
            
            Plate_n = Plate_n+1;
            % create new plate
            all_plates_data{end+1} = cell(8, 12);
            all_plates_time{end+1} = cell(8, 12);
            
            % add to plate name list
            Plates_name{end+1} = Plate_name;
            
            % update index
            Plate_index = Plate_n;
        end
        
        all_plates_data{Plate_index}{row, col} = data_tmp;
        all_plates_time{Plate_index}{row, col} = well_time;
        
    end
    disp('done')
end

all_data.data = all_plates_data;
all_data.time = all_plates_time;

Plates_info.name = Plates_name;

toc