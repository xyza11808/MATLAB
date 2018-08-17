TrType = double(BehavStrc.Trial_Type(CorrectInds));
UsedActionChoice = double(BehavStrc.Action_choice(CorrectInds));
%% Stimulus based labeling
nTrs = length(TrType);
StimsAll = double(CorrTrialStim);
StimTypes = unique(StimsAll);
nStims = length(StimTypes);
RealLoss = zeros(nTrs,1);
[NormMdDatas,NormMu,NormSigma] = zscore(ConsideringData);
NormTrainMd = fitcsvm(NormMdDatas,TrType);

Ops = statset('UseParallel',true);
TrainMdl = fitcsvm(ConsideringData,TrType);
c = crossval(TrainMdl,'leaveOut','on');
CVTrInds = zeros(nTrs,1);
for cTrs = 1 : nTrs
    CVTrInds(cTrs) = find(c.Partition.test(cTrs));
end
L = kfoldLoss(c,'mode','individual');
RealLoss(CVTrInds) = L;
%

StimRProb = zeros(nStims,1);
for cStimInds = 1 : nStims
    cStim = StimTypes(cStimInds);
    cStimTrs = StimsAll == cStim;
    cStimRProb = mean(RealLoss(cStimTrs));
    if cStim <= 16000
        StimRProb(cStimInds) = cStimRProb;
    else
        StimRProb(cStimInds) = 1 - cStimRProb;
    end
end
StimBasedRProb = StimRProb;
%     figure;
%     plot(StimRProb)

% #####################################################################################
%% calculate the distance factor
% calculate stimulus data for each stimuli type
nROIs = size(ConsideringData,2);
StimAvgData = zeros(nStims,nROIs);
StimCorrAvgData = zeros(nStims,nROIs);
StimTrTypes = zeros(nStims,1);
for cStim = 1 : nStims
    cStimInds = StimsAll == StimTypes(cStim);
    cStimData = ConsideringData(cStimInds,:);
    StimAvgData(cStim,:) = mean(cStimData);
    StimTrTypes(cStim) = mode(TrType(cStimInds));
    
    cStimCorrInds = StimsAll(:) == StimTypes(cStim) & UsedActionChoice(:) == TrType(:);
    StimCorrAvgData(cStim,:) = mean(ConsideringData(cStimCorrInds,:));
end
BehavRProb = boundary_result.StimCorr;
StimRevert = ~StimTrTypes; %boundary_result.StimType < 16000;
BehavRProb(StimRevert) = 1 - BehavRProb(StimRevert);

NormedStimAvgData = (StimAvgData - repmat(NormMu,nStims,1))./repmat(NormSigma,nStims,1);
NormedStimCorrAvgData = (StimCorrAvgData - repmat(NormMu,nStims,1))./repmat(NormSigma,nStims,1);
%%
% [StimTypePred,StimTypeScore] = predict(TrainMdl,StimAvgData);
[StimTypePred,StimTypeScore] = predict(NormTrainMd,NormedStimAvgData);
TypeNorSc = (max(BehavRProb) - min(BehavRProb)) * (StimTypeScore(:,2) - min(StimTypeScore(:,2)))/...
    (max(StimTypeScore(:,2)) - min(StimTypeScore(:,2))) + min(BehavRProb);

[~,CorrStimTypeScore] = predict(NormTrainMd,NormedStimCorrAvgData);
CorrTypeNorSc = (max(BehavRProb) - min(BehavRProb)) * (CorrStimTypeScore(:,2) - min(CorrStimTypeScore(:,2)))/...
    (max(CorrStimTypeScore(:,2)) - min(CorrStimTypeScore(:,2))) + min(BehavRProb);

StimScoreAll = {BehavRProb,StimTypeScore,TypeNorSc};
StimNorScore = TypeNorSc;
figure;
hold on
plot(BehavRProb,'r-o')
plot(StimNorScore,'b-o')
plot(CorrTypeNorSc,'c-o')
%
save CurrentTrClfModel.mat BehavRProb StimNorScore TrainMdl StimAvgData StimTypes ...
    NormedStimAvgData NormMu NormSigma NormTrainMd StimRevert StimsAll -v7.3
%% Choice based labeling
StimsAll = double(CorrTrialStim);
StimTypes = unique(StimsAll);
nStims = length(StimTypes);
RealLoss = zeros(nTrs,1);
TrainMdl = fitcsvm(ConsideringData,AnmTrChoice);
NormTrainMdl = fitcsvm(NormMdDatas,AnmTrChoice);  % NormMdDatas,NormMu,NormSigma

c = crossval(TrainMdl,'leaveOut','on');
CVTrInds = zeros(nTrs,1);
for cTrs = 1 : nTrs
    CVTrInds(cTrs) = find(c.Partition.test(cTrs));
end
L = kfoldLoss(c,'mode','individual');
RealLoss(CVTrInds) = L;
%

StimRProb = zeros(nStims,1);
for cStimInds = 1 : nStims
    cStim = StimTypes(cStimInds);
    cStimTrs = StimsAll == cStim;
    cStimRProb = mean(RealLoss(cStimTrs));
    if cStim <= 16000
        StimRProb(cStimInds) = cStimRProb;
    else
        StimRProb(cStimInds) = 1 - cStimRProb;
    end
