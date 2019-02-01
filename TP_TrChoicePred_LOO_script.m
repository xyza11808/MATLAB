
% this scripts is used for analysis of the trial by trial results by using
% error trials as real behavior choice for training

if IsTaskSess
    TimeScale = 1;
    if length(TimeScale) == 1
        FrameScale = sort([(start_frame+1),(start_frame + round(TimeScale*frame_rate))]);
    elseif length(TimeScale) == 2
        FrameScale = sort([(start_frame + round(TimeScale(1)*frame_rate)),(start_frame + round(TimeScale(2)*frame_rate))]);
    end
    if exist('UsedROIInds','var')
        RespData = mean(data_aligned(:,UsedROIInds,FrameScale(1):FrameScale(2)),3);
    else
        RespData = mean(data_aligned(:,:,FrameScale(1):FrameScale(2)),3);
    end
    %
    % Trial outcomes correction
    AnimalChoice = double(behavResults.Action_choice(:));
    UsingTrInds = AnimalChoice ~= 2;
    % UsingTrInds = trial_outcome == 1;
    UsingAnmChoice = double(AnimalChoice(UsingTrInds));
    UsingRespData = RespData(UsingTrInds,:);
    Stimlulus = (double(behavResults.Stim_toneFreq(UsingTrInds)))';
    TrialOutcomes = trial_outcome(UsingTrInds);
    TrialTypes = (double(behavResults.Trial_Type(UsingTrInds)))';
    
   
    StimTypes = unique(Stimlulus);
    StimAvgDatas = zeros(numel(StimTypes),size(UsingRespData,2));
    StimRProb = zeros(numel(StimTypes),2);
    for cs = 1 : numel(StimTypes)
        csInds = Stimlulus == StimTypes(cs);
        StimAvgDatas(cs,:) = mean(UsingRespData(csInds,:));

        StimRProb(cs,:) = [mean(UsingAnmChoice(csInds)),std(UsingAnmChoice(csInds))/sqrt(sum(csInds))];
    end
    rescaleB = max(StimRProb);
    rescaleA = min(StimRProb);

    StimOctaves = log2(Stimlulus/min(Stimlulus)) - 1;
    StimOctaveTypes = unique(StimOctaves);
    BehavFit = FitPsycheCurveWH_nx(StimOctaves(:),UsingAnmChoice);
    TaskStimTypeOcts = StimOctaveTypes;
else
    TimeScale = 1;
    start_frame = frame_rate;
    if length(TimeScale) == 1
        FrameScale = sort([(start_frame+1),(start_frame + round(TimeScale*frame_rate))]);
    elseif length(TimeScale) == 2
        FrameScale = sort([(start_frame + round(TimeScale(1)*frame_rate)),(start_frame + round(TimeScale(2)*frame_rate))]);
    end
    if exist('UsedROIInds','var')
        RespData = mean(SelectData(:,UsedROIInds,FrameScale(1):FrameScale(2)),3);
    else
        RespData = mean(SelectData(:,:,FrameScale(1):FrameScale(2)),3);
    end
    if exist('UsedTrInds','var')
        RespData = mean(SelectData(UsedTrInds,:,FrameScale(1):FrameScale(2)),3);
        Stimlulus = SelectSArray(UsedTrInds);
    else
        RespData = mean(SelectData(UsedTrInds,:,FrameScale(1):FrameScale(2)),3);
        Stimlulus = SelectSArray;
    end

    % generate artificial choice types for passive sessions
    % Trial outcomes correction

    StimTypes = unique(Stimlulus);
    GroupNum = length(StimTypes)/2;
    StimOctaves = log2(Stimlulus/min(Stimlulus)) - 1;
    StimOctaveTypes = unique(StimOctaves);

    AnimalChoice = double(StimOctaves > 0);
    UsingTrInds = AnimalChoice ~= 2;
    % UsingTrInds = trial_outcome == 1;
    UsingAnmChoice = double(AnimalChoice(UsingTrInds));
    UsingRespData = RespData(UsingTrInds,:);
    StimAvgDatas = zeros(numel(StimTypes),size(UsingRespData,2));
    for cs = 1 : numel(StimTypes)
        csInds = Stimlulus == StimTypes(cs);
        StimAvgDatas(cs,:) = mean(UsingRespData(csInds,:));
    end

    TrialOutcomes = ones(numel(AnimalChoice),1);
    TrialTypes = AnimalChoice;

    TaskStimTypeOcts = log2(BehavDataStrc.boundary_result.StimType(:)/min(Stimlulus)) - 1;
    LeftInds = TaskStimTypeOcts < 0;
    StimRProb = BehavDataStrc.boundary_result.StimCorr;
    StimRProb(LeftInds) = 1 - StimRProb(LeftInds);
