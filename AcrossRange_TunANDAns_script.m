% across freq range tuning and answer ROIs check
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
%
Plots_Save_path = 'E:\DataToGo\NewDataForXU\CellTypeSummary';
SubDir = 'c728_416Sess_summary';
if ~isdir(fullfile(Plots_Save_path,SubDir))
    mkdir(fullfile(Plots_Save_path,SubDir));
end
SaveFolderPath = fullfile(Plots_Save_path,SubDir);
SameTunROISumms = cell(NumPaths,2);
for cPath = 1 : NumPaths
    %
%     cPath = 1;
    c832Path = Sess8_32PathAll{cPath};
    c416Path = Sess4_16_Part1_PathAll{cPath};
    c832PassPath = Sess8_32PassPathA{cPath};
    c416PassPath = Sess4_16_Part1_PassPassA{cPath};
    
    cSess832Path = fullfile(c832Path,'Tunning_fun_plot_New1s','NMTuned Meanfreq colormap plot','TaskPassBFDis.mat');
    cSess832TunData = load(cSess832Path);
    cSess416Path = fullfile(c416Path,'Tunning_fun_plot_New1s','NMTuned Meanfreq colormap plot','TaskPassBFDis.mat');
    cSess416TunData = load(cSess416Path);
    
    Sess832ROIIndexFile = fullfile(c832Path,'Tunning_fun_plot_New1s','SelectROIIndex.mat');
    Sess416ROIIndexFile = fullfile(c416Path,'Tunning_fun_plot_New1s','SelectROIIndex.mat');
    
    Sess832BehavStrc = load(fullfile(c832Path,'RandP_data_plots','boundary_result.mat'));
    Sess416BehavStrc = load(fullfile(c416Path,'RandP_data_plots','boundary_result.mat'));
    
    cSess832DataStrc = load(Sess832ROIIndexFile);
    cSess416DataStrc = load(Sess416ROIIndexFile);
    
    CommonROINum = min(numel(cSess832DataStrc.ROIIndex),numel(cSess416DataStrc.ROIIndex));
    CommonROIIndex = cSess832DataStrc.ROIIndex(1:CommonROINum) & cSess416DataStrc.ROIIndex(1:CommonROINum);
    
%     n832ROIs(cPath) = numel(cSess832DataStrc.ROIIndex);
    % loading Ans response ROI inds
    cSess832SelectROIStrc = load(fullfile(c832Path,'SigSelectiveROIInds.mat'));
    cSess832PassROIStrc = load(fullfile(c832PassPath,'PassCoefMtxSave.mat'));
    FreqsTypes = Sess832BehavStrc.boundary_result.StimType;
    nFreqs = length(FreqsTypes);
    CommonOctRange = log2(FreqsTypes/4000);  % octave within the 4k and 32k range
    c832ROIs = numel(cSess832DataStrc.ROIIndex);
    UsedCoefInds = zeros(c832ROIs,1);
    TaskCoefMtx = zeros(c832ROIs,nFreqs);
    TaskCoefMtx(cSess832SelectROIStrc.SigROIInds,:) = cSess832SelectROIStrc.SigROICoefMtx;
    PassCoefMtx = zeros(c832ROIs,nFreqs);
    PassCoefMtx(cSess832PassROIStrc.PassRespROIInds,:) = cSess832PassROIStrc.PassRespCoefMtx;
    TaskCoefInds = UsedCoefInds;
    TaskCoefInds(cSess832SelectROIStrc.SigROIInds) = 1;
    PassCoefInds = UsedCoefInds;
    PassCoefInds(cSess832PassROIStrc.PassRespROIInds) = 1;
    ComTunInds = TaskCoefInds > 0 & PassCoefInds > 0;
    ComTunInds(~CommonROIIndex) = false;
    ComTunInds(CommonROINum + 1:end) = false;
    ComTunROIIndex = find(ComTunInds); % commonly tuned ROI index
    CommonCoefMtxT = TaskCoefMtx(ComTunInds,:);
    CommonCoefMtxP = PassCoefMtx(ComTunInds,:);
