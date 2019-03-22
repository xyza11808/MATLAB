function NormDws = gradientClip(dws,Thres)
% clip the gradient if necessary
GradVec = dws(:);
GradLen = sqrt(sum(GradVec.^2));
if GradLen > Thres
    NormDws = Thres*dws/GradLen;
else
    NormDws = dws;
end

