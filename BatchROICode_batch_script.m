% immport the tif file data. if there are channle label, using
% given channel label for analysis
% cclr
UsedChannellabel = 'Ch2';

% [fn,fp,fi] = uigetfile('*.tif','Please select one tif file within the data folder.');
% if ~fi
%     return;
% end
% cd(fp);
TiffileAll = dir(fullfile(cfp,'*.tif'));
if isempty(TiffileAll)
    return;
end

IsChannelLabelExistIndex = arrayfun(@(cc) contains(cc.name,UsedChannellabel,'IgnoreCase',true),TiffileAll);
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
    ROIinfos = load(fullfile(cfp,'ROIinfoData.mat'));
catch
    fprintf('session %d without ROIinfo data exists.\n',cSess);
    return;
%     [ROIfn,ROIfp,ROIfi] = uigetfile('*.mat','Please select the ROI info datas');
%     ROIinfos = load(fullfile(ROIfp,ROIfp));
end

%% read and extract data from tif files

fROIDataAlls = cell(nfiles,1);
for cf = 1 : nfiles
    cfName = loadedTifFile(cf).name;
    [im,~] = load_scim_data(fullfile(cfp,cfName));
    cfData = arrayfun(@(x) Fun_ROIDataExtract(x.ROIMask,im),ROIinfos.ROIInfoDatas,'UniformOutput',false);
    fROIDataAlls{cf} = cell2mat(cfData');
end
clearvars cfData

%% read motion excluded data index
% [Textfn,Textfp,Textfi] = uigetfile('*.txt','Please select the movement index text file');
% if ~Textfi
%     return;
% end
TextFiles = dir(fullfile(cfp,'*.txt'));
if isempty(TextFiles)
    fprintf('Session %d without movement data.\n',cSess);
    MoveMentIndex = 0;
else
    Textfp = cfp;
    Textfn = TextFiles(1).name;

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

    % Exclude frame index from extracted data set
    MoveMentIndex = cell2mat(FrameMoveIndex(:,1));
end
%%
% IsMoveExtsts = 1;
if ~sum(MoveMentIndex)
    fprintf('No movement exists for session %d.\n',cSess);
    MoveFreeData = fROIDataAlls';
%     IsMoveExtsts = 0;
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

% %% plots
% hf = figure;
% imagesc(MoveFreedff_matrix,[0 1]);

%% save all datas
save SavedROIDatas.mat MoveFreeTrace MoveFreedff_matrix FrameMoveIndex fROIDataAlls -v7.3

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
FilterOpsAll.IsPlot = 0;

% events detection parameters
EventParas.NoiseMethod = 'Res_std';
EventParas.PeakThres = 1;
EventParas.BaselinePrc = 18;
EventParas.MinHalfPeakWid = 1.5; % seconds
EventParas.OnsetThres = 1;
EventParas.OffsetThres = 1;
EventParas.IsPlot = 1;
%%
nROIs = size(MoveFreedff_matrix,1);
if ~isdir('./ROI_events_plot/')
    mkdir('./ROI_events_plot/');
end
cd('./ROI_events_plot/');
EventsIndsAllROI = cell(nROIs,1);
for cROI = 1 : nROIs
    cROITrace = MoveFreedff_matrix(cROI,:);
    [~,EventIndex,ROIPlots] = TraceEventDetect(cROITrace,FilterOpsAll,EventParas);
    EventsIndsAllROI{cROI} = EventIndex;
    
    ffName = sprintf('ROI%d event Trace plots',cROI);
    saveas(ROIPlots{2},ffName);
    saveas(ROIPlots{2},ffName,'png');
    close(ROIPlots{2});
end

save ROIEventsDataAll.mat EventsIndsAllROI -v7.3
    
    
    