%     SameTunROI = ComTunROIIndex(sum(CommonCoefMtxT == CommonCoefMtxP,2) > 0);
    SameTunROI = ComTunROIIndex(sum(CommonCoefMtxT > 0,2) > 0);
    
    SameTunTaskMtx = TaskCoefMtx(SameTunROI,:);
    SameTunPassMtx = PassCoefMtx(SameTunROI,:);
    [~,TaskBFInds] = max(SameTunTaskMtx,[],2);
    [~,PassBFInds] = max(SameTunPassMtx,[],2);
    SameTunTaskBFs = CommonOctRange(TaskBFInds);
    SameTunPassBFs = CommonOctRange(PassBFInds);
    
    c832FreqOctaveRange = CommonOctRange([1,end]);
    
    %
    
     % loading Ans response ROI inds
    cSess416SelectROIStrc = load(fullfile(c416Path,'SigSelectiveROIInds.mat'));
    cSess416PassROIStrc = load(fullfile(c416PassPath,'PassCoefMtxSave.mat'));
    Freqs416Types = Sess416BehavStrc.boundary_result.StimType;
    nFreqs = length(Freqs416Types);
    CommonOctRange416 = log2(Freqs416Types/4000);  % octave within the 4k and 32k range
    c416ROIs = numel(cSess416DataStrc.ROIIndex);
    UsedCoefInds = zeros(c416ROIs,1);
    TaskCoefMtx = zeros(c416ROIs,nFreqs);
    TaskCoefMtx(cSess416SelectROIStrc.SigROIInds,:) = cSess416SelectROIStrc.SigROICoefMtx;
    PassCoefMtx = zeros(c416ROIs,nFreqs);
    PassCoefMtx(cSess416PassROIStrc.PassRespROIInds,:) = cSess416PassROIStrc.PassRespCoefMtx;
    TaskCoefInds = UsedCoefInds;
    TaskCoefInds(cSess416SelectROIStrc.SigROIInds) = 1;
    PassCoefInds = UsedCoefInds;
    PassCoefInds(cSess416PassROIStrc.PassRespROIInds) = 1;
    ComTunInds = TaskCoefInds > 0 & PassCoefInds > 0;
    ComTunInds(~CommonROIIndex) = false;
    ComTunInds(CommonROINum + 1:end) = false;
    ComTunROIIndex416 = find(ComTunInds); % commonly tuned ROI index
    CommonCoefMtxT416 = TaskCoefMtx(ComTunInds,:);
    CommonCoefMtxP416 = PassCoefMtx(ComTunInds,:);
%     SameTunROI416 = ComTunROIIndex416(sum(CommonCoefMtxT416 == CommonCoefMtxP416,2) > 0);
    SameTunROI416 = ComTunROIIndex416(sum(CommonCoefMtxT416 > 0,2) > 0);
    
    SameTunTask416Mtx = TaskCoefMtx(SameTunROI416,:);
    SameTunPass416Mtx = PassCoefMtx(SameTunROI416,:);
    [~,TaskBFInds] = max(SameTunTask416Mtx,[],2);
    [~,PassBFInds] = max(SameTunPass416Mtx,[],2);
    SameTun416TaskBFs = CommonOctRange416(TaskBFInds);
    SameTun416PassBFs = CommonOctRange416(PassBFInds);
    
    c416FreqOctaveRange = CommonOctRange416([1,end]);
    
    SharedOctRange = [max(c832FreqOctaveRange(1),c416FreqOctaveRange(1)),...
        min(c832FreqOctaveRange(2),c416FreqOctaveRange(2))];
    %
     hf = figure('position',[100 100 850 320]);
     subplot(121)
     imagesc(CommonOctRange,1:numel(SameTunROI),SameTunTaskMtx)
     set(gca,'xtick',CommonOctRange)
     set(gca,'ytick',1:numel(SameTunROI),'yticklabel',SameTunROI)
     title('Session 1');
     
     subplot(122)
     imagesc(CommonOctRange416,1:numel(SameTunROI416),SameTunTask416Mtx)
     set(gca,'xtick',CommonOctRange416)
     set(gca,'ytick',1:numel(SameTunROI416),'yticklabel',SameTunROI416)
     title('Session 2');
     
     saveas(hf,fullfile(SaveFolderPath,sprintf('Sess%d Tuning summary plots.fig',cPath)));
     saveas(hf,fullfile(SaveFolderPath,sprintf('Sess%d Tuning summary plots.png',cPath)));
     close(hf);
    % check the sensory response within same frequency range, either BF or
    % not
    c832WithinShareInds = CommonOctRange >= SharedOctRange(1)-0.02 & CommonOctRange <= SharedOctRange(2)+0.02;
    c416WithinShareInds = CommonOctRange416 >= SharedOctRange(1)-0.02 & CommonOctRange416 <= SharedOctRange(2)+0.02;
    
    c416WRCoefMtx = SameTunTask416Mtx(:,c416WithinShareInds);
    c416WROctaves = CommonOctRange416(c416WithinShareInds);
    
    c832WRROIInds = sum(SameTunTaskMtx(:,c832WithinShareInds),2) > 0;
    c832WROctaves = CommonOctRange(c832WithinShareInds);
    c832WRCoefROIs = SameTunROI(c832WRROIInds); % ROIs showing sigresponse within range
    c832WRROIsCoefMtx = SameTunTaskMtx(c832WRROIInds,c832WithinShareInds); % Coef Matrix
    SameNeuAcrossRange = zeros(numel(c832WRCoefROIs),3);
    for ccR = 1 : numel(c832WRCoefROIs)
        ccRIndex = c832WRCoefROIs(ccR);
        ccRWRCoefs = c832WRROIsCoefMtx(ccR,:);
        [~,MaxInds] = max(ccRWRCoefs);
        ccRSessOcts = c832WROctaves(MaxInds);
        
        if any(SameTunROI416(:) == ccRIndex)
            AnotherSessROIInds = find(SameTunROI416(:) == ccRIndex);
            AnotherSessROIWRCoef = c416WRCoefMtx(AnotherSessROIInds,:);
            if sum(AnotherSessROIWRCoef) % should there be also coef within range
                [~,anoMaxInds] = max(AnotherSessROIWRCoef);
                cAnotherSessOcts = c416WROctaves(anoMaxInds);
                SameNeuAcrossRange(ccR,:) = [ccRIndex,ccRSessOcts,cAnotherSessOcts];
            else
                SameNeuAcrossRange(ccR,:) = [ccRIndex,ccRSessOcts,0];
            end
        end
    end
    SameTunROIInds = SameNeuAcrossRange(:,3) ~= 0;
    if sum(SameTunROIInds)
        SameNeuAcrossRangeSelect = SameNeuAcrossRange(SameTunROIInds,:);
        SameTunROISumms{cPath,1} = SameNeuAcrossRangeSelect;
        SameTunROISumms{cPath,2} = sum(CommonROIIndex);
    end
