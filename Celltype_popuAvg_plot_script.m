% summed data saved at: E:\DataToGo\data_for_xu\SingleCell_RespType_summary
nSession = length(SessDataStrcAll);
CategRespTaskAll = [];
CategRespPassAll = [];
TunRespTaskAll = [];
TunRespPassAll = [];
TaskOctavesAll = [];
PassOctaveAll = [];
Task2BoundOctAll = [];
Pass2BoundOctAll = [];
TaskNearBoundOctAll = [];
PassNearBoundOctAll = [];
TaskNearBoundDataA = [];
PassNearBoundDataA = [];
BoundTunDataOctAll = [];
BoundTunDataPassOctAll = [];
CBoundTunDataOctAll = [];
CBoundTunDataPassOctAll = [];
for cSess = 1 : nSession
    cSessStrc = SessDataStrcAll{cSess};
    NorCategTaskResp = cSessStrc.CategROITaskData./repmat(max(cSessStrc.CategROITaskData),size(cSessStrc.CategROITaskData,1),1);
    NorCategPassResp = cSessStrc.CategROIPassData./repmat(max(cSessStrc.CategROIPassData),size(cSessStrc.CategROIPassData,1),1);
    NorTunTaskResp = cSessStrc.TunROITaskdata./repmat(max(cSessStrc.TunROITaskdata),size(cSessStrc.TunROITaskdata,1),1);
    NorTunPassResp = cSessStrc.TunROIPassdata./repmat(max(cSessStrc.TunROIPassdata),size(cSessStrc.TunROIPassdata,1),1);
    PassMaxV = max(cSessStrc.TunROIPassdata);
    NegMaxInds = PassMaxV < 0;
    NegNorData = cSessStrc.TunROIPassdata(:,NegMaxInds) ./repmat(max(abs(cSessStrc.TunROIPassdata(:,NegMaxInds))),size(cSessStrc.TunROIPassdata,1),1);
    NorTunPassResp(:,NegMaxInds) = NegNorData;
    if max(NorTunPassResp(:)> 2)
        error('Error max value');
    end
    NorTunPassResp(NorTunPassResp < -1) = 0;
    CategRespTaskAll = [CategRespTaskAll;NorCategTaskResp(:)];
    CategRespPassAll = [CategRespPassAll;NorCategPassResp(:)];
    TunRespTaskAll = [TunRespTaskAll;NorTunTaskResp(:)];
    TunRespPassAll = [TunRespPassAll;NorTunPassResp(:)];
    TaskOctavesAll = [TaskOctavesAll;repmat(cSessStrc.TaskOct(:),size(NorCategTaskResp,2),1)];
    PassOctaveAll = [PassOctaveAll;repmat(cSessStrc.PassOct(:),size(NorCategPassResp,2),1)];
    Task2BoundOctAll = [Task2BoundOctAll;repmat(cSessStrc.TaskOct(:) - cSessStrc.BehavBound,size(NorTunTaskResp,2),1)];
    if size(NorTunTaskResp,1) ~= length(cSessStrc.TaskOct(:))
        error('Dimension mislike');
    end
    Pass2BoundOctAll = [Pass2BoundOctAll;repmat(cSessStrc.PassOct(:) - cSessStrc.BehavBound,size(NorTunPassResp,2),1)];
    
    [~,TaskPeakInds] = max(NorTunTaskResp);
    TaskOct2BoundDiff = cSessStrc.TaskOct(:) - cSessStrc.BehavBound;
    TunedOcts = zeros(length(TaskPeakInds),1);
    for cROI = 1 : length(TaskPeakInds)
        TunedOcts(cROI) = TaskOct2BoundDiff(TaskPeakInds(cROI));
    end
    NearBoundOctInds = abs(TunedOcts) < 0.21;
    NearBoundTunTaskData = NorTunTaskResp(:,NearBoundOctInds);
    TaskNearBoundOctAll = [TaskNearBoundOctAll;repmat(TaskOct2BoundDiff,size(NearBoundTunTaskData,2),1)];
    TaskNearBoundDataA = [TaskNearBoundDataA;NearBoundTunTaskData(:)];
    
    NearBoundTunPassData = NorTunPassResp(:,NearBoundOctInds);
    PassNearBoundOctAll = [PassNearBoundOctAll;repmat(cSessStrc.PassOct(:) - cSessStrc.BehavBound,size(NearBoundTunPassData,2),1)];
    PassNearBoundDataA = [PassNearBoundDataA;NearBoundTunPassData(:)];
    
    % plot the boundary tuning ROI response and averaged together
    BoundTunTaskData = NorTunTaskResp(:,BoundTunROIindex{cSess,2});
    BoundTunPassData = NorTunPassResp(:,BoundTunROIindex{cSess,2});
