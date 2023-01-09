function RepeatCorrSum = crossValCCA(RawFullDataIn,ValidFullDataIn,AreaUnitInds,CVRatio)
% fucntion used to calculation cross-validated CCA for given datas
Area1Units = AreaUnitInds{1};
Area2Units = AreaUnitInds{2};
if ~exist('CVRatio','var') || isempty(CVRatio)
    CVRatio = 0.5;
end

[AllTrialNum, NumUnit, FrameNum] = size(RawFullDataIn);
TrialBaseInds = false(AllTrialNum,1);

% normalize unit variance into 1
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

TrCellData = mat2cell(RawFullData,ones(AllTrialNum,1),NumUnit, FrameNum);
TrCellData = cellfun(@squeeze, TrCellData, 'un',0);

RawFullTrace = (reshape(permute(RawFullData,[2,3,1]),size(RawFullData,2),[]))'; % NumTimepoints by NumUnits
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
    cR_ValidTestData = ValidFullData(~cR_TrainTrInds,:,:);
    
%     A1_cR_trainData = cR_trainData(:,Area1Units,:);
%     A2_cR_trainData = cR_trainData(:,Area2Units,:);
    
    A1_cR_ValidtestData = cR_ValidTestData(:,Area1Units,:);
    A2_cR_ValidtestData = cR_ValidTestData(:,Area2Units,:);
    
    A1_trainTrace = RawFullTrace(TrainTraceTrInds,Area1Units);
    A2_trainTrace = RawFullTrace(TrainTraceTrInds,Area2Units);
    
    A1_testTrace = RawFullTrace(~TrainTraceTrInds,Area1Units);
    A2_testTrace = RawFullTrace(~TrainTraceTrInds,Area2Units);
    
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
    ShufCorrs = cell(1,ShufExtraRePeat);
    for cShuf = 1 : ShufExtraRePeat
        [~,RandSeqs] = sort(ShufIndsMtx(:,cShuf));
        A1_shufCellData = TrCell_TrainTrData(RandSeqs);
        A1_shufCellUnitData = cellfun(@(x) (x(Area1Units,:))',A1_shufCellData,'un',0);
        A1_shufUnitData = cat(1,A1_shufCellUnitData{:});
        
        A2_shufCellUnitData = cellfun(@(x) (x(Area2Units,:))',TrCell_TrainTrData,'un',0);
        A2_shufUnitData = cat(1,A2_shufCellUnitData{:});
        
        A1_U_testProjShuf = (A1_shufUnitData - mean(A1_shufUnitData)) * A1_base;
        A2_V_testProjShuf = (A2_shufUnitData - mean(A2_shufUnitData)) * A2_base;

        SampleRShuf = corr(A1_U_testProjShuf,A2_V_testProjShuf); % Correlation matrix
        ShufCorrs{cShuf} = diag(SampleRShuf);
    end
    
    RepeatCorrSum(cR,:) = {single(A1_base), single(A2_base), single(R_base), single(SampleR), ...
        single(cat(2,FrameCorrs{:})), single(cat(2,ShufCorrs{:}))};
    
end

warning on