%     SameNeuAcrossRange = zeros(numel(SameTunROI),5);
%     for cR = 1 : numel(SameTunROI) % loop one session data
%         cRBFs = SameTunTaskBFs(cR);
%         if cRBFs > SharedOctRange(1) && cRBFs < SharedOctRange(2) % if ROI bf within the common freq range
%             cRIndex = SameTunROI(cR);
%             if any(SameTunROI416 == cRIndex) % whether current ROI also exists in another session
%                 AnotherSessInds = find(SameTunROI416 == cRIndex);
%                 SameNeuAcrossRange(cR,:) = [cRIndex,SameTunTaskBFs(cR),SameTunPassBFs(cR),...
%                     SameTun416TaskBFs(AnotherSessInds),SameTun416PassBFs(AnotherSessInds)];
%             end
%         end
%     end
            
    %
end
save(fullfile(SaveFolderPath,'ConstSensROIs.mat'),'SameTunROISumms','-v7.3');

%% check same stimulus different choice side affects neuron response
Sess8_32_Inds = SessIndexAll == 1;
Sess8_32PathAll = SessPathAll(Sess8_32_Inds,1);
Sess8_32PassPathA = SessPathAll(Sess8_32_Inds,3);

Sess4_16_Part1_Inds = SessIndexAll == 2;
Sess4_16_Part1_PathAll = SessPathAll(Sess4_16_Part1_Inds,1);
Sess4_16_Part1_PassPassA = SessPathAll(Sess4_16_Part1_Inds,3);

if length(Sess4_16_Part1_PathAll) ~= length(Sess8_32PathAll)
    warning('The session path number is different, please check your input data.\n');
    return;
end
%
NumPaths = length(Sess4_16_Part1_PathAll);
Plots_Save_path = 'E:\DataToGo\NewDataForXU\CellTypeSummary';
SubDir = 'c832_416Sess_summaryResponse';
if ~isdir(fullfile(Plots_Save_path,SubDir))
    mkdir(fullfile(Plots_Save_path,SubDir));
end
SaveFolderPath = fullfile(Plots_Save_path,SubDir);
SessSummaryfileName = 'c832_416Sess_singleROIsummary.pptx';
%%
pptFullfile = fullfile(SaveFolderPath,SessSummaryfileName);
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
%%
ModuIndexAll = cell(NumPaths,2);
PreferSideAll = cell(NumPaths,1);
MergeROITunDataAll = cell(NumPaths,4);
for cPath = 1 : NumPaths
    %
%     cPath = 1;
    c832Path = Sess8_32PathAll{cPath};
    c416Path = Sess4_16_Part1_PathAll{cPath};
    c832PassPath = Sess8_32PassPathA{cPath};
    c416PassPath = Sess4_16_Part1_PassPassA{cPath};
    
    cSess832Path = fullfile(c832Path,'Tunning_fun_plot_New1s','NMTuned Meanfreq colormap plot','TaskPassBFDis.mat');
    cSess832TunData = load(cSess832Path);
    try
        c832TunData = load(fullfile(c832Path,'Tunning_fun_plot_New1s','TunningSTDDataSave.mat'),'CorrTunningFun',...
            'CorrTunningCellData','PassTunningfun');
    catch
        c832TunData = load(fullfile(c832Path,'Tunning_fun_plot_New1s','TunningDataSave.mat'),'CorrTunningFun',...
            'CorrTunningCellData','PassTunningfun');
    end
    c832AUCData = load(fullfile(c832Path,'Stim_time_Align','ROC_Left2Right_result','ROC_score.mat'));
    
    cSess416Path = fullfile(c416Path,'Tunning_fun_plot_New1s','NMTuned Meanfreq colormap plot','TaskPassBFDis.mat');
    cSess416TunData = load(cSess416Path);
    try
        c416TunData = load(fullfile(c416Path,'Tunning_fun_plot_New1s','TunningSTDDataSave.mat'),'CorrTunningFun',...
            'CorrTunningCellData','PassTunningfun');
    catch
        c416TunData = load(fullfile(c416Path,'Tunning_fun_plot_New1s','TunningDataSave.mat'),'CorrTunningFun',...
            'CorrTunningCellData','PassTunningfun');
    end
    c416AUCData = load(fullfile(c416Path,'Stim_time_Align','ROC_Left2Right_result','ROC_score.mat'));
    
    Sess832ROIIndexFile = fullfile(c832Path,'Tunning_fun_plot_New1s','SelectROIIndex.mat');
    Sess416ROIIndexFile = fullfile(c416Path,'Tunning_fun_plot_New1s','SelectROIIndex.mat');
    
    Sess832BehavStrc = load(fullfile(c832Path,'RandP_data_plots','boundary_result.mat'));
    Sess416BehavStrc = load(fullfile(c416Path,'RandP_data_plots','boundary_result.mat'));
    
    cSess832DataStrc = load(Sess832ROIIndexFile);
    cSess416DataStrc = load(Sess416ROIIndexFile);
    
    CommonROINum = min(numel(cSess832DataStrc.ROIIndex),numel(cSess416DataStrc.ROIIndex));
    CommonROIIndex = cSess832DataStrc.ROIIndex(1:CommonROINum) & cSess416DataStrc.ROIIndex(1:CommonROINum);
    