%     BoundTunTaskOct = repmat(cSessStrc.TaskOct(:),1,size(BoundTunTaskData,2));
%     BoundTunPassOct = repmat(cSessStrc.PassOct(:),1,size(BoundTunPassData,2));
    BoundTunTaskOct = repmat(TaskOct2BoundDiff,1,size(BoundTunTaskData,2));
    BoundTunPassOct = repmat(cSessStrc.PassOct(:) - cSessStrc.BehavBound,1,size(BoundTunPassData,2));
    BoundTunDataOctAll = [BoundTunDataOctAll;[BoundTunTaskData(:),BoundTunTaskOct(:)]];
    BoundTunDataPassOctAll = [BoundTunDataPassOctAll;[BoundTunPassData(:),BoundTunPassOct(:)]];
    
    cBoundTunTaskData = NorTunTaskResp(:,BoundTunROIindex{cSess,4});
    cBoundTunPassData = NorTunPassResp(:,BoundTunROIindex{cSess,4});
    cBoundTunTaskOct = repmat(cSessStrc.TaskOct(:) - cSessStrc.BehavBound,1,size(cBoundTunTaskData,2));
    cBoundTunPassOct = repmat(cSessStrc.PassOct(:) - cSessStrc.BehavBound,1,size(cBoundTunPassData,2));
    CBoundTunDataOctAll = [CBoundTunDataOctAll;[cBoundTunTaskData(:),cBoundTunTaskOct(:)]];
    CBoundTunDataPassOctAll = [CBoundTunDataPassOctAll;[cBoundTunPassData(:),cBoundTunPassOct(:)]];
    
end

%%
OctaveDisTypes = unique(PassNearBoundOctAll);
OctDisValue = zeros(length(OctaveDisTypes),1);
for cType = 1 : length(OctaveDisTypes)
    OctDisValue(cType) = mean(PassNearBoundDataA(PassNearBoundOctAll == OctaveDisTypes(cType)));
end
%% fitting the tuning data with a gaussian function
% fitting the tuning with a guassian function
modelfunc = @(c1,c2,c3,c4,x) c1*exp((-1)*((x - c2).^2)./(2*(c3^2)))+c4;
[AmpV,AmpInds] = max(TunRespTaskAll);
c0 = [AmpV,0,0.2,min(TunRespTaskAll)];  % 0.4 is the octave step
cUpper = [AmpV*10,max(Task2BoundOctAll),max(Task2BoundOctAll) - min(Task2BoundOctAll),AmpV*10];
cLower = [0,min(Task2BoundOctAll),0.2,-Inf];
[ffit,gof] = fit(Task2BoundOctAll(:),TunRespTaskAll(:),modelfunc,...
'StartPoint',c0,'Upper',cUpper,'Lower',cLower,'Robust','LAR','MaxIter',1000);  % 'Method','NonlinearLeastSquares',
Octs = linspace(min(Task2BoundOctAll),max(Task2BoundOctAll),500);
fitData = feval(ffit,Octs);
figure;
plot(Octs,fitData,'r','linewidth',1.8);
% Passive fit
modelfunc = @(c1,c2,c3,c4,x) c1*exp((-1)*((x - c2).^2)./(2*(c3^2)))+c4;
[AmpV,AmpInds] = max(TunRespPassAll);
c0 = [AmpV,0,0.2,min(TunRespPassAll)];  % 0.4 is the octave step
cUpper = [AmpV*10,max(Pass2BoundOctAll),max(Pass2BoundOctAll) - min(Pass2BoundOctAll),AmpV*10];
cLower = [-1*AmpV*10,min(Pass2BoundOctAll),0.1,-Inf];
[ffitPass,gofPass] = fit(Pass2BoundOctAll(:),TunRespPassAll(:),modelfunc,...
'StartPoint',c0,'Upper',cUpper,'Lower',cLower,'Robust','LAR','MaxIter',1000);  % 'Method','NonlinearLeastSquares',
Octs = linspace(min(Pass2BoundOctAll),max(Pass2BoundOctAll),500);
fitData = feval(ffitPass,Octs);
hold on
plot(Octs,fitData,'k','linewidth',1.8)

