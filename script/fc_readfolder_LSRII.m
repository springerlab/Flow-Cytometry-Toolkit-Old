function [all_data, Plates_info, para_name] = fc_readfolder_LSRII(folder_name, channel)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
%     The function will read raw FCS3.0 data from a folder, and split data
%     according to plate name. In addition, time of acquisition will be
%     recorded. This function specifically deals with experiment with multiple plates
% 
% Input: 
%     folder address
% Output: 
%     Plates_data: event data for each plate, 
%     Plates_info: Plate name, time of acquisition
%     para_name: parameter names
% 
% Created by 
%     Bo Hua @03292012
%     
% Modification History:
%     Bo Hua @04012012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% sample:
% [Plates_data, Plates_info, para_name] = folder_read('../data/');

% test input
% folder_name = '../data/';

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
Plates_name = {sorted_folder_list(:).name};

Plate_i = 0;

for sub_folder_name = {sorted_folder_list(:).name}
    fprintf('Reading: %s...\t', sub_folder_name{1})
    Plate_i = Plate_i + 1;
    file_name_list = dir(strcat(folder_name,'/',sub_folder_name{1}));

    Plate_data = cell(8,12);
    Plate_time = cell(8,12);
    
    for file_name = {file_name_list(:).name}
%         regexp(file_name{1}, '.fcs$')
        if isempty(regexp(file_name{1}, '.fcs$'))
            continue
        end
%         file_name
        file_address = [folder_name,'/', sub_folder_name{1}, '/', file_name{1}];
        [data,paramVals,textHeader] = fcsread(file_address);

        % read parameter name
        if isempty(para_name)
            para_name = {paramVals.Name};
        end
        
        % well position
        well_id = textHeader{find(strcmp('TUBE NAME',{textHeader{:,1}})),2};
        row = well_id(1)-'A'+1;
        col = str2num(well_id(2:end));
        
        % 
        time_tmp = datenum([textHeader{find(strcmp('$DATE',{textHeader{:,1}})),2}, ' ', textHeader{find(strcmp('$BTIM',{textHeader{:,1}})),2}]);
        Plate_time{row, col} = time_tmp;
        
        %
        data_tmp = [];
        for field_name = fieldnames(channel)'
            data_tmp.(field_name{1}) = data(:,channel.(field_name{1}));
        end
        
        %
        Plate_data{row, col} = data_tmp;
    end

    all_plates_data{Plate_i} = Plate_data;
    all_plates_time{Plate_i} = Plate_time;
    disp('done')
end

all_data.data = all_plates_data;
all_data.time = all_plates_time;

Plates_info.name = Plates_name;

toc