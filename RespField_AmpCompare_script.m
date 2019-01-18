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
%%
for cPath = 1 : NumPaths
    %%
    cPath = 1;
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
%%     nCommonInds = numel(CommonInds);
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
        [EitherRespFieldIndexR, EitherRespFieldIndexC] = find(EitherRespFields);
        PassUsedTunData = cSess832TunStrc.PassTunningfun(cSess832TunStrc.PassFreqInds,:);
        PassUsedTunCellData = cSess832TunStrc.PassTunCellData(cSess832TunStrc.PassFreqInds,:);
        RespFieldDatas = cell(numel(EitherRespFieldIndexR),8);
        for cffs = 1 : numel(EitherRespFieldIndexR)
            cROI = EitherRespFieldIndexR(cffs);
            cFIndex = EitherRespFieldIndexC(cffs);
            TaskTunValue = cSess832TunStrc.CorrTunningFun(cFIndex,cROI);
            PassTunValue = PassUsedTunData(cFIndex,cROI);
            
            TaskTunDataAlls = cSess832TunStrc.CorrTunningCellData{cFIndex,cROI};
            PassTunDataAlls = PassUsedTunCellData{cFIndex,cROI};
            
            [~,ppp] = ttest2(TaskTunDataAlls,PassTunDataAlls);
            
            RespFieldDatas(cffs,:) = {cROI,cFIndex,TaskTunValue,PassTunValue,TaskTunDataAlls,PassTunDataAlls,ppp,NearBoundInds(cFIndex)};
        end
    end
   %% 
    
end
