clear
clc

% select the high response ROIs and extract the response profile into a ppt file
[fn,fp,fi] = uigetfile('*.txt','Please select the session path storage file');
if ~fi
    return;
end
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);
m = 1;

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
    clearvars data_aligned behavResults start_frame
    
    if m == 1
        PPTname = input('Please input the name for current PPT file:\n','s');
        if isempty(strfind(PPTname,'.ppt'))
            PPTname = [PPTname,'.pptx'];
        end
        pptSavePath = uigetdir(pwd,'Please select the path used for ppt file savege');
    end
    FullfilePath = fullfile(pptSavePath,PPTname);
    if ~exist(FullfilePath,'file')
        IsNewFile = 1;
    else
        IsNewFile = 0;
    end
    if IsNewFile
        exportToPPTX('new','Dimensions',[16,9],'Author','XinYu','Comments','Export of tunning curve plot data');
    else
        exportToPPTX('open',FullfilePath);
    end
    
    load(fullfile(SessPath,'CSessionData.mat'));
    cd(SessPath);
    
    % [fn,fp,fi] = uigetfile('CSessionData.mat','Please select the sessin summary data');
%     load(fullfile(fp,fn));

    [nTrs,nROIs,nFrames] = size(data_aligned);
    TimeWin = [0.2,1.2];
    FrameScales = round(TimeWin*frame_rate);
    FreqsAll = double(behavResults.Stim_toneFreq);
    TrOutcome = behavResults.Action_choice(:) == behavResults.Trial_Type(:);
    Freqtypes = unique(FreqsAll);
    nFreqs = length(Freqtypes);
    ROIfreqMeanResp = zeros(nROIs,nFreqs);
    for cROI = 1 : nROIs
        cROIdata = squeeze(data_aligned(:,cROI,:));
        cROIrespData = mean(cROIdata(:,(start_frame+FrameScales(1)):(start_frame+FrameScales(2))),2);
        for cfreq = 1 : nFreqs
            cFreqInds = FreqsAll == Freqtypes(cfreq);
            cFreqDataMean = cROIrespData(cFreqInds);
            cFreqCorrInds = TrOutcome(cFreqInds);
            cFreqCorrData = cFreqDataMean(cFreqCorrInds == 1);
            ROIfreqMeanResp(cROI,cfreq) = mean(cFreqCorrData);
        end
    end
    %
    CDDataPath = fullfile(SessPath,'Fluo_cd_data\RespCDSave.mat');
    CDDataStrc = load(CDDataPath,'ROI_CD_All');
    CDDataAll = CDDataStrc.ROI_CD_All;
    
    CategDataPath = fullfile(SessPath,'CDInds_calculation_CorrErro\NewROIindsSave.mat');
    CategDataStrc = load(CategDataPath);
%     CategDataIndex = CategDataStrc
    
    SigRespROIs = double(ROIfreqMeanResp > 80); % high response level ROI inds
    if ~isdir('HighResp ROIs')
        mkdir('HighResp ROIs');
    end
    % cd('HighResp ROIs');
    TargetPath = fullfile(SessPath,'HighResp ROIs');

    HighRespROIs = sum(SigRespROIs,2);
    SelectROIinds = find(HighRespROIs);
    if ~isempty(SelectROIinds)
        for SelectROIs = 1 : length(SelectROIinds);
            cROIrespfile = [SessPath,'\All BehavType Colorplot\',sprintf('ROI%d all behavType color plot',SelectROIinds(SelectROIs))];
            copyfile(sprintf('%s.png',cROIrespfile),TargetPath);
            copyfile(sprintf('%s.fig',cROIrespfile),TargetPath);
            
            MeanRespDataPath = [SessPath,'\CDInds_calculation_CorrErro\',sprintf('ROI%d response plot.png',SelectROIinds(SelectROIs))];
            exportToPPTX('addslide');
            cfigName = sprintf('%s.png',cROIrespfile);
            figureID = imread(sprintf('%s.png',cROIrespfile));
            MeanRespID = imread(MeanRespDataPath);
            exportToPPTX('addtext',sprintf('ROI%d',SelectROIinds(SelectROIs)),'Position',[2 0 2 1],'FontSize',20);
            exportToPPTX('addtext',sprintf('BCD = %.3f, WCD = %.3f',CDDataAll(SelectROIinds(SelectROIs),1),...
                CDDataAll(SelectROIinds(SelectROIs),2)),'Position',[6 0 2 1],'FontSize',20);
            exportToPPTX('addtext',sprintf('Index = %.4f, MaxDifSum = %d, CategInds = %d',...
                CategDataStrc.ROIindsAll(SelectROIinds(SelectROIs)),...
                CategDataStrc.ROIindexMaxSum(SelectROIinds(SelectROIs)),...
                CategDataStrc.CategIndsMaxS(SelectROIinds(SelectROIs))),'Position',[9 0 4 1],'FontSize',20);
            exportToPPTX('addnote',pwd);
            exportToPPTX('addpicture',figureID,'Position',[4 1 12 8]);
            exportToPPTX('addpicture',MeanRespID,'Position',[0 4 4 3.2]);
        end
    end
    cd('HighResp ROIs');
    save HighRespROIs.mat SelectROIinds ROIfreqMeanResp TimeWin -v7.3
    
    m = m + 1;
    saveName = exportToPPTX('saveandclose',FullfilePath);
    tline = fgetl(fid);
end

%% calculate the BCD and WCD values for each session
[fn,fp,fi] = uigetfile('*.txt','Please select the session path storage file');
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
    clearvars data_aligned behavResults start_frame
   
    load(fullfile(SessPath,'CSessionData.mat'));
    cd(SessPath);
    
    Resp_CI_script;
    
    tline = fgetl(fid);
end