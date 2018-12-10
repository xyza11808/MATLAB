
NSessions = length(NormSessPathTask);
SessOctDiffmodeAll = zeros(NSessions,2); % first column is task diff, second is Pass diff
SessOctDiffMeanAll = zeros(NSessions,2); 
for cSess = 1 : NSessions
    cSessPath = fullfile(NormSessPathTask{cSess},'Tunning_fun_plot_New1s','NMTuned Meanfreq colormap plot','TaskPassBFDis.mat');
    SessROIIndexFile = fullfile(NormSessPathTask{cSess},'Tunning_fun_plot_New1s','SelectROIIndex.mat');
    cSessDataStrc = load(cSessPath);
    SessROIIndexData = load(SessROIIndexFile);
%     if isfield(SessROIIndexData,'UsedROIindex')
%         UsedROIinds = SessROIIndexData.UsedROIindex;
%     else
%         fprintf('Please check the Common ROI index before usage.\n');
%     end
    
    SessOctDiffmodeAll(cSess,1) = abs(mode(cSessDataStrc.TaskMaxOct) - cSessDataStrc.BehavBoundData);
    SessOctDiffmodeAll(cSess,2) = abs(mode(cSessDataStrc.PassMaxOct) - cSessDataStrc.BehavBoundData);
    
    SessOctDiffMeanAll(cSess,1) = mean(abs(cSessDataStrc.TaskMaxOct - cSessDataStrc.BehavBoundData));
    SessOctDiffMeanAll(cSess,2) = mean(abs(cSessDataStrc.PassMaxOct - cSessDataStrc.BehavBoundData));
    
end
