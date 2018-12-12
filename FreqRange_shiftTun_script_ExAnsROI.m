cclr
[fn,fp,fi] = uigetfile('*.txt','Please select the compasison session path file');
if ~fi
    return;  
end 
fPath = fullfile(fp,fn);
%%
fid = fopen(fPath);
tline = fgetl(fid);
SessType = 0;
SessPathAll = {};
m = 1;
while ischar(tline)
    if ~isempty(strfind(tline,'######')) % new section flag
        SessType = SessType + 1;
        tline = fgetl(fid);
        continue;
    end
    if ~isempty(strfind(tline,'NO_Correction\mode_f_change'))
        SessPathAll{m,1} = tline;
        SessPathAll{m,2} = SessType;
        m = m + 1;
    end
    tline = fgetl(fid);
end
SessIndexAll = cell2mat(SessPathAll(:,2));
%% processing 8k-32k and 4k-16k sessions data
Sess8_32_Inds = SessIndexAll == 1;
Sess8_32PathAll = SessPathAll(Sess8_32_Inds,1);

Sess4_16_Part1_Inds = SessIndexAll == 2;
Sess4_16_Part1_PathAll = SessPathAll(Sess4_16_Part1_Inds,1);

if length(Sess4_16_Part1_PathAll) ~= length(Sess8_32PathAll)
    warning('The session path number is different, please check your input data.\n');
    return;
end
%
NumPaths = length(Sess4_16_Part1_PathAll);
SessOctDiffmodeAll = zeros(NumPaths,4);
SessOctDiffMeanAll = zeros(NumPaths,4);
n832ROIs = zeros(NumPaths,1);
for cPath = 1 : NumPaths
    c832Path = Sess8_32PathAll{cPath};
    c416Path = Sess4_16_Part1_PathAll{cPath};
    
    cSess832Path = fullfile(c832Path,'Tunning_fun_plot_New1s','NMTuned Meanfreq colormap plot','TaskPassBFDis.mat');
    cSess832TunData = load(cSess832Path);
    cSess416Path = fullfile(c416Path,'Tunning_fun_plot_New1s','NMTuned Meanfreq colormap plot','TaskPassBFDis.mat');
    cSess416TunData = load(cSess416Path);
    
    Sess832ROIIndexFile = fullfile(c832Path,'Tunning_fun_plot_New1s','SelectROIIndex.mat');
    Sess416ROIIndexFile = fullfile(c416Path,'Tunning_fun_plot_New1s','SelectROIIndex.mat');
    
    cSess832DataStrc = load(Sess832ROIIndexFile);
    cSess416DataStrc = load(Sess416ROIIndexFile);
    
    CommonROINum = min(numel(cSess832DataStrc.ROIIndex),numel(cSess416DataStrc.ROIIndex));
    CommonROIIndex = cSess832DataStrc.ROIIndex(1:CommonROINum) & cSess416DataStrc.ROIIndex(1:CommonROINum);
    n832ROIs(cPath) = numel(cSess832DataStrc.ROIIndex);
    % loading Ans response ROI inds
    cSess832SelectROIStrc = load(fullfile(c832Path,'SigSelectiveROIInds.mat'));
    LR_AnsROIIndex = [cSess832SelectROIStrc.LAnsMergedInds;cSess832SelectROIStrc.RAnsMergedInds];
    LR_AnsROIIndex(LR_AnsROIIndex > CommonROINum) = [];
    c832CommonROIIndex = CommonROIIndex;
    c832CommonROIIndex(LR_AnsROIIndex) = false;
    
    SessOctDiffmodeAll(cPath,1) = abs(mode(cSess832TunData.TaskMaxOct(c832CommonROIIndex)) - cSess832TunData.BehavBoundData);
    SessOctDiffmodeAll(cPath,2) = abs(mode(cSess832TunData.PassMaxOct(c832CommonROIIndex)) - cSess832TunData.BehavBoundData);
    SessOctDiffmodeAll(cPath,3) = abs(mode(cSess416TunData.TaskMaxOct(c832CommonROIIndex)) - cSess416TunData.BehavBoundData);
    SessOctDiffmodeAll(cPath,4) = abs(mode(cSess416TunData.PassMaxOct(c832CommonROIIndex)) - cSess416TunData.BehavBoundData);
    
     % loading Ans response ROI inds
    cSess416SelectROIStrc = load(fullfile(c416Path,'SigSelectiveROIInds.mat'));
    LR_AnsROIIndex = [cSess416SelectROIStrc.LAnsMergedInds;cSess416SelectROIStrc.RAnsMergedInds];
    LR_AnsROIIndex(LR_AnsROIIndex > CommonROINum) = [];
    c416CommonROIIndex = CommonROIIndex;
    c416CommonROIIndex(LR_AnsROIIndex) = false;
    
    SessOctDiffMeanAll(cPath,1) = mean(abs(cSess832TunData.TaskMaxOct(c416CommonROIIndex) - cSess832TunData.BehavBoundData));
    SessOctDiffMeanAll(cPath,2) = mean(abs(cSess832TunData.PassMaxOct(c416CommonROIIndex) - cSess832TunData.BehavBoundData));
    SessOctDiffMeanAll(cPath,3) = mean(abs(cSess416TunData.TaskMaxOct(c416CommonROIIndex) - cSess416TunData.BehavBoundData));
    SessOctDiffMeanAll(cPath,4) = mean(abs(cSess416TunData.PassMaxOct(c416CommonROIIndex) - cSess416TunData.BehavBoundData));
