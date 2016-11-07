
SelectFrameData = CorrDatas(:,:,FrameScale(1):FrameScale(2));
MeanSelectData = squeeze(mean(SelectFrameData,3));
CorrTrialTypes = double(CorrTrialTypes);
TypeNUmbers = unique(CorrTrialTypes);
ClusterNum = length(TypeNUmbers);

if ClusterNum == 2
    fprintf('Current session as a normal 2-tone 2afc session.\n');
elseif ClusterNum >= 6
    fprintf('Current session as a multi-tones 2afc session.\n');
    PutativeTType = CorrTrialTypes > TypeNUmbers(ClusterNum/2);
    CorrTTypeFreq = CorrTrialTypes;
    CorrTrialTypes = PutativeTType;
end

%%
ModelFoldLoss = zeros(20,1);
TestErrorSum = zeros(20,1);
for n = 1 : 20
    TrainSetInds = false(length(CorrTrialTypes),1);
    RandInds = randsample(length(CorrTrialTypes),round(0.8*length(CorrTrialTypes)));
    TrainSetInds(RandInds) = true;
    TestSetInds = ~TrainSetInds;
    svmModel = fitcsvm(MeanSelectData(TrainSetInds,:),CorrTrialTypes(TrainSetInds));
    ModelLoss = kfoldLoss(crossval(svmModel));
    TestScore = predict(svmModel,MeanSelectData(TestSetInds,:));
    TestError = sum(abs(TestScore' - CorrTrialTypes(TestSetInds)))/length(TestScore);
    TestErrorSum(n) = TestError;
    ModelFoldLoss(n) = ModelLoss;
end
%%
TTypeLogi = logical(CorrTrialTypes);
[coeffT,scoreT,~,~,explainedT,~]=pca(MeanSelectData);
pc3DimData = scoreT(:,1:3);
figure;
hold on;
scatter3(pc3DimData(~TTypeLogi,1),pc3DimData(~TTypeLogi,2),pc3DimData(~TTypeLogi,3),50,'bo');
scatter3(pc3DimData(TTypeLogi,1),pc3DimData(TTypeLogi,2),pc3DimData(TTypeLogi,3),50,'r*');
xlabel('PC1');
ylabel('PC2');
zlabel('PC3');
fprintf('First 3 PCs explains %.3f percent of total variance.\n',sum(explainedT(1:3)));


%%
ClusterDataset = MeanSelectData;
options = statset('UseParallel',1);
ClusterNum = length(unique(CorrTTypeFreq));
CentroidData = cell(9,4);
TotalWithinDis = zeros(9,1);
for ncluater = 2 : 10
    [idx,Centers,sumd,D] = kmeans(ClusterDataset,ncluater,'Options',options,'MaxIter',10000,...
        'Display','final','Replicates',20);
    CentroidData(ncluater-1,:) = {idx,Centers,sumd,D};
    TotalWithinDis(ncluater-1) = sum(sumd);
end

%%
if ClusterNum == 2
    [idx,Centers,sumd,D] = deal(CentroidData{1,:});
    %
    hold on
    Class1Inds = idx == 1;
    Class2Inds = idx == 2;
    scatter3(pc3DimData(Class1Inds,1),pc3DimData(Class1Inds,2),pc3DimData(Class1Inds,3),100,'cd');
    scatter3(pc3DimData(Class2Inds,1),pc3DimData(Class2Inds,2),pc3DimData(Class2Inds,3),100,'gp');
elseif ClusterNum == 6
    [idx,Centers,sumd,D] = deal(CentroidData{ClusterNum - 1,:});
    ClassPropertyType = {'yd','md','cd','gp','bp','rp'};
    hold on
    for nc = 1 : ClusterNum
        ClassInds = idx == nc;
        scatter3(pc3DimData(ClassInds,1),pc3DimData(ClassInds,2),pc3DimData(ClassInds,3),120,ClassPropertyType{nc});
    end
elseif ClusterNum == 8
    [idx,Centers,sumd,D] = deal(CentroidData{ClusterNum - 1,:});
    ClassPropertyType = {'yd','md','cd','kd','gp','bp','rp','kp'};
    hold on
    for nc = 1 : ClusterNum
        ClassInds = idx == nc;
        scatter3(pc3DimData(ClassInds,1),pc3DimData(ClassInds,2),pc3DimData(ClassInds,3),120,ClassPropertyType{nc});
    end
end


%%
saveas(gcf,'After Flick Choice classification')
saveas(gcf,'After Flick Choice classification','png')



%%
% #################################################################################
% the following section will be used for another way of classification
AlignedDataAll = nnspike(radom_inds,:,:);
TrStimAll = behavResults.Stim_toneFreq(radom_inds);
TrialOutComes = trial_outcome(radom_inds);
AlignF = start_frame;
Frate = frame_rate;
TimeScale = [0 1];

%%
% Corr inds selection
CorrTrInds = TrialOutComes == 1;
CorrAlignData = AlignedDataAll(CorrTrInds,:,:);
% CorrAlignData = nnspike(CorrTrInds,:,:);
CorrTrStimFreq = TrStimAll(CorrTrInds);
FrameScale = round(Frate*TimeScale);
SelectAlignData = CorrAlignData(:,:,(AlignF+FrameScale(1)+1):(AlignF+FrameScale(2)));
MtxAlignData = max(SelectAlignData,[],3);

%%
%Try to plot the matrix data according to different stim types
UniStimTypes = unique(CorrTrStimFreq);
TrialTypeclass = CorrTrStimFreq > UniStimTypes(3);
baseInds = 1;
TrialTypeInds = zeros(length(UniStimTypes),1);
OrderData = zeros(size(MtxAlignData));
StimTypeData = cell(length(UniStimTypes),1);
StimTypeNum = zeros(length(UniStimTypes),1);
for nnn = 1 : length(UniStimTypes)
    TrialTypeInds(nnn) = baseInds;
    cFreq = UniStimTypes(nnn);
    cFreqInds = CorrTrStimFreq == cFreq;
    OrderData(baseInds:(baseInds+sum(cFreqInds)-1),:) = MtxAlignData(cFreqInds,:);
    baseInds = baseInds+sum(cFreqInds);
    StimTypeData{nnn} = MtxAlignData(cFreqInds,:);
    StimTypeNum(nnn) = sum(cFreqInds);
end
h_StimResp = figure;
% imagesc(OrderData,[0 300]);
imagesc(OrderData);
colorbar;
set(gca,'ytick',TrialTypeInds,'yticklabel',UniStimTypes);
ylabel('Stimulus');
xlabel('# ROIs');
title('Select Time win response');
saveas(h_StimResp,'Stim response within current timewin');
saveas(h_StimResp,'Stim response within current timewin','png');
% close(h_StimResp);

%%
% ###############################################################################
% this section used the well trained stimulus used for classification
WellTrainedDataSet = [StimTypeData{1};StimTypeData{end}];
WellTrainedClabel = [zeros(StimTypeNum(1),1);ones(StimTypeNum(end),1)];
SVModel = fitcsvm(WellTrainedDataSet,WellTrainedClabel);
modelloss = kfoldLoss(crossval(SVModel));
InterStimPred = predict(SVModel,[StimTypeData{2};StimTypeData{3};StimTypeData{4};StimTypeData{5}]);
InterStimReal = [zeros(StimTypeNum(2),1);zeros(StimTypeNum(3),1);ones(StimTypeNum(4),1);ones(StimTypeNum(5),1)];
InterStimError = sum(abs(InterStimReal - InterStimPred))/length(InterStimPred);
%%
ErrorInds = abs(InterStimReal - InterStimPred);
StimError = zeros(4,1); 
BaseInds = 1;
for nr = 1 : 4
    StimError(nr) = sum(ErrorInds(BaseInds:(BaseInds+StimTypeNum(nr+1)-1)))/StimTypeNum(nr+1);
    BaseInds = BaseInds+StimTypeNum(nr+1);
end

%%
% ###############################################################################
% classification of every single trials
TrainSetInds = false(length(TrialTypeclass),1);
RandInds = randsample(length(TrialTypeclass),round(0.8*length(TrialTypeclass)));
TrainSetInds(RandInds) = true;
TestSetInds = ~TrainSetInds;

TrSVModel = fitcsvm(MtxAlignData(TrainSetInds,:),TrialTypeclass(TrainSetInds));
ModellossTrT = kfoldLoss(crossval(TrSVModel))
ModelTrTPredict = predict(TrSVModel,MtxAlignData(TestSetInds,:));
ModelTrTErro = sum(abs(ModelTrTPredict' - TrialTypeclass(TestSetInds)))/length(ModelTrTPredict);
fprintf('Test Error rate is %.2f.\n',ModelTrTErro);


%%
% ###############################################################################
% this section will used the hardest two sounds for SVM training
StimLength = length(UniStimTypes);
HardestStimInds = StimLength/2;

HardestStimDataSet = [StimTypeData{HardestStimInds};StimTypeData{HardestStimInds+1}];
HardestStimClabel = [zeros(StimTypeNum(HardestStimInds),1);ones(StimTypeNum(HardestStimInds+1),1)];
SVModel = fitcsvm(HardestStimDataSet,HardestStimClabel);
modelloss = kfoldLoss(crossval(SVModel));
InterStimPred = predict(SVModel,[StimTypeData{1};StimTypeData{2};StimTypeData{5};StimTypeData{6}]);
InterStimReal = [zeros(StimTypeNum(1),1);zeros(StimTypeNum(2),1);ones(StimTypeNum(5),1);ones(StimTypeNum(6),1)];
InterStimError = sum(abs(InterStimReal - InterStimPred))/length(InterStimPred);
%%

StimError = zeros(4,1); 
BaseInds = 1;
StimIndsForE = [1,2,5,6];
StimNumForE = StimTypeNum(StimIndsForE);
for nr = 1 : 4
    StimError(nr) = sum(ErrorInds(BaseInds:(BaseInds+StimNumForE(nr)-1)))/StimNumForE(nr);
    BaseInds = BaseInds+StimNumForE(nr);
end
