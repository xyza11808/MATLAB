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

%%
Sess8_32_Inds = SessIndexAll == 4;
Sess8_32PathAll = SessPathAll(Sess8_32_Inds,1);
Sess8_32PassPath = SessPathAll(Sess8_32_Inds,3);

Sess4_16_Part1_Inds = SessIndexAll == 3;
Sess4_16_Part1_PathAll = SessPathAll(Sess4_16_Part1_Inds,1);
Sess4_16_Part1_PassPath = SessPathAll(Sess4_16_Part1_Inds,3);

if length(Sess4_16_Part1_PathAll) ~= length(Sess8_32PathAll)
    warning('The session path number is different, please check your input data.\n');
    return;
end

NumPaths = length(Sess8_32PathAll);
c832DataAll = cell(NumPaths,1); 
c416DataAll = cell(NumPaths,1);
% SessTypeNumAll = cell(NumPaths,6);
%%
for cPath = 1 : NumPaths
    %
%     cPath = 1;
    c832Path = Sess8_32PathAll{cPath};
    c416Path = Sess4_16_Part1_PathAll{cPath};
    c832PassPath = Sess8_32PassPath{cPath};
    c416PassPath = Sess4_16_Part1_PassPath{cPath};
    
    cSess832Path = fullfile(c832Path,'Tunning_fun_plot_New1s','NMTuned Meanfreq colormap plot','TaskPassBFDis.mat');
    try
        cSess832TunStrc = load(fullfile(c832Path,'Tunning_fun_plot_New1s','TunningSTDDataSave.mat'),'CorrTunningFun','PassTunningfun',...
            'CorrTunningCellData','PassTunCellData','PassFreqInds');
    catch
        cSess832TunStrc = load(fullfile(c832Path,'Tunning_fun_plot_New1s','TunningDataSave.mat'),'CorrTunningFun','PassTunningfun',...
            'CorrTunningCellData','PassTunCellData','PassFreqInds');
    end
    if ~isfield(cSess832TunStrc,'PassFreqInds')
        cSess832TunStrc.PassFreqInds = 1 : size(cSess832TunStrc.PassTunningfun,1);
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
    n832FreqTypes = length(cSess832StimOct);
    
    cSess416Path = fullfile(c416Path,'Tunning_fun_plot_New1s','NMTuned Meanfreq colormap plot','TaskPassBFDis.mat');
    try
        cSess416TunStrc = load(fullfile(c416Path,'Tunning_fun_plot_New1s','TunningSTDDataSave.mat'),'CorrTunningFun','PassTunningfun',...
            'CorrTunningCellData','PassTunCellData','PassFreqInds');
    catch
        cSess416TunStrc = load(fullfile(c416Path,'Tunning_fun_plot_New1s','TunningDataSave.mat'),'CorrTunningFun','PassTunningfun',...
            'CorrTunningCellData','PassTunCellData','PassFreqInds');
    end
    if ~isfield(cSess416TunStrc,'PassFreqInds')
        cSess416TunStrc.PassFreqInds = 1 : size(cSess416TunStrc.PassTunningfun,1);
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
    n416FreqTypes = length(cSess416StimOct);
    
    Sess832ROIIndexFile = fullfile(c832Path,'Tunning_fun_plot_New1s','SelectROIIndex.mat');
    Sess416ROIIndexFile = fullfile(c416Path,'Tunning_fun_plot_New1s','SelectROIIndex.mat');
    
    cSess832DataStrc = load(Sess832ROIIndexFile);
    cSess416DataStrc = load(Sess416ROIIndexFile);
    
    CommonROINum = min(numel(cSess832DataStrc.ROIIndex),numel(cSess416DataStrc.ROIIndex));
    CommonROIIndex = cSess832DataStrc.ROIIndex(1:CommonROINum) & cSess416DataStrc.ROIIndex(1:CommonROINum);
    
    % processing 832 session datas
    c832SelectROIStrc = load(fullfile(c832Path,'SigSelectiveROIInds.mat'));
    Pass832TunROIStrc = load(fullfile(c832PassPath,'PassCoefMtxSave.mat'));
    cPass832FreqStrc = load(fullfile(c832PassPath,'ROIglmCoefSave.mat'),'FreqTypes');
    cPass832UsedFreqs = cPass832FreqStrc.FreqTypes;
    n832ROIs = numel(cSess832DataStrc.ROIIndex);
    
    TPCommonInds = false(n832ROIs,1);
    TPCommonInds(unique([Pass832TunROIStrc.PassRespROIInds;c832SelectROIStrc.SigROIInds])) = true; % merge all task and passive inds
