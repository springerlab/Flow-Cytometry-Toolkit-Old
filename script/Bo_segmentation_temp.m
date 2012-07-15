% segmentation

close all

% specify all the parameters here
plate = 4;
row = 6;
col = 10;
cha1 = 'cfp';
cha2 = 'mch';

% data extraction
data_well = all_data.data{plate}{row, col};
data_well_thin = fc_thin(data_well,1000);

fcsplot(data_well, {cha1, cha2, 'ssc'}, 'log10')


%%
fcsplot(all_data.data{4}{6,8})

%%
[ data_append ] = fcsappend( all_data.data{4}{6,7}, all_data.data{4}{6,8})

%%