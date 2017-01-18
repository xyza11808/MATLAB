function varargout = ReomitPlot(AllData,OmitInds,TrialResult,TrialType,TimeAnswer,TimeOnset,FrameRate,varargin)
% this function is another function that will be used for plotting the
% reward omit trials for comparation with normal trials, using a simplified
% methods than other function: RewardOmitPlot
isplot = 1;
if ~isempty(varargin)
    isplot = varargin{1};
end

CorrectInds = TrialResult == 1;
OmitInds = OmitInds(CorrectInds);
TrialType = TrialType(CorrectInds);
TimeAnswer = TimeAnswer(CorrectInds);
TimeOnset = TimeOnset(CorrectInds);
DataSelected = AllData(CorrectInds,:,:);

TimeAnswerF = round(double(TimeAnswer)/1000*FrameRate);
TimeOnsetF = round(double(TimeOnset)/1000*FrameRate);
[AllTrials,nROIs,nFrames] = size(DataSelected);
%%
% align all data to sound onset
AlignedFrame = min(TimeOnsetF);
FrameAdjust = TimeOnsetF - AlignedFrame;
AlFrameLength = nFrames - max(FrameAdjust) - 1;
RewardFAfAdjusted = TimeAnswerF - FrameAdjust;

AlignedDataSet = zeros(AllTrials,nROIs,AlFrameLength);
for ntrials = 1 : AllTrials
    AlignedDataSet(ntrials,:,:) = DataSelected(ntrials,:,FrameAdjust(ntrials)+1:FrameAdjust(ntrials)+AlFrameLength);
end
[AnsSortedF,AnsSortedInds] = sort(RewardFAfAdjusted);
AnsSortedData = AlignedDataSet(AnsSortedInds,:,:);
TrialTypes = TrialType(AnsSortedInds);
OmitInds = OmitInds(AnsSortedInds);

%%
% Inds arrangements for all Plot types
LeftNorInds = TrialTypes == 0 & OmitInds == 0;
LeftOmitInds = TrialTypes == 0 & OmitInds == 1;
RightNorInds = TrialTypes == 1 & OmitInds == 0;
RightOmitInds = TrialTypes == 1 & OmitInds == 1;

% give the dataset that aligned to answer frame
AnsAlignAdjust = min(AnsSortedF);
AnsAlignFrame = AnsAlignAdjust + AlignedFrame;
AnsFrameAdjust = AnsSortedF - AnsAlignAdjust;
AnsAlignFrameLength = AlFrameLength - max(AnsFrameAdjust) - 1;
AnsAlignData = zeros(AllTrials,nROIs,AnsAlignFrameLength);
for nTr = 1 : AllTrials
    AnsAlignData(nTr,:,:) = AlignedDataSet(nTr,:,AnsFrameAdjust(nTr)+1:AnsFrameAdjust(nTr)+AnsAlignFrameLength);
end
% data set AnsAlignData will only be used for calculating the mean trace
% aligned to answer time and its sem, but also will be saved for any
% further analysis

%%
% plot current results
ROIclimAll = zeros(nROIs,2);
xtick = 1:FrameRate:AlFrameLength;
xticklabel = xtick/FrameRate;
xt = 1:AlFrameLength/FrameRate;  % time x value for sound onset alignment data
ansXt = (1:AnsAlignFrameLength)/FrameRate;  % time x value for answer time alignment data
AnsAlignT = AnsAlignFrame/FrameRate;
ROImeanSemDataLeft = zeros(nROIs,4,AnsAlignFrameLength);  %first column for mean. and second column for sem
ROImeanSemDataRight = zeros(nROIs,4,AnsAlignFrameLength);  
if isplot
    if ~isdir('./Reward_omit_simPlot')
        mkdir('./Reward_omit_simPlot');
    end
    cd('./Reward_omit_simPlot');