%     nCommonInds = numel(CommonInds);
    TPCommonInds(CommonROINum+1:end) = false;
    TPCommonInds(1:CommonROINum) = TPCommonInds(1:CommonROINum) & CommonROIIndex(:);
    if n832FreqTypes == length(cPass832UsedFreqs)
        TaskAndPassiveCoefMtx = zeros(numel(TPCommonInds),n832FreqTypes,2); % the third dimension indicates task and passive
        TaskAndPassiveCoefMtx(c832SelectROIStrc.SigROIInds,:,1) = c832SelectROIStrc.SigROICoefMtx;
        TaskAndPassiveCoefMtx(Pass832TunROIStrc.PassRespROIInds,:,2) = Pass832TunROIStrc.PassRespCoefMtx;
        TaskAndPassiveCoefMtx(~TPCommonInds,:,:) = 0;

        TaskRespField = squeeze(TaskAndPassiveCoefMtx(:,:,1)) > 0;
        PassRespField = squeeze(TaskAndPassiveCoefMtx(:,:,2)) > 0;
        EitherRespFields = (TaskRespField | PassRespField);
        
        RespROIInds = sum(EitherRespFields,2) > 0;
        
        TaskRespROITunfield = squeeze(TaskAndPassiveCoefMtx(RespROIInds,:,1));
        PassRespROITunfield = squeeze(TaskAndPassiveCoefMtx(RespROIInds,:,2));
        [TaskRespCoefAmp,TaskRespCoefInds] = max(TaskRespROITunfield,[],2);
        [PassRespCoefAmp,PassRespCoefInds] = max(PassRespROITunfield,[],2);
        SameBFInds = PassRespCoefInds == TaskRespCoefInds & PassRespCoefAmp > 0 & TaskRespCoefAmp > 0;
        BaseSameBFIndsAll = false(numel(RespROIInds),1);
        BaseSameBFIndsAll(RespROIInds) = SameBFInds;
        BaseSameBFFreqIndex = zeros(numel(RespROIInds),1);
        BaseSameBFFreqIndex(RespROIInds) = TaskRespCoefInds;
        
        [EitherRespFieldIndexR, EitherRespFieldIndexC] = find(EitherRespFields);
        PassUsedTunData = cSess832TunStrc.PassTunningfun(cSess832TunStrc.PassFreqInds,:);
        PassUsedTunCellData = cSess832TunStrc.PassTunCellData(cSess832TunStrc.PassFreqInds,:);
        RespFieldDatas = cell(numel(EitherRespFieldIndexR),11);
        for cffs = 1 : numel(EitherRespFieldIndexR)
            cROI = EitherRespFieldIndexR(cffs);
            cFIndex = EitherRespFieldIndexC(cffs);
            TaskTunValue = cSess832TunStrc.CorrTunningFun(cFIndex,cROI);
            PassTunValue = PassUsedTunData(cFIndex,cROI);
            
            IsBFIndex = 0;
            if BaseSameBFIndsAll(cROI)
                if BaseSameBFFreqIndex(cROI) == cFIndex
                    IsBFIndex = 1;
                end
            end
                
            TaskTunDataAlls = cSess832TunStrc.CorrTunningCellData{cFIndex,cROI};
            PassTunDataAlls = PassUsedTunCellData{cFIndex,cROI};
            
            [~,ppp] = ttest2(TaskTunDataAlls,PassTunDataAlls);
            
            RespFieldDatas(cffs,:) = {cROI,cFIndex,TaskTunValue,PassTunValue,TaskTunDataAlls,PassTunDataAlls,ppp,NearBoundInds(cFIndex),...
                cSess832BehavStrc.boundary_result.StimType(:),cPass832UsedFreqs,IsBFIndex};
        end
    end
    c832DataAll{cPath} = RespFieldDatas;
   % processing 416 sessions
   c416SelectROIStrc = load(fullfile(c416Path,'SigSelectiveROIInds.mat'));
    Pass416TunROIStrc = load(fullfile(c416PassPath,'PassCoefMtxSave.mat'));
    cPass416FreqStrc = load(fullfile(c416PassPath,'ROIglmCoefSave.mat'),'FreqTypes');
    cPass416UsedFreqs = cPass416FreqStrc.FreqTypes;
    n416ROIs = numel(cSess416DataStrc.ROIIndex);
    
    TPCommonInds = false(n416ROIs,1);
    TPCommonInds(unique([Pass416TunROIStrc.PassRespROIInds;c416SelectROIStrc.SigROIInds])) = true; % merge all task and passive inds