end

%% common population decoding

Sess8_32_Inds = SessIndexAll == 1;
Sess8_32PathAll = SessPathAll(Sess8_32_Inds,1);

Sess4_16_Part1_Inds = SessIndexAll == 2;
Sess4_16_Part1_PathAll = SessPathAll(Sess4_16_Part1_Inds,1);

if length(Sess4_16_Part1_PathAll) ~= length(Sess8_32PathAll)
    warning('The session path number is different, please check your input data.\n');
    return;
end

NumPaths = length(Sess4_16_Part1_PathAll);
for cPath = 10 : NumPaths
    c832Path = Sess8_32PathAll{cPath};
    c416Path = Sess4_16_Part1_PathAll{cPath};
    
    cSess832Path = fullfile(c832Path,'Tunning_fun_plot_New1s','NMTuned Meanfreq colormap plot','TaskPassBFDis.mat');
    cSess832TunData = load(cSess832Path);
    cSess416Path = fullfile(c416Path,'Tunning_fun_plot_New1s','NMTuned Meanfreq colormap plot','TaskPassBFDis.mat');
    cSess416TunData = load(cSess416Path);
    
    Sess832ROIIndexFile = fullfile(c832Path,'Tunning_fun_plot_New1s','SelectROIIndex.mat');
    Sess416ROIIndexFile = fullfile(c416Path,'Tunning_fun_plot_New1s','SelectROIIndex.mat');
    
    cSess832DataStrc = load(Sess832ROIIndexFile);
    cSess416DataStrc = load(Sess416ROIIndexFile);
    
    CommonROINum = min(numel(cSess832DataStrc.ROIIndex),numel(cSess416DataStrc.ROIIndex));
    CommonROIIndex = cSess832DataStrc.ROIIndex(1:CommonROINum) & cSess416DataStrc.ROIIndex(1:CommonROINum);
    
    cd(c832Path);
    UsedROIInds = false(numel(cSess832DataStrc.ROIIndex),1);
    UsedROIInds(1:CommonROINum) = CommonROIIndex;
    clearvars behavResults data_aligned frame_rate
    load('CSessionData.mat')
    Partitioned_neurometric_prediction;
%     multiCClass(data_aligned,behavResults,trial_outcome,start_frame,frame_rate,1,[],UsedROIInds);
    
    cd(c416Path);
    UsedROIInds = false(numel(cSess416DataStrc.ROIIndex),1);
    UsedROIInds(1:CommonROINum) = CommonROIIndex;
    clearvars behavResults data_aligned frame_rate
    load('CSessionData.mat')
    Partitioned_neurometric_prediction;
%     multiCClass(data_aligned,behavResults,trial_outcome,start_frame,frame_rate,1,[],UsedROIInds);
    
end

%  another section
Sess7_28_Inds = SessIndexAll == 4;
Sess7_28PathAll = SessPathAll(Sess7_28_Inds,1);

Sess4_16_Part2_Inds = SessIndexAll == 3;
Sess4_16_Part2_PathAll = SessPathAll(Sess4_16_Part2_Inds,1);

if length(Sess4_16_Part2_PathAll) ~= length(Sess7_28PathAll)
    warning('The session path number is different, please check your input data.\n');
    return;
end