%     if mod(numel(StimRProb),2)
%         StimRProb(ceil(numel(StimRProb)/2)) = [];
%         StimOctaveTypes(ceil(numel(StimRProb)/2)) = [];
%     end
%     rescaleB = max(StimRProb);
%     rescaleA = min(StimRProb);
    BehavFit = BehavDataStrc.boundary_result.FitValue;
    if ~isstruct(BehavFit)
        BehavFit = BehavDataStrc.boundary_result.FitModelAll{1}{1,1};
    end

end

%%
% performing leave-one-out prediction for each trial

nTrs = size(UsingRespData,1);
nROI = size(UsingRespData,2);
PredTrChoice = zeros(nTrs,1);
MdSelfPerf = zeros(nTrs,1);
parfor cTr = 1 : nTrs
    cTrainInds = true(nTrs,1);
    cTrainInds(cTr) = false;
    
    cTrainData = UsingRespData(cTrainInds,:);
    cTrainLabel = UsingAnmChoice(cTrainInds);
    
    cTrTestData = UsingRespData(cTr,:);
    
    cFitMd = fitcsvm(cTrainData,cTrainLabel);
    MdSelfPerf(cTr) = 1 - kfoldLoss(crossval(cFitMd));
    
    cPredChoice = predict(cFitMd,cTrTestData);
    PredTrChoice(cTr) = cPredChoice;
end
    
%% plot the results
PassStimOcts = unique(StimOctaves);
NumOcts = numel(PassStimOcts);
OctPredRProb = zeros(NumOcts,2);
for cOct = 1 : NumOcts
    cOctInds = StimOctaves(:) == PassStimOcts(cOct);
    cOctChoice = PredTrChoice(cOctInds);
    OctPredRProb(cOct,:) = [mean(cOctChoice),std(cOctChoice)/sqrt(numel(cOctChoice))];
end

PredPerfFits = FitPsycheCurveWH_nx(StimOctaves(:),PredTrChoice(:));
hLOOf = figure('position',[100 100 420 340]);
hold on
plot(PredPerfFits.curve(:,1),PredPerfFits.curve(:,2),'r','linewidth',2);
plot(BehavFit.curve(:,1),BehavFit.curve(:,2),'k','linewidth',2)
errorbar(PassStimOcts,OctPredRProb(:,1),OctPredRProb(:,2),'ro','linewidth',1.8);
if IsTaskSess
    errorbar(TaskStimTypeOcts,StimRProb(:,1),StimRProb(:,2),'ko','linewidth',1.8);
else
    plot(TaskStimTypeOcts,StimRProb,'ko','linewidth',1.8);
end
xlim([-1.1 1.1]);
ylim([-0.05 1.05]);
set(gca,'xtick',StimOctaveTypes,'xticklabel',cellstr(num2str(StimTypes/1000,'%.1f')),'ytick',[0 0.5 1]);
title('Pred score and behav compare plot');
set(gca,'FontSize',12);
xlabel('Frequnecy (kHz)');
ylabel('Right prob');
    
%%
if ~isdir('./Test_anmChoice_LOO/')
    mkdir('./Test_anmChoice_LOO/');
end
cd('./Test_anmChoice_LOO/');

save LOOPred_NeuroCurve.mat PredTrChoice UsingAnmChoice MdSelfPerf BehavFit PredPerfFits...
    OctPredRProb StimRProb StimOctaveTypes StimOctaves -v7.3

