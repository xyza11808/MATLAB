cclr
[fn,fp,fi] = uigetfile('*.txt','Please select the compasison session path file');
if ~fi
    return;  
end 
fPath = fullfile(fp,fn);
%%
fid = fopen(fPath);
tline = fgetl(fid);
SessType = 0;
SessPathAll = {};
m = 1;
while ischar(tline)
    if ~isempty(strfind(tline,'######')) % new section flag
        SessType = SessType + 1;
        tline = fgetl(fid);
        continue;
    end
    if ~isempty(strfind(tline,'NO_Correction\mode_f_change'))
        SessPathAll{m,1} = tline;
        SessPathAll{m,2} = SessType;
        
        [~,EndInds] = regexp(tline,'test\d{2,3}');
        cPassDataUpperPath = fullfile(sprintf('%srf',tline(1:EndInds)),'im_data_reg_cpu','result_save');
        
        [~,InfoDataEndInds] = regexp(tline,'result_save');
        PassPathline = fullfile(sprintf('%srf%s',tline(1:EndInds),tline(EndInds+1:InfoDataEndInds)),'plot_save','NO_Correction');
        SessPathAll{m,3} = PassPathline;
        
        m = m + 1;
    end
    tline = fgetl(fid);
end
SessIndexAll = cell2mat(SessPathAll(:,2));
%% processing 8k-32k and 4k-16k sessions data
Sess8_32_Inds = SessIndexAll == 4;
Sess8_32PathAll = SessPathAll(Sess8_32_Inds,1);

Sess4_16_Part1_Inds = SessIndexAll == 3;
Sess4_16_Part1_PathAll = SessPathAll(Sess4_16_Part1_Inds,1);

if length(Sess4_16_Part1_PathAll) ~= length(Sess8_32PathAll)
    warning('The session path number is different, please check your input data.\n');
    return;
end
%
NumPaths = length(Sess4_16_Part1_PathAll);
FieldChangeDataAll = cell(NumPaths,6);
FieldChangePos816 = cell(NumPaths,2);
IndexedFieldChange = cell(NumPaths,4);
OctIndexFieldChange = cell(NumPaths,2);
SameDiffCoefDataSummary = cell(NumPaths,10);
%%
for cPath = 1 : NumPaths
    %
