function ShufCorrs = crosscoefthresFun(RealData, Maxlag,varargin)
% used for generate the threshold value for given input data that used to
% calculate the time-laggedcross correlation
% the real data should be a two rows trace 
ShufSteps = size(RealData,2)/2; % use half length as shufshift range
if nargin > 2
    if ~isempty(varargin{1})
        ShufSteps = varargin{1};
    end
end
Trace1 = RealData(1,:);
Trace2 = RealData(2,:);

% [rReal,~] = xcorr(Trace1,Trace2,Maxlag,'Coeff');
% [~, maxinds] = max(rReal);
% MaxCorrlags = lagReal(maxinds);

TraceTimepoints = length(Trace1);
Shufrepeats = 200;
ShufCorrs = zeros(Shufrepeats, Maxlag*2+1);
parfor cshuf = 1 : Shufrepeats

    Corr_Neu_SP = Trace1(:);

    RandShiftRange = ShufSteps;
    RandValue = round((rand(1,TraceTimepoints) - 0.5)*2*RandShiftRange);
    Shuf_peak_Inds = (1:TraceTimepoints)' + RandValue(:);
    Shuf_peak_Inds(Shuf_peak_Inds < 1) = Shuf_peak_Inds(Shuf_peak_Inds < 1) + TraceTimepoints;
    Shuf_peak_Inds(Shuf_peak_Inds > TraceTimepoints) = ...
        Shuf_peak_Inds(Shuf_peak_Inds > TraceTimepoints) - TraceTimepoints;
    ShufDatapoints = Corr_Neu_SP(Shuf_peak_Inds);
    
    [rshuf, ~] = xcorr(ShufDatapoints,Trace2,Maxlag,'Coeff');
    ShufCorrs(cshuf,:) = rshuf;
end





