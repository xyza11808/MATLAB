cAUnits = ExistField_ClusIDs{4,2};
BaselineData = mean(NewBinnedDatas(NMTrInds,cAUnits,1:(OutDataStrc.TriggerStartBin-1)),3);
StimOnTimeBin = OutDataStrc.TriggerStartBin;
RespDataUsedMtx = NewBinnedDatas(NMTrInds,cAUnits,:);
[NMTrNum,cAROINum,FrameBins] = size(RespDataUsedMtx);

BaseSubRespData = RespDataUsedMtx - repmat(BaselineData,1,1,FrameBins);

xTimes = OutDataStrc.BinCenters;
%%
RevTrInds = NMRevFreqInds;
NonRevTrInds = ~NMRevFreqInds;

RevTr_ActChoices = NMActionChoices(RevTrInds);
RevTr_BTs = NMBlockTypes(RevTrInds);
RevTr_TrNum = length(RevTr_ActChoices);
% RevTr_BaseData = BaselineData(RevTrInds,:,:);
RevTr_BaseSubData = BaseSubRespData(RevTrInds,:,:);
RevTr_RawRespData = RespDataUsedMtx(RevTrInds,:,:);


NonRevTr_ActChoices = NMActionChoices(NonRevTrInds);
NonRevTr_TrNum = length(NonRevTr_ActChoices);
% NonRevTr_BaseData = BaselineData(NonRevTrInds,:);
NonRevTr_BaseSubData = BaseSubRespData(NonRevTrInds,:,:);
NonRevTr_RawRespData = RespDataUsedMtx(NonRevTrInds,:,:);

% create choice decoding space using nonRev trials, sampling 70% to create
% and the rest 30% for test
NonRevTr_SampleIndex = randsample(NonRevTr_TrNum,round(NonRevTr_TrNum*0.7));
NonRevTr_SampleInds = false(NonRevTr_TrNum,1);
NonRevTr_SampleInds(NonRevTr_SampleIndex) = true;

NonRevTr_Sample_baseSubD = NonRevTr_BaseSubData(NonRevTr_SampleInds,:,:);
NonRevTr_SampleChoices = NonRevTr_ActChoices(NonRevTr_SampleInds);

% create defined Left and Right choice trajectory
LChoice_BSData_Avg = squeeze(mean(NonRevTr_Sample_baseSubD(NonRevTr_SampleChoices == 0,:,:)));
RChoice_BSData_Avg = squeeze(mean(NonRevTr_Sample_baseSubD(NonRevTr_SampleChoices == 1,:,:)));

NonRevTr_TestData = NonRevTr_BaseSubData(~NonRevTr_SampleInds,:,:);
NonRevTr_TestChoice = NonRevTr_ActChoices(~NonRevTr_SampleInds);
TestDataTrNum = size(NonRevTr_TestData,1);

TestDataTrajs_2Left = zeros(TestDataTrNum,FrameBins);
TestDataTrajs_2Right = zeros(TestDataTrNum,FrameBins);
TestDataTrajs_SI = zeros(TestDataTrNum,FrameBins);

NonRevTr_TestDataUsed = permute(NonRevTr_TestData,[2,3,1]);
for cTr = 1 : TestDataTrNum
    cNonRev_testData = NonRevTr_TestDataUsed(:,:,cTr);
    TestDataTrajs_2Left(cTr,:) = sum((cNonRev_testData - LChoice_BSData_Avg).^2);
    TestDataTrajs_2Right(cTr,:) = sum((cNonRev_testData - RChoice_BSData_Avg).^2);
    TestDataTrajs_SI(cTr,:) = (TestDataTrajs_2Left(cTr,:) - TestDataTrajs_2Right(cTr,:))./...
        (TestDataTrajs_2Left(cTr,:) + TestDataTrajs_2Right(cTr,:));
end

TestData_LC_SI = mean(TestDataTrajs_SI(NonRevTr_TestChoice == 0,:));
TestData_RC_SI = mean(TestDataTrajs_SI(NonRevTr_TestChoice == 1,:));
%% sample test data selection index

%% calculate the distance for ReverTrDatas 
RevTr_BaseSubDataUsed = permute(RevTr_BaseSubData,[2,3,1]);
RevTr_Nums = size(RevTr_BaseSubDataUsed,3);

