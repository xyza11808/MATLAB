function BehavLickPlot(behavStruct,BehavSetting,LickEndT,varargin)
%this function will be used for raster plot of mouse lick time during
%behav session, and try to compare control and experimental data to see
%whetehr there are any differences
if isempty(LickEndT)
    LickEndT=10;
end

TrialTypes=behavStruct.Trial_Type;
TrialStimOnT=behavStruct.Time_stimOnset;
RespDelay=BehavSetting.responseDelay;
isProbTrial=behavStruct.Trial_isProbeTrial;
TrialFreq=behavStruct.Stim_toneFreq;
FreqTypes=unique(TrialFreq);
OnsetTimeDiff=double(TrialStimOnT-min(TrialStimOnT));  %for stim on time alignment
AlignedTime=min(TrialStimOnT);
StimOffTime=AlignedTime+300;
RespDelayOffTime=StimOffTime+double(RespDelay(1));

corr_trial_inds = behavStruct.Action_choice == behavStruct.Trial_Type;
Error_trial_inds = (behavStruct.Action_choice ~= behavStruct.Trial_Type) & (behavStruct.Action_choice ~= 2);
miss_tiral = behavStruct.Action_choice == 2;
trial_outcome = zeros(length(corr_trial_inds),1);
trial_outcome(corr_trial_inds) = 1;
trial_outcome(Error_trial_inds) = 0;
trial_outcome(miss_tiral) = 2;

[lick_time_struct,Lick_bias_side]=beha_lickTime_data(behavStruct,LickEndT); %returned data in ms form