saveas(hLOOf,'LOO neurometric curve plot save');
saveas(hLOOf,'LOO neurometric curve plot save','pdf');
saveas(hLOOf,'LOO neurometric curve plot save','png');
close(hLOOf);

%%
% clearvars -except NormSessPathTask NormSessPathPass
% m = 1;
% nSession = length(NormSessPathTask);
% 
% % Sess8_32_Inds = SessIndexAll == 4;
% % Sess8_32PathAll = SessPathAll(Sess8_32_Inds,1);
% 
% %
% Plots_Save_path = 'E:\DataToGo\NewDataForXU';
% SubDir = 'TbyT_NeuroCurve_summary';
% if ~isdir(fullfile(Plots_Save_path,SubDir))
%     mkdir(fullfile(Plots_Save_path,SubDir));
% end
% SavingPath = fullfile(Plots_Save_path,SubDir);
% SessSummaryfileName = 'Neurometric_curveSummary.pptx';
% %
% pptFullfile = fullfile(SavingPath,SessSummaryfileName);
% if ~exist(pptFullfile,'file')
%     NewFileExport = 1;
% else
%     NewFileExport = 0;
% end
% if NewFileExport
%     exportToPPTX('new','Dimensions',[16,9],'Author','XinYu','Comments','Export of tunning curve plot data');
% else
%     exportToPPTX('open',pptFullfile);
% end 
% %
% NumPaths = length(NormSessPathTask);
% 
% for cPath = 1 : NumPaths
%     c832Path = NormSessPathTask{cPath};
%     c832PassPath = NormSessPathPass{cPath};
%     
%     % loading task session neurometric curve
%     ToldTestPredPerfFig = fullfile(c832Path,'Test_anmChoice_predCROIsNew','TBYT choice decoding result compare plot.png');
%     TTestScoreFig = fullfile(c832Path,'Test_anmChoice_predCROIsNew','TestPredScore psychometric curve plots.png');
%     TNewTestPredPerfFig = fullfile(c832Path,'Test_anmChoice_LOO','LOO neurometric curve plot save.png');
%     
%     %  loading passive session figures
%     PoldTestPredPerfFig = fullfile(c832PassPath,'Test_anmChoice_predCROIsNew','TBYT choice decoding result compare plot.png');
%     PTestScoreFig = fullfile(c832PassPath,'Test_anmChoice_predCROIsNew','TestPredScore psychometric curve plots.png');
%     PNewTestPredPerfFig = fullfile(c832PassPath,'Test_anmChoice_LOO','LOO neurometric curve plot save.png');
%     
%     c832PathInfo = SessInfoExtraction(c832Path);
% 
%     try
%         exportToPPTX('addslide');
% 
%         exportToPPTX('addpicture',imread(TTestScoreFig),'Position',[4 1 4 3.2]);
%         exportToPPTX('addpicture',imread(ToldTestPredPerfFig),'Position',[0 4 4 3.24]);
%         exportToPPTX('addpicture',imread(TNewTestPredPerfFig),'Position',[4 4 4 3.24]);
%         
%         exportToPPTX('addpicture',imread(PTestScoreFig),'Position',[12 1 4 3.2]);
%         exportToPPTX('addpicture',imread(PoldTestPredPerfFig),'Position',[8 4 4 3.24]);
%         exportToPPTX('addpicture',imread(PNewTestPredPerfFig),'Position',[12 4 4 3.24]);
%         
%         exportToPPTX('addtext',sprintf('Batch:%s Anm: %s \nDate: %s Field: %s',...
%             c832PathInfo.BatchNum,c832PathInfo.AnimalNum,c832PathInfo.SessionDate,c832PathInfo.TestNum),...
%             'Position',[1 2 2 2],'FontSize',20);
%         exportToPPTX('addtext',sprintf('Session %d',cPath),'position',[0 0 2 1]);
%         exportToPPTX('addtext','Task','position',[0 1 1 1]);
%         exportToPPTX('addtext','Passive','position',[9 1 1 1]);
%         
%         exportToPPTX('addnote',c832Path);
%     catch ME
%         disp(ME.message);
%     end
%         
% end
% saveName = exportToPPTX('saveandclose',pptFullfile);



