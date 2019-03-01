cclr
cd('E:\DataToGo\data_for_xu\Tuning_curve_plot');
[fn,fp,~] = uigetfile('*.txt','Please select the text file contains the path of all task sessions');
[Passfn,Passfp,~] = uigetfile('*.txt','Please select the text file contains the path of all passive sessions');
% load('E:\DataToGo\data_for_xu\SingleCell_RespType_summary\NewMethod\SessROItypeData.mat');
%%

fpath = fullfile(fp,fn);
PassFid = fopen(fullfile(Passfp,Passfn));

ff = fopen(fpath);
tline = fgetl(ff);
PassLine = fgetl(PassFid);
cSess = 1;
%
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
       tline = fgetl(ff);
       PassLine = fgetl(PassFid);
        continue;
    end
    cd(tline);
    
    load('CSessionData.mat');

%     BoundTunROIs = BoundTunROIindex{cSess,1};
%     NoBoundROIinds = true(size(smooth_data,2),1);
%     NoBoundROIinds(BoundTunROIs) = false;
    RandNMTChoiceDecoding(smooth_data,behavResults,trial_outcome,start_frame,frame_rate,1); %,[],[],NoBoundROIinds
    
    figure(gcf);
    
    subplot(144);
    BehavDataPath = fullfile(pwd,'RandP_data_plots','boundary_result.mat');
    BehavDataStrc = load(BehavDataPath);
    StimCorr = BehavDataStrc.boundary_result.StimCorr;
    GrStimNum = floor(numel(StimCorr)/2);
    RProb = StimCorr;
    RProb(1:GrStimNum) = 1 - RProb(1:GrStimNum);
    Stims = BehavDataStrc.boundary_result.StimType;
    StimOct = log2(Stims/16000);
    StimStr = cellstr(num2str(Stims(:)/1000,'%.1f'));
    plot(StimOct,RProb,'g-o','linewidth',1.6);
    set(gca,'xtick',StimOct,'xticklabel',StimStr,'ylim',[0 1],'ytick',[0 0.5 1]);
    title('Behavior')
    xlabel('Freqs (kHz)');
    ylabel('Accuracy');
    set(gca,'FontSize',14);

    saveas(gcf,'Popu SVM accuracy plots save');
    saveas(gcf,'Popu SVM accuracy plots save','png');
    close(gcf);

    %
    cd(PassLine);
    PassStrc = load('rfSelectDataSet.mat');
    PassDataAll = PassStrc.SelectData;
    RFSmoothData = zeros(size(PassStrc.SelectData));
    [nTrs,nROIs,nFrames] = size(PassStrc.SelectData);
    parfor cTr = 1 : nTrs
        for cROI = 1 : nROIs
            RFSmoothData(cTr,cROI,:) = smooth(squeeze(PassDataAll(cTr,cROI,:)),5);
        end
    end
    %
    UsedTrInds = PassStrc.SelectSArray(:) > 7900 & PassStrc.SelectSArray(:) < 33000;
    PesudoChoice = double(PassStrc.SelectSArray(:) > 16000);
    PassFakeStrc = [PassStrc.SelectSArray(:),PesudoChoice];
    PassTrOutcome = ones(numel(PesudoChoice),1);
    %
    BehavStrPath = fullfile(tline,'RandP_data_plots','boundary_result.mat');
    RandNMTChoiceDecoding_RF(RFSmoothData(UsedTrInds,:,:),PassFakeStrc(UsedTrInds,:),PassTrOutcome(UsedTrInds),PassStrc.frame_rate,PassStrc.frame_rate,...
        1,[],[],[],[],[],BehavStrPath);
     %
    tline = fgetl(ff);
    PassLine = fgetl(PassFid);
    cSess = cSess + 1;
end

%%

fpath = fullfile(fp,fn);
PassFid = fopen(fullfile(Passfp,Passfn));

