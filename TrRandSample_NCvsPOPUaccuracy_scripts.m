nTrs = size(data_aligned,1);
SampleFrac = 0.7;
TrFreqs = double(behavResults.Stim_toneFreq);
nIters = 1000;
IterNC = zeros(nIters,1);
for nt = 1 : nIters
    SampleIndex = CusRandSample(TrFreqs,0.8);

    DataAnaObj = DataAnalysisSum(data_aligned(SampleIndex,:,:),TrFreqs(SampleIndex),start_frame,frame_rate,1);  % smooth_data
    ROIcorrlation = DataAnaObj.popuZscoredCorr(1.5,'Mean',[],[],0);
    % DataAnaObj.popuSignalCorr(1,'Mean',1);  % boot-strap signal correlation
    % DataAnaObj.popuSignalCorr(1,'Mean');  % normal methods
    MatrixmaskRaw = ones(size(ROIcorrlation));
    Matrixmask = logical(tril(MatrixmaskRaw,-1));
    PairedROIcorr = ROIcorrlation(Matrixmask);
    IterNC(nt) = mean(PairedROIcorr);
end
figure;hist(IterNC,20)

%%
nTrs = size(data_aligned,1);
[~,bootsam] = bootstrp(1000,@mean,1:nTrs);
% SampleFrac = 0.7;
TrFreqs = double(behavResults.Stim_toneFreq);
nIters = 1000;
IterNC = zeros(nIters,1);
IterTestLoss = zeros(nIters,1);
for nt = 1 : nIters
%     SampleIndex = CusRandSample(TrFreqs,0.8);

    DataAnaObj = DataAnalysisSum(data_aligned(bootsam(:,nt),:,:),TrFreqs(bootsam(:,nt)),start_frame,frame_rate,1);  % smooth_data
    ROIcorrlation = DataAnaObj.popuZscoredCorr(1.5,'Mean',[],[],0);
    % DataAnaObj.popuSignalCorr(1,'Mean',1);  % boot-strap signal correlation
    % DataAnaObj.popuSignalCorr(1,'Mean');  % normal methods
    MatrixmaskRaw = ones(size(ROIcorrlation));
    Matrixmask = logical(tril(MatrixmaskRaw,-1));
    PairedROIcorr = ROIcorrlation(Matrixmask);
    IterNC(nt) = mean(PairedROIcorr);
    
    TestLoss = TbyTAllROIclassInputParse(data_aligned(bootsam(:,nt),:,:),TrFreqs(bootsam(:,nt)),trial_outcome(bootsam(:,nt)),...
        start_frame,frame_rate,'TimeLen',1,'TrOutcomeOp',0);
    IterTestLoss(nt) = mean(TestLoss);
end
figure;hist(IterNC,20)

%% performing population decoding according to ROI coef pvalue
clear
clc
[fn,fp,fi] = uigetfile('ROIselectiveTypeSave.mat','Please select the ROI selective type data');
ROIselectiveType = load(fullfile(fp,fn));
%
cd(fp);
ROIselective2 = sum(ROIselectiveType.ROISelectTypeIndex(:,1:2),2);
FreqROIs = (ROIselectiveType.ROISelectTypeIndex(:,1) == 1 & ROIselective2 == 1);
ChoiceROIs = (ROIselectiveType.ROISelectTypeIndex(:,2) == 1 & ROIselective2 == 1);
MixROIs = (ROIselective2 == 2);
%
ROIROCpath = strrep(fp,'ROIcoef_plot_anova','Stim_time_Align\ROC_Left2Right_result');
ROIROCdata = load(fullfile(ROIROCpath,'ROC_score.mat'));
ROIROCabs = ROIROCdata.ROCarea;
ROIROCabs(ROIROCdata.ROCRevert == 1) = 1 - ROIROCabs(ROIROCdata.ROCRevert == 1);
[ROCsort,ROCInds] = sort(ROIROCabs);
SortxIndex = 1 : length(ROCInds);
hff = figure;
hold on
plot(SortxIndex,ROCsort,'o','Color',[.7 .7 .7],'linewidth',1.4);
hl1 = plot(SortxIndex(FreqROIs(ROCInds)),ROCsort(FreqROIs(ROCInds)),'ro','linewidth',1.5);
hl2 = plot(SortxIndex(ChoiceROIs(ROCInds)),ROCsort(ChoiceROIs(ROCInds)),'bo','linewidth',1.5);
hl3 = plot(SortxIndex(MixROIs(ROCInds)),ROCsort(MixROIs(ROCInds)),'ko','linewidth',1.5);
legend([hl1,hl2,hl3],{'FreqSelect','ChoiceSelect','MixSelect'},'FontSize',14,'Location','northwest');
legend('boxoff');

%% performing population decoding of choice using fraction of ROIs
[fn,fp,fi] = uigetfile('CSessionData.mat','Please select the session data file');
if ~fi
    return;
end
SessData = load(fullfile(fp,fn));
data_aligned = SessData.data_aligned;
trial_outcome = SessData.trial_outcome;

