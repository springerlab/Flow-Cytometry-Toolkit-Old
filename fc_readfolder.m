function [all_data, Plates_info, para_name] = fc_readfolder(folder_name, channel, machineType, acquisitionMode)

if strcmpi(acquisitionMode, 'plate')
    if strcmpi(machineType, 'LSRII')
        [all_data, Plates_info, para_name] = fc_readfolder_LSRII(folder_name, channel);
    elseif strcmpi(machineType, 'stratedigm')
        % to be finished
        [all_data, Plates_info, para_name] = fc_readfolder_Stratedigm(folder_name, channel);
    end
elseif strcmpi(acquisitionMode, 'tube')
    % to be finished
end

all_data = all_data;
Plates_info = Plates_info;
para_name = para_name;