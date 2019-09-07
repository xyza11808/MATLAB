function varargout = TraceEventDetect(RawTrace,filterOps,EventOps)
% function used for events detection, based on filtering result
% using input parameters for filtering and events detection
% for filter options, includes following structures
%    filterOps: 
%         Type:         filter type; lowpass,bandpass,highpass
%         Fr:           raw data frame rate
%         PassBand1:    used for firstpart of bandpass or for the low pass
%         StopBand1:    used for firstpart of bandpass or for the low pass
%         PassBand2:    used for secondpart of bandpass or for the high pass
%         StopBand2:    used for secondpart of bandpass or for the high pass
%         StopAttenu1:  FisrtStop attenuation
%         StopAttenu2:  SecondStop attenuation
%         DesignMethod: Medthod for filtering
%         IsPlot:       Whether plot the raw trace and residues
% for events detection parameters
%     EventOps:
%         NoiseMethod:     Method for noise calculation, Raw_std, Raw_mad or residue
%                          std (Res_std)
%         PeakThres:       factor threshold for calculate peak value
%         BaselinePrc:     Prctile value used for baseline calculation
%         MinHalfPeakWid:  Min half peak width
%         OnsetThres:      Onset threshold ratio
%         OffsetThres:     Offset threshold ratio
%         IsPlot:          Whether plot the event(s) on raw trace

% The output can be filtered trace and detected events

% will not check thether the input parameters is valid or not
% if not,just pop out with an error 
if numel(RawTrace) ~= length(RawTrace)
    error('The input raw trace must be one row or column');
end
NumTrace = numel(RawTrace);
if ~isfield(filterOps,'IsPlot')
    filterOps.IsPlot = 1;
end
FilterTypes = filterOps.Type;
if contains(FilterTypes,'bandpass','IgnoreCase',true)
    fprintf('Performing bandpass filtering of raw data.\n');
    cDesNew = designfilt(filterOps.Type,'PassbandFrequency1',filterOps.PassBand1,'StopbandFrequency1',filterOps.StopBand1,...
        'PassbandFrequency2',filterOps.PassBand2,'StopbandFrequency2',filterOps.StopBand2,'SampleRate',filterOps.Fr,'StopbandAttenuation1',...
        filterOps.StopAttenu1,'StopbandAttenuation2',filterOps.StopAttenu2,'DesignMethod',filterOps.DesignMethod);
    IsBaselineCorrection = 1;
elseif contains(FilterTypes,'lowpass','IgnoreCase',true)
    fprintf('Performing lowpass filtering of raw data.\n');
    cDesNew = designfilt(filterOps.Type,'PassbandFrequency',filterOps.PassBand1,'StopbandFrequency',filterOps.StopBand1,...
        'SampleRate',filterOps.Fr,'StopbandAttenuation',...
        filterOps.StopAttenu1,'DesignMethod',filterOps.DesignMethod);
    IsBaselineCorrection = 0;
elseif contains(FilterTypes,'highpass','IgnoreCase',true)
    fprintf('Performing highpass filtering of raw data.\n');
    cDesNew = designfilt(filterOps.Type,'PassbandFrequency',filterOps.PassBand2,'StopbandFrequency',filterOps.StopBand2,...
        'SampleRate',filterOps.Fr,'StopbandAttenuation',...
        filterOps.StopAttenu1,'DesignMethod',filterOps.DesignMethod);
    IsBaselineCorrection = 0;
end
% performing data filtering 
NeededDatgapoints = 3*(length(cDesNew.Coefficients) - 1);
ExtraRepeatsNum = ceil(NeededDatgapoints/length(RawTrace));
RepDatas = repmat(RawTrace(:),ExtraRepeatsNum,1);
RepNFSignal = filtfilt(cDesNew,RepDatas);
ExtraFiltData = RepNFSignal(1:length(RawTrace));
Residues = RawTrace(:) - ExtraFiltData;
SmoothData = smooth(Residues,0.05,'rloess');
if IsBaselineCorrection
    NFNew = ExtraFiltData + SmoothData;
else
    NFNew = ExtraFiltData;
end

if filterOps.IsPlot
    hhhf = figure('position',[200 100 1260 420]);
    subplot(1,3,[1,2])
    hold on;
    plot(RawTrace,'r');
    plot(NFNew,'k','linewidth',1.2);