RevTr_BS_TrajDis2Left = zeros(RevTr_Nums, FrameBins);
RevTr_BS_TrajDis2Right = zeros(RevTr_Nums, FrameBins);
RevTr_BSData_SI = zeros(RevTr_Nums, FrameBins);
for ccTr = 1 : RevTr_Nums
    cRevTr_Data = RevTr_BaseSubDataUsed(:,:,ccTr);
    RevTr_BS_TrajDis2Left(ccTr,:) = sum((cRevTr_Data - LChoice_BSData_Avg).^2);
    RevTr_BS_TrajDis2Right(ccTr,:) = sum((cRevTr_Data - RChoice_BSData_Avg).^2);
    RevTr_BSData_SI(ccTr,:) = (RevTr_BS_TrajDis2Left(ccTr,:) - RevTr_BS_TrajDis2Right(ccTr,:))./...
        (RevTr_BS_TrajDis2Left(ccTr,:) + RevTr_BS_TrajDis2Right(ccTr,:));
end
% hf2 = figure;
% hold on

%%
hf = figure;
hold on
[~,~,hl1] = MeanSemPlot(TestDataTrajs_SI(NonRevTr_TestChoice == 0,:),xTimes,hf,0.5,[1 0.4 0.4],...
    'b','linewidth',1);
[~,~,hl2] = MeanSemPlot(TestDataTrajs_SI(NonRevTr_TestChoice == 1,:),xTimes,hf,0.5,[0.4 0.4 1],...
    'r','linewidth',1);


[~,~,hl3] = MeanSemPlot(RevTr_BSData_SI(RevTr_ActChoices == 0,:),xTimes,hf,0.5,[1 0.4 0.4],...
    'color',[0.1 0.2 0.6],'linewidth',1.4);
[~,~,hl4] = MeanSemPlot(RevTr_BSData_SI(RevTr_ActChoices == 1,:),xTimes,hf,0.5,[0.4 0.4 1],...
    'color','m','linewidth',1.4);


%% calculate raw response data trajectories
RevTr_RawRespDataUsed = permute(RevTr_RawRespData,[2,3,1]);
RevTr_Num = size(RevTr_RawRespDataUsed,3);

RevTr_RawRespDis2L = zeros(RevTr_Num,FrameBins);
RevTr_RawRespDis2R = zeros(RevTr_Num,FrameBins);
RevTr_RawRespSI = zeros(RevTr_Num,FrameBins);
for cTr = 1 : RevTr_Num
    cRevTr_RawRespData = RevTr_RawRespDataUsed(:,:,cTr);
    RevTr_RawRespDis2L(cTr,:) = sum((cRevTr_RawRespData - LChoice_BSData_Avg).^2);
    RevTr_RawRespDis2R(cTr,:) = sum((cRevTr_RawRespData - RChoice_BSData_Avg).^2);
    RevTr_RawRespSI(cTr,:) = (RevTr_RawRespDis2L(cTr,:) - RevTr_RawRespDis2R(cTr,:))./...
        (RevTr_RawRespDis2L(cTr,:) + RevTr_RawRespDis2R(cTr,:));
end
% RevTr_ActChoices

NonRevTr_RawRespDataUsed = permute(NonRevTr_RawRespData,[2,3,1]);
NonRevTr_Num = size(NonRevTr_RawRespDataUsed,3);

NonRevTr_RawRespDis2L = zeros(NonRevTr_Num,FrameBins);
NonRevTr_RawRespDis2R = zeros(NonRevTr_Num,FrameBins);
NonRevTr_RawRespSI = zeros(NonRevTr_Num,FrameBins);
for cTr = 1 : NonRevTr_Num
    cNRevTr_RawRespData = NonRevTr_RawRespDataUsed(:,:,cTr);
    NonRevTr_RawRespDis2L(cTr,:) = sum((cNRevTr_RawRespData - LChoice_BSData_Avg).^2);
    NonRevTr_RawRespDis2R(cTr,:) = sum((cNRevTr_RawRespData - RChoice_BSData_Avg).^2);
    NonRevTr_RawRespSI(cTr,:) = (NonRevTr_RawRespDis2L(cTr,:) - NonRevTr_RawRespDis2R(cTr,:))./...
        (NonRevTr_RawRespDis2L(cTr,:) + NonRevTr_RawRespDis2R(cTr,:));
end

% NonRevTr_ActChoices
%%
hf2 = figure;
hold on
[~,~,hl5] = MeanSemPlot(TestDataTrajs_SI(NonRevTr_TestChoice == 0,:),xTimes,hf2,0.5,[1 0.4 0.4],...
    'b','linewidth',1);
[~,~,hl6] = MeanSemPlot(TestDataTrajs_SI(NonRevTr_TestChoice == 1,:),xTimes,hf2,0.5,[0.4 0.4 1],...
    'r','linewidth',1);


[~,~,hl7] = MeanSemPlot(NonRevTr_RawRespSI(NonRevTr_ActChoices == 0,:),xTimes,hf2,0.5,[1 0.4 0.4],...
    'color','c','linewidth',1.4);
