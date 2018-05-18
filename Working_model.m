
modelfunb = @(g,l,u,v,x) g+(1-g-l)*0.5*(1+erf((x-u)/sqrt(2*v^2)));
g = 0;
l = 0;
u = -0.5;
v = 0.2;

xRange = linspace(-1,1,500);
yRange = modelfunb(g,l,u,v,xRange);

hhf = figure('position',[100 100 380 300]);
plot(xRange,yRange,'k','linewidth',1.6);

%%
% using logistic fitting of current data
OctaveData = [-1,-0.6,-0.2,0.2,0.6,1];
NorTundata = [0.1 0.2 0.4 0.8 0.9 1];
opts = statset('nlinfit');
opts.RobustWgtFun = 'bisquare';
opts.MaxIter = 1000;
modelfunb = @(b1,b2,b3,b4,x) (b1+ b2./(1+exp(-(x - b3)./b4)));
% using the new model function
UL = [max(NorTundata)+abs(min(NorTundata)), Inf, max(OctaveData), 100];
SP = [min(NorTundata),max(NorTundata) - min(NorTundata), mean(OctaveData), 1];
LM = [-Inf,-Inf, min(OctaveData), -100];
ParaBoundLim = ([UL;SP;LM]);
[fit_model,fitgof] = fit(OctaveData',NorTundata',modelfunb,'StartPoint',SP,'Upper',UL,'Lower',LM);
OctaveRange = linspace(min(OctaveData),max(OctaveData),500);
FitCurve = feval(fit_model,OctaveRange);
hhf = figure('position',[100 100 380 300]);
hold on
plot(OctaveRange,FitCurve,'k','linewidth',1.6);
plot(OctaveData',NorTundata','o','MarkerSize',12,'Linewidth',2)

%% Initial categorical ROI response function
modelfunb = @(g,l,u,v,x) g+(1-g-l)*0.5*(1+erf((x-u)/sqrt(2*v^2)));
g = 0;
l = 0;
% u = -0.5;
v = 0.2;

RPreferBound = -0.5:0.1:0.5;
LPreferBound = -0.5:0.1:0.5;
nCategROI = length(RPreferBound);
RPrefCategFun = cell(nCategROI,1);
LPrefCategFun = cell(nCategROI,1);
for cROI = 1 : nCategROI
    RPrefCategFun{cROI} = @(x) modelfunb(g,l,RPreferBound(cROI),v,x);
    LPrefCategFun{cROI} = @(x) 1 - modelfunb(g,l,RPreferBound(cROI),v,x);
end
%% Test categorical ROI function
xRange = linspace(-1,1,500);
hf = figure;
hold on
for cROI = 1 : nCategROI
    cRFun = RPrefCategFun{cROI};
    cLFun = LPrefCategFun{cROI};
    cRCurve = cRFun(xRange);
    cLCurve = cLFun(xRange);
    plot(xRange,cRCurve,'r','linewidth',1.6);
    plot(xRange,cLCurve,'b','linewidth',1.6);
end
% saveas(hf,'Initial raw categNeuron population data');
% saveas(hf,'Initial raw categNeuron population data','pdf');
% %% calculate output value by given function
% xData = -0.5:0.1:0.5;
% RDataCell = cell(nCategROI,1);
% LDataCell = cell(nCategROI,1);
% for cROI = 1 : nCategROI
%     cRFun = RPrefCategFun{cROI};
%     cLFun = LPrefCategFun{cROI};
%     RDataCell{cROI} = cRFun(xData);
%     LDataCell{cROI} = cLFun(xData);
% end
% RDataMtx = cell2mat(RDataCell);
% LDataMtx = cell2mat(LDataCell);
% 
% ChoiceData = (sum(RDataMtx) - sum(LDataMtx))/nCategROI;
% figure;
% plot(xData,ChoiceData,'k','Linewidth',1.6)
% 
% 
% BehavThres = 0.8;
% Value2ThresRatio = abs(ChoiceData)/BehavThres;
% Value2ThresRatio(Value2ThresRatio > 1) = 1;
% BoostFun = 1 - Value2ThresRatio;
% figure;
% plot(xData,BoostFun,'k','Linewidth',1.6)