%     title(sprintf('Pass %.4f Stop %.4f',PassBand,StopBand));

    subplot(133)
    hold on
    plot(Residues,'b');
    plot(SmoothData,'k','linewidth',1.2)
end

% using filtered data for events detection
switch EventOps.NoiseMethod
    case 'Raw_std'
        EventStd = std(RawTrace);
    case 'Raw_mad'
        EventStd = mad(RawTrace,1)*1.4826;
    case 'Res_std'
        EventStd = std(Residues);
    otherwise
        error('Unkonown std value calculation method.');
end

ResStd = std(Residues);
MadStd = mad(RawTrace,1)*1.4826;
if max(ResStd,MadStd) > min(ResStd,MadStd) * 2
    EventStd = min(ResStd,MadStd);
    warning('Correct for std values.\n');
end
    
IsStartFalse = 0; 
if EventOps.BaselinePrc >= 20
    warning('The baseline calculation prctile was larger than usual condition.\n');
elseif EventOps.BaselinePrc < 1
    error('The prctile value should larger than 1.');
end
BaselineValue = prctile(NFNew,EventOps.BaselinePrc);

[pks,locs] = findpeaks(NFNew,'MinPeakHeight',BaselineValue+EventStd * EventOps.PeakThres,...
    'MinPeakDistance',round(EventOps.MinHalfPeakWid * filterOps.Fr * 2));
[TFs,pp] = islocalmin(NFNew,'MinSeparation',round(EventOps.MinHalfPeakWid * filterOps.Fr * 2),...
    'FlatSelection', 'first');
SigMinimalPoints = pp > (EventStd * 3);
UsedMinimIndex = (TFs(:) & SigMinimalPoints(:));

%%
if isempty(locs)
    warning('No peak have been found using current parameters.\n');
    return;
