clear
clc
cd('E:\DataToGo\data_for_xu\Tuning_curve_plot');
[fn,fp,~] = uigetfile('*.txt','Please select the text file contains the path of all task sessions');
% [Passfn,Passfp,~] = uigetfile('*.txt','Please select the text file contains the path of all passive sessions');
% load('E:\DataToGo\data_for_xu\SingleCell_RespType_summary\NewMethod\SessROItypeData.mat');

%%
fpath = fullfile(fp,fn);
ff = fopen(fpath);
tline = fgetl(ff);
nSess = 1;
% SessErrorNumSum = {};
NearBoundAmpAll = {};
PassBFRespAmpAll = {};
TaskBFRespAmpAll = {};
TaskPassMaxVAmpAll = {};

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(ff);
        continue;
    end
    %
    clearvars PassFreqOctave PassTunningfun NonMissTunningFun CorrTunningFun 
    TunDataPath = fullfile(tline,'Tunning_fun_plot_New1s','TunningDataSave.mat');
    load(TunDataPath);
    cd(fullfile(tline,'Tunning_fun_plot_New1s'));
    
    BehavBoundfile = load(fullfile(tline,'RandP_data_plots','boundary_result.mat'));
    BehavBoundData = BehavBoundfile.boundary_result.Boundary - 1;
    
    UsedOctaveInds = ~(abs(PassFreqOctave) > 1.1);
    UsedOctave = PassFreqOctave(UsedOctaveInds);
    UsedOctave = UsedOctave(:);
    UsedPassCellData = PassTunCellData(UsedOctaveInds,:);
    UsedPassTunData = PassTunningfun(UsedOctaveInds,:);
    TaskFreqOctave = TaskFreqOctave(:);