end
ChoiceBasedRProb = StimRProb;
%     figure;
%     plot(StimRProb)
% figure;plot(StimRProb)
%% #############################################################
% choice training prediction
% [ChoiceTypePred,ChoiceTypeScore] = predict(TrainMdl,StimAvgData);
[ChoiceTypePred,ChoiceTypeScore] = predict(NormTrainMdl,NormedStimAvgData);
TypeNorSc = (max(BehavRProb) - min(BehavRProb)) * (ChoiceTypeScore(:,2) - min(ChoiceTypeScore(:,2)))/...
    (max(ChoiceTypeScore(:,2)) - min(ChoiceTypeScore(:,2))) + min(BehavRProb);

[~,CorrChoiceTypeScore] = predict(NormTrainMdl,NormedStimCorrAvgData);
CorrTypeNorSc = (max(BehavRProb) - min(BehavRProb)) * (CorrChoiceTypeScore(:,2) - min(CorrChoiceTypeScore(:,2)))/...
    (max(CorrChoiceTypeScore(:,2)) - min(CorrChoiceTypeScore(:,2))) + min(BehavRProb);

ChoiceScoreAll = {BehavRProb,ChoiceTypeScore,TypeNorSc,CorrChoiceTypeScore};
ChoiceNorScore = TypeNorSc;

figure;
hold on
plot(BehavRProb,'r-o')
plot(ChoiceNorScore,'b-o')
plot(CorrTypeNorSc,'c-o')

save ChoiceTrClfModel.mat BehavRProb ChoiceTypeScore ChoiceNorScore TrainMdl StimAvgData StimTypes ...
    NormedStimAvgData NormMu NormSigma NormTrainMd StimRevert NormedStimCorrAvgData StimsAll -v7.3

return;
%% Correct train and error predict
TempCorrInds = AnmTrChoice == TrType;
TempCorrIndex = find(TempCorrInds);

RealLoss = zeros(nTrs,1);
StimsAll = double(CorrTrialStim);
StimTypes = unique(StimsAll);
nStims = length(StimTypes);
CorrTrainMdl = fitcsvm(ConsideringData(TempCorrInds,:),AnmTrChoice(TempCorrInds));
c = crossval(CorrTrainMdl,'leaveOut','on');
CVTrInds = zeros(length(TempCorrIndex),1);
for cTrs = 1 : length(TempCorrIndex)
    CVTrInds(cTrs) = find(c.Partition.test(cTrs));
end
L = kfoldLoss(c,'mode','individual');
CVTempCorrIndex = TempCorrIndex(CVTrInds);
RealLoss(CVTempCorrIndex) = L;
%
ErroDataPreds = predict(CorrTrainMdl,ConsideringData(~TempCorrInds,:));
ErroDataAccu = 1 - ErroDataPreds(:) == (AnmTrChoice(~TempCorrInds))';
RealLoss(~TempCorrInds) = ErroDataAccu;
%
StimRProb = zeros(nStims,1);
for cStimInds = 1 : nStims
    cStim = StimTypes(cStimInds);
    cStimTrs = StimsAll == cStim;
    cStimRProb = mean(RealLoss(cStimTrs));
    if cStim <= 16000
        StimRProb(cStimInds) = cStimRProb;
    else
        StimRProb(cStimInds) = 1 - cStimRProb;
    end
end
CorrBasedRProb = StimRProb;
% #############################################################################
% current model prediction
[CorrTypePred,CorrTypeScore] = predict(CorrTrainMdl,StimAvgData);
TypeNorSc = (max(BehavRProb) - min(BehavRProb)) * (CorrTypeScore(:,2) - min(CorrTypeScore(:,2)))/...
    (max(CorrTypeScore(:,2)) - min(CorrTypeScore(:,2))) + min(BehavRProb);
CorrScoreAll = {BehavRProb,CorrTypeScore,TypeNorSc};
CorrNorScore = TypeNorSc;


%%
StimOcts = log2(StimTypes/16000);
StimStrs = cellstr(num2str(StimTypes(:)/1000,'%.1f'));


%% plot normal scores
hff = figure('position',[100 500 900 240]);
subplot(131)
hold on
plot(StimOcts,StimNorScore,'r-o','linewidth',1.6);
plot(StimOcts,BehavRProb,'k-o','linewidth',1.6);
set(gca,'xtick',StimOcts,'xticklabel',StimStrs,'ylim',[0 1],'ytick',[0 0.5 1]);
title('StimBase Score')
xlabel('Freqs (kHz)');
ylabel('Stim RProb');
set(gca,'FontSize',14);

subplot(132)
hold on
plot(StimOcts,ChoiceNorScore,'b-o','linewidth',1.6);
plot(StimOcts,BehavRProb,'k-o','linewidth',1.6);
set(gca,'xtick',StimOcts,'xticklabel',StimStrs,'ylim',[0 1],'ytick',[0 0.5 1]);
title('ChoiceBase Score')
xlabel('Freqs (kHz)');
ylabel('Choice RPRob');
set(gca,'FontSize',14);

