function [RepeatCorrSum, RepeatAvgs] = crossValCCA_SepData(RawFullDataIn,ValidFullDataIn,...
    RawFullDataIn2,ValidFullDataIn2,CVRatio)
% fucntion used to calculation cross-validated CCA for given datas

if ~exist('CVRatio','var') || isempty(CVRatio)
    CVRatio = 0.5;
end

[AllTrialNum, NumUnit, FrameNum] = size(RawFullDataIn);
[AllTrialNum2, NumUnit2, FrameNum2] = size(RawFullDataIn2);
TrialBaseInds = false(AllTrialNum,1);
if AllTrialNum ~= AllTrialNum2 || FrameNum ~= FrameNum2
    error('The trial num or frame number from two dataset is different, please check your input.');
end

% normalize unit variance into 1 for first dataset
RawFullData = zeros(size(RawFullDataIn));
ValidFullData = zeros(size(ValidFullDataIn));
RawFullDataIn = permute(RawFullDataIn,[1,3,2]);
% ValidFullDataIn = permute(ValidFullDataIn,[1,3,2]);
for cU = 1 : NumUnit
    cU_rawFullData = RawFullDataIn(:,:,cU);
    cU_DataVar = std(cU_rawFullData(:));
    if cU_DataVar < 1e-6
        RawFullData(:,cU,:) = cU_rawFullData;
        ValidFullData(:,cU,:) = ValidFullDataIn(:,cU,:);
    else
        RawFullData(:,cU,:) = cU_rawFullData/cU_DataVar;
        ValidFullData(:,cU,:) = ValidFullDataIn(:,cU,:)/cU_DataVar;
    end
end
ValidFrameNum = size(ValidFullData,3);

% normalize unit variance into 1 for second dataset
RawFullData2 = zeros(size(RawFullDataIn2));
ValidFullData2 = zeros(size(ValidFullDataIn2));
RawFullDataIn2 = permute(RawFullDataIn2,[1,3,2]);
% ValidFullDataIn = permute(ValidFullDataIn,[1,3,2]);
for cU = 1 : NumUnit2
    cU_rawFullData = RawFullDataIn2(:,:,cU);
    cU_DataVar = std(cU_rawFullData(:));
    if cU_DataVar < 1e-6
        RawFullData2(:,cU,:) = cU_rawFullData;
        ValidFullData2(:,cU,:) = ValidFullDataIn2(:,cU,:);
    else
        RawFullData2(:,cU,:) = cU_rawFullData/cU_DataVar;
        ValidFullData2(:,cU,:) = ValidFullDataIn2(:,cU,:)/cU_DataVar;
    end
end


TrCellData = mat2cell(RawFullData,ones(AllTrialNum,1),NumUnit, FrameNum);
TrCellData = cellfun(@squeeze, TrCellData, 'un',0);
TrCellData2 = mat2cell(RawFullData2,ones(AllTrialNum,1),NumUnit2, FrameNum);
TrCellData2 = cellfun(@squeeze, TrCellData2, 'un',0);


RawFullTrace = (reshape(permute(RawFullData,[2,3,1]),size(RawFullData,2),[]))'; % NumTimepoints by NumUnits
RawFullTrace2 = (reshape(permute(RawFullData2,[2,3,1]),size(RawFullData2,2),[]))'; % NumTimepoints by NumUnits
AllTrIndexTrace = uint16(reshape(repmat(1:AllTrialNum,FrameNum,1),[],1));
%%
warning off
RepeatNum = 100;
ShufExtraRePeat = 5; % totally 500 times shuffling
RepeatCorrSum = cell(RepeatNum,6);
parfor cR = 1 : RepeatNum
%     cR = 1;
    cR_TrainTrSample = randsample(AllTrialNum,round(AllTrialNum*CVRatio));
    cR_TrainTrInds = TrialBaseInds;
    cR_TrainTrInds(cR_TrainTrSample) = true;
    TrainTraceTrInds = ismember(AllTrIndexTrace,cR_TrainTrSample);
    
%     cR_trainData = RawFullData(cR_TrainTrInds,:,:);
%     cR_testData = RawFullData(~cR_TrainTrInds,:,:);
%     cR_ValidTestData = ValidFullData(~cR_TrainTrInds,:,:);
%     cR_ValidTestData2 = ValidFullData2(~cR_TrainTrInds,:,:);
    A1_cR_ValidtestData = ValidFullData(~cR_TrainTrInds,:,:);
    A2_cR_ValidtestData = ValidFullData2(~cR_TrainTrInds,:,:);
    
