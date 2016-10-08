function varargout = ChoiceProbCal(RawData,TrialFreq,ActionChoice,TimeScale,OnFrame,FrameRate,varargin)
% this function is tried to calculate the choice probability for each ROI
% and try to find whether there are some differences of firing rate between
% correct and error trials
% Xin Yu, 2016/06/24
IsBoundary = 0;
if nargin > 6
    if ~isempty(varargin{1})
        FreqBoundary = varargin{1};
        IsBoundary = 1;
    end
end
isplot = 1;
if nargin > 7
    isplot = varargin{2};
end
if ~IsBoundary
    fprintf('There is no valid frequency boundary input, please input a value as frequency boundary.\n');
    Boundary = input('Please Input current session''s frequency boundary.\n','s');
    FreqBoundary = str2num(Boundary); %#ok<ST2NM>
end

nmissTrialInds = ActionChoice == 2;
ExmissData = RawData(~nmissTrialInds,:,:);
ExmissTrialFreq = TrialFreq(~nmissTrialInds);
ExmissToutcome = ActionChoice(~nmissTrialInds);
[nTrials,nROIs,nFrames] = size(ExmissData);

FreqType = double(unique(ExmissTrialFreq));
OctaveType = log2(FreqType/min(FreqType));
VariScale = 0.1*min(diff(OctaveType));  % minus and add

if length(TimeScale) == 1
    FrameSelect = round(sort([OnFrame,(OnFrame+(FrameRate*TimeScale))]));
elseif length(TimeScale) == 2
    FrameSelect = round(sort([(OnFrame+(FrameRate*TimeScale(1))),(OnFrame+(FrameRate*TimeScale(2)))]));
else
    error('Current input timescale length is %d, but it can only be 1 or 2.',length(TimeScale));
end

if FrameSelect(1) < 1
    FrameSelect(1) = 1;
end
if FrameSelect(2) > nFrames
    FrameSelect(2) = nFrames;
end
if isplot
    if ~isdir('./Choice_prob_plot/')
        mkdir('./Choice_prob_plot/');
    end
    cd('./Choice_prob_plot/');
end

MeanTypeData = zeros(nROIs,length(FreqType),2);
StdTypeData = zeros(nROIs,length(FreqType),2);
NumTypeData = zeros(nROIs,length(FreqType),2);
DataStoreCell = cell(nROIs,length(FreqType),2);
DataSig = zeros(nROIs,length(FreqType),2) - 1;