%     nCommonInds = numel(CommonInds);
    TPCommonInds(CommonROINum+1:end) = false;
    TPCommonInds(1:CommonROINum) = TPCommonInds(1:CommonROINum) & CommonROIIndex(:);
    if n416FreqTypes == length(cPass416UsedFreqs)
        TaskAndPassiveCoefMtx = zeros(numel(TPCommonInds),n416FreqTypes,2); % the third dimension indicates task and passive
        TaskAndPassiveCoefMtx(c416SelectROIStrc.SigROIInds,:,1) = c416SelectROIStrc.SigROICoefMtx;
        TaskAndPassiveCoefMtx(Pass416TunROIStrc.PassRespROIInds,:,2) = Pass416TunROIStrc.PassRespCoefMtx;
        TaskAndPassiveCoefMtx(~TPCommonInds,:,:) = 0;

        TaskRespField = squeeze(TaskAndPassiveCoefMtx(:,:,1)) > 0;
        PassRespField = squeeze(TaskAndPassiveCoefMtx(:,:,2)) > 0;
        EitherRespFields = (TaskRespField | PassRespField);
        
        RespROIInds = sum(EitherRespFields,2) > 0;
        
        
        TaskRespROITunfield = squeeze(TaskAndPassiveCoefMtx(RespROIInds,:,1));
        PassRespROITunfield = squeeze(TaskAndPassiveCoefMtx(RespROIInds,:,2));
        [TaskRespCoefAmp,TaskRespCoefInds] = max(TaskRespROITunfield,[],2);
        [PassRespCoefAmp,PassRespCoefInds] = max(PassRespROITunfield,[],2);
        SameBFInds = PassRespCoefInds == TaskRespCoefInds & PassRespCoefAmp > 0 & TaskRespCoefAmp > 0;
        BaseSameBFIndsAll = false(numel(RespROIInds),1);
        BaseSameBFIndsAll(RespROIInds) = SameBFInds;
        BaseSameBFFreqIndex = zeros(numel(RespROIInds),1);
        BaseSameBFFreqIndex(RespROIInds) = TaskRespCoefInds;
        
        [EitherRespFieldIndexR, EitherRespFieldIndexC] = find(EitherRespFields);
        PassUsedTunData = cSess416TunStrc.PassTunningfun(cSess416TunStrc.PassFreqInds,:);
        PassUsedTunCellData = cSess416TunStrc.PassTunCellData(cSess416TunStrc.PassFreqInds,:);
        RespField416Datas = cell(numel(EitherRespFieldIndexR),11);
        for cffs = 1 : numel(EitherRespFieldIndexR)
            cROI = EitherRespFieldIndexR(cffs);
            cFIndex = EitherRespFieldIndexC(cffs);
            TaskTunValue = cSess416TunStrc.CorrTunningFun(cFIndex,cROI);
            PassTunValue = PassUsedTunData(cFIndex,cROI);
            
            IsBFIndex = 0;
            if BaseSameBFIndsAll(cROI)
                if BaseSameBFFreqIndex(cROI) == cFIndex
                    IsBFIndex = 1;
                end
            end
            
            TaskTunDataAlls = cSess416TunStrc.CorrTunningCellData{cFIndex,cROI};
            PassTunDataAlls = PassUsedTunCellData{cFIndex,cROI};
            
            [~,ppp] = ttest2(TaskTunDataAlls,PassTunDataAlls);
            
            RespField416Datas(cffs,:) = {cROI,cFIndex,TaskTunValue,PassTunValue,TaskTunDataAlls,PassTunDataAlls,ppp,cSess416NearBoundInds(cFIndex),...
                cSess416BehavStrc.boundary_result.StimType(:),cPass416UsedFreqs,IsBFIndex};
        end
    end
   c416DataAll{cPath} = RespField416Datas;
