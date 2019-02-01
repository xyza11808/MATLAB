% Pass similarity matrix calculation
% Passive prediction of choice

if isPassSess
    TimeScale = 1;
    start_frame = frame_rate;

    if length(TimeScale) == 1
        FrameScale = sort([(start_frame+1),(start_frame + round(TimeScale*frame_rate))]);
    elseif length(TimeScale) == 2
        FrameScale = sort([(start_frame + round(TimeScale(1)*frame_rate)),(start_frame + round(TimeScale(2)*frame_rate))]);
    end
    if exist('ccUsedROIInds','var')
        RespDataAll = mean(SelectData(:,ccUsedROIInds,FrameScale(1):FrameScale(2)),3);
    else
        RespDataAll = mean(SelectData(:,:,FrameScale(1):FrameScale(2)),3);
    end
    if exist('PassUsedTrInds','var')
        RespData = RespDataAll(PassUsedTrInds,:);
        Stimlulus = SelectSArray(PassUsedTrInds);
        Stimlulus = Stimlulus(:);
    else
        RespData = RespDataAll;
        Stimlulus = SelectSArray(:);
    end

    %
    % Trial outcomes correction

    StimTypes = unique(Stimlulus);

    MannuBound = TaskBehavBound;  % calculated from task sessions

    UsingAnmChoice = double(Stimlulus > MannuBound);

    UsingRespData = RespData;
    TrialOutcomes = ones(numel(Stimlulus),1);

    NumStims = numel(StimTypes);
    StimTypeIndsAll = cell(NumStims,2);
    for cStim = 1 : NumStims
        csInds = Stimlulus == StimTypes(cStim);
        StimTypeIndsAll{cStim,1} = csInds;
        StimTypeIndsAll{cStim,2} = UsingRespData(csInds,:);
    end
else
    % task choice calculation
    TimeScale = 1;
    if length(TimeScale) == 1
        FrameScale = sort([(start_frame+1),(start_frame + round(TimeScale*frame_rate))]);
    elseif length(TimeScale) == 2
        FrameScale = sort([(start_frame + round(TimeScale(1)*frame_rate)),(start_frame + round(TimeScale(2)*frame_rate))]);
    end
    if exist('ccUsedROIInds','var')
        RespData = mean(data_aligned(:,ccUsedROIInds,FrameScale(1):FrameScale(2)),3);
    else
        RespData = mean(data_aligned(:,:,FrameScale(1):FrameScale(2)),3);
    end
    %
    % Trial outcomes correction
    AnimalChoice = double(behavResults.Action_choice(:));
    UsingTrInds = AnimalChoice ~= 2;
    % UsingTrInds = trial_outcome == 1;
    UsingAnmChoice = double(AnimalChoice(UsingTrInds));
    UsingRespData = RespData(UsingTrInds,:);
    Stimlulus = (double(behavResults.Stim_toneFreq(UsingTrInds)))';
    TrialOutcomes = trial_outcome(UsingTrInds);
    TrialTypes = (double(behavResults.Trial_Type(UsingTrInds)))';

    StimTypes = unique(Stimlulus);
    NumStims = numel(StimTypes);
    % StimTypeDatas = cell(numel(StimTypes),size(UsingRespData,2));
    StimRProb = zeros(NumStims,1);
    StimTypeIndsAll = cell(NumStims,2);
    for cs = 1 : NumStims
        csInds = Stimlulus == StimTypes(cs);
        StimTypeIndsAll{cs,1} = csInds;

        StimTypeIndsAll{cs,2} = UsingRespData(csInds,:);
        StimRProb(cs) = mean(UsingAnmChoice(csInds));
    end
    rescaleB = max(StimRProb);
    rescaleA = min(StimRProb);

    StimOctaves = log2(Stimlulus/min(Stimlulus)) - 1;
    StimOctaveTypes = unique(StimOctaves); 
    
end

%%
% using the variable to calcuolate the similarity
StimROIRespAvg = cellfun(@(x) mean(x),StimTypeIndsAll(:,2),'uniformOutput',false);
StimROIRespMtx = (cell2mat(StimROIRespAvg))';
CurrentCoef = corrcoef(StimROIRespMtx); % performing no normalization, incase of the low response values