% figure;
% hold on
% plot(Pass2BoundOctAll,TunRespPassAll,'ko')
% plot(Task2BoundOctAll,TunRespTaskAll,'ro')

%%
SpaceStep = -2:0.2:2;
BinCenters = SpaceStep+(0.2/2);
BinedValueAvg = zeros(length(SpaceStep),2);
BinedValueAll = cell(length(SpaceStep),1);
PassBinedValueAvg = zeros(length(SpaceStep),2);
PassBinValueAll = cell(length(SpaceStep),1);
for cStep = 1 : length(SpaceStep)-1
    WithinStepInds = find(Task2BoundOctAll > SpaceStep(cStep) & Task2BoundOctAll < SpaceStep(cStep+1));
    PassStepInds = find(Pass2BoundOctAll > SpaceStep(cStep) & Pass2BoundOctAll < SpaceStep(cStep+1));
    if ~isempty(WithinStepInds)
        cBinData = TunRespTaskAll(WithinStepInds);
        BinedValueAll{cStep} = cBinData;
        BinedValueAvg(cStep,:) = [mean(cBinData),std(cBinData)/sqrt(numel(cBinData))];
    end
    if ~isempty(PassStepInds)
        cBinPass = TunRespPassAll(PassStepInds);
        PassBinValueAll{cStep} = cBinPass;
        PassBinedValueAvg(cStep,:) = [mean(cBinPass),std(cBinPass)/sqrt(numel(cBinPass))];
    end
end
EmptyBinInds = cellfun(@isempty,BinedValueAll);
UsedBinInds = BinCenters(~EmptyBinInds);
UsedBinData = BinedValueAvg(~EmptyBinInds,:);
PassEmotyInds = cellfun(@isempty,PassBinValueAll);
PassUsedBinInds = BinCenters(~PassEmotyInds);
PassUsedBinData = PassBinedValueAvg(~PassEmotyInds,:);
PassUsedBinVAll = PassBinValueAll(~PassEmotyInds);

hold on
errorbar(UsedBinInds,UsedBinData(:,1),UsedBinData(:,2),'ro--','linewidth',1.2);
errorbar(PassUsedBinInds,PassUsedBinData(:,1),PassUsedBinData(:,2),'ko--','linewidth',1.2);
set(gca,'xlim',[-2 2],'ylim',[0.1 0.7],'xtick',[-2 0 2],'ytick',[0 0.5 0.7],'box','off');
xlabel('AwayFromBoundary');
ylabel('Response (Nor.)');
set(gca,'FontSize',16)
saveas(gcf,'Tuned ROIs popuAvg fit plot');
saveas(gcf,'Tuned ROIs popuAvg fit plot','png');
saveas(gcf,'Tuned ROIs popuAvg fit plot','pdf');

