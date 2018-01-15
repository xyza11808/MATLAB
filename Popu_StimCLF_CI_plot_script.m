
nBoundFreq = 16000;
[fn,fp,fi] = uigetfile('*.txt','Please select task session data path saved file');
if ~fi
    return;
end
[Passfn,Passfp,~] = uigetfile('*.txt','Please select Passive session data path saved file');
Passf = fullfile(Passfp,Passfn);


%%
clearvars -except fp fn Passf Passfn Passfp nBoundFreq
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
%%
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        Passline = fgetl(Passid);
        continue;
    end
    %%
    cd(fullfile(tline,'NeuroM_MC_TbyT','AfterTimeLength-1000ms'));
    filepath = fullfile(tline,'NeuroM_MC_TbyT','AfterTimeLength-1000ms','PairedClassResult.mat');
    PassFPath = fullfile(Passline,'NeuroM_MC_TbyT','AfterTimeLength-1000ms','PairedClassResult.mat');
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
    
    DisWiseClassCorrData = load(fullfile(tline,'NeuroM_MC_TbyT','AfterTimeLength-1000ms','DisErrorDataAllSave.mat'));
    PassDisWiseCCorrData = load(fullfile(Passline,'NeuroM_MC_TbyT','AfterTimeLength-1000ms','DisErrorDataAllSave.mat'));
  %%  
