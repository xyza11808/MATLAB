function TimeCourseChoiceDecod(SmoothedData,TrParameter,alignpoint,FrameRate,varargin)
% this function is tried to decode choice from current time bin across
% whole trial epoch, using formally trained choice decoding classifier
% 
% TrParameter: should be atleast a three columns variable, with the row
% number is the same as trial number. the first column is the trial types;
% the second column is the trial outcomes; the third column is the trial
% frequencies; the fourth columns is the trial choice
% more columns will not be processed for now
%
% XIN Yu, 4,May, 2017
TrFreqs = TrParameter(:,3);
TrOutcome = TrParameter(:,2);
TrTypes= TrParameter(:,1);
TrChoice = TrParameter(:,4); 

if isempty(varargin) || isempty(varargin{1})
    TimeBins=100;  %ms
else
    TimeBins=varargin{1};
end
IsMdlGiven = 0;
IsSelfTrain = 0;
if nargin > 5
    if ~isempty(varargin{2})
        if isdouble(varargin{2})
            IsSelfTrain = varargin{2};
        else
            ExternalMdl = varargin{2};
            IsMdlGiven = 1;
            
            if ~isdir('./InputTrainModel_save/')
                mkdir('./InputTrainModel_save/');
            end
            cd('./InputTrainModel_save/');
        end
    end
end
if IsSelfTrain
    % training a classifier using given dataset
   FrameScales = [alignpoint+1,alignpoint+round(1.5*FrameRate)];
   DataResp = max(SmoothedData(:,:,FrameScales(1):FrameScales(2)),[],3);
   NonMissTrs = TrChoice ~= 2;
   ChoiceDeMdl = fitcsvm(DataResp(NonMissTrs,:),TrChoice(NonMissTrs));
   ErrorRate = kfoldLoss(crossval(ChoiceDeMdl));
   fprintf('The model classification correct rate is %.3f',1-ErrorRate);
   ExternalMdl = ChoiceDeMdl;
    IsMdlGiven = 0;
    
    if ~isdir('./SelfTrainModel_save/')
        mkdir('./SelfTrainModel_save/');
    end
    cd('./SelfTrainModel_save/');
else
    IsMdlGiven = 1;
end

if ~IsMdlGiven
    [fn,fp,fi] = uigetfile('Clfsave.mat','Please select the file that contains classification model');
    if ~fi
        return;
    else
        fpath = fullfile(fp,fn);
        Modelfile = load(fpath);
        ExternalMdl = Modelfile.mdl;
    end
     if ~isdir('./ExterTrainModel_save/')
        mkdir('./ExterTrainModel_save/');
    end
    cd('./ExterTrainModel_save/');
end     

FrameBin=round((TimeBins/1000)*FrameRate);
TimeBins = (FrameBin / FrameRate)*1000;
fprintf('Real Timebin value is %.4fms.\n',TimeBins);
DatSize=size(SmoothedData);

% BeforeBinNum = floor(alignpoint/FrameBin);
BeforeBinInds = alignpoint:-FrameBin:1;
if BeforeBinInds(end) ~= 1
    BeforeBinInds(end) = 1; % including the last few frames into the same frame bin, but not one single bin along
end
BeforeBinInds = fliplr(BeforeBinInds);
BeforeBinNum = length(BeforeBinInds)-1; % bin inds number minus 1
AfterBinInds = (alignpoint+1):FrameBin:DatSize(3);
if AfterBinInds(end) ~= DatSize(3)
    AfterBinInds(end) = DatSize(3); % set the remain frames into the last framebin, do not given extra bin number
end
AfterBinNum = length(AfterBinInds)-1;
BinLength = BeforeBinNum + AfterBinNum;
BinIndsAll = [BeforeBinInds,AfterBinInds(2:end)]; % at the alignpoint the after bin inds should started with alignpoint+1
PredScoreAll = zeros(DatSize(1),BinLength);
PredClass = zeros(DatSize(1),BinLength);
for cTr = 1 : DatSize(1)
    for cBin = 1 : BinLength
        if cBin == (BeforeBinNum+1)
            cTrData = squeeze(SmoothedData(cTr,:,(BinIndsAll(cBin)+1):BinIndsAll(cBin+1)));
        else
            cTrData = squeeze(SmoothedData(cTr,:,(BinIndsAll(cBin)):BinIndsAll(cBin+1)));
        end
        CellRespPattern = (max(cTrData,[],2))';
        DataScore = CellRespPattern * ExternalMdl.Beta + ExternalMdl.Bias;
        if DataScore <= 0
            Classlabel = ExternalMdl.ClassNames(1);
        else
            Classlabel = ExternalMdl.ClassNames(2);
        end
        PredScoreAll(cTr,cBin) = DataScore;
        PredClass(cTr,cBin) = Classlabel;
    end
end

save TimeCourPredSave.mat ExternalMdl BeforeBinNum AfterBinNum BinIndsAll PredScoreAll PredClass -v7.3
%%
PXtick = ((BinIndsAll(1:end-1)+BinIndsAll(2:end))/2);
% PXtick = FrameBin:FrameBin:(DatSize(3));
AlignTime = alignpoint/FrameRate;
% AlignBin = alignpoint/FrameBin;
AlignBin = BeforeBinNum+0.5;
% PXtick(1)=[];
PXtickTime=PXtick/FrameRate - AlignTime; % set alignment time into 0

% plot each frequency types choice change across time
hfAll = figure('position',[200 100 1600 950]);
TrTypenames = {'Error','Correct','Miss'};
FreqTypes = unique(TrFreqs);
nFreqs = length(FreqTypes);
for cFreq = 1 : nFreqs
    cFreqInds = TrFreqs == FreqTypes(cFreq);
    cFreqScores = PredScoreAll(cFreqInds,:);
    cFreqChoice = TrOutcome(cFreqInds,:);
    
    for nChoice = 0:2
        cSubInds = cFreq + nChoice * nFreqs;
        cChoiceInds = cFreqChoice == nChoice;
        cChoiceScores = cFreqScores(cChoiceInds,:);
        
        subplot(3,nFreqs,cSubInds)
        hold on
        plot(repmat(PXtickTime(:),1,size(cChoiceScores,1)),cChoiceScores','color',[.6 .6 .6],'linewidth',0.8);
        plot(PXtickTime,mean(cChoiceScores),'k','LineWidth',2);
        yscales = get(gca,'ylim');
        line([0 0],yscales,'Color',[.7 .7 .7],'linewidth',1.6,'linestyle','--');
        set(gca,'ylim',yscales);
        if nChoice == 0
            title(sprintf('Freq = %dHz',FreqTypes(cFreq)));
        end
        if cFreq == 1
            ylabel(TrTypenames{nChoice+1});
%         else
%             set(gca,'yticklabel','');
        end
        if nChoice == 2
            xlabel('Time (s)');
        else
            set(gca,'xticklabel','');
        end
        
        set(gca,'FontSize',18,'xlim',[-2 9]);
    end
end
%
saveas(hfAll,'Type Score Plot save');
saveas(hfAll,'Type Score Plot save','png');
saveas(hfAll,'Type Score Plot save','pdf');
close(hfAll);

cd ..;