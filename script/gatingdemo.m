%% Flow Cytometry Toolkit Demo
% This file shows how to use the functions in the Flow Cytometry Toolkit.
%
% Created 20120703 JW
% Updated 2012/7/13 JW

%% Load and prepare the data
% This section shows how to use the FCSPARSE and FC_FOLDERREAD functions to
% load data for analysis
data = fcsparse('data/stratedigm/Sample 001_Tube 16_001.fcs','common')

%% GATING
% This section shows how to filter flow cytometry data by defining gates in
% 2 dimensions. It uses functions UIGETGATE and APPLYGATE.

% Thin the data for display
thindata = fc_thin(data,50000)

%% Define first gate
figure
subplot(1,2,1)

% Prompt user to draw a gate on a scatterplot of FSC versus SSC
gate1 = uigetgate(thindata,{'fsc','ssc'});
xlabel('FSC')
ylabel('SSC')

%% UIGETGATE returns a struct
gate1

%% The returned gate object can be applied on the unthinned data
newdata = applygate(data, gate1)

%% Define another gate, this time on mCherry versus BFP
subplot(1,2,2)

% Use log-log axes
gate2 = uigetgate(fc_thin(newdata,100000),{'mch','bfp'},'log');   
xlabel('log10(mCherry)')
ylabel('log10(BFP)')

%% Filtered data
newdata = applygate(newdata, gate2)