%     A1_cR_ValidtestData = cR_ValidTestData(:,Area1Units,:);
%     A2_cR_ValidtestData = cR_ValidTestData(:,Area2Units,:);
    
    A1_trainTrace = RawFullTrace(TrainTraceTrInds,:);
    A2_trainTrace = RawFullTrace2(TrainTraceTrInds,:);
    
    A1_testTrace = RawFullTrace(~TrainTraceTrInds,:);
    A2_testTrace = RawFullTrace2(~TrainTraceTrInds,:);
    
    % U = (X - mean(X))*A; V = (Y - mean(Y))*B; R(x) = corrcoef(U(:,1),V(:,1));
    [A1_base, A2_base, R_base] = canoncorr(A1_trainTrace, A2_trainTrace);
    
    % calculate correlation on test dataset
    A1_U_testProj = (A1_testTrace - mean(A1_testTrace)) * A1_base;
    A2_V_testProj = (A2_testTrace - mean(A2_testTrace)) * A2_base;
    
    SampleR = corr(A1_U_testProj,A2_V_testProj); % Correlation matrix
    
    % calculate the correlation on calidation data, for each timebin
    FrameCorrs = cell(1,ValidFrameNum);
    for cTbin = 1 : ValidFrameNum
        A1_cF_ValidTestData = A1_cR_ValidtestData(:,:,cTbin);
        A2_cF_ValidTestData = A2_cR_ValidtestData(:,:,cTbin);
        A1_U_validProj = (A1_cF_ValidTestData - mean(A1_cF_ValidTestData)) * A1_base;
        A2_V_validProj = (A2_cF_ValidTestData - mean(A2_cF_ValidTestData)) * A2_base;
        cBinCorr = corr(A1_U_validProj,A2_V_validProj);
        FrameCorrs{cTbin} = diag(cBinCorr);
    end
    
    % calculate shuf corrs
    ShufIndsMtx = rand(sum(cR_TrainTrInds),ShufExtraRePeat);
    TrCell_TrainTrData = TrCellData(cR_TrainTrInds);
    TrCell_TrainTrData2 = TrCellData2(cR_TrainTrInds);
    ShufCorrs = cell(1,ShufExtraRePeat);
    for cShuf = 1 : ShufExtraRePeat
        [~,RandSeqs] = sort(ShufIndsMtx(:,cShuf));
        A1_shufCellData = TrCell_TrainTrData(RandSeqs);
%         A1_shufCellUnitData = cellfun(@(x) (x(Area1Units,:))',A1_shufCellData,'un',0);
        A1_shufUnitData = cat(2,A1_shufCellData{:})';
        
%         A2_shufCellUnitData = cellfun(@(x) (x(Area2Units,:))',TrCell_TrainTrData,'un',0);
        A2_shufUnitData = cat(2,TrCell_TrainTrData2{:})';
        
        A1_U_testProjShuf = (A1_shufUnitData - mean(A1_shufUnitData)) * A1_base;
        A2_V_testProjShuf = (A2_shufUnitData - mean(A2_shufUnitData)) * A2_base;

        SampleRShuf = corr(A1_U_testProjShuf,A2_V_testProjShuf); % Correlation matrix
        ShufCorrs{cShuf} = diag(SampleRShuf);
    end
    
    RepeatCorrSum(cR,:) = {single(A1_base), single(A2_base), single(R_base), single(SampleR), ...
        single(cat(2,FrameCorrs{:})), single(cat(2,ShufCorrs{:}))};
    
end

% Train data correlation
BaseTrainCorrs = cat(1,RepeatCorrSum{:,3});
% test data correlation
BaseTestCorrs = cellfun(@diag,RepeatCorrSum(:,4),'un',0);
BaseTestCorrs = cat(2,BaseTestCorrs{:});
% valid data correlation
BaseValidTimeCorr = cat(3,RepeatCorrSum{:,5});
BaseValidTimeCorrAvg = mean(BaseValidTimeCorr,3);
BaseValidTimeCorrSTD = std(BaseValidTimeCorr,[],3);

% shuf threshold for thres calculation
BaseShufCorrs = cat(2,RepeatCorrSum{:,6});
BaseShufCorrThres = prctile(BaseShufCorrs,95,2);

BaseTrainCorrAvg = dataSEMmean(BaseTrainCorrs,'Trace');
BaseTestCorrsAvg = dataSEMmean(BaseTestCorrs','Trace');

RepeatAvgs = {BaseTrainCorrAvg, BaseTestCorrsAvg, BaseValidTimeCorrAvg,BaseValidTimeCorrSTD,BaseShufCorrThres};

warning on