ff = fopen(fpath);
tline = fgetl(ff);
PassLine = fgetl(PassFid);
nSess = 1;
SVMNeuTaskSum = {};

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
       tline = fgetl(ff);
       PassLine = fgetl(PassFid);
        continue;
    end
    
    TaskNMDataPath = fullfile(tline,'NeuroM_test','AfterTimeLength-1000ms','NMDataSummry.mat');
    PassNMDataPath = fullfile(PassLine,'NeuroM_test','AfterTimeLength-1000ms','NMDataSummry.mat');
    TaskNMDataStrc = load(TaskNMDataPath);
    PassNMDataStrc = load(PassNMDataPath);
    
    BehavTones = TaskNMDataStrc.Octavexfit(:);
    BehavRProbs = TaskNMDataStrc.realy(:);
    TaskNeuRProb = TaskNMDataStrc.fityAll(:);
    SVMNeuTaskSum{nSess,1} = BehavTones;
    SVMNeuTaskSum{nSess,2} = BehavRProbs;
    SVMNeuTaskSum{nSess,3} = TaskNeuRProb;
    
    PassOctaves = PassNMDataStrc.Octavexfit(:);
    disp(BehavTones');
    disp(PassOctaves');
    IndsStr = input('Please input used index for passive session:\n','s');
    UsedInds = str2num(IndsStr);
    if isempty(UsedInds)
        tline = fgetl(ff);
        PassLine = fgetl(PassFid);
        nSess = nSess + 1;
        continue;
    else
        PassOctaves = PassOctaves(UsedInds);
        PassNeuData = PassNMDataStrc.fityAll(UsedInds);
    end
    
    SVMNeuTaskSum{nSess,4} = PassNeuData;
    SVMNeuTaskSum{nSess,5} = PassOctaves;
    
    tline = fgetl(ff);
    PassLine = fgetl(PassFid);
    nSess = nSess + 1;
    
end
%%
UsedSessIndex = ~cellfun(@isempty,SVMNeuTaskSum(:,1));
UsedSVMNeuTaskSum = SVMNeuTaskSum(UsedSessIndex,:);

BehavOctsAll = cell2mat(SVMNeuTaskSum(:,1));
BehavRProbAll = cell2mat(SVMNeuTaskSum(:,2));
TaskRProbAll = cell2mat(SVMNeuTaskSum(:,3));

PassOctsAll = cell2mat(UsedSVMNeuTaskSum(:,5));
PassBehavsAll = cell2mat(UsedSVMNeuTaskSum(:,2));
PassRProbAll = cell2mat(UsedSVMNeuTaskSum(:,4));
%%
nUsedSess = size(SVMNeuTaskSum,1);
TaskSessOcts = nan(nUsedSess,8);
UsedSessBehav = nan(nUsedSess,8);
UsedSessTaskRProb = nan(nUsedSess,8);
PassSessOcts = nan(nUsedSess,8);
UsedSessPassRProb = nan(nUsedSess,8);
for cSess = 1 : nUsedSess
    cSessBehavTone = SVMNeuTaskSum{cSess,1};
    cSessBehav = SVMNeuTaskSum{cSess,2};
    cSessTaskRProb = SVMNeuTaskSum{cSess,3};
    cSessPassOcts = SVMNeuTaskSum{cSess,5};
    cSessPassRProb = SVMNeuTaskSum{cSess,4};
    
    if length(cSessBehavTone) == 7
        cUsedOctInds = [1,2,3,5,6,7];
        cAssignInds = [1,2,3,6,7,8];
    elseif length(cSessBehavTone) == 8
        cUsedOctInds = 1:8;
        cAssignInds = 1:8;
    else
        cUsedOctInds = 1:6;
        cAssignInds = [1,2,3,6,7,8];
    end
    
    TaskSessOcts(cSess,cAssignInds) = cSessBehavTone(cUsedOctInds);
    UsedSessBehav(cSess,cAssignInds) = cSessBehav(cUsedOctInds);
    UsedSessTaskRProb(cSess,cAssignInds) = cSessTaskRProb(cUsedOctInds);
    
    % assign passive data
    if ~isempty(cSessPassRProb)
        if numel(cAssignInds) == numel(cSessPassOcts)
            PassSessOcts(cSess,cAssignInds) = cSessPassOcts;
            UsedSessPassRProb(cSess,cAssignInds) = cSessPassRProb;
        elseif numel(cSessPassOcts) == 7 && numel(cAssignInds) == 6
            PassSessOcts(cSess,cAssignInds) = cSessPassOcts([1,2,3,5,6,7]);
            UsedSessPassRProb(cSess,cAssignInds) = cSessPassRProb([1,2,3,5,6,7]);
        end
            
    end
end
%%
TaskTones = mean(TaskSessOcts,'omitnan');
PassTones = mean(PassSessOcts,'omitnan');
TaskPassSessNum = zeros(8,2);
for cTone = 1 : 8
    TaskPassSessNum(cTone,:) = [sum(~isnan(TaskSessOcts(:,cTone))),sum(~isnan(PassTones(:,cTone)))];
end
behavAvgSem = [mean(UsedSessBehav,'omitnan');std(UsedSessBehav,'omitnan')];%/sqrt(nUsedSess)
TaskAvgSem = [mean(UsedSessTaskRProb,'omitnan');std(UsedSessTaskRProb,'omitnan')];%/sqrt(nUsedSess)
PassAvgSem = [mean(UsedSessPassRProb,'omitnan');std(UsedSessPassRProb,'omitnan')];%/sqrt(nUsedSess)

BehavFitData = FitPsycheCurveWH_nx(BehavOctsAll,BehavRProbAll);
BehavCI = predint(BehavFitData.ffit,BehavFitData.curve(:,1),0.95,'functional','on');
TaskFitData = FitPsycheCurveWH_nx(BehavOctsAll,TaskRProbAll);
TaskCI = predint(TaskFitData.ffit,TaskFitData.curve(:,1),0.95,'functional','on');
PassFitData = FitPsycheCurveWH_nx(PassOctsAll,PassRProbAll);
PassCI = predint(PassFitData.ffit,PassFitData.curve(:,1),0.95,'functional','on');

%%
hf = figure('position',[2000 100 380 300]);
hold on
plot(BehavFitData.curve(:,1),BehavFitData.curve(:,2),'Color','r','linewidth',1.6);
plot(TaskFitData.curve(:,1),TaskFitData.curve(:,2),'Color',[1 0.7 0.2],'linewidth',1.6);
plot(PassFitData.curve(:,1),PassFitData.curve(:,2),'Color','k','linewidth',1.6);
errorbar(TaskTones,behavAvgSem(1,:),behavAvgSem(2,:),'ro','linewidth',1.4,'CapSize',0); %,'Marker','none'
errorbar(TaskTones,TaskAvgSem(1,:),TaskAvgSem(2,:),'o','linewidth',1.4,'CapSize',0,'Color',[1 0.7 0.2]);
errorbar(PassTones,PassAvgSem(1,:),PassAvgSem(2,:),'ko','linewidth',1.4,'CapSize',0);
plot(BehavFitData.curve(:,1),BehavCI,'Color','r','linewidth',1.2,'linestyle','--');
plot(TaskFitData.curve(:,1),TaskCI,'Color',[1 0.7 0.2],'linewidth',1.2,'linestyle','--');
plot(PassFitData.curve(:,1),PassCI,'Color','k','linewidth',1.2,'linestyle','--');

set(gca,'xtick',[0,1,2],'xticklabel',[8 16 32],'ytick',[0 0.5 1],'xlim',[-0.1 2.1],'ylim',[-0.1 1.1]);
xlabel('Frequency(kHz)');
ylabel('Right Prob');
set(gca,'FontSize',14);
saveas(hf,'SVM neurometric curve plot save');
saveas(hf,'SVM neurometric curve plot save','pdf');
%% category index compare plot
BehavFitAll = cell(nUsedSess,1);
TaskFitAll = cell(nUsedSess,1);
% PassFitAll = cell(nUsedSess,1);

for cSess = 1 : nUsedSess
    cSessBehavTone = UsedSVMNeuTaskSum{cSess,1};
    cSessBehavRProb = UsedSVMNeuTaskSum{cSess,2};
    cSessTaskRProb = UsedSVMNeuTaskSum{cSess,3};
    
    cBehavFit = FitPsycheCurveWH_nx(cSessBehavTone,cSessBehavRProb);
    cTaskFit = FitPsycheCurveWH_nx(cSessBehavTone,cSessTaskRProb);
    
%     cSessPassTone = UsedSVMNeuTaskSum{cSess,5};
%     cSessPassRProb = UsedSVMNeuTaskSum{cSess,4};
%     cPassFit = FitPsycheCurveWH_nx(cSessPassTone,cSessPassRProb);
    
    BehavFitAll{cSess} = cBehavFit.ffit;
    TaskFitAll{cSess} = cTaskFit.ffit;
%     PassFitAll{cSess} = cPassFit.ffit;
    
end

%%
BehavBoundAll = cellfun(@(x) x.u,BehavFitAll);
TaskBoundAll = cellfun(@(x) x.u,TaskFitAll);
% PassBoundAll = cellfun(@(x) x.u,PassFitAll);

BehavBound = BehavBoundAll;
TaskNor2behvBound = TaskBoundAll;
% PassNor2behvBound = PassBoundAll;
[TaskR,TaskIndex_p] = corrcoef(BehavBound,TaskNor2behvBound);
% [PassR,PassIndex_p] = corrcoef(BehavBound,PassNor2behvBound);
[Taskmd,TaskCurve] = lmFunCalPlot(BehavBound,TaskNor2behvBound,0);
% [Passmd,PassCurve] = lmFunCalPlot(BehavBound,PassNor2behvBound,0);
hhf = figure('position',[2400 100 420 350]);
hold on
Cir1 = plot(BehavBound,TaskNor2behvBound,'o','MarkerSize',9,'Linewidth',2,'Color',[1 0.7 0.2]);
% Cir2 = plot(BehavBound,PassNor2behvBound,'ko','MarkerSize',9,'Linewidth',2);
plot(TaskCurve(:,1),TaskCurve(:,2),'Color',[0.6 0.4 0.1],'linewidth',1.8);
% plot(PassCurve(:,1),PassCurve(:,2),'Color',[0.2 0.2 0.2],'linewidth',1.8);
yscales = get(gca,'ylim');
xscales = get(gca,'xlim');
CommonScale = [xscales;yscales];
UsedScales = [min(CommonScale(:,1)),max(CommonScale(:,2))];
% line(UsedScales,UsedScales,'Color',[.7 .7 .7],'linewidth',1.6,'linestyle','--');
line([1 1],UsedScales,'Color',[.7 .7 .7],'linewidth',1.6,'linestyle','--');
line(UsedScales,[1 1],'Color',[.7 .7 .7],'linewidth',1.6,'linestyle','--');
set(gca,'xtick',[0.5 1 1.5],'ytick',[0.5 1 1.5],'xlim',[0.4 1.6],'ylim',[0.4 1.6]);  % 'xlim',[0 1],'ylim',[0 1],
xlabel('Behaviior bound');
ylabel('Boundary (Task)');
set(gca,'FontSize',16)
% LegH = legend([Cir1,Cir2],{sprintf('Task Coef %.4f, p=%.2e',TaskR(1,2),TaskIndex_p(1,2)),...
%     sprintf('Pass Coef %.4f,p=%.2e',PassR(1,2),PassIndex_p(1,2))},...
%     'FontSize',8,'Location','Northwest','TextColor','r','Box','off','Autoupdate','off');
% legend('boxoff');
% set(LegH,'position',get(LegH,'position')+[-0.1 0 0 0]);
% title(sprintf('Behavior Bound %.4f-%.4f',mean(BehavBound),std(BehavBound)));
title('Boundary correlation analysis');
saveas(gcf,'SVM neurometric curve boundary compare plot Task');
saveas(gcf,'SVM neurometric curve boundary compare plot Task','pdf');
%% Category index plot
CISumAll = zeros(nUsedSess,3);
for cSess = 1 : nUsedSess
    cSessBehav = UsedSessBehav(cSess,:);
    cSessTask = UsedSessTaskRProb(cSess,:);
    cSessPass = UsedSessPassRProb(cSess,:);
    CISumAll(cSess,1) = (mean(cSessBehav(4:6)) - mean(cSessBehav(1:3)));%/(mean(cSessBehav(4:6)) + mean(cSessBehav(1:3)));
    CISumAll(cSess,2) = (mean(cSessTask(4:6)) - mean(cSessTask(1:3)));%/(mean(cSessTask(4:6)) + mean(cSessTask(1:3))); 
    CISumAll(cSess,3) = (mean(cSessPass(4:6)) - mean(cSessPass(1:3)));%/(mean(cSessPass(4:6)) + mean(cSessPass(1:3))); 
end
BehavCI = CISumAll(:,1);
TaskIndexCI = CISumAll(:,2);
PassIndexCI = CISumAll(:,3);
[~,TaskIndex_p] = ttest(BehavCI,TaskIndexCI);
[~,PassIndex_p] = ttest(BehavCI,PassIndexCI);
hhf = figure('position',[2600 100 420 350]);
hold on
Cir1 = plot(BehavCI,TaskIndexCI,'bo','MarkerSize',9,'Linewidth',2);
Cir2 = plot(BehavCI,PassIndexCI,'ko','MarkerSize',9,'Linewidth',2);
line([0 1],[0 1],'Color',[.7 .7 .7],'linewidth',1.6,'linestyle','--');
line([0 0.5],[0.5 0.5],'Color',[.7 .7 .7],'linewidth',1.6,'linestyle','--');
line([0.5 0.5],[0 0.5],'Color',[.7 .7 .7],'linewidth',1.6,'linestyle','--');
set(gca,'xlim',[0 1],'ylim',[0 1],'xtick',[0 0.5 1],'ytick',[0 0.5 1]);
xlabel('Behav CI');
ylabel({'TaskIndexCI';'PassIndexCI'});
set(gca,'FontSize',16)
LegH = legend([Cir1,Cir2],{sprintf('%.4f-%.4f,p=%.2e',mean(TaskIndexCI),std(TaskIndexCI),TaskIndex_p),...
    sprintf('%.4f-%.4f,p=%.2e',mean(PassIndexCI),std(PassIndexCI),PassIndex_p)},...
    'FontSize',8,'Location','Southwest','TextColor','r','Box','off');
% legend('boxoff');
set(LegH,'position',get(LegH,'position')+[-0.1 0 0 0]);
title('Category Index');
saveas(gcf,'SVM neurometric curve CI plot');
saveas(gcf,'SVM neurometric curve CI plot','pdf');