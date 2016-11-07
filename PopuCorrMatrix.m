function PopuCorrMatrix(RawData,EventsTime,TrialTypes,TrialOutcomes,TimeScale,FrameRate,varargin)
% this function is tried to calculate a correlation matrix for each trial,
% and try to see whether there are some patterns that can be used for trial
% type classification
% using so for every trial we can get a nROI*(nROI-1)/2 dimension point and
% that will be used for classification
UsingTrialType = 1;
if ~isempty(varargin)
    UsingTrialType = varargin{1};
end
if UsingTrialType == 1
    UsingTrialInds = TrialOutcomes == 1;
elseif UsingTrialType == 0
    UsingTrialInds = true(length(TrialOutcomes),1);
else
    UsingTrialInds = TrialOutcomes ~= 1;
end
UsingData = RawData(UsingTrialInds,:,:);
UsingTrialtype = TrialTypes(UsingTrialInds);
AllTrialType = unique(UsingTrialtype);
nTrialType = length(AllTrialType);
[nTrials,nROIs,nFrames] = size(UsingData);

AllFrameUsage = 0;
if length(TimeScale) == 1
    ConsiFrame = round(TimeScale*FrameRate);
    if (max(EventsTime)+ConsiFrame) >= nFrames
        ConsiFrame = nFrames - max(EventsTime) - 1;
    end
    FrameScale = [1 ConsiFrame];
elseif length(TimeScale) == 2
    ConsiFrame = round(TimeScale*FrameRate);
    if (max(EventsTime)+ConsiFrame(2)) >= nFrames
        ConsiFrame(2) = nFrames - max(EventsTime) - 1;
    end
    if (min(EventsTime)+ConsiFrame(1)) <= 1
        ConsiFrame(1) = min(EventsTime) - 2;
    end
    if ConsiFrame(2) <= ConsiFrame(1)
        fprintf('Input time scale out matrix index, please check your input, quit analysis.\n');
    end
    FrameScale = ConsiFrame;
elseif isempty(TimeScale)
    AllFrameUsage = 1;
end