subplot(133)
hold on
plot(StimOcts,CorrNorScore,'m-o','linewidth',1.6);
plot(StimOcts,BehavRProb,'k-o','linewidth',1.6);
set(gca,'xtick',StimOcts,'xticklabel',StimStrs,'ylim',[0 1],'ytick',[0 0.5 1]);
title('CorrBase Score')
xlabel('Freqs (kHz)');
ylabel('Corr RProb');
set(gca,'FontSize',14);

saveas(hff,'Normalized Score compare plot with behavior');
saveas(hff,'Normalized Score compare plot with behavior','png');
close(hff);

%% plot the correct rates
hf = figure('position',[100 100 1200 240]);
subplot(141)
plot(StimOcts,StimBasedRProb,'r-o','linewidth',1.6);
set(gca,'xtick',StimOcts,'xticklabel',StimStrs,'ylim',[0 1],'ytick',[0 0.5 1]);
title('StimBase')
xlabel('Freqs (kHz)');
ylabel('Accuracy');
set(gca,'FontSize',14);

subplot(142)
plot(StimOcts,ChoiceBasedRProb,'b-o','linewidth',1.6);
set(gca,'xtick',StimOcts,'xticklabel',StimStrs,'ylim',[0 1],'ytick',[0 0.5 1]);
title('ChoiceBase')
xlabel('Freqs (kHz)');
ylabel('Accuracy');
set(gca,'FontSize',14);

subplot(143)
plot(StimOcts,CorrBasedRProb,'k-o','linewidth',1.6);
set(gca,'xtick',StimOcts,'xticklabel',StimStrs,'ylim',[0 1],'ytick',[0 0.5 1]);
title('CorrBase')
xlabel('Freqs (kHz)');
ylabel('Accuracy');
set(gca,'FontSize',14);

save SVMAccuracy.mat StimBasedRProb ChoiceBasedRProb CorrBasedRProb StimTypes CorrScoreAll ChoiceScoreAll StimScoreAll -v7.3

%%
clear
clc
cd('E:\DataToGo\data_for_xu\Tuning_curve_plot');
[fn,fp,~] = uigetfile('*.txt','Please select the text file contains the path of all task sessions');
[Passfn,Passfp,~] = uigetfile('*.txt','Please select the text file contains the path of all passive sessions');
%%
clearvars -except fn fp Passfp Passfn
m = 1;
nSession = 1;

fpath = fullfile(fp,fn);
ff = fopen(fpath);
tline = fgetl(ff);
PassFid = fopen(fullfile(Passfp,Passfn));
PassLine = fgetl(PassFid);

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change')) %#ok<*STREMP>
        tline = fgetl(ff);
        PassLine = fgetl(PassFid);
        continue;
    end
    %
    if m == 1
        %
        %                 PPTname = input('Please input the name for current PPT file:\n','s');
        PPTname = 'SVM_class_accuracy_summary_Re';
        if isempty(strfind(PPTname,'.ppt'))
            PPTname = [PPTname,'.pptx'];
        end
        %                 pptSavePath = uigetdir(pwd,'Please select the path used for ppt file savege');
        pptSavePath = 'F:\TestOutputSave';
        %
    end
    Anminfo = SessInfoExtraction(tline);
    SVMFigs = fullfile(tline,'SVM accuracy plots save.png');
    SVMNorScoreFigs = fullfile(tline,'Normalized Score compare plot with behavior.png');
    PassSVMFigs = fullfile(PassLine,'NoBound Popu Passive StimBased SVM plots.png');
    
    pptFullfile = fullfile(pptSavePath,PPTname);
    if ~exist(pptFullfile,'file')
        NewFileExport = 1;
    else
        NewFileExport = 0;
    end
    if NewFileExport
        exportToPPTX('new','Dimensions',[16,9],'Author','XinYu','Comments','Export of tunning curve plot data');
    else
        exportToPPTX('open',pptFullfile);
    end
    %
    exportToPPTX('addslide');
    
    % Anminfo
    exportToPPTX('addtext',sprintf('Session%d',nSession),'Position',[2 0 2 0.5],'FontSize',24);
    exportToPPTX('addnote',tline);
    exportToPPTX('addpicture',imread(SVMFigs),'Position',[0 0.5 16 3.2]);
    exportToPPTX('addpicture',imread(SVMNorScoreFigs),'Position',[0 4 9.4 2.5]);
    exportToPPTX('addpicture',imread(PassSVMFigs),'Position',[0 6.5 6.25 2.5]);
    
    exportToPPTX('addtext',sprintf('Batch:%s Anm: %s\r\nDate: %s Field: %s',...
        Anminfo.BatchNum,Anminfo.AnimalNum,Anminfo.SessionDate,Anminfo.TestNum),...
        'Position',[10 5 5 2],'FontSize',22);
    
    m = m + 1;
    nSession = nSession + 1;
    saveName = exportToPPTX('saveandclose',pptFullfile);
    tline = fgetl(ff);
    PassLine = fgetl(PassFid);
end
fprintf('Current figures saved in file:\n%s\n',saveName);
cd(pptSavePath);
