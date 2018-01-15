clear
clc
[fn,fp,fi] = uigetfile('*.txt','Please select the factor analysis data path');
if ~fi
    return;
end
[Passfn,Passfp,~] = uigetfile('*.txt','Please select passive factor analysis data path');
%%
clearvars -except fn fp Passfp Passfn PassUsedInds
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);
Passid = fopen(fullfile(Passfp,Passfn));
Passline = fgetl(Passid);
nSess = 1;
nSessData = {};
nTunSessData = {};
DisGrWiseAUC = {};
TunedROIinds = {};
if ~exist('PassUsedInds','var')
    PassUsedInds = {};
    isPassIndsExist = 0;
else
    isPassIndsExist = 1;
end

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        Passline = fgetl(Passid);
        continue;
    end
    %%
    NewTaskLine = ['D:\data\xinyu\Data\',tline(4:end)];
    
    PairedAUCPath = fullfile(NewTaskLine,'ROI_pairedWiseAUC_plot','StimPairedAUC.mat');
    AUCDataStrc = load(PairedAUCPath);
    BehavPath = fullfile(NewTaskLine,'RandP_data_plots','boundary_result.mat');
    BehavDataStrc = load(BehavPath);
    SessionStimsOct = log2(AUCDataStrc.StimulusTypes/8000);
    TaskPairedAUCData = AUCDataStrc.ROIwisedAUC;
    
    if length(SessionStimsOct) > 6
        if mod(length(SessionStimsOct),2)
            SessionStimsOct(ceil(length(SessionStimsOct)/2)) = [];
            TaskPairedAUCData(:,ceil(length(SessionStimsOct)/2),:) = [];
            TaskPairedAUCData(:,:,ceil(length(SessionStimsOct)/2)) = [];
        else
            ExcludInds = (abs(SessionStimsOct - 1)) < 0.18;
            SessionStimsOct = SessionStimsOct(~ExcludInds);
            TaskPairedAUCData = TaskPairedAUCData(:,~ExcludInds,~ExcludInds);
        end
    end
    
    TaskDisWiseAUC = DataIndexDiffSub(TaskPairedAUCData);
    BehavBound = BehavDataStrc.boundary_result.Boundary;
    Oct2BoundDis = abs(SessionStimsOct - BehavBound);
    [~,SortInds] = sort(Oct2BoundDis);
    BetBoundTwoOctsInds = min(SortInds(1:2));
    rawMask = ones(length(Oct2BoundDis));
    NearStimMask = logical(tril(rawMask,-1) - tril(rawMask,-2));
    nROIs = length(AUCDataStrc.ROIwisedAUC);
    BetANDWinAvgAUC = zeros(nROIs,2);
    for cR = 1 : nROIs
        cRData = squeeze(TaskPairedAUCData(cR,:,:));
        cRNearBoundData = cRData(NearStimMask);
        LogicalInds = false(length(cRNearBoundData),1);
        LogicalInds(BetBoundTwoOctsInds) = true;
        BetANDWinAvgAUC(cR,:) = [cRNearBoundData(BetBoundTwoOctsInds),mean(cRNearBoundData(~LogicalInds))];
    end
    
    ROITypeDatafile = fullfile(NewTaskLine,'Tunning_fun_plot_New1s','Curve fitting plots','NewCurveFitsave.mat');
    ROITypeDataStrc = load(ROITypeDatafile);
%     CategROIInds = logical(ROITypeDataStrc.IsCategROI);
    TunedROIInds = logical(ROITypeDataStrc.IsTunedROI);
    TaskTunData = BetANDWinAvgAUC(TunedROIInds,:);
    
    NewPassLine = ['D:\data\xinyu\Data\',Passline(4:end)];
    PassAUCPath = fullfile(NewPassLine,'ROI_pairedWiseAUC_plot','StimPairedAUC.mat');
    PassAUCStrc = load(PassAUCPath);
    PassOctaves = log2(PassAUCStrc.StimulusTypes/8000);
    if ~isPassIndsExist
        disp((SessionStimsOct(:))');
        disp((PassOctaves(:))');
        UsedPassStr = input('Please select the used passive Inds:\n','s');
        UsedPassInds = str2num(UsedPassStr);
    else
        UsedPassInds = PassUsedInds{nSess};
    end
    if isempty(UsedPassInds)
        tline = fgetl(fid);
        Passline = fgetl(Passid);
        nSess = nSess + 1;
%         continue;
    else
        PassOctaves = PassOctaves(UsedPassInds);
        PassStimPairedAUC = PassAUCStrc.ROIwisedAUC(:,UsedPassInds,UsedPassInds);
    end
    PassUsedInds{nSess} = UsedPassInds;
    PassDisWiseAUC = DataIndexDiffSub(PassStimPairedAUC);
%     if length(PassOctaves) > size(PassAUCStrc.ROIwisedAUC,2)
%         PassOctaves(ceil(length(PassOctaves)/2)) = [];
%%     end
    PassOct2BoundDis = abs(PassOctaves - BehavBound);
    [~,SortInds] = sort(PassOct2BoundDis);
    BetBoundTwoOctsInds = min(SortInds(1:2));
    PassMask = ones(length(PassOct2BoundDis));
    PassNearStimMask = logical(tril(PassMask,-1) - tril(PassMask,-2));

    PassBetANDWinAvgAUC = zeros(nROIs,2);
    for cr = 1 : nROIs
        cPassData = squeeze(PassStimPairedAUC(cr,:,:));
        cNearBoundData = cPassData(PassNearStimMask);
        LogiInds = false(length(cNearBoundData),1);
        LogiInds(BetBoundTwoOctsInds) = true;
        PassBetANDWinAvgAUC(cr,:) = [cNearBoundData(LogiInds),mean(cNearBoundData(~LogiInds))];
    end
    PassTunData = PassBetANDWinAvgAUC(TunedROIInds,:);
    
    SavePath = fullfile(NewTaskLine,'ROI_pairedWiseAUC_plot','NearStimAUCSave.mat');
    save(SavePath,'BetANDWinAvgAUC','PassBetANDWinAvgAUC','-v7.3');
    
    TunedROIinds{nSess} = TunedROIInds;
    nSessData{nSess,1} = BetANDWinAvgAUC;
    nSessData{nSess,2} = PassBetANDWinAvgAUC;
    nTunSessData{nSess,1} = TaskTunData;
    nTunSessData{nSess,2} = PassTunData;
    DisGrWiseAUC{nSess,1} = TaskDisWiseAUC;
    DisGrWiseAUC{nSess,2} = PassDisWiseAUC;
    
    tline = fgetl(fid);
    Passline = fgetl(Passid);
    nSess = nSess + 1;
end
save('E:\DataToGo\data_for_xu\SingleNeu_PaireStim_AUC\PairedStimAUC\SessSumAUCDataNew2.mat','nSessData','nTunSessData','PassUsedInds',...
    'TunedROIinds','DisGrWiseAUC','-v7.3');
cd('E:\DataToGo\data_for_xu\SingleNeu_PaireStim_AUC\PairedStimAUC');

%% paired ttest
Task_BetANDWinAll = cell2mat(nSessData(:,1));
Pass_BetANDWinAll = cell2mat(nSessData(:,2));
[~,Task_p] = ttest(Task_BetANDWinAll(:,1),Task_BetANDWinAll(:,2));
[~,Pass_p] = ttest(Pass_BetANDWinAll(:,1),Pass_BetANDWinAll(:,2));
hf = GrdistPlot([Task_BetANDWinAll,Pass_BetANDWinAll],{'TaskBet','TaskWin','PassBet','PassWin'});
hf = GroupSigIndication([1,2],max(Task_BetANDWinAll) , Task_p, hf);
hf = GroupSigIndication([3,4],max(Pass_BetANDWinAll) , Pass_p, hf);
saveas(hf,'All ROI OneStep PairedStim compare plot');
saveas(hf,'All ROI OneStep PairedStim compare plot','png');
saveas(hf,'All ROI OneStep PairedStim compare plot','pdf');

%% paired ttest
Task_BetANDWinAll = cell2mat(nTunSessData(:,1));
Pass_BetANDWinAll = cell2mat(nTunSessData(:,2));
[~,Task_p] = ttest(Task_BetANDWinAll(:,1),Task_BetANDWinAll(:,2));
[~,Pass_p] = ttest(Pass_BetANDWinAll(:,1),Pass_BetANDWinAll(:,2));
hf = GrdistPlot([Task_BetANDWinAll,Pass_BetANDWinAll],{'TaskBet','TaskWin','PassBet','PassWin'});
hf = GroupSigIndication([1,2],max(Task_BetANDWinAll) , Task_p, hf);
hf = GroupSigIndication([3,4],max(Pass_BetANDWinAll) , Pass_p, hf);
saveas(hf,'All TunROI OneStep PairedStim compare plot');
saveas(hf,'All TunROI OneStep PairedStim compare plot','png');
saveas(hf,'All TunROI OneStep PairedStim compare plot','pdf');

%% ranksum test
Task_BetANDWinAll = cell2mat(nSessData(:,1));
Pass_BetANDWinAll = cell2mat(nSessData(:,2));
Task_p = ranksum(Task_BetANDWinAll(:,1),Task_BetANDWinAll(:,2));
Pass_p = ranksum(Pass_BetANDWinAll(:,1),Pass_BetANDWinAll(:,2));
[Taskf_bet,Taskx_bet] = ecdf(Task_BetANDWinAll(:,1));
[Taskf_win,Taskx_win] = ecdf(Task_BetANDWinAll(:,2));
[Passf_bet,Passx_bet] = ecdf(Pass_BetANDWinAll(:,1));
[Passf_win,Passx_win] = ecdf(Pass_BetANDWinAll(:,2));
MeanValue = [median(Task_BetANDWinAll),median(Pass_BetANDWinAll)];
GrStrs = {'TaskBet','TaskWin','PassBet','PassWin'};
hf = figure('position',[30 100 480 400]);
ha = axes;
hold on
ll1 = plot(Taskx_bet,Taskf_bet,'Color','r','linewidth',1.8);
ll2 = plot(Taskx_win,Taskf_win,'Color',[0.9 0.6 0.6],'linewidth',1.8);
ll3 = plot(Passx_bet,Passf_bet,'Color',[0 0 0],'linewidth',1.8);
ll4 = plot(Passx_win,Passf_win,'Color',[0.7 0.7 0.7],'linewidth',1.8);
legend([ll1,ll2,ll3,ll4],{'TaskBet','TaskWin','PassBet','PassWin'},'Location','Northwest','FontSize',8,'Box','off');
set(ha,'xtick',[0 0.5 1],'ytick',[0 0.5 1]);
xlabel(ha,'AUC');
ylabel(ha,'Fraction');
title('Paired Stim OneStep AUC')
set(ha,'FontSize',16)
caxesPos = get(ha,'position');
h_axes = axes('position',[caxesPos(1)+(2/3*caxesPos(3)),caxesPos(2)+0.02*caxesPos(4),caxesPos(3)/3,caxesPos(4)*0.5], 'color', 'none', 'visible','off');
hold(h_axes,'on');
bar(h_axes,1,mean(Task_BetANDWinAll(:,1)),0.4,'EdgeColor','none','FaceColor','r');
bar(h_axes,2,mean(Task_BetANDWinAll(:,2)),0.4,'EdgeColor','none','FaceColor',[0.9 0.6 0.6]);
bar(h_axes,3,mean(Pass_BetANDWinAll(:,1)),0.4,'EdgeColor','none','FaceColor','k');
bar(h_axes,4,mean(Pass_BetANDWinAll(:,2)),0.4,'EdgeColor','none','FaceColor',[0.7 0.7 0.7]);
set(h_axes,'xlim',[0.5 4.5],'xcolor','w');
text(h_axes,[1,2,3,4],MeanValue*1.05,cellstr(num2str(MeanValue(:),'%.4f')),'HorizontalAlignment','center','FontSize',6);
GroupSigIndication([1,2],MeanValue([1,2])*1.05 , Task_p, h_axes);
GroupSigIndication([3,4],MeanValue([3,4])*1.05 , Pass_p, h_axes);

saveas(hf,'All ROI OneStep PairedStim ranksum compare');
saveas(hf,'All ROI OneStep PairedStim ranksum compare','png');
saveas(hf,'All ROI OneStep PairedStim ranksum compare','pdf');

%% ranksum test for tuned neurons
Task_BetANDWinAll = cell2mat(nTunSessData(:,1));
Pass_BetANDWinAll = cell2mat(nTunSessData(:,2));
Task_p = ranksum(Task_BetANDWinAll(:,1),Task_BetANDWinAll(:,2));
Pass_p = ranksum(Pass_BetANDWinAll(:,1),Pass_BetANDWinAll(:,2));
[Taskf_bet,Taskx_bet] = ecdf(Task_BetANDWinAll(:,1));
[Taskf_win,Taskx_win] = ecdf(Task_BetANDWinAll(:,2));
[Passf_bet,Passx_bet] = ecdf(Pass_BetANDWinAll(:,1));
[Passf_win,Passx_win] = ecdf(Pass_BetANDWinAll(:,2));
MeanValue = [median(Task_BetANDWinAll),median(Pass_BetANDWinAll)];
GrStrs = {'TaskBet','TaskWin','PassBet','PassWin'};
hf = figure('position',[30 100 480 400]);
ha = axes;
hold on
ll1 = plot(Taskx_bet,Taskf_bet,'Color','r','linewidth',1.8);
ll2 = plot(Taskx_win,Taskf_win,'Color',[0.9 0.6 0.6],'linewidth',1.8);
ll3 = plot(Passx_bet,Passf_bet,'Color',[0 0 0],'linewidth',1.8);
ll4 = plot(Passx_win,Passf_win,'Color',[0.7 0.7 0.7],'linewidth',1.8);
legend([ll1,ll2,ll3,ll4],{'TaskBet','TaskWin','PassBet','PassWin'},'Location','Northwest','FontSize',8,'Box','off');
set(ha,'xtick',[0 0.5 1],'ytick',[0 0.5 1]);
xlabel(ha,'AUC');
ylabel(ha,'Fraction');
title('Paired Stim OneStep AUC')
set(ha,'FontSize',16)
caxesPos = get(ha,'position');
h_axes = axes('position',[caxesPos(1)+(2/3*caxesPos(3)),caxesPos(2)+0.02*caxesPos(4),caxesPos(3)/3,caxesPos(4)*0.5], 'color', 'none', 'visible','off');
hold(h_axes,'on');
bar(h_axes,1,mean(Task_BetANDWinAll(:,1)),0.4,'EdgeColor','none','FaceColor','r');
bar(h_axes,2,mean(Task_BetANDWinAll(:,2)),0.4,'EdgeColor','none','FaceColor',[0.9 0.6 0.6]);
bar(h_axes,3,mean(Pass_BetANDWinAll(:,1)),0.4,'EdgeColor','none','FaceColor','k');
bar(h_axes,4,mean(Pass_BetANDWinAll(:,2)),0.4,'EdgeColor','none','FaceColor',[0.7 0.7 0.7]);
set(h_axes,'xlim',[0.5 4.5],'xcolor','w');
text(h_axes,[1,2,3,4],MeanValue*1.05,cellstr(num2str(MeanValue(:),'%.4f')),'HorizontalAlignment','center','FontSize',6);
GroupSigIndication([1,2],MeanValue([1,2])*1.05 , Task_p, h_axes);
GroupSigIndication([3,4],MeanValue([3,4])*1.05 , Pass_p, h_axes);
saveas(hf,'TunROI OneStep PairedStim ranksum compare');
saveas(hf,'TunROI OneStep PairedStim ranksum compare','png');
saveas(hf,'TunROI OneStep PairedStim ranksum compare','pdf');

%% rank test seperate plot
Task_BetANDWinAll = cell2mat(nSessData(:,1));
Pass_BetANDWinAll = cell2mat(nSessData(:,2));
Task_p = ranksum(Task_BetANDWinAll(:,1),Task_BetANDWinAll(:,2));
Pass_p = ranksum(Pass_BetANDWinAll(:,1),Pass_BetANDWinAll(:,2));
[Taskf_bet,Taskx_bet] = ecdf(Task_BetANDWinAll(:,1));
[Taskf_win,Taskx_win] = ecdf(Task_BetANDWinAll(:,2));
[Passf_bet,Passx_bet] = ecdf(Pass_BetANDWinAll(:,1));
[Passf_win,Passx_win] = ecdf(Pass_BetANDWinAll(:,2));
MeanValue = [median(Task_BetANDWinAll),median(Pass_BetANDWinAll)];
GrStrs = {'TaskBet','TaskWin','PassBet','PassWin'};
hf = figure('position',[30 100 880 380]);
ha = subplot(121);
hold on
ll1 = plot(Taskx_bet,Taskf_bet,'Color','r','linewidth',1.8);
ll2 = plot(Taskx_win,Taskf_win,'Color',[0.9 0.6 0.6],'linewidth',1.8);
legend([ll1,ll2],{'TaskBet','TaskWin'},'Location','Northwest','FontSize',8,'Box','off');
set(ha,'xtick',[0 0.5 1],'ytick',[0 0.5 1]);
xlabel(ha,'AUC');
ylabel(ha,'Fraction');
title('Task Paired Stim OneStep AUC')
set(ha,'FontSize',16)
caxesPos = get(ha,'position');
h_axes = axes('position',[caxesPos(1)+(2/3*caxesPos(3)),caxesPos(2)+0.05*caxesPos(4),caxesPos(3)/3,caxesPos(4)*0.5], 'color', 'none', 'visible','off');
hold(h_axes,'on');
bar(h_axes,1,mean(Task_BetANDWinAll(:,1)),0.4,'EdgeColor','none','FaceColor','r');
bar(h_axes,2,mean(Task_BetANDWinAll(:,2)),0.4,'EdgeColor','none','FaceColor',[0.9 0.6 0.6]);
% bar(h_axes,3,mean(Pass_BetANDWinAll(:,1)),0.4,'EdgeColor','none','FaceColor','k');
% bar(h_axes,4,mean(Pass_BetANDWinAll(:,2)),0.4,'EdgeColor','none','FaceColor',[0.7 0.7 0.7]);
set(h_axes,'xlim',[0.5 2.5],'xcolor','w');
text(h_axes,[1,2],MeanValue([1,2])*1.05,cellstr(num2str((MeanValue([1,2]))','%.4f')),'HorizontalAlignment','center','FontSize',6);
GroupSigIndication([1,2],MeanValue([1,2])*1.05 , Task_p, h_axes);

haPass = subplot(122);
hold on
ll3 = plot(Passx_bet,Passf_bet,'Color',[0 0 0],'linewidth',1.8);
ll4 = plot(Passx_win,Passf_win,'Color',[0.7 0.7 0.7],'linewidth',1.8);
legend([ll3,ll4],{'PassBet','PassWin'},'Location','Northwest','FontSize',8,'Box','off');
set(haPass,'xtick',[0 0.5 1],'ytick',[0 0.5 1]);
xlabel(haPass,'AUC');
ylabel(haPass,'Fraction');
title('Pass Paired Stim OneStep AUC')
set(haPass,'FontSize',16)
caxesPos = get(haPass,'position');
h_axes = axes('position',[caxesPos(1)+(2/3*caxesPos(3)),caxesPos(2)+0.05*caxesPos(4),caxesPos(3)/3,caxesPos(4)*0.5], 'color', 'none', 'visible','off');
hold(h_axes,'on');
% bar(h_axes,1,mean(Task_BetANDWinAll(:,1)),0.4,'EdgeColor','none','FaceColor','r');
% bar(h_axes,2,mean(Task_BetANDWinAll(:,2)),0.4,'EdgeColor','none','FaceColor',[0.9 0.6 0.6]);
bar(h_axes,1,mean(Pass_BetANDWinAll(:,1)),0.4,'EdgeColor','none','FaceColor','k');
bar(h_axes,2,mean(Pass_BetANDWinAll(:,2)),0.4,'EdgeColor','none','FaceColor',[0.7 0.7 0.7]);
set(h_axes,'xlim',[0.5 2.5],'xcolor','w');
text(h_axes,[1,2],MeanValue([3,4])*1.05,cellstr(num2str((MeanValue([3,4])'),'%.4f')),'HorizontalAlignment','center','FontSize',6);
GroupSigIndication([1,2],MeanValue([3,4])*1.05 , Pass_p, h_axes);

saveas(hf,'Seperate Task pass GrwiseAUC compare plot');
saveas(hf,'Seperate Task pass GrwiseAUC compare plot','png');
saveas(hf,'Seperate Task pass GrwiseAUC compare plot','pdf');
