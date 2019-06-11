
CNOfilePath = 'R:\Xulab_Share_Nutstore\Zhang_Yuan\hM4D withmiss sum plot\ACtx hM4D raw behavior\CNO matfile';
BehavConlPath = 'R:\Xulab_Share_Nutstore\Zhang_Yuan\hM4D withmiss sum plot\ACtx hM4D raw behavior\control for CNO matfile';
salinePath = 'R:\Xulab_Share_Nutstore\Zhang_Yuan\hM4D withmiss sum plot\ACtx hM4D raw behavior\saline control matfile';

%%
cd(CNOfilePath);
CNPmatfileAll = dir('*.mat');
CNODataStrc = struct('fname','','TrStimFreq',[],'TrType',[],'TrChoice',[],'TrIsProb',[]);
CNOCurveData = cell(length(CNPmatfileAll),2);
psyCurveFit = cell(length(CNPmatfileAll),1);
for cf = 1 : length(CNPmatfileAll)
    cfName = CNPmatfileAll(cf).name;
    cfData = load(cfName);
    [behavResults,behavSettings] = behav_cell2struct(cfData.SessionResults,cfData.SessionSettings);
    CNODataStrc(cf).fname = cfName(1:end-3);
    NMInds = behavResults.Action_choice ~= 2;
    
    
    NMChoice = double(behavResults.Action_choice(NMInds));
    NMfreqsAll = double(behavResults.Stim_toneFreq(NMInds));
    NMIsProb = double(behavResults.Trial_isProbeTrial(NMInds));
    NMTrTypes = double(behavResults.Trial_Type(NMInds));
    
    CNODataStrc(cf).TrStimFreq = NMfreqsAll;
    CNODataStrc(cf).TrType = NMTrTypes;
    CNODataStrc(cf).TrChoice = NMChoice;
    CNODataStrc(cf).TrIsProb = NMIsProb;
    
    NMOctAlls = log2(NMfreqsAll/14000);
    ffitData = FitPsycheCurveWH_nx(NMOctAlls(:),NMChoice(:));
    psyCurveFit{cf} = ffitData;
    
    FreqTypes = unique(NMfreqsAll);
    CNOCurveData{cf,1} = FreqTypes;
    nFreqs = length(FreqTypes);
    FreqChoiceFrac = zeros(nFreqs,1);
    for ccc = 1 : nFreqs
        cffreq = FreqTypes(ccc);
        cfreqInds = NMfreqsAll == cffreq;
        FreqChoiceFrac(ccc) = mean(NMChoice(cfreqInds));
    end
    CNOCurveData{cf,2} = FreqChoiceFrac;
end
%%
CNODataFreqMtx = cell2mat(CNOCurveData(:,1));
CNODataOctaveMtx = log2(CNODataFreqMtx/14000);
CNODataChoiceMtx = cell2mat(CNOCurveData(:,2)');
hf = figure;
plot(CNODataOctaveMtx',CNODataChoiceMtx,'k-o')

%% session data path
% R:\Xulab_Share_Nutstore\Zhang_Yuan\hM4D withmiss sum plot\CNO VS saline control

CNOSalineDataStrc = load('R:\Xulab_Share_Nutstore\Zhang_Yuan\hM4D withmiss sum plot\CNO VS saline control\CNO_saline_sum.mat');

CNO_trainData = CNOSalineDataStrc.percent_correct_traing_withdrug;
CNO_probData = CNOSalineDataStrc.percent_correct_probe_withdrug;
Saline_trainData = CNOSalineDataStrc.percent_correct_traing_control;
Saline_probData = CNOSalineDataStrc.percent_correct_probe_control;
%%
hf = figure('position',[2000 100 680 300]);

ax1 = subplot(121);
hold on
bar([1,2],[mean(Saline_trainData) mean(CNO_trainData)],0.5,'FaceColor',[.7 .7 .7],'EdgeColor','none');
plot([1,2],[Saline_trainData;CNO_trainData],'Color','k','linewidth',1.2);

[~,p1] = ttest(Saline_trainData,CNO_trainData);
GroupSigIndication([1 2],[max(Saline_trainData) max(CNO_trainData)],p1,ax1);
set(gca,'xtick',[1 2],'xticklabel',{'Saline','CNO'},'ytick',[0 0.5 1]);
ylabel('Corect rate');
title('Training')
set(gca,'FontSize',10);

ax2 = subplot(122);
hold on
bar([1,2],[mean(Saline_probData) mean(CNO_probData)],0.5,'FaceColor',[.7 .7 .7],'EdgeColor','none');
plot([1,2],[Saline_probData;CNO_probData],'Color','k','linewidth',1.2);
[~,p2] = ttest(Saline_probData,CNO_probData);
GroupSigIndication([1 2],[max(Saline_probData) max(CNO_probData)],p2,ax2);
set(gca,'xtick',[1 2],'xticklabel',{'Saline','CNO'},'ytick',[0 0.5 1])
ylabel('Corect rate');
title('Prob')
set(gca,'FontSize',10);

