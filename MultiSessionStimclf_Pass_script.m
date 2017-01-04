% this script is used for summarize multisession data together and
% performing multisession classification of stimulus types
% save CSessionData.mat smooth_data trial_outcome behavResults start_frame frame_rate NormalTrialInds -v7.3
add_char = 'y';
inputChoice = input('would like to added new session data into last summary result?\n','s');
if strcmpi(inputChoice,'y')
    [fnx,fpx,fix] = uigetfile('SessionDataSum.mat','Please load your last summary plot result');
    if fix
        load(fullfile(fpx,fnx));
        isOldLoad = 1;
    else
        isOldLoad = 0;
    end
else
    isOldLoad = 0;
end
if ~isOldLoad
    m = 1;
    datapath = {};
    DataSum = {};
    SumSessionData = {};
    SumSessionStim = {};
else
   m = length(DataSum) + 1;
end

while ~strcmpi(add_char,'n')
    [fn,fp,fi] = uigetfile('rfSelectDataSet.mat','Please select your ROI fraction based classification result save');
    if fi
        datapath{m} = fullfile(fp,fn);
        xx = load(fullfile(fp,fn));
        if length(xx.SelectSArray) < 80
            fprintf('Too few trials, skip this session.\n');
            continue;
        end
        DataSum{m} = xx;
        [DataOutput,SessionStim] = SessionDataExtra(xx.SelectData,ones(length(xx.SelectSArray),1),xx.SelectSArray,xx.frame_rate,...
            xx.frame_rate,[],30);
        SumSessionData{m} = reshape(permute(DataOutput,[2,1,3]),[],size(DataOutput,3)); % finally should be a 1 by m cell vector
        SumSessionStim{m} = SessionStim;
    end
    add_char = input('Do you want to add with more session data?\n','s');
    m = m + 1;
end
m = m - 1;

fp = uigetdir(pwd,'Please select a session to save your current data');
cd(fp);
f = fopen('Session_resp_path.txt','w');
fprintf(f,'Sessions path for response summary plot:\r\n');
FormatStr = '%s;\r\n';
for nbnb = 1 : m
    fprintf(f,FormatStr,datapath{nbnb});
end
fclose(f);
save SessionDataSum.mat DataSum SumSessionData SumSessionStim -v7.3
%%
SessionStimNum = cellfun(@length,SumSessionStim);
if length(unique(SessionStimNum)) > 1
    SelectStimLen = min(unique(SessionStimNum));
    OutlengthStimInds = SessionStimNum == SelectStimLen;
    SessionStimSelect = SumSessionStim(OutlengthStimInds);
    SessionDataSelect = SumSessionData(OutlengthStimInds);
else
    SessionStimSelect = SumSessionStim;
    SessionDataSelect = SumSessionData;
end
isequalStim = true(length(SessionStimSelect),1);
% for nxnx = 1 : length(SessionStimSelect)
%     if isequal(SessionStimSelect(nxnx),SessionStimSelect(1))
%         isequalStim(nxnx) = true;
%     end
% end
equalStimSession = SessionStimSelect(isequalStim);
equalDataSession = cell2mat(SessionDataSelect(isequalStim));