%     n832ROIs(cPath) = numel(cSess832DataStrc.ROIIndex);
    % loading Ans response ROI inds
    cSess832SelectROIStrc = load(fullfile(c832Path,'SigSelectiveROIInds.mat'));
    cSess832PassROIStrc = load(fullfile(c832PassPath,'PassCoefMtxSave.mat'));
    FreqsTypes = Sess832BehavStrc.boundary_result.StimType;
    nFreqs = length(FreqsTypes);
    CommonOctRange = log2(FreqsTypes/4000);  % octave within the 4k and 32k range
    c832ROIs = numel(cSess832DataStrc.ROIIndex);
%     UsedCoefInds = zeros(c832ROIs,1);
    TaskCoefMtx = zeros(c832ROIs,nFreqs);
    TaskCoefMtx(cSess832SelectROIStrc.SigROIInds,:) = cSess832SelectROIStrc.SigROICoefMtx;
    PassCoefMtx = zeros(c832ROIs,nFreqs);
    PassCoefMtx(cSess832PassROIStrc.PassRespROIInds,:) = cSess832PassROIStrc.PassRespCoefMtx;
%     TaskCoefInds = UsedCoefInds;
%     TaskCoefInds(cSess832SelectROIStrc.SigROIInds) = 1;
%     PassCoefInds = UsedCoefInds;
%     PassCoefInds(cSess832PassROIStrc.PassRespROIInds) = 1;
%     ComTunInds = TaskCoefInds > 0 & PassCoefInds > 0;
%     ComTunInds(~CommonROIIndex) = false;
%     ComTunInds(CommonROINum + 1:end) = false;
    ComTunROIIndex = intersect(cSess832SelectROIStrc.SigROIInds,cSess832PassROIStrc.PassRespROIInds);
%     ComTunROIIndex = find(ComTunInds); % commonly tuned ROI index
    CommonCoefMtxT = TaskCoefMtx(ComTunROIIndex,:);
    CommonCoefMtxP = PassCoefMtx(ComTunROIIndex,:);
    SameTunROI = ComTunROIIndex(sum(CommonCoefMtxT == CommonCoefMtxP,2) > 0);
%     SameTunROI = ComTunROIIndex(sum(CommonCoefMtxT > 0,2) > 0);
    
    SameTunTaskMtx = TaskCoefMtx(SameTunROI,:);
    SameTunPassMtx = PassCoefMtx(SameTunROI,:);
    
    c832FreqOctaveRange = CommonOctRange([1,end]);

     % loading sensory response ROI inds
    cSess416SelectROIStrc = load(fullfile(c416Path,'SigSelectiveROIInds.mat'));
    cSess416PassROIStrc = load(fullfile(c416PassPath,'PassCoefMtxSave.mat'));
    Freqs416Types = Sess416BehavStrc.boundary_result.StimType;
    nFreqs = length(Freqs416Types);
    CommonOctRange416 = log2(Freqs416Types/4000);  % octave within the 4k and 32k range
    c416ROIs = numel(cSess416DataStrc.ROIIndex);
%     UsedCoefInds = zeros(c416ROIs,1);
    TaskCoefMtx = zeros(c416ROIs,nFreqs);
    TaskCoefMtx(cSess416SelectROIStrc.SigROIInds,:) = cSess416SelectROIStrc.SigROICoefMtx;
    PassCoefMtx = zeros(c416ROIs,nFreqs);
    PassCoefMtx(cSess416PassROIStrc.PassRespROIInds,:) = cSess416PassROIStrc.PassRespCoefMtx;
%     TaskCoefInds = UsedCoefInds;
%     TaskCoefInds(cSess416SelectROIStrc.SigROIInds) = 1;
%     PassCoefInds = UsedCoefInds;
%     PassCoefInds(cSess416PassROIStrc.PassRespROIInds) = 1;
%     ComTunInds = TaskCoefInds > 0 & PassCoefInds > 0;
    ComTunROIIndex416 = intersect(cSess416SelectROIStrc.SigROIInds,cSess416PassROIStrc.PassRespROIInds);
    