if ~sum(isProbTrial)  %if there are no prob trials
    if length(FreqTypes)==2 % one paired stimulus 2afc task
        %         TypeDesp={'Left','Right'};
        %         LickSideDes={'LickTimeLeft','LickTimeRight'};
        CorrLeftInds = TrialTypes ==0 & trial_outcome' == 1;
        ErroLeftInds = TrialTypes ==0 & trial_outcome' == 0;
        CorrRightInds = TrialTypes ==1 & trial_outcome' == 1;
        ErroRightInds = TrialTypes ==1 & trial_outcome' == 0;
        
        h_all=figure('position',[220 40 1500 900],'PaperPositionMode','auto');
        subplot(2,2,1);
        hold on;
        CorrLeftLickTime=lick_time_struct(CorrLeftInds);
        CorrLeftLickTDif=OnsetTimeDiff(CorrLeftInds);
        CorrBiasSide=Lick_bias_side(CorrLeftInds);
        TrialLength=length(CorrLeftLickTime);
        for n=1:TrialLength
            TLLT=CorrLeftLickTime(n).LickTimeLeft-CorrLeftLickTDif(n);
            TRLT=CorrLeftLickTime(n).LickTimeRight-CorrLeftLickTDif(n);
            TLLT(TLLT<0)=[];
            TRLT(TRLT<0)=[];
            scatter(TLLT,ones(length(TLLT),1)*n,15,'o','MarkerEdgeColor','k','MarkerFaceColor','b');
            scatter(TRLT,ones(length(TRLT),1)*n,15,'o','MarkerEdgeColor','k','MarkerFaceColor','r');
            if CorrBiasSide(n)
                line([LickEndT*1000 LickEndT*1000],[n-0.3 n+0.3],'LineWidth',2,'Color','r');
            else
                line([LickEndT*1000 LickEndT*1000],[n-0.3 n+0.3],'LineWidth',2,'Color','b');
            end
        end
        
        axisscale=axis(gca);
        patch([AlignedTime,StimOffTime,StimOffTime,AlignedTime],[axisscale(3),axisscale(3),axisscale(4),axisscale(4)],1,...
            'facecolor','g','edgecolor','none','facealpha',0.4);  % Stim plot
        if double(RespDelay(1))
            patch([StimOffTime,RespDelayOffTime,RespDelayOffTime,StimOffTime],[axisscale(3),axisscale(3),axisscale(4),axisscale(4)],1,...
                'facecolor',[.8 .8 .8],'edgecolor','none','facealpha',0.4);
        end
        title('Correct Left Trials');
        xlabel('Time (ms)');
        ylabel('# Trials');
        
        
        subplot(2,2,2)
        hold on;
        CorrRightLickTime=lick_time_struct(CorrRightInds);
        CorrRightLickTDif=OnsetTimeDiff(CorrRightInds);
        CorrBiasSide=Lick_bias_side(CorrRightInds);
        TrialLength=length(CorrRightLickTime);
        for n=1:TrialLength
            TLLT=CorrRightLickTime(n).LickTimeLeft-CorrRightLickTDif(n);
            TRLT=CorrRightLickTime(n).LickTimeRight-CorrRightLickTDif(n);
            TLLT(TLLT<0)=[];
            TRLT(TRLT<0)=[];
            scatter(TLLT,ones(length(TLLT),1)*n,15,'o','MarkerEdgeColor','k','MarkerFaceColor','b');
            scatter(TRLT,ones(length(TRLT),1)*n,15,'o','MarkerEdgeColor','k','MarkerFaceColor','r');
            if CorrBiasSide(n)
                line([LickEndT*1000 LickEndT*1000],[n-0.3 n+0.3],'LineWidth',2,'Color','r');
            else
                line([LickEndT*1000 LickEndT*1000],[n-0.3 n+0.3],'LineWidth',2,'Color','b');
            end
        end
        axisscale=axis(gca);
        patch([AlignedTime,StimOffTime,StimOffTime,AlignedTime],[axisscale(3),axisscale(3),axisscale(4),axisscale(4)],1,...
            'facecolor','g','edgecolor','none','facealpha',0.4);  % Stim plot
        if double(RespDelay(1))
            patch([StimOffTime,RespDelayOffTime,RespDelayOffTime,StimOffTime],[axisscale(3),axisscale(3),axisscale(4),axisscale(4)],1,...
                'facecolor',[.8 .8 .8],'edgecolor','none','facealpha',0.4);
        end
        title('Correct Right Trials');
        xlabel('Time (ms)');
        ylabel('# Trials');
        
        subplot(2,2,3)
        hold on;
        ErroLeftLickTime=lick_time_struct(ErroLeftInds);
        ErroLeftLickTDif=OnsetTimeDiff(ErroLeftInds);
        ErroBiasSide=Lick_bias_side(ErroLeftInds);
        TrialLength=length(ErroLeftLickTime);
        for n=1:TrialLength
            TLLT=ErroLeftLickTime(n).LickTimeLeft-ErroLeftLickTDif(n);
            TRLT=ErroLeftLickTime(n).LickTimeRight-ErroLeftLickTDif(n);
            TLLT(TLLT<0)=[];
            TRLT(TRLT<0)=[];
            scatter(TLLT,ones(length(TLLT),1)*n,15,'o','MarkerEdgeColor','k','MarkerFaceColor','b');
            scatter(TRLT,ones(length(TRLT),1)*n,15,'o','MarkerEdgeColor','k','MarkerFaceColor','r');
            if ErroBiasSide(n)
                line([LickEndT*1000 LickEndT*1000],[n-0.3 n+0.3],'LineWidth',2,'Color','r');
            else
                line([LickEndT*1000 LickEndT*1000],[n-0.3 n+0.3],'LineWidth',2,'Color','b');
            end
        end
        axisscale=axis(gca);
        patch([AlignedTime,StimOffTime,StimOffTime,AlignedTime],[axisscale(3),axisscale(3),axisscale(4),axisscale(4)],1,...
            'facecolor','g','edgecolor','none','facealpha',0.4);  % Stim plot
        if double(RespDelay(1))
            patch([StimOffTime,RespDelayOffTime,RespDelayOffTime,StimOffTime],[axisscale(3),axisscale(3),axisscale(4),axisscale(4)],1,...
                'facecolor',[.8 .8 .8],'edgecolor','none','facealpha',0.4);
        end
        title('Error Left Trials');
        xlabel('Time (ms)');
        ylabel('# Trials');
        
        subplot(2,2,4)
        hold on;
        ErroRightLickTime=lick_time_struct(ErroRightInds);
        ErroRightLickTDif=OnsetTimeDiff(ErroRightInds);
        ErroBiasSide=Lick_bias_side(ErroRightInds);
        TrialLength=length(ErroRightLickTime);
        for n=1:TrialLength
            TLLT=ErroRightLickTime(n).LickTimeLeft-ErroRightLickTDif(n);
            TRLT=ErroRightLickTime(n).LickTimeRight-ErroRightLickTDif(n);
            TLLT(TLLT<0)=[];
            TRLT(TRLT<0)=[];
            scatter(TLLT,ones(length(TLLT),1)*n,15,'o','MarkerEdgeColor','k','MarkerFaceColor','b');
            scatter(TRLT,ones(length(TRLT),1)*n,15,'o','MarkerEdgeColor','k','MarkerFaceColor','r');
            if ErroBiasSide(n)
                line([LickEndT*1000 LickEndT*1000],[n-0.3 n+0.3],'LineWidth',2,'Color','r');
            else
                line([LickEndT*1000 LickEndT*1000],[n-0.3 n+0.3],'LineWidth',2,'Color','b');
            end
        end
        axisscale=axis(gca);
        patch([AlignedTime,StimOffTime,StimOffTime,AlignedTime],[axisscale(3),axisscale(3),axisscale(4),axisscale(4)],1,...
            'facecolor','g','edgecolor','none','facealpha',0.4);  % Stim plot
        if double(RespDelay(1))
            patch([StimOffTime,RespDelayOffTime,RespDelayOffTime,StimOffTime],[axisscale(3),axisscale(3),axisscale(4),axisscale(4)],1,...
                'facecolor',[.8 .8 .8],'edgecolor','none','facealpha',0.4);
        end
        title('Error Right Trials');
        xlabel('Time (ms)');
        ylabel('# Trials');
        
        suptitle('Lick Time Plot');
        saveas(h_all,'Raster_plot_2T2AFC_Lick_plot.png');
        saveas(h_all,'Raster_plot_2T2AFC_Lick_plot.fig');
        close(h_all);
    else
        FreqNum=length(FreqTypes);
        h_all=figure('position',[220 40 1500 900],'PaperPositionMode','auto');
        for n=1:FreqNum
            CurrentFreq=FreqTypes(n);
            CurrentCorrInds = TrialFreq == CurrentFreq & trial_outcome' == 1;
            CurrentErroInds = TrialFreq == CurrentFreq & trial_outcome' == 0;
            
            subplot(2,FreqNum,n)
            hold on
            CorrectLickT=lick_time_struct(CurrentCorrInds);
            CorrLickDif=OnsetTimeDiff(CurrentCorrInds);
            CorrBiasSide=Lick_bias_side(CurrentCorrInds);
            for m=1:length(CorrectLickT)
                TLLT=CorrectLickT(m).LickTimeLeft-CorrLickDif(m);
                TRLT=CorrectLickT(m).LickTimeRight-CorrLickDif(m);
                TLLT(TLLT<0)=[];
                TRLT(TRLT<0)=[];
                scatter(TLLT,ones(length(TLLT),1)*m,15,'o','MarkerEdgeColor','k','MarkerFaceColor','b');
                scatter(TRLT,ones(length(TRLT),1)*m,15,'o','MarkerEdgeColor','k','MarkerFaceColor','r');
                if CorrBiasSide(m)
                    line([LickEndT*1000 LickEndT*1000],[m-0.3 m+0.3],'LineWidth',2,'Color','r');
                else
                    line([LickEndT*1000 LickEndT*1000],[m-0.3 m+0.3],'LineWidth',2,'Color','b');
                end
            end
            axisscale=axis(gca);
            patch([AlignedTime,StimOffTime,StimOffTime,AlignedTime],[axisscale(3),axisscale(3),axisscale(4),axisscale(4)],1,...
                'facecolor','g','edgecolor','none','facealpha',0.2);  % Stim plot
            if double(RespDelay(1))
                patch([StimOffTime,RespDelayOffTime,RespDelayOffTime,StimOffTime],[axisscale(3),axisscale(3),axisscale(4),axisscale(4)],1,...
                    'facecolor',[.8 .8 .8],'edgecolor','none','facealpha',0.2);
            end
            title(sprintf('Freq-%d Corr',CurrentFreq));
            xlabel('Time (ms)');
            ylabel('# Trials');
            
            subplot(2,FreqNum,n+FreqNum);
            hold on
            ErroLickT=lick_time_struct(CurrentErroInds);
            ErroLickDif=OnsetTimeDiff(CurrentErroInds);
            ErroBiasSide=Lick_bias_side(CurrentErroInds);
            for m=1:length(ErroLickT)
                TLLT=ErroLickT(m).LickTimeLeft-ErroLickDif(m);
                TRLT=ErroLickT(m).LickTimeRight-ErroLickDif(m);
                TLLT(TLLT<0)=[];
                TRLT(TRLT<0)=[];
                scatter(TLLT,ones(length(TLLT),1)*m,15,'o','MarkerEdgeColor','k','MarkerFaceColor','b');
                scatter(TRLT,ones(length(TRLT),1)*m,15,'o','MarkerEdgeColor','k','MarkerFaceColor','r');
                if ErroBiasSide(m)
                    line([LickEndT*1000 LickEndT*1000],[m-0.3 m+0.3],'LineWidth',2,'Color','r');
                else
                    line([LickEndT*1000 LickEndT*1000],[m-0.3 m+0.3],'LineWidth',2,'Color','b');
                end
            end
            axisscale=axis(gca);
            patch([AlignedTime,StimOffTime,StimOffTime,AlignedTime],[axisscale(3),axisscale(3),axisscale(4),axisscale(4)],1,...
                'facecolor','g','edgecolor','none','facealpha',0.4);  % Stim plot
            if double(RespDelay(1))
                patch([StimOffTime,RespDelayOffTime,RespDelayOffTime,StimOffTime],[axisscale(3),axisscale(3),axisscale(4),axisscale(4)],1,...
                    'facecolor',[.8 .8 .8],'edgecolor','none','facealpha',0.4);
            end
            title(sprintf('Freq-%d Erro',CurrentFreq));
            xlabel('Time (ms)');
            ylabel('# Trials');
        end
        suptitle('Lick Time Plot');
        saveas(h_all,'Raster_plot_MT2AFC_Lick_plot.png');
        saveas(h_all,'Raster_plot_MT2AFC_Lick_plot.fig');
        close(h_all);
    end
