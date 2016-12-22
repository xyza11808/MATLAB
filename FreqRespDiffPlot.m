function varargout = FreqRespDiffPlot(AlignData,TrialFreq,Timescale,FrameRate,OnsetFrame,varargin)
% this function is to plot different response of same ROI to different
% frequency, and to see what are the differences

isPlot = 1;
if ~isempty(varargin)
    isPlot = varargin{1};
end
    
[Trialnum,ROINum,FrameNum] = size(AlignData);
if isempty(Timescale)
    error('No time scale is given, quit analysis.');
end

if ~iscell(Timescale)
    error('Input time scale must be in cell mode, please check your input fata format.');
end
TimeScaleNum = length(Timescale);
if TimeScaleNum > 1
    fprintf('Multi-timescale input, will process the comparation one by one.\n');
end

FreqType = double(unique(TrialFreq));
FreqTypeNum = length(FreqType);
OctaceInds=log2(FreqType/min(FreqType));
CorrStimTypeTick = FreqType/1000;
if mod(FreqTypeNum,2)
    error('Input frequency type can not be a odd number.\n');
end
ColorSelect = jet(64);
ColorIndsL = round(linspace(1,20,FreqTypeNum/2));
ColorIndsR = round(linspace(44,64,FreqTypeNum/2));
ColorInds = [ColorIndsL,ColorIndsR];

if isPlot
    if ~isdir('./Freq_resp_plot/')
        mkdir('./Freq_resp_plot/');
    end
    cd('./Freq_resp_plot/');
else
    % storing different time scale data in one matrix
    TotalTimeWinData = zeros(TimeScaleNum,ROINum,FreqTypeNum);
end

for nTime = 1 : TimeScaleNum
    cTimeScale = Timescale{nTime};
    
        if length(cTimeScale) == 1
            FrameScale = [OnsetFrame+1,OnsetFrame+round(cTimeScale*FrameRate)];
            if isPlot
                if ~isdir(['./TimeScale_' num2str(cTimeScale) 's/'])
                    mkdir(['./TimeScale_' num2str(cTimeScale) 's/']);
                end
                cd(['./TimeScale_' num2str(cTimeScale) 's/']);
            end
        else
            FrameScale = [OnsetFrame+round(cTimeScale(1)*FrameRate),OnsetFrame+round(cTimeScale(2)*FrameRate)];
            if isPlot
                if ~isdir(['./TimeScale_' num2str(cTimeScale(1)) '-' num2str(cTimeScale(2)) 's/'])
                    mkdir(['./TimeScale_' num2str(cTimeScale(1)) '-' num2str(cTimeScale(2)) 's/']);
                end
                cd(['./TimeScale_' num2str(cTimeScale(1)) '-' num2str(cTimeScale(2)) 's/']);
            end
        end

    if FrameScale(2) > FrameNum
        fprintf('Selected time scale out of matrix index, reset to maxium index.\n');
        FrameScale(2) = FrameNum;
    end
%     AlignedMeanTarace = squeeze(mean())
    SelectData = AlignData(:,:,FrameScale(1):FrameScale(2));
    FreqmeanData = zeros(FreqTypeNum,ROINum,size(SelectData,3));
    AlignedMeanTarace = zeros(FreqTypeNum,ROINum,size(AlignData,3));
    xTickTime = (1:size(AlignData,3))/FrameRate;
    OnsetTime = OnsetFrame / FrameRate;
    for nFreq = 1 : FreqTypeNum
        cfreqInds = TrialFreq == FreqType(nFreq);
        cfreqData = SelectData(cfreqInds,:,:);
        if sum(cfreqInds) > 1
            cfreqMeanData = squeeze(mean(cfreqData));
        else
            cfreqMeanData = squeeze(cfreqData);
        end
        FreqmeanData(nFreq,:,:) = cfreqMeanData;
        
        CDataAll = AlignData(cfreqInds,:,:);
        if size(CDataAll) > 1
            AlignedMeanTarace(nFreq,:,:) = squeeze(mean(CDataAll));
        else
            AlignedMeanTarace(nFreq,:,:) = squeeze(CDataAll);
        end
    end
    WinData = squeeze(mean(FreqmeanData,3)); % nFreq by nROI
    if isPlot
        TDindex = zeros(ROINum,1);
        CIindex = zeros(ROINum,1);
        CIindexM2 = zeros(ROINum,1);
        LLargeThanR = zeros(ROINum,1);
        for nROI = 1 : ROINum
            cROIData = squeeze(AlignedMeanTarace(:,nROI,:));
            cROIDataSmooth = zeros(size(cROIData));
            h_ROI = figure('position',[450,150,900,800],'paperpositionmode','auto');
            subplot(2,1,1)
            hold on;
            LegendText = cell(1,FreqTypeNum);
            for nTrace = 1 : FreqTypeNum
                plot(xTickTime,cROIData(nTrace,:),'color',ColorSelect(ColorInds(nTrace),:),'LineWidth',1.8);
