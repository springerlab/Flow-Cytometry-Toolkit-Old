%% jue's scratch work 
% 20120709
cd('C:\Users\jw125\Documents\research\springer\code\flow_cytometry_toolkit\script\')

%%
[a,b,c] = fcsread('../data/stratedigm/single_well_from_plate.fcs');

%% lsrii
[a,b,c] = fcsread('../data/lsrii/b043 day 0/Specimen_001_F4_F04.fcs');
%%
save('LSRII_header','textHeader')
%%
[data metadata] = fcsparse('data/stratedigm/Sample 001_Tube 16_001.fcs',pstrat({'mch','yfp'}))
%%
[data metadata] = fcsparse('data/stratedigm/single_well_from_plate.fcs')
%%
[data param textHeader] = fcsread('../data/stratedigm/single_tube.fcs');

