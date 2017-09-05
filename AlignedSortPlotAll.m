function AlignedSortPlotAll(RawData,BehavStrc,Frate,RewardTime,varargin)
% Function used for plot ROI response for each frequency and outcome
% combination
IsLickPlot = 0;
if nargin > 4
    if ~isempty(varargin{1})
        LickTimeStrc = varargin{1};
        IsLickPlot = 1;
    end
end
IsTrIndsInput = 0;
if nargin > 5
    if ~isempty(varargin{2})
        UsedTrInds = varargin{2};
        IsTrIndsInput = 1;
    end
end
AlignLickFStrc = LickTimeStrc;
[AllTrNum,ROInum,FrameNum] = size(RawData);
TrStimOnset = double(BehavStrc.Time_stimOnset);
TrTypes = double(BehavStrc.Trial_Type);
TrAnsTime = double(BehavStrc.Time_answer);
TrChoice = double(BehavStrc.Action_choice);
TrStimFreq = double(BehavStrc.Stim_toneFreq);

if IsTrIndsInput
    AllTrInds = false(length(TrStimOnset),1);
    AllTrInds(UsedTrInds) = true;
    TrStimOnset = TrStimOnset(AllTrInds);
    TrTypes = TrTypes(AllTrInds);
    TrAnsTime = TrAnsTime(AllTrInds);
    TrChoice = TrChoice(AllTrInds);
    TrStimFreq = TrStimFreq(AllTrInds);
    RewardTime = RewardTime(AllTrInds);
    RawData = RawData(AllTrInds,:,:);
    [AllTrNum,ROInum,FrameNum] = size(RawData);
end
    
TrOutcome = double(TrTypes == TrChoice);  
TrOutcome(TrChoice == 2) = 2;

FreqTypes = unique(TrStimFreq);
NumFreq = length(FreqTypes);
if NumFreq == 2
    fprintf('Normal 2afc session data plot.\n');
    SessionDesp = 'NormAFC';
elseif NumFreq == 6 || NumFreq == 8
    fprintf('Random puretone session with %d frequencies.\n',NumFreq);
    SessionDesp = 'RandomTone';
elseif mod(NumFreq,2) == 1 && NumFreq > 1
    fprintf('Boundary Tone session with %d frequencies.\n',NumFreq);
    SessionDesp = 'BoundTone';
else
    warning('Unknowing session type, current session have %d tones.\n');
    disp(FreqTypes);
    fprintf('\n');
    SessionDesp = 'undefined';
end
%%
MinStimOnsetTime = min(TrStimOnset);
TrTimeDiff = TrStimOnset - MinStimOnsetTime;
TrFrameDiff = round(TrTimeDiff/1000*Frate);
LickFrameDiff = (TrTimeDiff/1000*Frate);
AnsTimeAdj = max(TrAnsTime(:) - TrTimeDiff(:),0);
RewawrdTAdj = max(RewardTime(:) - TrTimeDiff(:),0);
% StimOnAlignF = round(MinStimOnsetTime/1000*Frate);
AnsAdjFrame = round(AnsTimeAdj/1000*Frate);
RewardAdjFrame = round(RewawrdTAdj/1000*Frate);

AlignFrameLen = FrameNum - max(TrFrameDiff);
AlignData = zeros(AllTrNum,ROInum,AlignFrameLen);
for nTr = 1 : AllTrNum
    cTrData = squeeze(RawData(nTr,:,:));
    AlignData(nTr,:,:) = cTrData(:,(TrFrameDiff(nTr)+1):(TrFrameDiff(nTr)+AlignFrameLen));
    AlignLickFStrc(nTr).Action_LeftLick_frame = AlignLickFStrc(nTr).Action_LeftLick_frame - LickFrameDiff(nTr);
    AlignLickFStrc(nTr).Action_RightLick_frame = AlignLickFStrc(nTr).Action_RightLick_frame - LickFrameDiff(nTr);
    if ~isempty(AlignLickFStrc(nTr).Action_LeftLick_frame)
        ExcludeInds = (AlignLickFStrc(nTr).Action_LeftLick_frame < 1) | (AlignLickFStrc(nTr).Action_LeftLick_frame > AlignFrameLen);
        AlignLickFStrc(nTr).Action_LeftLick_frame(ExcludeInds) = [];
    end
    if ~isempty(AlignLickFStrc(nTr).Action_RightLick_frame)
       ExcludeInds = (AlignLickFStrc(nTr).Action_RightLick_frame < 1) | (AlignLickFStrc(nTr).Action_RightLick_frame > AlignFrameLen);
        AlignLickFStrc(nTr).Action_RightLick_frame(ExcludeInds) = [];
    end 
