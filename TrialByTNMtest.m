function TrialByTNMtest(RawDataAll,BehavStrc,TrialResult,AlignFrame,FrameRate,varargin)
%this function will calculate pca points trial by trial and then group them
%according to its corresponded trial type, with this group of points we
%will then using a SVM mechine to classified the two trial types and see
%its outcomes


if ~isempty(varargin{1})
    TimeLength=varargin{1};
else
    TimeLength=1.5;
end
if nargin>6
    if ~isempty(varargin{2})
        isShuffle=varargin{2};
    else
        isShuffle=0;
    end
else
    isShuffle=0;
end
StimAll = double(BehavStrc.Stim_toneFreq(:));
TrTypeAll = double(BehavStrc.Trial_Type(:));
%%
%some preprocesing and prelocation
DataSize=size(RawDataAll);
CorrectInds = TrialResult==1;
% CorrectInds=true(1,length(TrialResult));
CorrTrialStim=StimAll(CorrectInds);
CorrTrialData=RawDataAll(CorrectInds,:,:);
CorrStimType=unique(CorrTrialStim);
NMTrInds = TrialResult ~= 2;
NMOutcomes = TrialResult(NMTrInds);
NMTrialStims = StimAll(NMTrInds);
NMTrTypes = TrTypeAll(NMTrInds);
% TrialPCAscore=zeros(length(CorrTrialStim),3);
ALLROIMeanTrial=zeros(length(CorrStimType),DataSize(2));
if length(TimeLength) == 1
    FrameScale = sort([AlignFrame,AlignFrame+floor(TimeLength*FrameRate)]);
elseif length(TimeLength) == 2
    FrameScale = sort([AlignFrame+floor(TimeLength(1)*FrameRate),AlignFrame+floor(TimeLength(2)*FrameRate)]);
else
    warning('Input TimeLength variable have a length of %d, but it have to be 1 or 2',length(TimeLength));
    return;
end
if FrameScale(1) < 1
    warning('Time Selection excceed matrix index, correct to 1');
end
if FrameScale(2) > DataSize(3)
    warning('Time Selection excceed matrix index, correct to %d',DataSize(3));
end

ConsideringData = CorrTrialData(:,:,FrameScale(1):FrameScale(2));
NMTrUsedData = RawDataAll(NMTrInds,:,FrameScale(1):FrameScale(2));
%%  
if isShuffle
    %shuffled trial types
    ShuffleType=CorrTrialStim;
    %#######################################
    %stimtype shuffle section
    TrialLength=numel(ShuffleType);
    for n=1:TrialLength
        w = ceil(rand*n);
        t = ShuffleType(w);
        ShuffleType(w) = ShuffleType(n);
        ShuffleType(n) = t;
    end
    CorrTrialStimBU=CorrTrialStim;
    CorrTrialStim=ShuffleType;
end

%%
if ~isdir('./NeuroM_test_TBT/')
    mkdir('./NeuroM_test_TBT/');
end
cd('./NeuroM_test_TBT/');

if ~isdir(sprintf('./AfterTimeLength-%dms/',TimeLength*1000))
    mkdir(sprintf('./AfterTimeLength-%dms/',TimeLength*1000));
end
cd(sprintf('./AfterTimeLength-%dms/',TimeLength*1000));

%%
ROImaxInds = zeros(length(CorrStimType),DataSize(2));
for n = 1 : length(CorrStimType)
    CStimType = CorrStimType(n);
    CStimInds = CorrTrialStim == CStimType;
    SingleStimData = ConsideringData(CStimInds,:,:);
    TrialMeanData=squeeze(mean(SingleStimData));
    [ROIMeanData,cROImaxInds]=max(TrialMeanData,[],2);
    ROImaxInds(n,:) = cROImaxInds;
    ALLROIMeanTrial(n,:)=ROIMeanData';
end
[coeff,scoreT,~,~,explainedT,~]=pca(ALLROIMeanTrial);
fprintf('First three component explained %.3f of total variation.\n',sum(explainedT(1:3)));

%%
[filename,filepath,~]=uigetfile('boundary_result.mat','Select your random plot fit result');
load(fullfile(filepath,filename));
Octavex=log2(double(CorrStimType)/min(double(CorrStimType)));
% Octavefit=Octavex;
Octavexfit=Octavex;
% OctaveTest=Octavex;
realy=boundary_result.StimCorr;
GrStimNum = floor(numel(realy)/2);
realy(1:GrStimNum)=1-realy(1:GrStimNum);
Curve_x=linspace(min(Octavex),max(Octavex),500);
modelfun = @(p1,t)(p1(2)./(1 + exp(-p1(3).*(t-p1(1)))));
rescaleB=max(realy);
rescaleA=min(realy);

%%
% h3df = figure;
LeftStims=CorrStimType(1:GrStimNum);
RightStims=CorrStimType((GrStimNum+1):end);
LeftStimsStr=cellstr(num2str(LeftStims(:)));
RightStimsStr=cellstr(num2str(RightStims(:)));
nROIs = DataSize(2);
TrialProj = zeros(size(NMTrUsedData,1),size(coeff,2));
ProjCoef = coeff';
for nTrial = 1 : size(NMTrUsedData,1)
    CTrialData = squeeze(NMTrUsedData(nTrial,:,:));
    CDataVector = zeros(nROIs,1);
    for nROI = 1 : nROIs
        CDataVector(nROI) = CTrialData(nROI,cROImaxInds(nROI));
    end
    TrialProj (nTrial,:) = (ProjCoef * (CDataVector - mean(CDataVector)))';