%% set uncertainty function
modelfunb = @(g,l,u,v,x) g+(1-g-l)*0.5*(1+erf((x-u)/sqrt(2*v^2)));
g = 0;
l = 0;
UCu = 0;
UCv = 0.2;
syms y
cFun = modelfunb(g,l,UCu,UCv,y);
UncertainFunDerivt = diff(cFun);
xRange = linspace(-1,1,500);
UncertainFun = double(subs(UncertainFunDerivt,xRange));

BiasV = 0;

hf = figure;
plot(xRange,UncertainFun,'r','Linewidth',1.6);
set(gca,'box','off');
% saveas(hf,'Initial Uncertainty function');
% saveas(hf,'Initial raw categNeuron population data','pdf');
%% using the uncertainty function for boosting sensory outcome
xData = linspace(-1,1,500);
RDataCell = cell(nCategROI,1);
LDataCell = cell(nCategROI,1);
for cROI = 1 : nCategROI
    cRFun = RPrefCategFun{cROI};
    cLFun = LPrefCategFun{cROI};
    RDataCell{cROI} = cRFun(xData);
    LDataCell{cROI} = cLFun(xData);
end
RDataMtx = cell2mat(RDataCell);
LDataMtx = cell2mat(LDataCell);

ChoiceData = (sum(RDataMtx) - sum(LDataMtx))/nCategROI;
%% fit the choice data with a sigmoidal function
SP = [min(ChoiceData),1-max(ChoiceData) - min(ChoiceData),0,1];
UL = [max(ChoiceData),max(ChoiceData),max(xData),100];
LM = [min(ChoiceData),min(ChoiceData),min(xData),1e-6];
[ffit, gof] =fit(xData(:),ChoiceData(:),modelfunb,'StartPoint',SP,'Upper',UL,'Lower',LM);
syms xValue
cChoiceFun = modelfunb(ffit.g,ffit.l,ffit.u,ffit.v,xValue);
ChoiceFunDerivative = diff(cChoiceFun);
ChoiceSlopeData = double(subs(ChoiceFunDerivative,xData));
hf = figure('position',[100 100 380 300]);
yyaxis left
plot(xData,ChoiceData,'r','linewidth',1.5);
ylabel('Raw');

yyaxis right
plot(xData,ChoiceSlopeData,'k','linewidth',1.6);
ylabel('Slope')

% saveas(hf,'Raw choice data and slope');
% saveas(hf,'Raw choice data and slope','pdf');
%% Combine uncertainty to final function
UncertainFun = double(subs(UncertainFunDerivt,xData));
ShapedSlope = ChoiceSlopeData(:) .* UncertainFun(:); % slope change, sensitivity change, something like gain modulation
NewxData = xData + BiasV; % bias term change
syms Newg Newl Newu Newv Newx
NewFunc = modelfunb(ffit.g,ffit.l,Newu,Newv,Newx);  % upper and lower bound fixed
NewChoiceFunSlope = diff(NewFunc,Newx);
NewChoiceFunSlopehandle = matlabFunction(NewChoiceFunSlope);
NewSP = SP.*[1 1 1 0] + [0 0 BiasV 1/(max(ShapedSlope)*max(UncertainFun))];
% cFitTypes = fittype(NewChoiceFunSlopehandle,'coefficients',{'Newg','Newl','Newu','Newv'},'independent',{'Newx'},'dependent',{'ShapedSlope'});
cFitTypes = fittype(NewChoiceFunSlopehandle,'coefficients',{'Newu','Newv'},'independent',{'Newx'},'dependent',{'ShapedSlope'});
[Newffit, Newgof] = fit(NewxData(:),ShapedSlope(:),cFitTypes,'StartPoint',NewSP(3:4),'Upper',UL(3:4),'Lower',LM(3:4));
NewSlopeData = feval(Newffit,xData);

hf = figure('position',[100 100 380 300]);
hold on
plot(xData,ChoiceSlopeData,'k','linewidth',1.5);
plot(xData,NewSlopeData,'r','linewidth',1.5);
legend({'ChoiceSlope','ModuSlope'},'FontSize',10,'Box','off','Location','Northwest');
title('Slope change')
% saveas(hf,'modulated slope curve');
% saveas(hf,'modulated slope curve','pdf');