%%
CategBins = -2:0.2:2;
CategBinCent = CategBins + 0.1;
nBins = length(CategBins);
BinTaskCategDataAll = cell(nBins , 1);
BinTaskCategDataAvg = mean(nBins , 1);
BinPassCategDataAll = cell(nBins , 1);
BinPassCategDataAvg = mean(nBins , 1);
for cBin = 1 : nBins - 1
    cBinTaskInds = find(TaskOctavesAll > CategBins(cBin) & TaskOctavesAll < CategBins(cBin+1));
    cBinPassInds = find(PassOctaveAll > CategBins(cBin) & PassOctaveAll < CategBins(cBin+1));
    if ~isempty(cBinTaskInds)
        cBinTaskData = CategRespTaskAll(cBinTaskInds);
        BinTaskCategDataAll{cBin} = cBinTaskData;
        BinTaskCategDataAvg(cBin) = mean(cBinTaskData);
    end
    if ~isempty(cBinPassInds)
        cBinPassData = CategRespPassAll(cBinPassInds);
        BinPassCategDataAll{cBin} = cBinPassData;
        BinPassCategDataAvg(cBin) = mean(cBinPassData);
    end
end
TaskEmpInds = cellfun(@isempty,BinTaskCategDataAll);
TaskCategusedOct = CategBinCent(~TaskEmpInds);
TaskCatehUsedData = BinTaskCategDataAvg(~TaskEmpInds);
PassEmpInds = cellfun(@isempty,BinPassCategDataAll);
PassCategOct = CategBinCent(~PassEmpInds);
PassCategUsedData = BinPassCategDataAvg(~PassEmpInds);

%% fitting the tuning of near bound tuning ROIs response with a guassian function
modelfunc = @(c1,c2,c3,c4,x) c1*exp((-1)*((x - c2).^2)./(2*(c3^2)))+c4;
[AmpV,AmpInds] = max(TaskNearBoundDataA);
c0 = [AmpV,0,0.2,min(TaskNearBoundDataA)];  % 0.4 is the octave step
cUpper = [AmpV*10,max(TaskNearBoundOctAll),max(TaskNearBoundOctAll) - min(TaskNearBoundOctAll),AmpV*10];
cLower = [0,min(TaskNearBoundOctAll),0.2,-Inf];
[ffit,gof] = fit(TaskNearBoundOctAll(:),TaskNearBoundDataA(:),modelfunc,...
'StartPoint',c0,'Upper',cUpper,'Lower',cLower,'Robust','LAR','MaxIter',1000);  % 'Method','NonlinearLeastSquares',
Octs = linspace(min(TaskNearBoundOctAll),max(TaskNearBoundOctAll),500);
fitData = feval(ffit,Octs);
figure;
plot(Octs,fitData,'r','linewidth',1.8);
% Passive fit
modelfunc = @(c1,c2,c3,c4,x) c1*exp((-1)*((x - c2).^2)./(2*(c3^2)))+c4;
[AmpV,AmpInds] = max(PassNearBoundDataA);
c0 = [AmpV,0,0.2,min(PassNearBoundDataA)];  % 0.4 is the octave step
cUpper = [AmpV*10,max(PassNearBoundOctAll),max(PassNearBoundOctAll) - min(PassNearBoundOctAll),AmpV*10];
cLower = [-1*AmpV*10,min(PassNearBoundOctAll),0.1,-Inf];
[ffitPass,gofPass] = fit(PassNearBoundOctAll(:),PassNearBoundDataA(:),modelfunc,...
'StartPoint',c0,'Upper',cUpper,'Lower',cLower,'Robust','LAR','MaxIter',1000);  % 'Method','NonlinearLeastSquares',
Octs = linspace(min(PassNearBoundOctAll),max(PassNearBoundOctAll),500);
fitData = feval(ffitPass,Octs);
hold on
plot(Octs,fitData,'k','linewidth',1.8)

figure;
hold on
plot(PassNearBoundOctAll,PassNearBoundDataA,'ko')
plot(TaskNearBoundOctAll,TaskNearBoundDataA,'ro')
%% categprical ROI fitting

