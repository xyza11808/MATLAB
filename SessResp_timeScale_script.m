clear
clc
cd('E:\DataToGo\data_for_xu\Tuning_curve_plot');
[fn,fp,~] = uigetfile('*.txt','Please select the text file contains the path of all task sessions');
[Passfn,Passfp,~] = uigetfile('*.txt','Please select the text file contains the path of all passive sessions');
% load('E:\DataToGo\data_for_xu\SingleCell_RespType_summary\NewMethod\SessROItypeData.mat');
% cd('E:\DataToGo\data_for_xu\CategDataSummary');
%%
fpath = fullfile(fp,fn);

ff = fopen(fpath);
tline = fgetl(ff);
Passid = fopen(fullfile(Passfp,Passfn));
Passline = fgetl(Passid);

nSess = 1;
SessDataRespAll = {};
PassSessDataRespAll = {};

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(ff);
        Passline = fgetl(Passid);
        continue;
    end
    cSessDataPath = (fullfile(tline,'CSessionData.mat'));
    cd(tline);
    
    clearvars data_aligned start_frame frame_rate 
    load(cSessDataPath);
    cSessData = SessionSumColorplot(data_aligned,start_frame,trial_outcome,behavResults.Stim_toneFreq,frame_rate,0,1);
    
    SessDataRespAll{nSess,1} = cSessData;
    SessDataRespAll{nSess,2} = start_frame;
    SessDataRespAll{nSess,3} = frame_rate;
    
    % extract passive data plots
    clearvars SelectData SelectSArray frame_rate
    cd(Passline);
    PassSessPath = fullfile(Passline,'rfSelectDataSet.mat');
    load(PassSessPath);
    TrOucome = ones(size(SelectData,1),1);
    if size(SelectData,2) ~= size(data_aligned,2)
        UsedPassData = SelectData(:,1:size(data_aligned,2),:);
    else
        UsedPassData = SelectData;
    end
    cPassData = SessionSumColorplot(UsedPassData,frame_rate,TrOucome,SelectSArray,frame_rate,0,1);
    
    PassSessDataRespAll{nSess,1} = cPassData;
    PassSessDataRespAll{nSess,2} = frame_rate;
    
    tline = fgetl(ff);
    Passline = fgetl(Passid);
    nSess = nSess + 1;
end
% cd('E:\DataToGo\data_for_xu\SessRespSummaryData');
% save SessDataSave.mat SessDataRespAll PassSessDataRespAll -v7.3
%%
UsedSess = 1:19;
SessCellDataAll = cellfun(@(x) x.NorData,SessDataRespAll(:,1),'uniformOutput',false);
NormDataAll = SessCellDataAll(UsedSess);
SessDataFrames = cellfun(@(x) size(x,2),NormDataAll);
UsedFInds = min(SessDataFrames);
fRate = SessDataRespAll{UsedSess(1),3};

PassSessCellAll = cellfun(@(x) x.NorData,PassSessDataRespAll(:,1),'uniformOutput',false);
PassDataCell = PassSessCellAll(UsedSess);

SessDataFrames = cellfun(@(x) size(x,2),PassDataCell);
UsedFPass = min(SessDataFrames);

PassSessData = [];
SessDataAlls = [];
for cSess = 1 : length(NormDataAll)
    cSessData = NormDataAll{cSess}(:,1:UsedFInds);
    SessDataAlls = [SessDataAlls;cSessData];
    
    cPassData = PassDataCell{cSess}(:,1:UsedFPass);
    PassSessData = [PassSessData;cPassData];
end
%%
UsedSess = 20:21;
% UsedFrameRange = 1:155;
% SessCellDataAll = cellfun(@(x) zscore(x.RawData(:,UsedFrameRange),0,2),SessDataRespAll(:,1),'uniformOutput',false);
SessCellDataAll = cellfun(@(x) x.NorData,SessDataRespAll(:,1),'uniformOutput',false);
NormDataAll = SessCellDataAll(UsedSess);
SessDataFrames = cellfun(@(x) size(x,2),NormDataAll);
UsedFInds = min(SessDataFrames);
fRate = SessDataRespAll{UsedSess(1),3};

