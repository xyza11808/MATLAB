
if strcmpi(SessionDesp,'Twotone2afc')
    %%
    % for normal two tone 2afc plot
    SessionData.clims = LRAlignedStrc.climsAll;
    SessionData.nROI = size(data_aligned,2);
    SessionData.FrameRate = frame_rate;
    SessionData.LeftAlignData = LRAlignedStrc.LeftAlignD;
    SessionData.RightAlignData = LRAlignedStrc.RightAlignD;
    SessionData.LeftAnsT = LRAlignedStrc.LeftAnsF;
    SessionData.RightAnsT = LRAlignedStrc.RightAnsF;
    SessionData.AlignFrame = LRAlignedStrc.AlignFrame;
    SessionData.ROIauc = AUCDataAS;
    SessionData.ROCCoursexTick = TimeCourseStrc.tickTime;
    SessionData.BinROCLR = TimeCourseStrc.ROIBinAUC;
    SessionData.AnsLRMeanTrace = AnsAlignData.AllMeanData;
    SessionData.AnsAlignF = AnsAlignData.AlignFrame;
    if exist('VShapeData','var')
        SessionData.VShapeData = VShapeData;
    end
    
%%   
elseif strcmpi(SessionDesp,'RandomPuretone')
    %%
    % for random puretone data plotting
    SessionData.LeftAlignData = LRAlignedStrc.LeftAlignD;
    SessionData.RightAlignData = LRAlignedStrc.RightAlignD;
    SessionData.LeftAnsT = LRAlignedStrc.LeftAnsF;
    SessionData.RightAnsT = LRAlignedStrc.RightAnsF;
    SessionData.AlignFrame = LRAlignedStrc.AlignFrame;
    SessionData.clims = LRAlignedStrc.climsAll;
    SessionData.nROI = size(data_aligned,2);
    SessionData.FrameRate = frame_rate;
    SessionData.ROIauc = AUCDataAS;
    SessionData.ROCCoursexTick = TimeCourseStrc.tickTime;
    SessionData.BinROCLR = TimeCourseStrc.ROIBinAUC;
    SessionData.AllFreqData = FreqAlignedStrc.FreqRespData;
    SessionData.AllAnsFrame = FreqAlignedStrc.FreqAnsFr;
    SessionData.Frequency = FreqAlignedStrc.FreqTypes;
    if exist('VShapeData','var')
        SessionData.VShapeData = VShapeData;
    end
    SessionData.MeanRespData = FreqMeanTrace;
    SessionData.ChoiceProbData = ChoiceDataValue;
    SessionData.TypeNumber = ChoiceDataNumber;
%%    
elseif strcmpi(SessionDesp,'RewardOmit')
    %%
    % for reward omit plot session
    SessionData.clims = ReOmitStrc.Climall;
    SessionData.nROI = size(data_aligned,2);
    SessionData.FrameRate = frame_rate;
    SessionData.AlignFrame = ReOmitStrc.AlignedF;
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
SummarizedPlot(SessionDesp,SessionData);
cd ..;