end
NMTrialLabel = NMTrTypes;
LeftPointInds = ~NMTrialLabel & NMOutcomes(:) == 1;
RightPointInds = NMTrialLabel & NMOutcomes(:) == 1;
h=figure;
hold on;
plot3(TrialProj(LeftPointInds,1),TrialProj(LeftPointInds,2),TrialProj(LeftPointInds,3),'bo','MarkerSize',10);
plot3(TrialProj(RightPointInds,1),TrialProj(RightPointInds,2),TrialProj(RightPointInds,3),'r*','MarkerSize',10);
plot3(scoreT(1:GrStimNum,1),scoreT(1:GrStimNum,2),scoreT(1:GrStimNum,3),'gp','MarkerSize',12);
plot3(scoreT(GrStimNum+1:end,1),scoreT(GrStimNum+1:end,2),scoreT(GrStimNum+1:end,3),'kp','MarkerSize',12)
text(scoreT(1:GrStimNum,1),scoreT(1:GrStimNum,2),scoreT(1:GrStimNum,3),LeftStimsStr);
text(scoreT(GrStimNum+1:end,1),scoreT(GrStimNum+1:end,2),scoreT(GrStimNum+1:end,3),RightStimsStr);

ErrorT = NMOutcomes(:) == 0;
plot3(TrialProj(ErrorT,1),TrialProj(ErrorT,2),TrialProj(ErrorT,3),'md','MarkerSize',12);
legend('Left\_score','Right\_score','LSum\_score','RSum\_score','ErrorTrials','location','northeastoutside');
legend('boxoff')
% ErrorScore = TrialProj(ErrorT,:);
% ErrorTrialLabel = CorrTrialLabel(ErrorT);

%%
CorrTrProj = TrialProj(NMOutcomes(:) == 1,:);
TrainTrLabels = NMTrialLabel(NMOutcomes(:) == 1);
CSvmModel = fitcsvm(CorrTrProj,TrainTrLabels(:));
CVSVMModel = crossval(CSvmModel);  %performing cross-validation
ErrorRate=kfoldLoss(CVSVMModel);  %disp kfold loss of validation
fprintf('Error Rate = %.4f.\n',ErrorRate);
[~,classscoresT]=predict(CSvmModel,scoreT(:,1:3));
difscore=classscoresT(:,2)-classscoresT(:,1);
fityAll=(rescaleB-rescaleA)*((difscore-min(difscore))./(max(difscore)-min(difscore)))+rescaleA;  %rescale to [0 1]
% ErrorTPredict = predict(CSvmModel,ErrorScore);

xlabel('pc1');ylabel('pc2');zlabel('pc3');
title(sprintf('10 fold CV error rate = %.3f',ErrorRate));
saveas(h,'T8T_pca_points.png');
saveas(h,'T8T_pca_points.fig');
close(h);

save T8TResult.mat TrialProj realy Octavex CSvmModel ErrorRate fityAll -v7.3
save pcaResultSave.mat scoreT -v7.3
options = statset('UseParallel',true);
[bootStat,bootSample]=bootstrp(1000,@(Data,TrialType)ScoreBootFun(Data,TrialType,CSvmModel,realy),...
    ConsideringData,CorrTrialStim(:),'Options',options);

h3=figure;
hold on;
scatter(Octavex,realy,30,'p','MarkerEdgeColor','k','MarkerFaceColor','y');
[~,breal]=fit_logistic(Octavex,(realy(:))');

scatter(Octavexfit,fityAll,30,'o','MarkerEdgeColor','r','MarkerFaceColor','y');
[~,bfit]=fit_logistic(Octavexfit,fityAll');
curve_realy=modelfun(breal,Curve_x);
curve_fity=modelfun(bfit,Curve_x);
syms x
Realboundary=solve(modelfun(breal,x)==0.5,x);
Fitboundary=solve(modelfun(bfit,x)==0.5,x);
plot(Curve_x,curve_realy,'k','LineWidth',2);
plot(Curve_x,curve_fity,'r','LineWidth',2);
text(0.1,0.9,sprintf('B=%.3f',double(Realboundary)),'Color','k','FontSize',14);
text(0.1,0.8,sprintf('B=%.3f',double(Fitboundary)),'Color','r','FontSize',14);
legend('Real\_data','Fit\_data','logi\_realc','logi\_fitc','location','northeastoutside');
title('Real and fit data comparation');
xlabel('Octave');
ylabel('Rightward Choice');
ylim([0 1]);
saveas(h3,sprintf('Neuro_psycho_%dms_T8T_plot.png',TimeLength*1000));
saveas(h3,sprintf('Neuro_psycho_%dms_T8T_plot.fig',TimeLength*1000));
close(h3);

save CurveFitResult.mat Octavex realy fityAll breal bfit modelfun -v7.3
cd ..;
cd ..;


function fityAll = ScoreBootFun(Data,TrialType,SVMMODEL,realyData)
%just used for bootstraping to calculate the SEM
CorrStimType = unique(TrialType);
ALLROIMeanTrial=zeros(length(CorrStimType),size(Data,2));
for n = 1 : length(CorrStimType)
    CStimType = CorrStimType(n);
    CStimInds = TrialType == CStimType;
    SingleStimData = Data(CStimInds,:,:);
    TrialMeanData=squeeze(mean(SingleStimData));
    [ROIMeanData,~]=max(TrialMeanData,[],2);
%         ROImaxInds(n,:) = cROImaxInds;
    ALLROIMeanTrial(n,:)=ROIMeanData';
end
[~,scoreT,~,~,~,~]=pca(ALLROIMeanTrial);
rescaleB=max(realyData);
rescaleA=min(realyData);
[~,classscoresT]=predict(SVMMODEL,scoreT(:,1:3));
difscore=classscoresT(:,2)-classscoresT(:,1);
fityAll=(rescaleB-rescaleA)*((difscore-min(difscore))./(max(difscore)-min(difscore)))+rescaleA;  %rescale to [0 1]