modelfunb = @(b1,b2,b3,b4,x) (b1+ b2./(1+exp(-(x - b3)./b4)));
% using the new model function
UL = [max(CategRespTaskAll)+abs(min(CategRespTaskAll)), Inf, max(TaskOctavesAll), 100];
SP = [min(CategRespTaskAll),max(CategRespTaskAll) - min(CategRespTaskAll), mean(TaskOctavesAll), 1];
LM = [-Inf,-Inf, min(TaskOctavesAll), 1e-6];
ParaBoundLim = ([UL;SP;LM]);
[fit_model,fitgof] = fit(TaskOctavesAll,CategRespTaskAll,modelfunb,'StartPoint',SP,'Upper',UL,'Lower',LM);
OctaveRange = linspace(min(TaskOctavesAll),max(TaskOctavesAll),500);
FitCurve = feval(fit_model,OctaveRange);
hhf = figure;
hold on
plot(OctaveRange,FitCurve,'r','linewidth',2);
% plot(TaskOctavesAll,CategRespTaskAll,'o','Color',[0.8 0.6 0.6],'linewidth',0.4);

% passive function
CategRespPassAll(CategRespPassAll < -1) = 0;
PassUL = [max(CategRespPassAll)+abs(min(CategRespPassAll)), Inf, max(PassOctaveAll), 100];
PassSP = [min(CategRespPassAll),max(CategRespPassAll) - min(CategRespPassAll), mean(PassOctaveAll), 1];
PassLM = [-Inf,-Inf, min(PassOctaveAll), 1e-6];
PassParaBoundLim = ([PassUL;PassSP;PassLM]);
[Passfit_model,Passfitgof] = fit(PassOctaveAll,CategRespPassAll,modelfunb,'StartPoint',PassSP,'Upper',PassUL,'Lower',PassLM);
OctaveRange = linspace(min(PassOctaveAll),max(PassOctaveAll),500);
PassFitCurve = feval(Passfit_model,OctaveRange);
plot(OctaveRange,PassFitCurve,'k','linewidth',2)
% plot(PassOctaveAll,CategRespPassAll,'o','Color',[0.8 0.8 0.8],'linewidth',0.4);
%
UsedInds = [-1,-0.6,-0.2,0.2,0.6,1];
Freqs = ((2.^UsedInds)*16);
FreqStrs = cellstr(num2str(Freqs(:),'%.1f'));
TaskMeanSem = zeros(length(UsedInds),3);
PassMeanSem = zeros(length(UsedInds),3);
for nUsedInds = 1 : length(UsedInds)
    cTaskData = CategRespTaskAll(TaskOctavesAll > (UsedInds(nUsedInds)-0.05) & TaskOctavesAll < (UsedInds(nUsedInds)+0.05));
    GrSEM = std(cTaskData)/sqrt(length(cTaskData));
    ts = tinv([0.025  0.975],length(cTaskData)-1);
    ErrorBarCI = ts*GrSEM;
    TaskMeanSem(nUsedInds,:) = [mean(cTaskData),ErrorBarCI];
    
    cPassData = CategRespPassAll(PassOctaveAll > (UsedInds(nUsedInds)-0.05) & PassOctaveAll < (UsedInds(nUsedInds)+0.05));
    GrSEM = std(cPassData)/sqrt(length(cPassData));
    ts = tinv([0.025  0.975],length(cPassData)-1);
    ErrorBarCI = ts*GrSEM;
    PassMeanSem(nUsedInds,:) = [mean(cPassData),ErrorBarCI];
end
figure(hhf);
errorbar(UsedInds,TaskMeanSem(:,1),abs(TaskMeanSem(:,2)),TaskMeanSem(:,3),'ro','linewidth',1.6);
errorbar(UsedInds,PassMeanSem(:,1),abs(PassMeanSem(:,2)),PassMeanSem(:,3),'ko','linewidth',1.6);
set(gca,'xlim',[-1.1 1.1],'ylim',[0 1],'xtick',UsedInds,'xticklabel',FreqStrs,'ytick',[0 0.5 1]);
xlabel('Frequency (kHz)');
ylabel('Response (Nor.)');
set(gca,'FontSize',18)

