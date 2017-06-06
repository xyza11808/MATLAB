function SingleNeuROCSfun(AlignData,BehavStrc,Frate,AlignF,TrOutcome,varargin)
% this function is used for calculating single cell neuromeric function,
% using AUC values compared with null condition
TrFreq = double(BehavStrc.Stim_toneFreq);
FreqTypes = unique(TrFreq);
if length(FreqTypes) < 6
    error('Error frequency types, should be large than 6, but only %d types exists.',length(FreqTypes));
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
    case 1
        TrIndsUsed = TrOutcome == 1;
    case 2
        TrIndsUsed = true(length(TrOutcome),1);
    otherwise
        warning('Unrecognized trial type usage input, using default value for calculation');
        TrIndsUsed = TrOutcome ~= 2;
end
TrDataUsed = AlignData(TrIndsUsed,:,:);
TrFreqUsed = TrFreq(TrIndsUsed);

