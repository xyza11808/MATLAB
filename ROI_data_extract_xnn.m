% immport the tif file data. if there are channle label, using
% given channel label for analysis
UsedChannellabel = 'Ch2';

[fn,fp,fi] = uigetfile('*.tif','Please select one tif file within the data folder.');
if ~fi
    return;
end
cd(fp);
TiffileAll = dir(fullfile(fp,'*.tif'));
IsChannelLabelExistIndex = arrayfun(@(cc) strcmpi(cc,UsedChannellabel),TiffileAll);
if ~sum(IsChannelLabelExistIndex)
    fprintf('No channel label was founded, loading all tif files for data extraction.\n');
    loadedTifFile = TiffileAll;
else
    UsedTifNum = sum(IsChannelLabelExistIndex);
    fprintf('Loading %d files with channle label %s for data extraction.\n',UsedTifNum,UsedChannellabel);
    loadedTifFile = TiffileAll(IsChannelLabelExistIndex);
end

nfiles = length(loadedTifFile);

%% load ROIinfo data
try
    ROIinfos = load(fullfile(fp,'ROIinfoData.mat'));
catch
    [ROIfn,ROIfp,ROIfi] = uigetfile('*.mat','Please select the ROI info datas');
    ROIinfos = load(fullfile(ROIfp,ROIfp));
end

%% read and extract data from tif files

