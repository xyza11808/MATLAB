ROIRawDatas = cell2mat(SavedCaTrials.f_raw');
ROINPDatas = cell2mat(SavedCaTrials.RingF');
ROIRawDatas(:, end-9:end) = [];
ROINPDatas(:, end-9:end) = [];
ROIBases = prctile(ROIRawDatas',15);

BaseMtx = repmat(ROIBases',1,size(ROIRawDatas,2));
DffMtx = (ROIRawDatas - BaseMtx) ./ BaseMtx;

ROINPDatas_Base = repmat((prctile(ROINPDatas',15))',1,size(ROIRawDatas,2));

RingSub_data = ROIRawDatas - ROINPDatas*0.7 + ROINPDatas_Base * 0.7;
RingSub_Base = prctile(RingSub_data',15);
RingSub_BaseMtx = repmat(RingSub_Base',1,size(ROIRawDatas,2));
Dff_RingSub_Mtx = (RingSub_data - RingSub_BaseMtx ) ./ RingSub_BaseMtx;

%%
NumROIs = size(Dff_RingSub_Mtx,1);
MoveFreeDataMtx = zeros(size(Dff_RingSub_Mtx));
for cR = 1 : NumROIs
    RawTrace = Dff_RingSub_Mtx(cR,:);
    [MoveFreetrace, MoveInds, ResidueSTD] =  PossibleMoveArtifactRemoveFun(RawTrace);
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    NumFindPeaks = size(MoveInds,1);
    Possi_FP_Arts = zeros(NumFindPeaks, 1);
    NewMoveFreeTrace = MoveFreetrace;
    for cP = 1 : NumFindPeaks
        cP_EndPointData = RawTrace([min(MoveInds{cP,1}),max(MoveInds{cP,1})]);
        cP_rawData = RawTrace(MoveInds{cP,1});
        if (diff(cP_EndPointData)) > ResidueSTD * 4 && ((min(cP_EndPointData) - min(cP_rawData)) < ResidueSTD*2)
            Possi_FP_Arts(cP) = 1;
            cFP_Inds_scale = MoveInds{cP,1};
            NewMoveFreeTrace(cFP_Inds_scale) = RawTrace(cFP_Inds_scale);
%             plot(MoveInds{cP,1}, RawTrace(MoveInds{cP,1}),'r');
        end
    end
    [MoveFreeBaseAdj,~]=BLSubStract(NewMoveFreeTrace',8,800);
    [MoveFreetrace2, MoveInds2, ResidueSTD2] =  PossibleMoveArtifactRemoveFun(MoveFreeBaseAdj);
%     figure('position',[1920 80 1750 420]);
%     hold on
%     plot(MoveFreeBaseAdj,'k')
%     plot(MoveFreetrace2,'r')
    % correct for the sharp increase peak again
    NumFindPeaks = size(MoveInds2,1);
    Possi_FP_Arts = zeros(NumFindPeaks, 1);
    NewMoveFreeTrace2 = MoveFreetrace2;
    for cP = 1 : NumFindPeaks
        cP_EndPointData = MoveFreeBaseAdj([min(MoveInds2{cP,1}),max(MoveInds2{cP,1})]);
        cP_rawData = RawTrace(MoveInds2{cP,1});
        if (diff(cP_EndPointData)) > ResidueSTD2 * 4 && ((min(cP_EndPointData) - min(cP_rawData)) < ResidueSTD2*2)
            Possi_FP_Arts(cP) = 1;
            cFP_Inds_scale = MoveInds2{cP,1};
            NewMoveFreeTrace2(cFP_Inds_scale) = MoveFreeBaseAdj(cFP_Inds_scale);
%             plot(MoveInds2{cP,1}, MoveFreeBaseAdj(MoveInds2{cP,1}),'c');
        end
    end
    MoveFreeDataMtx(cR,:) = NewMoveFreeTrace2;
end
%%
options = statset('UseParallel',1);

myFunc = @(x, k) kmeans(x,k,'Distance','correlation',...
    'Options',options,'MaxIter',5000,'Display','final');

eva = evalclusters(MoveFreeDataMtx,myFunc,'silhouette',...
    'klist',[1:20]);
CorrMtx = corrcoef(MoveFreeDataMtx');
%%
MormRespMtx = zscore(MoveFreeDataMtx');
zz = linkage(UsedDAta','average','squaredeuclidean');
cutoff = median(zz(end-15:end-1,3))
groups = cluster(zz,'cutoff',cutoff, 'criterion','distance');
unique(groups);
[~,Inds] = sort(groups);

figure;
% imagesc(CorrMtx(Inds,Inds))

%%
close
close
close
cR = 172;
figure('position',[200 650 1860 370]);
hold on
% yyaxis left
% plot(ROIRawDatas(cR,:));

% yyaxis right
% plot(ROINPDatas(cR,:));

plot(DffMtx(cR,:),'k','linewidth',0.7);
plot(Dff_RingSub_Mtx(cR,:),'g','linewidth',0.7);
plot([0, diff(Dff_RingSub_Mtx(cR,:))],'m');
DiffThres = std(diff(Dff_RingSub_Mtx(cR,:))) * 3;
NegDiffThres = -1 * std(diff(Dff_RingSub_Mtx(cR,:))) * 2;
NumFrames = size(DffMtx,2);
plot([1 NumFrames],[DiffThres DiffThres],'c','linewidth',1.5,'linestyle','--');
plot([1 NumFrames],[NegDiffThres NegDiffThres],'c','linewidth',1.5,'linestyle','--');

RawTrace = Dff_RingSub_Mtx(cR,:);
[MoveFreetrace, MoveInds, ResidueSTD] =  PossibleMoveArtifactRemoveFun(RawTrace);
figure('position', [210 50 1710 420]);
hold on
plot(RawTrace,'k')
plot(MoveFreetrace,'c')

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NumFindPeaks = size(MoveInds,1);
Possi_FP_Arts = zeros(NumFindPeaks, 1);
NewMoveFreeTrace = MoveFreetrace;
for cP = 1 : NumFindPeaks
    cP_EndPointData = RawTrace([min(MoveInds{cP,1}),max(MoveInds{cP,1})]);
    cP_rawData = RawTrace(MoveInds{cP,1});
    if (diff(cP_EndPointData)) > ResidueSTD * 4 && ((min(cP_EndPointData) - min(cP_rawData)) < ResidueSTD*2)
        Possi_FP_Arts(cP) = 1;
        cFP_Inds_scale = MoveInds{cP,1};
        NewMoveFreeTrace(cFP_Inds_scale) = RawTrace(cFP_Inds_scale);
        plot(MoveInds{cP,1}, RawTrace(MoveInds{cP,1}),'r');
    end
end
% BaselineFitTb = lmFunCalPlot([],MoveFreetrace,0);
% BaselineFits = predict(BaselineFitTb,(1:numel(MoveFreetrace))');
% MoveFreeBaseAdj = MoveFreetrace' - BaselineFits + median(BaselineFits);
[MoveFreeBaseAdj,~]=BLSubStract(NewMoveFreeTrace',8,800);
plot(MoveFreeBaseAdj,'r')
% plot(BaselineFits, 'Color', [0.1 0.7 0.1])
% plot(NewMoveFreeTrace,'r')

[MoveFreetrace2, MoveInds2, ResidueSTD2] =  PossibleMoveArtifactRemoveFun(MoveFreeBaseAdj);
figure('position',[1920 80 1750 420]);
hold on
plot(MoveFreeBaseAdj,'k')
plot(MoveFreetrace2,'r')
% correct for the sharp increase peak again
NumFindPeaks = size(MoveInds2,1);
Possi_FP_Arts = zeros(NumFindPeaks, 1);
NewMoveFreeTrace2 = MoveFreetrace2;
for cP = 1 : NumFindPeaks
    cP_EndPointData = MoveFreeBaseAdj([min(MoveInds2{cP,1}),max(MoveInds2{cP,1})]);
    cP_rawData = RawTrace(MoveInds2{cP,1});
    if (diff(cP_EndPointData)) > ResidueSTD2 * 4 && ((min(cP_EndPointData) - min(cP_rawData)) < ResidueSTD2*2)
        Possi_FP_Arts(cP) = 1;
        cFP_Inds_scale = MoveInds2{cP,1};
        NewMoveFreeTrace2(cFP_Inds_scale) = MoveFreeBaseAdj(cFP_Inds_scale);
        plot(MoveInds2{cP,1}, MoveFreeBaseAdj(MoveInds2{cP,1}),'c');
    end
end
%

%% find assumed movement signal and then replace the artifact
% NArt = size(MoveInds,1);
% AllFits = cell(NArt,1);
% for cArti = 1 : NArt
%     cAtrData = MoveInds{cArti, 2};
%     lmfits = lmFunCalPlot([],cAtrData,0);
%     AllFits{cArti} = lmfits;
% end
% RSq_adj = cellfun(@(x) x.Rsquared.Adjusted,AllFits);
% CenterInds = cellfun(@mean, MoveInds(:,1));
% RSFitSlope = cellfun(@(x) x.Coefficients.Estimate(2),AllFits);
% FalsePositiveInds = find(RSq_adj > 0.5 & RSFitSlope > 0);
% NumFP_peaks = length(FalsePositiveInds);
% for cP = 1 : NumFP_peaks
%     cP_Inds = MoveInds{FalsePositiveInds(cP), 1};
%     cP_IndsRawdata = RawTrace(cP_Inds);
%     plot(cP_Inds,cP_IndsRawdata,'r');
% end


%%
% try with events detection method

% performing events detection for current sessions
% using function for events detection
FilterOpsAll.Type = 'bandpassfir';
FilterOpsAll.Fr = 31;
FilterOpsAll.PassBand2 = 1;
FilterOpsAll.StopBand2 = 3;
FilterOpsAll.PassBand1 = 0.005;
FilterOpsAll.StopBand1 = 0.001;
FilterOpsAll.StopAttenu1 = 60;
FilterOpsAll.StopAttenu2 = 60;
FilterOpsAll.DesignMethod = 'kaiserwin';
FilterOpsAll.IsPlot = 0;

% events detection parameters
EventParas.NoiseMethod = 'Res_std';
EventParas.PeakThres = 1;
EventParas.BaselinePrc = 18;
EventParas.MinHalfPeakWid = 1.5; % seconds
EventParas.OnsetThres = 1;
EventParas.OffsetThres = 1;
EventParas.IsPlot = 1;
EventParas.ABSPeakValue = 0.2;
%%
% [~,EventIndex,ROIPlots] = TraceEventDetectNew(Dff_RingSub_Mtx(cR,:),FilterOpsAll,EventParas);
nROIs = size(test01_dffData,1);
parfor cROI = 1 : nROIs
%     cROITrace = AdJustMoveFreeData_All_mtx(cROI,:);
    [~,EventIndex,ROIPlots] = TraceEventDetectNew(test01_dffData(cROI,:),FilterOpsAll,EventParas);
    EventsIndsAllROI{cROI} = EventIndex;
    if ishandle(ROIPlots{2})
        title(num2str(cROI,'ROI%d'));
        ffName = sprintf('ROI%d event Trace plots',cROI);
        saveas(ROIPlots{2},ffName);
        saveas(ROIPlots{2},ffName,'png');
        close(ROIPlots{2});
    end
end
%%

% DffMtx_BF_test01 = DffMtx;
% DffMtx_10AF_test04 = DffMtx;
DffMtx_AF_test03 = DffMtx;
% DffMtx_rf_test02 = DffMtx;

% save DiffMatrixSave.mat DffMtx_rf_test02 DffMtx_AF_test03 DffMtx_BF_test01
%%
[BF_test01_CorrMtx,~] = corrcoef(DffMtx_BF_test01');

[RF_test02_CorrMtx,~] = corrcoef(DffMtx_rf_test02');

[AF_test03_CorrMtx,~] = corrcoef(DffMtx_AF_test03');

[AF10mins_test04_CorrMtx,~] = corrcoef(DffMtx_10AF_test04');

figure
subplot(221)
imagesc(BF_test01_CorrMtx,[-1 1]);

subplot(222)
imagesc(RF_test02_CorrMtx,[-1 1]);

subplot(223)
imagesc(AF_test03_CorrMtx,[-1 1]);

subplot(224)
imagesc(AF10mins_test04_CorrMtx,[-1 1]);

%%
save DataMtxAndCorrMtx.mat DffMtx_10AF_test04 DffMtx_AF_test03 DffMtx_BF_test01 DffMtx_rf_test02 ...
    BF_test01_CorrMtx RF_test02_CorrMtx AF_test03_CorrMtx AF10mins_test04_CorrMtx -v7.3

%%
zz = linkage(BF_test01_CorrMtx,'average','correlation');
figure('position',[600 100 420 350]);
dendrogram(zz)
groups = cluster(zz,'cutoff',0.9,'criterion','distance');
Gr_Types = unique(groups);
GrNum = zeros(length(Gr_Types),1);
for cGr = 1 : length(Gr_Types)
    GrNum(cGr) = sum(groups == Gr_Types(cGr));
end
UsedGrNums = cumsum([1;GrNum]);
[~,SortInds] = sort(groups);
hf = figure('position',[100 100 420 350]);
imagesc(BF_test01_CorrMtx(SortInds,SortInds),[-0.5 0.5]);

%%

figure
subplot(221)
imagesc(BF_test01_CorrMtx(SortInds,SortInds),[-1 1]);

subplot(222)
imagesc(RF_test02_CorrMtx(SortInds,SortInds),[-1 1]);

subplot(223)
imagesc(AF_test03_CorrMtx(SortInds,SortInds),[-1 1]);

subplot(224)
imagesc(AF10mins_test04_CorrMtx(SortInds,SortInds),[-1 1]);



%%
Test01_BF_Corrs = BF_test01_CorrMtx(tril(true(size(BF_test01_CorrMtx)),-1));
RF_test02_Corrs = RF_test02_CorrMtx(tril(true(size(RF_test02_CorrMtx)),-1));
AF_test03_Corrs = AF_test03_CorrMtx(tril(true(size(RF_test02_CorrMtx)),-1));
AF_test04_Corrs = AF10mins_test04_CorrMtx(tril(true(size(RF_test02_CorrMtx)),-1));

%%
figure;
hold on
plot(RF_test02_Corrs,Test01_BF_Corrs,'bo','linewidth',0.5,'MarkerSize',5)
plot(RF_test02_Corrs,AF_test03_Corrs,'ro','linewidth',0.5,'MarkerSize',5)
plot(RF_test02_Corrs,AF_test04_Corrs,'o','linewidth',0.5,'MarkerSize',5,'Color',[.7 .7 .7])
xlabel('RF Corr')
ylabel('Spont Corr')

%%

[EigVec,EigValueMtx] = eig(RF_test02_CorrMtx);
EigValues = diag(EigValueMtx);
EigVars = EigValues .^ 2;
[~,Inds] = sort(EigValues,'descend');
EigValues = EigValues(Inds);
EigVars = EigVars(Inds);
EigVecSort = EigVec(:,Inds);
VarienceExplained = EigVars/sum(EigVars);
FirstThreeVarExp = sum(VarienceExplained(1:3))
FirstThreeEigVec = EigVecSort(:,1:3);


%%
X = DffMtx_10AF_test04;
MVGC_CusScript;
sig(isnan(sig)) = 0;
F(~logical(sig)) = 0;
SigInds = find(F);
[Rows,Cols] = ind2sub([119,119],SigInds);
GG = digraph(Cols,Rows,F(SigInds));
figure;
p = plot(GG);

% layout(pg, 'force3');
% view(3)
%%
GG.Nodes.NodeColors = indegree(GG);
p.NodeCData = GG.Nodes.NodeColors;
colorbar
%%
GG.Edges.LWidths = 7*GG.Edges.Weight/max(GG.Edges.Weight);
p.LineWidth = GG.Edges.LWidths;

%%
AF10mins_net_cent = centrality(GG,'hubs','Importance',GG.Edges.Weight);

%% dimension reduction test

[coeff, score,~,~,explain,mu] = pca(DffMtx_BF_test01');
DffMtx_rf_test02_Trans = DffMtx_rf_test02';
RF_MeanSubMtx = DffMtx_rf_test02_Trans - repmat(mean(DffMtx_rf_test02_Trans),...
    size(DffMtx_rf_test02_Trans,1),1);

RF_2_BF_scores = RF_MeanSubMtx *  coeff;

%%
Test02_corrs = Test02_corrs - diag(ones(size(Test02_corrs,1),1));
[~,RF_2_BF_scores,~] = pca(Test02_corrs);


%%
RF_frame_info = cellfun(@(x) size(x,2), SavedCaTrials.f_raw);
UsedFrameLen = min(RF_frame_info);
Trace_2_Mtx = zeros(length(RF_frame_info), size(coeff,1), UsedFrameLen);
TrBase = 1;
for cTr = 1 : length(RF_frame_info)
    Trace_2_Mtx(cTr,:,:) = (RF_2_BF_scores(TrBase:(TrBase + UsedFrameLen - 1), :))';
    TrBase = TrBase + RF_frame_info(cTr);
end

% Soundarrays = textread('b70a04_test02_rf_150um_20200521.txt');

DBTypes = unique(Soundarrays(:,2));
FreqTypes = unique(Soundarrays(:,1));
Num_dbType = length(DBTypes);
DBTypeDatas = cell(Num_dbType,1);
DB_FreqValues = cell(Num_dbType,1);
DB_duration = cell(Num_dbType,1);
for cDb = 1 : Num_dbType
    cDB_inds = Soundarrays(:,2) == DBTypes(cDb);
    DBTypeDatas{cDb} = Trace_2_Mtx(cDB_inds,:,:);
    DB_FreqValues{cDb} = Soundarrays(cDB_inds,1);
    DB_duration{cDb} = Soundarrays(cDB_inds,3);
end

%%
figure;
hold on
% plot3(smooth(score(:,1),5),smooth(score(:,2),5),smooth(score(:,3),5),'r');
UsedDB_typeIndex = 3;
UsedDB_Data = DBTypeDatas{UsedDB_typeIndex};
UsedDB_Freqs = DB_FreqValues{UsedDB_typeIndex};
UsedDB_Dur = DB_duration{UsedDB_typeIndex};
Num_Freqs = length(FreqTypes);
lineStyles=linspecer(Num_Freqs);
for cf = 1 : Num_Freqs
    cf_Inds = UsedDB_Freqs == FreqTypes(cf);
    cf_Datas = UsedDB_Data(cf_Inds, :, :);
    cf_data_Avg = squeeze(mean(cf_Datas));
    plot3(smooth(cf_data_Avg(1,:),5),smooth(cf_data_Avg(2,:),5),smooth(cf_data_Avg(3,:),5),'color',lineStyles(cf,:));
end

xlabel('x1');
ylabel('x2');
zlabel('x3');

%%

corrs = corrcoef(MoveFreeDataMtx');
CorMtx_mask = logical(tril(ones(size(corrs)),-1));
MaskInds = find(CorMtx_mask);
MaskIndsCoefs = corrs(MaskInds);
UsedCoefIndex = MaskIndsCoefs > 0.3;

MaskInds_used = MaskInds(UsedCoefIndex);
MaskCoef_used = MaskIndsCoefs(UsedCoefIndex);
[Rows, Cols] = ind2sub(size(CorMtx_mask), MaskInds_used);
Gnets = graph(Cols, Rows, MaskCoef_used);

%%
figure; 
pp = plot(Gnets);
Gnets.Nodes.NodeColors = degree(Gnets);
pp.NodeCData = Gnets.Nodes.NodeColors;
pp.NodeFontSize = Gnets.Nodes.NodeColors+1;
colorbar

Gnets.Edges.LWidths = 7*Gnets.Edges.Weight/max(Gnets.Edges.Weight);
pp.LineWidth = Gnets.Edges.LWidths;
layout(pp,'force3')
view(3)
