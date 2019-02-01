
nBoundFreq = 16000;
[fn,fp,fi] = uigetfile('*.txt','Please select task session data path saved file');
if ~fi
    return;
end
[Passfn,Passfp,~] = uigetfile('*.txt','Please select Passive session data path saved file');
Passf = fullfile(Passfp,Passfn);


%%
clearvars -except fp fn Passf Passfn Passfp nBoundFreq UsedPassInds
fpath = fullfile(fp,fn);
fid = fopen(fpath);
Passid = fopen(Passf);
tline = fgetl(fid);
Passline = fgetl(Passid);
nSess = 1;
TaskIndex = [];
PassiveIndex = [];
TaskDisData = {};
PassDisData = {};
TaskPassOneStepclf = {};

if ~exist('UsedPassInds','var') || isempty(UsedPassInds)
    UsedPassInds = {};
    isPassIndsExist = 0;
else
    isPassIndsExist = 1;
end
%
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        Passline = fgetl(Passid);
        continue;
    end
    %
    cd(fullfile(tline,'NeuroM_MC_TbyTNew','AfterTimeLength-1000ms'));
    filepath = fullfile(tline,'NeuroM_MC_TbyTNew','AfterTimeLength-1000ms','PairedClassResult.mat');
    PassFPath = fullfile(Passline,'NeuroM_MC_TbyTNew','AfterTimeLength-1000ms','PairedClassResult.mat');
    fDataStrc = load(filepath);
    PassDataStrc = load(PassFPath);
    StimsAll = double(fDataStrc.StimTypesAll);
    StimOctave = log2(StimsAll/16000);
    PassStimOct = log2(double(PassDataStrc.StimTypesAll)/16000);
