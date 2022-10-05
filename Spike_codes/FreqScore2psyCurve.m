function OutDataStrc = FreqScore2psyCurve(AllSessScores, Octaves)
% input the freqwise score for different sessions and then calculate the
% response overall psychometric curve
NumSessions = size(AllSessScores,3);
LowBoundScores = squeeze(AllSessScores(:,1,:));
HighBoundScores = squeeze(AllSessScores(:,2,:));

OctsMatch2Scores = repmat(Octaves(:),1,NumSessions);

[LowFitCurve, LowfitMD, LowfitSlope, LowfitGOF] = fitFun(LowBoundScores, OctsMatch2Scores);
[HighFitCurve, HighfitMD, HighfitSlope, HighfitGOF] = fitFun(HighBoundScores, OctsMatch2Scores);

OutDataStrc = struct();
OutDataStrc.LowFitMD = LowfitMD;
OutDataStrc.LowFitCurve = LowFitCurve;
OutDataStrc.LowGof = LowfitGOF;
OutDataStrc.SlopeAll = [LowfitSlope, HighfitSlope];
OutDataStrc.BoundAll = [LowfitMD.b3,HighfitMD.b3];
OutDataStrc.HighFitMD = HighfitMD;
OutDataStrc.HighFitCurve = HighFitCurve;
OutDataStrc.HighGof = HighfitGOF;



function [FitCurve, fit_model, FitSlope, fitgof] = fitFun(AllScores, AllOctaves)
NorTundata = AllScores(:);%/mean(cROITunData);
OctaveData = AllOctaves(:);

% using logistic fitting of current data
opts = statset('nlinfit');
opts.RobustWgtFun = 'bisquare';
opts.MaxIter = 1000;
modelfunb = @(b1,b2,b3,b4,x) (b1+ b2./(1+exp(-(x - b3)./b4)));
% using the new model function
UL = [max(NorTundata)+abs(min(NorTundata)), Inf, max(OctaveData), 100];
SP = [min(NorTundata),max(NorTundata) - min(NorTundata), mean(OctaveData), 1];
LM = [-Inf,-Inf, min(OctaveData), -100];

[fit_model,fitgof] = fit(OctaveData,NorTundata,modelfunb,'StartPoint',SP,'Upper',UL,'Lower',LM);
OctaveRange = linspace(min(OctaveData),max(OctaveData),500);
FitValue = feval(fit_model,OctaveRange);
FitSlope = fit_model.b2/(4*fit_model.b4);

FitCurve = [OctaveRange(:),FitValue(:)];