%%
TrFreqs = double(SessData.behavResults.Stim_toneFreq);
TotalSelectROIs = logical(FreqROIs+ChoiceROIs+MixROIs);
NonSelectROINum = sum(~TotalSelectROIs);
SelectROInum = sum(TotalSelectROIs);
ROIbaseIndex = false(size(TotalSelectROIs));
nIters = 200;
if SelectROInum < NonSelectROINum
    SelectTestLoss = TbyTAllROIclassInputParse(data_aligned,TrFreqs,trial_outcome,...
        SessData.start_frame,SessData.frame_rate,'TimeLen',1,'TrOutcomeOp',0,'PartialROIInds',TotalSelectROIs);
    NonSelectIndex = find(~TotalSelectROIs);
    NonSelectLoss = zeros(nIters,1);
    for nIt = 1 : nIters
        cNonSelectIndex = randsample(NonSelectROINum,SelectROInum);
        cNonSelectROIs = ROIbaseIndex;
        cNonSelectROIs(NonSelectIndex(cNonSelectIndex)) = true;
        NonSeTestLoss = TbyTAllROIclassInputParse(data_aligned,TrFreqs,trial_outcome,...
             SessData.start_frame,SessData.frame_rate,'TimeLen',1,'TrOutcomeOp',0,'PartialROIInds',cNonSelectROIs);
        NonSelectLoss(nIt) = mean(NonSeTestLoss);
    end
elseif SelectROInum > NonSelectROINum
    NonSelectLoss = TbyTAllROIclassInputParse(data_aligned,TrFreqs,trial_outcome,...
        SessData.start_frame,SessData.frame_rate,'TimeLen',1,'TrOutcomeOp',0,'PartialROIInds',~TotalSelectROIs);
    SelectIndex =  find(TotalSelectROIs);
    SelectTestLoss = zeros(nIters,1);
    for nIt = 1 : nIters
        cSelectIndex = randsample(SelectROInum,NonSelectROINum);
        cSelectROIs = ROIbaseIndex;
        cSelectROIs(SelectIndex(cSelectIndex)) = true;
        cSelectLoss = TbyTAllROIclassInputParse(data_aligned,TrFreqs,trial_outcome,...
             SessData.start_frame,SessData.frame_rate,'TimeLen',1,'TrOutcomeOp',0,'PartialROIInds',cSelectROIs);
        SelectTestLoss(nIt) = mean(cSelectLoss);
    end
else
    NonSelectLoss = TbyTAllROIclassInputParse(data_aligned,TrFreqs,trial_outcome,...
        SessData.start_frame,SessData.frame_rate,'TimeLen',1,'TrOutcomeOp',0,'PartialROIInds',~TotalSelectROIs);
    SelectTestLoss = TbyTAllROIclassInputParse(data_aligned,TrFreqs,trial_outcome,...
        SessData.start_frame,SessData.frame_rate,'TimeLen',1,'TrOutcomeOp',0,'PartialROIInds',TotalSelectROIs);
end
save SelectNonSePupoDecodSave.mat NonSelectLoss SelectTestLoss FreqROIs ChoiceROIs MixROIs -v7.3

%% adding significant ROIs into non-selective ROI population and calculate decoding accuracy
ROIsigSelectInds = [3,6,13,18,26,30,37,49,52,63,88];
nSigSelectROIs = length(ROIsigSelectInds);
TrFreqs = double(SessData.behavResults.Stim_toneFreq);
nROIs = size(SessData.data_aligned,2);
nNonSigSelectROI = nROIs - nSigSelectROIs;

ROIselect = false(nROIs,1);
ROIselect(ROIsigSelectInds) = true; % significantly selective ROIs
NonSelectLoss = TbyTAllROIclassInputParse(data_aligned,TrFreqs,trial_outcome,...
        SessData.start_frame,SessData.frame_rate,'TimeLen',1,'TrOutcomeOp',0,'PartialROIInds',~ROIselect);
%%
ROIaddFraction = 0.5;
ROISampNum = round(ROIaddFraction*nSigSelectROIs);
if ROISampNum < 1
    ROISampNum = 1;
end
nIters = 10;
IterROIinds = cell(nIters,1);
IterTestLoss = cell(nIters,1);
SelectROIinds = find(ROIselect);
NonSelectROIinds = find(~ROIselect);
ROIbaseIndex = false(nROIs,1);
for nit = 1:nIters
    cSetSampleInds = SelectROIinds(randsample(nSigSelectROIs,ROISampNum));
    cNonSetSampleInds = randsample(nNonSigSelectROI,ROISampNum);
    AddROIinds = NonSelectROIinds;
    AddROIinds(cNonSetSampleInds) = [];
    AddROIinds = [AddROIinds(:);cSetSampleInds(:)];
    ROIaddedInds = ROIbaseIndex;
    ROIaddedInds(AddROIinds) = true;
    NonSelectLoss = TbyTAllROIclassInputParse(data_aligned,TrFreqs,trial_outcome,...
        SessData.start_frame,SessData.frame_rate,'TimeLen',1,'TrOutcomeOp',0,'PartialROIInds',ROIaddedInds);
    IterTestLoss{nit} = NonSelectLoss;
    IterROIinds{nit} = AddROIinds;
end

%% 
AllROIloss = TbyTAllROIclassInputParse(data_aligned,TrFreqs,trial_outcome,...
        SessData.start_frame,SessData.frame_rate,'TimeLen',1,'TrOutcomeOp',0);