end
for nROI = 1 : nROIs
    cAnsSortedData = AnsSortedData(:,nROI,:);
    cAnsAlignedData = AnsAlignData(:,nROI,:);
    clim(1) = max(0,min(cAnsSortedData(:)));
    clim(2) = min(300,max(cAnsSortedData(:)));
    ROIclimAll(nROI,:) = clim;
    if isplot
        h_reOmit = figure('position',[100,100,1200,1000],'paperpositionmode','auto');
        % plot the left normal trials
        subplot(3,2,1)
        cLeftNorData = cAnsSortedData(LeftNorInds,:);
        cLeftAnsF = AnsSortedF(LeftNorInds);
        imagesc(cLeftNorData,clim);
        for nn = 1 : length(cLeftAnsF)
            line([cLeftAnsF(nn) cLeftAnsF(nn)],[nn-0.5 nn+0.5],'Color',[0.8,0,0.8],'LineWidth',2);
        end
        line([AlignedFrame AlignedFrame],[0.5 nn+0.5],'Color',[.8 .8 .8],'LineWidth',1.6);
        set(gca,'xtick',xtick,'xticklabel',xticklabel);
        xlabel('Time (s)');
        ylabel('# Trials');
        title('Left Normal Trials');
        set(gca,'FontSize',20);
        
        % plot the right Normal trials
        subplot(3,2,2)
        cRightNorData = cAnsSortedData(RightNorInds,:);
        cRightAnsF = AnsSortedF(RightNorInds);
        imagesc(cRightNorData,clim);
        for nn = 1 : length(cLeftAnsF)
            line([cRightAnsF(nn) cRightAnsF(nn)],[nn-0.5 nn+0.5],'Color',[0.8,0,0.8],'LineWidth',2);
        end
        line([AlignedFrame AlignedFrame],[0.5 nn+0.5],'Color',[.8 .8 .8],'LineWidth',1.6);
        set(gca,'xtick',xtick,'xticklabel',xticklabel);
        xlabel('Time (s)');
        ylabel('# Trials');
        title('Right Normal Trials');
        set(gca,'FontSize',20);
        
        % plot the left rewad omit correct trials
        subplot(3,2,3)
        cLeftOmitData = cAnsSortedData(RightNorInds,:);
        cLeftOmitAnsF = AnsSortedF(RightNorInds);
        imagesc(cLeftOmitData,clim);
        for nn = 1 : length(cLeftAnsF)
            line([cLeftOmitAnsF(nn) cLeftOmitAnsF(nn)],[nn-0.5 nn+0.5],'Color',[0.8,0,0.8],'LineWidth',2);
        end
        line([AlignedFrame AlignedFrame],[0.5 nn+0.5],'Color',[.8 .8 .8],'LineWidth',1.6);
        set(gca,'xtick',xtick,'xticklabel',xticklabel);
        xlabel('Time (s)');
        ylabel('# Trials');
        title('Left Omit Trials');
        set(gca,'FontSize',20);
        
        % plot the right omit trials
        subplot(3,2,4)
        cRightOmitData = cAnsSortedData(RightNorInds,:);
        cRightOmitAnsF = AnsSortedF(RightNorInds);
        imagesc(cRightOmitData,clim);
        for nn = 1 : length(cLeftAnsF)
            line([cRightOmitAnsF(nn) cRightOmitAnsF(nn)],[nn-0.5 nn+0.5],'Color',[0.8,0,0.8],'LineWidth',2);
        end
        line([AlignedFrame AlignedFrame],[0.5 nn+0.5],'Color',[.8 .8 .8],'LineWidth',1.6);
        set(gca,'xtick',xtick,'xticklabel',xticklabel);
        xlabel('Time (s)');
        ylabel('# Trials');
        title('Right Omit Trials');
        set(gca,'FontSize',20);
    end
    
        
        LeftAnsAlNorData = cAnsAlignedData(LeftNorInds,:);
        LeftAnsOmitData = cAnsAlignedData(LeftOmitInds,:);
        LeftNorMean = mean(LeftAnsAlNorData);
        LeftNorSem = std(LeftAnsAlNorData)/sqrt(size(LeftAnsAlNorData,1));
        LeftOmitMean = mean(LeftAnsOmitData);
        LeftOmitSem = std(LeftAnsOmitData)/sqrt(size(LeftAnsOmitData,1));
        xPatchtick = [ansXt flipud(ansXt)];
        LeftNorPatch = [LeftNorMean+LeftNorSem,flipud(LeftNorMean-LeftNorSem)];
        LeftOmitPatch = [LeftOmitMean+LeftOmitSem,flipud(LeftOmitMean-LeftOmitSem)];
        ROImeanSemDataLeft(nROI,1,:) = LeftNorMean;
        ROImeanSemDataLeft(nROI,2,:) = LeftNorSem;
        ROImeanSemDataLeft(nROI,3,:) = LeftOmitMean;
        ROImeanSemDataLeft(nROI,4,:) = LeftOmitSem;
        
       if isplot 
            % plot the left normal and omit mean trace, aligned to answer time
            subplot(3,2,5)
            hold on;
            h1 = plot(ansXt,LeftNorMean,'b','LineWidth',1.5);
            h2 = plot(ansXt,LeftOmitMean,'Color',[1,0,1],'LineWidth',1.5);
            patch(xPatchtick,LeftNorPatch,1,'FaceColor',[.8 .8 .8],'EdgeColor','None','FaceAlpha',0.8);
            patch(xPatchtick,LeftOmitPatch,1,'FaceColor',[.8 .8 .8],'EdgeColor','None','FaceAlpha',0.8);
            legend([h1,h2],'Reward','Reward Omit');
            yaxis = axis;
            line([AnsAlignT AnsAlignT],[yaxis(3) yaxis(4)],'Color',[.8 .8 .8],'LineWidth',1.6);
            xlabel('Time (s)');
            ylabel('Mean \DeltaF/F_0 (%)');
            title('Left Mean reward and reward omit');
       end
        
        RightAnsAlNorData = cAnsAlignedData(RightNorInds,:);
        RightAnsOmitData = cAnsAlignedData(RightOmitInds,:);
        RightNorMean = mean(RightAnsAlNorData);
        RightNorSem = std(RightAnsAlNorData)/sqrt(size(RightAnsAlNorData,1));
        RightOmitMean = mean(RightAnsOmitData);
        RightOmitSem = std(RightAnsOmitData)/sqrt(size(RightAnsOmitData,1));
        xPatchtick = [ansXt flipud(ansXt)];
        RightNorPatch = [RightNorMean+RightNorSem,flipud(RightNorMean-RightNorSem)];
        RightOmitPatch = [RightOmitMean+RightOmitSem,flipud(RightOmitMean-RightOmitSem)];
        ROImeanSemDataRight(nROI,1,:) = RightNorMean;
        ROImeanSemDataRight(nROI,2,:) = RightNorSem;
        ROImeanSemDataRight(nROI,3,:) = RightOmitMean;
        ROImeanSemDataRight(nROI,4,:) = RightOmitSem;
        
        if isplot
            % plot the right normal and omit mean trace, aligned to answer time
            subplot(3,2,6)
            hold on;
            h1 = plot(ansXt,RightNorMean,'r','LineWidth',1.5);
            h2 = plot(ansXt,RightOmitMean,'Color','k','LineWidth',1.5);
            patch(xPatchtick,RightNorPatch,1,'FaceColor',[.8 .8 .8],'EdgeColor','None','FaceAlpha',0.8);
            patch(xPatchtick,RightOmitPatch,1,'FaceColor',[.8 .8 .8],'EdgeColor','None','FaceAlpha',0.8);
            legend([h1,h2],'Reward','Reward Omit');
            yaxis = axis;
            line([AnsAlignT AnsAlignT],[yaxis(3) yaxis(4)],'Color',[.8 .8 .8],'LineWidth',1.6);
            xlabel('Time (s)');
            ylabel('Mean \DeltaF/F_0 (%)');
            title('Right Mean reward and reward omit');

            saveas(h_reOmit,sprintf('ROI%d reward omit plot',nROI));
            saveas(h_reOmit,sprintf('ROI%d reward omit plot',nROI),'png');
            close(h_reOmit);
        end