%% ROI type fraction pie plot
% pie plot for categorical fraction
CategFrac = mean(SessROItypeFrac(:,1)./SessROItypeFrac(:,5));
TunROIFrac = mean(SessROItypeFrac(:,2)./SessROItypeFrac(:,5));
RestFrac = 1 - CategFrac - TunROIFrac;
PieData = [CategFrac,TunROIFrac,RestFrac];
PieStrs = {sprintf('Categ. %.2f%%',CategFrac*100);sprintf('Tuning %.2f%%',TunROIFrac*100);sprintf('NoSelect. %.2f%%',RestFrac*100)};
CategExplode = [1 0 0];
tunExplode = [0 1 0];
hhf = figure('position',[100 100 620 280]);
subplot(121)
hp = pie(PieData,CategExplode,PieStrs);
set(hp(1),'FaceColor','m','EdgeColor','none');
set(hp(2),'Color','m');
set(hp(3),'FaceColor','g','EdgeColor','none');
set(hp(4),'Color',[0 0.5 0]);
set(hp(5),'FaceColor',[.5 .5 .5],'EdgeColor','none');
set(hp(6),'Color',[.1 .1 .1]);

subplot(122)
hp = pie(PieData,tunExplode,PieStrs);
set(hp(1),'FaceColor','m','EdgeColor','none');
set(hp(2),'Color','m');
set(hp(3),'FaceColor','g','EdgeColor','none');
set(hp(4),'Color',[0 0.5 0]);
set(hp(5),'FaceColor',[.5 .5 .5],'EdgeColor','none');
set(hp(6),'Color',[.1 .1 .1]);

saveas(hhf,'Cell type fraction pie plot');
saveas(hhf,'Cell type fraction pie plot','png');
saveas(hhf,'Cell type fraction pie plot','pdf');

%% fitting the boundaryTuning data with a gaussian function
% fitting the tuning with a guassian function
modelfunc = @(c1,c2,c3,c4,x) c1*exp((-1)*((x - c2).^2)./(2*(c3^2)))+c4;
[AmpV,AmpInds] = max(BoundTunDataOctAll(:,1));
c0 = [AmpV,0,0.2,min(BoundTunDataOctAll(:,1))];  % 0.4 is the octave step
cUpper = [AmpV*1,max(BoundTunDataOctAll(:,2)),max(BoundTunDataOctAll(:,2)) - min(BoundTunDataOctAll(:,2)),AmpV*10];
cLower = [0,min(BoundTunDataOctAll(:,2)),0.1,-Inf];
[ffit,gof] = fit(BoundTunDataOctAll(:,2),BoundTunDataOctAll(:,1),modelfunc,...
'StartPoint',c0,'Upper',cUpper,'Lower',cLower,'Robust','LAR','MaxIter',1000);  % 'Method','NonlinearLeastSquares',
Octs = linspace(min(BoundTunDataOctAll(:,2)),max(BoundTunDataOctAll(:,2)),500);
fitData = feval(ffit,Octs);
figure;
ll1 = plot(Octs,fitData,'r','linewidth',1.8);
% Passive fit
modelfunc = @(c1,c2,c3,c4,x) c1*exp((-1)*((x - c2).^2)./(2*(c3^2)))+c4;
[AmpV,AmpInds] = max(BoundTunDataPassOctAll(:,1));
c0 = [AmpV,0,0.2,min(BoundTunDataPassOctAll(:,1))];  % 0.4 is the octave step
cUpper = [AmpV*1,max(BoundTunDataPassOctAll(:,2)),max(BoundTunDataPassOctAll(:,2)) - min(BoundTunDataPassOctAll(:,2)),AmpV*10];
cLower = [-1*AmpV*10,min(BoundTunDataPassOctAll(:,2)),0.1,-Inf];
[ffitPass,gofPass] = fit(BoundTunDataPassOctAll(:,2),BoundTunDataPassOctAll(:,1),modelfunc,...
'StartPoint',c0,'Upper',cUpper,'Lower',cLower,'Robust','LAR','MaxIter',1000);  % 'Method','NonlinearLeastSquares',
PassOcts = linspace(min(BoundTunDataPassOctAll(:,2)),max(BoundTunDataPassOctAll(:,2)),500);
PassfitData = feval(ffitPass,PassOcts);
hold on
plot(PassOcts,PassfitData,'k','linewidth',1.8);
%
SpaceStep = -2:0.2:2;
BinCenters = SpaceStep+(0.2/2);
BinedValueAvg = zeros(length(SpaceStep),2);
BinedValueAll = cell(length(SpaceStep),1);
PassBinedValueAvg = zeros(length(SpaceStep),2);
PassBinValueAll = cell(length(SpaceStep),1);
for cStep = 1 : length(SpaceStep)-1
    WithinStepInds = find(BoundTunDataOctAll(:,2) > SpaceStep(cStep) & BoundTunDataOctAll(:,2) < SpaceStep(cStep+1));
    PassStepInds = find(BoundTunDataPassOctAll(:,2) > SpaceStep(cStep) & BoundTunDataPassOctAll(:,2) < SpaceStep(cStep+1));
    if ~isempty(WithinStepInds)
        cBinData = BoundTunDataOctAll(WithinStepInds,1);
        BinedValueAll{cStep} = cBinData;
        BinedValueAvg(cStep,:) = [mean(cBinData),std(cBinData)/sqrt(numel(cBinData))];
    end
    if ~isempty(PassStepInds)
        cBinPass = BoundTunDataPassOctAll(PassStepInds,1);
        PassBinValueAll{cStep} = cBinPass;
        PassBinedValueAvg(cStep,:) = [mean(cBinPass),std(cBinPass)/sqrt(numel(cBinPass))];
    end