%     ComTunInds(~CommonROIIndex) = false;
%     ComTunInds(CommonROINum + 1:end) = false;
%     ComTunROIIndex416 = find(ComTunInds); % commonly tuned ROI index
    CommonCoefMtxT416 = TaskCoefMtx(ComTunROIIndex416,:);
    CommonCoefMtxP416 = PassCoefMtx(ComTunROIIndex416,:);
%     SameTunROI416 = ComTunROIIndex416(sum(CommonCoefMtxT416 == CommonCoefMtxP416,2) > 0);
    SameTunROI416 = ComTunROIIndex416(sum(CommonCoefMtxT416 > 0,2) > 0);
    
    SameTunTask416Mtx = TaskCoefMtx(SameTunROI416,:);
    SameTunPass416Mtx = PassCoefMtx(SameTunROI416,:);
    
    c416FreqOctaveRange = CommonOctRange416([1,end]);
    
    SharedOctRange = [max(c832FreqOctaveRange(1),c416FreqOctaveRange(1)),...
        min(c832FreqOctaveRange(2),c416FreqOctaveRange(2))];
    %
     hf = figure('position',[100 100 850 320]);
     subplot(121)
     imagesc(SameTunTaskMtx)
     set(gca,'xtick',1:numel(CommonOctRange),'xticklabel',cellstr(num2str(CommonOctRange(:),'%.1f')));
     set(gca,'ytick',1:numel(SameTunROI),'yticklabel',SameTunROI)
%      xtickangle(-60);
     title('Session 1');
     
     subplot(122)
     imagesc(SameTunTask416Mtx)
     set(gca,'xtick',1:numel(CommonOctRange416),'xticklabel',cellstr(num2str(CommonOctRange416(:),'%.1f')));
     set(gca,'ytick',1:numel(SameTunROI416),'yticklabel',SameTunROI416);
%      xtickangle(-60);
     title('Session 2');
     
     saveas(hf,fullfile(SaveFolderPath,sprintf('Sess%d Tuning summary plots.fig',cPath)));
     saveas(hf,fullfile(SaveFolderPath,sprintf('Sess%d Tuning summary plots.png',cPath)));
     close(hf);
    % check the sensory response within same frequency range, either BF or
    % not
    c832WithinShareInds = CommonOctRange >= SharedOctRange(1) & CommonOctRange <= SharedOctRange(2) & ...
        (CommonOctRange >= CommonOctRange416(1)+1) & (CommonOctRange <= CommonOctRange(1)+1);
    c416WithinShareInds = CommonOctRange416 >= SharedOctRange(1) & CommonOctRange416 <= SharedOctRange(2) & ...
        CommonOctRange416 > (CommonOctRange416(1)+1) & CommonOctRange416 < (CommonOctRange(1)+1);
    
    c832WithinShareCoefMtx = SameTunTaskMtx(:,c832WithinShareInds);
    c416WithinShareCoefMtx = SameTunTask416Mtx(:,c416WithinShareInds);
    
    c832WithinShareCoefSigInds = SameTunROI(sum(c832WithinShareCoefMtx > 0.1,2) > 0);
    c416WithinShareCoefSigInds = SameTunROI416(sum(c416WithinShareCoefMtx > 0.1,2) > 0);

    MergedUSedROIs = unique([c832WithinShareCoefSigInds;c416WithinShareCoefSigInds]);
%     MergedUSedROIs = intersect(c832WithinShareCoefSigInds,c416WithinShareCoefSigInds);
    MergedUSedROIs(MergedUSedROIs > CommonROINum) = [];
    %
    nMergROIs = length(MergedUSedROIs);
    ROIpreferedSide = zeros(nMergROIs,1);
    ROIModuIndex = zeros(nMergROIs,6);
    MergeROITunDataAll{cPath,1} = c832TunData.CorrTunningFun(:,MergedUSedROIs);
    MergeROITunDataAll{cPath,2} = c416TunData.CorrTunningFun(:,MergedUSedROIs);
    MergeROITunDataAll{cPath,3} = c832TunData.PassTunningfun(:,MergedUSedROIs);
    MergeROITunDataAll{cPath,4} = c416TunData.PassTunningfun(:,MergedUSedROIs);
    if size(c832TunData.CorrTunningFun,1) == 6
        TempDataBase = nan(8,nMergROIs);
        TempData = TempDataBase;
        TempData(1:3,:) = c832TunData.CorrTunningFun(1:3,MergedUSedROIs);
        TempData(6:8,:) = c832TunData.CorrTunningFun(4:6,MergedUSedROIs);
        MergeROITunDataAll{cPath,1} = TempData;
        
        TempData = TempDataBase;
        TempData(1:3,:) = c416TunData.CorrTunningFun(1:3,MergedUSedROIs);
        TempData(6:8,:) = c416TunData.CorrTunningFun(4:6,MergedUSedROIs);
        MergeROITunDataAll{cPath,2} = TempData;
        
        TempData = TempDataBase;
        TempData(1:3,:) = c832TunData.PassTunningfun(1:3,MergedUSedROIs);
        TempData(6:8,:) = c832TunData.PassTunningfun(4:6,MergedUSedROIs);
        MergeROITunDataAll{cPath,3} = TempData;
        
        TempData = TempDataBase;
        TempData(1:3,:) = c416TunData.PassTunningfun(1:3,MergedUSedROIs);
        TempData(6:8,:) = c416TunData.PassTunningfun(4:6,MergedUSedROIs);
        MergeROITunDataAll{cPath,4} = TempData;
    end
    
    for cRR = 1 : nMergROIs
        %
        cR832TunTData = c832TunData.CorrTunningFun(:,MergedUSedROIs(cRR));
        cR416TunTData = c416TunData.CorrTunningFun(:,MergedUSedROIs(cRR));
        cR832TunTAllTrData = c832TunData.CorrTunningCellData(:,MergedUSedROIs(cRR));
        cR416TunTAllTrData = c416TunData.CorrTunningCellData(:,MergedUSedROIs(cRR));
        cR832TunPData = c832TunData.PassTunningfun(:,MergedUSedROIs(cRR));
        cR416TunPData = c416TunData.PassTunningfun(:,MergedUSedROIs(cRR));
        
        cR832ShareRangeResp = cR832TunTData(c832WithinShareInds);
        cR416ShareRangeResp = cR416TunTData(c416WithinShareInds);
        cR832ShareRangeCellData = cR832TunTAllTrData(c832WithinShareInds);
        cR416ShareRangeCellData = cR416TunTAllTrData(c416WithinShareInds);
        cR832SRPassResp = cR832TunPData(c832WithinShareInds);
        cR416SRPassResp = cR416TunPData(c416WithinShareInds);
        
        c832SelectionIndex = (c832AUCData.ROCarea(MergedUSedROIs(cRR)) - 0.5)*2;
        c416SelectionIndex = (c416AUCData.ROCarea(MergedUSedROIs(cRR)) - 0.5)*2;
        ROIpreferedSide(cRR) = (c832SelectionIndex + c416SelectionIndex)/2;
