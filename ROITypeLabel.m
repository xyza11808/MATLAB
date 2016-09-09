function ROITypeLabel(varargin)
% this function will be used for labeling the ROI types when multichannel
% data is avaluable for different cell types discrimination, user should
% point out different cell types manually, and then the ROI types will be
% returned by this function

if nargin < 1
    fprintf('NO ROI info being input, please select your ROI info data storage file.\n');
    [ROIfn,ROIfp,ROIfx] = uigetfile('*.mat','Plaese select your ROI info file');
    if ROIfx
        xxxx = load(fullfile(ROIfp,ROIfn));
        if isfield(xxxx,'ROIinfo')
            ROInfos = xxxx.ROIinfo(1);
        elseif isfield(xxxx,'ROIinfoBU')
            ROInfos = xxxx.ROIinfoBU;
        else
            error('Error file selected, quit analysis.');
        end
    else
        return;
    end
else
    ROInfos = varargin{1};
end

ROIcenter = ROI_insite_label(ROInfos,0);
numROIs = size(ROIcenter,1);

fprintf('Please select one tif file for ROI type labeling, which should be a multichannel saved tif files.\n');
[tiffn,tiffp,tiffi] = uigetfile('*.tif','Please select your tif file for labeling');
if tiffi
    fprintf('Loading file %s ...\n',tiffn);
    [im_data,im_header] = load_scim_data(fullfile(tiffp,tiffn));
    [FrameRow,FrameCol,FrameNUm] = size(im_data);
    im_dataDouble = double(im_data);
    ChannelNUm = length(im_header.SI4.channelsSave);
    if ChannelNUm < 2
        fprintf('Not a multichannel tif file, quit analysis.\n');
        return;
    end
    system(sprintf('D:\\Fiji.app\\ImageJ-win64.exe %s',fullfile(tiffp,tiffn)));
%     fprintf('Please select a range to generate a mean image for multi channels.');
    NUmbers = input('Please select a range to generate a mean image for multi channels:\n','s');
    FrameNUms = sort(str2num(NUmbers));
    ChannelFrames = cell(ChannelNUm,1);  % used to storage the frame index for each channel
    MeanChannelData = zeros(FrameRow,FrameCol,ChannelNUm);
    for Nchannel = 1 : ChannelNUm 
        TotalFileNumber = Nchannel:ChannelNUm:FrameNUm;
        SelectFramesInds = TotalFileNumber > FrameNUms(1) & TotalFileNumber < FrameNUms(2);
        ChannelFrames(Nchannel) = {TotalFileNumber(SelectFramesInds)};
        MeanChannelData(:,:,Nchannel) = squeeze(mean(im_dataDouble(:,:,ChannelFrames{Nchannel}),3));
    end
%     MeanChannelData = uint16(MeanChannelData); % for imagesc display
    GreenChannelScale = [0 350];
    RedChannelScale = [0 350];
    BlueChannelScale = [0 350];
    GreenDataset = squeeze(MeanChannelData(:,:,1));
    GreenCDataset = (GreenDataset - GreenChannelScale(1))/(GreenChannelScale(2) - GreenChannelScale(1));
    GreenCDataset(GreenCDataset < 0) = 0;
    GreenCDataset(GreenCDataset > 1) = 1;
    RedDataset = squeeze(MeanChannelData(:,:,2));
    RedCDataset = (RedDataset - RedChannelScale(1))/(RedChannelScale(2) - RedChannelScale(1));
    RedCDataset(RedCDataset < 0) = 0;
    RedCDataset(RedCDataset > 1) = 1;
    if ChannelNUm < 3
        BlueCDataset = zeros(FrameRow,FrameCol);
    else
        BlueDataset = squeeze(MeanChannelData(:,:,3));
        BlueCDataset = (BlueDataset - BlueChannelScale(1))/(BlueChannelScale(2) - BlueChannelScale(1));
        BlueCDataset(BlueCDataset < 0) = 0;
        BlueCDataset(BlueCDataset > 1) = 1;
    end
    ImageData(:,:,1) = RedCDataset;
    ImageData(:,:,2) = GreenCDataset;
    ImageData(:,:,3) = BlueCDataset;
    h_merge = figure('position',[200 100 1000 850]);
    imagesc(ImageData);
    fprintf('Please Select the target ROIs and press enter when you finished.\n');
    [Cols,rows] = ginput;
    LabeledROIs = length(Cols);
    LabeledROIinds = zeros(LabeledROIs,1);
    for nSROIs = 1 : LabeledROIs
        %calculate the ROI center distance one by one and decide current
        %ROI belongings
        cROIPos = [Cols(nSROIs),rows(nSROIs)];
        AllROIDis = sum((ROIcenter - repmat(cROIPos,numROIs,1)).^2,2);
        [~,I] = min(AllROIDis);
        LabeledROIinds(nSROIs) = I;
    end
    fprintf('Totally %d out of %d ROIs being labeled as Red labeling ROIs',LabeledROIs,numROIs);
else
    fprintf('No file being selected, quit analysis...');
end