%     cPath = 1;
    c832Path = Sess8_32PathAll{cPath};
    c416Path = Sess4_16_Part1_PathAll{cPath};
    
    cSess832Path = fullfile(c832Path,'Tunning_fun_plot_New1s','NMTuned Meanfreq colormap plot','TaskPassBFDis.mat');
    try
        cSess832TunStrc = load(fullfile(c832Path,'Tunning_fun_plot_New1s','TunningSTDDataSave.mat'),'CorrTunningFun','PassTunningfun');
    catch
        cSess832TunStrc = load(fullfile(c832Path,'Tunning_fun_plot_New1s','TunningDataSave.mat'),'CorrTunningFun','PassTunningfun');
    end
    cSess832TunData = load(cSess832Path);
    cSess832BehavStrc = load(fullfile(c832Path,'RandP_data_plots','boundary_result.mat'));
    try
        cSess832ToneBound = cSess832BehavStrc.boundary_result.FitValue.u;
    catch
        cSess832ToneBound = cSess832BehavStrc.boundary_result.FitValue.ffit.u;
    end
        
    cSess832StimOct = log2(cSess832BehavStrc.boundary_result.StimType/min(cSess832BehavStrc.boundary_result.StimType));
    NearBoundInds = abs(cSess832StimOct - cSess832ToneBound) <= 0.4;
    
    cSess416Path = fullfile(c416Path,'Tunning_fun_plot_New1s','NMTuned Meanfreq colormap plot','TaskPassBFDis.mat');
    try
        cSess416TunStrc = load(fullfile(c416Path,'Tunning_fun_plot_New1s','TunningSTDDataSave.mat'),'CorrTunningFun','PassTunningfun');
    catch
        cSess416TunStrc = load(fullfile(c416Path,'Tunning_fun_plot_New1s','TunningDataSave.mat'),'CorrTunningFun','PassTunningfun');
    end
    cSess416TunData = load(cSess416Path);
    cSess416BehavStrc = load(fullfile(c416Path,'RandP_data_plots','boundary_result.mat'));
    try
        cSess416ToneBound = cSess416BehavStrc.boundary_result.FitValue.u;
    catch
        cSess416ToneBound = cSess416BehavStrc.boundary_result.FitValue.ffit.u;
    end
    cSess416StimOct = log2(cSess416BehavStrc.boundary_result.StimType/min(cSess416BehavStrc.boundary_result.StimType));
    cSess416NearBoundInds = abs(cSess416StimOct - cSess416ToneBound) <= 0.4;
    
    Sess832ROIIndexFile = fullfile(c832Path,'Tunning_fun_plot_New1s','SelectROIIndex.mat');
    Sess416ROIIndexFile = fullfile(c416Path,'Tunning_fun_plot_New1s','SelectROIIndex.mat');
    
    cSess832DataStrc = load(Sess832ROIIndexFile);
    cSess416DataStrc = load(Sess416ROIIndexFile);
    
    CommonROINum = min(numel(cSess832DataStrc.ROIIndex),numel(cSess416DataStrc.ROIIndex));
    CommonROIIndex = cSess832DataStrc.ROIIndex(1:CommonROINum) & cSess416DataStrc.ROIIndex(1:CommonROINum);
    
    % response field change analysis
    cd(c832Path);
    c832BoundIndex = cSess832ToneBound/max(cSess832StimOct)*(numel(cSess832StimOct) - 1) + 1;
    [FieldChange,FieldChangeWithIndex832,c832TPCoefDiff,FieldChangeMtx] = TuningfieldChangeFun(c832Path,numel(cSess832DataStrc.ROIIndex),CommonROIIndex,c832BoundIndex);
    NearFieldChangeAll = cell2mat((FieldChange(NearBoundInds))');
    FarFieldChangeAll = cell2mat((FieldChange(~NearBoundInds))');
    FieldChangeDataAll{cPath,1} = NearFieldChangeAll;
    FieldChangeDataAll{cPath,2} = FarFieldChangeAll;
    NoChangeNearInds = abs(cSess832StimOct(c832TPCoefDiff(:,3)) - cSess832ToneBound) <= 0.4;
    FieldChangeDataAll{cPath,5} = [c832TPCoefDiff,NoChangeNearInds(:)];
    FieldChange(:,4) = mat2cell(cSess832StimOct(:) - 1,ones(numel(cSess832StimOct),1));
    OctIndexFieldChange{cPath,1} = FieldChange;
    
    FieldChangeOctDis = abs(cSess832StimOct(FieldChangeWithIndex832(:,2)) - cSess832ToneBound);
    FieldChangePos816{cPath,1} = [FieldChangeWithIndex832(:,1),FieldChangeOctDis(:)];
    IndexedFieldChange{cPath,1} = FieldChangeMtx;
    IndexedFieldChange{cPath,2} = cSess832BehavStrc.boundary_result.StimCorr;
    %
    TaskRespCoefMtx = FieldChangeMtx.TaskRespField;
    PassRespCoefMtx = FieldChangeMtx.PassRespField;
    TaskNullCoefInds = sum(TaskRespCoefMtx,2) == 0;
    TaskNullCoefROIs = FieldChangeMtx.RespROIIndex(TaskNullCoefInds);
    TaskNullCoefTunData = (cSess832TunStrc.CorrTunningFun(:,TaskNullCoefROIs))';
    TaskCoefTunMixedMtx = TaskRespCoefMtx;
    TaskCoefTunMixedMtx(TaskNullCoefInds,:) = TaskNullCoefTunData;
    
    PassNullCoefInds = sum(PassRespCoefMtx,2) == 0;
    PassNullCoefROIs = FieldChangeMtx.RespROIIndex(PassNullCoefInds);
    PassNullCoefTunData = (cSess832TunStrc.PassTunningfun(:,PassNullCoefROIs))';
    PassCoefTunMixedMtx = PassRespCoefMtx;
    PassCoefTunMixedMtx(PassNullCoefInds,:) = PassNullCoefTunData;
    %
    [~,TaskMixedMtxBFInds] = max(TaskCoefTunMixedMtx,[],2);
    [~,PassMixedMtxBFInds] = max(PassCoefTunMixedMtx,[],2);
    SameBFInds = TaskMixedMtxBFInds == PassMixedMtxBFInds;
    SameBFTaskCoefMtx = TaskRespCoefMtx; % will exlcude BF coef value
    SameBFPassCoefMtx = PassRespCoefMtx; % will exlcude BF coef value
    DiffBFCoefBF = zeros(length(SameBFInds),2);
    for cIsSameInds = 1 : length(SameBFInds)
        cIsSame = SameBFInds(cIsSameInds);
        if cIsSame  % same BF for both context
            SameBFTaskCoefMtx(cIsSameInds,TaskMixedMtxBFInds(cIsSameInds)) = 0;
            SameBFPassCoefMtx(cIsSameInds,TaskMixedMtxBFInds(cIsSameInds)) = 0;
        else
            DiffBFCoefBF(cIsSameInds,:) = [TaskMixedMtxBFInds(cIsSameInds),PassMixedMtxBFInds(cIsSameInds)];
        end
    end
    
     % response field change analysis
    cd(c416Path);
    c416BoundIndex = cSess416ToneBound/max(cSess416StimOct)*(numel(cSess416StimOct) - 1) + 1;
    [FieldChange416, FieldChangeWithIndex416, c416TPCoefDiff,FieldChangeMtx416] = TuningfieldChangeFun(c416Path,numel(cSess416DataStrc.ROIIndex),CommonROIIndex,c416BoundIndex);
    NearFieldChangeAll416 = cell2mat((FieldChange416(cSess416NearBoundInds))');
    FarFieldChangeAll416 = cell2mat((FieldChange416(~cSess416NearBoundInds))');
    FieldChangeDataAll{cPath,3} = NearFieldChangeAll416;
    FieldChangeDataAll{cPath,4} = FarFieldChangeAll416;
    NoChangeNearInds416 = abs(cSess416StimOct(c416TPCoefDiff(:,3)) - cSess416ToneBound) <= 0.4;
    FieldChangeDataAll{cPath,6} = [c416TPCoefDiff,NoChangeNearInds416(:)];
    
    FieldChangeOctDis416 = abs(cSess416StimOct(FieldChangeWithIndex416(:,2)) - cSess416ToneBound);
    FieldChangePos816{cPath,2} = [FieldChangeWithIndex416(:,1),FieldChangeOctDis416(:)];
    IndexedFieldChange{cPath,3} = FieldChangeMtx416;
    IndexedFieldChange{cPath,4} = cSess416BehavStrc.boundary_result.StimCorr;
    FieldChange416(:,4) = mat2cell(cSess416StimOct(:) - 1,ones(numel(cSess416StimOct),1));
    OctIndexFieldChange{cPath,2} = FieldChange416;
    
     %
    TaskRespCoefMtx = FieldChangeMtx416.TaskRespField;
    PassRespCoefMtx = FieldChangeMtx416.PassRespField;
    TaskNullCoefInds = sum(TaskRespCoefMtx,2) == 0;
    TaskNullCoefROIs = FieldChangeMtx416.RespROIIndex(TaskNullCoefInds);
    TaskNullCoefTunData = (cSess832TunStrc.CorrTunningFun(:,TaskNullCoefROIs))';
    TaskCoefTunMixedMtx = TaskRespCoefMtx;
    TaskCoefTunMixedMtx(TaskNullCoefInds,:) = TaskNullCoefTunData;
    
    PassNullCoefInds = sum(PassRespCoefMtx,2) == 0;
    PassNullCoefROIs = FieldChangeMtx416.RespROIIndex(PassNullCoefInds);
    PassNullCoefTunData = (cSess832TunStrc.PassTunningfun(:,PassNullCoefROIs))';
    PassCoefTunMixedMtx = PassRespCoefMtx;
    PassCoefTunMixedMtx(PassNullCoefInds,:) = PassNullCoefTunData;
    %
    [~,TaskMixedMtxBFInds] = max(TaskCoefTunMixedMtx,[],2);
    [~,PassMixedMtxBFInds] = max(PassCoefTunMixedMtx,[],2);
    SameBFInds = TaskMixedMtxBFInds == PassMixedMtxBFInds;
    SameBFTaskCoefMtx416 = TaskRespCoefMtx; % will exlcude BF coef value
    SameBFPassCoefMtx416 = PassRespCoefMtx; % will exlcude BF coef value
    DiffBFCoefBF416 = zeros(length(SameBFInds),2);
    for cIsSameInds = 1 : length(SameBFInds)
        cIsSame = SameBFInds(cIsSameInds);
        if cIsSame  % same BF for both context
            SameBFTaskCoefMtx416(cIsSameInds,TaskMixedMtxBFInds(cIsSameInds)) = 0;
            SameBFPassCoefMtx416(cIsSameInds,TaskMixedMtxBFInds(cIsSameInds)) = 0;
        else
            DiffBFCoefBF416(cIsSameInds,:) = [TaskMixedMtxBFInds(cIsSameInds),PassMixedMtxBFInds(cIsSameInds)];
        end
    end
     
     SameDiffCoefDataSummary(cPath,:) = {SameBFTaskCoefMtx, SameBFPassCoefMtx, DiffBFCoefBF,FieldChangeMtx.RespROIIndex, ...
         SameBFTaskCoefMtx416, SameBFPassCoefMtx416, DiffBFCoefBF416, FieldChangeMtx416.RespROIIndex,cSess832ToneBound, cSess416ToneBound};
    
end

%% 
c832NearFieldAll = cell2mat(FieldChangeDataAll(:,1));
c832FarFieldAll = cell2mat(FieldChangeDataAll(:,2));

c416NearFieldAll = cell2mat(FieldChangeDataAll(:,3));
c416FarFieldAll = cell2mat(FieldChangeDataAll(:,4));

c832NearFieldChangedInds = c832NearFieldAll ~= 0;
c832NearFieldChangedData = c832NearFieldAll(c832NearFieldChangedInds);
c832FarFieldCInds = c832FarFieldAll ~= 0;
c832FarFieldCData = c832FarFieldAll(c832FarFieldCInds);

c416NearFieldCInds = c416NearFieldAll ~= 0;
c416NearFieldCData = c416NearFieldAll(c416NearFieldCInds);

c416FarFieldCInds = c416FarFieldAll ~= 0;
c416FarFieldCData = c416FarFieldAll(c416FarFieldCInds);

Sess832Table = table([sum(c832NearFieldChangedData > 0);sum(c832NearFieldChangedData < 0)],...
    [sum(c832FarFieldCData > 0);sum(c832FarFieldCData < 0)],'VariableNames',{'c832Near','c832Far'},'RowNames',{'Pos','Neg'});
Sess416Table = table([sum(c416NearFieldCData> 0);sum(c416NearFieldCData< 0)],...
    [sum(c416FarFieldCData > 0);sum(c416FarFieldCData < 0)],'VariableNames',{'c416Near','c416Far'},'RowNames',{'Pos','Neg'});
SummaryMtx = table2array(Sess832Table) + table2array(Sess416Table);
SummaryTable = table(SummaryMtx(:,1),SummaryMtx(:,2),'VariableNames',{'Near','Far'},'RowNames',{'Pos','Neg'});

%%
IndexedFieldChangeBU = IndexedFieldChange;
IDFields = cellfun(@(x) Six2eightFun(x.RespFieldMtx),IndexedFieldChange(:,1),'UniformOutput',false);
IDFieldsmask = cellfun(@(x) Six2eightFun(x.RespFieldMask),IndexedFieldChange(:,1),'UniformOutput',false);
PassRespAlls = cellfun(@(x) Six2eightFun(x.PassRespField),IndexedFieldChange(:,1),'UniformOutput',false);
for css = 1 : length(IDFields)
    cssBehav = IndexedFieldChange{css,2};
    if length(cssBehav) == 6
        NewcssBehav = nan(1,8);
        NewcssBehav(1:3) = cssBehav(1:3);
        NewcssBehav(6:8) = cssBehav(4:6);
    else
        NewcssBehav = cssBehav;
    end
    IndexedFieldChange{css,2} = NewcssBehav;
end
SessBehavsMtx = cell2mat(IndexedFieldChange(:,2));
%
IDFieldsMtx = cell2mat(IDFields);
IDFieldsMaskMtx = cell2mat(IDFieldsmask);

IndexTypesAll = size(IDFieldsMtx,2);
for cInds = 1 : IndexTypesAll
    cIndsMasks = IDFieldsMaskMtx(:,cInds);
    cIndsMtx = IDFieldsMtx(:,cInds);
    
    cIndsRealMtx = cIndsMtx(cIndsMasks);
    cIndsRealMtxPos = binofit(sum(cIndsRealMtx == 1),numel(cIndsRealMtx));
    
    IndexTypesAll(cInds) = cIndsRealMtxPos;
end
AvgBehavs = mean(SessBehavsMtx,'omitnan');
figure;
plot(AvgBehavs);
yyaxis right
plot(IndexTypesAll)

% PassRespAllMtx = cell2mat(PassRespAlls);
% PassRespInds = sum(PassRespAllMtx,2,'omitnan') > 0;
% PassRespSigMtx = PassRespAllMtx(PassRespInds,:);
% figure;
% plot(mean(PassRespSigMtx > 0))

%% calculate the octive distance and filed change
c832FieldChange_pos_All = cell2mat(FieldChangePos816(:,1));
DecreaseFieldInds = c832FieldChange_pos_All(:,1) == -1;
DecreaseFieldDis = c832FieldChange_pos_All(DecreaseFieldInds,2);
[DecreaseFieldDisy,DecreaseFieldDisx] = hist(DecreaseFieldDis,15);

NoChangeDis = c832FieldChange_pos_All(c832FieldChange_pos_All(:,1) == 0,2);
[NoChangeDisy,NoChangeDisx] = hist(NoChangeDis,15);

IncreaseFieldDis = c832FieldChange_pos_All(c832FieldChange_pos_All(:,1) == 1,2);
[IncreaseFieldDisy,IncreaseFieldDisx] = hist(IncreaseFieldDis,15);

hf = figure('position',[100 100 380 300]);
hold on
hl1 = plot(DecreaseFieldDisx,DecreaseFieldDisy/numel(DecreaseFieldDis),'Color',[0.2 0.2 0.8],'linewidth',2);
hl2 = plot(NoChangeDisx,NoChangeDisy/numel(NoChangeDis),'Color',[0.4 0.4 0.4],'linewidth',2);
hl3 = plot(IncreaseFieldDisx,IncreaseFieldDisy/numel(IncreaseFieldDis),'Color',[0.8 0.2 0.2],'linewidth',2);

saveas(hf,'C716_728 session resp-field change vs BoundDistance','png')
saveas(hf,'C716_728 session resp-field change vs BoundDistance','pdf')
saveas(hf,'C716_728 session resp-field change vs BoundDistance')

%%
UsedSess = 1;
nSess = size(IndexedFieldChange,1);
SessIndexNum = cell(nSess,2);
for css = 1 : nSess
    csRespField = IndexedFieldChange{css,UsedSess}.RespFieldMtx;
    csSessBehav = IndexedFieldChange{css,UsedSess+1}; % behav difficulty
    csSessRespFieldMask = IndexedFieldChange{css,UsedSess}.RespFieldMask;
    NonNanInds = find(~isnan(csSessBehav));
    NonNanIndTypeNum = zeros(length(NonNanInds),3);
    for cNaN = 1 : length(NonNanInds)
        cIndsPosNum = sum(csRespField(:,cNaN) == 1);
        cIndsNegNum = sum(csRespField(:,cNaN) == -1);
%         cIndsModuNum = sum(csSessRespFieldMask(:,cNaN));
        cIndsModuNum = size(csRespField,1);
        NonNanIndTypeNum(cNaN,:) = [cIndsPosNum,cIndsNegNum,cIndsModuNum];
    end
    
    SessIndexNum{css,1} = NonNanIndTypeNum;
    SessIndexNum{css,2} = (csSessBehav(NonNanInds))';
end
%
SessBehavsAll = cell2mat(SessIndexNum(:,2));
SsssPosNumCell = cellfun(@(x) x(:,1),SessIndexNum(:,1),'uniformOutput',false);
SsssPosNumAll = cell2mat(SsssPosNumCell);
SsssNegNumCell = cellfun(@(x) x(:,2),SessIndexNum(:,1),'uniformOutput',false);
SsssNegNumAll = cell2mat(SsssNegNumCell);
SsssFieldNumCell = cellfun(@(x) x(:,3),SessIndexNum(:,1),'uniformOutput',false);
SsssFieldNumAll = cell2mat(SsssFieldNumCell);

ZeroNumInds = ~(SsssFieldNumAll < 3);
NZeroBehavAll = SessBehavsAll(ZeroNumInds);
NZeroPosNumAll = SsssPosNumAll(ZeroNumInds);
NZeroNegNumAll = SsssNegNumAll(ZeroNumInds);
NZeroFieldNumAll = SsssFieldNumAll(ZeroNumInds);

NZeroPosProb = binofit(NZeroPosNumAll,NZeroFieldNumAll);
NZeroNegProb = binofit(NZeroNegNumAll,NZeroFieldNumAll);

hf = figure('position',[100 100 420 350]);
hold on
plot(NZeroBehavAll,NZeroPosProb,'ro');
plot(NZeroBehavAll,NZeroNegProb,'bo');

%%
BehavBin = 0:0.05:1;
nBins = length(BehavBin);
BinDatas = zeros(nBins,4);
IsBinZeroData = zeros(nBins,1);
for cBin = 1 : nBins-1
    cBinInds = NZeroBehavAll >= BehavBin(cBin) & NZeroBehavAll < BehavBin(cBin+1);
    cPosData = NZeroPosProb(cBinInds);
    
    if ~isempty(cPosData)
        IsBinZeroData(cBin) = 1;
        BinDatas(cBin,1) = mean(cPosData);
        BinDatas(cBin,2) = std(cPosData)/sqrt(numel(cPosData));

        cNegData = NZeroNegProb(cBinInds);
        BinDatas(cBin,3) = mean(cNegData);
        BinDatas(cBin,4) = std(cNegData)/sqrt(numel(cNegData));
    end
end

RealBehavBin = BehavBin(logical(IsBinZeroData));
RealBinPosData = BinDatas(logical(IsBinZeroData),1:2);
RealBinNegData = BinDatas(logical(IsBinZeroData),3:4);

hf = figure('position',[100 100 380 300]);
hold on
errorbar(RealBehavBin,RealBinPosData(:,1),RealBinPosData(:,2),'r-o','linewidth',1.6);
errorbar(RealBehavBin,RealBinNegData(:,1),RealBinNegData(:,2),'b-o','linewidth',1.6);

%%
nSess = 12;
NewRespFieldMtx = IndexedFieldChange{nSess,1}.RespFieldMtx;
mean(NewRespFieldMtx > 0)
mean(NewRespFieldMtx < 0)
IndexedFieldChange{nSess,2}

%%
RespCoefField = cellfun(@(x) x.RespFieldMtx,IndexedFieldChange(:,1),'UniformOutput',false);
TaskCoefCell = cellfun(@(x) x.TaskRespField,IndexedFieldChange(:,1),'UniformOutput',false);
PassCoefCell = cellfun(@(x) x.PassRespField,IndexedFieldChange(:,1),'UniformOutput',false);
RespCoefFieldMtx = cell2mat(RespCoefField);
TaskCoefMtx = cell2mat(TaskCoefCell);
PassCoefMtx = cell2mat(PassCoefCell);
%%
RespCoefField416 = cellfun(@(x) x.RespFieldMtx,IndexedFieldChange(:,3),'UniformOutput',false);
TaskCoefCell416 = cellfun(@(x) x.TaskRespField,IndexedFieldChange(:,3),'UniformOutput',false);
PassCoefCell416 = cellfun(@(x) x.PassRespField,IndexedFieldChange(:,3),'UniformOutput',false);
RespCoefFieldMtx416 = cell2mat(RespCoefField416);
TaskCoefMtx416 = cell2mat(TaskCoefCell416);
PassCoefMtx416 = cell2mat(PassCoefCell416);
%%
NonZeroTaskCoef = TaskCoefMtx416(sum(TaskCoefMtx416,2) ~= 0,:);
[~,MaxInds] = max(NonZeroTaskCoef,[],2);
N = histcounts(MaxInds,0.5:8.5)

%%
n728ROIs = size(RespCoefFieldMtx,1);
RespCoefFieldEnh = sum(RespCoefFieldMtx > 0);
RespCoefFielddec = sum(RespCoefFieldMtx < 0);
RespCoefFieldEnhProb = binofit(RespCoefFieldEnh,n728ROIs);
RespCoefFielddecProb = binofit(RespCoefFielddec,n728ROIs);

n416ROIs = size(RespCoefFieldMtx416,1);
RespCoefFieldEnh416 = sum(RespCoefFieldMtx416 > 0);
RespCoefFielddec416 = sum(RespCoefFieldMtx416 < 0);
RespCoefFieldEnh416Prob = binofit(RespCoefFieldEnh416,n416ROIs);
RespCoefFielddec416Prob = binofit(RespCoefFielddec416,n416ROIs);

c728SessOcts = [0,0.4,0.8,0.9,1.1,1.2,1.6,2]+log2(7/4);
c416SessOcts = [0,0.4,0.8,0.9,1.1,1.2,1.6,2];
c416SessUsedInds = logical([0 0 1 1 1 1 1 1]);
c728SessUsedInds = logical([1 1 1 1 1 1 0 0]);

bound = [1,log2(14/4)];

huf = figure('position',[100 100 380 300]);
hold on
plot(c728SessOcts(c728SessUsedInds),RespCoefFieldEnhProb(c728SessUsedInds),'r-o','linewidth',1.6);
plot(c416SessOcts(c416SessUsedInds),RespCoefFieldEnh416Prob(c416SessUsedInds),'b-o','linewidth',1.6);
plot(c728SessOcts(c728SessUsedInds),RespCoefFielddecProb(c728SessUsedInds),'r-o','linewidth',1.6,'linestyle','--');
plot(c416SessOcts(c416SessUsedInds),RespCoefFielddec416Prob(c416SessUsedInds),'b-o','linewidth',1.6,'linestyle','--');
xlim([0 3])
yscales = get(gca,'ylim');
line([bound(1) bound(1)],yscales,'Color','b','linestyle','--');
line([bound(2) bound(2)],yscales,'Color','r','linestyle','--');

%% summarize all plots for comparison

Plots_Save_path = 'E:\DataToGo\NewDataForXU';
SubDir = 'fieldChangeData';
if ~isdir(fullfile(Plots_Save_path,SubDir))
    mkdir(fullfile(Plots_Save_path,SubDir));
end
SavingPath = fullfile(Plots_Save_path,SubDir);
SessSummaryfileName = 'c728_416Sess_Respfieldsummary.pptx';

Sess8_32_Inds = SessIndexAll == 4;
Sess8_32PathAll = SessPathAll(Sess8_32_Inds,1);
Sess8_32PassPathA = SessPathAll(Sess8_32_Inds,3);

Sess4_16_Part1_Inds = SessIndexAll == 3;
Sess4_16_Part1_PathAll = SessPathAll(Sess4_16_Part1_Inds,1);
Sess4_16_Part1_PassPassA = SessPathAll(Sess4_16_Part1_Inds,3);

if length(Sess4_16_Part1_PathAll) ~= length(Sess8_32PathAll)
    warning('The session path number is different, please check your input data.\n');
    return;
end
%
NumPaths = length(Sess4_16_Part1_PathAll);
%%
pptFullfile = fullfile(SavingPath,SessSummaryfileName);
if ~exist(pptFullfile,'file')
    NewFileExport = 1;
else
    NewFileExport = 0;
end
if NewFileExport
    exportToPPTX('new','Dimensions',[16,9],'Author','XinYu','Comments','Export of tunning curve plot data');
else
    exportToPPTX('open',pptFullfile);
end 

for cPath = 1 : NumPaths
    c832Path = Sess8_32PathAll{cPath};
    c416Path = Sess4_16_Part1_PathAll{cPath};
    
    exportToPPTX('addslide');
    c832PathInfo = SessInfoExtraction(c832Path);
    c416PathInfo = SessInfoExtraction(c416Path);

    c832BehavPath = fullfile(c832Path,'RandP_data_plots','Behav_fit plot.png');
    c416BehavPath = fullfile(c416Path,'RandP_data_plots','Behav_fit plot.png');

    c832CoefMtx = fullfile(c832Path,'Task Passive Coef Summary.png');
    c416CoefMtx = fullfile(c416Path,'Task Passive Coef Summary.png');

    c832CoefDistri = fullfile(c832Path,'Task passive Tuning distribution plots.png');
    c416CoefDistri = fullfile(c416Path,'Task passive Tuning distribution plots.png');

    exportToPPTX('addpicture',imread(c832BehavPath),'Position',[0 5.5 2 1.5]);
    exportToPPTX('addpicture',imread(c832CoefMtx),'Position',[0 0.5 8 4.8]);
    exportToPPTX('addpicture',imread(c832CoefDistri),'Position',[3 5.5 3.5 2.63]);

    exportToPPTX('addpicture',imread(c416BehavPath),'Position',[8 5.5 2 1.5]);
    exportToPPTX('addpicture',imread(c416CoefMtx),'Position',[8 0.5 8 4.8]);
    exportToPPTX('addpicture',imread(c416CoefDistri),'Position',[11 5.5 3.5 2.63]);

    exportToPPTX('addtext',sprintf('Batch:%s Anm: %s \nDate: %s Field: %s',...
        c832PathInfo.BatchNum,c832PathInfo.AnimalNum,c832PathInfo.SessionDate,c832PathInfo.TestNum),...
        'Position',[0 8 4 1],'FontSize',20);
    exportToPPTX('addtext',sprintf('Batch:%s Anm: %s \nDate: %s Field: %s',...
        c416PathInfo.BatchNum,c416PathInfo.AnimalNum,c416PathInfo.SessionDate,c416PathInfo.TestNum),...
        'Position',[8 8 4 1],'FontSize',20);
    exportToPPTX('addtext',sprintf('Sess%d',cPath),'Position',[2 0 2 0.5],'FontSize',20,'Color',[1 0 0]);
    exportToPPTX('addnote',c832Path);
        
end
saveName = exportToPPTX('saveandclose',pptFullfile);
%%

% c716SummaryTable = SummaryTable;
% c816SummaryTable = SummaryTable;

AllSummaryMtx = table2array(c716SummaryTable) + table2array(c816SummaryTable);
AllSummaryTable = table(AllSummaryMtx(:,1),AllSummaryMtx(:,2),'VariableNames',{'Near','Far'},'RowNames',{'Pos','Neg'});
[~,p,Stat] = fishertest(AllSummaryTable);

save FieldChangeDataSave.mat c716SummaryTable c816SummaryTable AllSummaryTable p Stat -v7.3

%% Tuning field change analysis seperately for same BF and different BF analysis
SameBFTaskFieldAlls = cell2mat(SameDiffCoefDataSummary(:,5));
SameBFPassFieldAlls = cell2mat(SameDiffCoefDataSummary(:,6));
EmptyTaskCoefInds = sum(SameBFTaskFieldAlls,2) == 0;
SameBFExtraTaskFields = SameBFTaskFieldAlls(~EmptyTaskCoefInds,:);
SameBFExtraPassFields = SameBFPassFieldAlls(~EmptyTaskCoefInds,:);

hf = figure('position',[2000 100 700 300]);
subplot(121)
imagesc(SameBFExtraTaskFields)

subplot(122)
imagesc(SameBFExtraPassFields)

%% For different BFs, check the tuning position change
DifferBFROIBFs = cell2mat(SameDiffCoefDataSummary(:,3));

NonZeroInds = sum(DifferBFROIBFs,2) > 0;
DifferBFROIAllBFs = DifferBFROIBFs(NonZeroInds,:);
SessROIBoundsCell = cellfun(@(x,y) repmat(x,size(y,1),1),SameDiffCoefDataSummary(:,9),SameDiffCoefDataSummary(:,3),'uniformOutput',false);
SessROIBoundsAll = cell2mat(SessROIBoundsCell);
DifferBFROIsBehavBound = SessROIBoundsAll(NonZeroInds);
Sess832Octaves = [0 0.4 0.8 0.9 1 1.1 1.2 1.6 2];

Differ416BFROIBFs = cell2mat(SameDiffCoefDataSummary(:,7));
NonZero416Inds = sum(Differ416BFROIBFs,2) > 0;
Differ416BFROIAllBFs = Differ416BFROIBFs(NonZero416Inds,:);
Sess416ROIBoundsCell = cellfun(@(x,y) repmat(x,size(y,1),1),SameDiffCoefDataSummary(:,10),SameDiffCoefDataSummary(:,7),'uniformOutput',false);
Sess416ROIBoundsAll = cell2mat(Sess416ROIBoundsCell);
Differ416BFROIBound = Sess416ROIBoundsAll(NonZero416Inds);
Sess416Octaves = [0 0.4 0.8 0.9 1 1.1 1.2 1.6 2];

Sess832TaskOcts = Sess832Octaves(DifferBFROIAllBFs(:,1));
Sess832PassOcts = Sess832Octaves(DifferBFROIAllBFs(:,2));

Sess416TaskOcts = Sess416Octaves(DifferBFROIAllBFs(:,1));
Sess416PassOcts = Sess416Octaves(DifferBFROIAllBFs(:,2));

c832TaskDis = Sess832TaskOcts(:) - DifferBFROIsBehavBound;
c832PassDis = Sess832PassOcts(:) - DifferBFROIsBehavBound;