NumPaths = length(Sess4_16_Part2_PathAll);
SessOctDiffmodeAll_2 = zeros(NumPaths,4);
SessOctDiffMeanAll_2 = zeros(NumPaths,4);
for cPath = 1 : NumPaths
    c728Path = Sess7_28PathAll{cPath};
    c416Path = Sess4_16_Part2_PathAll{cPath};
    
    cSess728Path = fullfile(c728Path,'Tunning_fun_plot_New1s','NMTuned Meanfreq colormap plot','TaskPassBFDis.mat');
    cSess728TunData = load(cSess728Path);
    cSess416Path = fullfile(c416Path,'Tunning_fun_plot_New1s','NMTuned Meanfreq colormap plot','TaskPassBFDis.mat');
    cSess416TunData = load(cSess416Path);
    
    Sess728ROIIndexFile = fullfile(c728Path,'Tunning_fun_plot_New1s','SelectROIIndex.mat');
    Sess416ROIIndexFile = fullfile(c416Path,'Tunning_fun_plot_New1s','SelectROIIndex.mat');
    
    cSess728DataStrc = load(Sess728ROIIndexFile);
    cSess416DataStrc = load(Sess416ROIIndexFile);
    
    CommonROINum = min(numel(cSess728DataStrc.ROIIndex),numel(cSess416DataStrc.ROIIndex));
    CommonROIIndex = cSess728DataStrc.ROIIndex(1:CommonROINum) & cSess416DataStrc.ROIIndex(1:CommonROINum);
    
    cd(c728Path);
    UsedROIInds = false(numel(cSess728DataStrc.ROIIndex),1);
    UsedROIInds(1:CommonROINum) = CommonROIIndex;
    clearvars behavResults data_aligned frame_rate
    load('CSessionData.mat')
    Partitioned_neurometric_prediction;
%     multiCClass(data_aligned,behavResults,trial_outcome,start_frame,frame_rate,1,[],UsedROIInds);
    
    cd(c416Path);
    UsedROIInds = false(numel(cSess416DataStrc.ROIIndex),1);
    UsedROIInds(1:CommonROINum) = CommonROIIndex;
    clearvars behavResults data_aligned frame_rate
    load('CSessionData.mat')
    Partitioned_neurometric_prediction;
%     multiCClass(data_aligned,behavResults,trial_outcome,start_frame,frame_rate,1,[],UsedROIInds);
end

%%  4k-16k and 7k-28k sessions data
Sess7_28_Inds = SessIndexAll == 4;
Sess7_28PathAll = SessPathAll(Sess7_28_Inds,1);

Sess4_16_Part2_Inds = SessIndexAll == 3;
Sess4_16_Part2_PathAll = SessPathAll(Sess4_16_Part2_Inds,1);

if length(Sess4_16_Part2_PathAll) ~= length(Sess7_28PathAll)
    warning('The session path number is different, please check your input data.\n');
    return;
end

