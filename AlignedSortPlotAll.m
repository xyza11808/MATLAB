function AlignedSortPlotAll(RawData,BehavStrc,Frate,RewardTime,varargin)
% Function used for plot ROI response for each frequency and outcome
% combination
IsPlot = 1;
if nargin > 4
    if ~isempty(varargin{1})
        IsPlot = varargin{1};
    end
end

IsLickPlot = 0;
if nargin > 5
    if ~isempty(varargin{2})
        LickTimeStrc = varargin{2};
        IsLickPlot = 1;
    end
end

IsTrIndsInput = 0;
if nargin > 6
    if ~isempty(varargin{3})
        UsedTrInds = varargin{3};
        IsTrIndsInput = 1;
    end
end

IsROIstatePlot = 0;
if nargin > 7
    if ~isempty(varargin{4})
        IsROIstatePlot = 1;
        ROIstate = varargin{4};
    end
end

IsSubfolder = 0;
if nargin > 8
    if ~isempty(varargin{5})
        IsSubfolder = 1;
        SubFolderName = varargin{5};
    end
end

IsBoundToneDefineRe = 0;
if nargin > 9
    if ~isempty(varargin{6})
        IsBoundToneDefineRe = varargin{6};
    end
end

if IsLickPlot
    AlignLickFStrc = LickTimeStrc;
end
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
    if IsLickPlot
        AlignLickFStrc = AlignLickFStrc(AllTrInds);
    end
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
    if ~IsBoundToneDefineRe
        BoundFreq = FreqTypes(ceil(NumFreq/2));
        LeftBoundFreqInds = TrStimFreq(:) == BoundFreq & TrChoice(:) == 0 & TrOutcome(:) ~= 2;
        RBoundFreqInds = TrStimFreq(:) == BoundFreq & TrChoice(:) == 1 & TrOutcome(:) ~= 2;
        TrOutcome(LeftBoundFreqInds) = 1;
        TrOutcome(RBoundFreqInds) = 0;
        RewardTime(LeftBoundFreqInds) = TrAnsTime(LeftBoundFreqInds);
    end
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
    cTrBaseFrame = round((TrStimOnset(nTr)/1000)*Frate);
    BaseMtx = repmat(mean(cTrData(:,1:cTrBaseFrame),2),1,size(cTrData,2));
    BaseCorrectData = cTrData - BaseMtx;
    AlignData(nTr,:,:) = BaseCorrectData(:,(TrFrameDiff(nTr)+1):(TrFrameDiff(nTr)+AlignFrameLen));
    if IsLickPlot
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
    if IsLickPlot
        cFreqLickStrc = AlignLickFStrc(cFreqInds);
    end
    
    ErrorOutAnsF = cFreqAnsF(cFreqOutcome == 0);
    CorrOutAnsF = cFreqAnsF(cFreqOutcome == 1);
    CorrOutReF = cFreqReF(cFreqOutcome == 1);
%     LeftLickStrcCorrF = AlignLickFStrc(cFreqOutcome == 1).Action_LeftLick_frame;
%     LeftLickStrcErroF = AlignLickFStrc(cFreqOutcome == 0).Action_LeftLick_frame;
%     RightLickStrcCorrF = AlignLickFStrc(cFreqOutcome == 1).Action_RightLick_frame;
%     RightLickStrcErroF = AlignLickFStrc(cFreqOutcome == 0).Action_RightLick_frame;
    if IsLickPlot
        CorrLickStrc = cFreqLickStrc(cFreqOutcome == 1);
        ErroLickStrc = cFreqLickStrc(cFreqOutcome == 0);
    end
    
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
    if IsLickPlot
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
    end
