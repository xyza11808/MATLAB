function AnsTimeAlignPlot(Data,BehavStrc,isPlot,Frate,Troutcome,varargin)
% this function is used for data alignment using answer time, and then
% plotting the aligned color plot and mean trace plot
IsDataStimAlign = 0;
if nargin > 5
    if ~isempty(varargin{1})
        IsDataStimAlign = varargin{1};
    end
end
AnswerTime = double(BehavStrc.Time_answer);
TrFreqAll = double(BehavStrc.Stim_toneFreq);
AnswerFrame = round(double(AnswerTime)/1000*Frate);
if IsDataStimAlign
    StimOnTime = BehavStrc.Time_stimOnset;
    StimOnFrame = round(double(StimOnTime)/1000*Frate);
    StimFDiff = StimOnFrame - min(StimOnFrame);
    AnswerFrame = AnswerFrame - StimFDiff;
end

NonMissInds = Troutcome ~= 2;
NMData = Data(NonMissInds,:,:);
NMAnsframe = AnswerFrame(NonMissInds);
NMStimFreq = TrFreqAll(NonMissInds);
NMOutcome = Troutcome(NonMissInds);
NMChoice = double(BehavStrc.Action_choice(NonMissInds));
FreqTypes = unique(NMStimFreq);
NumFreq = length(FreqTypes);
if mod(NumFreq,2)  % change the correct-right plots into left-right panel plots
    BoundFreq = FreqTypes(ceil(NumFreq/2));
    LeftBoundInds = NMStimFreq(:) == BoundFreq & NMChoice(:) == 0;
    RBoundInds = NMStimFreq(:) == BoundFreq & NMChoice(:) == 1;
    NMOutcome(LeftBoundInds) = 1;
    NMOutcome(RBoundInds) = 0;
end

MinAnsF = min(NMAnsframe);
AlignDiff = NMAnsframe - MinAnsF;
AfterAliLen = size(NMData,3) - max(AlignDiff);
AnsAlignData = zeros(length(NMStimFreq),size(NMData,2),AfterAliLen);
for nTr = 1 : length(NMStimFreq)
    AnsAlignData(nTr,:,:) = NMData(nTr,:,(AlignDiff(nTr)+1):(AlignDiff(nTr)+AfterAliLen));
end

if ~isdir('./AnsTime_Align_plot/')
    mkdir('./AnsTime_Align_plot/');
end
cd('./AnsTime_Align_plot/');
%
if (AfterAliLen - MinAnsF) < 2*Frate
    fprintf('The latest answer time is much too late, using only quik answering data.\n');
    EarlyAnsTrs = (size(NMData,3) - AlignDiff - MinAnsF) >= round(1.5*Frate);
    SelectROIinds = NonMissInds;
    SelectROIinds(~EarlyAnsTrs) = false;
    EarlyAnsData = NMData(EarlyAnsTrs,:,:);
    EarlyAnsStimFreq = NMStimFreq(EarlyAnsTrs);
    EarlyAnsOutcome = NMOutcome(EarlyAnsTrs);
    EarlyAnsChoice = NMChoice(EarlyAnsTrs);
    EarlyAnsAlignDiff = AlignDiff(EarlyAnsTrs);
    NewAfteraliLen = size(NMData,3) - max(EarlyAnsAlignDiff);
    
    EarlyAnsAlignData = zeros(length(EarlyAnsStimFreq),size(NMData,2),NewAfteraliLen);
    for ntr = 1 : length(EarlyAnsStimFreq)
        EarlyAnsAlignData(ntr,:,:) = EarlyAnsData(ntr,:,(EarlyAnsAlignDiff(ntr)+1):(EarlyAnsAlignDiff(ntr)+NewAfteraliLen));
    end
    save EarlyAnsAlignSave.mat EarlyAnsAlignData EarlyAnsOutcome EarlyAnsStimFreq MinAnsF SelectROIinds EarlyAnsChoice Frate -v7.3
end

