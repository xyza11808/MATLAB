function Shufflex=RandShuffle(x)

TrialLength=numel(x);
Shufflex=x;
for n=1:TrialLength
    w = ceil(rand*n);
    t = Shufflex(w);
    Shufflex(w) = Shufflex(n);
    Shufflex(n) = t;
end
