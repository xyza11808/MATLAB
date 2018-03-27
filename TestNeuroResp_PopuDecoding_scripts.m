% Gaussian function for each ROIs
clear
clc
GausCategFun = @(c1,c2,c3,x) c1*exp((-1)*((x - c2).^2)./(2*(c3^2)));
c3 = 0.2;
xRange = linspace(-1,1,500);
c2 = [-1,-0.6,-0.2,0.2,0.6,1];
c1 = 10;
NoiseAmp = 2;
nROI = length(c2);
StimTypes = c2;
nStims = length(c2);
cROIfun = cell(nROI,1);
cROICurve = cell(nROI,1);
figure;
hold on
for cROI = 1 : nROI
    cROIfun{cROI} = @(x) GausCategFun(c1,c2(cROI),c3,x);
    cROICurve{cROI} = GausCategFun(c1,c2(cROI),c3,xRange);
    plot(xRange,cROICurve{cROI},'k')
end
%% Categorical ROIs
clear
clc
SigmoidalFun = @(g,l,u,v,x) g+(1-g-l)*0.5*(1+erf((x-u)/sqrt(2*v^2)));
NoiseAmp = 2;
SigAmp = 10;
uAll = linspace(-0.2,0.2,6);
g = 0.1;
l = 0.1;
v = 0.2;
xRange = linspace(-1,1,500);
StimTypes = [-1,-0.6,-0.2,0.2,0.6,1];
nStims = length(StimTypes);

nROI = length(uAll)*2;
cROIfun = cell(nROI,1);
cROICurve = cell(nROI,1);
xShift = 0.3;
figure;
hold on
for cROI = 1 : (nROI/2)
    cROIfun{cROI} = @(x) SigAmp * SigmoidalFun(g,l,uAll(cROI),v,x+xShift);
    cROICurve{cROI} = SigAmp * SigmoidalFun(g,l,uAll(cROI),v,xRange+xShift);
    plot(xRange,cROICurve{cROI},'b');
    cROIfun{cROI+nROI/2} = @(x) SigAmp * (1-SigmoidalFun(g,l,uAll(cROI),v,x+xShift));
    cROICurve{cROI+nROI/2} = SigAmp * (1 - SigmoidalFun(g,l,uAll(cROI),v,xRange+xShift));
    plot(xRange,cROICurve{cROI+nROI/2},'r');
end

%%
StimTrials = 300;
StimROIData = zeros(StimTrials,nROI);
TrStims = zeros(StimTrials,1);
for cTr = 1 : StimTrials
    cTrStim = StimTypes(randsample(nStims,1));
    TrStims(cTr) = cTrStim;
    
    cTrData = zeros(nROI,1);
    for cROI = 1 : nROI
        cTrData(cROI) = cROIfun{cROI}(cTrStim) + NoiseAmp/5*randn(1);
    end
    StimROIData(cTr,:) = cTrData;
end

%
RealLoss = zeros(StimTrials,1);
TrTypes = TrStims > 0;
TrainMdl = fitcsvm(StimROIData,TrTypes);
c = crossval(TrainMdl,'leaveOut','on');
CVTrInds = zeros(StimTrials,1);
for cTrs = 1 : StimTrials
    CVTrInds(cTrs) = find(c.Partition.test(cTrs));
end
L = kfoldLoss(c,'mode','individual');
RealLoss(CVTrInds) = L;
%

StimRProb = zeros(nStims,1);
StimAvgData = zeros(nStims,nROI);
for cStimInds = 1 : nStims
    cStim = StimTypes(cStimInds);
    cStimTrs = TrStims == cStim;
    cStimRProb = mean(RealLoss(cStimTrs));
    if cStim <= 0
        StimRProb(cStimInds) = cStimRProb;
    else
        StimRProb(cStimInds) = 1 - cStimRProb;
    end
    
    cStimDataAvg = mean(StimROIData(cStimTrs,:));
    StimAvgData(cStimInds,:) = cStimDataAvg;
end
[~,Scores] = predict(TrainMdl,StimAvgData);
NormScores = (Scores(:,2) - min(Scores(:,2)))/(max(Scores(:,2)) - min(Scores(:,2)));
hf = figure;
hold on
plot(StimTypes,NormScores,'k-o')
Fittt = FitPsycheCurveWH_nx(StimTypes,NormScores);
plot(Fittt.curve(:,1),Fittt.curve(:,2),'r');
Fittt.ffit.u
%%

CategMdFun = @(g,l,u,v,x) g+(1-g-l)*0.5*(1+erf((x-u)/sqrt(2*v^2)));