%     CorrTrReFXData(CorrSortReF == 0,1:2) = nan;
%     CorrTrReFYData(CorrSortReF == 0,1:2) = nan;
    AnsFIndsSort{cFreqType,1} = ErrorAnsIndsSort;
    AnsFIndsSort{cFreqType,2} = corrAnsIndsSort;
    FreqTypeEventF{cFreqType,3} = [ErrorTrXData,ErrorTrYData];
    FreqTypeEventF{cFreqType,1} = [CorrTrAnsFXData,CorrTrAnsFYData];
    FreqTypeEventF{cFreqType,2} = [CorrTrReFXData,CorrTrReFYData];
    if IsLickPlot
        AlignLickStrc{cFreqType,1} = LeftCorrLick(:,2:end);
        AlignLickStrc{cFreqType,2} = RightCorrLick(:,2:end);
        AlignLickStrc{cFreqType,3} = LeftErroLick(:,2:end);
        AlignLickStrc{cFreqType,4} = RightErroLick(:,2:end);
    end
end
    
%% plot all dataset
if ~isdir('./All BehavType Colorplot/')
    mkdir('./All BehavType Colorplot/');
end
cd('./All BehavType Colorplot/');
if IsSubfolder
    if ~isdir(SubFolderName)
        mkdir(SubFolderName);
    end
    cd(SubFolderName);
end

%%
PointSize = 1;
ROIMeanTraceData = cell(ROInum,NumFreq,3);
for nROI = 1 : ROInum
    %%
    cROIdata = squeeze(AlignData(:,nROI,:));
    climMax = prctile(cROIdata(:),99);
%     if climMax < 0
%         climMax = 10;
%     elseif climMax == 0
%         climMax = 1;
%     end
    clim = [min(cROIdata(:)),climMax];
    if clim(2) > 400
        clim(2) = 200;
    end
    %
    MeanPlotAxes = [];
    MeanyScales = zeros(NumFreq,2);
    if IsPlot
        hROI = figure('position',[20 100 1200 840],'PaperPositionMode','auto','visible','off');
    end
    for nFreq = 1 : NumFreq
        cFreqInds = TrStimFreq == FreqTypes(nFreq);
        cFreqOut = TrOutcome(cFreqInds);
        cFreqData = cROIdata(cFreqInds,:);
        %Correct data plot
        if IsPlot
            AxCorr = subplot(6,NumFreq,[nFreq,nFreq+NumFreq]);
            hold on;
        end
        CorrTrData = cFreqData(cFreqOut == 1,:);
        if ~isempty(CorrTrData)
            if IsPlot
                CorrTrAnsSortInds = AnsFIndsSort{nFreq,2};
                CorrTrAnsEventFPlot = FreqTypeEventF{nFreq,1};
                CorrTrReEventFPlot = FreqTypeEventF{nFreq,2};
                imagesc(CorrTrData(CorrTrAnsSortInds,:),clim);
                plot(CorrTrAnsEventFPlot(:,1),CorrTrAnsEventFPlot(:,2),'Color',[1 0 1],'LineWidth',1.8);
                plot(CorrTrReEventFPlot(:,1),CorrTrReEventFPlot(:,2),'Color','g','LineWidth',1.8);
                line([AlignedFrame AlignedFrame],[0.5 size(CorrTrData,1)+0.5],'Color',[.7 .7 .7],'LineWidth',2);
                line([SoundOffFrame SoundOffFrame],[0.5 size(CorrTrData,1)+0.5],'Color',[.7 .7 .7],'LineWidth',2,'linestyle','--');
                if IsLickPlot
                    nfLeftCorrLick = AlignLickStrc{nFreq,1};
                    nfRightCorrLick = AlignLickStrc{nFreq,2};
                    plot(nfLeftCorrLick(1,:),nfLeftCorrLick(2,:),'ro','MarkerFaceColor','r','MarkerSize',PointSize);
                    plot(nfRightCorrLick(1,:),nfRightCorrLick(2,:),'go','MarkerFaceColor','g','MarkerSize',PointSize);
                end
                set(gca,'yDir','reverse','ylim',[0.5 size(CorrTrData,1)+0.5],'xlim',[0 size(CorrTrData,2)]);
                if nFreq == NumFreq
                    AxsPos = get(AxCorr,'position');
                    hbar = colorbar;
                    set(AxCorr,'position',AxsPos);
                    barPos = get(hbar,'position');
                    set(hbar,'position',[barPos(1),barPos(2),barPos(3)*0.3,barPos(4)]);
                end
                if nFreq == 1
                    ylabel('Correct Trials','Color','r');
                end
                set(gca,'xtick',AlignXtick,'xticklabel',AlignxtickLabel);
                title(sprintf('Freq = %d',FreqTypes(nFreq)));
                set(gca,'FontSize',12);
            end
        end
        
        % error data plot
        if IsPlot
            AxErro = subplot(6,NumFreq,[nFreq+NumFreq*2,nFreq+NumFreq*3]);
            hold on;
        end
        ErroData = cFreqData(cFreqOut == 0,:);
        if ~isempty(ErroData) && IsPlot
            ErroTrAnsSortInds = AnsFIndsSort{nFreq,1};
            ErroTrAnsEventFPlot = FreqTypeEventF{nFreq,3};
            imagesc(ErroData(ErroTrAnsSortInds,:),clim);
            plot(ErroTrAnsEventFPlot(:,1),ErroTrAnsEventFPlot(:,2),'Color',[1 0 1],'LineWidth',1.8);
            line([AlignedFrame AlignedFrame],[0.5 size(ErroData,1)+0.5],'Color',[.7 .7 .7],'LineWidth',2);
            line([SoundOffFrame SoundOffFrame],[0.5 size(CorrTrData,1)+0.5],'Color',[.7 .7 .7],'LineWidth',2,'linestyle','--');
            set(gca,'yDir','reverse','ylim',[0.5 size(ErroData,1)+0.5],'xlim',[0 size(ErroData,2)]);