for nROI = 1 : nROIs
    for nfreq = 1 : length(FreqType)
        cfreq = FreqType(nfreq);
        cFreqInds = ExmissTrialFreq == cfreq;
        cFreqResult = ExmissToutcome(cFreqInds);
        cFreqData = squeeze(ExmissData(cFreqInds,nROI,FrameSelect(1):FrameSelect(2)));
        cFreqMax = max(cFreqData,[],2);
        CorrectData = cFreqMax(cFreqResult == 1);  % rightward choice trials
        ErrorData = cFreqMax(cFreqResult == 0); % leftward choice trials
        MeanTypeData(nROI,nfreq,:) = [mean(CorrectData),mean(ErrorData)];
        StdTypeData(nROI,nfreq,:) = [std(CorrectData),std(ErrorData)];
        NumTypeData(nROI,nfreq,:) = [length(CorrectData),length(ErrorData)];
        DataStoreCell(nROI,nfreq,:) = {{CorrectData},{ErrorData}};
    end
    if isplot
        h_roi = figure('position',[680 300 970 800],'Paperpositionmode','auto');
        hold on;
    %     cROItrialNum = zeros(length(FreqType) * 2,1);
    %     cROItrialXlabel = zeros(length(FreqType) * 2,1);
        for nfreq = 1 : length(FreqType)
            CorrRandx = ((rand(NumTypeData(nROI,nfreq,1),1)-0.5)*2)*VariScale + OctaveType(nfreq)-VariScale;
            ErroRandx = ((rand(NumTypeData(nROI,nfreq,2),1)-0.5)*2)*VariScale + OctaveType(nfreq)+VariScale;
    %         cROItrialNum(nfreq*2 - 1: nfreq*2) = reshape(NumTypeData(nROI,nfreq,:),[],1);
    %         cROItrialXlabel(nfreq*2 - 1: nfreq*2) = [OctaveType(nfreq)-VariScale;OctaveType(nfreq)+VariScale];
            scatter(CorrRandx,DataStoreCell{nROI,nfreq,1}{:},50,'ro','filled');
            scatter(ErroRandx,DataStoreCell{nROI,nfreq,2}{:},50,'ko','filled');
            if ~(isempty(ErroRandx) || isempty(CorrRandx))
                [h,p] = ttest2(DataStoreCell{nROI,nfreq,1}{:},DataStoreCell{nROI,nfreq,2}{:});
                if ~h
                    DataSig(nROI,nfreq,:) = [0,0];
                else
                    DataSig(nROI,nfreq,:) = [h,p];
                end
            end
        end
        alpha(0.5);
        errorbar((OctaveType - VariScale),squeeze(MeanTypeData(nROI,:,1)),squeeze(StdTypeData(nROI,:,1)),'co','LineWidth',1.8);
        errorbar((OctaveType + VariScale),squeeze(MeanTypeData(nROI,:,2)),squeeze(StdTypeData(nROI,:,2)),'bo','LineWidth',1.8);
        ylimvalue=get(gca,'ylim');
        text(OctaveType,ones(length(OctaveType),1)*ylimvalue(2)*0.9,strsplit(num2str(squeeze(NumTypeData(nROI,:,1))),' '),'color','r','FontSize',15);
        text(OctaveType,ones(length(OctaveType),1)*ylimvalue(2)*0.8,strsplit(num2str(squeeze(NumTypeData(nROI,:,2))),' '),'color','k','FontSize',15);
    %     text(cROItrialXlabel,ones(length(cROItrialXlabel),1)*ylimvalue(2)*0.8,cellstr(num2str(cROItrialNum(:))),'color','b','FontSize',15);

        xlabel('Octave');
        ylabel('Max \DeltaF/F_0');
        title(sprintf('ROI%d response',nROI));
        set(gca,'FontSize',20);
        saveas(h_roi,sprintf('ROI%d response for choice prob',nROI),'fig');
        saveas(h_roi,sprintf('ROI%d response for choice prob',nROI),'png');
        close(h_roi);

        h_line = figure('position',[680 300 970 800],'Paperpositionmode','auto');
        hold on;
        errorbar((OctaveType - VariScale),squeeze(MeanTypeData(nROI,:,1)),squeeze(StdTypeData(nROI,:,1)),'r-o','LineWidth',1.8);
        errorbar((OctaveType + VariScale),squeeze(MeanTypeData(nROI,:,2)),squeeze(StdTypeData(nROI,:,2)),'k-o','LineWidth',1.8);
        ylimvalue=get(gca,'ylim');
        SigInds = (squeeze(DataSig(nROI,:,1)) > 0);
        SigOctave = OctaveType(SigInds);
        if ~isempty(SigOctave)
            ytick = 0.9 * ylimvalue(2);
            scatter(SigOctave,ones(length(SigOctave),1)*ytick,40,'b*','LineWidth',1.8);
        end
        xlabel('Octave');
        ylabel('Max \DeltaF/F_0');
        title(sprintf('ROI%d response',nROI));
        set(gca,'FontSize',20);
        saveas(h_line,sprintf('ROI%d response mean for choice prob',nROI),'fig');
        saveas(h_line,sprintf('ROI%d response mean for choice prob',nROI),'png');
        close(h_line);
    end
end
save ChoiceProbData.mat MeanTypeData StdTypeData NumTypeData DataStoreCell DataSig -v7.3
if isplot
    if ~isdir('./CP_value_cal/')
        mkdir('./CP_value_cal/');
    end
    cd('./CP_value_cal/');
    CP_And_dprime_cal(RawData,TrialFreq,OnFrame,TimeScale,FrameRate,ActionChoice,FreqBoundary)
    % ChoiceProbCal(RawData,TrialFreq,ActionChoice,TimeScale,OnFrame,FrameRate,varargin)
    cd ..;
end
if nargout > 0
    varargout(1) = {DataStoreCell};
    varargout(2) = {NumTypeData};
end
cd ..;