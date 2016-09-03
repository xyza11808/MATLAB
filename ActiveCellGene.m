function ActiveCellGene(RawData,BehavResult,TrialOut,FrameRate,TimeWin,varargin)
% Test of significant response of neuron

SmoothRawData = RawData;
[~,UpdateStd] = GPsmoothRaw(RawData(1:20,:,:));
[TrialNum,ROINum,FrameNum] = size(SmoothRawData);  % matrix dimension
% TrialSigResult = zeros(TrialNum,ROINum);
if isempty(TimeWin)
    fprintf('Empty input of time window, using default window length.\n');
    TimeWin = 1.5;
end
FrameWin = round(TimeWin*FrameRate);

TimeOnsetF = floor((double(BehavResult.Time_stimOnset)/1000)*FrameRate);
TimeAnswerF = floor((double(BehavResult.Time_answer)/1000)*FrameRate);
TrialTypes = double(BehavResult.Trial_Type);

%%
% sound onset time alignment
alignFrame = min(TimeOnsetF);
TrialAlinAdjust = TimeOnsetF - alignFrame;
FrameLength = FrameNum - max(TrialAlinAdjust);
AlignInds = TrialAlinAdjust + 1;
DataAlignedSoundOn = zeros(TrialNum,ROINum,FrameLength);

%%
% answer time alignment
answerFUni = unique(TimeAnswerF);
AnswerAlignF = answerFUni(2);  % smallest non-zero frame number as alignpoint
TrialAdjust = TimeAnswerF - AnswerAlignF;
FrameLengthAns = FrameNum - max(TrialAdjust);
AnsAlignInds = TrialAdjust + 1;
DataAlignAnsFrame = zeros(TrialNum,ROINum,FrameLengthAns);

for nTr = 1 : TrialNum
     DataAlignedSoundOn(nTr,:,:) = RawData(nTr,:,AlignInds(nTr):(AlignInds(nTr)+FrameLength-1));
     if TimeAnswerF(nTr)
         DataAlignAnsFrame(nTr,:,:) = RawData(nTr,:,AnsAlignInds(nTr):(AnsAlignInds(nTr)+FrameLengthAns-1));
     end
end

% GivenFWin = FrameRate*1.5;
SoundSigInds = AlignSigRespCheck(DataAlignedSoundOn,alignFrame,FrameWin);
AnsSigInds = AlignSigRespCheck(DataAlignAnsFrame,AnswerAlignF,FrameWin);

if ~isdir('./Response_Type_classification/')
    mkdir('./Response_Type_classification/');
end
cd('./Response_Type_classification/');
    
% classify siginds based on behavior parameters
%%
% sound response classifing
% only classified as left and right trials
LeftTInds = TrialTypes == 0;
RightTInds = TrialTypes == 1;
SoundSigLeft = SoundSigInds(LeftTInds,:);
SoundSigRight = SoundSigInds(RightTInds,:);
MeanSigLeft = mean(SoundSigLeft);
MeanSigRight = mean(SoundSigRight);
SummarySigInds = [MeanSigLeft;MeanSigRight];
%%
if ~isdir('./SoundResponse_Plot/')
    mkdir('./SoundResponse_Plot/');
