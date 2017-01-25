% scripts for tbyt choice decoding analysis result, summarized result

addchar = 'y';

datasum = {};
DataRealPerf = [];
DataPredPerf = [];
Dataoctave = [];
dataPath = {};
meanRealPerf = [];
meanPredPerf = [];
m = 1;
%%
while ~strcmpi(addchar,'n')
    [fn,fp,fi] = uigetfile('AnmChoicePredSave.mat','Please select your TbyT neurometric data');
    if fi
        dataPath{m} = fullfile(fp,fn);
        xx = load(fullfile(fp,fn));
        datasum{m} = xx;
        cNeuroPerf = xx.PredStimPerf;
        cBehavPerf = xx.RealStimPerf;
        cOctaves = xx.StimOct;
        WithinFreqPerfInds = cOctaves>0.00001 & cOctaves<1.9999;
        
        cNeuroPerfMean = mean(cNeuroPerf,2);
        if ~mod(length(cNeuroPerfMean),2)
            excludedInds = cOctaves == 1;
        else
            excludedInds = cOctaves == mean(cOctaves(1)+cOctaves(end));
        end
        
        cBehavPerf(excludedInds) = [];
        cNeuroPerfMean(excludedInds) = [];
        cOctaves(excludedInds) = [];
%         if mod(length(cBehavPerf),2)
%             ExInds = (floor(length(cBehavPerf)/2))+1;
%             cBehavPerf(ExInds) = [];
%             cNeuroPerfMean(ExInds) = [];
%             cOctaves(ExInds) = [];
%         end
        
        DataRealPerf(m,:) = cBehavPerf;
        DataPredPerf(m,:) = cNeuroPerfMean;
        Dataoctave(m,:) = cOctaves;
        
        meanRealPerf(m) = mean(cBehavPerf(WithinFreqPerfInds));
        meanPredPerf(m) = mean(cNeuroPerfMean(WithinFreqPerfInds));
        m = m + 1;
    end
    
    addchar = input('Do you want to add another session data?\n','s');
end

%%
m = m - 1;
DataSvaePath = uigetdir('Please select a path to save current data');
cd(DataSvaePath);
save SummaryDataSave.mat datasum Dataoctave DataRealPerf DataPredPerf meanRealPerf meanPredPerf -v7.3
f = fopen('New_neurometric_save_path.txt','w+');
fprintf(f,'New neurometric analysis summary path:\r\n');
FormatStr = '%s;\r\n';
for nbnb = 1 : m
    fprintf(f,FormatStr,dataPath{nbnb});
end
fclose(f);

%%
% calculate the internal frequencies correct rate
fprintf('Totally %d session data being summarized for analysis.\n',m);
BehavSumMean = mean(meanRealPerf);
RFNeuroSunMean = mean(meanPredPerf);
PairedPoints = [meanRealPerf;meanPredPerf];
h_RFAll = figure('position',[200 200 1200 800]);
hold on;
bar(1,BehavSumMean,0.2,'k');
bar(2,RFNeuroSunMean,0.2,'b');
plot(PairedPoints,'color',[.5 .5 .5],'LineWidth',4);
xlim([0 3]);
set(gca,'xtick',[1 2],'xticklabel',{'Behav','Task Neuro'});
set(gca,'ytick',[0 0.5 1]);
ylim([0 1.1]);
title('Task Neuron compare with behavior');
set(gca,'FontSize',20);
[h,p] = ttest(meanRealPerf,meanPredPerf);  % vartest2 for equal variance test
text(1.5,0.9,sprintf('p = %.4f',p),'HorizontalAlignment','center','FontSize',14);
saveas(h_RFAll,'Task and behavior compare plot2');
saveas(h_RFAll,'Task and behavior compare plot2','png');


%%
% loading trial by trial presiction result
addchar = 'y';
ifoldLoad = 0;
OldDataLoad = input('Would you like to load former summarization data?\n','s');
if ~strcmpi(OldDataLoad,'n')
    [fn,fp,fi] = uigetfile('SingleTrChoicSave.mat','Please select your fomer analysis data');
    ifoldLoad = 1;
    load(fullfile(fp,fn));
    m = length(DataSum)+1;
else
    DataSum = {};
    SessionStimulus = {};
    SessionTrialTYpes = {};
    SessionAnmChoiceall = {};
    SessionPredChoiceAll = {};
    m = 1;
