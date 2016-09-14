function RawROIvideocheck(varargin)
% this function will be used for substract raw videos from raw tif files
% for given ROI inds, and saved into avi files for further view
% ROIinfo, tif file path, tif file index, behavior result file, frame rate is needed
% for this function

if nargin < 1
    fprintf('Please select your 2afc analysis result mat file:\n');
    [filename,filepath,Findex]=uigetfile('*.mat','Select your 2p analysis storage data','MultiSelect','on');
    if Findex
        cd(filepath);
        for n = 1 : length(filename)
            x = load(filename{n});
            if isfield(x,'CaTrials') || isfield(x,'CaSignal')
                FieldName = fieldnames(x);
                CaTrials = x.(FieldName{1});
            end
            if isfield(x,'SavedCaTrials')
                fieldN=fieldnames(x);
                CaTrials=x.(fieldN{1});
            end
            if isfield(x,'ROIinfo')
                ROIinfo=x.ROIinfo;
            elseif isfield(x,'ROIinfoBU')
                ROIinfo=x.ROIinfoBU;
            end
        end
        frame_rate=floor(1000/CaTrials(1).FrameTime);
        UsingROIinfo = ROIinfo(1);
    else
        return;
    end
    Tiffp = uigetdir(pwd,'Please select your tif file path for tif file loading'); % tif file path
    [Behavfn,Behavfp,Begavfi] = uigetfile('*.mat','Please selct your behavior result saving mat file');
    if Begavfi
        y = load(fullfile(Behavfp,Behavfn));
        BehResult = y.behavResults;
        BehSetting = y.behavSettings;
    else
        return;
    end
else
    [UsingROIinfo,frame_rate,Tiffp,BehResult] = deal(varargin{:});
end
if isempty(Tiffp)
    Tiffp = uigetdir(pwd,'Please select your tif file path for tif file loading'); % tif file path
end

stimOnFrame = round((double(BehResult.Time_stimOnset)/1000)*frame_rate);
AnswerFrame = round((double(BehResult.Time_answer)/1000)*frame_rate);
TrialType = double(BehResult.Trial_Type);
SoundTime = round(0.3*frame_rate);

cd(Tiffp);
files = dir('*.tif');
if length(files) < 15
    fprintf('Not enough files within given tif file path, are you sure want to continue with those files?\n');
    ChoiceChar = input('Continue?\n','s');
    if strcmpi(ChoiceChar,'n')
        return;
    end
    FileLength = length(files);
else
    FileLength = 15;
end
ROImask1 = UsingROIinfo.ROImask{1};
[rows,cols] = size(ROImask1);
TargetROIs = input('Plese input the ROI inds that you want to generate video.\n Multiple ROIs please sepatrated by ,:\n','s');
ROIinds = str2num(TargetROIs);
TargetROInum = length(ROIinds);
centersAll = ROI_insite_label(UsingROIinfo,0);
ROIcenters = centersAll(ROIinds,:);%= cellfun(@(x) mean(x),UsingROIinfo.ROIpos(ROIinds));
TargetROImask = cell(TargetROInum,1);
for nRoi = 1 : TargetROInum
    cROIcenter = ROIcenters(nRoi,:);
    if rows == 256
        Rowscales = round([cROIcenter(1) - 20,cROIcenter(1) + 20]);
        Colscale = round([cROIcenter(2) - 20,cROIcenter(2) + 20]);
    else
        Rowscales = round([cROIcenter(1) - 40,cROIcenter(1) + 40]);
        Colscale = round([cROIcenter(2) - 40,cROIcenter(2) + 40]);
    end
    if Rowscales(1) < 1
        Rowscales(1) = 1;
    end
    if Rowscales(2) > rows
        Rowscales(2) = rows;
    end
    if Colscale(1) < 1
        Colscale(1) = 1;
    end
    if Colscale(2) > cols
        Colscale(2) = cols;
    end
%     FrameMask = false(rows,cols);
    FrameMask = [Rowscales(1),Rowscales(2),Colscale(1),Colscale(2)];
    TargetROImask(nRoi) = {FrameMask};
end
%%
% ROIDataCell = cell(TargetROInum,1);
mov = struct('cdata',[],'colormap',[]);
% FrameNum = 1;
for nFiles = 1 : FileLength
    cFilename = files(nFiles).name;
    [im_data,~] = load_scim_data(cFilename);
    fprintf('Loading file %s ...\n',cFilename);
    fileTrialNum = str2num(cFilename(end-6:end-4));
    cStimOnFrame = stimOnFrame(fileTrialNum);
    cAnsFrame = AnswerFrame(fileTrialNum);
    cTrialType = TrialType(fileTrialNum);
    FrameNumber = size(im_data,3);
    for nnROI = 1 : TargetROInum
        cFrameScale = TargetROImask{nnROI};
        for nframe = 1 : FrameNumber
            cROIdata = squeeze(im_data(:,:,nframe));
            cROIdataPart = cROIdata(cFrameScale(1):cFrameScale(2),cFrameScale(3):cFrameScale(4));
            imagesc(cROIdataPart,[0 500]);
            colormap gray;
            axis off
            box off
            if nframe >= cStimOnFrame && nframe < (cStimOnFrame + SoundTime)
                if cTrialType
                    patch([2,8,8,2],[8 8 2 2],'r');
                else
                    patch([2,8,8,2],[8 8 2 2],'b');
                end
            end
            if nframe >= cAnsFrame && nframe < (cAnsFrame+20)
                patch([2,8,8,2],[38 38 32 32],'g');
            end
            mov(nnROI,nframe+((nFiles-1)*FrameNumber)) = getframe(gcf);
        end
    end
end

% write frame data into avi moive
if ~isdir('./ROI_response_check/')
    mkdir('./ROI_response_check/');
end
cd('./ROI_response_check/');
for nnnROI = 1 : TargetROInum
    RealROINum = ROIinds(nnnROI);
    ROIsaveName = sprintf('ROI%d response video',RealROINum);
    if verLessThan('matlab','8.4')
        fprintf('Writing data into video file %s...\n',ROIsaveName);
        movie2avi(mov(nnnROI,:),ROIsaveName,'compression','none','fps',frame_rate); %#ok<MOVIE2>
        fprintf('GVI file writing complete!\n');
    else
        fprintf('Writing data into video file %s...\n',ROIsaveName);
        cVideo = VideoWriter([ROIsaveName,'.avi'],'Uncompressed AVI'); %#ok<TNMLP>
        cVideo.FrameRate = frame_rate;
        open(cVideo);
        writeVideo(cVideo,mov(nnnROI,:));
        close(cVideo);
        fprintf('GVI file writing complete!\n');
    end
end

cd ..;