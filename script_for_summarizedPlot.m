SessionData.RadDataAll = data_aligned;
SessionData.BehavData = behavResults;
%%
if strcmpi(SessionDesp,'Twotone2afc')
    %%
    % for normal two tone 2afc plot
    SessionData.clims = LRAlignedStrc.climsAll; % imagesc color scale for each ROI
    SessionData.nROI = size(data_aligned,2);  % number of ROIs within current session
    SessionData.FrameRate = frame_rate; % frame rate of current session
    SessionData.LeftAlignData = LRAlignedStrc.LeftAlignD; % Left trials aligned to stimulus onset, only correct trials, nROIs-by-ntrials-by-nframes
    SessionData.RightAlignData = LRAlignedStrc.RightAlignD; % Right trials aligned to stimulus onset, only correct trials, nROIs-by-ntrials-by-nframes
    SessionData.LeftAnsT = LRAlignedStrc.LeftAnsF; % Left correct trials answer time, 1-by-nTrials
    SessionData.RightAnsT = LRAlignedStrc.RightAnsF; % Right correct trials answer time, 1-by-nTrials
    SessionData.AlignFrame = LRAlignedStrc.AlignFrame; % The aligned stimonset frame
    SessionData.ROIauc = AUCDataAS; % AUC value for each ROI, 1-by-nROIs
    SessionData.ROCCoursexTick = TimeCourseStrc.tickTime; % Time points for each time bin center time that used for calculating time-coursed AUC
    SessionData.BinROCLR = TimeCourseStrc.ROIBinAUC; % time bin AUC for each ROI, nROIs-by-nBins matrix
    SessionData.AnsLRMeanTrace = AnsAlignData.AllMeanData; % mean trace for reward time aligned data, nROIs-by-4-by-nFrames matrix
    % for the second dimension, 1 and 3 indicates the left and right mean
    % trace after aligned to answer time, 2 and 4 indicates the
    % corresponded sem data
    SessionData.AnsAlignF = AnsAlignData.AlignFrame; % The aligned answer frame
    if exist('VShapeData','var')
        SessionData.VShapeData = VShapeData;  % vshapedata if availuable
    end
    
%%   
elseif strcmpi(SessionDesp,'RandomPuretone')
    %%
    % for random puretone data plotting
    SessionData.LeftAlignData = LRAlignedStrc.LeftAlignD; % Left trials aligned to stimulus onset, only correct trials, nROIs-by-ntrials-by-nframes
    SessionData.RightAlignData = LRAlignedStrc.RightAlignD; % Right trials aligned to stimulus onset, only correct trials, nROIs-by-ntrials-by-nframes
    SessionData.LeftAnsT = LRAlignedStrc.LeftAnsF; % Left correct trials answer time, 1-by-nTrials 
    SessionData.RightAnsT = LRAlignedStrc.RightAnsF; % Right correct trials answer time, 1-by-nTrials
    SessionData.AlignFrame = LRAlignedStrc.AlignFrame; % The aligned stimonset frame
    SessionData.clims = LRAlignedStrc.climsAll; % imagesc color scale for each ROI
    SessionData.nROI = size(data_aligned,2); % number of ROIs within current session
    SessionData.FrameRate = frame_rate; % frame rate of current session
    SessionData.ROIauc = AUCDataAS; % AUC value for each ROI, 1-by-nROIs
    SessionData.ROCCoursexTick = TimeCourseStrc.tickTime; % Time points for each time bin center time that used for calculating time-coursed AUC
    SessionData.BinROCLR = TimeCourseStrc.ROIBinAUC; % time bin AUC for each ROI, nROIs-by-nBins matrix
    SessionData.AllFreqData = FreqAlignedStrc.FreqRespData; % frequency-wised data, aligned to stimonset, nFreqs-by-nROIs cells, each cell is a nTrials-by-nFrames matrix
    SessionData.AllAnsFrame = FreqAlignedStrc.FreqAnsFr; % answer frames for each stimuli, nFreqs-by-1 cells, each is a nTrials-by-1 data vector
    SessionData.Frequency = FreqAlignedStrc.FreqTypes; % frequency types, nFreqs-by-1 vector
    if exist('VShapeData','var')
        SessionData.VShapeData = VShapeData; % vshapedata if availuable
    end
    SessionData.MeanRespData = FreqMeanTrace; % Mean trace data aligned to stimulus onset, nROIs-by-nFreqs-by-nFrames array
    SessionData.ChoiceProbData = ChoiceDataValue; 
    SessionData.TypeNumber = ChoiceDataNumber;
%%    
elseif strcmpi(SessionDesp,'RewardOmit')
    %%
    % for reward omit plot session
    SessionData.clims = ReOmitStrc.Climall; % imagesc color scale for each ROI
    SessionData.nROI = size(data_aligned,2); % number of ROIs within current session
    SessionData.FrameRate = frame_rate; % frame rate of current session
    SessionData.AlignFrame = ReOmitStrc.AlignedF; % The aligned stimonset frame
    SessionData.LeftAlignData = ReOmitStrc.AllLeftNorData; 
    SessionData.LeftAnsT = ReOmitStrc.LeftNorAnsF;
    SessionData.RightAlignData = ReOmitStrc.AllRightNorData;
    SessionData.RightAnsT = ReOmitStrc.RightNorAnsF;
    SessionData.LeftAlignOmit = ReOmitStrc.AllLeftOmitData;
    SessionData.LeftOmitAnsF = ReOmitStrc.LeftOmitAnsF;
    SessionData.RightAlignOmit = ReOmitStrc.AllRightOmitData;
    SessionData.RightOmitAnsF = ReOmitStrc.RightOmitAnsF;
    SessionData.LeftAnsAlMeanTr = ReOmitStrc.LeftAnsAlMeanTrace;
    SessionData.RightAnsAlMeanTr = ReOmitStrc.RightAnsAlMeanTrace;
    SessionData.AlignedF = ReOmitStrc.AnsAlignF;
    SessionData.ROCCoursexTick = TimeCourseStrc.tickTime;
    SessionData.BinROCLR = TimeCourseStrc.ROIBinAUC;
    SessionData.ROIauc = AUCDataAS;
    if exist('VShapeData','var')
        SessionData.VShapeData = VShapeData;
    end
 %%   
end
%%
if ~isdir('./Summarized_plot_save/')
    mkdir('./Summarized_plot_save/');
end
cd('./Summarized_plot_save/');
save SessDataSum.mat SessionDesp SessionData -v7.3
SummarizedPlot(SessionDesp,SessionData);
cd ..;