end
EmptyBinInds = cellfun(@isempty,BinedValueAll);
UsedBinInds = BinCenters(~EmptyBinInds);
UsedBinData = BinedValueAvg(~EmptyBinInds,:);
PassEmotyInds = cellfun(@isempty,PassBinValueAll);
PassUsedBinInds = BinCenters(~PassEmotyInds);
PassUsedBinData = PassBinedValueAvg(~PassEmotyInds,:);
PassUsedBinVAll = PassBinValueAll(~PassEmotyInds);

hold on
errorbar(UsedBinInds,UsedBinData(:,1),UsedBinData(:,2),'ro--','linewidth',1.2);
errorbar(PassUsedBinInds,PassUsedBinData(:,1),PassUsedBinData(:,2),'ko--','linewidth',1.2);
set(gca,'xlim',[-1.1 1.1],'ylim',[0 1.2],'xtick',[-1 0 1],'ytick',[0 0.5 1],'box','off');
xlabel('AwayFromBoundary');
ylabel('Response (Nor.)');
 title('Boundary Tuning ROIs')
set(gca,'FontSize',16)
saveas(gca,'Boundary tuning ROI population average')
saveas(gca,'Boundary tuning ROI population average','pdf')


%% fitting the constrained boundaryTuning data with a gaussian function
% fitting the tuning with a guassian function
modelfunc = @(c1,c2,c3,c4,x) c1*exp((-1)*((x - c2).^2)./(2*(c3^2)))+c4;
[AmpV,AmpInds] = max(CBoundTunDataOctAll(:,1));
c0 = [AmpV,0,0.2,min(CBoundTunDataOctAll(:,1))];  % 0.4 is the octave step
cUpper = [AmpV*10,max(CBoundTunDataOctAll(:,2)),max(CBoundTunDataOctAll(:,2)) - min(CBoundTunDataOctAll(:,2)),AmpV*10];
cLower = [0,min(CBoundTunDataOctAll(:,2)),0.1,-Inf];
[ffit,gof] = fit(CBoundTunDataOctAll(:,2),CBoundTunDataOctAll(:,1),modelfunc,...
'StartPoint',c0,'Upper',cUpper,'Lower',cLower,'Robust','LAR','MaxIter',1000);  % 'Method','NonlinearLeastSquares',
Octs = linspace(min(CBoundTunDataOctAll(:,2)),max(CBoundTunDataOctAll(:,2)),500);
fitData = feval(ffit,Octs);
figure;
ll1 = plot(Octs,fitData,'r','linewidth',1.8);
% Passive fit
modelfunc = @(c1,c2,c3,c4,x) c1*exp((-1)*((x - c2).^2)./(2*(c3^2)))+c4;
[AmpV,AmpInds] = max(CBoundTunDataPassOctAll(:,1));
c0 = [AmpV,0,0.2,min(CBoundTunDataPassOctAll(:,1))];  % 0.4 is the octave step
cUpper = [AmpV*10,max(CBoundTunDataPassOctAll(:,2)),max(CBoundTunDataPassOctAll(:,2)) - min(CBoundTunDataPassOctAll(:,2)),AmpV*10];
cLower = [-1*AmpV*10,min(CBoundTunDataPassOctAll(:,2)),0.1,-Inf];
[ffitPass,gofPass] = fit(CBoundTunDataPassOctAll(:,2),CBoundTunDataPassOctAll(:,1),modelfunc,...
'StartPoint',c0,'Upper',cUpper,'Lower',cLower,'Robust','LAR','MaxIter',1000);  % 'Method','NonlinearLeastSquares',
PassOcts = linspace(min(CBoundTunDataPassOctAll(:,2)),max(CBoundTunDataPassOctAll(:,2)),500);
PassfitData = feval(ffitPass,PassOcts);
hold on
plot(PassOcts,PassfitData,'k','linewidth',1.8);
%
SpaceStep = -2:0.2:2;
BinCenters = SpaceStep+(0.2/2);
BinedValueAvg = zeros(length(SpaceStep),2);
BinedValueAll = cell(length(SpaceStep),1);
PassBinedValueAvg = zeros(length(SpaceStep),2);
PassBinValueAll = cell(length(SpaceStep),1);
for cStep = 1 : length(SpaceStep)-1
    WithinStepInds = find(CBoundTunDataOctAll(:,2) > SpaceStep(cStep) & CBoundTunDataOctAll(:,2) < SpaceStep(cStep+1));
    PassStepInds = find(CBoundTunDataPassOctAll(:,2) > SpaceStep(cStep) & CBoundTunDataPassOctAll(:,2) < SpaceStep(cStep+1));
    if ~isempty(WithinStepInds)
        cBinData = CBoundTunDataOctAll(WithinStepInds,1);
        BinedValueAll{cStep} = cBinData;
        BinedValueAvg(cStep,:) = [mean(cBinData),std(cBinData)/sqrt(numel(cBinData))];
    end
    if ~isempty(PassStepInds)
        cBinPass = CBoundTunDataPassOctAll(PassStepInds,1);
        PassBinValueAll{cStep} = cBinPass;
        PassBinedValueAvg(cStep,:) = [mean(cBinPass),std(cBinPass)/sqrt(numel(cBinPass))];
    end
end
EmptyBinInds = cellfun(@isempty,BinedValueAll);
UsedBinInds = BinCenters(~EmptyBinInds);
UsedBinData = BinedValueAvg(~EmptyBinInds,:);
PassEmotyInds = cellfun(@isempty,PassBinValueAll);
PassUsedBinInds = BinCenters(~PassEmotyInds);
PassUsedBinData = PassBinedValueAvg(~PassEmotyInds,:);
PassUsedBinVAll = PassBinValueAll(~PassEmotyInds);

hold on
errorbar(UsedBinInds,UsedBinData(:,1),UsedBinData(:,2),'ro--','linewidth',1.2);
errorbar(PassUsedBinInds,PassUsedBinData(:,1),PassUsedBinData(:,2),'ko--','linewidth',1.2);
set(gca,'xlim',[-1.1 1.1],'ylim',[0 1],'xtick',[-1 0 1],'ytick',[0 0.5 1],'box','off');
xlabel('AwayFromBoundary');
ylabel('Response (Nor.)');
title('Constrained Boundary Tuning ROIs')
set(gca,'FontSize',16)

saveas(gca,'Constrained Boundary tuning ROI population average')
saveas(gca,'Constrained Boundary tuning ROI population average','pdf')

