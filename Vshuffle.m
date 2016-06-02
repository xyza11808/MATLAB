function Svector=Vshuffle(Ordervector)
%shuffled trial types

    ShuffleType=Ordervector;
    %#######################################
    %stimtype shuffle section
    TrialLength=numel(ShuffleType);
    for n=1:TrialLength
        w = ceil(rand*n);
        t = ShuffleType(w);
        ShuffleType(w) = ShuffleType(n);
        ShuffleType(n) = t;
    end
%     CorrTrialStimBU=CorrTrialStim;
    Svector=ShuffleType;