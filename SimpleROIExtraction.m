function MoveFreeTrace = SimpleROIExtraction(TifPath,ROIPath)
% extract ROI datas from input path, using input ROI datas
UsedChannellabel = 'Ch2';
cfp = TifPath;
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

ROIinfos = load(ROIPath);

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
    fprintf('No movement exists.\n');
    MoveMentIndex = 0;
    FrameIndsAll = [];
else
    Textfp = cfp;
    Textfn = TextFiles(1).name;

    Textfile = fullfile(Textfp,Textfn);
    fid = fopen(Textfile);
    tline = fgetl(fid);
    
    MoveMentIndex = 0;
    while ischar(tline)
        if isempty(strfind(tline,'movement'))
            tline = fgetl(fid);
            continue;
        end

        [StartInd,EndInds] = regexp(tline,'\d{1,4}');
        if ~isempty(StartInd) % surely some movement index exists
            MoveMentIndex = 1;
            if length(StartInd) > 2
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
            
        end
        tline = fgetl(fid);
    end

%     % Exclude frame index from extracted data set
%     MoveMentIndex = cell2mat(FrameMoveIndex(:,1));
end
%%
% IsMoveExtsts = 1;
MoveFreeData = cell2mat(fROIDataAlls');
if ~MoveMentIndex
    fprintf('No movement exists for current session.\n');
    MoveFreeTrace = MoveFreeData;
%     IsMoveExtsts = 0;
else
    NumFrameInds = size(FrameIndsAll,1);
    IsDataIncluded = ones(size(MoveFreeData,2),1);
    for cf = 1 : NumFrameInds
        IsDataIncluded(FrameIndsAll(cf,1):FrameIndsAll(cf,2)) = 0;
    end
    MoveFreeTrace = MoveFreeData(:,logical(IsDataIncluded));
end

%% MoveFreeTrace = cell2mat(MoveFreeData);
save(fullfile(cfp,'RawROIDatas.mat'),'MoveFreeTrace','-v7.3');
% exclude the first 100 frames
MoveFreeTrace(:,1:100) = [];
% MoveFreePrcData = prctile(MoveFreeTrace',10);
% 
% MoveFreedff_matrix = (MoveFreeTrace - repmat(MoveFreePrcData',1,size(MoveFreeTrace,2)))./...
%     repmat(MoveFreePrcData',1,size(MoveFreeTrace,2));