NumPaths = length(Sess4_16_Part2_PathAll);
SessOctDiffmodeAll_2 = zeros(NumPaths,4);
SessOctDiffMeanAll_2 = zeros(NumPaths,4);
for cPath = 1 : NumPaths
    c728Path = Sess7_28PathAll{cPath};
    c416Path = Sess4_16_Part2_PathAll{cPath};
    
    cSess728Path = fullfile(c728Path,'Tunning_fun_plot_New1s','NMTuned Meanfreq colormap plot','TaskPassBFDis.mat');
    cSess728TunData = load(cSess728Path);
    cSess416Path = fullfile(c416Path,'Tunning_fun_plot_New1s','NMTuned Meanfreq colormap plot','TaskPassBFDis.mat');
    cSess416TunData = load(cSess416Path);
    
    Sess728ROIIndexFile = fullfile(c728Path,'Tunning_fun_plot_New1s','SelectROIIndex.mat');
    Sess416ROIIndexFile = fullfile(c416Path,'Tunning_fun_plot_New1s','SelectROIIndex.mat');
    
    cSess728DataStrc = load(Sess728ROIIndexFile);
    cSess416DataStrc = load(Sess416ROIIndexFile);
    
    CommonROINum = min(numel(cSess728DataStrc.ROIIndex),numel(cSess416DataStrc.ROIIndex));
    CommonROIIndex = cSess728DataStrc.ROIIndex(1:CommonROINum) & cSess416DataStrc.ROIIndex(1:CommonROINum);
     
     
    % loading Ans response ROI inds
    cSess728SelectROIStrc = load(fullfile(c728Path,'SigSelectiveROIInds.mat'));
    LR_AnsROIIndex = [cSess728SelectROIStrc.LAnsMergedInds;cSess728SelectROIStrc.RAnsMergedInds];
    LR_AnsROIIndex(LR_AnsROIIndex > CommonROINum) = [];
    c728CommonROIIndex = CommonROIIndex;
    c728CommonROIIndex(LR_AnsROIIndex) = false;
    
    SessOctDiffmodeAll_2(cPath,1) = abs(mode(cSess728TunData.TaskMaxOct(c728CommonROIIndex)) - cSess728TunData.BehavBoundData);
    SessOctDiffmodeAll_2(cPath,2) = abs(mode(cSess728TunData.PassMaxOct(c728CommonROIIndex)) - cSess728TunData.BehavBoundData);
    SessOctDiffmodeAll_2(cPath,3) = abs(mode(cSess416TunData.TaskMaxOct(c728CommonROIIndex)) - cSess416TunData.BehavBoundData);
    SessOctDiffmodeAll_2(cPath,4) = abs(mode(cSess416TunData.PassMaxOct(c728CommonROIIndex)) - cSess416TunData.BehavBoundData);
    
    % loading Ans response ROI inds
    cSess416SelectROIStrc = load(fullfile(c416Path,'SigSelectiveROIInds.mat'));
    LR_AnsROIIndex = [cSess416SelectROIStrc.LAnsMergedInds;cSess416SelectROIStrc.RAnsMergedInds];
    LR_AnsROIIndex(LR_AnsROIIndex > CommonROINum) = []; 
    c416CommonROIIndex = CommonROIIndex;
    c416CommonROIIndex(LR_AnsROIIndex) = false;
    
    SessOctDiffMeanAll_2(cPath,1) = mean(abs(cSess728TunData.TaskMaxOct(c416CommonROIIndex) - cSess728TunData.BehavBoundData));
    SessOctDiffMeanAll_2(cPath,2) = mean(abs(cSess728TunData.PassMaxOct(c416CommonROIIndex) - cSess728TunData.BehavBoundData));
    SessOctDiffMeanAll_2(cPath,3) = mean(abs(cSess416TunData.TaskMaxOct(c416CommonROIIndex) - cSess416TunData.BehavBoundData));
    SessOctDiffMeanAll_2(cPath,4) = mean(abs(cSess416TunData.PassMaxOct(c416CommonROIIndex) - cSess416TunData.BehavBoundData));
end

%%
nSessNum = size(SessPathAll,1);
SessBehavData = cell(nSessNum,1);
SessBehavSum = cell(nSessNum,3);
for cSess = 1 : nSessNum
    SessBehavPath = fullfile(SessPathAll{cSess,1},'RandP_data_plots','boundary_result.mat');
    SessBehavStrc = load(SessBehavPath);
    SessBehavData{cSess} = SessBehavStrc.boundary_result;
    
    cSessStim = SessBehavStrc.boundary_result.StimType(:);
    cSessStimOcts = log2(cSessStim/min(cSessStim)) - 1;
    cSessBehavCorr = SessBehavStrc.boundary_result.StimCorr(:);
    RProbReverseInds = cSessStimOcts < 0;
    cSessBehavRprob = cSessBehavCorr;
    cSessBehavRprob(RProbReverseInds) = 1 - cSessBehavRprob(RProbReverseInds);
    
    CommonOctRange = log2(cSessStim/4000);
    SessBehavSum{cSess,1} = CommonOctRange;
    SessBehavSum{cSess,2} = cSessStimOcts;
    SessBehavSum{cSess,3} = cSessBehavRprob;    
end

%% plots the 832k and 4k-16k sessions
Sess832kInds = SessIndexAll == 1;
Sess832kStimOctsAll = cell2mat(SessBehavSum(Sess832kInds,1));
Sess832kStimRProb = cell2mat(SessBehavSum(Sess832kInds,3));
Sess832kStimTypes = unique(Sess832kStimOctsAll);
Sess832kAvgRprob = zeros(length(Sess832kStimTypes),3);
for cStimType = 1 : length(Sess832kStimTypes)
    cTypeInds = Sess832kStimOctsAll == Sess832kStimTypes(cStimType);
    cTypeProb = Sess832kStimRProb(cTypeInds);
    Sess832kAvgRprob(cStimType,:) = [mean(cTypeProb),std(cTypeProb),numel(cTypeProb)];