end
cd('./SoundResponse_Plot/');
LeftIndsData = squeeze(mean(DataAlignedSoundOn(LeftTInds,:,:)));  % nROI by nFrame
RightIndsData = squeeze(mean(DataAlignedSoundOn(RightTInds,:,:))); % nROI by nFrame
SoundSigInds = zeros(ROINum,2);  % first column stands for left trials, second column stands for right trials
SoundSigData = zeros(ROINum,4); 
for nroi = 1 : ROINum
    h = figure;
    hold on;
    cLeftTrace = (LeftIndsData(nroi,:));
    cRightTrace = (RightIndsData(nroi,:));
    if mean((cLeftTrace((alignFrame+1):(alignFrame+FrameWin)))) > 3 * mean(cLeftTrace(1:alignFrame)) && mean(cLeftTrace(1:alignFrame)) > 0
        
        SoundSigData(nroi,1:2) = [mean((cLeftTrace((alignFrame+1):(alignFrame+FrameWin)))),...
            mean(cLeftTrace(1:alignFrame))];
        if max((cLeftTrace((alignFrame+1):(alignFrame+FrameWin)))) > 3 * UpdateStd(nroi)
            SoundSigInds(nroi,1) = 1;
        end
    end
    if mean(smooth(cRightTrace((alignFrame+1):(alignFrame+FrameWin)))) > 3 * mean(cRightTrace(1:alignFrame)) && mean(cRightTrace(1:alignFrame)) > 0
        
        SoundSigData(nroi,3:4) = [mean(smooth(cRightTrace((alignFrame+1):(alignFrame+FrameWin)))),...
            mean(cRightTrace(1:alignFrame))];
        if max(smooth(cRightTrace((alignFrame+1):(alignFrame+FrameWin)))) > 3 * UpdateStd(nroi)
            SoundSigInds(nroi,2) = 1;
        end
    end
    plot((1:length(cLeftTrace))/FrameRate,cLeftTrace,'b');
    plot((1:length(cLeftTrace))/FrameRate,cRightTrace,'r');
    y_axis = axis;
    line([alignFrame alignFrame]/FrameRate,[y_axis(3) y_axis(4)],'color',[.8 .8 .8],'LineWidth',1.5);
    line([alignFrame+FrameWin,alignFrame+FrameWin]/FrameRate,[y_axis(3) y_axis(4)],'color',[.8 .8 .8],'LineWidth',1.5);
    text([alignFrame+FrameWin,alignFrame+FrameWin]/FrameRate,[cLeftTrace(alignFrame+FrameWin),cRightTrace(alignFrame+FrameWin)],...
        {num2str(SoundSigInds(nroi,1)),num2str(SoundSigInds(nroi,2))},'color','k','FontSize',22);
    t = text([0.6*y_axis(2) 0.6*y_axis(2) 0.6*y_axis(2)],[0.9*y_axis(4) (0.74*y_axis(4)) (0.6*y_axis(4))],...
        {sprintf('%.2f>%.2f',mean((cLeftTrace((alignFrame+1):(alignFrame+FrameWin)))),3*mean(cLeftTrace(1:alignFrame))...
        ),sprintf('%.2f>%.2f',mean(smooth(cRightTrace((alignFrame+1):(alignFrame+FrameWin)))),...
        3 * mean(cRightTrace(1:alignFrame))),sprintf('3*STD=%.2f',3 * UpdateStd(nroi))},'color','k','FontSize',18);
    t(1).Color = 'b';
    t(2).Color = 'r';
    xlabel('Time');
    ylabel('Fluo response');
    title(['ROI' num2str(nroi)]);
    set(gca,'FontSize',20);
%     waitforbuttonpress;
    saveas(h,sprintf('Sound response Plot ROI%d',nroi));
    saveas(h,sprintf('Sound response Plot ROI%d',nroi),'png');
    close(h);
end
cd ..;
save SoundRespData.mat SoundSigInds SoundSigData -v7.3

%%
% Answer response classifing
% four different types being considered
LeftCorrInds = TrialTypes == 0 & TrialOut' == 1;
LeftErroInds = TrialTypes == 0 & TrialOut' == 0;
RightCorrInds = TrialTypes == 1 & TrialOut' == 1;
RightErroInds = TrialTypes == 1 & TrialOut' == 0;
MeanLeftCorrSig = mean(AnsSigInds(LeftCorrInds,:));
if sum(LeftErroInds) == 1
    MeanLeftErroSig = AnsSigInds(LeftErroInds,:);
elseif sum(LeftErroInds) < 1
    MeanLeftErroSig = zeros(1,ROINum)-1;
else
    MeanLeftErroSig = mean(AnsSigInds(LeftErroInds,:));
end
MeanRightCorrSig = mean(AnsSigInds(RightCorrInds,:));
if sum(RightErroInds) == 1
    MeanRightErroSig = AnsSigInds(RightErroInds,:);