%         if length(cR832ShareRangeResp) ~= length(cR416ShareRangeResp)
        
        [cR416ShareRangeMaxResp, cR416ShareRangeMaxInds] = max(cR416ShareRangeResp);
        [cR832ShareRangeMaxResp, cR832ShareRangeMaxInds] = max(cR832ShareRangeResp);
        [~,pp] = ttest2(cR832ShareRangeCellData{cR832ShareRangeMaxInds},cR416ShareRangeCellData{cR416ShareRangeMaxInds});
        
        AllROIModuIndex = (cR416ShareRangeMaxResp - cR832ShareRangeMaxResp)/...
            (cR416ShareRangeMaxResp + cR832ShareRangeMaxResp);  % right choice minus left choice
%         AllROIModuIndex = (mean(cR416ShareRangeResp) - mean(cR832ShareRangeResp))/...
%             (mean(cR416ShareRangeResp) + mean(cR832ShareRangeResp));  % right choice minus left choice
        
%         ROIModuIndex(cRR,:) = [mean(cR832ShareRangeResp),mean(cR416ShareRangeResp),AllROIModuIndex,pp];
        ROIModuIndex(cRR,:) = [cR832ShareRangeMaxResp,cR416ShareRangeMaxResp,AllROIModuIndex,pp,...
            cR832SRPassResp(cR832ShareRangeMaxInds),cR416SRPassResp(cR416ShareRangeMaxInds)];
        
%         % save all ROIs in one slice
%         exportToPPTX('addslide');
%         c832PathInfo = SessInfoExtraction(c832Path);
%         c416PathInfo = SessInfoExtraction(c416Path);
%         
%         c832TunPath = fullfile(c832Path,'Tunning_fun_plot_New1s',sprintf('ROI%d Tunning curve comparison plot.png',MergedUSedROIs(cRR)));
%         c416TunPath = fullfile(c416Path,'Tunning_fun_plot_New1s',sprintf('ROI%d Tunning curve comparison plot.png',MergedUSedROIs(cRR)));
%         
%         [~,c832MorphInds] = regexp(c832Path,'result_save');
%         [~,c416MorphInds] = regexp(c416Path,'result_save');
%         c832MorphPath = fullfile(c832Path(1:c832MorphInds),'ROI_morph_plot',sprintf('ROI%d morph plot save.png',MergedUSedROIs(cRR)));
%         c416MorphPath = fullfile(c416Path(1:c416MorphInds),'ROI_morph_plot',sprintf('ROI%d morph plot save.png',MergedUSedROIs(cRR)));
%         
%         exportToPPTX('addpicture',imread(c832TunPath),'Position',[0 0.5 5 3.82]);
%         exportToPPTX('addpicture',imread(c832MorphPath),'Position',[0 4.5 3 2.3]);
%         exportToPPTX('addpicture',imread(c416TunPath),'Position',[8 0.5 5 3.82]);
%         exportToPPTX('addpicture',imread(c416MorphPath),'Position',[8 4.5 3 2.3]);
%         
%         exportToPPTX('addtext',sprintf('Batch:%s Anm: %s \nDate: %s Field: %s',...
%             c832PathInfo.BatchNum,c832PathInfo.AnimalNum,c832PathInfo.SessionDate,c832PathInfo.TestNum),...
%             'Position',[0 7 4 2],'FontSize',20);
%         exportToPPTX('addtext',sprintf('Batch:%s Anm: %s \nDate: %s Field: %s',...
%             c416PathInfo.BatchNum,c416PathInfo.AnimalNum,c416PathInfo.SessionDate,c416PathInfo.TestNum),...
%             'Position',[8 7 4 2],'FontSize',20);
%         exportToPPTX('addtext',sprintf('ModuIndex %.3f\nP_Value %.3e',ROIModuIndex(cRR,3),pp),'Position',[5 2 2.5 2],'FontSize',20);
%         exportToPPTX('addnote',c832Path);
    end
    
    %
    PreferSideAll{cPath} = ROIpreferedSide;
    ModuIndexAll{cPath,1} = ROIModuIndex;
    ModuIndexAll{cPath,2} = [MergedUSedROIs,cPath*ones(numel(MergedUSedROIs),1)];