fROIDataAlls = cell(nfiles,1);
for cf = 1 : nfiles
    cfName = loadedTifFile(cf).name;
    [im,~] = load_scim_data(fullfile(fp,cfName));
    cfData = arrayfun(@(x) Fun_ROIDataExtract(x.ROIMask,im),ROIinfos.ROIInfoDatas,'UniformOutput',false);
    fROIDataAlls{cf} = cell2mat(cfData');
end
clearvars cfData

%% read motion excluded data index
[Textfn,Textfp,Textfi] = uigetfile('*.txt','Please select the movement index text file');
if ~Textfi
    return;
end
%%
Textfile = fullfile(Textfp,Textfn);
fid = fopen(Textfile);
tline = fgetl(fid);

FrameMoveIndex = cell(nfiles,2);
while ischar(tline)
    if isempty(strfind(tline,'movement'))
        tline = fgetl(fid);
        continue;
    end
    
    [StartInd,EndInds] = regexp(tline,'\d{1,4}');
    if ~isempty(StartInd) % surely some movement index exists
        [SessStartInd,SessEndInds] = regexp(tline,'sess\d{1,2}');
        TargetSessLabel = tline(SessStartInd:SessEndInds);
        
        if length(StartInd) > 3
            nFrameBin = floor(numel(StartInd)/2);
            FrameIndsAll = zeros(nFrameBin,2);
            for cfBin = 1 : nFrameBin
                cfEnd_base = (cfBin - 1)*2;
                Frame_end_index = str2num(tline(StartInd(end-cfEnd_base):EndInds(end-cfEnd_base)));
                Frame_start_index = str2num(tline(StartInd(end-1-cfEnd_base):EndInds(end-1-cfEnd_base)));
                FrameIndsAll(cfBin,:) = [Frame_start_index,Frame_end_index];
            end  
        else
            Frame_start_index = str2num(tline(StartInd(end-1):EndInds(end-1)));
            Frame_end_index = str2num(tline(StartInd(end):EndInds(end)));
            FrameIndsAll = [Frame_start_index,Frame_end_index];
        end
        
        MoveSessIndex = arrayfun(@(ccc) ~isempty(strfind(ccc.name,TargetSessLabel)),loadedTifFile);
        FrameMoveIndex{MoveSessIndex,1} = 1;
        FrameMoveIndex{~MoveSessIndex,1} = 0;
        FrameMoveIndex{MoveSessIndex,2} = FrameIndsAll;
    end
    tline = fgetl(fid);
end

%% Exclude frame index from extracted data set
MoveMentIndex = cell2mat(FrameMoveIndex(:,1));
if ~sum(MoveMentIndex)
    fprintf('No movement exists.\n');
    MoveFreeData = fROIDataAlls;
else
    MoveFreeData = cell(1,nfiles);
    for cf = 1 : nfiles
        if MoveMentIndex(cf)
            cfData = fROIDataAlls{cf};
            cfUsedInds = ones(size(cfData,2),1);
            MoveFrameInds = FrameMoveIndex{cf,2};
            NumFrameBin = size(MoveFrameInds,1);
            for cBin = 1 : NumFrameBin
                cfUsedInds(MoveFrameInds(cBin,1):MoveFrameInds(cBin,2)) = 0;
            end
            MoveFreeData{cf} = cfData(:,logical(cfUsedInds));
        else
            MoveFreeData{cf} = fROIDataAlls{cf};
        end
    end
end

%% merge movefree ROI trace together

MoveFreeTrace = cell2mat(MoveFreeData);
MoveFreePrcData = prctile(MoveFreeTrace',10);

MoveFreedff_matrix = (MoveFreeTrace - repmat(MoveFreePrcData',1,size(MoveFreeTrace,2)))./...
    repmat(MoveFreePrcData',1,size(MoveFreeTrace,2));
%% plots
hf = figure;
imagesc(MoveFreedff_matrix,[0 2]);

%% save all datas
save SavedROIDatas.mat MoveFreeTrace MoveFreedff_matrix FrameMoveIndex fROIDataAlls -v7.3

%%
cROI = 103;
plot(MoveFreedff_matrix(cROI,:))
%%
close;
cROI = 111;
cROIData = MoveFreedff_matrix(cROI,:);
fr = 29;
PassBand = 2;
StopBand = 4;
PassBand2 = 0.005;
StopBand2 = 0.001;

% cDes = designfilt('lowpassfir','PassbandFrequency',PassBand,'StopbandFrequency',StopBand,...
%     'StopbandAttenuation', 60,'SampleRate',fr,'DesignMethod','kaiserwin');  %'ZeroPhase',true,
cDesNew = designfilt('bandpassfir','PassbandFrequency1',PassBand2,'StopbandFrequency1',StopBand2,...
    'PassbandFrequency2',PassBand,'StopbandFrequency2',StopBand,'SampleRate',fr,'StopbandAttenuation1',40,...
    'StopbandAttenuation2',60,'DesignMethod','kaiserwin');
NeededDatgapoints = 3*(length(cDesNew.Coefficients) - 1);
ExtraRepeatsNum = ceil(NeededDatgapoints/length(cROIData));
RepDatas = repmat(cROIData(:),ExtraRepeatsNum,1);
RepNFSignal = filtfilt(cDesNew,RepDatas);
ExtraFiltData = RepNFSignal(1:length(cROIData));
% filled up of the constant values, for bandpass filter only
Residues = cROIData(:) - ExtraFiltData;
ResidueMiddleMedian = median(Residues);
NFSignal = ExtraFiltData + ResidueMiddleMedian;
SmoothData = smooth(Residues,0.05,'rloess');
NFNew = ExtraFiltData + SmoothData;
%
figure('position',[2000 200 1260 420]);
subplot(1,3,[1,2])
hold on;
plot(cROIData,'r');
plot(NFSignal,'k','linewidth',1.2);
plot(NFNew,'c','linewidth',1.2);
title(sprintf('Pass %.4f Stop %.4f',PassBand,StopBand));

subplot(133)
hold on
plot(Residues,'b');
plot(SmoothData,'k','linewidth',1.2)

% subplot(144)
% hold on
% plot(cROIData - NFSignal,'r','linewidth',1);
% plot(cROIData - NFNew,'c','linewidth',1);

%% using function for events detection
FilterOpsAll.Type = 'bandpassfir';
FilterOpsAll.Fr = 29;
FilterOpsAll.PassBand2 = 1;
FilterOpsAll.StopBand2 = 3;
FilterOpsAll.PassBand1 = 0.005;
FilterOpsAll.StopBand1 = 0.001;
FilterOpsAll.StopAttenu1 = 60;
FilterOpsAll.StopAttenu2 = 60;
FilterOpsAll.DesignMethod = 'kaiserwin';
FilterOpsAll.IsPlot = 1;

% events detection parameters
EventParas.NoiseMethod = 'Res_std';
EventParas.PeakThres = 1;
EventParas.BaselinePrc = 18;
EventParas.MinHalfPeakWid = 1.5; % seconds
EventParas.OnsetThres = 1;
EventParas.OffsetThres = 1;
EventParas.IsPlot = 1;

%%
close all
cROI = 64;
cROITrace = MoveFreedff_matrix(cROI,:);
[FiltTrace,PeakIndex] = TraceEventDetect(cROITrace,FilterOpsAll,EventParas);

