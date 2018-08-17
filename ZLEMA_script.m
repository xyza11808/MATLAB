% The smaller the alpha parameter is, the more efficiently noise is going to be filtered out - 
% but the less responsive the EMA is going to be when a genuine move appears in the data.
RawData = ROIRealTrace;
alpha = 0.1;
nPoints = length(ROI1RealTrace);
cSmoothData = zeros(nPoints,1);
BackSmooth = zeros(nPoints,1);
cSmoothData(1) = RawData(1);

for cPoint = 2 : nPoints
    cSmoothData(cPoint) = (1 - alpha) * cSmoothData(cPoint - 1) + alpha * RawData(cPoint);
end
BackSmooth(end) = cSmoothData(end);
for cPoint = (nPoints - 1) : -1 : 1
    BackSmooth(cPoint) = (1 - alpha) * BackSmooth(cPoint + 1) + alpha * cSmoothData(cPoint);
end

% zeros lag smooth
% period = 2/alpha - 1
nLag = round(1/alpha - 1); % (period - 1)/2
cZeroLagSM = zeros(nPoints,1);
cZeroLagSM(1) = RawData(1);
for cPoint = (1 + nLag) : nPoints
    cZeroLagSM(cPoint) = (1 - alpha) * cZeroLagSM(cPoint - 1) + alpha * (2 * RawData(cPoint) - RawData(cPoint - nLag));
end

%%
figure;
hold on
plot(RawData,'k');
plot(cSmoothData,'r');
plot(cZeroLagSM,'c')

%%
ROITrace = reshape((squeeze(data_aligned(:,3,:)))',[],1);
NanTraceInds = isnan(ROITrace);
ROIRealTrace = ROITrace(~NanTraceInds);