%%
if isPlot
    xticks = 0:Frate:AfterAliLen;
    xticklabels = xticks/Frate;
    nROIs = size(AnsAlignData,2);
    for cROI = 1 : nROIs
        cROIdata = squeeze(AnsAlignData(:,cROI,:));
        clim = [0 prctile(cROIdata(:),85)];
        if clim(2) < 0
            clim(2) = 10;
        end
        %
        hf = figure('position',[200 100 1500 1000],'visible','off');
        for nf = 1 : NumFreq
            cFreqInds = NMStimFreq == FreqTypes(nf);
            cFreqData = cROIdata(cFreqInds,:);
            cFreqOutcome = NMOutcome(cFreqInds);

            % plot the correct trials color plot
            CorrInds = cFreqOutcome == 1;
            CorrData = cFreqData(CorrInds,:);
            MeanCorr = mean(CorrData);
            CorrAx = subplot(3,NumFreq,nf);
            if ~isempty(CorrData)
                imagesc(CorrData,clim);
                line([MinAnsF MinAnsF],[0.5,size(CorrData,1)+0.5],'color','m','linewidth',1.2);
                set(gca,'xlim',[0.5,size(CorrData,2)+0.5],'ylim',[0.5,size(CorrData,1)+0.5]);
                title(sprintf('Freq = %d',FreqTypes(nf)));
                set(gca,'xtick',xticks,'xticklabel',xticklabels,'FontSize',14);
                if nf == 1
                    ylabel('Correct Trials','Color','r');
                end
                if nf == NumFreq
                    AxsPos = get(CorrAx,'position');
                    hbar = colorbar;
                    set(CorrAx,'position',AxsPos);
                    barPos = get(hbar,'position');
                    set(hbar,'position',[barPos(1),barPos(2),barPos(3)*0.3,barPos(4)]);
                end
            end

            % plot the error trials
            ErrpoAx = subplot(3,NumFreq,nf+NumFreq);
            ErroInds = cFreqOutcome == 0;
            ErroData = cFreqData(ErroInds,:);
             MeanErro = mean(ErroData);
            if ~isempty(ErroData)
                imagesc(ErroData,clim);
                line([MinAnsF MinAnsF],[0.5,size(ErroData,1)+0.5],'color','m','linewidth',1.2);
                set(gca,'xlim',[0.5,size(ErroData,2)+0.5],'ylim',[0.5,size(ErroData,1)+0.5]);
        %         title(sprintf('Freq = %d',FreqTypes(nf)));
                set(gca,'xtick',xticks,'xticklabel',xticklabels,'FontSize',14);
            end
            if nf == 1
                ylabel('Error Trials','Color','b','FontSize',14);
            end

            %plot the mean trace
            if length(MeanCorr) == 1
                MeanCorr = CorrData;
            end
            if length(MeanErro) == 1
                MeanErro = ErroData;
            end
            MeanTrAx = subplot(3,NumFreq,nf+NumFreq*2);
            hold on;
            plot(MeanCorr,'r','Linewidth',1.2);
            plot(MeanErro,'b','Linewidth',1.2);
            yscales = get(MeanTrAx,'ylim');
            line([MinAnsF MinAnsF],yscales,'color',[.4 .4 .4],'linewidth',1.2);
            set(gca,'xlim',[1,size(ErroData,2)],'ylim',yscales);
            set(gca,'xtick',xticks,'xticklabel',xticklabels,'FontSize',14);
            xlabel('Time (s)');
            if nf ==1
                ylabel({'AnswerTime Aligned';'Mean Trace'});
            end
        end
        %
        annotation('textbox',[0.49,0.685,0.3,0.3],'String',['ROI' num2str(cROI)],'FitBoxToText','on','EdgeColor',...
               'none','FontSize',16);
        saveas(hf,sprintf('Answer time aligned color plot for ROI%d',cROI));
        saveas(hf,sprintf('Answer time aligned color plot for ROI%d',cROI),'png');
        close(hf);
    end
end
save AnsAlignData.mat AnsAlignData MinAnsF NonMissInds NMStimFreq NMOutcome NMChoice Frate -v7.3
cd ..;