%             xlabel('Time (s)');
            if IsLickPlot
                nfLeftErroLick = AlignLickStrc{nFreq,3};
                nfRightErroLick = AlignLickStrc{nFreq,4};
                plot(nfLeftErroLick(1,:),nfLeftErroLick(2,:),'ro','MarkerFaceColor','r','MarkerSize',PointSize);
                plot(nfRightErroLick(1,:),nfRightErroLick(2,:),'go','MarkerFaceColor','g','MarkerSize',PointSize);
            end
            set(gca,'xtick',AlignXtick,'xticklabel',AlignxtickLabel);
            set(gca,'FontSize',12);
        end
        if IsPlot
            if nFreq == 1 && IsPlot
                ylabel('Error Trials','Color','b');
    %             set(gca,'FontSize',16);
            end
        end
        CorrectMean = mean(CorrTrData);
        ErroMean = mean(ErroData);
        MisData = cFreqData(cFreqOut == 2,:);
        if ~isempty(MisData)
            MissMean = mean(MisData);
            if IsPlot
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

                AxMean = subplot(6,NumFreq,nFreq+NumFreq*5);
                hold on
                plot(CorrectMean,'r','linewidth',1);
            end
            ROIMeanTraceData{nROI,nFreq,1} = CorrectMean;
            if length(ErroData) == numel(ErroData) % only have single trial for certain condition
                if IsPlot
                    plot(ErroData,'b','linewidth',1);
                end
                ROIMeanTraceData{nROI,nFreq,2} = ErroData;
            else
                if IsPlot
                    plot(ErroMean,'b','linewidth',1);
                end
                ROIMeanTraceData{nROI,nFreq,2} = ErroMean;
            end
            if numel(MisData) == length(MisData)
                if IsPlot
                    plot(MisData,'k','linewidth',1);
                end
                ROIMeanTraceData{nROI,nFreq,3} = MisData;
            else
                if IsPlot
                    plot(MissMean,'k','linewidth',1);
                end
                ROIMeanTraceData{nROI,nFreq,3} = MissMean;
            end
            if IsPlot
                yscales = get(gca,'ylim');
    %             line([AlignedFrame AlignedFrame],yscales,'Color',[.7 .7 .7],'LineWidth',1.2);
    %             line([SoundOffFrame SoundOffFrame],yscales,'Color',[.7 .7 .7],'LineWidth',1.2,'linestyle','--');
                set(gca,'xtick',AlignXtick,'xticklabel',AlignxtickLabel,'xlim',[0 size(CorrTrData,2)],'ylim',yscales);
                set(gca,'FontSize',14);
                xlabel('Time (s)');
                if nFreq == 1
                    ylabel('Mean \DeltaF/F_0(%)');
    %                 set(gca,'FontSize',16);
                end
            end
