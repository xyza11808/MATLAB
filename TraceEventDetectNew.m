function varargout = TraceEventDetectNew(RawTrace,filterOps,EventOps,varargin)
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
%         ABSPeakValue:    absolute peak value threshold
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
if ~isfield(filterOps,'ABSPeakValue')
    EventOps.ABSPeakValue = 0.2;
end
IsSmTraceGiven = 0;
if nargin > 3
    if ~isempty(varargin{1})
        NFNew = varargin{1};
        IsSmTraceGiven = 1;
    end
end

if ~IsSmTraceGiven
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
    NeededDatapoints = 3*(length(cDesNew.Coefficients) - 1);
    ExtraRepeatsNum = ceil(NeededDatapoints/length(RawTrace));
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
end

if filterOps.IsPlot
    hhhf = figure('position',[200 100 1260 420],'visible','off');
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
PeakValueThres = BaselineValue+EventStd * EventOps.PeakThres;
[pks,locs] = findpeaks(NFNew,'MinPeakHeight',PeakValueThres,...
    'MinPeakDistance',round(EventOps.MinHalfPeakWid * filterOps.Fr * 2));
[TFs,pp] = islocalmin(NFNew,'MinSeparation',round(EventOps.MinHalfPeakWid * filterOps.Fr * 2),...
    'FlatSelection', 'first');
SigMinimalPoints = pp > (EventStd * 3);
UsedMinimIndex = (TFs(:) & SigMinimalPoints(:));

% diff value calculation for threshold detection
span1 = round(filterOps.Fr*0.2);
span2 = round(filterOps.Fr*0.3);
span3 = round(filterOps.Fr*0.5);
Span1DiffData = [zeros(span1-1,1);NFNew(span1:end) - NFNew(1:(end-span1+1))];
Span2DiffData = [zeros(span2-1,1);NFNew(span2:end) - NFNew(1:(end-span2+1))];
Span3DiffData = [zeros(span3-1,1);NFNew(span3:end) - NFNew(1:(end-span3+1))];
DiffThress = std(Residues)*1.05;

%%

if isempty(locs)
    warning('No peak have been found using current parameters.\n');
    NFNew = [];
    MergedEventsAll = {};
    PlotHandles = {{},{}};
    if nargout == 1
        varargout = {{NFNew,MergedEventsAll,PlotHandles}};
    elseif nargout == 2
        varargout{1} = NFNew;
        varargout{2} = MergedEventsAll;
    elseif nargout == 3
        varargout{1} = NFNew;
        varargout{2} = MergedEventsAll;
        varargout{3} = PlotHandles;
    end
    return;
