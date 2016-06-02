function CaTrials = batch_ROI_analysis(CaTrials_init, trialRange)
% Batch extract time series of mean pixel intensity of all ROIs, and save
% to a structure array.

% - NX 2015.4

ROIinfo = CaTrials_init.ROIinfo;

file_mainName = CaTrials_init.FileName_prefix;

datafile_list = dir([file_mainName, '*.tif']);

if nargin < 2
    trialInds = 1:length(datafile_list);
else
    trialInds = (trialRange(1) : trialRange(2));
end

for i = 1:length(trialInds)
    TrialNo = trialInds(i);
    fname = datafile_list(TrialNo);
    
    
    if ~exist(fname,'file')
        error('Data file not exist!\n');
    end;
    
    fprintf('Batch analyzing trial %d of total %d trials with %d ROIs...', ...
        TrialNo, End_trial-Start_trial+1, ROIinfo.nROIs);
    
    [im, header] = load_scim_data(fname);
    
    CaTrials(i).nROIs = ROIinfo.nROIs;
    CaTrials(i).AnimalName = CaTrials_init.AnimalName;
    CaTrials(i).ExpDate = CaTrials_init.ExpDate;
    CaTrials(i).SessionName = CaTrials_init.SessionName;
    
    CaTrials(i).DataPath = pwd;
    CaTrials(i).FileName = fname;
    CaTrials(i).FileName_prefix = CaTrials_init.FileName_prefix;
    CaTrials(i).TrialNo = fname;
    
    
    if isfield(header, 'acq')
        CaTrials(i).DaqInfo = header;
        CaTrials(i).nFrames = header.acq.numberOfFrames;
        CaTrials(i).FrameTime = header.acq.msPerLine*header.acq.linesPerFrame;
    elseif isfield(header, 'SI4')
        CaTrials(i).DaqInfo = header.SI4;
        CaTrials(i).nFrames = header.SI4.acqNumFrames;
        CaTrials(i).FrameTime = header.SI4.scanFramePeriod;
    else
        CaTrials(i).nFrames = header.n_frame;
        CaTrials(i).FrameTime = [];
    end
   
    if CaTrials(i).FrameTime < 1 % some earlier version of ScanImage use sec as unit for msPerLine
        CaTrials(i).FrameTime = CaTrials.FrameTime*1000;
    end
    
    
    ROIinfo(TrialNo) = ROIinfo;
    CaTrials(i).f_raw = trial_ROI_analysis(im, ROIinfo);
end

Save_Results(CaTrials, pwd);
disp(['Batch analysis completed for Session of ' file_mainName]);
end

%%
function roi_signal = trial_ROI_analysis(im_trial, ROIinfo)
% Extract time series of mean pixel intensity of all ROIs
nROI = length(ROIinfo.ROIpos);
ROImask = ROIinfo.ROImask;

F = zeros(nROI, size(im_trial,3));
dff = zeros(size(F));

for i = 1: nROI
    mask = repmat(ROImask{i}, [1 1 size(im_trial,3)]); % reproduce masks for every frame
    nPix = sum(sum(ROImask{i}));
    % Using reshape to partition into different trials.
    roi_img = reshape(im_trial(mask), nPix, []);
    % Raw intensity averaged from pixels of the ROI in each trial.
    if nPix == 0
        F(i,:) = 0;
    else
        F(i,:) = mean(roi_img, 1);
    end
end
roi_signal = F;
end


%%
function Save_Results(CaTrials, save_dir)
% Save Results
clock_str = sprintf('%d_%d_%d_%d_%d_%d', fix(clock));
results_fname = [save_dir filesep 'CaTrials_' CaTrials(1).FileName_prefix clock_str '.mat'];

save(results_fname, 'CaTrials');
end