end
% save(fullfile(SaveFolderPath,'ConstSensROIsRespSave.mat'),'ModuIndexAll','PreferSideAll','MergeROITunDataAll','-v7.3');
% saveName = exportToPPTX('saveandclose',pptFullfile);
%%
ModuIndexValueAll = cell2mat(ModuIndexAll(:,1));
CompareAmpSigAll = ModuIndexValueAll(:,4);
PrefersideAll = cell2mat(PreferSideAll(:,1));
ModureverseInds = PrefersideAll < 0;
ModuReverseValue = ModuIndexValueAll(:,3);
ModuReverseValue(ModureverseInds) = -ModuReverseValue(ModureverseInds);
hf = figure;
hist(ModuReverseValue,20)
[~,pp] = ttest(ModuReverseValue);
title(sprintf('Test of zero %.3e',pp));
% saveas(hf,fullfile(SaveFolderPath,'Moduilation index distribution plot'));
% saveas(hf,fullfile(SaveFolderPath,'Moduilation index distribution plot'),'png');
%%

SessROIs = cell2mat(ModuIndexAll(:,2));

PreferSideAmp = ModuIndexValueAll(:,2);
PreferSideAmp(ModureverseInds) = ModuIndexValueAll(ModureverseInds,1);
NonPreferSide = ModuIndexValueAll(:,1);
NonPreferSide(ModureverseInds) = ModuIndexValueAll(ModureverseInds,2);

EnhanceInds = PreferSideAmp > NonPreferSide & CompareAmpSigAll < 0.01;
SurppressInds = PreferSideAmp < NonPreferSide & CompareAmpSigAll < 0.01;
MidInds = ~(EnhanceInds | SurppressInds);

hampf = figure('position',[100 100 420 350]);
hold on
hhl1 = plot(NonPreferSide(EnhanceInds),PreferSideAmp(EnhanceInds),'ro','linewidth',1.4);
hhl2 = plot(NonPreferSide(SurppressInds),PreferSideAmp(SurppressInds),'bo','linewidth',1.4);
hhl3 = plot(NonPreferSide(MidInds),PreferSideAmp(MidInds),'ko','linewidth',1.4);
legend([hhl1,hhl2,hhl3],{sprintf('%.1f',mean(EnhanceInds)*100),sprintf('%.1f',mean(SurppressInds)*100),...
    sprintf('%.1f',mean(MidInds)*100)},'box','off','location','east');
xscales = get(gca,'xlim');
yscales = get(gca,'ylim');
CommonScales = [min(xscales(1),yscales(1)),max(xscales(2),yscales(2))];
set(gca,'xlim',CommonScales,'ylim',CommonScales);
xlabel('Prefer Amp.');
ylabel('NonPrefer Amp.');
set(gca,'FontSize',12);

% saveas(hampf,fullfile(SaveFolderPath,'response amplitude compare plots'));
% saveas(hampf,fullfile(SaveFolderPath,'response amplitude compare plots'),'png');

%% plot the modulation index regardless of category selective side
ModuIndexValueAll = cell2mat(ModuIndexAll(:,1));
% SessROIs = cell2mat(ModuIndexAll(:,2));
CompareAmpSigAll = ModuIndexValueAll(:,4);

RightCSideAmp = ModuIndexValueAll(:,2);
% PreferSideAmp(ModureverseInds) = ModuIndexValueAll(ModureverseInds,1);
LeftCSideAMP = ModuIndexValueAll(:,1);
% NonPreferSide(ModureverseInds) = ModuIndexValueAll(ModureverseInds,2);

EnhanceInds = RightCSideAmp > LeftCSideAMP & CompareAmpSigAll < 0.01;
SurppressInds = RightCSideAmp < LeftCSideAMP & CompareAmpSigAll < 0.01;
MidInds = ~(EnhanceInds | SurppressInds);

hampf = figure('position',[100 100 420 350]);
hold on
hhl1 = plot(LeftCSideAMP(EnhanceInds),RightCSideAmp(EnhanceInds),'ro','linewidth',1.4);
hhl2 = plot(LeftCSideAMP(SurppressInds),RightCSideAmp(SurppressInds),'bo','linewidth',1.4);
hhl3 = plot(LeftCSideAMP(MidInds),RightCSideAmp(MidInds),'ko','linewidth',1.4);
legend([hhl1,hhl2,hhl3],{sprintf('%.1f',mean(EnhanceInds)*100),sprintf('%.1f',mean(SurppressInds)*100),...
    sprintf('%.1f',mean(MidInds)*100)},'box','off','location','east');
