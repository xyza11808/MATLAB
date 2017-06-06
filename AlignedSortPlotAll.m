function AlignedSortPlotAll(RawData,BehavStrc,Frate,RewardTime,varargin)
% Function used for plot ROI response for each frequency and outcome
% combination

[AllTrNum,ROInum,FrameNum] = size(RawData);
TrStimOnset = double(BehavStrc.Time_stimOnset);
TrTypes = double(BehavStrc.Trial_Type);
TrAnsTime = double(BehavStrc.Time_answer);
TrChoice = double(BehavStrc.Action_choice);
TrStimFreq = double(BehavStrc.Stim_toneFreq);

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

MinStimOnsetTime = min(TrStimOnset);
TrTimeDiff = TrStimOnset - MinStimOnsetTime;
TrFrameDiff = round(TrTimeDiff/1000*Frate);
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
end
AlignedFrame = round(MinStimOnsetTime/1000*Frate);
AlignXtick = 0:Frate:AlignFrameLen;
AlignxtickLabel = AlignXtick/Frate;
%%
FreqTypeEventF = cell(NumFreq,3);
AnsFIndsSort = cell(NumFreq,2);
for cFreqType = 1 : NumFreq
    cFreqInds = TrStimFreq == FreqTypes(cFreqType);
    cFreqOutcome = TrOutcome(cFreqInds);
    cFreqAnsF = AnsAdjFrame(cFreqInds);
    cFreqReF = RewardAdjFrame(cFreqInds);
    
    ErrorOutAnsF = cFreqAnsF(cFreqOutcome == 0);
    CorrOutAnsF = cFreqAnsF(cFreqOutcome == 1);
    CorrOutReF = cFreqReF(cFreqOutcome == 1);
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
%     CorrTrReFXData(CorrSortReF == 0,1:2) = nan;
%     CorrTrReFYData(CorrSortReF == 0,1:2) = nan;
    AnsFIndsSort{cFreqType,1} = ErrorAnsIndsSort;
    AnsFIndsSort{cFreqType,2} = corrAnsIndsSort;
    FreqTypeEventF{cFreqType,3} = [ErrorTrXData,ErrorTrYData];
    FreqTypeEventF{cFreqType,1} = [CorrTrAnsFXData,CorrTrAnsFYData];
    FreqTypeEventF{cFreqType,2} = [CorrTrReFXData,CorrTrReFYData];
end
    
%% plot all dataset
if ~isdir('./All BehavType Colorplot/')
    mkdir('./All BehavType Colorplot/');
end
cd('./All BehavType Colorplot/');

for nROI = 1 : ROInum
    cROIdata = squeeze(AlignData(:,nROI,:));
    clim = [0,max(cROIdata(:))];
    if clim(2) > 400
        clim(2) = 350;
    end
    
    hROI = figure('position',[100 100 1500 980]);
    %%
    for nFreq = 1 : NumFreq
        cFreqInds = TrStimFreq == FreqTypes(nFreq);
        cFreqOut = TrOutcome(cFreqInds);
        cFreqData = cROIdata(cFreqInds,:);
        %
        AxCorr = subplot(3,NumFreq,nFreq);
        hold on;
        CorrTrData = cFreqData(cFreqOut == 1,:);
        CorrTrAnsSortInds = AnsFIndsSort{nFreq,2};
        CorrTrAnsEventFPlot = FreqTypeEventF{nFreq,1};
        CorrTrReEventFPlot = FreqTypeEventF{nFreq,2};
        imagesc(CorrTrData(CorrTrAnsSortInds,:),clim);
        plot(CorrTrAnsEventFPlot(:,1),CorrTrAnsEventFPlot(:,2),'Color',[1 0 1],'LineWidth',1.8);
        plot(CorrTrReEventFPlot(:,1),CorrTrReEventFPlot(:,2),'Color','g','LineWidth',1.8);
        line([AlignedFrame AlignedFrame],[0.5 size(CorrTrData,1)+0.5],'Color',[.7 .7 .7],'LineWidth',2);
        set(gca,'yDir','reverse','ylim',[0.5 size(CorrTrData,1)+0.5],'xlim',[0 size(CorrTrData,2)]);
        if nFreq == NumFreq
            AxsPos = get(AxCorr,'position');
            hbar = colorbar;
            set(AxCorr,'position',AxsPos);
            barPos = get(hbar,'position');
            set(hbar,'position',[barPos(1),barPos(2),barPos(3)*0.3,barPos(4)]);
        end
        xlabel('Time (s)');
        if nFreq == 1
            ylabel('Correct Trials');
        end
        set(gca,'xtick',AlignXtick,'xticklabel',AlignxtickLabel);
        title(sprintf('Freq = %d',FreqTypes(nFreq)));
        set(gca,'FontSize',16);
        %
        AxErro = subplot(3,NumFreq,nFreq+NumFreq);
        hold on;
        ErroData = cFreqData(cFreqOut == 0,:);
        if ~isempty(ErroData)
            ErroTrAnsSortInds = AnsFIndsSort{nFreq,1};
            ErroTrAnsEventFPlot = FreqTypeEventF{nFreq,3};
            imagesc(ErroData(ErroTrAnsSortInds,:),clim);
            plot(ErroTrAnsEventFPlot(:,1),ErroTrAnsEventFPlot(:,2),'Color',[1 0 1],'LineWidth',1.8);
            line([AlignedFrame AlignedFrame],[0.5 size(ErroData,1)+0.5],'Color',[.7 .7 .7],'LineWidth',2);
            set(gca,'yDir','reverse','ylim',[0.5 size(ErroData,1)+0.5],'xlim',[0 size(ErroData,2)]);
            xlabel('Time (s)');
            
            set(gca,'xtick',AlignXtick,'xticklabel',AlignxtickLabel);
            set(gca,'FontSize',16);
        end
        if nFreq == 1
            ylabel('Error Trials');
            set(gca,'FontSize',16);
        end
        
        AxMiss = subplot(3,NumFreq,nFreq+NumFreq*2);
        hold on
        MisData = cFreqData(cFreqOut == 2,:);
        if ~isempty(MisData)
            imagesc(MisData,clim);
            line([AlignedFrame AlignedFrame],[0.5 size(MisData,1)+0.5],'Color',[.7 .7 .7],'LineWidth',2);
            set(gca,'yDir','reverse','ylim',[0.5 size(MisData,1)+0.5],'xlim',[0 size(MisData,2)]);
            xlabel('Time (s)');
%             ylabel('Miss Trials');
            set(gca,'xtick',AlignXtick,'xticklabel',AlignxtickLabel);
            set(gca,'FontSize',16);
        end
        if nFreq == 1
            ylabel('Miss Trials');
            set(gca,'FontSize',16);
        end
    end
    annotation('textbox',[0.49,0.685,0.3,0.3],'String',['ROI' num2str(nROI)],'FitBoxToText','on','EdgeColor',...
               'none','FontSize',20);
           %%
    saveas(hROI,sprintf('ROI%d all behavType color plot',nROI));
    saveas(hROI,sprintf('ROI%d all behavType color plot',nROI),'png');
    close(hROI);
end

save PlotRelatedData.mat FreqTypeEventF AnsFIndsSort SessionDesp -v7.3
cd ..;