elseif sum(RightErroInds) < 1
    MeanRightErroSig = zeros(1,ROINum)-1;
else
    MeanRightErroSig = mean(AnsSigInds(RightErroInds,:));
end
SummarySigIndsAns = [MeanLeftCorrSig;MeanLeftErroSig;MeanRightCorrSig;MeanRightErroSig];
% DataAlignAnsFrame
% figure('position',[500 120 1050 1000]);
%%
if ~isdir('./AnsResponse_Plot/')
    mkdir('./AnsResponse_Plot/');
end
cd('./AnsResponse_Plot/');
LeftCorrAnsData = squeeze(mean(DataAlignAnsFrame(LeftCorrInds,:,:)));
RightCorrAnsData = squeeze(mean(DataAlignAnsFrame(RightCorrInds,:,:)));
AnsSigInds = zeros(ROINum,2);
% AnsSigData = zeros(ROINum,4);
for nROI = 1 : ROINum
    h_ans = figure('position',[770 60 1050 1000]);
    CAnsLeftTrace = LeftCorrAnsData(nROI,:);
    CAnsRightTrace = RightCorrAnsData(nROI,:);
    
    %
     % consecutive increase of fluo value, and high value higher than 3 times baseline mean
     pgmodel = fitrgp((1:length(CAnsLeftTrace))',CAnsLeftTrace','Basis','linear','FitMethod','exact','PredictMethod','exact');
     FitY = resubPredict(pgmodel);
     DiffY = diff([FitY(1);FitY]) > 1; % given a minimum increse speed
     SmoothDiffY = smooth(double(DiffY),20); % at least 20 consecutive increase of current trace
     SigTraceInds = find(SmoothDiffY(AnswerAlignF:end) > 0.9,1,'first'); % the first index that meets former constraints
    if ~isempty(SigTraceInds)
        if SigTraceInds < round(1.5 * FrameRate)  % this increase should happens within 1.5s after answer onset
            if max(CAnsLeftTrace((AnswerAlignF+1):(AnswerAlignF+FrameWin))) > 3 * SoundSigData(nROI,2) % above 3 times of baseline
                AnsSigInds(nROI,1) = 1;
            end
        end
    else
        DecreaseY = diff([FitY(1);FitY]) < -1;
        smoothDeY = smooth(double(DecreaseY),20);
        SigIndsDe = find(smoothDeY(AnswerAlignF:end)>0.9,1,'first');
        if isempty(SigIndsDe)  % no consecutive decrease after answer time
            if max(CAnsLeftTrace((AnswerAlignF+1):(AnswerAlignF+FrameWin))) > 3 * SoundSigData(nROI,2)
               if SoundSigInds(nROI,1) && mean(CAnsLeftTrace((AnswerAlignF+1):(AnswerAlignF+FrameWin))) > 0.8 * SoundSigData(nROI,1)
                   AnsSigInds(nROI,1) = 2;  % peak overlap
               end
            end
        end
    end
    
    pgmodel = fitrgp((1:length(CAnsRightTrace))',CAnsRightTrace','Basis','linear','FitMethod','exact','PredictMethod','exact');
     FitY = resubPredict(pgmodel);
     DiffY = diff([FitY(1);FitY]) > 1; % given a minimum increse speed
     SmoothDiffY = smooth(double(DiffY),20); % at least 20 consecutive increase of current trace
     SigTraceInds = find(SmoothDiffY(AnswerAlignF:end) > 0.9,1,'first'); % the first index that meets former constraints
    if ~isempty(SigTraceInds)
        if SigTraceInds < round(1.5 * FrameRate)  % this increase should happens within 1.5s after answer onset
            if max(CAnsRightTrace((AnswerAlignF+1):(AnswerAlignF+FrameWin))) > 3 * SoundSigData(nROI,4) % above 3 times of baseline
                AnsSigInds(nROI,2) = 1;
            end
        end
    else
        DecreaseY = diff([FitY(1);FitY]) < -1;
        smoothDeY = smooth(double(DecreaseY),20);
        SigIndsDe = find(smoothDeY(AnswerAlignF:end)>0.9,1,'first');
        if isempty(SigIndsDe)  % no consecutive decrease after answer time
            if max(CAnsRightTrace((AnswerAlignF+1):(AnswerAlignF+FrameWin))) > 3 * SoundSigData(nROI,4)
               if SoundSigInds(nROI,2) && mean(CAnsRightTrace((AnswerAlignF+1):(AnswerAlignF+FrameWin))) > 0.8 * SoundSigData(nROI,3)
                   AnsSigInds(nROI,2) = 2;  % peak overlap
               end
            end
        end
    end
    
    subplot(2,1,1)
    hold on
    plot((1:length(LeftIndsData(nROI,:)))/FrameRate,LeftIndsData(nROI,:),'b');
    plot((1:length(RightIndsData(nROI,:)))/FrameRate,RightIndsData(nROI,:),'r');
    y_axis = axis;
    line([alignFrame alignFrame]/FrameRate,[y_axis(3) y_axis(4)],'color',[.8 .8 .8],'LineWidth',1.5);
    text([alignFrame+20,alignFrame+20]/FrameRate,[LeftIndsData(nROI,alignFrame+20),RightIndsData(nROI,alignFrame+20)],...
        {num2str(SoundSigInds(nROI,1)),num2str(SoundSigInds(nROI,2))},'Color','k','FontSize',22);
    xlabel('Time');
    ylabel('Fluo response');
    set(gca,'FontSize',20);