%     UsedOctaveData = PassTunningfun(UsedOctaveInds,:);
%     nROIs = size(UsedOctaveData,2);
%     [MaxAmp,maxInds] = max(UsedOctaveData);
%     PassMaxOct = zeros(nROIs,1);
%     for cROI = 1 : nROIs
%         PassMaxOct(cROI) = UsedOctave(maxInds(cROI));
%     end
    disp(UsedOctave');
    disp(TaskFreqOctave');
    UsedStr = input('Please select the used octave inds:\n','s');
    UsedInds = str2num(UsedStr);
    if isempty(UsedInds)
        tline = fgetl(ff);
        nSess = nSess + 1;
        continue;
    else
        UsedOctave = UsedOctave(UsedInds);
        UsedPassCellData = UsedPassCellData(UsedInds,:);
        UsedPassTunData = UsedPassTunData(UsedInds,:);
    end
    %
    OctToBoundDis = abs(UsedOctave - BehavBoundData);
    [~,CloseInds] = min(OctToBoundDis);
    NearBoundBFData = UsedPassCellData(CloseInds,:);  % nROI by 1 cell vectors
    PassNearBoundBFData = cellfun(@mean,NearBoundBFData);
    
    
    TaskOct2BoundDis = abs(TaskFreqOctave - BehavBoundData);
    [~,TaskCloseInds] = min(TaskOct2BoundDis);
    TaskNearBoundData = CorrTunningCellData(TaskCloseInds,:);
    TaskNearBoundAmpAvg = cellfun(@mean,TaskNearBoundData);
    %
    nROIs = length(TaskNearBoundData);
    ROINearBoundSigDiff = zeros(nROIs,1);
    TaskBoundModuIndex = zeros(nROIs,1);
    for cROI = 1 : nROIs
        cROIPassData = NearBoundBFData{cROI};
        cROITaskData = TaskNearBoundData{cROI};
        [~,p] = ttest2(cROIPassData,cROITaskData);
        ROINearBoundSigDiff(cROI) = p;
        
        % calculated the modulation index for boundary tones
        cPassTunData = UsedPassTunData(:,cROI);
        cTaskTunData = CorrTunningFun(:,cROI);
        cTaskBoundValue = cTaskTunData(TaskCloseInds);
        if cTaskBoundValue > 10
            LocalOutData = mean(cTaskTunData([TaskCloseInds-1,TaskCloseInds+1]));
            if LocalOutData < 0
                TaskBoundModuIndex(cROI) = 1;
            else
                TaskBoundModuIndex(cROI) = (cTaskBoundValue - LocalOutData)/(cTaskBoundValue + LocalOutData);
            end
        end
    end
    
    % calculate Passive BF Amp and corresponded task octave Amp
    [PassMaxValue,PassOctInds] = max(UsedPassTunData); % max Response for all Passive Data
    TaskCorresMaxValue = zeros(nROIs,1);
    AmpCompareP = zeros(nROIs,1);
    PassBFOcts = zeros(nROIs,1);
    for cROI = 1 : nROIs
        cROIPassBF = UsedOctave(PassOctInds(cROI));
        [~,TaskNearOctInds] = min(abs(TaskFreqOctave - cROIPassBF));
        TaskCorresMaxValue(cROI) = CorrTunningFun(TaskNearOctInds,cROI);
        cPassDataAll = UsedPassCellData{PassOctInds(cROI),cROI};
        cTaskDataAll = CorrTunningCellData{TaskNearOctInds,cROI};
        [~,p] = ttest2(cPassDataAll,cTaskDataAll);
        AmpCompareP(cROI) = p;
        
        PassBFOcts(cROI) = cROIPassBF;
    end
    PassBFRespAmpAll{nSess,1} = PassMaxValue;
    PassBFRespAmpAll{nSess,2} = TaskCorresMaxValue;
    PassBFRespAmpAll{nSess,3} = AmpCompareP;
    
    % calculate the task BF Amp and corresponded passive Amp
    [TaskBFValue,TaskOctInds] = max(CorrTunningFun);
    PassCorresValue = zeros(nROIs,1);
    TaskCompP = zeros(nROIs,1);
    TaskBFOcts = zeros(nROIs,1);
    for cROI = 1 : nROIs
        cROITaskBF = TaskFreqOctave(TaskOctInds(cROI));
        [~,PassNearOctInds] = min(abs(UsedOctave - cROITaskBF));
        PassCorresValue(cROI) = UsedPassTunData(PassNearOctInds,cROI);
        
        cTaskDatas = CorrTunningCellData{TaskOctInds(cROI),cROI};
        cPassDatas = UsedPassCellData{PassNearOctInds,cROI};
        [~,p] = ttest2(cTaskDatas,cPassDatas);
        TaskCompP(cROI) = p;
        
        TaskBFOcts(cROI) = cROITaskBF;
    end
    TaskBFRespAmpAll{nSess,1} = PassCorresValue;
    TaskBFRespAmpAll{nSess,2} = TaskBFValue;
    TaskBFRespAmpAll{nSess,3} = TaskCompP;
    
    TaskPassMaxVSigAll = zeros(nROIs,1);
    for cROI = 1 : nROIs
        cROITaskDatas = CorrTunningCellData{TaskOctInds(cROI),cROI};
        cROIPassDatas = UsedPassCellData{PassOctInds(cROI),cROI};

        [~,pp] = ttest2(cROITaskDatas,cROIPassDatas);
        TaskPassMaxVSigAll(cROI) = pp;
    end
    TaskPassMaxVAmpAll{nSess,1} = TaskBFValue;
    TaskPassMaxVAmpAll{nSess,2} = PassMaxValue;
    TaskPassMaxVAmpAll{nSess,3} = TaskPassMaxVSigAll;
    
    
    NearBoundAmpAll{nSess,1} = TaskNearBoundAmpAvg;
    NearBoundAmpAll{nSess,2} = PassNearBoundBFData;
    NearBoundAmpAll{nSess,3} = ROINearBoundSigDiff;
    NearBoundAmpAll{nSess,4} = TaskBoundModuIndex;
    NearBoundAmpAll{nSess,5} = PassBFOcts;
    NearBoundAmpAll{nSess,6} = TaskBFOcts;
    
    save NearBoundAmpDiffSig.mat ROINearBoundSigDiff TaskNearBoundAmpAvg PassNearBoundBFData ...
        TaskBoundModuIndex TaskCorresMaxValue PassMaxValue -v7.3
    %
    nSess = nSess + 1;
    tline = fgetl(ff);
end
cd('E:\DataToGo\data_for_xu\BoundTun_DataSave\AmpCompare');
% cd('E:\DataToGo\data_for_xu\BoundTun_DataSave\AmpCompare\2-3TimeWin');
save NearBAmpAll.mat NearBoundAmpAll TaskBFRespAmpAll PassBFRespAmpAll TaskPassMaxVAmpAll -v7.3

%%
TaskAmpAll = cell2mat((NearBoundAmpAll(:,1))');
PassAmpAll = cell2mat((NearBoundAmpAll(:,2))');
ComSigAll = (cell2mat(NearBoundAmpAll(:,3)))';
UInds = ~(TaskAmpAll > 1000 | PassAmpAll > 1000);
TaskUsedData = TaskAmpAll(UInds);
PassUsedData = PassAmpAll(UInds);
SigPUsed = ComSigAll(UInds);

hhhf = figure;
hold on

hl1 = plot(TaskAmpAll(ComSigAll > 0.05 & UInds),PassAmpAll((ComSigAll > 0.05 & UInds)),'o','MarkerSize',6,...
    'MarkerFaceColor',[.7 .7 .7],'MarkerEdgeColor','none');
hl2 = plot(TaskAmpAll(ComSigAll > 0.01 & UInds & ComSigAll < 0.05),PassAmpAll((ComSigAll > 0.01 & UInds  & ComSigAll < 0.05)),'o','MarkerSize',6,...
    'MarkerFaceColor',[1 0.7 0.2],'MarkerEdgeColor','none');
hl3 = plot(TaskAmpAll(ComSigAll < 0.01 & UInds),PassAmpAll((ComSigAll < 0.01 & UInds)),'o','MarkerSize',6,...
    'MarkerFaceColor','r','MarkerEdgeColor','none');

FigAxes = figaxesScaleUni(gca);
AxesScales = get(FigAxes,'xlim');
line(AxesScales,AxesScales,'Color',[.7 .7 .7],'linewidth',1.6,'Linestyle','--');
xlabel('TaskAmp \DeltaF/F_0 (%)');
ylabel('PassAmp \DeltaF/F_0 (%)');
set(gca,'FontSize',14);
legend([hl1,hl2,hl3],{'NoSig','p<0.05','p<0.01'},'Location','NorthWest')
title('BoundTun ROI Amp compare');
FracAboveCal = [mean(TaskUsedData < PassUsedData & SigPUsed < 0.05),mean(TaskUsedData < PassUsedData & SigPUsed < 0.01)];
FracBelowCal = [mean(TaskUsedData > PassUsedData & SigPUsed < 0.05),mean(TaskUsedData > PassUsedData & SigPUsed < 0.01)];
text(400,400,sprintf('SigAbove %.3f, %.3f',FracAboveCal(1),FracAboveCal(2)),'Color','b');
text(400,350,sprintf('SigBelow %.3f, %.3f',FracBelowCal(1),FracBelowCal(2)),'Color','b');

saveas(hhhf,'BoundTunAmp compare plot');
saveas(hhhf,'BoundTunAmp compare plot','png');
saveas(hhhf,'BoundTunAmp compare plot','pdf');

%% plot the amp compare plot
% plot the passive Amp compare
% cSess = 2;
PassBFAmpAll = (cell2mat(PassBFRespAmpAll(:,1)'))';
TaskCorresAmp = cell2mat(PassBFRespAmpAll(:,2));
UInds = ~(PassBFAmpAll(:) > 1000 | TaskCorresAmp(:) > 1000);
[~,p] = ttest(PassBFAmpAll(UInds),TaskCorresAmp(UInds));
ComSigAll = cell2mat(PassBFRespAmpAll(:,3));

TaskUsedData = TaskCorresAmp(UInds);
PassUsedData = PassBFAmpAll(UInds);
SigPUsed = ComSigAll(UInds);

hPassf = figure;
hold on
% plot(PassBFAmpAll(~ExInds),TaskCorresAmp(~ExInds),'o','MarkerSize',6,...
%     'MarkerFaceColor','k','MarkerEdgeColor','none');
hl1 = plot(TaskCorresAmp(ComSigAll > 0.05 & UInds),PassBFAmpAll((ComSigAll > 0.05 & UInds)),'o','MarkerSize',6,...
    'MarkerFaceColor',[.7 .7 .7],'MarkerEdgeColor','none');
hl2 = plot(TaskCorresAmp(ComSigAll > 0.01 & UInds & ComSigAll < 0.05),PassBFAmpAll((ComSigAll > 0.01 & UInds  & ComSigAll < 0.05)),'o','MarkerSize',6,...
    'MarkerFaceColor',[1 0.7 0.2],'MarkerEdgeColor','none');
hl3 = plot(TaskCorresAmp(ComSigAll < 0.01 & UInds),PassBFAmpAll((ComSigAll < 0.01 & UInds)),'o','MarkerSize',6,...
    'MarkerFaceColor','r','MarkerEdgeColor','none');

FigAxes = figaxesScaleUni(gca);
AxesScales = get(FigAxes,'xlim');
line(AxesScales,AxesScales,'Color',[.7 .7 .7],'linewidth',1.6,'Linestyle','--');
xlabel('TaskAmp \DeltaF/F_0 (%)');
ylabel('PassAmp \DeltaF/F_0 (%)');
set(gca,'FontSize',14);
legend([hl1,hl2,hl3],{'NoSig','p<0.05','p<0.01'},'Location','NorthWest')
title(sprintf('PassBF Amp p = %.3e',p));
FracAboveCal = [mean(TaskUsedData < PassUsedData & SigPUsed < 0.05),mean(TaskUsedData < PassUsedData & SigPUsed < 0.01)];
FracBelowCal = [mean(TaskUsedData > PassUsedData & SigPUsed < 0.05),mean(TaskUsedData > PassUsedData & SigPUsed < 0.01)];
text(400,500,sprintf('SigAbove %.3f, %.3f',FracAboveCal(1),FracAboveCal(2)),'Color','b');
text(400,450,sprintf('SigBelow %.3f, %.3f',FracBelowCal(1),FracBelowCal(2)),'Color','b');
saveas(hPassf,'Passive BFAmp compare plot');
saveas(hPassf,'Passive BFAmp compare plot','png');
saveas(hPassf,'Passive BFAmp compare plot','pdf');

%% plot the task amp compare
PassCorresAmp = cell2mat(TaskBFRespAmpAll(:,1));
TaskBFAmpAll = (cell2mat(TaskBFRespAmpAll(:,2)'))';
UInds = ~(PassCorresAmp(:) > 1000 | TaskBFAmpAll(:) > 1000);
[~,p] = ttest(PassCorresAmp(UInds),TaskBFAmpAll(UInds));
ComSigAll = cell2mat(TaskBFRespAmpAll(:,3));

TaskUsedData = TaskBFAmpAll(UInds);
PassUsedData = PassCorresAmp(UInds);
SigPUsed = ComSigAll(UInds);


hTaskf = figure;
hold on
hl1 = plot(TaskBFAmpAll(ComSigAll > 0.05 & UInds),PassCorresAmp((ComSigAll > 0.05 & UInds)),'o','MarkerSize',6,...
    'MarkerFaceColor',[.7 .7 .7],'MarkerEdgeColor','none');
hl2 = plot(TaskBFAmpAll(ComSigAll > 0.01 & UInds & ComSigAll < 0.05),PassCorresAmp((ComSigAll > 0.01 & UInds  & ComSigAll < 0.05)),'o','MarkerSize',6,...
    'MarkerFaceColor',[1 0.7 0.2],'MarkerEdgeColor','none');
hl3 = plot(TaskBFAmpAll(ComSigAll < 0.01 & UInds),PassCorresAmp((ComSigAll < 0.01 & UInds)),'o','MarkerSize',6,...
    'MarkerFaceColor','r','MarkerEdgeColor','none');

FigAxes = figaxesScaleUni(gca);
AxesScales = get(FigAxes,'xlim');
line(AxesScales,AxesScales,'Color',[.7 .7 .7],'linewidth',1.6,'Linestyle','--');
xlabel('TaskAmp \DeltaF/F_0 (%)');
ylabel('PassAmp \DeltaF/F_0 (%)');
set(gca,'FontSize',14);
legend([hl1,hl2,hl3],{'NoSig','p<0.05','p<0.01'},'Location','NorthWest')

title(sprintf('TaskBF Amp p = %.3e',p));
% text(700,800,sprintf('Task %.2f',mean(TaskBFAmpAll(UInds))));
% text(700,750,sprintf('Pass %.2f',mean(PassCorresAmp(UInds))));
FracAboveCal = [mean(TaskUsedData < PassUsedData & SigPUsed < 0.05),mean(TaskUsedData < PassUsedData & SigPUsed < 0.01)];
FracBelowCal = [mean(TaskUsedData > PassUsedData & SigPUsed < 0.05),mean(TaskUsedData > PassUsedData & SigPUsed < 0.01)];
text(400,500,sprintf('SigAbove %.3f, %.3f',FracAboveCal(1),FracAboveCal(2)),'Color','b');
text(400,450,sprintf('SigBelow %.3f, %.3f',FracBelowCal(1),FracBelowCal(2)),'Color','b');

saveas(hTaskf,'Task BFAmp compare plot');
saveas(hTaskf,'Task BFAmp compare plot','png');
saveas(hTaskf,'Task BFAmp compare plot','pdf');

%% combine the task and passive data together
PassBFAmpAll = (cell2mat(PassBFRespAmpAll(:,1)'))';
TaskCorresAmp = cell2mat(PassBFRespAmpAll(:,2));
PassComSigAll = cell2mat(PassBFRespAmpAll(:,3));

PassCorresAmp = cell2mat(TaskBFRespAmpAll(:,1));
TaskBFAmpAll = (cell2mat(TaskBFRespAmpAll(:,2)'))';
TaskCompSigAll = cell2mat(TaskBFRespAmpAll(:,3));

% PassBFAll = cell2mat(NearBoundAmpAll(:,5));
% TaskBFAll = cell2mat(NearBoundAmpAll(:,6));

UsedInds = (PassBFAmpAll < 1000) & (TaskCorresAmp < 1000) & ...
    (PassCorresAmp < 1000) & (TaskBFAmpAll < 1000);
SigLevel = 0.05;
PassBFSuppresedInds = (TaskCorresAmp < PassBFAmpAll) & (PassComSigAll < SigLevel);

PassSurBFPassData = PassBFAmpAll(PassBFSuppresedInds & UsedInds);
PassSurTaskCorrData = TaskCorresAmp(PassBFSuppresedInds & UsedInds);

PassSurTaskData = TaskBFAmpAll(PassBFSuppresedInds & UsedInds);
PassSurPassCorData = PassCorresAmp(PassBFSuppresedInds & UsedInds);
PassSurTaskP = TaskCompSigAll(PassBFSuppresedInds & UsedInds);
ComSigAll = PassSurTaskP;

hAllf = figure('position',[100 100 1000 480]);
subplot(2,3,[1,2,4,5]);
hold on
hl1 = plot(PassSurTaskData(ComSigAll > 0.05),PassSurPassCorData((ComSigAll > 0.05)),'o','MarkerSize',6,...
    'MarkerFaceColor',[.7 .7 .7],'MarkerEdgeColor','none');
hl2 = plot(PassSurTaskData(ComSigAll > 0.01 & ComSigAll < 0.05),PassSurPassCorData((ComSigAll > 0.01 & ComSigAll < 0.05)),'o','MarkerSize',6,...
    'MarkerFaceColor',[1 0.7 0.2],'MarkerEdgeColor','none');
hl3 = plot(PassSurTaskData(ComSigAll < 0.01),PassSurPassCorData((ComSigAll < 0.01)),'o','MarkerSize',6,...
    'MarkerFaceColor','r','MarkerEdgeColor','none');

FigAxes = figaxesScaleUni(gca);
AxesScales = get(FigAxes,'xlim');
line(AxesScales,AxesScales,'Color',[.7 .7 .7],'linewidth',1.6,'Linestyle','--');
xlabel('TaskAmp \DeltaF/F_0 (%)');
ylabel('PassAmp \DeltaF/F_0 (%)');
set(gca,'FontSize',14);
legend([hl1,hl2,hl3],{'NoSig','p<0.05','p<0.01'},'Location','NorthWest')
title('PassSurpressed Task Amp');
FracAboveCal = [mean(PassSurTaskData < PassSurPassCorData & PassSurTaskP < 0.05),mean(PassSurTaskData < PassSurPassCorData & PassSurTaskP < 0.01)];
FracBelowCal = [mean(PassSurTaskData > PassSurPassCorData & PassSurTaskP < 0.05),mean(PassSurTaskData > PassSurPassCorData & PassSurTaskP < 0.01)];
text(400,500,sprintf('SigAbove %.3f, %.3f',FracAboveCal(1),FracAboveCal(2)),'Color','b');
text(400,400,sprintf('SigBelow %.3f, %.3f',FracBelowCal(1),FracBelowCal(2)),'Color','b');
%
DataSum = [PassSurBFPassData,PassSurTaskCorrData,PassSurPassCorData,PassSurTaskData];
DataSumAvg = mean(DataSum);
DataSumSem = std(DataSum)/sqrt(size(DataSum,1));
DataSumMedian = median(DataSum);
subplot(2,3,3)
cla
hold on
bar([1,2,4,5],DataSumAvg,0.5,'FaceColor',[.7 .7 .7],'EdgeColor','none')
errorbar([1,2,4,5],DataSumAvg,DataSumSem,'ko','linewidth',1.6,'Color','k');
set(gca,'xtick',[1,2,4,5],'xticklabel',{'PassBF','TaskCF','PassCF','TaskBF'});
ylabel('\DeltaF/F_0');
set(gca,'FontSize',8);

%
FracSig1All = [FracAboveCal(1),FracBelowCal(1),1-FracAboveCal(1)-FracBelowCal(1)];
FracSig2All = [FracAboveCal(2),FracBelowCal(2),1-FracAboveCal(2)-FracBelowCal(2)];
subplot(2,3,6)
pie(FracSig1All,{sprintf('Surp %.1f%%',FracSig1All(1)*100),sprintf('Enhan %.1f%%',FracSig1All(2)*100),...
    sprintf('NonSig %.1f%%',FracSig1All(3)*100)});
title('SigLevel = 0.05')
%%
saveas(hAllf,'PassSurp TaskBF Amp compare plot');
saveas(hAllf,'PassSurp TaskBF Amp compare plot','png');
saveas(hAllf,'PassSurp TaskBF Amp compare plot','pdf');

%% plot the both max value compare plot

% plot the passive Amp compare
% cSess = 2;
PassBFAmpAll = (cell2mat(TaskPassMaxVAmpAll(:,1)'))';
TaskCorresAmp = (cell2mat(TaskPassMaxVAmpAll(:,2)'))';
UInds = ~(PassBFAmpAll(:) > 1000 | TaskCorresAmp(:) > 1000);
[~,p] = ttest(PassBFAmpAll(UInds),TaskCorresAmp(UInds));
ComSigAll = cell2mat(TaskPassMaxVAmpAll(:,3));

TaskUsedData = TaskCorresAmp(UInds);
PassUsedData = PassBFAmpAll(UInds);
SigPUsed = ComSigAll(UInds);

hPassf = figure;
hold on
% plot(PassBFAmpAll(~ExInds),TaskCorresAmp(~ExInds),'o','MarkerSize',6,...
%     'MarkerFaceColor','k','MarkerEdgeColor','none');
hl1 = plot(TaskCorresAmp(ComSigAll > 0.05 & UInds),PassBFAmpAll((ComSigAll > 0.05 & UInds)),'o','MarkerSize',6,...
    'MarkerFaceColor',[.7 .7 .7],'MarkerEdgeColor','none');
hl2 = plot(TaskCorresAmp(ComSigAll > 0.01 & UInds & ComSigAll < 0.05),PassBFAmpAll((ComSigAll > 0.01 & UInds  & ComSigAll < 0.05)),'o','MarkerSize',6,...
    'MarkerFaceColor',[1 0.7 0.2],'MarkerEdgeColor','none');
hl3 = plot(TaskCorresAmp(ComSigAll < 0.01 & UInds),PassBFAmpAll((ComSigAll < 0.01 & UInds)),'o','MarkerSize',6,...
    'MarkerFaceColor','r','MarkerEdgeColor','none');

FigAxes = figaxesScaleUni(gca);
AxesScales = get(FigAxes,'xlim');
line(AxesScales,AxesScales,'Color',[.7 .7 .7],'linewidth',1.6,'Linestyle','--');
xlabel('TaskAmp \DeltaF/F_0 (%)');
ylabel('PassAmp \DeltaF/F_0 (%)');
set(gca,'FontSize',14);
legend([hl1,hl2,hl3],{'NoSig','p<0.05','p<0.01'},'Location','NorthWest')
title(sprintf('PassBF Amp p = %.3e',p));
FracAboveCal = [mean(TaskUsedData < PassUsedData & SigPUsed < 0.05),mean(TaskUsedData < PassUsedData & SigPUsed < 0.01)];
FracBelowCal = [mean(TaskUsedData > PassUsedData & SigPUsed < 0.05),mean(TaskUsedData > PassUsedData & SigPUsed < 0.01)];
text(400,500,sprintf('SigAbove %.3f, %.3f',FracAboveCal(1),FracAboveCal(2)),'Color','b');
text(400,450,sprintf('SigBelow %.3f, %.3f',FracBelowCal(1),FracBelowCal(2)),'Color','b');
saveas(hPassf,'Both BFAmp compare plot');
saveas(hPassf,'Both BFAmp compare plot','png');
saveas(hPassf,'Both BFAmp compare plot','pdf');

%%
% extract the BF data for passive surpressed Amplitudes
PassBFAmpAll = (cell2mat(PassBFRespAmpAll(:,1)'))';
TaskCorresAmp = cell2mat(PassBFRespAmpAll(:,2));
PassComSigAll = cell2mat(PassBFRespAmpAll(:,3));

PassCorresAmp = cell2mat(TaskBFRespAmpAll(:,1));
TaskBFAmpAll = (cell2mat(TaskBFRespAmpAll(:,2)'))';
TaskCompSigAll = cell2mat(TaskBFRespAmpAll(:,3));

PassBFAll = cell2mat(NearBoundAmpAll(:,5));
TaskBFAll = cell2mat(NearBoundAmpAll(:,6));
%
UsedInds = (PassBFAmpAll < 1000) & (TaskCorresAmp < 1000) & ...
    (PassCorresAmp < 1000) & (TaskBFAmpAll < 1000);
SigLevel = 0.05;
%
PassBFSuppresedInds = (TaskCorresAmp < PassBFAmpAll) & (PassComSigAll < SigLevel);

PassSurBFPassData = PassBFAmpAll(PassBFSuppresedInds & UsedInds);
PassSurTaskCorrData = TaskCorresAmp(PassBFSuppresedInds & UsedInds);

PassSurTaskData = TaskBFAmpAll(PassBFSuppresedInds & UsedInds);
PassSurPassCorData = PassCorresAmp(PassBFSuppresedInds & UsedInds);
PassSurTaskP = TaskCompSigAll(PassBFSuppresedInds & UsedInds);
PassSurTaskBF = TaskBFAll(PassBFSuppresedInds & UsedInds);
PassSurPassBF = PassBFAll(PassBFSuppresedInds & UsedInds);
ComSigAll = PassSurTaskP;

PassSurTaskSurInds = (PassSurTaskP < 0.05 & PassSurTaskData < PassSurPassCorData);
PassSurTaskEnhInds = (PassSurTaskP < 0.05 & PassSurTaskData > PassSurPassCorData);

PassSurTaskSurBFDiff = abs(PassSurTaskBF(PassSurTaskSurInds) - PassSurPassBF(PassSurTaskSurInds)); 
PassSurTaskEnhBFDiff = abs(PassSurTaskBF(PassSurTaskEnhInds) - PassSurPassBF(PassSurTaskEnhInds)); 
[PassSurTaskSurBFy,PassSurTaskSurBFx] = ecdf(PassSurTaskSurBFDiff);
[PassSurTaskEnhBFy,PassSurTaskEnhBFx] = ecdf(PassSurTaskEnhBFDiff);
%%
hf = figure('position',[100 100 320 250]);
hold on
plot(PassSurTaskSurBFx,PassSurTaskSurBFy,'Linewidth',1.5,'Color','m');
plot(PassSurTaskEnhBFx,PassSurTaskEnhBFy,'Linewidth',1.5,'Color',[0.1 0.5 0.1]);
set(gca,'xlim',[-0.1 2.1],'ylim',[-0.1 1.1],'yTick',[0 0.5 1]);
xlabel('BF Difference');
ylabel('Cumulative fraction');
set(gca,'FontSize',10);
saveas(hf,'BF Difference cumulative fraction plot');
saveas(hf,'BF Difference cumulative fraction plot','pdf');
saveas(hf,'BF Difference cumulative fraction plot','png');

%% additional distribution plot
hsumf = figure('position',[50 200 800 260]);
% plot the overall distribution
subplot(231)
hold on
[Counts,Centers] = hist([PassSurTaskEnhBFDiff;PassSurTaskSurBFDiff],15);
bar(Centers,Counts,0.8,'FaceColor',[.7 .7 .7],'edgecolor','none')
plot(Centers,Counts,'k','linewidth',1.2)
xlabel('Distance');
ylabel('Counts')

subplot(232)
hold on
[Counts2,Centers2] = hist(PassSurTaskEnhBFDiff,15);
bar(Centers2,Counts2,0.8,'FaceColor',[.7 .7 .7],'edgecolor','none')
plot(Centers2,Counts2,'k','linewidth',1.2)
xlabel('Distance');
ylabel('Counts')
title('TaskEnh BFDis')

subplot(235)
hold on
[Counts3,Centers3] = hist(PassSurTaskSurBFDiff,15);
bar(Centers3,Counts3,0.8,'FaceColor',[.7 .7 .7],'edgecolor','none')
plot(Centers3,Counts3,'k','linewidth',1.2)
xlabel('Distance');
ylabel('Counts')
title('TaskSur BFDis')

subplot(233)
hold on
[Counts5,Centers5] = hist(PassSurTaskBF(PassSurTaskEnhInds),15);
bar(Centers5,Counts5,0.8,'FaceColor',[.7 .7 .7],'edgecolor','none')
plot(Centers5,Counts5,'k','linewidth',1.2)
xlabel('BF');
ylabel('Counts')
title('Task Enh')

subplot(236)
hold on
[Counts4,Centers4] = hist(PassSurTaskBF(PassSurTaskSurInds),15);
bar(Centers4,Counts4,0.8,'FaceColor',[.7 .7 .7],'edgecolor','none')
plot(Centers4,Counts4,'k','linewidth',1.2)
xlabel('BF');
ylabel('Counts')
title('Task Sup')

% saveas(hsumf,'BF distrtibution summary plot for passBF supData');
% saveas(hsumf,'BF distrtibution summary plot for passBF supData','png');
% saveas(hsumf,'BF distrtibution summary plot for passBF supData','pdf');
%% directly plot the task BF distribution for passBF sup ROIs
TaskBFAllSup = TaskBFAll(PassBFSuppresedInds);
PassBFAllSup = PassBFAll(PassBFSuppresedInds);
BFDiff = abs(TaskBFAllSup - PassBFAllSup);
BFDiffSameInds = BFDiff < 0.05;

hf = figure('position',[100 100 480 420]);
subplot(221)
hold on
[Counts,Centers] = hist(BFDiff,15);
bar(Centers,Counts/sum(Counts),0.8,'FaceColor',[.7 .7 .7],'edgecolor','none')
plot(Centers,Counts/sum(Counts),'k','linewidth',1.2)
xlabel('Difference');
ylabel('Counts')

subplot(222)
hold on
[Counts2,Centers2] = hist(TaskBFAllSup(~BFDiffSameInds),15);
bar(Centers2,Counts2/sum(Counts2),0.8,'FaceColor',[.7 .7 .7],'edgecolor','none')
plot(Centers2,Counts2/sum(Counts2),'k','linewidth',1.2)
xlabel('BF');
ylabel('Counts')
title('Task BF')

subplot(224)
hold on
[Counts3,Centers3] = hist(TaskBFAllSup(BFDiffSameInds),15);
bar(Centers3,Counts3/sum(Counts3),0.8,'FaceColor',[.7 .7 .7],'edgecolor','none')
plot(Centers3,Counts3/sum(Counts3),'k','linewidth',1.2)
xlabel('BF');
ylabel('Counts')
title('Task BF')
%%
saveas(hf,'PassBF Sup TaskBF disrtibution summary');
saveas(hf,'PassBF Sup TaskBF disrtibution summary','png');
saveas(hf,'PassBF Sup TaskBF disrtibution summary','pdf');

%% plot the BF distribution for passBF enhanced ROI's BF

PassBFAmpAll = (cell2mat(PassBFRespAmpAll(:,1)'))';
TaskCorresAmp = cell2mat(PassBFRespAmpAll(:,2));
PassComSigAll = cell2mat(PassBFRespAmpAll(:,3));

PassCorresAmp = cell2mat(TaskBFRespAmpAll(:,1));
TaskBFAmpAll = (cell2mat(TaskBFRespAmpAll(:,2)'))';
TaskCompSigAll = cell2mat(TaskBFRespAmpAll(:,3));

PassBFAll = cell2mat(NearBoundAmpAll(:,5));
TaskBFAll = cell2mat(NearBoundAmpAll(:,6));
%
UsedInds = (PassBFAmpAll < 1000) & (TaskCorresAmp < 1000) & ...
    (PassCorresAmp < 1000) & (TaskBFAmpAll < 1000);
SigLevel = 0.05;
%
PassBFEnhanceInds = PassBFAmpAll < TaskCorresAmp & PassComSigAll < SigLevel & UsedInds;
PassBFEnhPassBF = PassBFAll(PassBFEnhanceInds);
PassBFEnhTaskBF = TaskBFAll(PassBFEnhanceInds);
[~,pTest] = ttest(PassBFEnhTaskBF,PassBFEnhPassBF);
[r,pCoef] = corrcoef(PassBFEnhTaskBF,PassBFEnhPassBF);

hf = figure('position',[100 100 320 250]);
plot(PassBFEnhTaskBF,PassBFEnhPassBF,'ko','MarkerSize',6,'linewidth',1.5);
line([-1.1 1.1],[-1.1 1.1],'Color',[.7 .7 .7],'linewidth',1.4,'linestyle','--');
title(sprintf('P = %.3e',pTest));
text(-0.9,0.8,sprintf('Coef = %.3f',r(2,1)));
text(-0.9,0.65,sprintf('Coefp = %.3e',pCoef(2,1)));
set(gca,'box','off','xlim',[-1.1 1.1],'ylim',[-1.1 1.1]);
xlabel('BF(Task)')
ylabel('BF(Passive)')
saveas(hf,'PassBF enhanced ROI BF compare plot');
saveas(hf,'PassBF enhanced ROI BF compare plot','png');
saveas(hf,'PassBF enhanced ROI BF compare plot','pdf');

%% plot the BF distribution for passBF suppressed ROI's BF
PassBFSuppInds = PassBFAmpAll > TaskCorresAmp & PassComSigAll < SigLevel & UsedInds;
PassBFSupPassBF = PassBFAll(PassBFSuppInds);
PassBFSupTaskBF = TaskBFAll(PassBFSuppInds);