%    % c832 sessions
%     [~,c832NearNumCol,c832NearBFNumCol] = AmpComparePlots(cell2mat(RespFieldDatas(:,3)),cell2mat(RespFieldDatas(:,4)),cell2mat(RespFieldDatas(:,7)),...
%     cell2mat(RespFieldDatas(:,8)),[],1000,cell2mat(RespFieldDatas(:,11)));
%     [~,c832FarNumCol,c832FarBFNumCol] = AmpComparePlots(cell2mat(RespFieldDatas(:,3)),cell2mat(RespFieldDatas(:,4)),cell2mat(RespFieldDatas(:,7)),...
%     ~cell2mat(RespFieldDatas(:,8)),[],1000,cell2mat(RespFieldDatas(:,11)));
%     c832DataStrc = struct();
%     c832DataStrc.NearNumCol = c832NearNumCol;
%     c832DataStrc.NearBFNumCol = c832NearBFNumCol;
%     c832DataStrc.FarNumCol = c832FarNumCol;
%     c832DataStrc.FarBFNumCol = c832FarBFNumCol;
%     ChiSquare_p832 = ChiSqureProbTest(c832NearNumCol(1:2),c832FarNumCol(1:2));
%     % c416 sessions
%     [~,c416NearNumCol,c416NearBFNumCol] = AmpComparePlots(cell2mat(RespField416Datas(:,3)),cell2mat(RespField416Datas(:,4)),cell2mat(RespField416Datas(:,7)),...
%     cell2mat(RespField416Datas(:,8)),[],1000,cell2mat(RespField416Datas(:,11)));
%     [~,c416FarNumCol,c416FarBFNumCol] = AmpComparePlots(cell2mat(RespField416Datas(:,3)),cell2mat(RespField416Datas(:,4)),cell2mat(RespField416Datas(:,7)),...
%     ~cell2mat(RespField416Datas(:,8)),[],1000,cell2mat(RespField416Datas(:,11)));
%     c416DataStrc = struct();
%     c416DataStrc.NearNumCol = c416NearNumCol;
%     c416DataStrc.NearBFNumCol = c416NearBFNumCol;
%     c416DataStrc.FarNumCol = c416FarNumCol;
%     c416DataStrc.FarBFNumCol = c416FarBFNumCol;
%     ChiSquare_p416 = ChiSqureProbTest(c416NearNumCol(1:2),c416FarNumCol(1:2));
%     
%     SessTypeNumAll(cPath,:) = {c832DataStrc,ChiSquare_p832,[c832NearNumCol(1)/c832NearNumCol(2),c832FarNumCol(1)/c832FarNumCol(2)],...
%         c416DataStrc,ChiSquare_p416,[c416NearNumCol(1)/c416NearNumCol(2),c416FarNumCol(1)/c416FarNumCol(2)]};
end

%% summarized plots