else
    OnsetThresValue = BaselineValue+EventStd * EventOps.OnsetThres;
    OffsetThresValue = BaselineValue+EventStd * EventOps.OffsetThres; 
    
    nPeaks = length(locs);
    MaskTraces = zeros(NumTrace,1);
    PeakDataSummary = zeros(nPeaks,3);
    for cP = 1 : nPeaks
        cPLocs = locs(cP);
        if MaskTraces(cPLocs)
            continue;
        end
        
        OnsetTemp_index = find(NFNew(1:cPLocs) < OnsetThresValue,1,'last');
        if isempty(OnsetTemp_index)
            if cPLocs == 1
                continue;
            else
                if sum(NFNew(1:(cPLocs-1)) >=  pks(cP)) > 0.8 || cPLocs < round(filterOps.Fr)
                    IsStartFalse = 1;
                    continue;
                else
                    OnsetIndex = 1;
                end
            end
        else
            OnsetIndex = OnsetTemp_index+1;
        end
        
        OffsetTemp_index = find(NFNew(cPLocs:end) < OffsetThresValue,1,'first');
        if isempty(OffsetTemp_index)
            OffsetIndex = length(NFNew);
        else
            OffsetIndex = cPLocs + OffsetTemp_index - 1;
            if (OffsetIndex - cPLocs) <  (cPLocs - OnsetIndex) % must be a asymmetric peak
                continue;
            end
        end
        if (OffsetIndex - OnsetIndex) <=  round(EventOps.MinHalfPeakWid * filterOps.Fr)
            continue;
        end
        MaskTraces(OnsetIndex:OffsetIndex) = 1;
        PeakDataSummary(cP,:) = [cPLocs,OnsetIndex,OffsetIndex];
    end
    %
    RealPeakIndex = PeakDataSummary(PeakDataSummary(:,1) > 0,:);
    % split merged peaks by using local minima index
    nMergedPeak = size(RealPeakIndex,1);
    LocalMinMaskTracce = zeros(numel(NFNew),1);
    LocalMinMaskTracce(UsedMinimIndex) = 1;
    MergePeakCellAll = cell(nMergedPeak,1);
    for cPeaks = 1 : nMergedPeak
        cPeakRange = RealPeakIndex(cPeaks,[2,3]);
        cPeakData = NFNew(cPeakRange(1):cPeakRange(2));
        PeakValue = max(cPeakData);
        if sum(LocalMinMaskTracce(cPeakRange(1):cPeakRange(2)))
            warning('Local minima exists for current events, split into multiple events.');
            LocalMinimaIndex = find(LocalMinMaskTracce(cPeakRange(1):cPeakRange(2)));
            PossMinimaIndex = LocalMinimaIndex(cPeakData(LocalMinimaIndex) <= PeakValue/2);
            WithinRangeIndexAlls = [1;PossMinimaIndex(:);numel(cPeakData)];
            Num_PosMinimaIndex = length(PossMinimaIndex);
            AllPeakRanges = zeros(Num_PosMinimaIndex+1,3);
            for cPosMinima = 1 : Num_PosMinimaIndex+1
                CanditateRange = WithinRangeIndexAlls([cPosMinima,cPosMinima+1]);
                if max(cPeakData(CanditateRange(1):CanditateRange(2))) > (PeakValue/2)
                    % exclude current part from peak range
                    ccData = cPeakData(CanditateRange(1):CanditateRange(2));
                    [~,Inds] = max(ccData);
                    AllPeakRanges(cPosMinima,:) = [CanditateRange(1)+Inds-1,CanditateRange'];
                end
            end
            RealSplitPeakRange = AllPeakRanges(AllPeakRanges(:,1) > 0,:) + cPeakRange(1) - 1;
            MergePeakCellAll{cPeaks} = RealSplitPeakRange;
        else
            MergePeakCellAll{cPeaks} = RealPeakIndex(cPeaks,:);
        end
    end
    
end
MergedEventsAll = cell2mat(MergePeakCellAll);
if IsStartFalse && MergedEventsAll(1,2) == 1
    MergedEventsAll(1,:) = [];
end
%%
NumEvents = size(MergedEventsAll,1);
EventTrace = zeros(NumTrace,1);
for cE = 1 : NumEvents
    EventTrace(MergedEventsAll(cE,2):MergedEventsAll(cE,3)) = 1;
    cEventData = NFNew(MergedEventsAll(cE,2):MergedEventsAll(cE,3));
    [MaxData,MaxInds] = max(cEventData);
    if max(MaxData) < 1
        MergedEventsAll(cE,4) = 1;
    else
        [~,locss] = findpeaks(cEventData,'MinPeakHeight',0.75*MaxData,...
            'MinPeakDistance',round(filterOps.Fr));
        NumLocs = length(locss);
        if numel(locss) > 1
            for cLoc = 1 : (numel(locss)-1)
                cEventLocData = cEventData(locss(cLoc):locss(cLoc+1));
                if (max(cEventLocData) - min(cEventLocData)) < (MaxData/8)
                    NumLocs = NumLocs - 1;
                end
            end
        end
        MergedEventsAll(cE,4) = NumLocs;
    end
    MergedEventsAll(cE,1) = MaxInds + MergedEventsAll(cE,2) - 1;
end
%%
if EventOps.IsPlot && ~isempty(MergedEventsAll)
%     NumRealPeaks = size(RealPeakIndex,1);
    EventData = nan(NumTrace,1);
    EventData(logical(EventTrace)) = NFNew(logical(EventTrace));
    
    hf = figure('position',[100 550 1500 420]);
    hold on
    plot(NFNew,'k','linewidth',1.2);
    plot(EventData,'r','linewidth',1.2);
    line([1 numel(EventData)],[BaselineValue BaselineValue],'Color','k','linestyle','--');
    
    
    xxxx = 1 : NumTrace;
    plot(xxxx(MergedEventsAll(:,1)),NFNew(MergedEventsAll(:,1)),'co');
    
    yscales = get(gca,'ylim');
    plot(([MergedEventsAll(:,2),MergedEventsAll(:,2)])'-1,yscales,'Color','m','linestyle','--','linewidth',1.2);
    plot(([MergedEventsAll(:,3),MergedEventsAll(:,3)])'+1,yscales,'Color','b','linestyle','--','linewidth',1.2);
    text(xxxx(MergedEventsAll(:,1)),NFNew(MergedEventsAll(:,1))+0.05,num2str(MergedEventsAll(:,4)));
    set(gca,'box','off');
end
%%
if nargout == 1
    varargout = {{NFNew,MergedEventsAll}};
elseif nargout == 2
    varargout{1} = NFNew;
    varargout{2} = MergedEventsAll;
end
    
        


        


