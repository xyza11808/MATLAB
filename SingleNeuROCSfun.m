function SingleNeuROCSfun(AlignData,BehavStrc,Frate,AlignF,TrOutcome,varargin)
% this function is used for calculating single cell neuromeric function,
% using AUC values compared with null condition
TrFreq = double(BehavStrc.Stim_toneFreq);
FreqTypes = unique(TrFreq);
if length(FreqTypes) < 6
    error('Error frequency types, should be large than 6, but only %d types exists.',length(FreqTypes));
end
PairNum = floor(length(FreqTypes)/2);
IsBoundTone = 0;
CoupleTones = FreqTypes;
if mod(length(FreqTypes),2) == 1
    IsBoundTone = 1;
    fprintf('Bound freq exits, plotted according to different choice.\n');
    BoundTone = FreqTypes(ceil(length(FreqTypes)/2));
    CoupleTones = FreqTypes;
    CoupleTones(CoupleTones == BoundTone) = [];
end

RespTimeWin = 1.5; % seconds after stimulus onset as response window
if nargin > 5
    if ~isempty(varargin{1})
        RespTimeWin = varargin{1};
    end
end

TrUsage = 0; % trial type used for analysis, 0 means non-missing trials, 1 means correct trials, 2 means all trials
if nargin > 6
    if ~isempty(varargin{2})
       TrUsage = varargin{2};
    end
end

switch TrUsage
    case 0
        TrIndsUsed = TrOutcome ~= 2;
        if ~isdir('./Single_ROI_neurometric/')
            mkdir('./Single_ROI_neurometric/');
        end
        cd('./Single_ROI_neurometric/');
    case 1
        TrIndsUsed = TrOutcome == 1;
        if ~isdir('./Single_ROI_neurometric_corr/')
            mkdir('./Single_ROI_neurometric_corr/');
        end
        cd('./Single_ROI_neurometric_corr/');
    case 2
        TrIndsUsed = true(length(TrOutcome),1);
        if ~isdir('./Single_ROI_neurometric_all/')
            mkdir('./Single_ROI_neurometric_all/');
        end
        cd('./Single_ROI_neurometric_all/');
    otherwise
        warning('Unrecognized trial type usage input, using default value for calculation');
        TrIndsUsed = TrOutcome ~= 2;
end
TrDataUsed = AlignData(TrIndsUsed,:,:);
TrFreqUsed = TrFreq(TrIndsUsed);

if IsBoundTone
    BoundToneInds = TrFreqUsed == BoundTone;
    TrDataUsed(BoundToneInds,:,:) = [];
    TrFreqUsed(BoundToneInds) = [];
end

% convert response time window into frame window
if length(RespTimeWin) == 1
    FrameWin = sort([AlignF,AlignF+(round(RespTimeWin*Frate))]);
elseif length(RespTimeWin) == 2
    FrameWin = sort([(AlignF+(round(RespTimeWin(1)*Frate))),(AlignF+(round(RespTimeWin(2)*Frate)))]);
else
    error('Error window epoch input.');
end

RespData = squeeze(mean(TrDataUsed(:,:,FrameWin(1)+1:FrameWin(2)),3));
ROIpairedAUcValue = zeros(size(RespData,2),PairNum*2);
ROIpairedAUcIsrevert = zeros(size(RespData,2),PairNum);
for cROI = 1 : size(RespData,2)
    cROIdata = RespData(:,cROI);
    for nPair = 1 : PairNum
        nLeftFreq = FreqTypes(nPair);
        nLeftFreqInds = TrFreqUsed == nLeftFreq;
        nRightFreq = FreqTypes(end-nPair+1);
        nRightFreqInds = TrFreqUsed == nRightFreq;
        
        cLeftData = cROIdata(nLeftFreqInds);
        cLeftDataInput = [cLeftData(:),zeros(numel(cLeftData),1)];
        if sum(isnan(cLeftData)) || numel(unique(cLeftData)) < 10
            ROIpairedAUcValue(cROI,nPair) = 0.5;
            ROIpairedAUcValue(cROI,end-nPair+1) = 0.5;
            ROIpairedAUcIsrevert(cROI,nPair) = 0;
            continue;
        end
        cRightData = cROIdata(nRightFreqInds);
        cRightDataInput = [cRightData(:),ones(numel(cRightData),1)];
        if sum(isnan(cRightData)) || numel(unique(cRightData)) < 10
            ROIpairedAUcValue(cROI,nPair) = 0.5;
            ROIpairedAUcValue(cROI,end-nPair+1) = 0.5;
            ROIpairedAUcIsrevert(cROI,nPair) = 0;
            continue;
        end
        
        [ROCSummary,LabelMeanS]=rocOnlineFoff([cLeftDataInput;cRightDataInput]);
        ROIpairedAUcIsrevert(cROI,nPair) = LabelMeanS;
        ROIpairedAUcValue(cROI,nPair) = 1 - ROCSummary;
        ROIpairedAUcValue(cROI,end-nPair+1) = ROCSummary;
    end
end

if ~isdir('./Single_ROI_neurometric_corr/')
    mkdir('./Single_ROI_neurometric_corr/');
end
cd('./Single_ROI_neurometric_corr/');
    
save ROIpairedAUCsave.mat ROIpairedAUcValue ROIpairedAUcIsrevert -v7.3

%%
freqOctave = log2(CoupleTones/16000);
for nROI = 1 : size(ROIpairedAUcValue)
    hf = figure;
    plot(freqOctave,ROIpairedAUcValue(nROI,:),'k-o','linewidth',1.5);
    set(gca,'xtick',freqOctave,'xticklabel',cellstr(num2str(freqOctave(:),'%.1f')),'ytick',[0 0.5 1]);
    xlabel('Octaves');
    ylabel('AUC values');
    title(sprintf('ROI%d AUC plot',nROI));
    set(gca,'FontSize',16);
    saveas(hf,sprintf('ROI%d AUC value savage plot',nROI));
    saveas(hf,sprintf('ROI%d AUC value savage plot',nROI),'png');
    close(hf);
end

cd ..;