end
Sess832kfits = FitPsycheCurveWH_nx(Sess832kStimOctsAll, Sess832kStimRProb);

Sess416kInds = SessIndexAll == 2;
Sess416kStimOctsAll = cell2mat(SessBehavSum(Sess416kInds,1));
Sess416kStimRProb = cell2mat(SessBehavSum(Sess416kInds,3));
Sess416kStimTypes = unique(Sess416kStimOctsAll);
Sess416kAvgRProb = zeros(length(Sess416kStimTypes),3);
for cStimT = 1 : length(Sess416kStimTypes)
    cStimTInds = Sess416kStimOctsAll == Sess416kStimTypes(cStimT);
    cTypeProb = Sess416kStimRProb(cStimTInds);
    Sess416kAvgRProb(cStimT,:) = [mean(cTypeProb),std(cTypeProb),numel(cTypeProb)];
end
Sess416kfits = FitPsycheCurveWH_nx(Sess416kStimOctsAll, Sess416kStimRProb);
%%
hf = figure('position',[100,100,450 340]);
hold on
hl1 = plot(Sess832kfits.curve(:,1),Sess832kfits.curve(:,2),'linewidth',2,'Color',[0.9 0.2 0.2]);
ho = errorbar(Sess832kStimTypes,Sess832kAvgRprob(:,1),Sess832kAvgRprob(:,2)./sqrt(Sess832kAvgRprob(:,3)),'o',...
    'Color',[0.9 0.2 0.2],'linewidth',1.8);
line(Sess832kfits.ffit.u*[1 1],[0 1],'linewidth',1.8,'Color',[0.9 0.2 0.2],'linestyle','--');
hl2 = plot(Sess416kfits.curve(:,1),Sess416kfits.curve(:,2),'linewidth',2,'Color',[0.2 0.2 0.9]);
ho2 = errorbar(Sess416kStimTypes,Sess416kAvgRProb(:,1),Sess416kAvgRProb(:,2)./sqrt(Sess416kAvgRProb(:,3)),'o',...
    'Color',[0.2 0.2 0.9],'linewidth',1.8);
line(Sess416kfits.ffit.u*[1 1],[0 1],'linewidth',1.8,'Color',[0.2 0.2 0.9],'linestyle','--');
xlimRange = [min([Sess832kStimTypes;Sess416kStimTypes]),max([Sess832kStimTypes;Sess416kStimTypes])];
UsedxTick = xlimRange(1):xlimRange(2);
UsedTickLabels = 4*2.^(UsedxTick); % kHz
set(gca,'xlim',xlimRange+[-0.1 0.1],'xtick',UsedxTick,'xticklabel',UsedTickLabels,'ylim',[-0.1 1.1],'ytick',[0 0.5 1]);
xlabel('Freq. (kHz)');
ylabel('Right Prob.');
title('8-32kHz and 4-16kHz compare');
set(gca,'FontSize',12);
legend([hl1,hl2],{'8-32 kHz','4-16kHz'},'Box','off','Location','Northwest','FontSize',8);

saveas(hfNew,'8-32k and 4-16k freq psychometric curve plot');
saveas(hfNew,'8-32k and 4-16k freq psychometric curve plot','pdf');
saveas(hfNew,'8-32k and 4-16k freq psychometric curve plot','png');
%%
Sess728kInds = SessIndexAll == 4;
Sess728kStimOctsAll = cell2mat(SessBehavSum(Sess728kInds,1));
Sess728kStimRProb = cell2mat(SessBehavSum(Sess728kInds,3));
Sess728kStimTypes = unique(Sess728kStimOctsAll);
Sess728kAvgRprob = zeros(length(Sess728kStimTypes),3);
for cStimType = 1 : length(Sess728kStimTypes)
    cTypeInds = Sess728kStimOctsAll == Sess728kStimTypes(cStimType);
    cTypeProb = Sess728kStimRProb(cTypeInds);
    Sess728kAvgRprob(cStimType,:) = [mean(cTypeProb),std(cTypeProb),numel(cTypeProb)];
end
Sess728kfits = FitPsycheCurveWH_nx(Sess728kStimOctsAll, Sess728kStimRProb);