end
AlignedFrame = (MinStimOnsetTime/1000*Frate);
SoundOffFrame = ((MinStimOnsetTime/1000)+0.3)*Frate;
AlignXtick = 0:Frate:AlignFrameLen;
AlignxtickLabel = AlignXtick/Frate;
%%
FreqTypeEventF = cell(NumFreq,3);
AnsFIndsSort = cell(NumFreq,2);
AlignLickStrc = cell(NumFreq,4);  % correct and error lick pattern
for cFreqType = 1 : NumFreq
    cFreqInds = TrStimFreq == FreqTypes(cFreqType);
    cFreqOutcome = TrOutcome(cFreqInds);
    cFreqAnsF = AnsAdjFrame(cFreqInds);
    cFreqReF = RewardAdjFrame(cFreqInds);
    cFreqLickStrc = AlignLickFStrc(cFreqInds);
    
    ErrorOutAnsF = cFreqAnsF(cFreqOutcome == 0);
    CorrOutAnsF = cFreqAnsF(cFreqOutcome == 1);
    CorrOutReF = cFreqReF(cFreqOutcome == 1);
%     LeftLickStrcCorrF = AlignLickFStrc(cFreqOutcome == 1).Action_LeftLick_frame;
%     LeftLickStrcErroF = AlignLickFStrc(cFreqOutcome == 0).Action_LeftLick_frame;
%     RightLickStrcCorrF = AlignLickFStrc(cFreqOutcome == 1).Action_RightLick_frame;
%     RightLickStrcErroF = AlignLickFStrc(cFreqOutcome == 0).Action_RightLick_frame;
    CorrLickStrc = cFreqLickStrc(cFreqOutcome == 1);
    ErroLickStrc = cFreqLickStrc(cFreqOutcome == 0);
    
    [ErrorOutAnsF,ErrorAnsIndsSort] = sort(ErrorOutAnsF);
    [CorrOutAnsF,corrAnsIndsSort] = sort(CorrOutAnsF);
    
    CorrSortReF = CorrOutReF(corrAnsIndsSort);
    ErroTrIndsNum = length(ErrorOutAnsF);
    CorrTrIndsNum = length(CorrOutAnsF);
    ErrorTrXData = reshape(([ErrorOutAnsF(:),ErrorOutAnsF(:),nan(ErroTrIndsNum,1)])',[],1);
    ErrorTrYData = reshape([(1:ErroTrIndsNum)-0.5;(1:ErroTrIndsNum)+0.5;nan(1,ErroTrIndsNum)],[],1);
    
    CorrTrAnsFXData = reshape(([CorrOutAnsF(:),CorrOutAnsF(:),nan(CorrTrIndsNum,1)])',[],1);
    CorrTrAnsFYData = reshape([(1:CorrTrIndsNum)-0.5;(1:CorrTrIndsNum)+0.5;nan(1,CorrTrIndsNum)],[],1);
    
    CorrSortReF(CorrSortReF == 0) = nan;
    CorrTrReFXData = reshape(([CorrSortReF(:),CorrSortReF(:),nan(CorrTrIndsNum,1)])',[],1);
    CorrTrReFYData = reshape([(1:CorrTrIndsNum)-0.5;(1:CorrTrIndsNum)+0.5;nan(1,CorrTrIndsNum)],[],1);
%     SortLeftLickStrcCorrF = LeftLickStrcCorrF(corrAnsIndsSort);
%     SortRightLickStrcCorrF = RightLickStrcCorrF(corrAnsIndsSort);
%     SortLeftLickStrcErroF = LeftLickStrcErroF(ErrorAnsIndsSort);
%     SortRightLickStrcErroF = RightLickStrcErroF(ErrorAnsIndsSort);
    SortCorrLickStrc = CorrLickStrc(corrAnsIndsSort);
    SortErroLickStrc = ErroLickStrc(ErrorAnsIndsSort);
    
    LeftCorrLick = [0;0];
    RightCorrLick = [0;0];
    for ncCorrTr = 1 : CorrTrIndsNum
        cTrLeftLick = SortCorrLickStrc(ncCorrTr).Action_LeftLick_frame;
        cTrRightLick = SortCorrLickStrc(ncCorrTr).Action_RightLick_frame;
        if ~isempty(cTrLeftLick)
            AddLeftLick = [(cTrLeftLick(:))';ncCorrTr*ones(1,length(cTrLeftLick))];
            LeftCorrLick = [LeftCorrLick,AddLeftLick];
        end
        if ~isempty(cTrRightLick)
            AddRightLick = [(cTrRightLick(:))';ncCorrTr*ones(1,length(cTrRightLick))];
            RightCorrLick = [RightCorrLick,AddRightLick];
        end
    end
    
    LeftErroLick = [0;0];
    RightErroLick = [0;0];
    for ncErroTr = 1 : ErroTrIndsNum
        cTrLeftLick = SortErroLickStrc(ncErroTr).Action_LeftLick_frame;
        cTrRightLick = SortErroLickStrc(ncErroTr).Action_RightLick_frame;
        if ~isempty(cTrLeftLick)
            AddLeftLick = [(cTrLeftLick(:))';ncErroTr*ones(1,length(cTrLeftLick))];
            LeftErroLick = [LeftErroLick,AddLeftLick];
        end
        if ~isempty(cTrRightLick)
            AddRightLick = [(cTrRightLick(:))';ncErroTr*ones(1,length(cTrRightLick))];
            RightErroLick = [RightErroLick,AddRightLick];
        end
    end
%     CorrTrReFXData(CorrSortReF == 0,1:2) = nan;
%     CorrTrReFYData(CorrSortReF == 0,1:2) = nan;
    AnsFIndsSort{cFreqType,1} = ErrorAnsIndsSort;
    AnsFIndsSort{cFreqType,2} = corrAnsIndsSort;
    FreqTypeEventF{cFreqType,3} = [ErrorTrXData,ErrorTrYData];
    FreqTypeEventF{cFreqType,1} = [CorrTrAnsFXData,CorrTrAnsFYData];
    FreqTypeEventF{cFreqType,2} = [CorrTrReFXData,CorrTrReFYData];
    
    AlignLickStrc{cFreqType,1} = LeftCorrLick(:,2:end);
    AlignLickStrc{cFreqType,2} = RightCorrLick(:,2:end);
    AlignLickStrc{cFreqType,3} = LeftErroLick(:,2:end);
    AlignLickStrc{cFreqType,4} = RightErroLick(:,2:end);
end
    
%% plot all dataset
if ~isdir('./All BehavType Colorplot/')
    mkdir('./All BehavType Colorplot/');
end
cd('./All BehavType Colorplot/');

for nROI = 1 : ROInum
    cROIdata = squeeze(AlignData(:,nROI,:));
    climMax = prctile(cROIdata(:),70);
    if climMax < 0
        climMax = 10;
    elseif climMax == 0
        climMax = 1;
    end
    clim = [0,climMax];
    if clim(2) > 400
        clim(2) = 200;
    end
    %%
    hROI = figure('position',[100 100 1500 980],'PaperPositionMode','auto');
    for nFreq = 1 : NumFreq
        cFreqInds = TrStimFreq == FreqTypes(nFreq);
        cFreqOut = TrOutcome(cFreqInds);
        cFreqData = cROIdata(cFreqInds,:);
        %Correct data plot
        AxCorr = subplot(6,NumFreq,[nFreq,nFreq+NumFreq]);
        hold on;
        CorrTrData = cFreqData(cFreqOut == 1,:);
        CorrTrAnsSortInds = AnsFIndsSort{nFreq,2};
        CorrTrAnsEventFPlot = FreqTypeEventF{nFreq,1};
        CorrTrReEventFPlot = FreqTypeEventF{nFreq,2};
        imagesc(CorrTrData(CorrTrAnsSortInds,:),clim);
        plot(CorrTrAnsEventFPlot(:,1),CorrTrAnsEventFPlot(:,2),'Color',[1 0 1],'LineWidth',1.8);
        plot(CorrTrReEventFPlot(:,1),CorrTrReEventFPlot(:,2),'Color','g','LineWidth',1.8);
        line([AlignedFrame AlignedFrame],[0.5 size(CorrTrData,1)+0.5],'Color',[.7 .7 .7],'LineWidth',2);
        line([SoundOffFrame SoundOffFrame],[0.5 size(CorrTrData,1)+0.5],'Color',[.7 .7 .7],'LineWidth',2,'linestyle','--');
        nfLeftCorrLick = AlignLickStrc{nFreq,1};
        nfRightCorrLick = AlignLickStrc{nFreq,2};
        plot(nfLeftCorrLick(1,:),nfLeftCorrLick(2,:),'ro','MarkerFaceColor','r','MarkerSize',2);
        plot(nfRightCorrLick(1,:),nfRightCorrLick(2,:),'go','MarkerFaceColor','g','MarkerSize',2);
        
        set(gca,'yDir','reverse','ylim',[0.5 size(CorrTrData,1)+0.5],'xlim',[0 size(CorrTrData,2)]);
        if nFreq == NumFreq
            AxsPos = get(AxCorr,'position');
            hbar = colorbar;
            set(AxCorr,'position',AxsPos);
            barPos = get(hbar,'position');
            set(hbar,'position',[barPos(1),barPos(2),barPos(3)*0.3,barPos(4)]);
        end
%         xlabel('Time (s)');
        if nFreq == 1
            ylabel('Correct Trials','Color','r');
        end
        set(gca,'xtick',AlignXtick,'xticklabel',AlignxtickLabel);
        title(sprintf('Freq = %d',FreqTypes(nFreq)));
        set(gca,'FontSize',12);
        
        % error data plot
        AxErro = subplot(6,NumFreq,[nFreq+NumFreq*2,nFreq+NumFreq*3]);
        hold on;
        ErroData = cFreqData(cFreqOut == 0,:);
        if ~isempty(ErroData)
            ErroTrAnsSortInds = AnsFIndsSort{nFreq,1};
            ErroTrAnsEventFPlot = FreqTypeEventF{nFreq,3};
            imagesc(ErroData(ErroTrAnsSortInds,:),clim);
            plot(ErroTrAnsEventFPlot(:,1),ErroTrAnsEventFPlot(:,2),'Color',[1 0 1],'LineWidth',1.8);
            line([AlignedFrame AlignedFrame],[0.5 size(ErroData,1)+0.5],'Color',[.7 .7 .7],'LineWidth',2);
            line([SoundOffFrame SoundOffFrame],[0.5 size(CorrTrData,1)+0.5],'Color',[.7 .7 .7],'LineWidth',2,'linestyle','--');
            set(gca,'yDir','reverse','ylim',[0.5 size(ErroData,1)+0.5],'xlim',[0 size(ErroData,2)]);
%             xlabel('Time (s)');
            nfLeftErroLick = AlignLickStrc{nFreq,3};
            nfRightErroLick = AlignLickStrc{nFreq,4};
            plot(nfLeftErroLick(1,:),nfLeftErroLick(2,:),'ro','MarkerFaceColor','r','MarkerSize',2);
            plot(nfRightErroLick(1,:),nfRightErroLick(2,:),'go','MarkerFaceColor','g','MarkerSize',2);
            
            set(gca,'xtick',AlignXtick,'xticklabel',AlignxtickLabel);
            set(gca,'FontSize',12);
        end
        if nFreq == 1
            ylabel('Error Trials','Color','b');
%             set(gca,'FontSize',16);
        end
        
        CorrectMean = mean(CorrTrData);
        ErroMean = mean(ErroData);
        MisData = cFreqData(cFreqOut == 2,:);
        if ~isempty(MisData)
            MissMean = mean(MisData);
            AxMiss1 = subplot(6,NumFreq,nFreq+NumFreq*4);
            hold on
            imagesc(MisData,clim);
            line([AlignedFrame AlignedFrame],[0.5 size(MisData,1)+0.5],'Color',[.7 .7 .7],'LineWidth',2);
            line([SoundOffFrame SoundOffFrame],[0.5 size(CorrTrData,1)+0.5],'Color',[.7 .7 .7],'LineWidth',2,'linestyle','--');
            set(gca,'yDir','reverse','ylim',[0.5 size(MisData,1)+0.5],'xlim',[0 size(MisData,2)]);
            
%             ylabel('Miss Trials');
            set(gca,'xtick',[]);
            set(gca,'FontSize',12);
            
            if nFreq == 1
                ylabel('Miss Trials');
                set(gca,'FontSize',12);
            end
            
            AxMiss2 = subplot(6,NumFreq,nFreq+NumFreq*5);
            hold on
            plot(CorrectMean,'r','linewidth',1);
            if length(ErroData) == numel(ErroData) % only have single trial for certain condition
                plot(ErroData,'b','linewidth',1);
            else
                plot(ErroMean,'b','linewidth',1);
            end
            if numel(MisData) == length(MisData)
                plot(MisData,'k','linewidth',1);
            else
                plot(MissMean,'k','linewidth',1);
            end
            yscales = get(gca,'ylim');
            line([AlignedFrame AlignedFrame],yscales,'Color',[.7 .7 .7],'LineWidth',1.2);
            line([SoundOffFrame SoundOffFrame],yscales,'Color',[.7 .7 .7],'LineWidth',1.2,'linestyle','--');
            set(gca,'xtick',AlignXtick,'xticklabel',AlignxtickLabel,'xlim',[0 size(CorrTrData,2)],'ylim',yscales);
            set(gca,'FontSize',14);
            xlabel('Time (s)');
            if nFreq == 1
                ylabel('Mean \DeltaF/F_0(%)');
%                 set(gca,'FontSize',16);
            end
%             if nFreq == NumFreq
%                 cAxisPos = get(AxMiss2,'position');
%                 legend('Corr','Erro','Miss');
%                 legend('boxoff','Location','northeastoutside','FontSize',4);
%             end    
        else
            AxMiss = subplot(6,NumFreq,[nFreq+NumFreq*4,nFreq+NumFreq*5]);
            hold on
            plot(CorrectMean,'r','linewidth',1);
            if length(ErroData) == numel(ErroData) % only have single trial for certain condition
                plot(ErroData,'b','linewidth',1);
            else
                plot(ErroMean,'b','linewidth',1);
            end
            yscales = get(gca,'ylim');
            line([AlignedFrame AlignedFrame],yscales,'Color',[.7 .7 .7],'LineWidth',1.2);
            line([SoundOffFrame SoundOffFrame],yscales,'Color',[.7 .7 .7],'LineWidth',1.2,'linestyle','--');
            set(gca,'xtick',AlignXtick,'xticklabel',AlignxtickLabel,'xlim',[0 size(CorrTrData,2)],'ylim',yscales);
            set(gca,'FontSize',12);
            xlabel('Time (s)');
            if nFreq == 1
                ylabel({'Miss Trials';'Mean \DeltaF/F_0(%)'});
            end
%             if nFreq == NumFreq
%                 cAxisPos = get(AxMiss2,'position');
%                 legend('Corr','Erro','Miss');
%             end    
        end
    end
    annotation('textbox',[0.49,0.685,0.3,0.3],'String',['ROI' num2str(nROI)],'FitBoxToText','on','EdgeColor',...
               'none','FontSize',20);
           %%
    saveas(hROI,sprintf('ROI%d all behavType color plot',nROI));
    saveas(hROI,sprintf('ROI%d all behavType color plot',nROI),'png');
    close(hROI);
end

save PlotRelatedData.mat FreqTypeEventF AnsFIndsSort SessionDesp AlignLickStrc -v7.3
cd ..;