c728Datas = cat(1,c416DataAll{:});

IsNearBoundField = cell2mat(c728Datas(:,8));
TaskfieldResp = cell2mat(c728Datas(:,3));
PassfieldResp = cell2mat(c728Datas(:,4));
TPDiffP_value = cell2mat(c728Datas(:,7));
SessIsBFfield = cell2mat(c728Datas(:,11));

[hNearf,NearNumCol,NearBFNumCol] = AmpComparePlots(TaskfieldResp,PassfieldResp,TPDiffP_value,IsNearBoundField,[],1000,SessIsBFfield);
title('Near fields');
close(hNearf);
[hFarf,FarNumCol,FarBFNumCol] = AmpComparePlots(TaskfieldResp,PassfieldResp,TPDiffP_value,~IsNearBoundField,[],1000,SessIsBFfield);
title('Far fields');
close(hFarf);

% disp(NearNumCol')
% disp(FarNumCol')
NoBFNearNums = NearNumCol - NearBFNumCol;
NoBFFarNums = FarNumCol - FarBFNumCol;
ChiSquare_p = ChiSqureProbTest(NoBFNearNums,NoBFFarNums)
ChiSquare_p = ChiSqureProbTest(NoBFNearNums(1:2),NoBFFarNums(1:2))
%% c832SessDataAll c816SessDataAll c728SessDataAll c716SessDataAll

c832SessDatas = cat(1,c832SessDataAll{:});
c816SessDatas = cat(1,c816SessDataAll{:});
c728SessDatas = cat(1,c728SessDataAll{:});
c716SessDatas = cat(1,c716SessDataAll{:});

MergedSessData = {c832SessDatas,c816SessDatas,c728SessDatas,c716SessDatas};
MergeSessDataStrc = cell(4,1);
TypeNumAlls = cell(1,4);
ChiTestData = zeros(3,4);
TypeNumSummation = zeros(3,2);
BFTypeNumSummation = zeros(3,2);
for cSess = 1 : 4
    %
    TempDataStrc = struct();
    cData = MergedSessData{cSess};
    TempDataStrc.IsNearBound = cell2mat(cData(:,8));
    TempDataStrc.TaskFieldResp = cell2mat(cData(:,3));
    TempDataStrc.PassfieldResp = cell2mat(cData(:,4));
    TempDataStrc.TPDiffP_value = cell2mat(cData(:,7));
    TempDataStrc.IsBFIndex = cell2mat(cData(:,11));
    MergeSessDataStrc{cSess} = TempDataStrc;
    
    [hNearf,NearNumCol,NearBFNumCol] = AmpComparePlots(TempDataStrc.TaskFieldResp,TempDataStrc.PassfieldResp,...
        TempDataStrc.TPDiffP_value,TempDataStrc.IsNearBound,[],1000,TempDataStrc.IsBFIndex);
    title(sprintf('Near fields Sess %d',cSess));
    [hFarf,FarNumCol,FarBFNumCol] = AmpComparePlots(TempDataStrc.TaskFieldResp,TempDataStrc.PassfieldResp,...
        TempDataStrc.TPDiffP_value,~TempDataStrc.IsNearBound,[],1000,TempDataStrc.IsBFIndex);
    title(sprintf('Far fields Sess %d',cSess));
    TypeNumAlls{1,cSess} = [NearNumCol,FarNumCol];
    TypeNumSummation = TypeNumSummation + TypeNumAlls{1,cSess};
    BFTypeNumSummation = BFTypeNumSummation + TypeNumAlls{1,cSess} - [NearBFNumCol,FarBFNumCol];
%     TypeNumAlls{2,cSess} = FarNumCol;
    close(hNearf);
    close(hFarf);
    
    ChiSquare_p = ChiSqureProbTest(NearNumCol(1:2),FarNumCol(1:2));
    ChiTestData(:,cSess) = [NearNumCol(1)/NearNumCol(2),FarNumCol(1)/FarNumCol(2),ChiSquare_p];
end

