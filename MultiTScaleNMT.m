function MultiTScaleNMT(DataAll,StimFreq,TrialResult,AlignF,FRate,varargin)
% this function will be used for batch plot of different time scale data
% neurometric curve plot

if ~isempty(varargin{1})
    TimeLength=varargin{1}; % in cell form, so that independent component can have variable length
else
    TimeLength=1.5;
end

isModelLoad = 0;
if nargin > 6
    if ~isempty(varargin{2})
        isModelLoad = varargin{2};
    end
end
ModelLoadStruc = [];
if isModelLoad
    [fn,fp,~]=uigetfile('FinalClassificationScore.mat','Please select your former model data');
    ExData = load(fullfile(fp,fn));
    ExCoef = ExData.coeffT;
    Exmodel = ExData.CVsvmmodel;
    ModelLoadStruc.ExtraCoef = ExCoef;
    ModelLoadStruc.ExtraModel = Exmodel;
    ModelLoadStruc.IsModelLoad = 1;
    ModelLoadStruc.NormalScale = ExData.NorScaleValue;
end
if length(TimeLength) < 2
    warning('Input time length is less than 2 components, please using function ## RandNeuroMTestCrossV ## instead.');
    return;
else
    BatchNum = length(TimeLength);
end
CorrStimType = unique(double(StimFreq));
FreqNum = length(CorrStimType);
FitResult = zeros(BatchNum,FreqNum);

%%
% labelType=[zeros(1,length(CorrStimType)/2) ones(1,length(CorrStimType)/2)]';
% svmmodel=fitcsvm(score(:,1:3),labelType);
% [~,classscores]=predict(svmmodel,score(:,1:3));
% difscore=classscores(:,2)-classscores(:,1);
% fity=((difscore-min(difscore))./(max(difscore)-min(difscore)));  %rescale to [0 1]
[filename,filepath,~]=uigetfile('boundary_result.mat','Select your random plot fit result');
xxxx=load(fullfile(filepath,filename));
Octavex=log2(double(CorrStimType)/min(double(CorrStimType)));
realy=xxxx.boundary_result.StimCorr;
realy(1:3)=1-realy(1:3);

modelfun = @(p1,t)(p1(2)./(1 + exp(-p1(3).*(t-p1(1)))));
Curve_x=linspace(min(Octavex),max(Octavex),500);

%%
if ~isModelLoad
    if ~isdir('./Batch_NMT_Save/')
        mkdir('./Batch_NMT_Save/');
    end
    cd('./Batch_NMT_Save/');
    
else
    if ~isdir('./Batch_NMT_Save_ModelLoad/')
        mkdir('./Batch_NMT_Save_ModelLoad/');
    end
    cd('./Batch_NMT_Save_ModelLoad/');
end
bFitAll = cell(BatchNum,1);
DespStr = cell(BatchNum,1);
for nTimeScle = 1 : BatchNum
    cTime = TimeLength{nTimeScle};
    [fityAll,bfit]=RandNeuroBatch(DataAll,StimFreq,TrialResult,AlignF,FRate,Octavex,xxxx.boundary_result,cTime,ModelLoadStruc);
    bFitAll{nTimeScle} = bfit;
    FitResult(nTimeScle,:) = fityAll;
    if length(cTime) > 1
        DespStr{nTimeScle} = strjoin(strsplit(num2str(cTime),' '),' - ');
    else
        DespStr{nTimeScle} = num2str(cTime);
    end
end
%%
SelectMap = cool;
SelectInds = round(linspace(1,size(SelectMap,1),BatchNum));
LegendLabel = zeros(BatchNum,1);
h_sum=figure('position',[320 220 1350 880]);
hold on;
for nTimeScle = 1 : BatchNum
    scatter(Octavex,FitResult(nTimeScle,:),150,SelectMap(SelectInds(nTimeScle),:),'filled');
    Curve_y = modelfun(bFitAll{nTimeScle},Curve_x);
    h=plot(Curve_x,Curve_y,'color',SelectMap(SelectInds(nTimeScle),:),'Linewidth',2.5);
    LegendLabel(nTimeScle) = h;
end
scatter(Octavex,realy,200,'k','filled')
legend(LegendLabel,DespStr,'location','northwest');
legend boxoff
xlabel('Octave');
ylabel('Rightward Choice');
set(gca,'FontSize',20);
saveas(h_sum,'Multi-timescale neurometric curve plot');
saveas(h_sum,'Multi-timescale neurometric curve plot','png');
%%
cd ..;