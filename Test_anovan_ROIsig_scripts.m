clear
clc

[fn,fp,fi] = uigetfile('*.txt','Please select the text files contains session plots path');
if ~fi
    return;
end
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);
while ischar(tline)
    if isempty(strfind(tline,'\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    %
    if ~isempty(strfind(tline,'All BehavType Colorplot'))
        SessPath = strrep(tline,'\All BehavType Colorplot','\');
    else
        SessPath = tline;
    end
    load(fullfile(SessPath,'CSessionData.mat'));
    cd(SessPath);
    %
    TrStimAll = double(behavResults.Stim_toneFreq);
    TrChoice = double(behavResults.Action_choice);
    MissInds = trial_outcome == 2;

    NMTrStim = TrStimAll(~MissInds);
    NMTrChoice = TrChoice(~MissInds);
    NMoutcome = trial_outcome(~MissInds);
    NMOctaves = log2(NMTrStim/16000);
    NMData = smooth_data(~MissInds,:,:);
    NMSPdata = SpikeAligned(~MissInds,:,:);
    %% calculate the p value for each ROI and each frame bin
    nROIs = size(smooth_data,2);
    nFrames = size(smooth_data,3);
    pValueMatrix = zeros(nROIs,nFrames,3);
    parfor cROI = 1 : nROIs
        cROIdata = squeeze(NMData(:,cROI,:));
        for nF = 1 : nFrames
            cFrameData = cROIdata(:,nF);
            p = anovan(cFrameData,{NMOctaves(:),NMTrChoice(:),NMoutcome(:)},'display','off');
            pValueMatrix(cROI,nF,:) = p;
        end
    end
    
    % calculate using the spike data
    pValueSPMtx = zeros(nROIs,nFrames,3);
    parfor cROI = 1 : nROIs
        cSPdata = squeeze(NMSPdata(:,cROI,:));
        Non_ZeroInds = cSPdata > 1e-6;
        Thres = prctile(cSPdata(Non_ZeroInds),10); % large above ten percent values
        cBinaryData = double(cSPdata > Thres);
        for nF = 1 : nFrames
            cFrameData = cBinaryData(:,nF);
            p = anovan(cFrameData,{NMOctaves(:),NMTrChoice(:),NMoutcome(:)},'display','off');
            pValueSPMtx(cROI,nF,:) = p;
        end
    end
    
    %%
    xticks = 0:frame_rate:nFrames;
    xticklabels = xticks/frame_rate;
    CoefSigMatrix = double(pValueMatrix < 0.01);
    if ~isdir('./ROIcoef_plot_anova/')
        mkdir('./ROIcoef_plot_anova/');
    end
    cd('./ROIcoef_plot_anova/');
    for cROI = 1 : nROIs
        cROIcoefData = squeeze(CoefSigMatrix(cROI,:,:));
        hf = figure;
        imagesc(cROIcoefData');
        line([start_frame start_frame],[0.5,3.5],'Color',[.7 .7 .7],'linewidth',1.2);
        set(gca,'xlim',[0.5 0.5 + nFrames],'ylim',[0.5 3.5],'FontSize',14);
        set(gca,'ytick',1:3,'yticklabel',{'Freq','Choice','Reward'},'xtick',xticks,'xticklabel',xticklabels);
        xlabel('Time (s)');
        title(sprintf('ROI%d coef plot',cROI));
        saveas(hf,sprintf('ROI%d coef sigPlot',cROI));
        saveas(hf,sprintf('ROI%d coef sigPlot',cROI),'png');
        close(hf);
    end
    save ROIcoefPmatrix.mat pValueMatrix CoefSigMatrix start_frame frame_rate pValueSPMtx -v7.3
    %
    tline = fgetl(fid);
end

%%
clear
clc
m = 1;
[fn,fp,fi] = uigetfile('*.txt','Please select the text files contains session plots path');
if ~fi
    return;
end
m = 1;
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);
while ischar(tline)
    if isempty(strfind(tline,'\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    if ~isempty(strfind(tline,'All BehavType Colorplot'))
        SessPath = strrep(tline,'\All BehavType Colorplot','\');
    else
        SessPath = tline;
    end
    filepath = [SessPath,'\ROIcoef_plot_anova\logP_lineplot'];
    TrRespPath = [SessPath,'\All BehavType Colorplot'];
    cd(SessPath);
    if m == 1
        PPTname = input('Please input the pptx file name:\n','s');
        if isempty(strfind(PPTname,'.ppt')) || isempty(strfind(PPTname,'.pptx'))
            PPTname = [PPTname,'.pptx'];
        end
        SavePath = uigetdir(pwd,'Please select a path to save the ppt file');
    end
    pptfullname = fullfile(SavePath,PPTname);
    if ~exist(pptfullname,'file')
         exportToPPTX('new','Dimensions',[16,9],'Author','XinYu','Comments','Export of session aligned sort plots');
    else
        exportToPPTX('open',pptfullname);
    end
    %
    figfiles = dir([filepath,'\*.png']);
    TrRespFiles = dir([TrRespPath,'\*.png']);
    nfiles = length(figfiles);
    for cROI = 1 : nfiles
        nfname = figfiles(cROI).name;
        figid = imread([filepath,'\',nfname]);
        nTRRespFname = TrRespFiles(cROI).name;
        TrRespfid = imread([TrRespPath,'\',nTRRespFname]);
        exportToPPTX('addslide');
        exportToPPTX('addtext',nTRRespFname(1:end-4),'Position',[1 1 4 3],'FontSize',24);
        exportToPPTX('addnote',SessPath);
        exportToPPTX('addpicture',TrRespfid,'Position',[5 2 11 6.875]);
        exportToPPTX('addpicture',figid,'Position',[0 4 6 4.5]);
    end
    m = m + 1;
    SaveName = exportToPPTX('saveandclose',pptfullname);
    tline = fgetl(fid);
end

%%

clear
clc

[fn,fp,fi] = uigetfile('*.txt','Please select the text files contains session plots path');
if ~fi
    return;
end
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);
while ischar(tline)
    if isempty(strfind(tline,'\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    if ~isempty(strfind(tline,'All BehavType Colorplot'))
        SessPath = strrep(tline,'\All BehavType Colorplot','\');
    else
        SessPath = tline;
    end
    load(fullfile(SessPath,'CSessionData.mat'));
    cd(SessPath);
    %%
    TrStimAll = double(behavResults.Stim_toneFreq);
    TrType = double(behavResults.Trial_Type);
    TrChoice = double(behavResults.Action_choice);
    MissInds = trial_outcome == 2;
    
    NMChoice = TrChoice(~MissInds);
    NMTrStim = TrStimAll(~MissInds);
    NMTrCateg = TrType(~MissInds);
    NMoutcome = trial_outcome(~MissInds);
    NMOctaves = log2(NMTrStim/16000);
    NMData = data_aligned(~MissInds,:,:);
    %% calculate the p value for each ROI and each frame bin
    nROIs = size(data_aligned,2);
    nFrames = size(data_aligned,3);
    pValueMatrix = zeros(nROIs,nFrames,2);
    parfor cROI = 1 : nROIs
        cROIdata = squeeze(NMData(:,cROI,:));
        for nF = 1 : nFrames
            cFrameData = cROIdata(:,nF);
            p = anovan(cFrameData,{NMOctaves(:),NMTrCateg(:)},'display','off');
            pValueMatrix(cROI,nF,:) = p;
        end
    end
    %%
    xticks = 0:frame_rate:nFrames;
    xticklabels = xticks/frame_rate;
    CoefSigMatrix = double(pValueMatrix < 0.01);
    if ~isdir('./Anovan_StimCag_freq/')
        mkdir('./Anovan_StimCag_freq/');
    end
    cd('./Anovan_StimCag_freq/');
    for cROI = 1 : nROIs
        cROIcoefData = squeeze(CoefSigMatrix(cROI,:,:));
        hf = figure;
        imagesc(cROIcoefData');
        line([start_frame start_frame],[0.5,3.5],'Color',[.7 .7 .7],'linewidth',1.2);
        set(gca,'xlim',[0.5 0.5 + nFrames],'ylim',[0.5 2.5],'FontSize',14);
        set(gca,'ytick',1:2,'yticklabel',{'Freq','Categ'},'xtick',xticks,'xticklabel',xticklabels);
        xlabel('Time (s)');
        title(sprintf('ROI%d coef plot',cROI));
        saveas(hf,sprintf('ROI%d coef sigPlot',cROI));
        saveas(hf,sprintf('ROI%d coef sigPlot',cROI),'png');
        close(hf);
    end
    save ROIcoefPmatrix.mat pValueMatrix CoefSigMatrix start_frame frame_rate -v7.3
    %
    tline = fgetl(fid);
end

%%
clear
clc
m = 1;
[fn,fp,fi] = uigetfile('*.txt','Please select the text files contains session plots path');
if ~fi
    return;
end
m = 1;
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);
while ischar(tline)
    if isempty(strfind(tline,'\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    if ~isempty(strfind(tline,'All BehavType Colorplot'))
        SessPath = strrep(tline,'\All BehavType Colorplot','\');
    else
        SessPath = tline;
    end
    filepath = [SessPath,'\Anovan_StimCag_freq'];
    TrRespPath = [SessPath,'\All BehavType Colorplot'];
    cd(SessPath);
    if m == 1
        PPTname = input('Please input the pptx file name:\n','s');
        if isempty(strfind(PPTname,'.ppt')) || isempty(strfind(PPTname,'.pptx'))
            PPTname = [PPTname,'.pptx'];
        end
        SavePath = uigetdir(pwd,'Please select a path to save the ppt file');
    end
    pptfullname = fullfile(SavePath,PPTname);
    if ~exist(pptfullname,'file')
         exportToPPTX('new','Dimensions',[16,9],'Author','XinYu','Comments','Export of session aligned sort plots');
    else
        exportToPPTX('open',pptfullname);
    end
    %
    figfiles = dir([filepath,'\*.png']);
    TrRespFiles = dir([TrRespPath,'\*.png']);
    nfiles = length(figfiles);
    for cROI = 1 : nfiles
        nfname = figfiles(cROI).name;
        figid = imread([filepath,'\',nfname]);
        nTRRespFname = TrRespFiles(cROI).name;
        TrRespfid = imread([TrRespPath,'\',nTRRespFname]);
        exportToPPTX('addslide');
        exportToPPTX('addtext',nTRRespFname(1:end-4),'Position',[1 1 4 3],'FontSize',24);
        exportToPPTX('addnote',SessPath);
        exportToPPTX('addpicture',TrRespfid,'Position',[5 2 11 6.875]);
        exportToPPTX('addpicture',figid,'Position',[0 4 6 4.5]);
    end
    m = m + 1;
    SaveName = exportToPPTX('saveandclose',pptfullname);
    tline = fgetl(fid);
end

%%
TrStimAll = double(behavResults.Stim_toneFreq);
TrType = double(behavResults.Trial_Type);
TrChoice = double(behavResults.Action_choice);
MissInds = trial_outcome == 2;

NMChoice = TrChoice(~MissInds);
NMTrStim = TrStimAll(~MissInds);
NMTrCateg = TrType(~MissInds);
NMoutcome = trial_outcome(~MissInds);
NMOctaves = log2(NMTrStim/16000);
NMData = data_aligned(~MissInds,:,:);
ErroTrNum = sum(NMoutcome~=1);
fprintf('Number of error trials are %d.\n',ErroTrNum);

nROIs = size(data_aligned,2);
nFrames = size(data_aligned,3);
% cROI = 1;
% pValueMatrixNew = zeros(nROIs,nFrames,2);
% parfor cROI = 1 : nROIs
%     cROIdata = squeeze(NMData(:,cROI,:));
%     for nF = 1 : nFrames
%         cFrameData = cROIdata(:,nF);
%         p = anovan(cFrameData,{NMTrCateg(:),NMChoice(:),NMoutcome(:)},'display','off');
%         pValueMatrixNew(cROI,nF,:) = p;
%     end
% end
[FactorCorr,Corrp] = corrcoef([NMTrCateg(:),NMoutcome(:)]);
if Corrp(1,2) < 0.001 || FactorCorr(1,2) > 0.5
    fprintf('Current factors are not independent.\n');
    return;
end

CategTypes = unique(NMTrCateg);
pSigAll = cell(nROIs,1);
ROIstds = zeros(nROIs,1);
ROICategValues = zeros(nROIs,length(CategTypes));
ROICategNames = cellstr(num2str(CategTypes(:)));
for cROI = 1 : nROIs
    %
    cROIdata = (squeeze(NMData(:,cROI,:)))';
    cROIstds = mad(cROIdata(:),1)*1.4826;
    ROIstds(cROI) = cROIstds;
    cROIdata = squeeze(NMData(:,cROI,(start_frame+round(frame_rate*0.2)):(start_frame+round(frame_rate*0.7))));
    cTrRespData = mean(cROIdata,2);
    %
    cCategValue = zeros(length(CategTypes),1);
    for cType = 1 : length(CategTypes)
        cCategTypeInds = NMTrCateg == CategTypes(cType);
        cCategValue(cType) = mean(cTrRespData(cCategTypeInds));
    end
    ROICategValues(cROI,:) = cCategValue;
    % [p,tbl,stats,terms] = anovan(cTrRespData,{NMTrCateg(:),NMChoice(:),NMoutcome(:)},'varnames',{'Categ','Choice','Outcome'});
    [p,tbl,stats,terms] = anovan(cTrRespData(:),{NMTrCateg(:),NMoutcome(:)},'varnames',{'Categ','Outcome'},'display','off');
    % figure;
    % multcompare(stats,'Dimension',[1 2])
    pSigAll{cROI} = p;
end
CategROIs = (cellfun(@(x) x(1) < 0.01,pSigAll));
CategMaxV = max(ROICategValues,[],2);
SigCategROIs = find((CategMaxV > ROIstds) & CategROIs)

%%
FreqTypes = unique(NMOctaves);
FreqRespData = zeros(length(FreqTypes),1);
for cFreq = 1 : length(FreqTypes)
    cFreqInds = NMOctaves == FreqTypes(cFreq);
    FreqRespData(cFreq) = mean(cTrRespData(cFreqInds));
end
