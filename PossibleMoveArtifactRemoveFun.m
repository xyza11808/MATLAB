function [MoveFreeTrace, PeakScaleInds] = PossibleMoveArtifactRemoveFun(RawTrace)
% this function finds possible movement artifactfact and remove it from raw
% trace

MoveFreeTrace = RawTrace;
PeakScaleInds = {};
k = 1;
SMTrace = smooth(RawTrace(:),7,'sgolay',3);

SMResidues = RawTrace(:) - SMTrace(:);
ResidueSTD = std(SMResidues);

RawTraceStd = mad(SMTrace,1) * 1.4826;
[RawNegPks, RawNegLocs, W, ~] = findpeaks(-RawTrace,'MinPeakHeight', RawTraceStd*3);
if ~isempty(RawNegLocs)
    PksUsedWidthInds = W > 5 & W < 10;
    UsedRawLocs = RawNegLocs(PksUsedWidthInds);
    RawNumPeaks = length(UsedRawLocs);
    for cRawNegP = 1 : RawNumPeaks
        cRawNegLocc = UsedRawLocs(cRawNegP);
        ccLocsScale = cRawNegLocc + [-3 3]; % extend to the outline position
        [AdInds, AdValues] = MoveFreeFun(SMTrace, ccLocsScale, ResidueSTD);
        MoveFreeTrace(AdInds) = AdValues;
        PeakScaleInds{k,1} = AdInds;
        PeakScaleInds{k,2} = AdValues;
        k = k + 1;
    end
    
    SMTrace = smooth(MoveFreeTrace(:),7,'sgolay',3);
    RawTrace = MoveFreeTrace;
end


RawTraceDiffs = [0;diff(RawTrace(:))];
RawDiff_waveThres = std(RawTraceDiffs) * 3;
NegDiff_waveThres = std(RawTraceDiffs) * 2;
% find  small negtive peaks within raw trace

FrameDiffInds = 9;
[pks,locs] = findpeaks(RawTraceDiffs,'MinPeakHeight',RawDiff_waveThres,...
    'MinPeakDistance',FrameDiffInds); % find positive peaks
[Negpks,Neglocs] = findpeaks(-RawTraceDiffs,'MinPeakHeight',NegDiff_waveThres,...
    'MinPeakDistance',FrameDiffInds); % find Negtive peaks
if isempty(pks) || isempty(Negpks)
    fprint('No Positive or Negtive peak across threshold, should be no movement artifact.\n');
    return;
end

NumPosPeaks = length(pks);


% NumNegPeaks = length(Negpks);
% % NumMoveMents = 1;
for cPosPeak = 1 : NumPosPeaks
    cPosLoc = locs(cPosPeak);
    if find(abs(Neglocs - cPosLoc) < FrameDiffInds & abs(Neglocs - cPosLoc) > 1) 
        % whether there is a negtive peak exists, its highly to be a movement artifact
        NerghborNegLocsInds = find(abs(Neglocs - cPosLoc) < FrameDiffInds & abs(Neglocs - cPosLoc) > 1);
        if length(NerghborNegLocsInds) > 1 % whether a "W" shaped artifact exists
            if pks(cPosPeak) > RawDiff_waveThres*5/3 && max(Negpks(NerghborNegLocsInds)) < RawDiff_waveThres
                continue;
            end
            if pks(cPosPeak) >= max(Negpks(NerghborNegLocsInds)) * 2
                continue;
            end
                
            NerNegLocs = Neglocs(NerghborNegLocsInds);
            AllPeakLocs = [cPosLoc;NerNegLocs(:)];
            PeakLocsScale = [min(AllPeakLocs), max(AllPeakLocs)];
            if ~isempty(find((locs - cPosLoc) > 0 & (locs - cPosLoc) < FrameDiffInds, 1))
                NearPosPeak = max(locs((locs - cPosLoc) > 0 & (locs - cPosLoc) < FrameDiffInds));
                PeakLocsScale(2) = max(PeakLocsScale(2), NearPosPeak);
            end
            [AdInds, AdValues] = MoveFreeFun(SMTrace, PeakLocsScale, ResidueSTD);
            Neglocs(NerghborNegLocsInds) = [];
            Negpks(NerghborNegLocsInds)  = [];
            MoveFreeTrace(AdInds) = AdValues;
            PeakScaleInds{k,1} = AdInds;
            PeakScaleInds{k,2} = AdValues;
%             NumMoveMents = NumMoveMents + 1;
        else
            if pks(cPosPeak) > RawDiff_waveThres*5/3 && max(Negpks(NerghborNegLocsInds)) < RawDiff_waveThres
                continue;
            end
            if pks(cPosPeak) >= max(Negpks(NerghborNegLocsInds)) * 2
                continue;
            end
            AllPeakLocs = sort([cPosLoc, Neglocs(NerghborNegLocsInds)]);
            if ~isempty(find((locs - cPosLoc) > 0 & (locs - cPosLoc) < FrameDiffInds, 1))
                NearPosPeak = max(locs((locs - cPosLoc) > 0 & (locs - cPosLoc) < FrameDiffInds));
                AllPeakLocs(2) = max(AllPeakLocs(2), NearPosPeak);
            end
            [AdInds, AdValues] = MoveFreeFun(SMTrace, AllPeakLocs, ResidueSTD);
            Neglocs(NerghborNegLocsInds) = [];
            Negpks(NerghborNegLocsInds)  = [];
            MoveFreeTrace(AdInds) = AdValues;
            PeakScaleInds{k,1} = AdInds;
            PeakScaleInds{k,2} = AdValues;
%             NumMoveMents = NumMoveMents + 1;
        end
    end
end

% find the remained negtive peaks 
[RestNegPks, RestNegLocs] = findpeaks(-MoveFreeTrace,'MinPeakProminence', RawDiff_waveThres*4/3,...
    'MaxPeakWidth', 5);
NumRestPeks = length(RestNegPks);
for cRP = 1  :  NumRestPeks
    cRPksLoc = RestNegLocs(cRP);
    cRPlocScale = cRPksLoc + [-2 2];
    [AdInds, AdValues] = MoveFreeFun(SMTrace, cRPlocScale, ResidueSTD);
    MoveFreeTrace(AdInds) = AdValues;
    PeakScaleInds{k,1} = AdInds;
    PeakScaleInds{k,2} = AdValues;
    k = k + 1;
end


function [AdjustInds, AdjustValue] = MoveFreeFun(RawSMTrace, MoveScaleInds, NoiseLevel)
try
    AdjustScaleInds = [MoveScaleInds(1) + [-4, -3], MoveScaleInds(2) + [3, 4]] ;
    ScaleSMValue = RawSMTrace(AdjustScaleInds);
    InterScaleInds = (MoveScaleInds(1) - 3):(MoveScaleInds(2) + 3);

    InterpValues = interp1(AdjustScaleInds, ScaleSMValue, InterScaleInds);
    ExtraNoise = randn(numel(InterScaleInds) ,1) * NoiseLevel;
    InterValue_WithNoise = InterpValues(:) + ExtraNoise;

    AdjustInds = InterScaleInds;
    AdjustValue = InterValue_WithNoise;
catch
    fprintf('Index out of range.\n');
    AdjustInds = [];
    AdjustValue = [];
end