%     waitforbuttonpress;
%     close(h_ans);
    
    subplot(2,1,2)
    hold on
    plot((1:length(CAnsLeftTrace))/FrameRate,CAnsLeftTrace,'b');
    plot((1:length(CAnsRightTrace))/FrameRate,CAnsRightTrace,'r');
    y_axis = axis;
    line([AnswerAlignF AnswerAlignF]/FrameRate,[y_axis(3) y_axis(4)],'color',[.8 .8 .8],'LineWidth',1.5);
    tt=text([AnswerAlignF+20 AnswerAlignF+20]/FrameRate,[CAnsLeftTrace(AnswerAlignF+20),CAnsRightTrace(AnswerAlignF+20)],...
        {num2str(AnsSigInds(nROI,1)),num2str(AnsSigInds(nROI,2))},'color','k','FontSize',22);
    tt(1).Color = 'b';
    tt(2).Color = 'r';
    xlabel('Time');
    ylabel('Fluo response');
    set(gca,'FontSize',20);
    
    suptitle(sprintf('ROI%d',nROI));
%     waitforbuttonpress;
    saveas(h_ans,sprintf('Answer Response plot ROI%d',nROI));
    saveas(h_ans,sprintf('Answer Response plot ROI%d',nROI),'png');
    close(h_ans);
end

cd ..;
save AnsRespData.mat AnsSigInds -v7.3

cd ..;
function SigInds = AlignSigRespCheck(AlignData,AlignFrame,FrameWin)
% two constraints will be used for this test
% peak value and peak width
% FrameWin normally should be a 1s time window, selected after align frame

[Trialnum,ROINum,~] = size(AlignData);
SigInds = zeros(Trialnum,ROINum);
for nROI = 1 : ROINum
    cROIdata = squeeze(AlignData(:,nROI,:));
    if sum(sum(cROIdata)) ~= 0
        for nTr = 1 : Trialnum
            cTrace = cROIdata(nTr,:);
            if mean(cTrace((AlignFrame+1):(AlignFrame + FrameWin))) > 2*(mean(cTrace(1:AlignFrame))) && mean(cTrace(1:AlignFrame)) > 0
                TimeWinData = cTrace((AlignFrame+1):(AlignFrame + FrameWin));
                Peakvalue = max(TimeWinData);
                UpthresInds = smooth(double(cTrace > 0.25 * Peakvalue),20);
                if max(UpthresInds((AlignFrame+1):(AlignFrame + FrameWin))) > 0.9
                    SigInds(nTr,nROI) = 1;
                end
            end
        end
    end
end

            