PassSessCellAll = cellfun(@(x) x.NorData,PassSessDataRespAll(:,1),'uniformOutput',false);
PassDataCell = PassSessCellAll(UsedSess);

SessDataFrames = cellfun(@(x) size(x,2),PassDataCell);
UsedFPass = min(SessDataFrames);

PassSessData = [];
SessDataAlls = [];
for cSess = 1 : length(NormDataAll)
    cSessData = NormDataAll{cSess}(:,1:UsedFInds);
    SessDataAlls = [SessDataAlls;cSessData];
    
    cPassData = PassDataCell{cSess}(:,1:UsedFPass);
    PassSessData = [PassSessData;cPassData];
end

%%
[~,MaxInds] = max(SessDataAlls,[],2);
[~,Inds] = sort(MaxInds);
huf = figure('position',[100 100 600 320]);
subplot(121)
imagesc(SessDataAlls(Inds,:),[0,2])
colormap hot
FramePatch = round([1,1.3]*fRate);
nCells = size(SessDataAlls,1);
patch([FramePatch(1) FramePatch(2) FramePatch(2) FramePatch(1)],[0 0 nCells nCells]+0.5, 1, 'FaceColor','g',...
    'EdgeColor','none','Facealpha',0.4)
xTimeTick = 0:fRate:size(SessDataAlls,2);
xTickLabels = xTimeTick/fRate;
set(gca,'xtick',xTimeTick,'xTicklabel',xTickLabels);
hbar = colorbar;
cPos = get(hbar,'position');
set(hbar,'YTick',[0 2],'position',cPos.*[1 1 0.5 0.3]+[0.1 0.03 0 0]);

title(sprintf('nROIs = %d',size(SessDataAlls,1)));

subplot(122)
imagesc(PassSessData(Inds,:),[0,2])
colormap hot
FramePatch = round([1,1.3]*fRate);
nCells = size(PassSessData,1);
patch([FramePatch(1) FramePatch(2) FramePatch(2) FramePatch(1)],[0 0 nCells nCells]+0.5, 1, 'FaceColor','g',...
    'EdgeColor','none','Facealpha',0.4)
xTimeTick = 0:fRate:size(PassSessData,2);
xTickLabels = xTimeTick/fRate;
set(gca,'xtick',xTimeTick,'xTicklabel',xTickLabels);
hbar = colorbar;
cPos = get(hbar,'position');
set(hbar,'YTick',[0 2],'position',cPos.*[1 1 0.5 0.3]+[0.1 0.03 0 0]);
title(sprintf('nROIs = %d',size(PassSessData,1)));
%%
saveas(huf,'Sess Summarized Response plot');
saveas(huf,'Sess Summarized Response plot','png');
saveas(huf,'Sess Summarized Response plot','pdf');

