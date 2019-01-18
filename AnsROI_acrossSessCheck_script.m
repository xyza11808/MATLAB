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
SubDir = 'c728_416Sess_AnsROIsummary';
if ~isdir(fullfile(Plots_Save_path,SubDir))
    mkdir(fullfile(Plots_Save_path,SubDir));
end
SavingPath = fullfile(Plots_Save_path,SubDir);
SessSummaryfileName = 'c728_416Sess_AnsROIsummary.pptx';
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

%%
ConstantROIIndex = cell(NumPaths,8); % the last two were ROI numbers within each session
ConstMeanTraceSum = cell(NumPaths,2);
for cPath = 1 : NumPaths
    
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
    cSess832FRate = load(fullfile(c832Path,'CSessionData.mat'),'frame_rate');
    cSess416FRate = load(fullfile(c416Path,'CSessionData.mat'),'frame_rate');
    
    Sess832BehavStrc = load(fullfile(c832Path,'RandP_data_plots','boundary_result.mat'));
    Sess416BehavStrc = load(fullfile(c416Path,'RandP_data_plots','boundary_result.mat'));
    
    cSess832DataStrc = load(Sess832ROIIndexFile);
    cSess416DataStrc = load(Sess416ROIIndexFile);
    %
    CommonROINum = min(numel(cSess832DataStrc.ROIIndex),numel(cSess416DataStrc.ROIIndex));
    CommonROIIndex = cSess832DataStrc.ROIIndex(1:CommonROINum) & cSess416DataStrc.ROIIndex(1:CommonROINum);
    
    c832UsedROIInds = false(numel(cSess832DataStrc.ROIIndex),1);
    c832UsedROIInds(1:CommonROINum) = CommonROIIndex;
    cSess832SelectROIStrc = load(fullfile(c832Path,'SigSelectiveROIInds.mat'));
    LAnsROIs = cSess832SelectROIStrc.LAnsMergedInds(c832UsedROIInds(cSess832SelectROIStrc.LAnsMergedInds));
    RAnsROIs = cSess832SelectROIStrc.RAnsMergedInds(c832UsedROIInds(cSess832SelectROIStrc.RAnsMergedInds));
    %
    [c832AnsPeakValue,FreqTypes, FreqTypeAnsTrace] = AnsResponseSumFun(c832Path,cSess832FRate.frame_rate);
    c832LAnsROIpeakV = c832AnsPeakValue(:,LAnsROIs,:);
    LAnsDataAll = zeros(numel(LAnsROIs),size(c832LAnsROIpeakV,3));
    for clROI = 1 : numel(LAnsROIs)
        cAnsLData = squeeze(c832LAnsROIpeakV(:,clROI,:));
        [~,MaxInds] = max(sum(cAnsLData,2));
        LAnsDataAll(clROI,:) = cAnsLData(MaxInds,:);
    end
    c832RAnsROIpeakV = c832AnsPeakValue(:,RAnsROIs,:);
    RAnsDataAll = zeros(numel(RAnsROIs),size(c832RAnsROIpeakV,3));
    for clROI = 1 : numel(RAnsROIs)
        cAnsRData = squeeze(c832RAnsROIpeakV(:,clROI,:));
        [~,MaxInds] = max(sum(cAnsRData,2));
        RAnsDataAll(clROI,:) = cAnsRData(MaxInds,:);
    end
    
    LAnsTraceAll = FreqTypeAnsTrace(:,LAnsROIs,:);
    RAnsTraceAll = FreqTypeAnsTrace(:,RAnsROIs,:);
    ComOctTypes = log2(FreqTypes/4000);
    
    % another session
    c416UsedROIInds = false(numel(cSess416DataStrc.ROIIndex),1);
    c416UsedROIInds(1:CommonROINum) = CommonROIIndex;
    cSess416SelectROIStrc = load(fullfile(c416Path,'SigSelectiveROIInds.mat'));
    LAns416ROIs = cSess416SelectROIStrc.LAnsMergedInds(c416UsedROIInds(cSess416SelectROIStrc.LAnsMergedInds));
    RAns416ROIs = cSess416SelectROIStrc.RAnsMergedInds(c416UsedROIInds(cSess416SelectROIStrc.RAnsMergedInds));
    
    [c416AnsPeakValue,FreqTypes416, FreqTypeAnsTrace416] = AnsResponseSumFun(c416Path,cSess416FRate.frame_rate);
    c416LAnsROIpeakV = c416AnsPeakValue(:,LAns416ROIs,:);
    LAnsData416All = zeros(numel(LAns416ROIs),size(c416LAnsROIpeakV,3));
    for clROI = 1 : numel(LAns416ROIs)
        cAnsLData = squeeze(c416LAnsROIpeakV(:,clROI,:));
        [~,MaxInds] = max(sum(cAnsLData,2));
        LAnsData416All(clROI,:) = cAnsLData(MaxInds,:);
    end
    c416RAnsROIpeakV = c416AnsPeakValue(:,RAns416ROIs,:);
    RAnsData416All = zeros(numel(RAns416ROIs),size(c416RAnsROIpeakV,3));
    for clROI = 1 : numel(RAns416ROIs)
        cAnsRData = squeeze(c416RAnsROIpeakV(:,clROI,:));
        [~,MaxInds] = max(sum(cAnsRData,2));
        RAnsData416All(clROI,:) = cAnsRData(MaxInds,:);
    end
    
    LAns416TraceAll = FreqTypeAnsTrace416(:,LAns416ROIs,:);
    RAns416TraceAll = FreqTypeAnsTrace416(:,RAns416ROIs,:);
    ComOct416Types = log2(FreqTypes416/4000);
    
    hf = figure('position',[2000 100 850 640]);
    subplot(221)
    imagesc(zscore(LAnsDataAll,0,2),[-1 1.5]);
    set(gca,'xtick',1:numel(ComOctTypes),'xticklabel',cellstr(num2str(ComOctTypes(:),'%.2f')),'ytick',1:numel(LAnsROIs),'yticklabel',LAnsROIs);
    title('LAnsResp Sess1');
    
    subplot(222)
    imagesc(zscore(RAnsDataAll,0,2),[-1 1.5]);
    set(gca,'xtick',1:numel(ComOctTypes),'xticklabel',cellstr(num2str(ComOctTypes(:),'%.2f')),'ytick',1:numel(RAnsROIs),'yticklabel',RAnsROIs);
    title('RAnsResp Sess1');
    
    subplot(223)
    imagesc(zscore(LAnsData416All,0,2),[-1 1.5]);
    set(gca,'xtick',1:numel(ComOct416Types),'xticklabel',cellstr(num2str(ComOct416Types(:),'%.2f')),'ytick',1:numel(LAns416ROIs),'yticklabel',LAns416ROIs);
    title('LAnsResp Sess2');
    
    subplot(224)
    imagesc(zscore(RAnsData416All,0,2),[-1 1.5]);
    set(gca,'xtick',1:numel(ComOct416Types),'xticklabel',cellstr(num2str(ComOct416Types(:),'%.2f')),'ytick',1:numel(RAns416ROIs),'yticklabel',RAns416ROIs);
    title('RAnsResp Sess2');
    
    saveas(hf,fullfile(SavingPath,sprintf('Sess%d AnsROIs compare plots.fig',cPath)));
    saveas(hf,fullfile(SavingPath,sprintf('Sess%d AnsROIs compare plots.png',cPath)));
    close(hf);
     
    % find the common ROIs and seqROIs for each session
    [CC,ia,ib] = intersect(LAnsROIs,LAns416ROIs);
    c832AllLAnsInds = false(numel(LAnsROIs),1);
    c832AllLAnsInds(ia) = true;
    c832LIndivROIs = LAnsROIs(~c832AllLAnsInds);
    
    c416AllLAnsInds = false(numel(LAns416ROIs),1);
    c416AllLAnsInds(ib) = true;
    c416LIndivROIs = LAns416ROIs(~c416AllLAnsInds);
    
    [CCR,iaR,ibR] = intersect(RAnsROIs,RAns416ROIs);
    c832AllRAnsInds = false(numel(RAnsROIs),1);
    c832AllRAnsInds(iaR) = true;
    c832RIndivROIs = RAnsROIs(~c832AllRAnsInds);
    
    c416AllRAnsInds = false(numel(RAns416ROIs),1);
    c416AllRAnsInds(ibR) = true;
    c416RIndivROIs = RAns416ROIs(~c416AllRAnsInds);
    
    ConstantROIIndex(cPath,:) = {CC,c832LIndivROIs,c416LIndivROIs,...
        CCR,c832RIndivROIs,c416RIndivROIs,sum(c832UsedROIInds),sum(c416UsedROIInds)};
    
    % summarize all ROIs
    nSegROIs = [length(CC),length(c832LIndivROIs),length(c416LIndivROIs),length(CCR),length(c832RIndivROIs),length(c416RIndivROIs)];
    nSegROITypes = [ones(nSegROIs(1),1);2*ones(nSegROIs(2),1);3*ones(nSegROIs(3),1);4*ones(nSegROIs(4),1);...
        5*ones(nSegROIs(5),1);6*ones(nSegROIs(6),1)];
    ROITypes = {'LAnsCommon','L832Ans','L416Ans','RAnsCommon','R832Ans','R416Ans'};
    ROIlabels = [CC(:);c832LIndivROIs(:);c416LIndivROIs(:);CCR;c832RIndivROIs;c416RIndivROIs];
    %
    nCumSegROIs = sum(nSegROIs);
    for cR = 1 : nCumSegROIs(end)
        cROIIndex = ROIlabels(cR);
        
        exportToPPTX('addslide');
        c832PathInfo = SessInfoExtraction(c832Path);
        c416PathInfo = SessInfoExtraction(c416Path);

        c832TunPath = fullfile(c832Path,'All BehavType Colorplot',sprintf('ROI%d all behavType color plot.png',cROIIndex));
        c416TunPath = fullfile(c416Path,'All BehavType Colorplot',sprintf('ROI%d all behavType color plot.png',cROIIndex));

        [~,c832MorphInds] = regexp(c832Path,'result_save');
        [~,c416MorphInds] = regexp(c416Path,'result_save');
        c832MorphPath = fullfile(c832Path(1:c832MorphInds),'ROI_morph_plot',sprintf('ROI%d morph plot save.png',cROIIndex));
        c416MorphPath = fullfile(c416Path(1:c416MorphInds),'ROI_morph_plot',sprintf('ROI%d morph plot save.png',cROIIndex));

        exportToPPTX('addpicture',imread(c832TunPath),'Position',[0 0 8 5.6]);
        exportToPPTX('addpicture',imread(c832MorphPath),'Position',[0 6 2.6 2]);
        exportToPPTX('addpicture',imread(c416TunPath),'Position',[8 0 8 5.6]);
        exportToPPTX('addpicture',imread(c416MorphPath),'Position',[8 6 2.6 2]);

        exportToPPTX('addtext',sprintf('Batch:%s Anm: %s \nDate: %s Field: %s',...
            c832PathInfo.BatchNum,c832PathInfo.AnimalNum,c832PathInfo.SessionDate,c832PathInfo.TestNum),...
            'Position',[3 7 4 2],'FontSize',20);
        exportToPPTX('addtext',sprintf('Batch:%s Anm: %s \nDate: %s Field: %s',...
            c416PathInfo.BatchNum,c416PathInfo.AnimalNum,c416PathInfo.SessionDate,c416PathInfo.TestNum),...
            'Position',[11 7 4 2],'FontSize',20);
        exportToPPTX('addtext',ROITypes{nSegROITypes(cR)},'Position',[8 8.2 3 0.5],'FontSize',20,'Color',[1 0 0]);
        exportToPPTX('addnote',c832Path);
    end
    
    ConstMeanTraceSum{cPath,1} = LAnsTraceAll;
    ConstMeanTraceSum{cPath,2} = RAnsTraceAll;
    ConstMeanTraceSum{cPath,3} = LAnsROIs;
    ConstMeanTraceSum{cPath,4} = RAnsROIs;
    
    
    ConstMeanTraceSum{cPath,5} = LAns416TraceAll;
    ConstMeanTraceSum{cPath,6} = RAns416TraceAll;
    ConstMeanTraceSum{cPath,7} = LAns416ROIs;
    ConstMeanTraceSum{cPath,8} = RAns416ROIs;
    
    %
end
saveName = exportToPPTX('saveandclose',pptFullfile);

%%
save(fullfile(SavingPath,'CommonAnsROI_IndexSummary.mat'),'ConstantROIIndex','ConstMeanTraceSum','-v7.3');

%%
AnsROITypeNum = cellfun(@numel,ConstantROIIndex(:,1:6));
SessTotalROIs = cell2mat(ConstantROIIndex(:,7:8));
Sess1AnsROINums = sum(AnsROITypeNum(:,1:3),2);
Sess2AnsROINums = sum(AnsROITypeNum(:,4:6),2);

Sess1AnsROIFrac = Sess1AnsROINums ./ SessTotalROIs(:,1);
Sess2AnsROIFrac = Sess2AnsROINums ./ SessTotalROIs(:,2);