%             if nFreq == NumFreq
%                 cAxisPos = get(AxMiss2,'position');
%                 legend('Corr','Erro','Miss');
%                 legend('boxoff','Location','northeastoutside','FontSize',4);
%             end    
        else
            if IsPlot
                AxMean = subplot(6,NumFreq,nFreq+NumFreq*5);  % hold at the last subplot
                hold on
                plot(CorrectMean,'r','linewidth',1);
            end
            ROIMeanTraceData{nROI,nFreq,1} = CorrectMean;
            if length(ErroData) == numel(ErroData) % only have single trial for certain condition
               if IsPlot
                    plot(ErroData,'b','linewidth',1);
               end
                ROIMeanTraceData{nROI,nFreq,2} = ErroData;
            else
                if IsPlot
                    plot(ErroMean,'b','linewidth',1);
                end
                ROIMeanTraceData{nROI,nFreq,2} = ErroMean;
            end
            if IsPlot
                yscales = get(gca,'ylim');
    %             line([AlignedFrame AlignedFrame],yscales,'Color',[.7 .7 .7],'LineWidth',1.2);
    %             line([SoundOffFrame SoundOffFrame],yscales,'Color',[.7 .7 .7],'LineWidth',1.2,'linestyle','--');
                set(gca,'xtick',AlignXtick,'xticklabel',AlignxtickLabel,'xlim',[0 size(CorrTrData,2)],'ylim',yscales);
                set(gca,'FontSize',12);
                xlabel('Time (s)');
                if nFreq == 1
                    ylabel({'Mean \DeltaF/F_0(%)'});
                end
            end
%             if nFreq == NumFreq
%                 cAxisPos = get(AxMiss2,'position');
%                 legend('Corr','Erro','Miss');
%             end    
        end
        if IsPlot
            MeanPlotAxes = [MeanPlotAxes,AxMean];
            MeanyScales(nFreq,:) = get(AxMean,'ylim');
        end
    end
    if IsPlot
        ComYScale = [min(MeanyScales(:,1)),max(MeanyScales(:,2))];
        if ComYScale(1) < -20
            ComYScale(1) = -20;
        end
        for cF = 1 : NumFreq
           set(MeanPlotAxes(cF),'ylim',ComYScale);
           line(MeanPlotAxes(cF),[AlignedFrame AlignedFrame],ComYScale,'Color',[.7 .7 .7],'LineWidth',1.2);
           line(MeanPlotAxes(cF),[SoundOffFrame SoundOffFrame],ComYScale,'Color',[.7 .7 .7],'LineWidth',1.2,'linestyle','--');
        end
        if ~IsROIstatePlot
            annotation('textbox',[0.49,0.685,0.3,0.3],'String',['ROI' num2str(nROI)],'FitBoxToText','on','EdgeColor',...
                       'none','FontSize',20);
        else
            ColorStr = {'r','g','m'};
            cROIstate = logical(ROIstate(nROI,:));
            if sum(cROIstate)
                annotation('textbox',[0.49,0.685,0.3,0.3],'String',['ROI' num2str(nROI)],'FitBoxToText','on','EdgeColor',...
                           'none','FontSize',20,'Color',ColorStr{cROIstate});
            else
                annotation('textbox',[0.49,0.685,0.3,0.3],'String',['ROI' num2str(nROI)],'FitBoxToText','on','EdgeColor',...
                           'none','FontSize',20,'Color','c');
            end
        end
               %
        saveas(hROI,sprintf('ROI%d all behavType color plot',nROI));
        saveas(hROI,sprintf('ROI%d all behavType color plot',nROI),'png');
        close(hROI);
    end
    %%
end

save PlotRelatedData.mat FreqTypeEventF AnsFIndsSort SessionDesp AlignLickStrc AlignedFrame SoundOffFrame Frate ROIMeanTraceData -v7.3
cd ..;
if IsSubfolder
    cd ..;
end