%                 text(OnsetTime+1,cROIData(nTrace,(OnsetFrame+FrameRate)),num2str(FreqType(nTrace)),'FontSize',14,...
%                     'color',ColorSelect(ColorInds(nTrace),:));
                LegendText(nTrace) = {sprintf('%.3f KHz',FreqType(nTrace)/1000)}; 
                cROIDataSmooth(nTrace,:) = smooth(cROIData(nTrace,:),7);
            end
            legend(LegendText);
            yaxiss = axis;
            line([OnsetTime OnsetTime],[yaxiss(3) yaxiss(4)],'LineWidth',1.4,'color',[.8 .8 .8]);
            WinTime = FrameScale/FrameRate;
            patch([WinTime(1) WinTime(2) WinTime(2) WinTime(1)],[yaxiss(3) yaxiss(3) yaxiss(4) yaxiss(4)],1,'facecolor','g','edgecolor','none','facealpha',0.5);
            xlabel('Time(s)');
            ylabel('\DeltaF/F_0(%)');
%             set(gca,'fontsize',18);
            
            % using the seven values between max as response value
            % directly using smoothed max value, 
            FreqValue = max(cROIDataSmooth(:,FrameScale(1):FrameScale(2)),[],2);
            % calculating the tuning depth index and CI
            if ~mod(FreqTypeNum,2)
                LeftFreqResps = FreqValue(1:(FreqTypeNum/2));
                RightFreqResps = FreqValue(((FreqTypeNum/2)+1):end);
                [MaxResp,~] = max(FreqValue);
            else
                LeftFreqResps = FreqValue(1:floor(FreqTypeNum/2));
                RightFreqResps = FreqValue((ceil(FreqTypeNum/2)+1):end);
                TempFreqv = FreqValue;
                TempFreqv(ceil(FreqTypeNum/2)) = [];
                [MaxResp,~] = max(TempFreqv);
            end
            if mean(RightFreqResps) >= mean(LeftFreqResps)
                PreferSide = RightFreqResps;
                NullSide = LeftFreqResps;
            else
                PreferSide = LeftFreqResps;
                NullSide = RightFreqResps;
            end
            SSpref = sqrt(sum((PreferSide - mean(PreferSide)).^2));
            SSnull = sqrt(sum((NullSide - mean(NullSide)).^2));
            if MaxResp <= 10 || mean(NullSide) <= 0
                % skip calculation of assumed non-responsive cells
                TDindex(nROI) = 0;
                CIindex(nROI) = 0;
                CIindexM2(nROI) = 0;
            else
                TDindex(nROI) = (MaxResp - ((sum(FreqValue) - MaxResp)/(FreqTypeNum - 1)))/MaxResp;
%                 CIindex(nROI) = abs(mean(LeftFreqResps) - mean(RightFreqResps))/(MaxResp - min(FreqValue));
                CIindex(nROI) = max([(mean(PreferSide) - mean(NullSide))/mean(PreferSide) - (max(PreferSide) - mean(PreferSide))/max(PreferSide),0]);
                
                CIindexM2(nROI) = max([(mean(PreferSide) - mean(NullSide))/mean(PreferSide) - (abs(SSpref - SSnull)/(SSpref + SSnull)),0]);
                LLargeThanR(nROI) = (mean(LeftFreqResps) - mean(RightFreqResps)) > 0;
            end
            
            subplot(2,1,2)
            plot(OctaceInds,FreqValue,'ro','MarkerFaceColor','r','MarkerSize',20);
            set(gca,'xtick',OctaceInds,'xticklabel',cellstr(num2str(CorrStimTypeTick(:),'%.2f'))); % show real frequency value at octave position
            xlabel('Frequency(KHz)');
            ylabel('mean \DeltaF/F_0(%)');
            axisScale = axis;
            text(0.4,axisScale(4)*1.05,sprintf('TD = %.3f, CI = %.3f, CIm2 = %.3f,Meanpref = %.1f, Meannull = %.1f',...
                TDindex(nROI),CIindex(nROI),CIindexM2(nROI),mean(PreferSide),mean(NullSide)));

            suptitle(sprintf('ROI%d',nROI));
            saveas(h_ROI,sprintf('ROI%d frequency response',nROI));
            saveas(h_ROI,sprintf('ROI%d frequency response',nROI),'png');
            close(h_ROI);
            
            
        end
        save FreqMeanData.mat AlignedMeanTarace FreqType WinData TDindex CIindex CIindexM2 LLargeThanR -v7.3
        cd ..;
    end
    if ~isPlot
       % if multitime scale have been input, and no figure is plotted, then
       % save different time scales data into three dimentional data set
       % for future plot
       TotalTimeWinData(nTime,:,:) = WinData'; 
       
    end
end
if isPlot
    cd ..;
end
if nargout > 0
    varargout(1) = {TotalTimeWinData};
    varargout(2) = {AlignedMeanTarace};
end