Sess416kInds = SessIndexAll == 3;
Sess416kStimOctsAll = cell2mat(SessBehavSum(Sess416kInds,1));
Sess416kStimRProb = cell2mat(SessBehavSum(Sess416kInds,3));
Sess416kStimTypes = unique(Sess416kStimOctsAll);
Sess416kAvgRProb = zeros(length(Sess416kStimTypes),3);
for cStimT = 1 : length(Sess416kStimTypes)
    cStimTInds = Sess416kStimOctsAll == Sess416kStimTypes(cStimT);
    cTypeProb = Sess416kStimRProb(cStimTInds);
    Sess416kAvgRProb(cStimT,:) = [mean(cTypeProb),std(cTypeProb),numel(cTypeProb)];
end
Sess416kfits = FitPsycheCurveWH_nx(Sess416kStimOctsAll, Sess416kStimRProb);
%%
hfNew = figure('position',[100,100,450 340]);
hold on
hll1 = plot(Sess728kfits.curve(:,1),Sess728kfits.curve(:,2),'linewidth',2,'Color',[0.9 0.2 0.2]);
ho = errorbar(Sess728kStimTypes,Sess728kAvgRprob(:,1),Sess728kAvgRprob(:,2)./sqrt(Sess728kAvgRprob(:,3)),'o',...
    'Color','m','linewidth',1.8);
line(Sess728kfits.ffit.u*[1 1],[0 1],'linewidth',1.8,'Color','m','linestyle','--');
hll2 = plot(Sess416kfits.curve(:,1),Sess416kfits.curve(:,2),'linewidth',2,'Color',[0.2 0.2 0.9]);
ho2 = errorbar(Sess416kStimTypes,Sess416kAvgRProb(:,1),Sess416kAvgRProb(:,2)./sqrt(Sess416kAvgRProb(:,3)),'o',...
    'Color',[0.2 0.2 0.9],'linewidth',1.8);
line(Sess416kfits.ffit.u*[1 1],[0 1],'linewidth',1.8,'Color',[0.2 0.2 0.9],'linestyle','--');
xlimRange = [min([Sess728kStimTypes;Sess416kStimTypes]),max([Sess728kStimTypes;Sess416kStimTypes])];
UsedxTick = 0:3;
UsedTickLabels = 4*2.^(UsedxTick); % kHz
set(gca,'xlim',[-0.1 3.1],'xtick',UsedxTick,'xticklabel',UsedTickLabels,'ylim',[-0.1 1.1],'ytick',[0 0.5 1]);
xlabel('Freq. (kHz)');
ylabel('Right Prob.');
title('7-28kHz and 4-16kHz compare');
set(gca,'FontSize',12);
legend([hll1,hll2],{'7-28 kHz','4-16kHz'},'Box','off','Location','Northwest','FontSize',8);
saveas(hfNew,'7-28k and 4-16k freq psychometric curve plot');
saveas(hfNew,'7-28k and 4-16k freq psychometric curve plot','pdf');
saveas(hfNew,'7-28k and 4-16k freq psychometric curve plot','png');

%%
hf = FourColDataPlots(SessOctDiffMeanAll,{'8-32T','8-32P','4-16T','4-16P'},{'r','k','m','k'});
ylabel('Distance (Oct.)')
[~,p_12] = ttest(SessOctDiffMeanAll(:,1),SessOctDiffMeanAll(:,2));
GroupSigIndication([1,2],max(SessOctDiffMeanAll(:,1:2)),p_12,hf);
[~,p_34] = ttest(SessOctDiffMeanAll(:,3),SessOctDiffMeanAll(:,4));
GroupSigIndication([3,4],max(SessOctDiffMeanAll(:,3:4)),p_34,hf);
saveas(hf,'Plots save ExAns for 8-32k and 4-16k');
saveas(hf,'Plots save ExAns for 8-32k and 4-16k','png');

%% another session
hNewf = FourColDataPlots(SessOctDiffMeanAll_2,{'7-28T','7-28P','4-16T','4-16P'},{'r','k','m','k'});
ylabel('Distance (Oct.)')
[~,p_12] = ttest(SessOctDiffMeanAll_2(:,1),SessOctDiffMeanAll_2(:,2));
GroupSigIndication([1,2],max(SessOctDiffMeanAll_2(:,1:2)),p_12,hNewf);
[~,p_34] = ttest(SessOctDiffMeanAll_2(:,3),SessOctDiffMeanAll_2(:,4));
GroupSigIndication([3,4],max(SessOctDiffMeanAll_2(:,3:4)),p_34,hNewf);
saveas(hNewf,'Plots save ExAns for 7-28k and 4-16k');
saveas(hNewf,'Plots save ExAns for 7-28k and 4-16k','png');
