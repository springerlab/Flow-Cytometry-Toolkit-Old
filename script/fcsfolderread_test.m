% [all_data, expr_meta] = fcsfolderread('../data/stratedigm/sample_plate');
% [all_data, expr_meta] = fcsfolderread('../data/LSRII/b043 day 0');
% [all_data, expr_meta] = fcsfolderread('../data_b050');

[all_data, expr_meta] = fcsfolderread('../data_b050', pstrat({'yfp', 'cfp'}));