%% 
load('E:\DataToGo\data_for_xu\BoundTun_DataSave\AmpCompare\NearBAmpAll.mat');
SumDataInds = false(size(SessDataRespAll,1),1);
SumDataInds(1:19) = true;
UsedSess = cellfun(@(x) ~isempty(x),PassBFRespAmpAll(:,1)) & SumDataInds;
UsedPassBFAmp = (cell2mat(PassBFRespAmpAll(UsedSess,1)'))';
UsedPassBFTaskAmp = cell2mat(PassBFRespAmpAll(UsedSess,2));
PassComSigAll = cell2mat(PassBFRespAmpAll(UsedSess,3));

PassSessDataUsed = [];
SessDataUsed = [];
for cSess = 1 : length(SessCellDataAll)
    if UsedSess(cSess)
        cSessData = SessCellDataAll{cSess}(:,1:UsedFInds);
        SessDataUsed = [SessDataUsed;cSessData];

        cPassData = PassSessCellAll{cSess}(:,1:UsedFPass);
        PassSessDataUsed = [PassSessDataUsed;cPassData];
    end
end

% save TypeDataRespSummary.mat UsedPassBFAmp UsedPassBFTaskAmp PassComSigAll SessDataUsed PassSessDataUsed -v7.3

%% plot final results
SigLevel = 0.05;
PassSurpInds = UsedPassBFAmp > UsedPassBFTaskAmp & PassComSigAll < SigLevel;
PassEnhanInds = UsedPassBFAmp < UsedPassBFTaskAmp & PassComSigAll < SigLevel;


PassSurpTaskResp = SessDataUsed(PassSurpInds,:);
PassSurpPassResp = PassSessDataUsed(PassSurpInds,:);
PassEnhanTaskResp = SessDataUsed(PassEnhanInds,:);
PassEnhanPassResp = PassSessDataUsed(PassEnhanInds,:);

[~,SurMaxInds] = max(PassSurpTaskResp,[],2);
[~,EnhMaxInds] = max(PassEnhanTaskResp,[],2);
[~,SurTrInds] = sort(SurMaxInds);
[~,EnhTrInds] = sort(EnhMaxInds);

FramePatch = round([1,1.3]*55);

hTypef = figure('position',[2000 100 600 540]);
subplot(221)
imagesc(PassSurpTaskResp(SurTrInds,:),[0 2]);
colormap hot
nCells = size(PassSurpTaskResp,1);
patch([FramePatch(1) FramePatch(2) FramePatch(2) FramePatch(1)],[0 0 nCells nCells]+0.5, 1, 'FaceColor','g',...
    'EdgeColor','none','Facealpha',0.4)
xTimeTick = 0:55:size(PassSurpTaskResp,2);
xTickLabels = xTimeTick/55;
set(gca,'xtick',xTimeTick,'xTicklabel',xTickLabels);
title('Surpress / Task')

subplot(222)
imagesc(PassSurpPassResp(SurTrInds,:),[0 2]);
colormap hot
nCells = size(PassSurpPassResp,1);
patch([FramePatch(1) FramePatch(2) FramePatch(2) FramePatch(1)],[0 0 nCells nCells]+0.5, 1, 'FaceColor','g',...
    'EdgeColor','none','Facealpha',0.4)
xTimeTick = 0:55:size(PassSurpPassResp,2);
xTickLabels = xTimeTick/55;
set(gca,'xtick',xTimeTick,'xTicklabel',xTickLabels);
title('Surpress / Pass')

subplot(223)
imagesc(PassEnhanTaskResp(EnhTrInds,:),[0 2]);
colormap hot
nCells = size(PassEnhanTaskResp,1);
patch([FramePatch(1) FramePatch(2) FramePatch(2) FramePatch(1)],[0 0 nCells nCells]+0.5, 1, 'FaceColor','g',...
    'EdgeColor','none','Facealpha',0.4)
xTimeTick = 0:55:size(PassEnhanTaskResp,2);
xTickLabels = xTimeTick/55;
set(gca,'xtick',xTimeTick,'xTicklabel',xTickLabels);
title('Enhance / Task')

subplot(224)
imagesc(PassEnhanPassResp(EnhTrInds,:),[0 2]);
colormap hot
nCells = size(PassEnhanPassResp,1);
patch([FramePatch(1) FramePatch(2) FramePatch(2) FramePatch(1)],[0 0 nCells nCells]+0.5, 1, 'FaceColor','g',...
    'EdgeColor','none','Facealpha',0.4)
xTimeTick = 0:55:size(PassEnhanPassResp,2);
xTickLabels = xTimeTick/55;
set(gca,'xtick',xTimeTick,'xTicklabel',xTickLabels);
title('Enhance / Pass')

hbar = colorbar;
cPos = get(hbar,'position');
set(hbar,'YTick',[0 2],'position',cPos.*[1 1 0.5 0.3]+[0.1 0.03 0 0]);
%
saveas(hTypef,'PassAmp modu TypeResp compare plot');
saveas(hTypef,'PassAmp modu TypeResp compare plot','png');
saveas(hTypef,'PassAmp modu TypeResp compare plot','pdf');

%% ##################################################################################
%% New plots above
%% nre compare plot using same mean and variance for normalization
% load('E:\DataToGo\data_for_xu\BoundTun_DataSave\AmpCompare\NearBAmpAll.mat');
UsedSess = 1:19;
SessCellDataAll = cellfun(@(x) x.RawData,SessDataRespAll(:,1),'uniformOutput',false);
NormDataAll = SessCellDataAll(UsedSess);
SessDataFrames = cellfun(@(x) size(x,2),NormDataAll);
UsedFInds = min(SessDataFrames);

PassSessCellAll = cellfun(@(x) x.RawData,PassSessDataRespAll(:,1),'uniformOutput',false);
PassDataCell = PassSessCellAll(UsedSess);

SessDataFrames = cellfun(@(x) size(x,2),PassDataCell);
UsedFPass = min(SessDataFrames);

PassSessData = [];
SessDataAlls = [];
for cSess = 1 : length(NormDataAll)
    cSessData = NormDataAll{cSess}(:,1:UsedFInds);
    SessDataAlls = [SessDataAlls;cSessData];
    
    cPassData = PassDataCell{cSess}(:,1:UsedFPass);
    PassSessData = [PassSessData;cPassData];
end

TaskFrames = size(SessDataAlls,2);
AllDataMerges = [SessDataAlls,PassSessData];
AllNormData = (zscore(AllDataMerges'))';
%%
TaskAllNormData = AllNormData(:,1:TaskFrames);
PassAllNormData = AllNormData(:,(1+TaskFrames):end);
[~,MaxInds] = max(TaskAllNormData,[],2);
[~,SortInds] = sort(MaxInds);

huf = figure('position',[100 100 600 320]);
subplot(121)
imagesc(TaskAllNormData(SortInds,:),[0,2])
colormap hot
FramePatch = round([1,1.3]*55);
nCells = size(TaskAllNormData,1);
patch([FramePatch(1) FramePatch(2) FramePatch(2) FramePatch(1)],[0 0 nCells nCells]+0.5, 1, 'FaceColor','g',...
    'EdgeColor','none','Facealpha',0.4)
xTimeTick = 0:55:size(TaskAllNormData,2);
xTickLabels = xTimeTick/55;
set(gca,'xtick',xTimeTick,'xTicklabel',xTickLabels);
hbar = colorbar;
cPos = get(hbar,'position');
set(hbar,'YTick',[0 2],'position',cPos.*[1 1 0.5 0.3]+[0.1 0.03 0 0]);

title(sprintf('nROIs = %d',size(TaskAllNormData,1)));

subplot(122)
imagesc(PassAllNormData(SortInds,:),[0,2])
colormap hot
FramePatch = round([1,1.3]*55);
nCells = size(PassAllNormData,1);
patch([FramePatch(1) FramePatch(2) FramePatch(2) FramePatch(1)],[0 0 nCells nCells]+0.5, 1, 'FaceColor','g',...
    'EdgeColor','none','Facealpha',0.4)
xTimeTick = 0:55:size(PassAllNormData,2);
xTickLabels = xTimeTick/55;
set(gca,'xtick',xTimeTick,'xTicklabel',xTickLabels);
hbar = colorbar;
cPos = get(hbar,'position');
set(hbar,'YTick',[0 2],'position',cPos.*[1 1 0.5 0.3]+[0.1 0.03 0 0]);
title(sprintf('nROIs = %d',size(PassAllNormData,1)));

saveas(huf,'Sess Summarized Response NewNor plot');
saveas(huf,'Sess Summarized Response NewNor plot','png');
saveas(huf,'Sess Summarized Response NewNor plot','pdf');

%% Sep plot using new normalizeation method
load('E:\DataToGo\data_for_xu\BoundTun_DataSave\AmpCompare\NearBAmpAll.mat');
SumDataInds = false(size(SessDataRespAll,1),1);
SumDataInds(1:19) = true;
EmpInds = cellfun(@(x) ~isempty(x),PassBFRespAmpAll(:,1));
UsedSess = EmpInds & SumDataInds;
cEmpInds = EmpInds(SumDataInds);
FrameSessNum = cellfun(@(x) size(x,1),NormDataAll);
CumSumFInds = cumsum(FrameSessNum);
BFUsedInds = true(size(TaskAllNormData,1),1);
for cSess = 1 : length(cEmpInds)
    if ~cEmpInds(cSess)
        if cSess == 1
            FrameInds = 1 : CumSumFInds(1);
        else
            FrameInds = CumSumFInds(cSess-1)+1 : CumSumFInds(cSess);
        end
        BFUsedInds(FrameInds) = false;
    end
end
TaskUsedNorData = TaskAllNormData(BFUsedInds,:);
PassusedNorData = PassAllNormData(BFUsedInds,:);

UsedPassBFAmp = (cell2mat(PassBFRespAmpAll(UsedSess,1)'))';
UsedPassBFTaskAmp = cell2mat(PassBFRespAmpAll(UsedSess,2));
PassComSigAll = cell2mat(PassBFRespAmpAll(UsedSess,3));

SigLevel = 0.05;
PassSurpInds = UsedPassBFAmp > UsedPassBFTaskAmp & PassComSigAll < SigLevel;
PassEnhanInds = UsedPassBFAmp < UsedPassBFTaskAmp & PassComSigAll < SigLevel;

PassSurpTaskResp = TaskUsedNorData(PassSurpInds,:);
PassSurpPassResp = PassusedNorData(PassSurpInds,:);
PassEnhanTaskResp = TaskUsedNorData(PassEnhanInds,:);
PassEnhanPassResp = PassusedNorData(PassEnhanInds,:);

[~,SurMaxInds] = max(PassSurpTaskResp,[],2);
[~,EnhMaxInds] = max(PassEnhanTaskResp,[],2);
[~,SurTrInds] = sort(SurMaxInds);
[~,EnhTrInds] = sort(EnhMaxInds);

FramePatch = round([1,1.3]*55);

hTypef = figure('position',[2000 100 600 540]);
subplot(221)
imagesc(PassSurpTaskResp(SurTrInds,:),[0 2]);
colormap hot
nCells = size(PassSurpTaskResp,1);
patch([FramePatch(1) FramePatch(2) FramePatch(2) FramePatch(1)],[0 0 nCells nCells]+0.5, 1, 'FaceColor','g',...
    'EdgeColor','none','Facealpha',0.4)
xTimeTick = 0:55:size(PassSurpTaskResp,2);
xTickLabels = xTimeTick/55;
set(gca,'xtick',xTimeTick,'xTicklabel',xTickLabels);
title('Surpress / Task')

subplot(222)
imagesc(PassSurpPassResp(SurTrInds,:),[0 2]);
colormap hot
nCells = size(PassSurpPassResp,1);
patch([FramePatch(1) FramePatch(2) FramePatch(2) FramePatch(1)],[0 0 nCells nCells]+0.5, 1, 'FaceColor','g',...
    'EdgeColor','none','Facealpha',0.4)
xTimeTick = 0:55:size(PassSurpPassResp,2);
xTickLabels = xTimeTick/55;
set(gca,'xtick',xTimeTick,'xTicklabel',xTickLabels);
title('Surpress / Pass')

subplot(223)
imagesc(PassEnhanTaskResp(EnhTrInds,:),[0 2]);
colormap hot
nCells = size(PassEnhanTaskResp,1);
patch([FramePatch(1) FramePatch(2) FramePatch(2) FramePatch(1)],[0 0 nCells nCells]+0.5, 1, 'FaceColor','g',...
    'EdgeColor','none','Facealpha',0.4)
xTimeTick = 0:55:size(PassEnhanTaskResp,2);
xTickLabels = xTimeTick/55;
set(gca,'xtick',xTimeTick,'xTicklabel',xTickLabels);
title('Enhance / Task')

subplot(224)
imagesc(PassEnhanPassResp(EnhTrInds,:),[0 2]);
colormap hot
nCells = size(PassEnhanPassResp,1);
patch([FramePatch(1) FramePatch(2) FramePatch(2) FramePatch(1)],[0 0 nCells nCells]+0.5, 1, 'FaceColor','g',...
    'EdgeColor','none','Facealpha',0.4)
xTimeTick = 0:55:size(PassEnhanPassResp,2);
xTickLabels = xTimeTick/55;
set(gca,'xtick',xTimeTick,'xTicklabel',xTickLabels);
title('Enhance / Pass')

hbar = colorbar;
cPos = get(hbar,'position');
set(hbar,'YTick',[0 2],'position',cPos.*[1 1 0.5 0.3]+[0.1 0.03 0 0]);

saveas(hTypef,'PassAmp modu TypeResp compare NewNor plot');
saveas(hTypef,'PassAmp modu TypeResp compare NewNor plot','png');
saveas(hTypef,'PassAmp modu TypeResp compare NewNor plot','pdf');