[~,~,hl8] = MeanSemPlot(NonRevTr_RawRespSI(NonRevTr_ActChoices == 1,:),xTimes,hf2,0.5,[0.4 0.4 1],...
    'color','m','linewidth',1.4);

%%
hf3 = figure;
hold on
[~,~,hl9] = MeanSemPlot(RevTr_BSData_SI(RevTr_ActChoices == 0,:),xTimes,hf3,0.5,[1 0.4 0.4],...
    'b','linewidth',1);
[~,~,hl10] = MeanSemPlot(RevTr_BSData_SI(RevTr_ActChoices == 1,:),xTimes,hf3,0.5,[0.4 0.4 1],...
    'r','linewidth',1);


[~,~,hl11] = MeanSemPlot(RevTr_RawRespSI(RevTr_ActChoices == 0,:),xTimes,hf3,0.5,[1 0.4 0.4],...
    'color','c','linewidth',1.4);
[~,~,hl12] = MeanSemPlot(RevTr_RawRespSI(RevTr_ActChoices == 1,:),xTimes,hf3,0.5,[0.4 0.4 1],...
    'color','m','linewidth',1.4);

 
%% differnce of two SI trajectories
BSData_LRSI_diff = mean(RevTr_BSData_SI(RevTr_ActChoices == 1,:)) - ...
    mean(RevTr_BSData_SI(RevTr_ActChoices == 0,:));
RespData_LRSI_diff = mean(RevTr_RawRespSI(RevTr_ActChoices == 1,:)) - ...
    mean(RevTr_RawRespSI(RevTr_ActChoices == 0,:));

figure;hold on
hdf1 = plot(xTimes, BSData_LRSI_diff,'Color','k','linewidth',1.2);
hdf2 = plot(xTimes, RespData_LRSI_diff,'Color',[0.8 0.5 0.2],'linewidth',1.2);

%%
NBSData_LRSI_diff = mean(TestDataTrajs_SI(NonRevTr_TestChoice == 1,:)) - ...
    mean(TestDataTrajs_SI(NonRevTr_TestChoice == 0,:));
NRespData_LRSI_diff = mean(NonRevTr_RawRespSI(NonRevTr_ActChoices == 1,:)) - ...
    mean(NonRevTr_RawRespSI(NonRevTr_ActChoices == 0,:));

figure;hold on
hdf3 = plot(xTimes, NBSData_LRSI_diff,'Color','k','linewidth',1.2);
hdf4 = plot(xTimes, NRespData_LRSI_diff,'Color',[0.8 0.5 0.2],'linewidth',1.2);

%% plot the response according to the blocktype

hf5 = figure;
hold on
[~,~,hl9] = MeanSemPlot(RevTr_BSData_SI(RevTr_ActChoices == 0 & RevTr_BTs == 0,:),...
    xTimes,hf5,0.5,[1 0.4 0.4],'b','linewidth',1);
[~,~,hl10] = MeanSemPlot(RevTr_BSData_SI(RevTr_ActChoices == 1 & RevTr_BTs == 0,:),...
    xTimes,hf5,0.5,[0.4 0.4 1],'r','linewidth',1);

[~,~,hl11] = MeanSemPlot(RevTr_BSData_SI(RevTr_ActChoices == 0 & RevTr_BTs == 1,:),...
    xTimes,hf5,0.5,[1 0.4 0.4],'color','c','linewidth',1.4);
[~,~,hl12] = MeanSemPlot(RevTr_BSData_SI(RevTr_ActChoices == 1 & RevTr_BTs == 1,:),...
    xTimes,hf5,0.5,[0.4 0.4 1],'color','m','linewidth',1.4);


%%
hf6 = figure;
hold on
[~,~,hl9] = MeanSemPlot(RevTr_RawRespSI(RevTr_ActChoices == 0 & RevTr_BTs == 0,:),...
    xTimes,hf6,0.5,[1 0.4 0.4],'b','linewidth',1);
[~,~,hl10] = MeanSemPlot(RevTr_RawRespSI(RevTr_ActChoices == 1 & RevTr_BTs == 0,:),...
    xTimes,hf6,0.5,[0.4 0.4 1],'r','linewidth',1);

[~,~,hl11] = MeanSemPlot(RevTr_RawRespSI(RevTr_ActChoices == 0 & RevTr_BTs == 1,:),...
    xTimes,hf6,0.5,[1 0.4 0.4],'color','c','linewidth',1.4);
[~,~,hl12] = MeanSemPlot(RevTr_RawRespSI(RevTr_ActChoices == 1 & RevTr_BTs == 1,:),...
    xTimes,hf6,0.5,[0.4 0.4 1],'color','m','linewidth',1.4);