%     h_sum = figure('position',[100 200 450 400]);
%     hold on
%     h1 = plot(DisWiseClassCorrData.BetweenClassCorrDataM(:,2)*DisWiseClassCorrData.OvatveStep,...
%         DisWiseClassCorrData.BetweenClassCorrDataM(:,1),'k-o','LineWidth',2,'MarkerSize',10);% between class distance vs error
%     h2 = plot(DisWiseClassCorrData.LeftClassCorrDataM(:,2)*DisWiseClassCorrData.OvatveStep,...
%         DisWiseClassCorrData.LeftClassCorrDataM(:,1),'b-o','LineWidth',2,'MarkerSize',10); % left winthin group error
%     h3 = plot(DisWiseClassCorrData.RightClassCorrDataM(:,2)*DisWiseClassCorrData.OvatveStep,...
%         DisWiseClassCorrData.RightClassCorrDataM(:,1),'r-o','LineWidth',2,'MarkerSize',10); %right within group error
%     xlim([0 2.4]);
%     set(gca,'xtick',DisWiseClassCorrData.BetweenClassCorrDataM(:,2)*DisWiseClassCorrData.OvatveStep,'xticklabel',...
%         cellstr(num2str(DisWiseClassCorrData.BetweenClassCorrDataM(:,2)*DisWiseClassCorrData.OvatveStep,'%.1f')));
%     PassDisOctaves = PassDisWiseCCorrData.OvatveStep;
%     PassBetClaCorr = PassDisWiseCCorrData.BetweenClassCorrDataM;
%     PassLeftClaCorr = PassDisWiseCCorrData.LeftClassCorrDataM;
%     PassRClaCorr = PassDisWiseCCorrData.RightClassCorrDataM;
%     h4 = plot(PassBetClaCorr(:,2)*PassDisOctaves,PassBetClaCorr(:,1),...
%         'k-o','LineWidth',1.8,'MarkerSize',10,'linestyle','--');
%     h5 = plot(PassLeftClaCorr(:,2)*PassDisOctaves,PassLeftClaCorr(:,1),...
%         'b-o','LineWidth',1.8,'MarkerSize',10,'linestyle','--');
%     h6 = plot(PassRClaCorr(:,2)*PassDisOctaves,PassRClaCorr(:,1),...
%         'r-o','LineWidth',1.8,'MarkerSize',10,'linestyle','--');
%     
%     
%     xlabel('Octave Difference');
%     ylabel('Mean correct rate');
%     title('Distance vs mean correct rate plot');
%     set(gca,'Fontsize',18);
%     legend([h1,h2,h3,h4,h5,h6],{'BetClass','WinLClass','WinRClass','PassBetC','PassLWin','PassRWin'},...
%         'FontSize',10,'Location','Southeast');
%     legend('boxoff');
%     saveas(h_sum,'Distance vs correctrate plot save');
%     saveas(h_sum,'Distance vs correctrate plot save','png');
%     close(h_sum);

    TaskGrNum = floor(length(StimOctave)/2);
    PassGrNum = floor(length(PassStimOct)/2);
    disp((PassStimOct(:))');
    UsedInds = input('Please select the used passive tone index:\n','s');
    if isempty(UsedInds)
        tline = fgetl(fid);
        Passline = fgetl(Passid);
        nSess = nSess + 1;
        continue;
    else
        PassUseInds = str2num(UsedInds);
        PassStimOct = PassStimOct(PassUseInds);
        

    cTaskBetDisData = DisWiseClassCorrData.BetweenClassCorrDataM(1:TaskGrNum-1,:);
    cTaskWinDisData = [DisWiseClassCorrData.LeftClassCorrDataM(1:TaskGrNum-1,:),...
        DisWiseClassCorrData.RightClassCorrDataM(1:TaskGrNum-1,:)];
    cPassBetDisData = PassBetClaCorr(1:PassGrNum-1,:);
    cPassWinDisData = [PassLeftClaCorr(1:PassGrNum-1,:),...
        PassRClaCorr(1:PassGrNum-1,:)];
    TaskDisData(nSess,:) = {cTaskBetDisData,cTaskWinDisData};
    PassDisData(nSess,:) = {cPassBetDisData,cPassWinDisData};
    
    if mod(length(PassStimOct),2)
        UsedInds = true(length(PassStimOct),1);
        UsedInds(PassGrNum + 1) = false;
        PassUsedOctave = PassStimOct(UsedInds);
        PassUsedMtxData = PassClfData(UsedInds,UsedInds);
    else
        PassUsedOctave = PassStimOct;
        PassUsedMtxData = PassClfData;
    end
%
    TaskBetnMask = false(size(PairedClfData));
    TaskBetnMask(1:TaskGrNum,TaskGrNum+1:end) = true;
    TaskWinMask = triu(ones(size(PairedClfData)),1);
    TaskWinMask(TaskBetnMask) = 0;
    TaskWinMask = logical(TaskWinMask);
%
    PassBetMask = false(size(PassUsedMtxData));
    PassBetMask(1:PassGrNum,PassGrNum+1:end) = true;
    PassWinMask = triu(ones(size(PassUsedMtxData)),1);
    PassWinMask(PassBetMask) = 0;
    PassWinMask = logical(PassWinMask);
    TaskIndex(nSess,:) = [mean(PairedClfData(TaskWinMask)),mean(PairedClfData(TaskBetnMask))];
    PassiveIndex(nSess,:) = [mean(PassUsedMtxData(PassWinMask)),mean(PassUsedMtxData(PassBetMask))];
    
    tline = fgetl(fid);
    Passline = fgetl(Passid);
    nSess = nSess + 1;
end

%%
TaskMean = mean(TaskIndex);
TaskSEM = std(TaskIndex)/sqrt(size(TaskIndex,1));
PassMean = mean(PassiveIndex);
PassSEM = std(PassiveIndex)/sqrt(size(PassiveIndex,1));
[~,Taskp] = ttest2(TaskIndex(:,1),TaskIndex(:,2));
[~,TaskBetPasBet] = ttest2(TaskIndex(:,2),PassiveIndex(:,2));
[~,TaskWinPasWin] = ttest2(TaskIndex(:,1),PassiveIndex(:,1));
[~,Passp] = ttest2(PassiveIndex(:,1),PassiveIndex(:,2));
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
hf = GroupSigIndication([1,3],[max(TaskIndex(:,1)),max(PassiveIndex(:,1))],TaskWinPasWin,hf,1.25);
%%
SavePath = uigetdir(pwd,'Please select current figure savage path');
cd(SavePath);
%%
saveas(hf,'Population paired stimulus classification correct rate');
saveas(hf,'Population paired stimulus classification correct rate','png');
close(hf);

save PopuClfDataSave.mat TaskIndex PassiveIndex TaskDisData PassDisData -v7.3