TrCorrCoefSet = zeros(nTrials,nROIs,nROIs);
TrCoefVector = zeros(nTrials,nROIs*(nROIs-1)/2);
TriuMask = logical(triu(ones(nROIs,nROIs),1));
for nTr = 1 : nTrials
    cEventFrame = EventsTime(nTr);
    if AllFrameUsage
        cTrData = squeeze(UsingData(nTr,:,:));
    elseif ~AllFrameUsage
        cTrData = squeeze(UsingData(nTr,:,(FrameScale(1)+cEventFrame):(FrameScale(2)+cEventFrame)));
    end
    CoefMatrix = corrcoef(cTrData');
    TrCorrCoefSet(nTr,:,:) = CoefMatrix;
    TrCoefVector(nTr,:) = CoefMatrix(TriuMask);
end

if ~isdir('./Popu_CorrelationMatrix_plot/')
    mkdir('./Popu_CorrelationMatrix_plot/');
end
cd('./Popu_CorrelationMatrix_plot/');

    if nTrialType == 2
        hMatrixcoef = figure('position',[360,120,1100,920],'Paperpositionmode','auto');
    elseif nTrialType >= 6
        hMatrixcoef = figure('position',[130,110,1600,650],'Paperpositionmode','auto');
    end
    TypeStr = {'Left','Right'};
    for cType = 1 : nTrialType
        cTypeValue = AllTrialType(cType);
        cTypeCoefData = TrCoefVector(UsingTrialtype == cTypeValue,:);

        axs = subplot(1,nTrialType,cType);
        imagesc(cTypeCoefData',[-1 1]);
        xlabel('# Trials');
        ylabel('ROI pairs');
        if nTrialType == 2
            title(TypeStr{cType+1});
        else
            title(sprintf('%d Hz',cTypeValue));
        end
        set(gca,'FontSize',18);
    end
    axPos = get(axs,'position');
    colorbar;
    set(axs,'position',axPos);
    annotation('textbox',[0.44,0.685,0.3,0.3],'String','Trial coef matrix','FitBoxToText','on','EdgeColor',...
                    'none','FontSize',20);
    saveas(hMatrixcoef,'Trial Corrceof Matrix Plot');
    saveas(hMatrixcoef,'Trial Corrceof Matrix Plot','png');
    close(hMatrixcoef);

    if nTrialType == 2
        TrialClass = double(UsingTrialtype);
    else
        TrialClass = double(UsingTrialtype > AllTrialType(nTrialType/2));
    end
    % TrCoefVector = zeros(nTrials,nROIs*(nROIs-1)/2);
    TrainSetInds = false(length(TrialClass),1);
    RandInds = randsample(length(TrialClass),round(0.8*length(TrialClass)));
    TrainSetInds(RandInds) = true;
    TestSetInds = ~TrainSetInds;
    SVModel = fitcsvm(TrCoefVector(TrainSetInds),TrialClass(TrainSetInds));
    ModelLoss = kfoldLoss(crossval(SVModel));
    performPred = predict(SVModel,TrCoefVector(TestSetInds));
    ErrorRate = sum(abs(double(TrialClass(TestSetInds)) - performPred'))/length(performPred);
    fprintf('Testing data error rate is %.3f',ErrorRate);

    save CorrMatrixSave.mat TrCoefVector TrCorrCoefSet SVModel TrialClass TrainSetInds TestSetInds ErrorRate -v7.3
    
    %%
    % using clustering method to try to analysis the high dimensional data
    % clustering and try to find whether thhis clustering can be
    % corresponded withi actual behavior types
    CPUCores=str2num(getenv('NUMBER_OF_PROCESSORS')); %#ok<ST2NM>
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        parpool('local',CPUCores);
    %     poolobj = gcp('nocreate');
    end
    options = statset('UseParallel',1);
    CentroidData = cell(9,4);
    TotalWithinDis = zeros(9,1);
    for ncluater = 2 : 10
        [idx,Centers,sumd,D] = kmeans(TrCoefVector,ncluater,'Options',options,'MaxIter',10000,...
            'Display','final','Replicates',20);
        CentroidData(ncluater-1,:) = {idx,Centers,sumd,D};
        TotalWithinDis(ncluater-1) = sum(sumd);
    end
    [MinDis,Inds] = min(TotalWithinDis);
    fprintf('Min within cluster distance is %.5e with %d cluster exists',MinDis,Inds+1);
    [idx,Centers,sumd,D] = deal(CentroidData{nTrialType-1,:});
    ClusterNum = nTrialType;
    %%
    cTypeClass = cell(nTrialType,1);
    NumEachClass = zeros(nTrialType,ClusterNum);
    for ntype = 1 : nTrialType
        cTypeValue = AllTrialType(ntype);
        cTypeInds = UsingTrialtype == cTypeValue;
        cTypeClass{ntype} = idx(cTypeInds);
        for ncluster = 1 : ClusterNum
            NumEachClass(ntype,ncluster) = sum(idx(cTypeInds) == ncluster);
        end
    end
    h_typecluster = figure('position',[450 300 900 740]);
    bar(NumEachClass,'stacked');
    if nTrialType == 2
        set(gca,'xtick',[1,2],'xticklabel',{'Left','Right'});
        xlabel('Trial Types');
        ylabel('Class Count');
    else
        AllTrialTypes = reshape(double(AllTrialType)/1000,[],1);
        set(gca,'xtick',1:nTrialType,'xticklabel',cellstr(num2str(AllTrialTypes,'%.2f')));
        xlabel('Frequency (kHz)');
        ylabel('Class Count');
    end
    title('Trial type class distribution');
    %%
    saveas(h_typecluster,'Clustering of current trial types');
    saveas(h_typecluster,'Clustering of current trial types','png');
    close(h_typecluster);
    save ClusterResult.mat idx Centers sumd D ClusterNum -v7.3
cd ..;