StimTypes = double(equalStimSession{1});
xtickStr = cellstr(num2str(StimTypes(:)/1000,'%.2f'));
StimNums = length(StimTypes);
disp(StimTypes);
StimDataSet = repmat((StimTypes(:))',30,1);
StimDataSet = StimDataSet(:);  % vector used for y input, corresponded to the input dataset

%%
nIters = 1000;
TainingFrac = 0.8;  % percent of trials used for model traing
PairNum = StimNums*(StimNums - 1)/2;
TestLossAll = zeros(PairNum,nIters);  % test data correct rate
ModelLossAll = zeros(PairNum,nIters); % model data correct rate
kk = 1;
for nxnx = 1 : StimNums
    for nmnm = (nxnx+1) : StimNums 
        cNegStim = StimTypes(nxnx);
        cPosStim = StimTypes(nmnm);
        NegStimDataInds = StimDataSet == cNegStim;
        PosStimDataInds = StimDataSet == cPosStim;
        SumStimInds = logical(NegStimDataInds + PosStimDataInds);
        CLFdata = equalDataSession(SumStimInds);
        CLFstim = StimDataSet(SumStimInds);
        nTrials = length(CLFdata);
        
        parfor nbnb = 1 : nIters
            TrainingInds = false(nTrials,1);
            TrainIndsReal = randsample(nTrials,round(nTrials*TainingFrac));
            TrainingInds(TrainIndsReal) = true;
            TestingInds = ~TrainingInds;
            PairCLFmodel = fitcsvm(CLFdata(TrainingInds,:),CLFstim(TrainingInds));
            ModelLoss = kfoldLoss(crossval(PairCLFmodel));
            ModelLossAll(kk,nbnb) = 1 - ModelLoss;
            TestPred = predict(PairCLFmodel,CLFdata(TestingInds,:));
            TestPerf = double(TestPred == CLFstim(TestingInds));
            TestLossAll(kk,nbnb) = sum(TestPerf)/length(TestPerf);
        end
        kk = kk + 1;
    end
end
save SumDataCLFSave.mat TestLossAll ModelLossAll StimTypes -v7.3
%%
% data plotting
MeanModelPerf = mean(ModelLossAll,2);
ModelPerfsem = std(ModelLossAll,[],2)/sqrt(size(ModelLossAll,2));
MeanTestPerf = mean(TestLossAll,2);
TestPerfsem = std(TestLossAll,[],2)/sqrt(size(TestLossAll,2));
ModelMatrix = squareform(MeanModelPerf);
TestPerfMatrix = squareform(MeanTestPerf);

h_model = figure('position',[200 200 950 850]);
imagesc(ModelMatrix);
h = colorbar;
% set(get(h,'title'),'string',{'Model';'Correct rate'});
set(gca,'xtick',1 : StimNums,'xticklabel',xtickStr,'ytick',1 : StimNums,'yticklabel',xtickStr);
xlabel('Fraquency (kHz)');
ylabel('Fraquency (kHz)');
title('Model classfication accuracy');
set(gca,'FontSize',20);
saveas(h_model,'Model perf color plot');
saveas(h_model,'Model perf color plot','png');

h_test = figure('position',[500 200 950 850]);
imagesc(TestPerfMatrix);
h = colorbar;
% set(get(h,'title'),'string',{'Test Data';'Correct rate'});
set(gca,'xtick',1 : StimNums,'xticklabel',xtickStr,'ytick',1 : StimNums,'yticklabel',xtickStr);
xlabel('Fraquency (kHz)');
ylabel('Fraquency (kHz)');
title('Test data classfication accuracy');
set(gca,'FontSize',20);
saveas(h_test,'Test perf color plot');
saveas(h_test,'Test perf color plot','png');
save MatrixDataSave.mat TestPerfMatrix ModelMatrix -v7.3

%%
% difference based classification error
% TargetMatrix = TestPerfMatrix(2:end-1,2:end-1);
TargetMatrix = TestPerfMatrix;
DisAccuracy = zeros((size(TargetMatrix,1) - 1),1);
for nDiff = 1 : (size(TargetMatrix,1) - 1)
    cDisdata = diag(TargetMatrix,nDiff);
    DisAccuracy(nDiff) = mean(cDisdata);
end

[~,~,~,~,hDiff] = lmFunCalPlot(1:length(DisAccuracy),DisAccuracy);
% corrcoef(1:length(DisAccuracy),DisAccuracy);
% hDiff = figure;
% plot(DisAccuracy,'-o','color',[.5 .5 .5],'LineWidth',1.8);
saveas(hDiff,'Octave Diff vs decoding accuracy');
saveas(hDiff,'Octave Diff vs decoding accuracy','png');
close(hDiff);
