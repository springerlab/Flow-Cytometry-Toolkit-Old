%@ fcsparse test
LSR_file = '../data/LSRII/b043 day 0/Specimen_001_A1_A01.fcs';
Strate_file = '../data/stratedigm/Sample 001_Tube 16_001.fcs';
Strate_plate_file = '../data/stratedigm/sample_plate/plate1/Sample 001_Tube 01_002.fcs';

%% single test
% tube
[datastruct, metadata]= fcsparse(Strate_file)
% plate
[datastruct, metadata]= fcsparse(LSR_file)
[datastruct, metadata]= fcsparse(Strate_plate_file)