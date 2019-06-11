clear
clc
cd('E:\DataToGo\data_for_xu\Tuning_curve_plot');
[fn,fp,~] = uigetfile('*.txt','Please select the text file contains the path of all task sessions');
% [Passfn,Passfp,~] = uigetfile('*.txt','Please select the text file contains the path of all passive sessions');
load('E:\DataToGo\data_for_xu\SingleCell_RespType_summary\NewMethod\SessROItypeData.mat');
cd('E:\DataToGo\data_for_xu\CategDataSummary');
%%
clearvars -except fn fp BoundTunROIindex
fpath = fullfile(fp,fn);
% PassFid = fopen(fullfile(Passfp,Passfn));

ff = fopen(fpath);
tline = fgetl(ff);
% PassLine = fgetl(PassFid);
cSess = 1;
SessBoundTunCorr = {};
% ROICoefAll = {};
% ROIPvalueAll = {};
SessPassBoundData = {};
%
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
       tline = fgetl(ff);
%        PassLine = fgetl(PassFid);
        continue;
    end
    %%
    BehavDatas = load(fullfile(tline,'RandP_data_plots','boundary_result.mat'));
    BehavCorr = BehavDatas.boundary_result.StimCorr;
    GroupStimsNum = floor(length(BehavCorr)/2);
    BehavOctaves = log2(double(BehavDatas.boundary_result.StimType)/16000);
    FreqStrs = cellstr(num2str(BehavDatas.boundary_result.StimType(:)/1000,'%.1f'));
    FitoctaveData = BehavCorr;
    FitoctaveData(1:GroupStimsNum) = 1 - FitoctaveData(1:GroupStimsNum);
    FFun = @(g,l,u,v,x) g+(1-g-l)*0.5*(1+erf((x-u)/sqrt(2*v^2)));
    fit_ReNew = FitPsycheCurveWH_nx(BehavOctaves, FitoctaveData);
    syms xx
    FitBehavFunc = FFun(fit_ReNew.ffit.g,fit_ReNew.ffit.l,fit_ReNew.ffit.u,fit_ReNew.ffit.v,xx);
    DerivativeFun = diff(FitBehavFunc,xx);
    DeriveValue = double(subs(DerivativeFun,BehavOctaves));
    DeriveValueNor = DeriveValue/max(DeriveValue);
    %%
    TuningDataPath = fullfile(tline,'Tunning_fun_plot_New1s','TunningDataSave.mat');
    TunData = load(TuningDataPath);
    
    cBoundTunROIInds = BoundTunROIindex{cSess,1};
    TunROIData = TunData.CorrTunningFun(:,cBoundTunROIInds);
    PassOctave = TunData.PassFreqOctave;
    WithinBoundInds = abs(PassOctave) < 1.1;
    WBPassOct = PassOctave(WithinBoundInds);
    WBPassData = TunData.PassTunningfun(WithinBoundInds,:);
    %%
    disp(TunData.TaskFreqOctave);
    disp(WBPassOct');
    UsedIndsTr = input('Please select pass octave used inds:\n','s');
    UsedInds = str2num(UsedIndsTr);
    if ~isempty(UsedInds)
        UsedPassData = WBPassData(UsedInds,:);
        UsedPassOct = WBPassOct(UsedInds,:);
    else
        tline = fgetl(ff);
        cSess = cSess + 1;
%         continue;
    end
    %%
    PassOctSlope = double(subs(DerivativeFun,UsedPassOct));
    PassOctSlopeNor = PassOctSlope / max(PassOctSlope);
    %
    if ~isempty(TunROIData)
%         DataForCorr = [TunROIData,DeriveValue(:)];
%         [r,p] = corrcoef(DataForCorr);
        [OctNum,ROINum] = size(TunROIData);
        OctMtx = repmat(DeriveValueNor(:),1,ROINum);
        SessBoundTunCorr{cSess,1} = TunROIData;
        SessBoundTunCorr{cSess,2} = OctMtx;
        SessBoundTunCorr{cSess,3} = DeriveValue;
        %Normalize Response value to [0 1]
        MinBaseData = repmat(min(TunROIData),OctNum,1);
        MinMaxDiff = repmat(max(TunROIData) - min(TunROIData),OctNum,1);
        Norm01Data = (TunROIData - MinBaseData)./MinMaxDiff;
        SessBoundTunCorr{cSess,4} = Norm01Data;
        [~,SlopeMaxInds] = max(OctMtx);
        ObNormInds = zeros(length(SlopeMaxInds),1);
        for nLen = 1 : length(SlopeMaxInds)
            if Norm01Data(SlopeMaxInds(nLen),nLen) < 0.5
                ObNormInds(nLen) = 1;
            end
        end
        SessBoundTunCorr{cSess,5} = ObNormInds;
        SessBoundTunCorr{cSess,6} = cBoundTunROIInds;
                
%         ROICoefAll{cSess} = r;
%         ROIPvalueAll{cSess} = p;
        SessPassBoundData{cSess,1} = UsedPassData(:,cBoundTunROIInds);
        PassOctMtx = repmat(PassOctSlopeNor(:),1,ROINum);
        PassOctNum = length(PassOctSlopeNor);
        SessPassBoundData{cSess,2} = PassOctMtx;
        SessPassBoundData{cSess,3} = PassOctSlope;
        % normalize to [0 1]
        PassMinBase = repmat(min(SessPassBoundData{cSess,1}),PassOctNum,1);
        PassMinMax = repmat(max(SessPassBoundData{cSess,1}) - min(SessPassBoundData{cSess,1}),PassOctNum,1);
        PassNorm01Data = (SessPassBoundData{cSess,1} - PassMinBase)./PassMinMax;
        SessPassBoundData{cSess,4} = PassNorm01Data;
    end
    %
    tline = fgetl(ff);
    cSess = cSess + 1;
end
cd('E:\DataToGo\data_for_xu\BoundTun_DataSave\TunValueSlopeVCoef');
% save BoundTunCoefAll.mat SessBoundTunCorr ROICoefAll ROIPvalueAll -v7.3
save BoundTunDataSlopeAll.mat SessBoundTunCorr SessPassBoundData -v7.3
%% extract the correlation data
EmptyInds = cellfun(@isempty,SessBoundTunCorr);
NECellDatas = SessBoundTunCorr(~EmptyInds);
NEROICoefAll = ROICoefAll(~EmptyInds);
NEROIPvalueAll = ROIPvalueAll(~EmptyInds);

NEROICoefVecCell = cellfun(@(x) x(1:end-1,end),NEROICoefAll,'UniformOutput',false);
NEROICoefpVecCell = cellfun(@(x) x(1:end-1,end),NEROIPvalueAll,'UniformOutput',false);
NEROICoefVecCell = NEROICoefVecCell';
NEROICoefpVecCell = NEROICoefpVecCell';
NEROICoefVecAll = cell2mat(NEROICoefVecCell);
NEROICoefpVecAll = cell2mat(NEROICoefpVecCell);
%%
figure
hBins = histogram(NEROICoefVecAll,25,'Visible','off');
SigData = NEROICoefVecAll(NEROICoefpVecAll<0.05);
figure
SigBins = histogram(SigData,hBins.BinEdges,'Visible','off');
BinCenters = (hBins.BinEdges(1:end-1) + hBins.BinEdges(2:end))/2;
hf = figure;
hold on
hb1 = bar(BinCenters,hBins.Values,0.8,'FaceColor',[.7 .7 .7],'EdgeColor','none');
hb2 = bar(BinCenters,SigBins.Values,0.8,'FaceColor','k','EdgeColor','none');
legend([hb1,hb2],{sprintf('Avg = %.3f',mean(NEROICoefVecAll)),sprintf('p<0.05, Avg = %.3f',mean(SigData))},...
    'Box','off','Location','NorthWest');
xlabel('Coefficient');
ylabel('Counts');
set(gca,'FontSize',16);
% saveas(hf,'BoundTun activity with slopeV coef');
% saveas(hf,'BoundTun activity with slopeV coef','png');
% saveas(hf,'BoundTun activity with slopeV coef','pdf');
%% activity corr with slope value
% SessBoundTunAct = cellfun(@(x) reshape((zscore(x))',[],1),SessBoundTunCorr,'uniformoutput',false);
% SessPassCell = cellfun(@(x) reshape((zscore(x))',[],1),SessPassBoundData,'uniformoutput',false);
SessTaskDataAll = cell2mat(cellfun(@(x) reshape((zscore(x))',[],1),SessBoundTunCorr(:,1),'uniformoutput',false));
SessTaskSlopeAll = cell2mat(cellfun(@(x) reshape((x)',[],1),SessBoundTunCorr(:,2),'uniformoutput',false));
SessPassDataAll = cell2mat(cellfun(@(x) reshape((zscore(x))',[],1),SessPassBoundData(:,1),'uniformoutput',false));
SessPassSlopeAll = cell2mat(cellfun(@(x) reshape((x)',[],1),SessPassBoundData(:,2),'uniformoutput',false));

[Taskr,Taskp] = corrcoef(SessTaskSlopeAll,SessTaskDataAll);
[Passr,Passp] = corrcoef(SessPassSlopeAll,SessPassDataAll);

BinsEdge = linspace(0,1,9);
nBins = length(BinsEdge)-1;
BinCent = (BinsEdge(1:end-1) + BinsEdge(2:end))/2;
TaskDataBins = zeros(nBins,3);
PassDataBins = zeros(nBins,3);
for cBin = 1 : nBins
    if cBin == 0
        cBinInds = SessTaskSlopeAll >= 0 & SessTaskSlopeAll <=  BinsEdge(cBin+1);
        cPassInds = SessPassSlopeAll >= 0 & SessPassSlopeAll <=  BinsEdge(cBin+1);
    else
        cBinInds = SessTaskSlopeAll > BinsEdge(cBin) & SessTaskSlopeAll <=  BinsEdge(cBin+1);
        cPassInds = SessPassSlopeAll > BinsEdge(cBin) & SessPassSlopeAll <=  BinsEdge(cBin+1);
    end
    cBinDatas = SessTaskDataAll(cBinInds);
    cBinPassData = SessPassDataAll(cPassInds);
    if ~isempty(cBinDatas)
        cBinDataAvg = mean(cBinDatas);
        cBinDataSem = std(cBinDatas)/numel(cBinDatas)*10;
        TaskDataBins(cBin,:) = [cBinDataAvg,cBinDataSem,1];
    end
    if ~isempty(cBinPassData)
        cPassAvg = mean(cBinPassData);
        cPassSem = std(cBinPassData)/numel(cBinPassData)*10;
        PassDataBins(cBin,:) = [cPassAvg,cPassSem,1];
    end
end
%
TaskNZDatas = TaskDataBins(logical(TaskDataBins(:,3)),1:2);
TaskNZSlopeInds = BinCent(logical(TaskDataBins(:,3)));
PassNZDatas = PassDataBins(logical(PassDataBins(:,3)),1:2);
PassNZSlopeInds = BinCent(logical(PassDataBins(:,3)));
hhhf = figure('position',[100 400 700 260]);
subplot(121)
hold on
scatter(SessTaskSlopeAll,SessTaskDataAll,6,'o','MarkerFaceColor',[1 0.8 0.6],'MarkerEdgeColor','none');
el1 = errorbar(TaskNZSlopeInds,TaskNZDatas(:,1),TaskNZDatas(:,2),'-o','Color',[1 0.7 0.2],'linewidth',3);
set(gca,'xtick',0:0.5:1,'box','off','xlim',[-0.05 1.05]);
xlabel('Distance to boundary');
ylabel('Response');
title(sprintf('Task,Coef %.3f, p %.3e',Taskr(2,1),Taskp(2,1)));
set(gca,'FontSize',12);

subplot(122)
hold on
scatter(SessPassSlopeAll,SessPassDataAll,6,'o','MarkerFaceColor',[.8 .8 .8],'MarkerEdgeColor','none');
el2 = errorbar(PassNZSlopeInds,PassNZDatas(:,1),PassNZDatas(:,2),'-o','Color','k','linewidth',3);
set(gca,'xtick',0:0.5:1,'box','off','xlim',[-0.05 1.05]);
xlabel('Distance to boundary');
ylabel('Response');
title(sprintf('Pass,Coef %.3f, p %.3e',Passr(2,1),Passp(2,1)));
set(gca,'FontSize',12);


% legend([el1,el2],{sprintf('Coef %.3f, p %.3e',Taskr(2,1),Taskp(2,1)),sprintf('Coef %.3f, p %.3e',Passr(2,1),Passp(2,1))},...
%     'Box','off','location','NorthWest','FontSize',8);
% saveas(hhhf,'Slope with neural activity correlation plots withDots');
% saveas(hhhf,'Slope with neural activity correlation plots withDots','pdf');
% saveas(hhhf,'Slope with neural activity correlation plots withDots','png');
%%
SessTaskDataAll = cell2mat(cellfun(@(x) reshape((zscore(x))',[],1),SessBoundTunCorr(:,1),'uniformoutput',false));
SessTaskSlopeAll = cell2mat(cellfun(@(x) reshape((x)',[],1),SessBoundTunCorr(:,2),'uniformoutput',false));
SessPassDataAll = cell2mat(cellfun(@(x) reshape((zscore(x))',[],1),SessPassBoundData(:,1),'uniformoutput',false));
SessPassSlopeAll = cell2mat(cellfun(@(x) reshape((x)',[],1),SessPassBoundData(:,2),'uniformoutput',false));
%%
nSess = size(SessBoundTunCorr,1);
DataAll = [];
SlopeAll = [];
for cSess = 1 : nSess
    
    cSessData = SessBoundTunCorr{cSess,1};
    if ~isempty(cSessData)
        figure;
        
        cROIs = size(cSessData,2);
        cSlope = repmat((SessBoundTunCorr{cSess,3})',1,cROIs); 
        DataAll = [DataAll;reshape((zscore(cSessData))',[],1)];
        SlopeAll = [SlopeAll;reshape(cSlope',[],1)];
        plot(reshape(cSlope',[],1),reshape((zscore(cSessData))',[],1),'ro')
    end
end
%%
SessTaskNorDataAll = cell2mat(cellfun(@(x) reshape((x)',[],1),SessBoundTunCorr(:,4),'uniformoutput',false));
SessTaskSlopeAll = cell2mat(cellfun(@(x) reshape((x)',[],1),SessBoundTunCorr(:,2),'uniformoutput',false));
SessPassNorDataAll = cell2mat(cellfun(@(x) reshape((x)',[],1),SessPassBoundData(:,4),'uniformoutput',false));
SessPassSlopeAll = cell2mat(cellfun(@(x) reshape((x)',[],1),SessPassBoundData(:,2),'uniformoutput',false));

[Taskr,Taskp] = corrcoef(SessTaskSlopeAll,SessTaskNorDataAll);
[Passr,Passp] = corrcoef(SessPassSlopeAll,SessPassNorDataAll);

BinsEdge = linspace(0,1,9);
nBins = length(BinsEdge)-1;
BinCent = BinsEdge(1:end-1) + 0.075;
TaskDataBins = zeros(nBins,3);
PassDataBins = zeros(nBins,3);
for cBin = 1 : nBins
    if cBin == 0
        cBinInds = SessTaskSlopeAll >= 0 & SessTaskSlopeAll <=  BinsEdge(cBin+1);
        cPassInds = SessPassSlopeAll >= 0 & SessPassSlopeAll <=  BinsEdge(cBin+1);
    else
        cBinInds = SessTaskSlopeAll > BinsEdge(cBin) & SessTaskSlopeAll <=  BinsEdge(cBin+1);
        cPassInds = SessPassSlopeAll > BinsEdge(cBin) & SessPassSlopeAll <=  BinsEdge(cBin+1);
    end
    cBinDatas = SessTaskNorDataAll(cBinInds);
    cBinPassData = SessPassNorDataAll(cPassInds);
    if ~isempty(cBinDatas)
        cBinDataAvg = mean(cBinDatas);
        cBinDataSem = std(cBinDatas)/numel(cBinDatas)*10;
        TaskDataBins(cBin,:) = [cBinDataAvg,cBinDataSem,1];
    end
    if ~isempty(cBinPassData)
        cPassAvg = mean(cBinPassData);
        cPassSem = std(cBinPassData)/numel(cBinPassData)*10;
        PassDataBins(cBin,:) = [cPassAvg,cPassSem,1];
    end
end
%
TaskNZDatas = TaskDataBins(logical(TaskDataBins(:,3)),1:2);
TaskNZSlopeInds = BinCent(logical(TaskDataBins(:,3)));
PassNZDatas = PassDataBins(logical(PassDataBins(:,3)),1:2);
PassNZSlopeInds = BinCent(logical(PassDataBins(:,3)));
hhf = figure('position',[100 100 700 260]);
subplot(121)
hold on
scatter(SessTaskSlopeAll,SessTaskNorDataAll,6,'o','MarkerFaceColor',[1 0.8 0.6],'MarkerEdgeColor','none');
el1 = errorbar(TaskNZSlopeInds,TaskNZDatas(:,1),TaskNZDatas(:,2),'-o','Color',[1 0.7 0.2],'linewidth',3);

set(gca,'xtick',0:0.5:1,'ytick',0:0.5:1,'ylim',[0 1],'xlim',[-0.1 1.1],'box','off');
xlabel('Discrimination ability');
ylabel('Response');
title(sprintf('Task,Coef %.3f, p %.3e',Taskr(2,1),Taskp(2,1)));
set(gca,'FontSize',14);

subplot(122)
hold on
scatter(SessPassSlopeAll,SessPassNorDataAll,6,'o','MarkerFaceColor',[.8 .8 .8],'MarkerEdgeColor','none');
el2 = errorbar(PassNZSlopeInds,PassNZDatas(:,1),PassNZDatas(:,2),'-o','Color','k','linewidth',3);
set(gca,'xtick',0:0.5:1,'ytick',0:0.5:1,'ylim',[0 1],'xlim',[-0.1 1.1],'box','off');
xlabel('Discrimination ability');
ylabel('Response');
title(sprintf('Pass,Coef %.3f, p %.3e',Passr(2,1),Passp(2,1)));
set(gca,'FontSize',14);
%%
saveas(hhf,'Slope with neural activity01Norm correlation plots withDots');
saveas(hhf,'Slope with neural activity01Norm correlation plots withDots','pdf');
saveas(hhf,'Slope with neural activity01Norm correlation plots withDots','png');

%%
legend([el1,el2],{sprintf('Coef %.3f, p %.3e',Taskr(2,1),Taskp(2,1)),sprintf('Coef %.3f, p %.3e',Passr(2,1),Passp(2,1))},...
    'Box','off','location','NorthWest','FontSize',8);

%%
% PassBFAmpAll = (cell2mat(PassBFRespAmpAll(:,1)'))';
% TaskCorresAmp = cell2mat(PassBFRespAmpAll(:,2));
% UInds = ~(PassBFAmpAll(:) > 1000 | TaskCorresAmp(:) > 1000);
% [~,p] = ttest(PassBFAmpAll(UInds),TaskCorresAmp(UInds));
% ComSigAll = cell2mat(PassBFRespAmpAll(:,3));
% 
% TaskUsedData = TaskCorresAmp(UInds);
% PassUsedData = PassBFAmpAll(UInds);
% SigPUsed = ComSigAll(UInds);
% 
% hPassf = figure;
% hold on
% % plot(PassBFAmpAll(~ExInds),TaskCorresAmp(~ExInds),'o','MarkerSize',6,...
% %     'MarkerFaceColor','k','MarkerEdgeColor','none');
% hl1 = plot(TaskCorresAmp(ComSigAll > 0.05 & UInds),PassBFAmpAll((ComSigAll > 0.05 & UInds)),'o','MarkerSize',6,...
%     'MarkerFaceColor',[.7 .7 .7],'MarkerEdgeColor','none');
% hl2 = plot(TaskCorresAmp(ComSigAll > 0.01 & UInds & ComSigAll < 0.05),PassBFAmpAll((ComSigAll > 0.01 & UInds  & ComSigAll < 0.05)),'o','MarkerSize',6,...
%     'MarkerFaceColor',[1 0.7 0.2],'MarkerEdgeColor','none');
% hl3 = plot(TaskCorresAmp(ComSigAll < 0.01 & UInds),PassBFAmpAll((ComSigAll < 0.01 & UInds)),'o','MarkerSize',6,...
%     'MarkerFaceColor','r','MarkerEdgeColor','none');
% 
% FigAxes = figaxesScaleUni(gca);
% AxesScales = get(FigAxes,'xlim');
% line(AxesScales,AxesScales,'Color',[.7 .7 .7],'linewidth',1.6,'Linestyle','--');
% xlabel('TaskAmp \DeltaF/F_0 (%)');
% ylabel('PassAmp \DeltaF/F_0 (%)');
% set(gca,'FontSize',14);
% legend([hl1,hl2,hl3],{'NoSig','p<0.05','p<0.01'},'Location','NorthWest')
% title(sprintf('PassBF Amp p = %.3e',p));
