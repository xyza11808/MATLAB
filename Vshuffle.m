function varargout = Vshuffle(Ordervector)
% shuffled trial types

ShuffleType=Ordervector;
% #######################################
% stimtype shuffle section
TrialLength=numel(ShuffleType);
ShuffleIndex = 1:TrialLength;
for n=1:TrialLength
    w = ceil(rand*n);
    t = ShuffleType(w);
    ShuffleType(w) = ShuffleType(n);
    ShuffleType(n) = t;
    
    cIndex = ShuffleIndex(w);
    ShuffleIndex(w) = ShuffleIndex(n);
    ShuffleIndex(n) = cIndex;
end
%     CorrTrialStimBU=CorrTrialStim;
if nargout == 1
    varargout{1} = ShuffleType;
elseif nargout == 2
    varargout{1} = ShuffleType;
    varargout{2} = ShuffleIndex(:);
end