xscales = get(gca,'xlim');
yscales = get(gca,'ylim');
CommonScales = [min(xscales(1),yscales(1)),max(xscales(2),yscales(2))];
set(gca,'xlim',CommonScales,'ylim',CommonScales);
xlabel('Rightside Amp.');
ylabel('Leftside Amp.');
set(gca,'FontSize',12);

%% calculate the response level according to passive
ModuIndexValueAll = cell2mat(ModuIndexAll(:,1));
% SessROIs = cell2mat(ModuIndexAll(:,2));
CompareAmpSigAll = ModuIndexValueAll(:,4);

RightCSideAmp = ModuIndexValueAll(:,2);
LeftCSideAmp = ModuIndexValueAll(:,1);

RightCSideAmpPass = ModuIndexValueAll(:,6);
LeftCSideAmpPass = ModuIndexValueAll(:,5);

RightSideNorAmp = (RightCSideAmp - max(0,RightCSideAmpPass))./(RightCSideAmp + max(RightCSideAmpPass,0));
LeftSideNorAmp = (LeftCSideAmp - max(0,LeftCSideAmpPass))./(LeftCSideAmp + max(LeftCSideAmpPass,0));

%% ROI response defined preference
ModuMtxAll = cell2mat(ModuIndexAll(:,1));
ModuIndexVec = ModuMtxAll(:,3);

MergeTunDatas832 = (cell2mat((MergeROITunDataAll(:,1))'))';
MergeTunDatas416 = (cell2mat((MergeROITunDataAll(:,2))'))';
MergeTunDatasPass832 = (cell2mat((MergeROITunDataAll(:,3))'))';
MergeTunDatasPass416 = (cell2mat((MergeROITunDataAll(:,4))'))';

GrNum = size(MergeTunDatas832,2)/2;

ReverseInds = ModuIndexVec < 0;

Prefer832Data = MergeTunDatas832;
Prefer832Data(ReverseInds,:) = Prefer832Data(ReverseInds,fliplr(1:(GrNum*2)));
PreferPass832Data = MergeTunDatasPass832;
PreferPass832Data(ReverseInds,:) = PreferPass832Data(ReverseInds,fliplr(1:(GrNum*2)));

Prefer416Data = MergeTunDatas416;
Prefer416Data(ReverseInds,:) = Prefer416Data(ReverseInds,fliplr(1:(GrNum*2)));
PreferPass416Data = MergeTunDatasPass416;
PreferPass416Data(ReverseInds,:) = PreferPass416Data(ReverseInds,fliplr(1:(GrNum*2)));


h832f = figure('position',[100 100 650 560]);
subplot(221)
imagesc(Prefer832Data,[0 100])
set(gca,'xtick',1:GrNum*2,'xticklabel',cellstr(num2str(FreqsTypes(:)/1000,'%.1f')));
xlabel('Freq (kHz)');
ylabel('ROIs');
title('8-32 Sess')

subplot(222)
imagesc(Prefer416Data,[0 100])
set(gca,'xtick',1:GrNum*2,'xticklabel',cellstr(num2str(FreqsTypes(:)/1000,'%.1f')));
xlabel('Freq (kHz)');
ylabel('ROIs');
title('4-16 Sess')

Prefer832Task = mean(zscore(Prefer832Data,0,2),'omitnan');
Prefer832Pass = mean(zscore(PreferPass832Data,0,2),'omitnan');
Prefer416Task = mean(zscore(Prefer416Data,0,2),'omitnan');
Prefer416Pass = mean(zscore(PreferPass416Data,0,2),'omitnan');

subplot(223)
hold on
hl1 = plot(CommonOctRange,Prefer832Task,'r-o','linewidth',1.2);
hl2 = plot(CommonOctRange,Prefer832Pass,'-o','linewidth',1.2,'Color',[.5 .5 .5]);
set(gca,'xtick',CommonOctRange,'xticklabel',cellstr(num2str(FreqsTypes(:)/1000,'%.1f')));
legend([hl1,hl2],{'Task','Pass'},'box','off','FontSize',10,'location','northwest')
xtickangle(-60);
xlabel('Freq (kHz)');
ylabel('Response');
title('8-32 Sess');
set(gca,'FontSize',12);

subplot(224)
hold on
hl3 = plot(CommonOctRange416,Prefer416Task,'b-o','linewidth',1.2);
hl4 = plot(CommonOctRange416,Prefer416Pass,'-o','linewidth',1.2,'Color',[.5 .5 .5]);
set(gca,'xtick',CommonOctRange416,'xticklabel',cellstr(num2str(Freqs416Types(:)/1000,'%.1f')));
legend([hl3,hl4],{'Task','Pass'},'box','off','FontSize',10,'location','northwest')
xtickangle(-60);
xlabel('Freq (kHz)');
ylabel('Response');
title('4-16 Sess')
set(gca,'FontSize',12);