else
    OnsetThresValue = BaselineValue+EventStd * EventOps.OnsetThres;
    OffsetThresValue = BaselineValue+EventStd * EventOps.OffsetThres;
    NFData_diff = [0.1;diff(NFNew)];
    
    nPeaks = length(locs);
    MaskTraces = zeros(NumTrace,1);
    PeakDataSummary = zeros(nPeaks,3);
    
    stdThres = prctile(NFNew,[10 90 8]);
    CalStd = std(NFNew(NFNew > stdThres(1) & NFNew < stdThres(2)));
    PeakValueThresNew = CalStd * 3 + stdThres(3);
    
    for cP = 1 : nPeaks
        cPLocs = locs(cP);
        if MaskTraces(cPLocs) || cPLocs < PeakValueThresNew
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
        NegDiffData_Inds = find(NFData_diff(OnsetIndex:cPLocs) < 0,round(filterOps.Fr/2),'last');
        if length(NegDiffData_Inds) == round(filterOps.Fr/2)
            OnsetIndex = NegDiffData_Inds(1)+OnsetIndex;
        end
        
        OffsetTemp_index = find(NFNew(cPLocs:end) < OffsetThresValue,1,'first');
        if isempty(OffsetTemp_index)
            OffsetIndex = length(NFNew);
        else
            OffsetIndex = cPLocs + OffsetTemp_index - 1;
            if pks(cP) < 0.15 % exclude small value events
                if (OffsetIndex - cPLocs) <  (cPLocs - OnsetIndex)*2 % must be a asymmetric peak
                    continue;
                end
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
                if max(cPeakData(CanditateRange(1):CanditateRange(2))) > min((PeakValue/2),0.3)
                    % exclude current part from peak range
                    ccData = cPeakData(CanditateRange(1):CanditateRange(2));
                    [~,Inds] = max(ccData);
                    AllPeakRanges(cPosMinima,:) = [CanditateRange(1)+Inds-1,CanditateRange'];
                else
                    cPeakDiff2Data = Span2DiffData(cPeakRange(1):cPeakRange(2));
                    cPeakDiff3Data = Span3DiffData(cPeakRange(1):cPeakRange(2));
                    cPosEventDiff2Data = cPeakDiff2Data(CanditateRange(1):CanditateRange(2));
                    cPosEventDiff3Data = cPeakDiff3Data(CanditateRange(1):CanditateRange(2));
                    if max(cPosEventDiff2Data) > DiffThress
                        % small events after main events
                        ccData = cPeakData(CanditateRange(1):CanditateRange(2));
                        [~,Inds] = max(ccData);
                        AllPeakRanges(cPosMinima,:) = [CanditateRange(1)+Inds-1,CanditateRange'];
                    elseif max(cPosEventDiff3Data) > DiffThress
                        ccData = cPeakData(CanditateRange(1):CanditateRange(2));
                        [~,Inds] = max(ccData);
                        ccDataDiff = [0;diff(ccData)];
                        BackTimeLapse = round(filterOps.Fr*0.5);
                        if  Inds > BackTimeLapse
                            if sum(ccDataDiff((Inds-BackTimeLapse+1):Inds)) == BackTimeLapse
                                AllPeakRanges(cPosMinima,:) = [CanditateRange(1)+Inds-1,CanditateRange'];
                            end
                        end
                    end
                end
            end
            RealSplitPeakRange = AllPeakRanges(AllPeakRanges(:,1) > 0,:) + cPeakRange(1) - 1;
            MergePeakCellAll{cPeaks} = RealSplitPeakRange;
        else
            MergePeakCellAll{cPeaks} = RealPeakIndex(cPeaks,:);
        end
    end
    
end
if ~isempty(MergePeakCellAll)
    MergedEventsAll = cell2mat(MergePeakCellAll);
    if IsStartFalse && MergedEventsAll(1,2) == 1
        MergedEventsAll(1,:) = [];
    end
    
    %
    NumEvents = size(MergedEventsAll,1);
    EventTrace = zeros(NumTrace,1);
    for cE = 1 : NumEvents
        EventTrace(MergedEventsAll(cE,2):MergedEventsAll(cE,3)) = 1;
        cEventData = NFNew(MergedEventsAll(cE,2):MergedEventsAll(cE,3));
        [MaxData,MaxInds] = max(cEventData);
        if max(MaxData) < 1
            MergedEventsAll(cE,4) = 1;
        else
            if numel(cEventData) > (round(filterOps.Fr)+1)
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
            else
                MergedEventsAll(cE,4) = 1;
            end
            
        end
        MergedEventsAll(cE,1) = MaxInds + MergedEventsAll(cE,2) - 1;
    end
else
    MergedEventsAll = [];
end
%%

PlotHandles = {[],[]};
if filterOps.IsPlot
    PlotHandles{1} = hhhf;
end

if EventOps.IsPlot
    hf = figure('position',[100 30 1500 420],'visible','off');
    hold on
    plot(NFNew,'k','linewidth',1.2);
    
    set(gca,'box','off');
    PlotHandles{2} = hf;
    
    line([1 numel(NFNew)],[DiffThress,DiffThress],'Color','g','linestyle','--','linewidth',1.4);
    hl1 = plot(Span1DiffData,'c');
    hl2 = plot(Span2DiffData,'b');
    hl3 = plot(Span3DiffData,'m');
    % yscales = get(gca,'ylim');
    legend([hl1,hl2,hl3],{'0.2s','0.3s','0.5s'},'box','off','AutoUpdate','off','location','northwest');
end

if ~isempty(MergedEventsAll)
    %     NumRealPeaks = size(RealPeakIndex,1);
    NumEvents = size(MergedEventsAll,1);
    ExcludeEvent = zeros(NumEvents,1);
    LMFitSqr = zeros(NumEvents,1);
    NewEventTrace  = EventTrace;
    warning off
    for cEvent = 1 : NumEvents
        cEventIndex = MergedEventsAll(cEvent,[2,3]);
        span1DiffData = Span1DiffData(cEventIndex(1):cEventIndex(2));
        span2DiffData = Span2DiffData(cEventIndex(1):cEventIndex(2));
        span3DiffData = Span3DiffData(cEventIndex(1):cEventIndex(2));
        ccEventDatas = NFNew(cEventIndex(1):cEventIndex(2));
        Fitx = (1 : numel(ccEventDatas))';
        fittb = fitlm(Fitx,ccEventDatas);
        LMFitSqr(cEvent) = fittb.Rsquared.Adjusted*sign(fittb.Coefficients.Estimate(2));
        % if not all diff values are above threshold
        if ~(max(span1DiffData) > DiffThress && max(span2DiffData) > DiffThress && max(span3DiffData) > DiffThress)
            
            if max(span3DiffData) < DiffThress % if the maximum raise slope is low, skip following estimation
                ExcludeEvent(cEvent) = 1;
                NewEventTrace(cEventIndex(1):cEventIndex(2)) = 0;
                continue;
            end
            
            PeakData = NFNew(MergedEventsAll(cEvent,1));
            if max(span2DiffData) > DiffThress && max(span3DiffData) > DiffThress && max(ccEventDatas) > PeakValueThresNew
                if diff(cEventIndex) > round(filterOps.Fr)
                    [~,Locs] = findpeaks(span3DiffData,'MinPeakHeight',DiffThress,...
                        'MinPeakDistance',round(filterOps.Fr));
                    MergedEventsAll(cEvent,4) = max(numel(Locs),1);
                else
                    MergedEventsAll(cEvent,4) = 1;
                end
            elseif ccEventDatas(1) > PeakValueThres && PeakData > PeakValueThresNew
                DiffDatas = [0;diff(ccEventDatas)];
                PeakRelateInds = MergedEventsAll(cEvent,1) - cEventIndex(1);
                if PeakRelateInds < filterOps.Fr
                    if mean(DiffDatas(1:PeakRelateInds)) == 1
                        if diff(cEventIndex) > round(filterOps.Fr)
                            [~,Locs] = findpeaks(span3DiffData,'MinPeakHeight',DiffThress,...
                                'MinPeakDistance',round(filterOps.Fr));
                            MergedEventsAll(cEvent,4) = max(numel(Locs),1);
                        else
                            MergedEventsAll(cEvent,4) = 1;
                        end
                    end
                else
                    if sum(DiffDatas((PeakRelateInds - filterOps.Fr+1):PeakRelateInds)) == filterOps.Fr
                        if diff(cEventIndex) > round(filterOps.Fr)
                            [~,Locs] = findpeaks(span3DiffData,'MinPeakHeight',DiffThress,...
                                'MinPeakDistance',round(filterOps.Fr));
                            MergedEventsAll(cEvent,4) = max(numel(Locs),1);
                        else
                            MergedEventsAll(cEvent,4) = 1;
                        end
                    end
                end
            else
                ExcludeEvent(cEvent) = 1;
                NewEventTrace(cEventIndex(1):cEventIndex(2)) = 0;
            end
        else
            if diff(cEventIndex) < round(2*filterOps.Fr)
                % the events is too short to be real, check the diff
                % ratio
                if max(span1DiffData) < std(Residues)*2 % sharp increase
                    ExcludeEvent(cEvent) = 1;
                    NewEventTrace(cEventIndex(1):cEventIndex(2)) = 0;
                else
                    MergedEventsAll(cEvent,4) = 1;
                end
            else
                if diff(cEventIndex) > round(filterOps.Fr)
                    [~,Locs] = findpeaks(span3DiffData,'MinPeakHeight',DiffThress,...
                        'MinPeakDistance',round(filterOps.Fr));
                    MergedEventsAll(cEvent,4) = max(numel(Locs),1);
                else
                    MergedEventsAll(cEvent,4) = 1;
                end
            end
        end
        if ~ExcludeEvent(cEvent)
            if diff(cEventIndex) > round(filterOps.Fr)
                [~,Locs] = findpeaks(span3DiffData,'MinPeakHeight',DiffThress,...
                    'MinPeakDistance',round(filterOps.Fr));
                MergedEventsAll(cEvent,4) = max(numel(Locs),1);
            else
                MergedEventsAll(cEvent,4) = 1;
            end
            
            UpperThres = BaselineValue+EventStd * 3;% number of response above thres
            LengthThres = round(0.5*filterOps.Fr);
            EventDatas = NFNew(cEventIndex(1):cEventIndex(2));
            ContinueAboveInds = smooth(EventDatas > UpperThres, LengthThres);
            if isempty(find(ContinueAboveInds > (1-1/LengthThres), 1)) % no continued time length data above threshold
                ExcludeEvent(cEvent) = 1;
                NewEventTrace(cEventIndex(1):cEventIndex(2)) = 0;
            end
            
            if (max(ccEventDatas) - min(ccEventDatas)) <  EventStd*5 || ...
                    (diff(cEventIndex) > filterOps.Fr * 20)%if the peak was low
                if diff(cEventIndex) <= round(filterOps.Fr)
                    ExcludeEvent(cEvent) = 1;
                    NewEventTrace(cEventIndex(1):cEventIndex(2)) = 0;
                    continue;
                end
                [~,Locs] = findpeaks(span1DiffData,'MinPeakHeight',DiffThress,...
                    'MinPeakDistance',round(filterOps.Fr));
                [~,LocsForPeak] = findpeaks(span2DiffData,'MinPeakHeight',DiffThress,...
                    'MinPeakDistance',round(filterOps.Fr));
                MergedEventsAll(cEvent,4) = max(numel(LocsForPeak),1);
                if ~(length(Locs) >= 1 && max(ccEventDatas) > EventStd*10)
                    if diff(cEventIndex) > filterOps.Fr * 15  % if the event is extremly long
                        if MergedEventsAll(cEvent,4) < 3
                            ExcludeEvent(cEvent) = 1;
                            NewEventTrace(cEventIndex(1):cEventIndex(2)) = 0;
                        end
                    elseif diff(cEventIndex) > filterOps.Fr * 12  % if the event is quiet long
                        if MergedEventsAll(cEvent,4) < 2
                            ExcludeEvent(cEvent) = 1;
                            NewEventTrace(cEventIndex(1):cEventIndex(2)) = 0;
                        end
                    end
                end
            end
            % linear fitting condition for flat response
            if ~ExcludeEvent(cEvent)
                if max(span1DiffData) < DiffThress % whether a sharp increase was existed
                    IsEventExclude = 0;
                    % If not,check the r-square values
                    if LMFitSqr(cEvent) < 0
                        if MergedEventsAll(cEvent,4) == 1
                            RsquareThres = 0.2;
                            if abs(LMFitSqr(cEvent)) < RsquareThres
                                IsEventExclude = 1;
                            end
                        elseif MergedEventsAll(cEvent,4) > 1
                            RsquareThres = 0.1;
                            if abs(LMFitSqr(cEvent)) < RsquareThres
                                IsEventExclude = 1;
                            end
                        end
                    else
                        IsEventExclude = 1;
                    end
                    
                    if IsEventExclude
                        ExcludeEvent(cEvent) = 1;
                        NewEventTrace(cEventIndex(1):cEventIndex(2)) = 0;
                    end
                    
                end
                
            end
        end
    end
    warning on
    
    MergedEventsAll(logical(ExcludeEvent),:) = [];
    LMFitSqr(logical(ExcludeEvent)) = [];
    EventData = nan(NumTrace,1);
    EventData(logical(EventTrace)) = NFNew(logical(EventTrace));
    
    if EventOps.IsPlot
        plot(EventData,'r','linewidth',1.2);
        
        if ~isempty(MergedEventsAll)
            
            NewEventData = nan(NumTrace,1);
            NewEventData(logical(NewEventTrace)) = NFNew(logical(NewEventTrace));
            
            
            plot(NewEventData,'Color',[1 0.7 0.2],'linewidth',1.2);
            
            line([1 numel(EventData)],[BaselineValue BaselineValue],'Color','k','linestyle','--');
            
            
            xxxx = 1 : NumTrace;
            plot(xxxx(MergedEventsAll(:,1)),NFNew(MergedEventsAll(:,1)),'co');
            
            yscales = get(gca,'ylim');
            plot(([MergedEventsAll(:,2),MergedEventsAll(:,2)])'-1,yscales,'Color','m','linestyle','--','linewidth',1.2);
            plot(([MergedEventsAll(:,3),MergedEventsAll(:,3)])'+1,yscales,'Color','b','linestyle','--','linewidth',1.2);
            text(xxxx(MergedEventsAll(:,1)),NFNew(MergedEventsAll(:,1))+0.01,num2str(MergedEventsAll(:,4)));
            text(xxxx(MergedEventsAll(:,1)),NFNew(MergedEventsAll(:,1))+0.02,num2str(LMFitSqr(:),'%.3f'),'FontSize',12,'color','r');
            set(gca,'xlim',[0 length(NFNew)+1]);
        end
    end
end


% Tau_on = 0.01; %s
% Tau_off = 0.5; %s
% A = 1;
% t_0 = 0;
% t_index = 0:0.02:10;
%
% CalEventsFun = @(x) A*(1 - exp(-(x - t_0)/Tau_on)) .* exp(-(x - t_0)/Tau_off);
%
% CalEvents = CalEventsFun(t_index);
% %%
%
% Tau_off_Vec = 1:0.5:5;
% nTau_off = numel(Tau_off_Vec);
% Tau_on_Vec = 0.1:0.05:1;
% nTau_on = numel(Tau_on_Vec);

%%
if nargout == 1
    varargout = {{NFNew,MergedEventsAll,PlotHandles}};
elseif nargout == 2
    varargout{1} = NFNew;
    varargout{2} = MergedEventsAll;
elseif nargout == 3
    varargout{1} = NFNew;
    varargout{2} = MergedEventsAll;
    varargout{3} = PlotHandles;
end