NewFunction = modelfunb(ffit.g,ffit.l,Newffit.Newu,Newffit.Newv,Newx);
NewChoiceData = double(subs(NewFunction,xData));
[~,BoundInds] = min(abs(NewChoiceData));
BoundIndex = xData(BoundInds);
hhf = figure('position',[500 100 380 300]);
hold on
plot(xData,ChoiceData,'k','linewidth',1.5);
plot(xData,NewChoiceData,'r','linewidth',1.5);
legend({'ChoiceRaw','ModuChoice'},'FontSize',10,'Box','off','Location','Northwest');
text(BoundIndex,0,sprintf('Bound = %.4f',BoundIndex));
title(sprintf('Choice Data, Gain = %d-%.2f, Bias = %.3f',UCu,UCv,BiasV));
set(gca,'ylim',[-1.1 1.1]);
% saveas(hhf,'Modulated Choice curve with bias');
% saveas(hhf,'Modulated Choice curve with bias','pdf');

%
PriorChoice = -1*0.1;  % negtive for left prior, positive for right prior
WithPriorChoice = NewChoiceData + PriorChoice;
WithPriorChoice(WithPriorChoice > 1) = 1;
WithPriorChoice(WithPriorChoice < -1) = -1;  % set within range
[~,BoundInds] = min(abs(WithPriorChoice));
BoundIndex = xData(BoundInds);
FinalSP = [SP(1:2),BoundInds,1/(max(ShapedSlope)*max(UncertainFun))];
[FinalFit,Finalgof] = fit(xData(:),WithPriorChoice(:),modelfunb,'StartPoint',FinalSP,'Upper',UL,'Lower',LM);
FinalCurve = feval(FinalFit,xData);
hhf = figure('position',[900 100 380 300]);
hold on
plot(xData,ChoiceData,'k','linewidth',1.5);
plot(xData,FinalCurve,'r','linewidth',1.5);
legend({'ChoiceRaw','ModuChoice'},'FontSize',10,'Box','off','Location','SouthEast');
text(-0.8,0.9,sprintf('Gain = %d-%.2f',UCu,UCv));
text(-0.8,0.8,sprintf('Bias = %.3f',BiasV))
text(-0.8,0.7,sprintf('Prior = %.3f',PriorChoice))
text(FinalFit.u,0,sprintf('Bound = %.4f',FinalFit.u));
title('Final formation');
% saveas(hhf,'Modulated Choice curve with bias and prior');
% saveas(hhf,'Modulated Choice curve with bias and prior','pdf');

%%
CombinedData = ChoiceData .* UncertainFun;
hf = figure;
plot(xData,CombinedData,'k','linewidth',1.5)

%% gaussian base neuron generation

c1 = 1;
c2 = 0;
c3 = 0.2;
c4 = 0;
TunBaseModel = @(x) c1*exp((-1)*((x - c2).^2)./(2*(c3^2)))+c4;
xscales = linspace(-1,1,100);
yData = TunBaseModel(xscales);
figure;
plot(xscales,yData);

%%
TunBaseModel = @(c1,c2,c3,c4,x) c1*exp((-1)*((x - c2).^2)./(2*(c3^2)))+c4;
cc1 = 1;
% c2 = 0;
cc3 = 0.2;
cc4 = 0;

TuningPeakNum = 100;
TunPeakData = linspace(-1,1,TuningPeakNum);
TunROIFun = cell(TuningPeakNum,1);
for cROI = 1 : TuningPeakNum
    TunROIFun{cROI} = @(x) TunBaseModel(cc1,TunPeakData(cROI),cc3,cc4,x);
end

xscales = linspace(-1,1,500);
BaseROIRespDataAll = cell(TuningPeakNum,1);
UsedColor = jet(TuningPeakNum);
figure;
hold on
for cROI = 1 : TuningPeakNum
    cROIFun = TunROIFun{cROI};
    cROIData = cROIFun(xscales);
    plot(xscales,cROIData,'Color',UsedColor(cROI,:),'linewidth',1.4);
    BaseROIRespDataAll{cROI} = cROIData * sign(TunPeakData(cROI));
end

% calculate the population output, left as negtive value
popuOutData = sum(cell2mat(BaseROIRespDataAll));
ScalePopuOut = (popuOutData - min(popuOutData))/(max(popuOutData) - min(popuOutData))*2-1;

hf = figure;
% hold on
yyaxis left
plot(xscales,popuOutData,'Color','k','linewidth',1.5);

yyaxis right
plot(xscales,ScalePopuOut,'Color','r','linewidth',1.5);