end

while ~strcmpi(addchar,'n')
    [fn,fp,fi] = uigetfile('AnmChoicePredSave.mat','Please select your analysis data set');
    if fi
        DataPath = fullfile(fp,fn);
        xx = load(DataPath);
        DataSum{m} = xx;
        if mod(length(unique(xx.Stimlulus)),2)
            stimTypes = unique(xx.Stimlulus);
            BoundStim = stimTypes(ceil(length(stimTypes)/2));
            BoundTrInds = xx.Stimlulus == BoundStim;
            
            xx.Stimlulus(BoundTrInds) = [];
            xx.TrialTypes(BoundTrInds) = [];
            xx.UsingAnmChoice(BoundTrInds) = [];
            xx.IterPredChoice(BoundTrInds) = [];
        end
        SessionStimulus{m} = xx.Stimlulus;
        SessionTrialTYpes{m} = xx.TrialTypes;
        SessionAnmChoiceall{m} = xx.UsingAnmChoice;
        SessionPredChoiceAll{m} = xx.IterPredChoice;
        m = m + 1;
    end
    addchar = input('Do you want to add another session data?\n','s');
end
m = m - 1;
save SingleTrChoicSave.mat DataSum SessionStimulus SessionTrialTYpes SessionAnmChoiceall SessionPredChoiceAll -v7.3

%%
[StimWiseData,StimAll] = cellfun(@(x,y,z,a) ChoiceCorrelationAna(x,y,z,a),SessionStimulus,SessionTrialTYpes,...
    SessionAnmChoiceall,SessionPredChoiceAll,'UniformOutput',false);
save StimWisedData.mat StimWiseData StimAll -v7.3

%%
% calculating the correlation, using one cell as as example
SingSessData = StimWiseData{1};
SingleStimOne = SingSessData{1,4};
cSinStimOutcomes = SingleStimOne(:,3);
ErrorInds = cSinStimOutcomes == 0;
cErroAnmChoice = SingleStimOne(ErrorInds,1);
cErroPredChoice = SingleStimOne(ErrorInds,2);
cAnmChoice = unique(cErroAnmChoice);
if length(cAnmChoice) > 1
    warning('Current anmchoice within error trials have more than one animal choice');
    cAnmChoice = min(cAnmChoice);
end
p_ErrTrpredError = mean(cErroPredChoice == cAnmChoice);
fprintf('Probability of predicted choice is also error is %.4f.\n',p_ErrTrpredError);

cCorrAnmChoice = SingleStimOne(~ErrorInds,1);
cCorrPredChoice = SingleStimOne(~ErrorInds,2);
cCorrChoice = 1 - cAnmChoice;
p_CorTrpredCorr = mean(cCorrPredChoice ~= cCorrChoice);
fprintf('Probability of predicted choice of error within correct trials is %.4f.\n',p_CorTrpredCorr);

%%
if ~isdir('./Single_session_result/')
    mkdir('./Single_session_result/');
end
cd('./Single_session_result/');

pErroErroAll = cell(length(StimWiseData),1);
pCorrErroAll = cell(length(StimWiseData),1);
for nSession = 1 : length(StimWiseData)
    cSessionData = StimWiseData{nSession};
    [p_ErroErro,p_corrErro] = cellfun(@(x) withinCellProbCal(x),cSessionData);
    % if perfrctly predicted, the value of p_ErroErro should all be 1, and
    % value of p_corrErro should all be 0
    
    pErroErroAll{nSession} = p_ErroErro;
    pCorrErroAll{nSession} = p_corrErro;
    
    h_f = figure('position',[100 100 1400 800]);
    subplot(121);
    imagesc(p_ErroErro);
    colorbar;
    title('Prob. of Pred\_of\_Error Within Error Trials');
    set(gca,'FontSize',20);
    
    subplot(122)
    imagesc(p_corrErro);
    colorbar
    title('Prob. of Pred\_of\_Error Within Correct Trials');
    set(gca,'FontSize',20);
    
    saveas(h_f,sprintf('Session %d pred_of_error probability plot',nSession));
    saveas(h_f,sprintf('Session %d pred_of_error probability plot',nSession),'png');
    close(h_f);
end
save ErrorProbCal.mat pErroErroAll pCorrErroAll -v7.3
cd ..;