end
if isplot
    cd ..;
end
if nargout > 0
    ReOmitStrc.AllLeftNorData = permute(AnsSortedData(LeftNorInds,:,:),[2,1,3]);
    ReOmitStrc.AllRightNorData = permute(AnsSortedData(RightNorInds,:,:),[2,1,3]);
    ReOmitStrc.AllLeftOmitData = permute(AnsSortedData(LeftOmitInds,:,:),[2,1,3]);
    ReOmitStrc.AllRightOmitData = permute(AnsSortedData(RightOmitInds,:,:),[2,1,3]);
    ReOmitStrc.LeftNorAnsF = AnsSortedF(LeftNorInds);
    ReOmitStrc.LeftOmitAnsF = AnsSortedF(LeftOmitInds);
    ReOmitStrc.RightNorAnsF = AnsSortedF(RightNorInds);
    ReOmitStrc.RightOmitAnsF = AnsSortedF(RightOmitInds);
    ReOmitStrc.LeftAnsAlMeanTrace = ROImeanSemDataLeft;
    ReOmitStrc.RightAnsAlMeanTrace = ROImeanSemDataRight;
    ReOmitStrc.AlignedF = AlignedFrame;
    ReOmitStrc.Climall = ROIclimAll;
    ReOmitStrc.AnsAlignF = AnsAlignFrame;
    varargout(1) = {ReOmitStrc};
end