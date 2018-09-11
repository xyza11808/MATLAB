
UsedConcentration = 0.1; %mg/kg
MouseWeight = 24; %g
StoreConcen = 10; %mg/ml
FinalVolume = 0.2; %ml
PreparedVol = 0.8; %ml
%%
UsedDrugWeight = (PreparedVol/FinalVolume)*(MouseWeight/1000)*UsedConcentration; %mg
UsedStoreVolume = UsedDrugWeight/StoreConcen % ml
% UsedStoreVolume = UsedDrugWeight/StoreConcen; % ml