%     disp((PassDataStrc.StimTypesAll(:))');
%     Indstr = input('Please select used octave index','s');
%     Inds = str2num(Indstr);
    PairedClfData = fDataStrc.matrixData;
    PassClfData = PassDataStrc.matrixData;
%     PassStimOct = PassStimOct(Inds);
%     PassClfData = PassClfData(Inds,Inds);

    TaskGrNum = floor(length(StimOctave)/2);
    PassGrNum = floor(length(PassStimOct)/2);
    disp((PassStimOct(:))');
    disp(StimOctave');
    if ~isPassIndsExist
        UsedInds = input('Please select the used passive tone index:\n','s');
        PassUseInds = str2num(UsedInds);
    else
        PassUseInds = UsedPassInds{nSess};
    end
    if isempty(PassUseInds)
        tline = fgetl(fid);
        Passline = fgetl(Passid);
        nSess = nSess + 1;
        continue;
    else
%         PassUseInds = str2num(UsedInds);
        PassStimOct = PassStimOct(PassUseInds);
        PassClfData = PassClfData(PassUseInds,PassUseInds);
    end
    UsedPassInds{nSess} = PassUseInds;
    if mod(length(StimOctave),2)
        StimOctave(TaskGrNum+1) = [];
        PairedClfData(TaskGrNum+1,:) = [];
        PairedClfData(:,TaskGrNum+1) = [];
    end
    if min(abs(StimOctave)) < 0.18
        ExcludedInds = abs(StimOctave) < 0.19;
        StimOctave(ExcludedInds) = [];
        PairedClfData = PairedClfData(~ExcludedInds,~ExcludedInds);
    end
      %
      RawMask = ones(size(PairedClfData));
      OneStepMask = logical(tril(RawMask,-1)-tril(RawMask,-2));
      TaskOneStepData = PairedClfData(OneStepMask);
      PassOneStepData = PassClfData(OneStepMask);
      
      TaskPassOneStepclf{nSess,1} = TaskOneStepData;
      TaskPassOneStepclf{nSess,2} = PassOneStepData;
      
       TaskDisDataStrc = DataIndexDiffSub(PairedClfData);
       PassDisDataStrc = DataIndexDiffSub(PassClfData);
       
       
       TaskDisData{nSess} = TaskDisDataStrc;
       PassDisData{nSess} = PassDisDataStrc;
%     if mod(length(PassStimOct),2)
%         UsedInds = true(length(PassStimOct),1);
%         UsedInds(PassGrNum + 1) = false;
%         PassUsedOctave = PassStimOct(UsedInds);
%         PassUsedMtxData = PassClfData(UsedInds,UsedInds);
%     else
%         PassUsedOctave = PassStimOct;
%         PassUsedMtxData = PassClfData;
%     end
%
    CommonDisScale = size(PassDisDataStrc.WinGrData,1);
    
    TaskIndex(nSess,:) = [mean(TaskDisDataStrc.WinGrData(1:CommonDisScale,1)),mean(TaskDisDataStrc.BetGrData(1:CommonDisScale,1))];
    PassiveIndex(nSess,:) = [mean(PassDisDataStrc.WinGrData(1:CommonDisScale,1)),mean(PassDisDataStrc.BetGrData(1:CommonDisScale,1))];
    %
    tline = fgetl(fid);
    Passline = fgetl(Passid);
    nSess = nSess + 1;
end

%%
BackTaskIndex = TaskIndex;
BackPassIndex = PassiveIndex;
TaskIndex(TaskIndex(:,1) == 0,:) = [];
PassiveIndex(PassiveIndex(:,1) == 0,:) = [];
TaskMean = mean(TaskIndex);
TaskSEM = std(TaskIndex)/sqrt(size(TaskIndex,1));
PassMean = mean(PassiveIndex);
PassSEM = std(PassiveIndex)/sqrt(size(PassiveIndex,1));
[~,Taskp] = ttest(TaskIndex(:,1),TaskIndex(:,2));
[~,TaskBetPasBet] = ttest(TaskIndex(:,2),PassiveIndex(:,2));
[~,TaskWinPasWin] = ttest(TaskIndex(:,1),PassiveIndex(:,1));
[~,Passp] = ttest(PassiveIndex(:,1),PassiveIndex(:,2));
hf = figure('position',[3000 200 450 380]);
hold on
plot([1,2],TaskIndex','Color',[1 .7 .7],'Linewidth',1.2);
El1 = errorbar([1,2],TaskMean,TaskSEM,'r-o','linewidth',2.2);
plot([3,4],PassiveIndex','Color',[.7 .7 .7],'Linewidth',1.2);
El2 = errorbar([3,4],PassMean,PassSEM,'k-o','linewidth',2.2);
xlim([0.5 4.4]);
% ylim([0.5 1]);
set(gca,'xtick',1:4,'xticklabel',{'TaskWin','TaskBet','PassWin','PassBet'},'ytick',[0.5 0.75 1]);
ylabel('Correct rate')
title('Popu Classfifcation of paired stimulus');
set(gca,'FontSize',16);
legend([El1,El2],{'TaskMean','PassMean'},'FontSize',10,'Location','Southwest','box','off','AutoUpdate','off');
% legend('boxoff');
hf = GroupSigIndication([1,2],max(TaskIndex),Taskp,hf,1.1);
hf = GroupSigIndication([3,4],max(PassiveIndex),Passp,hf,1.1);
hf = GroupSigIndication([2,4],[max(TaskIndex(:,2)),max(PassiveIndex(:,2))],TaskBetPasBet,hf,1.3);
hf = GroupSigIndication([1,3],[max(TaskIndex(:,1)),max(PassiveIndex(:,1))],TaskWinPasWin,hf,1.2);
%%
SavePath = uigetdir(pwd,'Please select current figure savage path');
cd(SavePath);
%%
saveas(hf,'Population paired stimulus classification correct rate');
saveas(hf,'Population paired stimulus classification correct rate','png');
close(hf);
%%
save PopuClfDataSaveNew.mat TaskIndex PassiveIndex TaskDisData PassDisData UsedPassInds BackTaskIndex BackPassIndex TaskPassOneStepclf -v7.3

%% compare population classification rate of paired stimulus, distance-wise
UsedSessInds = ~(cellfun(@isempty,PassDisData));
RealSessTaskData = TaskDisData(UsedSessInds);
RealSessPassData = PassDisData(UsedSessInds);
MaxWinDis = size(RealSessTaskData{1}.WinGrData,1);
MaxBetDis = size(RealSessTaskData{1}.BetGrData,1);
TaskSessBetGrData = cell2mat((cellfun(@(x) (x.BetGrData(:,1))',RealSessTaskData,'UniformOutput',false))');
TaskSessWinGrData = cell2mat((cellfun(@(x) (x.WinGrData(:,1))',RealSessTaskData,'UniformOutput',false))');
PassSessBetGrData = cell2mat((cellfun(@(x) (x.BetGrData(:,1))',RealSessPassData,'UniformOutput',false))');
PassSessWinGrData = cell2mat((cellfun(@(x) (x.WinGrData(:,1))',RealSessTaskData,'UniformOutput',false))');

%% Task AUC plot
hh_f = figure('position',[100 100 420 350]);
hold on
for cDis = 1 : MaxBetDis
    if MaxWinDis >= cDis  % within group distance value exists
        cPlotData = [TaskSessBetGrData(:,cDis),TaskSessWinGrData(:,cDis)];
        ErrorSEM = std(cPlotData)/sqrt(size(cPlotData,1));
        PlotInds = [cDis-0.25,cDis+0.25];
        plot(PlotInds,cPlotData','Color',[.7 .7 .7],'Linewidth',0.8);
        errorbar(PlotInds,mean(cPlotData),ErrorSEM,'Color','k','linewidth',2);
        [~,cP] = ttest(cPlotData(:,1),cPlotData(:,2));
%         cP = ranksum(cPlotData(:,1),cPlotData(:,2));
        GroupSigIndication(PlotInds,max(cPlotData) , cP, hh_f,1.05);
    else
        cPlotData = TaskSessBetGrData(:,cDis);
        ErrorSEM = std(cPlotData)/sqrt(length(cPlotData));
        plot(cDis,cPotdata,'o','Color',[.7 .7 .7],'Linewidth',0.8);
        errorbar(cDis,mean(cPlotData),ErrorSEM,'Color','k','linewidth',2);
    end
end
set(gca,'ytick',[0.5 0.75 1]);
title('Task AUC distance-wise compare plot');
saveas(hh_f,'Task distance-wise AUC compare plot');
saveas(hh_f,'Task distance-wise AUC compare plot','png');
saveas(hh_f,'Task distance-wise AUC compare plot','pdf');
%% Passive AUC plot
hh_f = figure('position',[100 100 420 350]);
hold on
for cDis = 1 : MaxBetDis
    if MaxWinDis >= cDis  % within group distance value exists
        cPlotData = [PassSessBetGrData(:,cDis),PassSessWinGrData(:,cDis)];
        ErrorSEM = std(cPlotData)/sqrt(size(cPlotData,1));
        PlotInds = [cDis-0.25,cDis+0.25];
        plot(PlotInds,cPlotData','Color',[.7 .7 .7],'Linewidth',0.8);
        errorbar(PlotInds,mean(cPlotData),ErrorSEM,'Color','k','linewidth',2);
        [~,cP] = ttest(cPlotData(:,1),cPlotData(:,2));
        GroupSigIndication(PlotInds,max(cPlotData) , cP, hh_f,1.05);
    else
        cPlotData = PassSessBetGrData(:,cDis);
        ErrorSEM = std(cPlotData)/sqrt(length(cPlotData));
        plot(cDis,cPotdata,'o','Color',[.7 .7 .7],'Linewidth',0.8);
        errorbar(cDis,mean(cPlotData),ErrorSEM,'Color','k','linewidth',2);
    end
end
set(gca,'ytick',[0.5 0.75 1]);
title('Pass AUC distance-wise compare plot');
saveas(hh_f,'Pass distance-wise AUC compare plot');
saveas(hh_f,'Pass distance-wise AUC compare plot','png');
saveas(hh_f,'Pass distance-wise AUC compare plot','pdf');

%% step-one classification groupwise plot
EmptyInds = ~(cellfun(@isempty,TaskPassOneStepclf(:,1)));
TaskOneStepDatacell = TaskPassOneStepclf(EmptyInds,1);
PassOneStepDatacell = TaskPassOneStepclf(EmptyInds,2);
TaskOneStepDataMtx = (cell2mat(TaskOneStepDatacell'))';
PassOneStepDataMtx = (cell2mat(PassOneStepDatacell'))';
TaskOneStepDataSEM = std(TaskOneStepDataMtx)/sqrt(size(TaskOneStepDataMtx,1));
PassOneStepDataSEM = std(PassOneStepDataMtx)/sqrt(size(PassOneStepDataMtx,1));
TypeNum = length(TaskOneStepDataSEM);
GrNum = floor(TypeNum/2);
TypeStrs = [repmat({'Win'},GrNum,1);{'Bet'};repmat({'Win'},GrNum,1)];

hf = figure('position',[100 100 380 300]);
hold on
errorbar(1:TypeNum,mean(TaskOneStepDataMtx),TaskOneStepDataSEM,'-o','Color',[1 0.7 0.2],'linewidth',2);
errorbar(1:TypeNum,mean(PassOneStepDataMtx),PassOneStepDataSEM,'k-o','linewidth',2);
set(gca,'xtick',1:TypeNum,'xticklabel',TypeStrs);
ylabel('Accuracy');
set(gca,'FontSize',16)
saveas(hf,'OneStep ClfAccuracy line comparison');
saveas(hf,'OneStep ClfAccuracy line comparison','png');

%%
UsedSessDataAll = SessDataAll;
UsedSessDataAll([10,11],:) = [];
SessCompareNum = cellfun(@length,UsedSessDataAll(:,1));
UsedGrNum = min(SessCompareNum);
WinGrNum = floor(UsedGrNum/2);
TypeStrs = [repmat({'Win'},WinGrNum,1);{'Bet'};repmat({'Win'},WinGrNum,1)];
SessNum = length(SessCompareNum);
SessSumRealDataAll = zeros(SessNum,UsedGrNum);
SessSumShufDataAll = zeros(SessNum,UsedGrNum);
for cSess = 1 : SessNum
    cSessRealData = UsedSessDataAll{cSess,1};
    cSessShufData = UsedSessDataAll{cSess,2};
    
    UsedInds = true(length(cSessRealData),1);
    if length(cSessRealData) > UsedGrNum
        cSessGrNum = floor(length(cSessRealData)/2);
        UsedInds([cSessGrNum,cSessGrNum+2]) = false;
    end
    SessSumRealDataAll(cSess,:) = cSessRealData(UsedInds);
    SessSumShufDataAll(cSess,:) = cSessShufData(UsedInds);
end
figure;
plot(mean(SessSumRealDataAll),'Color',[1 0.7 0.2],'linewidth',1.6);
hold on
plot(mean(SessSumShufDataAll),'Color',[.7 .7 .7],'linewidth',1.6);
set(gca,'xtick',1:UsedGrNum,'xticklabel',TypeStrs);
ylabel('Accuracy');
title('OneStep Accuracy');
set(gca,'FontSize',16)
saveas(gcf,'Task real and shuf Data plots');
saveas(gcf,'Task real and shuf Data plots','png');