else
    if ~(sum(behavStruct.Trial_isOptoProbeTrial) || sum(behavStruct.Trial_isOptoTraingTrial))
        %simple prob trial plot
        %Prob Trials plot
        ProbTrialInds=isProbTrial==1;
        ControlTrialInds=isProbTrial==0;
        ControlFreq=TrialFreq(ControlTrialInds);
        conTrolFreqType=unique(ControlFreq);
        ProbFreq=TrialFreq(ProbTrialInds);
        ProbFreqType=unique(ProbFreq);
        ControlLickT=lick_time_struct(ControlTrialInds);
        ProbLickT=lick_time_struct(ProbTrialInds);
        ControlTimedif=OnsetTimeDiff(ControlTrialInds);
        ProbTimeDif=OnsetTimeDiff(ProbTrialInds);
        ConTrilOutcome=(trial_outcome(ControlTrialInds))';
        ProbTrilOutcome=(trial_outcome(ProbTrialInds))';
        ControlBias=Lick_bias_side(ControlTrialInds);
        ProbBias=Lick_bias_side(ProbTrialInds);
        
        fConTrol=figure('position',[220 40 1500 900],'PaperPositionMode','auto');
        %control Trial plot
        for n=1:length(conTrolFreqType)
            CurrentCorrInds=ControlFreq==conTrolFreqType(n) & ConTrilOutcome ==1;
            CurrentErroInds=ControlFreq==conTrolFreqType(n) & ConTrilOutcome ==0;
            
            subplot(2,length(conTrolFreqType),n);
            hold on
            CorrectLickT=ControlLickT(CurrentCorrInds);
            CorrLickDif=ControlTimedif(CurrentCorrInds);
            CorrBiasSide=ControlBias(CurrentCorrInds);
            for m=1:length(CorrectLickT)
                TLLT=CorrectLickT(m).LickTimeLeft-CorrLickDif(m);
                TRLT=CorrectLickT(m).LickTimeRight-CorrLickDif(m);
                TLLT(TLLT<0)=[];
                TRLT(TRLT<0)=[];
                scatter(TLLT,ones(length(TLLT),1)*m,15,'o','MarkerEdgeColor','k','MarkerFaceColor','b');
                scatter(TRLT,ones(length(TRLT),1)*m,15,'o','MarkerEdgeColor','k','MarkerFaceColor','r');
                if CorrBiasSide(m)
                    line([LickEndT*1000 LickEndT*1000],[m-0.3 m+0.3],'LineWidth',2,'Color','r');
                else
                    line([LickEndT*1000 LickEndT*1000],[m-0.3 m+0.3],'LineWidth',2,'Color','b');
                end
            end
            axisscale=axis(gca);
            patch([AlignedTime,StimOffTime,StimOffTime,AlignedTime],[axisscale(3),axisscale(3),axisscale(4),axisscale(4)],1,...
                'facecolor','g','edgecolor','none','facealpha',0.2);  % Stim plot
            if double(RespDelay(1))
                patch([StimOffTime,RespDelayOffTime,RespDelayOffTime,StimOffTime],[axisscale(3),axisscale(3),axisscale(4),axisscale(4)],1,...
                    'facecolor',[.8 .8 .8],'edgecolor','none','facealpha',0.2);
            end
            title(sprintf('Freq-%d Corr',conTrolFreqType(n)));
            xlabel('Time (ms)');
            ylabel('# Trials');
            
            subplot(2,length(conTrolFreqType),n+length(conTrolFreqType));
            hold on
            ErroectLickT=ControlLickT(CurrentErroInds);
            ErroLickDif=ControlTimedif(CurrentErroInds);
            ErroBiasSide=ControlBias(CurrentErroInds);
            for m=1:length(CorrectLickT)
                TLLT=ErroectLickT(m).LickTimeLeft-ErroLickDif(m);
                TRLT=ErroectLickT(m).LickTimeRight-ErroLickDif(m);
                TLLT(TLLT<0)=[];
                TRLT(TRLT<0)=[];
                scatter(TLLT,ones(length(TLLT),1)*m,15,'o','MarkerEdgeColor','k','MarkerFaceColor','b');
                scatter(TRLT,ones(length(TRLT),1)*m,15,'o','MarkerEdgeColor','k','MarkerFaceColor','r');
                if ErroBiasSide(m)
                    line([LickEndT*1000 LickEndT*1000],[m-0.3 m+0.3],'LineWidth',2,'Color','r');
                else
                    line([LickEndT*1000 LickEndT*1000],[m-0.3 m+0.3],'LineWidth',2,'Color','b');
                end
            end
            axisscale=axis(gca);
            patch([AlignedTime,StimOffTime,StimOffTime,AlignedTime],[axisscale(3),axisscale(3),axisscale(4),axisscale(4)],1,...
                'facecolor','g','edgecolor','none','facealpha',0.2);  % Stim plot
            if double(RespDelay(1))
                patch([StimOffTime,RespDelayOffTime,RespDelayOffTime,StimOffTime],[axisscale(3),axisscale(3),axisscale(4),axisscale(4)],1,...
                    'facecolor',[.8 .8 .8],'edgecolor','none','facealpha',0.2);
            end
            title(sprintf('Freq-%d Erro',conTrolFreqType(n)));
            xlabel('Time (ms)');
            ylabel('# Trials');
            
            suptitle('Control Trial lick Time');
            saveas(fConTrol,'Raster_plot_Prob2AFC_ControlLick_plot.png');
            saveas(fConTrol,'Raster_plot_Prob2AFC_ControlLick_plot.fig');
            close(fConTrol);
        end
        
        %prob Trials plot
        fProb=figure('position',[220 40 1500 900],'PaperPositionMode','auto');
        for n=1:length(ProbFreqType)
            CurrentCorrInds=ProbFreq==ProbFreqType(n) & ProbTrilOutcome ==1;
            CurrentErroInds=ProbFreq==ProbFreqType(n) & ProbTrilOutcome ==0;
            
            subplot(2,length(ProbFreqType),n);
            hold on
            CorrectLickT=ProbLickT(CurrentCorrInds);
            CorrLickDif=ProbTimeDif(CurrentCorrInds);
            CorrBiasSide=ProbBias(CurrentCorrInds);
            for m=1:length(CorrectLickT)
                TLLT=CorrectLickT(m).LickTimeLeft-CorrLickDif(m);
                TRLT=CorrectLickT(m).LickTimeRight-CorrLickDif(m);
                TLLT(TLLT<0)=[];
                TRLT(TRLT<0)=[];
                scatter(TLLT,ones(length(TLLT),1)*m,15,'o','MarkerEdgeColor','k','MarkerFaceColor','b');
                scatter(TRLT,ones(length(TRLT),1)*m,15,'o','MarkerEdgeColor','k','MarkerFaceColor','r');
                if CorrBiasSide(m)
                    line([LickEndT*1000 LickEndT*1000],[m-0.3 m+0.3],'LineWidth',2,'Color','r');
                else
                    line([LickEndT*1000 LickEndT*1000],[m-0.3 m+0.3],'LineWidth',2,'Color','b');
                end
            end
            axisscale=axis(gca);
            patch([AlignedTime,StimOffTime,StimOffTime,AlignedTime],[axisscale(3),axisscale(3),axisscale(4),axisscale(4)],1,...
                'facecolor','g','edgecolor','none','facealpha',0.2);  % Stim plot
            if double(RespDelay(1))
                patch([StimOffTime,RespDelayOffTime,RespDelayOffTime,StimOffTime],[axisscale(3),axisscale(3),axisscale(4),axisscale(4)],1,...
                    'facecolor',[.8 .8 .8],'edgecolor','none','facealpha',0.2);
            end
            title(sprintf('Freq-%d Corr',ProbFreqType(n)));
            xlabel('Time (ms)');
            ylabel('# Trials');
            
            subplot(2,length(ProbFreqType),n+length(ProbFreqType));
            hold on
            ErroectLickT=ProbLickT(CurrentErroInds);
            ErroLickDif=ProbTimeDif(CurrentErroInds);
            ErroBiasSide=ProbBias(CurrentErroInds);
            for m=1:length(ErroectLickT)
                TLLT=ErroectLickT(m).LickTimeLeft-ErroLickDif(m);
                TRLT=ErroectLickT(m).LickTimeRight-ErroLickDif(m);
                TLLT(TLLT<0)=[];
                TRLT(TRLT<0)=[];
                scatter(TLLT,ones(length(TLLT),1)*m,15,'o','MarkerEdgeColor','k','MarkerFaceColor','b');
                scatter(TRLT,ones(length(TRLT),1)*m,15,'o','MarkerEdgeColor','k','MarkerFaceColor','r');
                if ErroBiasSide(m)
                    line([LickEndT*1000 LickEndT*1000],[m-0.3 m+0.3],'LineWidth',2,'Color','r');
                else
                    line([LickEndT*1000 LickEndT*1000],[m-0.3 m+0.3],'LineWidth',2,'Color','b');
                end
            end
            axisscale=axis(gca);
            patch([AlignedTime,StimOffTime,StimOffTime,AlignedTime],[axisscale(3),axisscale(3),axisscale(4),axisscale(4)],1,...
                'facecolor','g','edgecolor','none','facealpha',0.2);  % Stim plot
            if double(RespDelay(1))
                patch([StimOffTime,RespDelayOffTime,RespDelayOffTime,StimOffTime],[axisscale(3),axisscale(3),axisscale(4),axisscale(4)],1,...
                    'facecolor',[.8 .8 .8],'edgecolor','none','facealpha',0.2);
            end
            title(sprintf('Freq-%d Erro',ProbFreqType(n)));
            xlabel('Time (ms)');
            ylabel('# Trials');
            
            suptitle('Control Trial lick Time');
            saveas(fProb,'Raster_plot_Prob2AFC_ProbLick_plot.png');
            saveas(fProb,'Raster_plot_Prob2AFC_ProbLick_plot.fig');
            close(fProb);
        end
    else
        %plot control opto trials and prob opto trials
        %this can be modulated into two different modulations and compare
        %the modulation effect to mouse lick
        %ProbTrials
        ProbTrialInds=behavResults.Trial_isProbeTrial == 1;
        ProbOptoTrials=behavResults.Trial_isOptoProbeTrial(ProbTrialInds);
        ProbFreq=TrialFreq(ProbTrialInds);
        ProbFreqType=unique(ProbFreq);
        ProbLickT=lick_time_struct(ProbTrialInds);
        ProbTimeDif=OnsetTimeDiff(ProbTrialInds);
        ProbBias=Lick_bias_side(ProbTrialInds);
        ProbTrialOutcome=(trial_outcome(ProbTrialInds))';
        %figure 1: within prob trials: corr opto trials vs corr non-opto
        corrDataOptoInds=ProbTrialOutcome==1 & ProbOptoTrials==1;
        corrDataNonoptoInds=ProbTrialOutcome==1 & ProbOptoTrials==0;
        
        h1=figure('position',[220 40 1500 900],'PaperPositionMode','auto');
        for n=1:length(ProbFreqType)
            subplot(2,length(ProbFreqType),n);
            ProbCorrDataFreq=ProbFreq(corrDataOptoInds);
            ProbCorrDataLickT=ProbLickT(corrDataOptoInds);
            ProbCorrDataTimeDif=ProbTimeDif(corrDataOptoInds);
            ProbCorrDataBias=ProbBias(corrDataOptoInds);
            
            currentFreq=ProbFreqType(n);
            CurrentInds=ProbCorrDataFreq==currentFreq;
            CDataLickT=ProbCorrDataLickT(CurrentInds);
            CDataTimeDif=ProbCorrDataTimeDif(CurrentInds);
            CDataBias=ProbCorrDataBias(CurrentInds);
            for m=1:length(CDataLickT)
                TLLT=CDataLickT(m).LickTimeLeft-CDataTimeDif(m);
                TRLT=CDataLickT(m).LickTimeRight-CDataTimeDif(m);
                TLLT(TLLT<0)=[];
                TRLT(TRLT<0)=[];
                scatter(TLLT,ones(length(TLLT),1)*m,15,'o','MarkerEdgeColor','k','MarkerFaceColor','b');
                scatter(TRLT,ones(length(TRLT),1)*m,15,'o','MarkerEdgeColor','k','MarkerFaceColor','r');
                if CDataBias(m)
                    line([LickEndT*1000 LickEndT*1000],[m-0.3 m+0.3],'LineWidth',2,'Color','r');
                else
                    line([LickEndT*1000 LickEndT*1000],[m-0.3 m+0.3],'LineWidth',2,'Color','b');
                end
            end
            axisscale=axis(gca);
            patch([AlignedTime,StimOffTime,StimOffTime,AlignedTime],[axisscale(3),axisscale(3),axisscale(4),axisscale(4)],1,...
                'facecolor','g','edgecolor','none','facealpha',0.2);  % Stim plot
            if double(RespDelay(1))
                patch([StimOffTime,RespDelayOffTime,RespDelayOffTime,StimOffTime],[axisscale(3),axisscale(3),axisscale(4),axisscale(4)],1,...
                    'facecolor',[.8 .8 .8],'edgecolor','none','facealpha',0.2);
            end
            title(sprintf('Freq-%d Erro',ProbFreqType(n)));
            xlabel('Time (ms)');
            ylabel('# Trials');
        end
        %figure 2: within prob trials: erro opto trials vs erro non-opto
        
        
        %figure 3: Non prob trials: corr opto trials vs corr non-opto
        
        
        %figure 3: Non prob trials: erro opto trials vs erro non-opto
    end
end

