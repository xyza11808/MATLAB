
 DataRaw = SavedCaTrials.f_raw;
 CurrentData = squeeze(DataRaw(1,1,:));
 figure;plot(CurrentData,'b.')
 pgmodel = fitrgp((1:280)',squeeze(DataRaw(1,1,:)),'Basis','linear','FitMethod','exact','PredictMethod','exact');
 NewY = resubPredict(pgmodel);
 hold on
 plot(NewY,'r')
 
 %%
 % estimate noise level
SmoothData = smooth(CurrentData,5,'sgolay',3);
CResidues = CurrentData - SmoothData;
VarianceValue = std(CResidues);
pgmodelNew = fitrgp((1:280)',squeeze(DataRaw(1,1,:)),'Basis','linear','FitMethod','exact','PredictMethod','exact',...
     'Sigma',VarianceValue);
NewYNew = resubPredict(pgmodelNew);
plot(NewYNew,'k')
  
  %%